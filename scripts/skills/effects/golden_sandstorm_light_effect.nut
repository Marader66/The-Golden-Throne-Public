// refactored to use ::GoldenThrone.InheritHelper.sandstormEffect.
this.golden_sandstorm_light_effect <- this.inherit("scripts/skills/skill",
    ::GoldenThrone.InheritHelper.sandstormEffect({
        id = "light",
        name = "Drifting Dust",
        description = "Fine dust drifts across the field. Eyes sting; bowstrings catch grit. -3 Ranged Skill, -1 Vision.",
        statDeltas = {
            RangedSkill = -3,
            Vision      = -1
        }
    })
);
