::GoldenThrone <- {
	ID = "mod_golden_throne",
	Version = "2.14.11",
	Name = "The Golden Throne"
};

::GoldenThrone.Hooks <- ::Hooks.register(::GoldenThrone.ID, ::GoldenThrone.Version, ::GoldenThrone.Name);

// ── Dependencies (shared convention across my mods) ───────────────────
// Required: Modern Hooks blocks load with a visible error if any are
// missing or below the listed version. Same gate Jimmy's Tooltips uses.
// TestedAgainst: soft — I paired this build with these versions. Drift
// is logged as a warning so a tester's log shows what I expected vs what
// they have. Not a block.
// SaveCompatFrom: lowest version of this mod whose save files still load
// in this build. Purely informational; no runtime check after the fact.
::GoldenThrone.Deps <- {
	Required = {
		mod_legends      = "19.3.17",
		mod_ROTUC        = "3.0.2",
		mod_msu          = "1.2.7",
		mod_modern_hooks = "0.4.0"
	},
	TestedAgainst = {
		mod_fury_of_the_northmen = "0.5.43",
		mod_PoV                  = "4.1.0",
		mod_nggh_magic_concept   = "3.0.0-beta.90"
	},
	SaveCompatFrom = "2.8.0"
};

// Deps.Required stays as documentation but no hard-require call —
// testers mix versions to diagnose bugs; blocking load at version
// mismatch gets in the way. Missing deps surface at use-time.

::GoldenThrone.checkDeps <- function () {
	local prefix = "[" + ::GoldenThrone.ID + " v" + ::GoldenThrone.Version + "]";
	local tested = [];
	local drifts = [];
	foreach (modID, wantVer in ::GoldenThrone.Deps.TestedAgainst) {
		if (!::Hooks.hasMod(modID)) continue;
		local mod = ::Hooks.getMod(modID);
		local haveVer   = mod.getVersionString();
		local shortName = modID.find("mod_") == 0 ? modID.slice(4) : modID;
		tested.push(shortName + " " + wantVer);
		// String-equality short-circuit first — fixes same-version false-
		// positive drift (Abyss 11.7 log 2026-04-24). Only invoke SemVer
		// calls when both sides are valid semver, so non-semver versions
		// like Black Pyramid "0.1" don't spam MSU's warning.
		local matched = (haveVer == wantVer);
		if (!matched) {
			local bothSemver = false;
			try { bothSemver = ::MSU.SemVer.isSemVer(haveVer) && ::MSU.SemVer.isSemVer(wantVer); } catch (e) {}
			if (bothSemver) {
				try { matched = ::MSU.SemVer.compareVersionWithOperator(haveVer, "==", wantVer); } catch (e) {}
			}
		}
		if (!matched) {
			local note = "version compare inconclusive";
			local bothSemver = false;
			try { bothSemver = ::MSU.SemVer.isSemVer(haveVer) && ::MSU.SemVer.isSemVer(wantVer); } catch (e) {}
			if (bothSemver) {
				try {
					note = ::MSU.SemVer.compareVersionWithOperator(haveVer, ">", wantVer)
						? "you're newer, probably fine"
						: "you're older, could miss fixes";
				} catch (e) {}
			}
			drifts.push(modID + ": you have " + haveVer + ", I tested with " + wantVer + " (" + note + ").");
		}
	}
	local summary = "";
	for (local i = 0; i < tested.len(); i++) summary += (i > 0 ? ", " : "") + tested[i];
	if (summary == "") summary = "no soft-tracked mods present";
	::logInfo(prefix + " Tested against " + summary + ". Save-compat from v" + ::GoldenThrone.Deps.SaveCompatFrom + ".");
	foreach (d in drifts) ::logWarning(prefix + " " + d);
};

// ── Inherit helpers (v2.12.2) ─────────────────────────────────────────
// Class-derivation helpers that return delta-tables for `::inherit(...)`.
// Pattern lifted from Reforged's mod_reforged/inherit_helper.nut + audit
// recommendation 2026-05-02. Reduces boilerplate for groups of similar
// subclasses (e.g. weather effects, future racial-style traits).
//
// Usage:
//   this.my_class <- ::inherit("scripts/skills/skill",
//       ::GoldenThrone.InheritHelper.snowEffect({ id = "blizzard", ... }));
::GoldenThrone.InheritHelper <- {};

// snowEffect — builds a status-effect class that applies a fixed set of
// stat deltas. Used by the 4 weather effect files (light/heavy/blizzard/night).
// Saves ~16 lines per effect file (~64 total). Adding a 5th snow tier
// (e.g. "freezing") becomes ~6 lines instead of 23.
::GoldenThrone.InheritHelper.snowEffect <- function (_def) {
    return {
        m = {},
        function create() {
            this.m.ID = "effects.golden_snow_" + _def.id;
            this.m.Name = _def.name;
            this.m.Description = _def.description;
            this.m.Icon = "skills/status_effect_109.png";
            this.m.IconMini = "status_effect_109_mini";
            this.m.Type = this.Const.SkillType.StatusEffect;
            this.m.Order = this.Const.SkillOrder.Perk;
            this.m.IsSerialized = false;
            this.m.IsActive = false;
            this.m.IsStacking = false;
            this.m.IsHidden = false;
            this.m.IsRemovedAfterBattle = true;
        }
        function onUpdate(_properties) {
            // Defensive: only apply deltas for keys that exist on _properties.
            // Catches typo'd stat names without crashing the per-tick update.
            foreach (k, v in _def.statDeltas) {
                if (k in _properties) _properties[k] += v;
            }
        }
    };
};

// v2.14.1-alpha — sandstorm equivalent of snowEffect. Same shape, different
// ID prefix, different default icon (status_effect_098 = sand-tinted vanilla
// brush). Used by 3 sandstorm effect files (light/heavy/full).
::GoldenThrone.InheritHelper.sandstormEffect <- function (_def) {
    return {
        m = {},
        function create() {
            this.m.ID = "effects.golden_sandstorm_" + _def.id;
            this.m.Name = _def.name;
            this.m.Description = _def.description;
            this.m.Icon = "skills/status_effect_109.png";
            this.m.IconMini = "status_effect_109_mini";
            this.m.Type = this.Const.SkillType.StatusEffect;
            this.m.Order = this.Const.SkillOrder.Perk;
            this.m.IsSerialized = false;
            this.m.IsActive = false;
            this.m.IsStacking = false;
            this.m.IsHidden = false;
            this.m.IsRemovedAfterBattle = true;
        }
        function onUpdate(_properties) {
            foreach (k, v in _def.statDeltas) {
                if (k in _properties) _properties[k] += v;
            }
        }
    };
};

