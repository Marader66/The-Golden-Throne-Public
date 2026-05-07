// v2.12.3 — refactored to read per-oath data from ::GoldenThrone.OathRegistry.
// Switch arms in getName/getDescription/getTooltip/_iconForOath/_applyOathEffects
// + per-oath hooks all replaced with table lookups. Each oath's data lives in
// one row of the registry; this class is now a dispatcher.
this.golden_oath_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {
		OathType         = 0,
		FuryStacks       = 0,
		HasUntouchable   = false,
		LastFuryCheckDay = 0   // v2.12.0 — track world-day for 1/day Fury decay
	},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.golden_oath";
		this.m.Icon = "ui/perks/lionheart.png";
	}

	function _getOathDef() {
		local t = this.m.OathType;
		if (t < 0 || t >= ::GoldenThrone.OathRegistry.len()) return null;
		return ::GoldenThrone.OathRegistry[t];
	}

	function _iconForOath(_type) {
		if (_type < 0 || _type >= ::GoldenThrone.OathRegistry.len()) return "ui/perks/lionheart.png";
		return ::GoldenThrone.OathRegistry[_type].icon;
	}

	function getOathName() {
		local def = this._getOathDef();
		return def != null ? def.name : "Oath of the Throne";
	}

	function getName() {
		return this.Const.UI.getColorized(this.getOathName(), "#FFD700");
	}

	function getDescription() {
		local def = this._getOathDef();
		return def != null ? def.description : "";
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		local def = this._getOathDef();
		if (def == null) return ret;
		try {
			local rows = def.getTooltipRows(this, this._getMandateMult());
			foreach (row in rows) ret.push(row);
		} catch (e) { ::logWarning("[gt oath] getTooltipRows threw on type " + this.m.OathType + ": " + e); }
		return ret;
	}

	function setOathType(_type) {
		this.m.OathType = _type;
		this.m.Icon = this._iconForOath(_type);
	}

	function onUpdate(_properties) {
		local def = this._getOathDef();
		if (def == null) return;
		try { def.applyStats(this, _properties, this._getMandateMult()); }
		catch (e) { ::logWarning("[gt oath] applyStats threw on type " + this.m.OathType + ": " + e); }
	}

	// v2.12.0 — Mandate-tier inverse scaling. Oaths grow stronger with the
	// brother's Mandate tier to counter ROTU/FoTN late-game difficulty
	// (40+ champion/miniboss usurper-dungeon territory). Curve picked by
	// user 2026-05-01.
	//
	// Tier:    0    1    2    3    4    5
	// Mult:  1.00 1.05 1.10 1.15 1.20 1.25
	//
	// Numeric stat additions and multiplicative percentage deltas both
	// scale via `m`. Binary effects (immunities, untouchable charges, the
	// MoraleEffectMult ×0.5 halving) stay flat — they're either on or off.
	function _getMandateMult() {
		try {
			local container = this.getContainer();
			if (container == null) return 1.0;
			local mandate = container.getSkillByID("trait.golden_mandate");
			if (mandate == null) return 1.0;
			local tier = 0;
			if ("getTierLevel" in mandate) {
				tier = mandate.getTierLevel();
			} else if ("m" in mandate && "TierStats" in mandate.m && "TierLevel" in mandate.m.TierStats) {
				tier = mandate.m.TierStats.TierLevel;
			}
			if (tier < 0) tier = 0;
			if (tier > 5) tier = 5;
			local table = [1.00, 1.05, 1.10, 1.15, 1.20, 1.25];
			local raw = table[tier];
			// v2.13.0 — MSU-tunable intensity. Stretches/flattens the curve
			// uniformly across all 8 oaths. intensity=0 → flat 1.0,
			// intensity=1 (default) → unchanged, intensity=2 → doubled deltas.
			local intensity = 1.0;
			try { intensity = ::GoldenThrone.getSetting("OathScaling", 1.0); } catch (e) {}
			return 1.0 + (raw - 1.0) * intensity;
		} catch (e) {}
		return 1.0;
	}

	// v2.12.0 — Fury 1-stack-per-world-day decay. Lazy: snapshots last-checked
	// day on first call after stacks become non-zero, drains elapsed days
	// at next call. So a player parked in town for 5 days returns to find
	// 5 fewer Fury stacks on the next combat tick. Cap at >=0.
	function _decayFuryByElapsedDays() {
		if (this.m.OathType != 6) return;
		if (this.m.FuryStacks <= 0) return;
		try {
			local now = ::World.getTime().Days;
			if (this.m.LastFuryCheckDay == 0) {
				this.m.LastFuryCheckDay = now;
				return;
			}
			local elapsed = now - this.m.LastFuryCheckDay;
			if (elapsed > 0) {
				this.m.FuryStacks -= elapsed;
				if (this.m.FuryStacks < 0) this.m.FuryStacks = 0;
				this.m.LastFuryCheckDay = now;
			}
		} catch (e) {}
	}

	function _bothHandsEmpty() {
		try {
			local actor = this.getContainer().getActor();
			if (actor == null) return false;
			local items = actor.getItems();
			if (items == null) return false;
			local mh = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
			local oh = items.getItemAtSlot(::Const.ItemSlot.Offhand);
			return (mh == null && oh == null);
		} catch (e) {}
		return false;
	}

	function _isInsideImperialAura() {
		try {
			local actor = this.getContainer().getActor();
			if (actor == null || !actor.isPlacedOnMap()) return false;
			local mine = actor.getTile();
			local ents = ::Tactical.Entities.getInstancesOfFaction(actor.getFaction());
			if (ents == null) return false;
			local maxRange = 10 + ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
			foreach (e in ents) {
				if (e == null || e == actor) continue;
				if (!e.isPlacedOnMap()) continue;
				if (!e.getFlags().has("GoldenEmperor")) continue;
				if (mine.getDistanceTo(e.getTile()) <= maxRange) return true;
			}
		} catch (e) {}
		return false;
	}

	function _countAdjacentEnemies(_actor) {
		local count = 0;
		try {
			local tile = _actor.getTile();
			for (local i = 0; i < 6; i++) {
				if (!tile.hasNextTile(i)) continue;
				local n = tile.getNextTile(i);
				if (!n.IsOccupiedByActor) continue;
				local other = n.getEntity();
				if (other == null || !other.isAlive()) continue;
				if (!other.isAlliedWith(_actor)) count++;
			}
		} catch (e) {}
		return count;
	}

	// _callDefHook — central dispatcher for optional per-oath hook fields.
	// Routes to the registry row's named hook when present, swallowing any
	// throw so one oath's bug can't blank a whole skill-container update.
	function _callDefHook(_name, _args) {
		local def = this._getOathDef();
		if (def == null) return;
		if (!(_name in def)) return;
		if (def[_name] == null) return;
		try { def[_name].acall(_args); }
		catch (e) { ::logWarning("[gt oath] " + _name + " threw on type " + this.m.OathType + ": " + e); }
	}

	function onTurnStart() {
		try {
			local actor = this.getContainer().getActor();
			if (actor == null || !actor.isPlacedOnMap()) return;
			this._callDefHook("onTurnStart", [this, this, actor]);
		} catch (e) {}
	}

	function onBeforeDamageReceived(_attacker, _skill, _properties) {
		this._callDefHook("onBeforeDamageReceived", [this, this, _attacker, _skill, _properties]);
	}

	function onCombatStarted() {
		this._callDefHook("onCombatStarted", [this, this]);
	}

	function onCombatFinished() {
		this._callDefHook("onCombatFinished", [this, this]);
	}

	function onAnySkillUsed(_skill, _targetEntity, _properties) {
		this._callDefHook("onAnySkillUsed", [this, this, _skill, _targetEntity, _properties]);
	}

	function onSerialize(_out) {
		this.character_trait.onSerialize(_out);
		_out.writeI32(this.m.OathType);
		_out.writeI32(this.m.FuryStacks);
		_out.writeBool(this.m.HasUntouchable);
		_out.writeI32(this.m.LastFuryCheckDay);  // v2.12.0
	}

	function onDeserialize(_in) {
		this.character_trait.onDeserialize(_in);
		this.m.OathType = _in.readI32();
		// Backward-compat — old saves only wrote OathType. Wrap reads in try
		// so existing brothers keep their oath without breaking deserialize.
		try { this.m.FuryStacks       = _in.readI32(); }  catch (e) { this.m.FuryStacks      = 0; }
		try { this.m.HasUntouchable   = _in.readBool(); } catch (e) { this.m.HasUntouchable  = false; }
		try { this.m.LastFuryCheckDay = _in.readI32(); }  catch (e) { this.m.LastFuryCheckDay = 0; }
		this.m.Icon = this._iconForOath(this.m.OathType);
	}
});
