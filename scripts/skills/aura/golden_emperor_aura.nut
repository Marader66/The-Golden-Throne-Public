this.golden_emperor_aura <- ::inherit("scripts/skills/aura/rotu_mod_aura_abstract", {
	m = {},

	function create() {
		rotu_mod_aura_abstract.create();
		m.ID = "actives.golden_emperor_aura";
		m.Name = "Imperial Presence";
		m.Description = "The Emperor's divine light radiates outward. Allies within his presence fight with renewed purpose, and the dead are held still by his holy light — they will not rise again within his reach.";
		m.ToggleOnDescription = m.Description;
		m.ToggleOffDescription = m.Description;
		m.Icon = "ui/perks/gt_golden_emperor_aura.png";
		m.IconMini = "status_effect_01_mini";
		m.Overlay = "active_128";
		m.SoundOnUse = ["sounds/combat/pov_holy_fire_01.wav"];
		m.SoundVolume = 1.5;
		m.MaxRange = 10;
		m.MinRange = 1;

		setAsPassiveAura(true);
	}

	function getTooltip() {
		local ret = rotu_mod_aura_abstract.getTooltip();
		local pos = ::Const.UI.Color.PositiveValue;
		local neg = ::Const.UI.Color.NegativeValue;

		// Compute live radius — base + Purge IV + Ascended Sovereign +5.
		local liveRadius = m.MaxRange;
		try {
			local bonus = 0;
			if (::World != null) bonus = ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
			local baseRadius = 10;
			try { baseRadius = ::GoldenThrone.getSetting("AuraBaseRadius", 10); } catch (e) {}
			if (bonus > 0) liveRadius = baseRadius + bonus;
		} catch (e) {}

		// Detect Purge tier for conditional tooltip rows (Farseer at I, etc).
		local purgeTier = 0;
		try {
			local actor = this.getContainer().getActor();
			if (actor != null) {
				local trait = actor.getSkills().getSkillByID("trait.golden_emperor");
				if (trait != null && ("getPurgeTier" in trait)) {
					purgeTier = trait.getPurgeTier();
				}
			}
		} catch (e) {}

		ret.push({ id = 10, type = "text", icon = "ui/icons/bravery.png",
			text = "Allies within [color=" + pos + "]" + liveRadius + " tiles[/color] gain [color=" + pos + "]+10 Resolve[/color]." });
		ret.push({ id = 11, type = "text", icon = "ui/icons/melee_defense.png",
			text = "Allies in radius gain [color=" + pos + "]+5 Melee Defense[/color] and [color=" + pos + "]+5 Ranged Defense[/color]." });
		ret.push({ id = 12, type = "text", icon = "ui/icons/special.png",
			text = "Every non-allied enemy in radius is held against [color=" + neg + "]all forms of resurrection[/color] — no zombie-rise, no necromancer revive — while the Emperor lives." });
		if (purgeTier >= 1) {
			ret.push({ id = 13, type = "text", icon = "ui/icons/vision.png",
				text = "[color=" + pos + "]Farseer (Purge I)[/color]: hidden enemies in radius are revealed." });
		}
		if (purgeTier >= 4) {
			ret.push({ id = 14, type = "text", icon = "ui/icons/special.png",
				text = "[color=" + pos + "]Expanded Presence (Purge IV)[/color]: aura radius permanently +1." });
		}
		return ret;
	}

	function onCombatStarted() {
		// v2.13.0 — base radius pulled from MSU settings; Purge IV + Ascended
		// bonuses stack on top via the world flag.
		local baseRadius = 10;
		try { baseRadius = ::GoldenThrone.getSetting("AuraBaseRadius", 10); } catch (e) {}
		if (::World != null) {
			local bonus = ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
			m.MaxRange = baseRadius + bonus;
		} else {
			m.MaxRange = baseRadius;
		}
		rotu_mod_aura_abstract.onCombatStarted();
	}

	function applyOnUpdate(_affectedTarget, _targetProperties) {
		local user = this.getContainer().getActor();
		if (!user.isAlive() || !user.isPlacedOnMap()) return;
		if (!_affectedTarget.isAlive()) return;

		if (_affectedTarget.isAlliedWith(user)) {
			_targetProperties.Bravery += 10;
			_targetProperties.MeleeDefense += 5;
			_targetProperties.RangedDefense += 5;
		} else {
			// Block all resurrection paths on non-allied enemies in aura.
			// Two-layer write because BB checks resurrection at death-time
			// from BOTH the live property cache AND the actor's m table:
			//   - _targetProperties.X = re-asserted every property recalc
			//     while the enemy is in aura range (canonical aura pattern)
			//   - _affectedTarget.m.X = persistent baseline (defence in depth)
			// SurvivesAsUndead = base zombie/skeleton/wiedergänger rise.
			// IsResurrectable = necromancer/hexen re-raise from corpse.
			// Allies are exempt automatically (only the else branch applies),
			// so our own resurrection paths (Compact, Solar Ascension,
			// Beloved, Reclaimer, Brand) are untouched. "Special" enemies
			// we'd want to return get an "no_purge" flag to opt out — none
			// currently exist; pattern reserved for future bosses.
			//
			// v2.14.4 — earlier v2.14.3 only wrote to actor.m, which the
			// base-properties recalc ignores at death-time. User report
			// 2026-05-02: undead still rising in aura range. Reverted to
			// the canonical _targetProperties write + kept the m-write as
			// belt-and-suspenders.
			if (!_affectedTarget.getFlags().has("no_purge")) {
				try { _targetProperties.SurvivesAsUndead = false; } catch (e) {}
				try { _targetProperties.IsResurrectable = false; } catch (e) {}
				try { _affectedTarget.m.SurvivesAsUndead = false; } catch (e) {}
				try { _affectedTarget.m.IsResurrectable = false; } catch (e) {}
			}
			local trait = user.getSkills().getSkillByID("trait.golden_emperor");
			if (trait != null && ("getPurgeTier" in trait) && trait.getPurgeTier() >= 1) {
				if (_affectedTarget.isHiddenToPlayer()) {
					_affectedTarget.setHidden(false);
				}
			}
		}
	}

	function applyEffectOnActivation(_affectedTarget) {
		local user = this.getContainer().getActor();
		if (_affectedTarget.isAlliedWith(user) && !_affectedTarget.isHiddenToPlayer()) {
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_affectedTarget) + " is bolstered by the Emperor's presence.");
		}
	}

	function isValidTarget(_user, _target) {
		// All non-allied targets — broadened so applyOnUpdate fires on every
		// enemy in radius (was undead-only, which left necromancer-revivable
		// non-undead enemies un-purged). Allies still get the buff branch.
		return true;
	}
});