// ── Oath registry (v2.12.3) ───────────────────────────────────────────
// One row per oath type. Drives golden_oath_trait's getName/getDescription/
// getTooltip/_iconForOath/_applyOathEffects + per-oath hook dispatch.
// Replaces the 8-arm switch statements with table lookups so each oath's
// data lives in one place. Kabu's 8-Oath system v2.10.8.
//
// Row schema:
//   name          string   — colorized in trait.getName
//   description   string   — returned by trait.getDescription
//   icon          string   — bound to m.Icon via setOathType
//   getTooltipRows(_trait, _mult) -> array of {id, type, icon, text}
//   applyStats(_trait, _properties, _mult) -> void
// Optional hook fields (omit when not used by that oath):
//   onTurnStart(_trait, _actor)
//   onBeforeDamageReceived(_trait, _attacker, _skill, _properties)
//   onCombatStarted(_trait)
//   onCombatFinished(_trait)
//   onAnySkillUsed(_trait, _skill, _targetEntity, _properties)
//
// All hook fns receive the trait instance as the first arg; the trait
// dispatcher calls them positionally. `this` inside each fn is the row
// table, not the trait — utility helpers like _bothHandsEmpty() must be
// invoked via _trait.X.
::GoldenThrone.OathRegistry <- [
    // 0 — Steel ─ blade-discipline
    {
        name        = "Oath of Steel",
        description = "Sworn to the edge. This brother has pledged his blade to the Emperor's cause — every strike carries the weight of that oath.",
        icon        = "ui/perks/lionheart.png",
        getTooltipRows = function (_trait, _mult) {
            return [
                { id=10, type="text", icon="ui/icons/melee_skill.png",
                  text = "[color=#FFD700]+8[/color] Melee Skill" },
                { id=11, type="text", icon="ui/icons/damage_dealt.png",
                  text = "[color=#FFD700]+10%[/color] Melee damage" },
                { id=12, type="text", icon="ui/icons/special.png",
                  text = "[color=#FFD700]+1[/color] Action Point" }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            _properties.MeleeSkill      += (8 * _mult).tointeger();
            _properties.MeleeDamageMult *= (1.0 + 0.10 * _mult);
            _properties.ActionPoints    += 1;  // +1 stays +1 across tiers
        }
    },
    // 1 — Stone ─ wall-discipline
    {
        name        = "Oath of Stone",
        description = "Sworn to hold. This brother has pledged to stand between the Emperor's enemies and those in his care, no matter the cost.",
        icon        = "ui/perks/anchor.png",
        getTooltipRows = function (_trait, _mult) {
            return [
                { id=10, type="text", icon="ui/icons/armor_body.png",
                  text = "[color=#FFD700]+15%[/color] Armour (body and head)" },
                { id=11, type="text", icon="ui/icons/melee_defense.png",
                  text = "[color=#FFD700]+8[/color] Melee Defense, [color=#FFD700]+8[/color] Ranged Defense" },
                { id=12, type="text", icon="ui/icons/damage_received.png",
                  text = "[color=#FFD700]-10%[/color] damage received" }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            _properties.ArmorMult[0]            *= (1.0 + 0.15 * _mult);
            _properties.ArmorMult[1]            *= (1.0 + 0.15 * _mult);
            _properties.MeleeDefense            += (8 * _mult).tointeger();
            _properties.RangedDefense           += (8 * _mult).tointeger();
            _properties.DamageReceivedTotalMult *= (1.0 - 0.10 * _mult);
        }
    },
    // 2 — Light ─ anti-unholy
    {
        name        = "Oath of Light",
        description = "Sworn to the light. This brother has pledged to carry the Emperor's divine fire, burning back the unholy wherever it stirs.",
        icon        = "ui/perks/holyfire_circle.png",
        getTooltipRows = function (_trait, _mult) {
            return [
                { id=10, type="text", icon="ui/icons/bravery.png",
                  text = "[color=#FFD700]+15[/color] Resolve" },
                { id=11, type="text", icon="ui/icons/morale.png",
                  text = "Morale effects reduced by [color=#FFD700]50%[/color]." },
                { id=12, type="text", icon="ui/icons/special.png",
                  text = "Deals [color=#FFD700]+20%[/color] damage to undead, beasts and monstrous foes." }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            _properties.Bravery          += (15 * _mult).tointeger();
            _properties.MoraleEffectMult *= 0.5;  // BINARY — halving stays flat
        },
        onAnySkillUsed = function (_trait, _skill, _targetEntity, _properties) {
            if (::MSU.isNull(_targetEntity)) return;
            local f = _targetEntity.getFlags();
            if (f.has("undead") || f.has("beast") || f.has("monstrous")) {
                local mult = _trait._getMandateMult();
                _properties.DamageTotalMult *= (1.0 + 0.20 * mult);
            }
        }
    },
    // 3 — Fists ─ unarmed-only
    {
        name        = "Oath of Fists",
        description = "Sworn empty-handed. This brother has pledged to break the Emperor's enemies with bare fists alone, when the moment demands it.",
        icon        = "ui/perks/sunderingstrikes_circle.png",
        getTooltipRows = function (_trait, _mult) {
            return [
                { id=10, type="text", icon="ui/icons/damage_dealt.png",
                  text = "While both hands are empty: [color=#FFD700]+25%[/color] damage" },
                { id=11, type="text", icon="ui/icons/melee_skill.png",
                  text = "While both hands are empty: [color=#FFD700]+20%[/color] direct damage and armour penetration" },
                { id=12, type="text", icon="ui/icons/special.png",
                  text = "No effect when wielding a weapon." }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            if (!_trait._bothHandsEmpty()) return;
            _properties.DamageTotalMult  *= (1.0 + 0.25 * _mult);
            _properties.DamageDirectAdd  += 0.20 * _mult;
            _properties.ArmorEffectMult  *= (1.0 + 0.20 * _mult);
        }
    },
    // 4 — Vigilance ─ close-combat-crossbow / untouchable
    {
        name        = "Oath of Vigilance",
        description = "Sworn to watch. This brother has pledged the bowman's vigil, calm in close quarters, and is given to clear sight before the storm.",
        icon        = "ui/perks/lookout_circle.png",
        getTooltipRows = function (_trait, _mult) {
            return [
                { id=10, type="text", icon="ui/icons/vision.png",
                  text = "[color=#FFD700]+1[/color] Vision, [color=#FFD700]+10[/color] Initiative, [color=#FFD700]+10[/color] Maximum Fatigue, [color=#FFD700]+5[/color] Ranged Skill" },
                { id=11, type="text", icon="ui/icons/special.png",
                  text = "Cannot be hit by friendly fire." },
                { id=12, type="text", icon="ui/icons/special.png",
                  text = "At the start of each turn, if not surrounded by 3 or more adjacent enemies, gains a single charge of [color=#FFD700]Untouchable[/color]: the next attack against this brother is automatically dodged." }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            _properties.Vision              += 1;  // integer; stays +1
            _properties.RangedSkill         += (5  * _mult).tointeger();
            _properties.Initiative          += (10 * _mult).tointeger();
            _properties.FatigueEffectiveMax += (10 * _mult).tointeger();
            // friendly-fire + untouchable handled in onBeforeDamageReceived
        },
        onTurnStart = function (_trait, _actor) {
            if (_trait._countAdjacentEnemies(_actor) < 3) {
                _trait.m.HasUntouchable = true;
            }
        },
        onBeforeDamageReceived = function (_trait, _attacker, _skill, _properties) {
            local actor = _trait.getContainer().getActor();
            // Friendly-fire immunity
            if (_attacker != null && actor != null && _attacker.isAlliedWith(actor) && _attacker != actor) {
                _properties.RegularDamage = 0;
                _properties.ArmorDamage   = 0;
                return;
            }
            // Untouchable charge
            if (_trait.m.HasUntouchable) {
                _trait.m.HasUntouchable = false;
                _properties.RegularDamage = 0;
                _properties.ArmorDamage   = 0;
            }
        },
        onCombatStarted = function (_trait) {
            _trait.m.HasUntouchable = false;
        },
        onCombatFinished = function (_trait) {
            _trait.m.HasUntouchable = false;
        },
        onAnySkillUsed = function (_trait, _skill, _targetEntity, _properties) {
            if (::MSU.isNull(_targetEntity)) return;
            try {
                local actor = _trait.getContainer().getActor();
                if (actor == null || !actor.isPlacedOnMap() || !_targetEntity.isPlacedOnMap()) return;
                local dist = actor.getTile().getDistanceTo(_targetEntity.getTile());
                if (dist >= 3) {
                    local mult = _trait._getMandateMult();
                    _properties.DamageTotalMult *= (1.0 + 0.15 * mult);
                }
            } catch (e) {}
        }
    },
    // 5 — Defiance ─ stun/bleed-immune anchor
    {
        name        = "Oath of Defiance",
        description = "Sworn unyielding. This brother has pledged to break before he bends — neither stunned, nor moved, nor drained.",
        icon        = "ui/perks/battleheart_circle.png",
        getTooltipRows = function (_trait, _mult) {
            return [
                { id=10, type="text", icon="ui/icons/special.png",
                  text = "Immune to [color=#FFD700]Stun[/color] and [color=#FFD700]Bleeding[/color]" },
                { id=11, type="text", icon="ui/icons/fatigue.png",
                  text = "[color=#FFD700]+5[/color] Fatigue Recovery" },
                { id=12, type="text", icon="ui/icons/damage_received.png",
                  text = "[color=#FFD700]-10%[/color] damage received" }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            _properties.IsImmuneToStun           = true;   // BINARY
            _properties.IsImmuneToBleeding       = true;   // BINARY
            _properties.FatigueRecoveryRate     += (5 * _mult).tointeger();
            _properties.DamageReceivedTotalMult *= (1.0 - 0.10 * _mult);
        }
    },
    // 6 — Fury ─ stack-on-hit, retain across combats
    {
        name        = "Oath of Fury",
        description = "Sworn in red. This brother has pledged to take the wound and answer with greater violence — the more he bleeds, the harder he hits.",
        icon        = "ui/perks/berserker_rage_circle.png",
        getTooltipRows = function (_trait, _mult) {
            local stacks = _trait.m.FuryStacks;
            local perStackDmg = ::Math.floor(3.0 * _mult * 100) / 100.0;  // round to 2dp
            local perStackDef = ::Math.floor(2.0 * _mult * 100) / 100.0;
            return [
                { id=10, type="text", icon="ui/icons/damage_dealt.png",
                  text = "Each time hit: gain a stack of [color=#FFD700]Fury[/color] (max 20 in combat). Currently: [color=#FFD700]" + stacks + "[/color]" },
                { id=11, type="text", icon="ui/icons/special.png",
                  text = "Per stack: [color=#FFD700]+" + perStackDmg + "%[/color] damage, [color=#FFD700]-" + perStackDef + "[/color] Melee Defense, [color=#FFD700]-" + perStackDef + "[/color] Ranged Defense (scaled by Mandate tier)" },
                { id=12, type="text", icon="ui/icons/special.png",
                  text = "After combat: keeps up to 10 stacks. Loses 1 stack per world day passed." }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            local s = _trait.m.FuryStacks;
            if (s <= 0) return;
            _properties.DamageTotalMult *= (1.0 + 0.03 * _mult * s);
            _properties.MeleeDefense    -= (2 * _mult * s).tointeger();
            _properties.RangedDefense   -= (2 * _mult * s).tointeger();
        },
        onBeforeDamageReceived = function (_trait, _attacker, _skill, _properties) {
            if (_trait.m.FuryStacks < 20) _trait.m.FuryStacks += 1;
        },
        onCombatStarted = function (_trait) {
            _trait._decayFuryByElapsedDays();
        },
        onCombatFinished = function (_trait) {
            if (_trait.m.FuryStacks > 10) _trait.m.FuryStacks = 10;
            try { _trait.m.LastFuryCheckDay = ::World.getTime().Days; } catch (e) {}
        }
    },
    // 7 — Faith ─ doubled aura benefits while inside the Emperor's aura
    {
        name        = "Oath of Faith",
        description = "Sworn under the throne. This brother has pledged so deeply that the Emperor's light burns brighter on him than on his peers.",
        icon        = "ui/perks/extended_aura_circle.png",
        getTooltipRows = function (_trait, _mult) {
            return [
                { id=10, type="text", icon="ui/icons/special.png",
                  text = "When inside the Emperor's Imperial Aura, gains [color=#FFD700]doubled[/color] aura benefits:" },
                { id=11, type="text", icon="ui/icons/bravery.png",
                  text = "[color=#FFD700]+20[/color] Resolve" },
                { id=12, type="text", icon="ui/icons/melee_defense.png",
                  text = "[color=#FFD700]+10[/color] Melee Defense, [color=#FFD700]+10[/color] Ranged Defense" }
            ];
        },
        applyStats = function (_trait, _properties, _mult) {
            if (!_trait._isInsideImperialAura()) return;
            _properties.Bravery       += (20 * _mult).tointeger();
            _properties.MeleeDefense  += (10 * _mult).tointeger();
            _properties.RangedDefense += (10 * _mult).tointeger();
        }
    }
];

// ── MSU settings page (v2.13.0) ───────────────────────────────────────
// User-tunable knobs surfaced in the in-game mod settings UI:
//   - Imperial Aura base radius (default 10 tiles, +Purge IV bumps still apply)
//   - Purge Meter tier thresholds (Farseer / Frozen Consecration / Martyr's
//     Light / Expanded Presence)
//   - Oath Mandate-tier scaling intensity (multiplier on the (mult-1.0)
//     delta of golden_oath_trait._getMandateMult; intensity 0 = flat,
//     1 = default 1.05/1.10/1.15/1.20/1.25, 2 = doubled curve)
//   - Verbose log toggle
// Settings read via `::GoldenThrone.getSetting(_key, _default)` at the
// usage site so stale-value risks live near the consumer, not the registry.
::GoldenThrone.Hooks.queue(">mod_msu", function () {
	if (!("MSU" in ::getroottable()) || !("Class" in ::MSU) || !("Mod" in ::MSU.Class)) {
		::logWarning("[mod_golden_throne] MSU not available — settings page skipped");
		return;
	}
	::GoldenThrone.Mod <- ::MSU.Class.Mod(::GoldenThrone.ID, ::GoldenThrone.Version, ::GoldenThrone.Name);
	local page = ::GoldenThrone.Mod.ModSettings.addPage("General");
	page.addRangeSetting("AuraBaseRadius", 10, 6, 15, 1,
		"Imperial Aura base radius",
		"Aura radius. Purge IV +1 and Ascended Sovereign +5 stack on top.");
	page.addRangeSetting("PurgeT1",  25,  10, 100, 1,
		"Purge Tier I — Farseer",
		"Unholy kills to reveal hidden enemies inside the aura.");
	page.addRangeSetting("PurgeT2", 100,  50, 300, 1,
		"Purge Tier II — Frozen Consecration",
		"Unholy kills before consecration also chills the target.");
	page.addRangeSetting("PurgeT3", 250, 150, 500, 1,
		"Purge Tier III — Martyr's Light",
		"Unholy kills before ally death in aura heals the Emperor.");
	page.addRangeSetting("PurgeT4", 500, 300, 1000, 1,
		"Purge Tier IV — Expanded Presence",
		"Unholy kills for permanent +1 to aura radius.");
	page.addRangeSetting("OathScaling", 1.0, 0.0, 2.0, 0.1,
		"Oath Mandate-tier scaling",
		"Multiplier on Mandate-tier oath bonuses. 0 = flat, 1 = default curve, 2 = doubled.");
	page.addBooleanSetting("VerboseLog", false,
		"Verbose logging",
		"Extra log lines for Purge milestones and oath transitions.");
});

::GoldenThrone.getSetting <- function (_key, _default) {
	try {
		if (!("Mod" in ::GoldenThrone)) return _default;
		local mod = ::GoldenThrone.Mod;
		if (mod == null) return _default;
		local s = mod.ModSettings.getSetting(_key);
		if (s == null) return _default;
		return s.getValue();
	} catch (e) {}
	return _default;
};

// purgeThresholds — single source of truth for tier gates. Read by
// golden_emperor_trait's _computePurgeTier and getTooltip "next" lookup.
::GoldenThrone.purgeThresholds <- function () {
	return [
		::GoldenThrone.getSetting("PurgeT1",  25),
		::GoldenThrone.getSetting("PurgeT2", 100),
		::GoldenThrone.getSetting("PurgeT3", 250),
		::GoldenThrone.getSetting("PurgeT4", 500)
	];
};

// v2.14.0-alpha — D4 Phase A pyramid spawn helper. Called from the rumor
// event's PUSH/PRAY/DISMISS handlers. Tries to find a desert tile within
// 12-30 hex distance of the player; falls back to ANY desert tile if the
// nearby search fails. Spawns the location and (on commit paths) marks it
// discovered so the player can navigate to it.
::GoldenThrone.spawnPyramidLocation <- function (_makeDiscovered = true) {
	if (::World == null) return null;
	if (::World.Flags.get("GoldenPyramidSpawned")) return null;
	try {
		local player = ::World.State.getPlayer();
		if (player == null) return null;
		local pCoords = player.getTile().Coords;
		local mapW = ::World.getMapSize().X;
		local mapH = ::World.getMapSize().Y;

		local foundTile = null;
		// Try 200 random offsets in [12..30] hex from player; must be Desert.
		for (local attempt = 0; attempt < 200; attempt++) {
			local angle = ::Math.rand(0, 359) * 3.14159 / 180.0;
			local dist  = ::Math.rand(12, 30);
			local x = pCoords.X + ::Math.floor(dist * ::Math.cos(angle));
			local y = pCoords.Y + ::Math.floor(dist * ::Math.sin(angle));
			if (x < 2 || x >= mapW - 2 || y < 2 || y >= mapH - 2) continue;
			local tile = ::World.getTileSquare(x, y);
			if (tile == null) continue;
			if (tile.Type != ::Const.World.TerrainType.Desert) continue;
			if (tile.IsOccupied) continue;
			foundTile = tile;
			break;
		}
		// Fallback: brute-force scan for any desert tile.
		if (foundTile == null) {
			for (local y = 2; y < mapH - 2 && foundTile == null; y++) {
				for (local x = 2; x < mapW - 2; x++) {
					local tile = ::World.getTileSquare(x, y);
					if (tile == null) continue;
					if (tile.Type != ::Const.World.TerrainType.Desert) continue;
					if (tile.IsOccupied) continue;
					foundTile = tile;
					break;
				}
			}
		}
		if (foundTile == null) {
			::logWarning("[gt pyramid] no desert tile found; pyramid not spawned");
			return null;
		}

		local loc = ::World.spawnLocation("scripts/entity/world/locations/golden_pyramid_location", foundTile.Coords);
		if (loc == null) {
			::logWarning("[gt pyramid] spawnLocation returned null");
			return null;
		}
		::World.Flags.set("GoldenPyramidSpawned", true);
		if (_makeDiscovered) {
			loc.setDiscovered(true);
			loc.onDiscovered();
			::World.uncoverFogOfWar(foundTile.Pos, 800);
		}
		::logInfo("[gt pyramid] spawned at desert tile (" + foundTile.Coords.X + ", " + foundTile.Coords.Y + ")"
			+ (_makeDiscovered ? " — discovered" : " — hidden"));
		return loc;
	} catch (e) {
		::logWarning("[gt pyramid] spawn helper threw: " + e);
	}
	return null;
};

// ── Snow weather system (v2.8.0) ──────────────────────────────────────
// On Golden Throne combat start, if the world tile is appropriate for
// snow (Snow / SnowHills / Tundra / Mountains), roll severity:
//   45% Light, 30% Heavy, 25% Blizzard.
// If the roll hits Blizzard AND combat starts at night, also apply the
// night-bonus effect (double-dip). All effects apply to every combatant
// on the field, ally and enemy alike — snow doesn't pick sides.

::GoldenThrone.isSnowAppropriateTerrain <- function (_tile) {
	if (_tile == null) return false;
	local t = null;
	try { t = _tile.Type; } catch (e) { return false; }
	local appropriate = [];
	local tt = this.Const.World.TerrainType;
	try { if ("Snow" in tt) appropriate.push(tt.Snow); } catch (e) {}
	try { if ("SnowHills" in tt) appropriate.push(tt.SnowHills); } catch (e) {}
	try { if ("Tundra" in tt) appropriate.push(tt.Tundra); } catch (e) {}
	try { if ("Mountains" in tt) appropriate.push(tt.Mountains); } catch (e) {}
	foreach (ok in appropriate) {
		if (t == ok) return true;
	}
	return false;
};

::GoldenThrone.applySnowVisuals <- function (_severity) {
	try {
		local weather = this.Tactical.getWeather();
		local rain = weather.createRainSettings();
		local clouds = weather.createCloudSettings();

		// Pick visuals by severity
		if (_severity == "light") {
			weather.setAmbientLightingColor(this.createColor(this.Const.Tactical.AmbientLightingColor.LightRain));
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.LightRain);
			rain.MinDrops = 150; rain.MaxDrops = 200;
			rain.NumSplats = 0;
			rain.MinVelocity = 150.0; rain.MaxVelocity = 300.0;
			rain.MinAlpha = 0.4; rain.MaxAlpha = 0.7;
			rain.MinScale = 1.0; rain.MaxScale = 2.5;
		}
		else if (_severity == "heavy") {
			weather.setAmbientLightingColor(this.createColor(this.Const.Tactical.AmbientLightingColor.LightRain));
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.LightRain);
			rain.MinDrops = 300; rain.MaxDrops = 350;
			rain.NumSplats = 0;
			rain.MinVelocity = 250.0; rain.MaxVelocity = 450.0;
			rain.MinAlpha = 0.6; rain.MaxAlpha = 0.9;
			rain.MinScale = 1.0; rain.MaxScale = 3.0;
		}
		else { // blizzard
			weather.setAmbientLightingColor(this.createColor(this.Const.Tactical.AmbientLightingColor.Storm));
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.Storm);
			rain.MinDrops = 500; rain.MaxDrops = 500;
			rain.NumSplats = 0;
			rain.MinVelocity = 400.0; rain.MaxVelocity = 600.0;
			rain.MinAlpha = 0.9; rain.MaxAlpha = 1.0;
			rain.MinScale = 1.5; rain.MaxScale = 3.5;
		}
		rain.clearDropBrushes();
		rain.addDropBrush("snow_particle_02");
		rain.addDropBrush("snow_particle_03");
		rain.addDropBrush("snow_particle_04");
		weather.buildRain(rain);

		clouds.Type = this.getconsttable().CloudType.Custom;
		clouds.MinClouds = (_severity == "blizzard") ? 220 : (_severity == "heavy" ? 150 : 80);
		clouds.MaxClouds = clouds.MinClouds;
		clouds.MinVelocity = 400.0; clouds.MaxVelocity = 500.0;
		clouds.MinAlpha = 0.6; clouds.MaxAlpha = 1.0;
		clouds.MinScale = 1.0; clouds.MaxScale = 4.0;
		clouds.Sprite = "wind_01";
		clouds.RandomizeDirection = false;
		clouds.RandomizeRotation = false;
		clouds.Direction = this.createVec(-1.0, -0.7);
		weather.buildCloudCover(clouds);

		this.Sound.setAmbience(0, this.Const.SoundAmbience.Blizzard, this.Const.Sound.Volume.Ambience * (_severity == "blizzard" ? 1.4 : 1.1), 0);
	} catch (e) {}
};

::GoldenThrone.rollAndApplySnow <- function () {
	if (::World == null) return;
	if (!("Assets" in ::World) || ::World.Assets == null) return;

	// Scenario gate — only apply during Golden Throne combat
	local scenarioID = "";
	try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return; }
	if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return;

	// Terrain gate — only appropriate terrains
	local tile = null;
	try { tile = ::World.State.getPlayer().getTile(); } catch (e) { return; }
	if (!::GoldenThrone.isSnowAppropriateTerrain.call(this, tile)) return;

	// Per-combat guard — don't double-apply
	if (!("Tactical" in ::getroottable()) || ::Tactical == null) return;
	local flag = "GoldenSnowAppliedThisCombat";
	try {
		if (::Tactical.State != null && ::Tactical.State.m.StrategicProperties != null) {
			local props = ::Tactical.State.m.StrategicProperties;
			if (flag in props && props[flag] == true) return;
			props[flag] <- true;
		}
	} catch (e) {}

	// v2.14.2-alpha — Moderate weather rates. 35% chance of NO storm
	// (clear weather, no effect applied). Within the 65% storm window:
	// 30% Light / 20% Heavy / 15% Blizzard (mirrors the moderate ratios
	// used by the sandstorm system). Earlier always-storm pattern (45/30/25)
	// felt too aggressive for "every tundra fight is snowy."
	local roll = ::Math.rand(1, 100);
	if (roll <= 35) {
		::logInfo("[GoldenThrone] snow weather skipped (clear sky on tundra)");
		return;
	}
	local effectScript = null;
	local severity = "";
	if (roll <= 65)       { severity = "light";    effectScript = "scripts/skills/effects/golden_snow_light_effect"; }
	else if (roll <= 85)  { severity = "heavy";    effectScript = "scripts/skills/effects/golden_snow_heavy_effect"; }
	else                  { severity = "blizzard"; effectScript = "scripts/skills/effects/golden_snow_blizzard_effect"; }

	// Night double-dip (blizzard + night only)
	local applyNight = false;
	if (severity == "blizzard") {
		try { applyNight = !::World.getTime().IsDaytime; } catch (e) {}
	}

	// Visuals
	::GoldenThrone.applySnowVisuals.call(this, severity);

	// Apply effect(s) to everyone on the field
	try {
		local groups = ::Tactical.Entities.getAllInstances();
		foreach (group in groups) {
			foreach (e in group) {
				if (e == null) continue;
				try { e.getSkills().add(::new(effectScript)); } catch (ex) {}
				if (applyNight) {
					try { e.getSkills().add(::new("scripts/skills/effects/golden_snow_night_effect")); } catch (ex) {}
				}
			}
		}
	} catch (e) {}

	::logInfo("[GoldenThrone] snow weather applied: " + severity + (applyNight ? " + night" : ""));
};

// ── Sandstorm weather system (v2.14.1-alpha) ─────────────────────────
// Desert-biome equivalent of snow. Same scenario gate (Golden Throne or
// Three Musketeers), same per-combat guard, same severity probabilities
// (45% light / 30% heavy / 25% full sandstorm). Applies to every
// combatant on the field, ally and enemy alike.

// v2.14.2-alpha — Nomad detection. Used by sandstorm apply-loop to skip
// these actors entirely (they don't get any sandstorm effect — narrative
// reason is "they're desert people; they grew up under this storm").
// Detection: nomad_background, nomad_ranged_background, or any actor
// carrying legend_nomad_trait. Snow does NOT honor this immunity —
// nomads in tundra freeze same as everyone else.
::GoldenThrone.isNomad <- function (_actor) {
	if (_actor == null) return false;
	try {
		local bgID = "";
		try { bgID = _actor.getBackground().getID(); } catch (e) {}
		if (bgID == "background.nomad" || bgID == "background.nomad_ranged") return true;
		local skills = _actor.getSkills();
		if (skills != null && skills.getSkillByID("trait.legend_nomad") != null) return true;
	} catch (e) {}
	return false;
};

::GoldenThrone.isSandstormAppropriateTerrain <- function (_tile) {
	if (_tile == null) return false;
	local t = null;
	try { t = _tile.Type; } catch (e) { return false; }
	local appropriate = [];
	local tt = this.Const.World.TerrainType;
	try { if ("Desert" in tt) appropriate.push(tt.Desert); } catch (e) {}
	try { if ("Steppe" in tt) appropriate.push(tt.Steppe); } catch (e) {}
	try { if ("Oasis" in tt) appropriate.push(tt.Oasis); } catch (e) {}
	foreach (ok in appropriate) {
		if (t == ok) return true;
	}
	return false;
};

::GoldenThrone.applySandstormVisuals <- function (_severity) {
	try {
		local weather = this.Tactical.getWeather();
		local rain = weather.createRainSettings();
		local clouds = weather.createCloudSettings();

		// v2.14.6 — particle counts halved across the board (perf — user
		// reported it hits hard) AND ambient lighting overridden with a
		// tan/sand hex tint per severity (Storm palette was too grey-blue).
		// The white snow_particle_NN brushes pick up the ambient tint at
		// render time, giving us a desert-dust look without needing
		// dedicated dust brushes.
		if (_severity == "light") {
			weather.setAmbientLightingColor(this.createColor("#d4b886"));    // soft tan
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.LightRain);
			rain.MinDrops = 50; rain.MaxDrops = 75;
			rain.NumSplats = 0;
			rain.MinVelocity = 200.0; rain.MaxVelocity = 350.0;
			rain.MinAlpha = 0.3; rain.MaxAlpha = 0.6;
			rain.MinScale = 0.8; rain.MaxScale = 1.8;
		}
		else if (_severity == "heavy") {
			weather.setAmbientLightingColor(this.createColor("#c4a875"));    // deeper tan
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.LightRain);
			rain.MinDrops = 125; rain.MaxDrops = 160;
			rain.NumSplats = 0;
			rain.MinVelocity = 350.0; rain.MaxVelocity = 500.0;
			rain.MinAlpha = 0.55; rain.MaxAlpha = 0.85;
			rain.MinScale = 1.0; rain.MaxScale = 2.5;
		}
		else { // sandstorm — full
			weather.setAmbientLightingColor(this.createColor("#b89863"));    // dusty haze
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.Storm);
			rain.MinDrops = 225; rain.MaxDrops = 250;
			rain.NumSplats = 0;
			rain.MinVelocity = 500.0; rain.MaxVelocity = 700.0;
			rain.MinAlpha = 0.85; rain.MaxAlpha = 1.0;
			rain.MinScale = 1.2; rain.MaxScale = 3.0;
		}
		rain.clearDropBrushes();
		rain.addDropBrush("snow_particle_02");
		rain.addDropBrush("snow_particle_03");
		rain.addDropBrush("snow_particle_04");
		weather.buildRain(rain);

		// Sand-haze cloud cover. Cloud counts also halved for perf.
		clouds.Type = this.getconsttable().CloudType.Custom;
		clouds.MinClouds = (_severity == "sandstorm") ? 100 : (_severity == "heavy" ? 65 : 35);
		clouds.MaxClouds = clouds.MinClouds;
		clouds.MinVelocity = 300.0; clouds.MaxVelocity = 450.0;
		clouds.MinAlpha = 0.5; clouds.MaxAlpha = 0.95;
		clouds.MinScale = 1.0; clouds.MaxScale = 4.0;
		clouds.Sprite = "wind_01";
		clouds.RandomizeDirection = false;
		clouds.RandomizeRotation = false;
		clouds.Direction = this.createVec(-1.0, -0.5);
		weather.buildCloudCover(clouds);

		// Reuse the Blizzard ambience — both are wind-howl loops; the
		// player won't audibly distinguish them. If a vanilla Sandstorm
		// ambience exists in a future BB version, swap here.
		this.Sound.setAmbience(0, this.Const.SoundAmbience.Blizzard, this.Const.Sound.Volume.Ambience * (_severity == "sandstorm" ? 1.4 : 1.1), 0);
	} catch (e) {}
};

