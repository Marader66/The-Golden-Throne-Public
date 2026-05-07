// stack_lib.nut — public ::StackLib.* API.
//
// Definition-driven. Consumer flow:
//   1. ::StackLib.register({ id="mod.foo", kind=..., ... })   — once at preload
//   2. ::StackLib.add(actor, "mod.foo", n)                    — at runtime
//   3. ::StackLib.get(actor, "mod.foo")                       — read
//
// IDs MUST be lowercase, dot-separated, with at least one dot
// ("modid.stackname"). Validation rejects collisions and bare strings.

// ── Helpers ─────────────────────────────────────────────────────────────

local function actorKey(_actor) {
    if (_actor == null) return null;
    // getIDString is the persistent identity (vs getID which is per-instance
    // and unstable across world re-creation). Confirmed across BB code.
    try { return _actor.getIDString(); } catch (e) {}
    try { return "" + _actor.getID(); } catch (e) {}
    return null;
}

local function flagKey(_actorKey, _stackID) {
    return "StackLib." + _actorKey + "." + _stackID;
}

local function tierKey(_actorKey, _stackID) {
    return "StackLib." + _actorKey + "." + _stackID + ".tier_seen";
}

local function validateID(_id) {
    if (_id == null || typeof _id != "string") return false;
    if (_id.find(".") == null) return false;  // require at least one dot
    return true;
}

local function getDef(_id) {
    if (!(_id in ::StackLib.Defs)) {
        ::logWarning("[StackLib] unknown stack id: " + _id);
        return null;
    }
    return ::StackLib.Defs[_id];
}

local function clamp(_v, _min, _max) {
    if (_max != null && _v > _max) return _max;
    if (_min != null && _v < _min) return _min;
    return _v;
}

local function readLegacy(_actor, _def) {
    if (_def.LegacyField == null) return null;
    try {
        foreach (sk in _actor.getSkills().m.Skills) {
            if (sk == null) continue;
            if (_def.LegacyField in sk.m) return sk.m[_def.LegacyField];
        }
    } catch (e) {}
    return null;
}

// ── Registration ────────────────────────────────────────────────────────

::StackLib.register <- function (_opts) {
    if (!("id" in _opts) || !validateID(_opts.id)) {
        ::logWarning("[StackLib] register: invalid id (need lowercase dotted string): "
            + (("id" in _opts) ? _opts.id : "<missing>"));
        return null;
    }
    local def = {
        ID          = _opts.id,
        Kind        = ("kind"        in _opts) ? _opts.kind        : ::StackLib.Kind.Combat,
        Max         = ("max"         in _opts) ? _opts.max         : null,
        Min         = ("min"         in _opts) ? _opts.min         : 0,
        OnOverflow  = ("onOverflow"  in _opts) ? _opts.onOverflow  : "clip",
        RolloverTo  = ("rolloverTo"  in _opts) ? _opts.rolloverTo  : null,
        Decay       = ("decay"       in _opts) ? _opts.decay       : null,
        ResetOn     = ("resetOn"     in _opts) ? _opts.resetOn     : ["combatStart","combatEnd"],
        Tiers       = ("tiers"       in _opts) ? _opts.tiers       : null,
        OnTier      = ("onTier"      in _opts) ? _opts.onTier      : null,
        LegacyField = ("legacyField" in _opts) ? _opts.legacyField : null
    };
    ::StackLib.Defs[_opts.id] <- def;
    return _opts.id;
};

// ── Read ────────────────────────────────────────────────────────────────

::StackLib.get <- function (_actor, _id) {
    local def = getDef(_id); if (def == null) return 0;
    local key = actorKey(_actor); if (key == null) return def.Min;

    if (def.Kind == ::StackLib.Kind.Persistent) {
        local fk = flagKey(key, _id);
        if (::World != null && ::World.Flags.get(fk) != null) {
            return ::World.Flags.getAsInt(fk);
        }
        // First read — try legacy field migration.
        local legacy = readLegacy(_actor, def);
        if (legacy != null) {
            try { ::World.Flags.set(fk, legacy); } catch (e) {}
            // v0.1.1: seed tier_seen on legacy migration so existing campaigns
            // don't re-fire tier callbacks for tiers already crossed pre-refactor.
            if (def.Tiers != null) {
                local migrated_tier = 0;
                foreach (i, threshold in def.Tiers) {
                    if (legacy >= threshold) migrated_tier = i + 1;
                }
                try { ::World.Flags.set(tierKey(key, _id), migrated_tier); } catch (e) {}
            }
            return legacy;
        }
        return def.Min;
    }

    // Combat
    if (!(key in ::StackLib.CombatStore)) return def.Min;
    if (!(_id in ::StackLib.CombatStore[key])) return def.Min;
    return ::StackLib.CombatStore[key][_id];
};

