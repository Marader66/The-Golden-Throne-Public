this.ascended_sovereign_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.ascended_sovereign";
		this.m.Name = "Ascended Sovereign";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.Description = "This is what is left when a mortal king rules long enough to stop being mortal. The Emperor now casts his light across the whole battlefield, and not even the spent miracle of his resurrection wholly abandons him.";
		this.m.Titles = ["the Ascended", "the Radiant Throne"];
		this.m.Type = this.m.Type | ::Const.SkillType.Trait;
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		ret.push({
			id = 10, type = "text", icon = "ui/icons/special.png",
			text = "Imperial Presence aura radius [color=" + ::Const.UI.Color.PositiveValue + "]+5[/color] (10 → 15 tiles)."
		});
		ret.push({
			id = 11, type = "text", icon = "ui/icons/special.png",
			text = "Grants the [color=#FFD700]Dawn's Rebirth[/color] active skill — once per battle, AoE heal."
		});
		ret.push({
			id = 12, type = "text", icon = "ui/icons/days_wounded.png",
			text = "Even after the first resurrection is spent, survives near-fatal blows at [color=" + ::Const.UI.Color.PositiveValue + "]10×[/color] the normal chance."
		});
		return ret;
	}

	function onAdded() {
		this.character_trait.onAdded();
		if (::World != null) {
			local bonus = ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
			::World.Flags.set("GoldenEmperorAuraBonus", bonus + 5);
		}
		local actor = this.getContainer().getActor();
		if (!actor.getSkills().hasSkill("actives.dawns_rebirth")) {
			actor.getSkills().add(::new("scripts/skills/actives/dawns_rebirth_skill"));
		}
	}

	function onAfterUpdate(_properties) {
		if (::World != null && ::World.Flags.get("GoldenEmperorResurrected")) {
			_properties.SurviveWithInjuryChanceMult = _properties.SurviveWithInjuryChanceMult * 10.0;
		}
	}
});