::GoldenThrone.rollAndApplySandstorm <- function () {
	if (::World == null) return;
	if (!("Assets" in ::World) || ::World.Assets == null) return;

	// Scenario gate
	local scenarioID = "";
	try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return; }
	if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return;

	// Terrain gate
	local tile = null;
	try { tile = ::World.State.getPlayer().getTile(); } catch (e) { return; }
	if (!::GoldenThrone.isSandstormAppropriateTerrain.call(this, tile)) return;

	// Per-combat guard — separate from snow's flag (different terrain → mutually exclusive in practice)
	if (!("Tactical" in ::getroottable()) || ::Tactical == null) return;
	local flag = "GoldenSandstormAppliedThisCombat";
	try {
		if (::Tactical.State != null && ::Tactical.State.m.StrategicProperties != null) {
			local props = ::Tactical.State.m.StrategicProperties;
			if (flag in props && props[flag] == true) return;
			props[flag] <- true;
		}
	} catch (e) {}

	// v2.14.2-alpha — Moderate weather rates. 35% no storm / 30% light /
	// 20% heavy / 15% full sandstorm. Mirrors the snow rates.
	local roll = ::Math.rand(1, 100);
	if (roll <= 35) {
		::logInfo("[GoldenThrone] sandstorm skipped (clear sky on desert)");
		return;
	}
	local effectScript = null;
	local severity = "";
	if (roll <= 65)       { severity = "light";      effectScript = "scripts/skills/effects/golden_sandstorm_light_effect"; }
	else if (roll <= 85)  { severity = "heavy";      effectScript = "scripts/skills/effects/golden_sandstorm_heavy_effect"; }
	else                  { severity = "sandstorm";  effectScript = "scripts/skills/effects/golden_sandstorm_full_effect"; }

	// Visuals (always apply — even nomads see the dust)
	::GoldenThrone.applySandstormVisuals.call(this, severity);

	// Apply effect to every combatant — except nomads, who are immune
	// per user spec 2026-05-02. Sand favors them; their kit is built
	// around sand. Mechanical reason to bring nomad-bg brothers.
	try {
		local groups = ::Tactical.Entities.getAllInstances();
		foreach (group in groups) {
			foreach (e in group) {
				if (e == null) continue;
				if (::GoldenThrone.isNomad(e)) continue;
				try { e.getSkills().add(::new(effectScript)); } catch (ex) {}
			}
		}
	} catch (e) {}

	::logInfo("[GoldenThrone] sandstorm weather applied: " + severity + " (nomads immune)");
};

