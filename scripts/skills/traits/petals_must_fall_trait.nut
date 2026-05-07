this.petals_must_fall_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.petals_must_fall";
		this.m.Name = "Petals Must Fall";
		this.m.Icon = "ui/perks/gt_petals_must_fall.png";
		this.m.Description = "Every swing a storm. The Emperor's strikes fly wide — until one lands, and the world shatters. When they miss, the air itself carries the weight.";
		this.m.Type = this.m.Type | ::Const.SkillType.Trait;
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		ret.push({
			id = 10, type = "text", icon = "ui/icons/melee_skill.png",
			text = "[color=" + ::Const.UI.Color.NegativeValue + "]-50%[/color] Melee Skill"
		});
		ret.push({
			id = 11, type = "text", icon = "ui/icons/damage_dealt.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+50%[/color] Melee Damage"
		});
		ret.push({
			id = 12, type = "text", icon = "ui/icons/special.png",
			text = "On a missed melee attack with a two-handed weapon, [color=" + ::Const.UI.Color.PositiveValue + "]always[/color] staggers the target."
		});
		return ret;
	}

	function onUpdate(_properties) {
		_properties.MeleeSkillMult *= 0.5;
		_properties.MeleeDamageMult *= 1.5;
	}

	function onTargetMissed(_skill, _targetEntity) {
		if (_skill == null || !_skill.isAttack()) return;
		if (_targetEntity == null || !_targetEntity.isAlive()) return;

		local actor = this.getContainer().getActor();
		local weapon = actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (weapon == null) return;
		if (!weapon.isItemType(::Const.Items.ItemType.TwoHanded)) return;
		if (!weapon.isItemType(::Const.Items.ItemType.MeleeWeapon)) return;

		if (("FOTN" in ::getroottable()) && ("applyStagger" in ::FOTN)) {
			::FOTN.applyStagger(actor, _targetEntity);
		} else {
			_targetEntity.getSkills().add(::new("scripts/skills/effects/staggered_effect"));
		}
	}
});
