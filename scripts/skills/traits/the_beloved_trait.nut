this.the_beloved_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.the_beloved";
		this.m.Icon = "ui/perks/holyfire_circle.png";
	}

	function getName() {
		return this.Const.UI.getColorized("The Beloved", "#FFD700");
	}

	function getDescription() {
		return "Once lost to the old empire. Returned by a thread of fate or faith — the bond with the Emperor unbroken by the grave. Carries themselves with the quiet certainty of one who has walked through the night and come back out the other side.";
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/bravery.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+25[/color] Resolve"
		});
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/melee_skill.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+5[/color] Melee Skill"
		});
		ret.push({
			id = 12,
			type = "text",
			icon = "ui/icons/ranged_defense.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+10[/color] Melee and Ranged Defense"
		});
		ret.push({
			id = 13,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Immune to routing — a presence this hard-won does not flee"
		});
		ret.push({
			id = 14,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Grants the [color=#FFD700]Beloved's Presence[/color] aura when in combat"
		});
		return ret;
	}

	function onUpdate(_properties) {
		this.character_trait.onUpdate(_properties);
		_properties.Bravery += 25;
		_properties.MeleeSkill += 5;
		_properties.MeleeDefense += 10;
		_properties.RangedDefense += 10;
		_properties.MoraleEffectMult = 0.0;
	}
});