// v2.11.0 — Phase 2 oath UI. Player picks 1 of 3 randomly-drawn oaths
// from the 8-oath pool when hiring a brother in the Golden Throne
// scenario. Falls through to random roll if the card-picker library
// isn't loaded.
::GoldenThrone.OathDefs <- [
	{ id = "0", title = "Oath of Steel",     subtitle = "The blade is the prayer",
	  flavor = "Discipline of the warrior. Strikes land truer; the brother moves with one extra purpose.",
	  mechanics = "+8 Melee Skill | +10% Melee Damage | +1 Action Point",
	  artPath = "ui/perks/perk_06.png" },
	{ id = "1", title = "Oath of Stone",     subtitle = "The shield is the prayer",
	  flavor = "Steadfast posture. Armor remembers its purpose; defense holds where weaker walls would crack.",
	  mechanics = "+15% Armor (body + head) | +8 Melee Defense | +8 Ranged Defense | -10% damage taken",
	  artPath = "ui/perks/perk_70.png" },
	{ id = "2", title = "Oath of Light",     subtitle = "The flame is the prayer",
	  flavor = "Beacon of conviction. Morale anchored; the dark recoils.",
	  mechanics = "+15 Resolve | Half morale loss | +20% damage vs undead",
	  artPath = "ui/perks/holyfire_circle.png" },
	{ id = "3", title = "Oath of Fists",     subtitle = "The body is the prayer",
	  flavor = "Closeness as ferocity. Sundering blows; the line breaks where the brother stands.",
	  mechanics = "Sundering strikes | +Melee combo damage",
	  artPath = "ui/perks/sunderingstrikes_circle.png" },
	{ id = "4", title = "Oath of Vigilance", subtitle = "The watch is the prayer",
	  flavor = "Bow + steady eye. One free strike when isolated. Far-sight, longer arrows.",
	  mechanics = "+Vision | +Ranged Skill | +Initiative | One untouchable charge / turn if not surrounded",
	  artPath = "ui/perks/lookout_circle.png" },
	{ id = "5", title = "Oath of Defiance",  subtitle = "The wound is the prayer",
	  flavor = "Refusal of pain. Stun-immune, bleed-immune, the body keeps the count of debts owed.",
	  mechanics = "Immune to stun + bleeding | +5 Fatigue Recovery | -10% damage taken",
	  artPath = "ui/perks/battleheart_circle.png" },
	{ id = "6", title = "Oath of Fury",      subtitle = "The rage is the prayer",
	  flavor = "Combat-fed wrath. The body keeps every hit owed and answers in kind.",
	  mechanics = "Stacks +1 per hit taken (cap 20 in combat) | Keeps up to 10 between fights | Loses 1/day | Per stack: +damage, -defense (scales with Mandate tier)",
	  artPath = "ui/perks/berserker_rage_circle.png" },
	{ id = "7", title = "Oath of Faith",     subtitle = "The aura is the prayer",
	  flavor = "Friendly-fire immune; charge through allies untouched. The Emperor's geometry over yours.",
	  mechanics = "Friendly-fire immunity | Charge through allies | +Aura range",
	  artPath = "ui/perks/extended_aura_circle.png" }
];

