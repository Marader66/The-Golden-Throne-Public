// v2.12.2 — refactored to use ::GoldenThrone.InheritHelper.snowEffect.
this.golden_snow_blizzard_effect <- this.inherit("scripts/skills/skill",
    ::GoldenThrone.InheritHelper.snowEffect({
        id = "blizzard",
        name = "Blizzard",
        description = "A howling blizzard blinds everyone on the field. Hands freeze around weapon grips. -10 Ranged Skill, -3 Melee Skill, -4 Initiative, -3 Vision.",
        statDeltas = {
            RangedSkill = -10,
            MeleeSkill  = -3,
            Initiative  = -4,
            Vision      = -3
        }
    })
);
