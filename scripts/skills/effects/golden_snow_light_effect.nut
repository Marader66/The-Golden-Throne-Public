// v2.12.2 — refactored to use ::GoldenThrone.InheritHelper.snowEffect.
// Boilerplate (create() body + status-effect flags) lives in the helper;
// this file only owns the per-effect data (id, name, description, deltas).
this.golden_snow_light_effect <- this.inherit("scripts/skills/skill",
    ::GoldenThrone.InheritHelper.snowEffect({
        id = "light",
        name = "Light Snow",
        description = "A gentle snowfall dusts the field. -3 Ranged Skill, -1 Vision.",
        statDeltas = {
            RangedSkill = -3,
            Vision      = -1
        }
    })
);
