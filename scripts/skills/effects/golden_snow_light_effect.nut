this.golden_snow_light_effect <- this.inherit("scripts/skills/skill", {
	m = {},
	function create() {
		this.m.ID = "effects.golden_snow_light";
		this.m.Name = "Light Snow";
		this.m.Description = "A gentle snowfall dusts the field. -3 Ranged Skill, -1 Vision.";
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
		_properties.RangedSkill += -3;
		_properties.Vision += -1;
	}
});