// v2.12.0 — build subject context block for the picker modal.
// Pulled out so showOathPickCard reads cleanly. Returns a table the
// CardPicker library knows how to render (see Card Picker v0.2.0+).
::GoldenThrone.buildOathPickSubject <- function (_bro) {
	local subj = {
		name         = "Brother",
		background   = "",
		portraitPath = "",  // BB portraits live in the entity render pipeline; skip for v2.12.0
		statsGrid    = [],
		perkRow      = []
	};
	if (_bro == null) return subj;
	try { subj.name = _bro.getName(); } catch (e) {}
	try {
		local bg = _bro.getBackground();
		local lvl = _bro.getLevel();
		if (bg != null) {
			local bgName = bg.getName();
			subj.background = bgName + " | Lvl " + lvl;
		}
	} catch (e) {}

	// Stats grid — current properties (modified by traits/items the bro has at hire time).
	try {
		local p = _bro.getCurrentProperties();
		subj.statsGrid = [
			{ label = "HP",       value = "" + p.Hitpoints,        icon = "ui/icons/health.png" },
			{ label = "Fatigue",  value = "" + p.Stamina,          icon = "ui/icons/fatigue.png" },
			{ label = "Resolve",  value = "" + p.Bravery,          icon = "ui/icons/bravery.png" },
			{ label = "Initiative", value = "" + p.Initiative,     icon = "ui/icons/initiative.png" },
			{ label = "Melee Skill",  value = "" + p.MeleeSkill,   icon = "ui/icons/melee_skill.png" },
			{ label = "Ranged Skill", value = "" + p.RangedSkill,  icon = "ui/icons/ranged_skill.png" },
			{ label = "Melee Def",  value = "" + p.MeleeDefense,   icon = "ui/icons/melee_defense.png" },
			{ label = "Ranged Def", value = "" + p.RangedDefense,  icon = "ui/icons/ranged_defense.png" }
		];
	} catch (e) { ::logWarning("[GoldenThrone] subject stats build failed: " + e); }

	// Perk row — visible traits at hire time. Level-1 bros have no perk
	// picks yet, so traits give the most signal about what they bring.
	try {
		local skills = _bro.getSkills();
		if (skills != null) {
			// SkillType.Trait covers all character traits (Strong / Tough / Quick / etc.)
			local traits = skills.query(::Const.SkillType.Trait);
			local seenIDs = {};
			foreach (t in traits) {
				if (t == null) continue;
				if ("isHidden" in t && t.isHidden()) continue;
				if (("m" in t) && ("IsHidden" in t.m) && t.m.IsHidden) continue;
				local id = ("m" in t && "ID" in t.m) ? t.m.ID : t.getID();
				if (id in seenIDs) continue;
				seenIDs[id] <- true;
				local nm = t.getName();
				if (nm == null || nm == "") continue;
				local ic = "";
				try { ic = ("m" in t && "Icon" in t.m) ? t.m.Icon : ""; } catch (ee) {}
				subj.perkRow.push({ name = nm, icon = ic });
			}
		}
	} catch (e) {}

	return subj;
};

