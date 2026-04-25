this.golden_snow_heavy_effect <- this.inherit("scripts/skills/skill", {
	m = {},
	function create() {
		this.m.ID = "effects.golden_snow_heavy";
		this.m.Name = "Heavy Snow";
		this.m.Description = "Thick snow blankets the field. -6 Ranged Skill, -2 Initiative, -2 Vision.";
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
		_properties.RangedSkill += -6;
		_properties.Initiative += -2;
		_properties.Vision += -2;
	}
});
