this.memory_burden_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.memory_burden";
		this.m.Icon = "ui/perks/gt_memory_burden.png";
		this.m.IsPersonality = false;
	}

	function getName() {
		return this.Const.UI.getColorized("Memory's Burden", "#6E5A42");
	}

	function getDescription() {
		return "What the Emperor faced in the crypt wore a face that had been dust for ages. The shade is gone — but the ache of almost-believing lingers. The Emperor is slower now, less easily moved to hope, but the cold fury they carry against the unquiet dead has a new edge.";
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/initiative.png",
			text = "[color=" + ::Const.UI.Color.NegativeValue + "]-5[/color] Initiative"
		});
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/damage_dealt.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+15%[/color] damage dealt to undead enemies"
		});
		ret.push({
			id = 12,
			type = "text",
			icon = "ui/icons/bravery.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+5[/color] Resolve — the ache teaches patience"
		});
		return ret;
	}

	function onUpdate(_properties) {
		this.character_trait.onUpdate(_properties);
		_properties.Initiative -= 5;
		_properties.Bravery += 5;
	}

	function onAnySkillUsed(_skill, _targetEntity, _properties) {
		this.character_trait.onAnySkillUsed(_skill, _targetEntity, _properties);
		if (_targetEntity == null) return;
		if (!_skill.isAttack()) return;
		local flags = _targetEntity.getFlags();
		if (flags == null) return;
		if (flags.has("undead")) {
			_properties.DamageRegularMult *= 1.15;
			_properties.DamageArmorMult *= 1.15;
		}
	}
});