::GoldenThrone.showOathPickCard <- function (_bro, _oathTrait) {
	if (!("CardPicker" in ::getroottable())) {
		// Fallback: random oath
		try { _oathTrait.setOathType(::Math.rand(0, 7)); } catch (e) {}
		return;
	}

	local broName = "the new brother";
	try { broName = _bro.getName(); } catch (e) {}

	// Pick 3 random distinct oaths from the 8-pool.
	local pool = [0, 1, 2, 3, 4, 5, 6, 7];
	local picks = [];
	for (local i = 0; i < 3; i++) {
		local idx = ::Math.rand(0, pool.len() - 1);
		picks.push(pool[idx]);
		pool.remove(idx);
	}

	local cards = [];
	foreach (oathIdx in picks) {
		local def = ::GoldenThrone.OathDefs[oathIdx];
		cards.push({
			id          = "" + oathIdx,
			title       = def.title,
			subtitle    = def.subtitle,
			flavor      = def.flavor,
			mechanics   = def.mechanics,
			artPath     = def.artPath,
			recommended = false
		});
	}

	// v2.12.0 — Card Picker v0.2.0+ accepts a subject block above the cards.
	// Show the bro's stats + traits so the player can pick informed.
	local subject = ::GoldenThrone.buildOathPickSubject(_bro);

	::CardPicker.show({
		title    = "Sworn before the Throne — " + broName,
		bodyText = "{The new brother kneels before the Emperor. The brand is set. Three oaths burn in the air, each one binding. The brother chooses the prayer that the body will keep.}",
		subject  = subject,
		cards    = cards,
		onPick = function (cardID) {
			try {
				local oathType = cardID.tointeger();
				_oathTrait.setOathType(oathType);
			} catch (e) {
				::logWarning("[GoldenThrone] oath setOathType failed: " + e);
				try { _oathTrait.setOathType(::Math.rand(0, 7)); } catch (ee) {}
			}
		},
		onCancel = function () {
			// Player cancelled — assign random from the 3 drawn so the
			// bro doesn't end up with the temp Steel default forever.
			try { _oathTrait.setOathType(picks[::Math.rand(0, picks.len() - 1)]); }
			catch (e) {}
		}
	});
};

