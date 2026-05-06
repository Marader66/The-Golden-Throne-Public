// v2.12.2 — refactored to use ::GoldenThrone.InheritHelper.snowEffect.
this.golden_snow_heavy_effect <- this.inherit("scripts/skills/skill",
    ::GoldenThrone.InheritHelper.snowEffect({
        id = "heavy",
        name = "Heavy Snow",
        description = "Thick snow blankets the field. -6 Ranged Skill, -2 Initiative, -2 Vision.",
        statDeltas = {
            RangedSkill = -6,
            Initiative  = -2,
            Vision      = -2
        }
    })
);
