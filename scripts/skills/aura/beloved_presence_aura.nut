this.beloved_presence_aura <- ::inherit("scripts/skills/aura/rotu_mod_aura_abstract", {
	m = {},

	function create() {
		rotu_mod_aura_abstract.create();
		m.ID = "actives.beloved_presence";
		m.Name = "The Beloved's Presence";
		m.Description = "The old-world bond endures. The Emperor fights with renewed purpose when his beloved stands near; lesser warriors, too, take heart from a face they thought lost to time.";
		m.ToggleOnDescription = m.Description;
		m.ToggleOffDescription = m.Description;
		m.Icon = "ui/perks/gt_beloved_presence.png";
		m.IconMini = "status_effect_01_mini";
		m.Overlay = "active_128";
		m.SoundOnUse = ["sounds/combat/pov_holy_fire_01.wav"];
		m.SoundVolume = 1.2;
		m.MaxRange = 6;
		m.MinRange = 1;

		setAsPassiveAura(true);
	}

	function getTooltip() {
		local ret = rotu_mod_aura_abstract.getTooltip();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/bravery.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+20[/color] Resolve and [color=" + ::Const.UI.Color.PositiveValue + "]+8[/color] Melee Defense for [color=#FFD700]the Emperor[/color] within " + m.MaxRange + " tiles"
		});
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/bravery.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+5[/color] Resolve for all other allies within " + m.MaxRange + " tiles"
		});
		return ret;
	}

	function onCombatStarted() {
		rotu_mod_aura_abstract.onCombatStarted();
	}

	function applyOnUpdate(_affectedTarget, _targetProperties) {
		local user = this.getContainer().getActor();
		if (!user.isAlive() || !user.isPlacedOnMap()) return;
		if (!_affectedTarget.isAlive()) return;
		if (!_affectedTarget.isAlliedWith(user)) return;

		local isEmperor = false;
		if (_affectedTarget.getFlags().has("GoldenEmperor")) isEmperor = true;
		if (!isEmperor && _affectedTarget.getSkills().getSkillByID("trait.golden_emperor") != null) {
			isEmperor = true;
		}

		if (isEmperor) {
			_targetProperties.Bravery += 20;
			_targetProperties.MeleeDefense += 8;
		} else {
			_targetProperties.Bravery += 5;
		}
	}

	function applyEffectOnActivation(_affectedTarget) {
		local user = this.getContainer().getActor();
		if (!_affectedTarget.isAlliedWith(user) || _affectedTarget.isHiddenToPlayer()) return;
		if (_affectedTarget.getFlags().has("GoldenEmperor")) {
			::Tactical.EventLog.log("[color=#FFD700]" + ::Const.UI.getColorizedEntityName(user) + "[/color] stands beside the Emperor once more.");
		}
	}

	function isValidTarget(_user, _target) {
		return _target.isAlliedWith(_user);
	}
});
