// Applied ONLY on top of a blizzard when combat starts at night. The
// double-dip: a night blizzard is the worst combination. Stacks with
// golden_snow_blizzard_effect for total penalties of -13 RS, -3 MS,
// -5 Init, -5 Vision.
//
// v2.12.2 — refactored to use ::GoldenThrone.InheritHelper.snowEffect.
this.golden_snow_night_effect <- this.inherit("scripts/skills/skill",
    ::GoldenThrone.InheritHelper.snowEffect({
        id = "night",
        name = "Night Blizzard",
        description = "Darkness and driving snow together. Visibility is nearly zero. -3 Ranged Skill, -1 Initiative, -2 Vision (on top of Blizzard).",
        statDeltas = {
            RangedSkill = -3,
            Initiative  = -1,
            Vision      = -2
        }
    })
);