::StackLib.getMax <- function (_id) {
    local def = getDef(_id); if (def == null) return 0;
    return def.Max != null ? def.Max : 9999;
};

// Returns 0 if no tiers defined or count below tier[0]; else returns the
// 1-based index of the highest tier reached.
::StackLib.getTier <- function (_actor, _id) {
    local def = getDef(_id); if (def == null) return 0;
    if (def.Tiers == null) return 0;
    local count = ::StackLib.get(_actor, _id);
    local tier = 0;
    foreach (i, threshold in def.Tiers) {
        if (count >= threshold) tier = i + 1;
    }
    return tier;
};

// ── Mutate ──────────────────────────────────────────────────────────────

local function writeCount(_actor, _id, _newValue) {
    local def = getDef(_id); if (def == null) return 0;
    local key = actorKey(_actor); if (key == null) return 0;

    local clamped = clamp(_newValue, def.Min, def.Max);

    if (def.Kind == ::StackLib.Kind.Persistent) {
        if (::World != null) {
            try { ::World.Flags.set(flagKey(key, _id), clamped); } catch (e) {}
        }
    } else {
        if (!(key in ::StackLib.CombatStore)) ::StackLib.CombatStore[key] <- {};
        ::StackLib.CombatStore[key][_id] <- clamped;
    }

    // Tier callback dispatch — Persistent only, fired on transition into
    // a new highest tier. tier_seen world flag prevents re-fire on save-load.
    if (def.Kind == ::StackLib.Kind.Persistent && def.Tiers != null && def.OnTier != null) {
        local newTier = 0;
        foreach (i, threshold in def.Tiers) {
            if (clamped >= threshold) newTier = i + 1;
        }
        if (::World != null && newTier > 0) {
            local tk = tierKey(key, _id);
            local seenTier = 0;
            try { seenTier = ::World.Flags.getAsInt(tk); } catch (e) {}
            if (newTier > seenTier) {
                try {
                    ::World.Flags.set(tk, newTier);
                    def.OnTier(_actor, newTier, seenTier);
                } catch (e) {
                    ::logWarning("[StackLib] tier callback for " + _id + " threw: " + e);
                }
            }
        }
    }

    return clamped;
};

::StackLib.add <- function (_actor, _id, _amount = 1) {
    local current = ::StackLib.get(_actor, _id);
    return writeCount(_actor, _id, current + _amount);
};

::StackLib.set <- function (_actor, _id, _value) {
    return writeCount(_actor, _id, _value);
};

::StackLib.consume <- function (_actor, _id) {
    local def = getDef(_id); if (def == null) return 0;
    local current = ::StackLib.get(_actor, _id);
    writeCount(_actor, _id, def.Min);
    return current;
};

::StackLib.reset <- function (_actor, _id) {
    return ::StackLib.consume(_actor, _id);
};

// ── Maintenance ────────────────────────────────────────────────────────

// Wipe all Combat-kind stacks for an actor. Called by combat_hooks on
// combatStarted/combatFinished depending on each def's ResetOn list.
::StackLib.clearCombat <- function (_actor, _trigger) {
    local key = actorKey(_actor); if (key == null) return;
    if (!(key in ::StackLib.CombatStore)) return;

    local store = ::StackLib.CombatStore[key];
    local toWipe = [];
    foreach (id, _ in store) {
        local def = getDef(id);
        if (def == null) continue;
        if (def.Kind != ::StackLib.Kind.Combat) continue;
        if (def.ResetOn != null && def.ResetOn.find(_trigger) != null) {
            toWipe.push(id);
        }
    }
    foreach (id in toWipe) {
        delete store[id];
    }
    if (store.len() == 0) delete ::StackLib.CombatStore[key];
};

// ── Tooltip helper (opt-in) ────────────────────────────────────────────

::StackLib.tooltipRow <- function (_actor, _id, _opts = null) {
    if (_opts == null) _opts = {};
    local def = getDef(_id); if (def == null) return null;
    local count = ::StackLib.get(_actor, _id);
    local label = ("label" in _opts) ? _opts.label : _id;
    local color = ("color" in _opts) ? _opts.color : "#E0C070";
    local maxStr = (def.Max != null) ? (" / " + def.Max) : "";
    return {
        id   = ("id" in _opts) ? _opts.id : 50,
        type = "text",
        icon = ("icon" in _opts) ? _opts.icon : "ui/icons/special.png",
        text = "[color=" + color + "]" + label + "[/color]: " + count + maxStr
    };
};
