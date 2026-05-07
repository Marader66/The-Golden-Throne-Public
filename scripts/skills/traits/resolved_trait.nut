this.resolved_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.resolved";
		this.m.Icon = "ui/perks/gt_resolved.png";
		this.m.IsPersonality = false;
	}

	function getName() {
		return this.Const.UI.getColorized("Resolved", "#C8BFA9");
	}

	function getDescription() {
		return "The old hurt has been laid to rest. What was lost is no longer a wound the Emperor carries — only a memory that strengthens every step forward.";
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/bravery.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+15[/color] Resolve"
		});
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/initiative.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+10[/color] Initiative — clarity and quickness, no longer hesitating"
		});
		ret.push({
			id = 12,
			type = "text",
			icon = "ui/icons/damage_dealt.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+10%[/color] damage dealt to undead enemies — the grief has become edge"
		});
		ret.push({
			id = 13,
			type = "text",
			icon = "ui/icons/special.png",
			text = "A lasting memory of one laid to rest — the Emperor fights with quiet purpose"
		});
		return ret;
	}

	function onUpdate(_properties) {
		this.character_trait.onUpdate(_properties);
		_properties.Bravery += 15;
		_properties.Initiative += 10;
	}

	function onAnySkillUsed(_skill, _targetEntity, _properties) {
		this.character_trait.onAnySkillUsed(_skill, _targetEntity, _properties);
		if (_targetEntity == null) return;
		if (_skill == null || !_skill.isAttack()) return;
		local flags = _targetEntity.getFlags();
		if (flags != null && flags.has("undead")) {
			_properties.DamageRegularMult *= 1.10;
			_properties.DamageArmorMult *= 1.10;
		}
	}
});
