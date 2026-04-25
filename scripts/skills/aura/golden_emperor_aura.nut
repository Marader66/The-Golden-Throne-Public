this.golden_emperor_aura <- ::inherit("scripts/skills/aura/rotu_mod_aura_abstract", {
	m = {},

	function create() {
		rotu_mod_aura_abstract.create();
		m.ID = "actives.golden_emperor_aura";
		m.Name = "Imperial Presence";
		m.Description = "The Emperor's divine light radiates outward. Allies within his presence fight with renewed purpose, and the dead are held still by his holy light — they will not rise again within his reach.";
		m.ToggleOnDescription = m.Description;
		m.ToggleOffDescription = m.Description;
		m.Icon = "skills/active_128.png";
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
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/bravery.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+10[/color] Resolve for all allies within " + m.MaxRange + " tiles"
		});
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/melee_defense.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+5[/color] Melee and Ranged Defense for all allies within " + m.MaxRange + " tiles"
		});
		ret.push({
			id = 12,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Undead enemies within " + m.MaxRange + " tiles [color=" + ::Const.UI.Color.NegativeValue + "]cannot be resurrected[/color] while the Emperor lives"
		});
		return ret;
	}

	function onCombatStarted() {
		if (::World != null) {
			local bonus = ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
			m.MaxRange = 10 + bonus;
		} else {
			m.MaxRange = 10;
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
			if (_affectedTarget.getFlags().has("undead")) {
				_targetProperties.SurvivesAsUndead = false;
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
		if (_target.isAlliedWith(_user)) return true;
		if (_target.getFlags().has("undead")) return true;
		return false;
	}
});
