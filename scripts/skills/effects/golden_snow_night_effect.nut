// Applied ONLY on top of a blizzard when combat starts at night. The
// double-dip: a night blizzard is the worst combination. Stacks with
// golden_snow_blizzard_effect for total penalties of -13 RS, -3 MS,
// -5 Init, -5 Vision.
this.golden_snow_night_effect <- this.inherit("scripts/skills/skill", {
	m = {},
	function create() {
		this.m.ID = "effects.golden_snow_night";
		this.m.Name = "Night Blizzard";
		this.m.Description = "Darkness and driving snow together. Visibility is nearly zero. -3 Ranged Skill, -1 Initiative, -2 Vision (on top of Blizzard).";
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
		_properties.Initiative += -1;
		_properties.Vision += -2;
	}
});