::GoldenThrone.Hooks.queue(">mod_ROTUC", function () {
	::GoldenThrone.checkDeps();

	if (!("GoldenThrone" in ::Mod_ROTU.Scenario)) {
		::Mod_ROTU.Scenario.GoldenThrone <- "scenario.golden_throne";
	}
	if (::Mod_ROTU.ValidOriginIDs.find("scenario.golden_throne") == null) {
		::Mod_ROTU.ValidOriginIDs.push("scenario.golden_throne");
	}

	if ("World" in ::getroottable() && "Events" in ::World && ::World.Events != null) {
		::World.Events.register("event.golden_throne_intro", "scripts/events/events/scenario/golden_throne_intro_event");
		::World.Events.register("event.golden_partner_rumor", "scripts/events/events/scenario/golden_partner_rumor_event");
		::World.Events.register("event.golden_partner_arrival", "scripts/events/events/scenario/golden_partner_arrival_event");
		::World.Events.register("event.golden_partner_resolution", "scripts/events/events/scenario/golden_partner_resolution_event");
		::World.Events.register("event.golden_throne_cleanup", "scripts/events/events/scenario/golden_throne_cleanup_event");
		::World.Events.register("event.golden_throne_finale", "scripts/events/events/scenario/golden_throne_finale_event");
		::World.Events.register("event.golden_ghost_dog_offer", "scripts/events/events/scenario/golden_ghost_dog_offer_event");
		::World.Events.register("event.golden_ghost_dog_ruins", "scripts/events/events/scenario/golden_ghost_dog_ruins_event");
		::World.Events.register("event.golden_ghost_dog_betrayal", "scripts/events/events/scenario/golden_ghost_dog_betrayal_event");
		::World.Events.register("event.golden_ghost_dog_battle", "scripts/events/events/scenario/golden_ghost_dog_battle_event");
		::World.Events.register("event.golden_ghost_dog_farewell", "scripts/events/events/scenario/golden_ghost_dog_farewell_event");
		// v2.14.0-alpha — D4 Phase A pyramid arc events.
		::World.Events.register("event.golden_pyramid_rumor",    "scripts/events/events/scenario/golden_pyramid_rumor_event");
		::World.Events.register("event.golden_pyramid_approach", "scripts/events/events/scenario/golden_pyramid_approach_event");
		::World.Events.register("event.golden_pyramid_floor",    "scripts/events/events/scenario/golden_pyramid_floor_event");
		::World.Events.register("event.golden_pyramid_finale",   "scripts/events/events/scenario/golden_pyramid_finale_event");
	}

	// Spectral Hound Troop spec — used by the Beat 4 ruins combat to spawn
	// the dog as a PlayerAnimals ally. Faction omitted here per vanilla
	// pattern; spec.Faction is set at spawn-time via newslot.
	if ("Const" in ::getroottable()
		&& "World" in ::Const
		&& "Spawn" in ::Const.World
		&& "Troops" in ::Const.World.Spawn
		&& !("GoldenGhostDog_Spec" in ::Const.World.Spawn.Troops))
	{
		::Const.World.Spawn.Troops.GoldenGhostDog_Spec <- {
			ID       = ::Const.EntityType.Direwolf,
			Variant  = 0,
			Script   = "scripts/entity/tactical/player/golden_ghost_dog_ally",
			Strength = 1,
			Cost     = 1,
			Row      = 0
		};
	}

	// Hook tactical combat start to roll + apply snow weather when GT scenario
	::mods_hookExactClass("states/tactical_state", function (o) {
		local originalOnShow = o.onShow;
		o.onShow = function () {
			originalOnShow.call(this);
			try { ::GoldenThrone.rollAndApplySnow.call(this); } catch (e) {
				::logWarning("[GoldenThrone] rollAndApplySnow threw: " + e);
			}
			// v2.14.1-alpha — sandstorm rolls in parallel. Each function
			// terrain-gates internally so they're mutually exclusive in
			// practice (snow tiles vs desert tiles).
			try { ::GoldenThrone.rollAndApplySandstorm.call(this); } catch (e) {
				::logWarning("[GoldenThrone] rollAndApplySandstorm threw: " + e);
			}
		};
	});

	::logInfo(::GoldenThrone.Name + " v" + ::GoldenThrone.Version + " registered.");
});

