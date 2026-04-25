this.golden_snow_blizzard_effect <- this.inherit("scripts/skills/skill", {
	m = {},
	function create() {
		this.m.ID = "effects.golden_snow_blizzard";
		this.m.Name = "Blizzard";
		this.m.Description = "A howling blizzard blinds everyone on the field. Hands freeze around weapon grips. -10 Ranged Skill, -3 Melee Skill, -4 Initiative, -3 Vision.";
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
		_properties.RangedSkill += -10;
		_properties.MeleeSkill += -3;
		_properties.Initiative += -4;
		_properties.Vision += -3;
	}
});
