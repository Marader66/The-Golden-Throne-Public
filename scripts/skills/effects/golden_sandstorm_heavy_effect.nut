// refactored to use ::GoldenThrone.InheritHelper.sandstormEffect.
this.golden_sandstorm_heavy_effect <- this.inherit("scripts/skills/skill",
    ::GoldenThrone.InheritHelper.sandstormEffect({
        id = "heavy",
        name = "Heavy Sand",
        description = "The wind has teeth. Sand finds every gap in armour. -6 Ranged Skill, -2 Initiative, -2 Vision.",
        statDeltas = {
            RangedSkill = -6,
            Initiative  = -2,
            Vision      = -2
        }
    })
);