// v2.11.3 — Holy Wrath (Combat) + Purge Count (Persistent) registered with
// the Stack Skills lib. Lib auto-handles cap/reset for Combat and tier
// callbacks for Persistent. Soft-fails if lib missing.
::GoldenThrone.Hooks.queue(">mod_lib_stack_skills", function () {
	if (!("StackLib" in ::getroottable())) {
		::logWarning("[GoldenThrone] Stack Skills lib not loaded — Holy Wrath + Purge Count falling back to legacy state");
		return;
	}
	::StackLib.register({
		id      = "goldenthrone.holywrath",
		kind    = ::StackLib.Kind.Combat,
		max     = 5,
		min     = 0,
		resetOn = ["combatStart", "combatEnd"]
	});
	::StackLib.register({
		id          = "goldenthrone.purge",
		kind        = ::StackLib.Kind.Persistent,
		min         = 0,
		tiers       = [25, 100, 250, 500],
		legacyField = "PurgeCount",
		onTier      = function (_actor, _newTier, _oldTier) {
			local trait = _actor.getSkills().getSkillByID("trait.golden_emperor");
			if (trait == null) return;
			try { trait._announcePurgeMilestone(_newTier, _actor); } catch (e) {}
			if (_newTier >= 4 && ::World != null) {
				try {
					local bonus = ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
					::World.Flags.set("GoldenEmperorAuraBonus", bonus + 1);
				} catch (e) {}
			}
		}
	});
	::logInfo("[GoldenThrone] Holy Wrath + Purge Count registered with StackLib");
});
