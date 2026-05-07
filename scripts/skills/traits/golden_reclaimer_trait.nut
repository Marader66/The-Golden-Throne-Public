// Reclaimer trait. Awarded to the Emperor on D4 Phase A
// finale (the Original's death). Marks the Emperor as the one who broke
// the dead curse. Personal capstone: small permanent stat passive +
// gold-eyes/light-tinged identity layer.
//
// Mechanically modest on purpose — the Emperor isn't ascending again.
// He has bought the world peace. The trait IS the recognition, not power.
//
// Numbers: +5 Resolve, +3 Initiative, +5 Fatigue. No combat-state effects.
this.golden_reclaimer_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.golden_reclaimer";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.Name = "Reclaimer of the World";
		this.m.Description = "Sworn to the throne, marked by the breaking of the dead curse. The age that killed the world has ended; the age that follows is built on this name.";
	}

	function getName() {
		return this.Const.UI.getColorized(this.m.Name, "#FFD700");
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		ret.push({ id=10, type="text", icon="ui/icons/bravery.png",
			text = "[color=#FFD700]+5[/color] Resolve" });
		ret.push({ id=11, type="text", icon="ui/icons/initiative.png",
			text = "[color=#FFD700]+3[/color] Initiative" });
		ret.push({ id=12, type="text", icon="ui/icons/fatigue.png",
			text = "[color=#FFD700]+5[/color] Maximum Fatigue" });
		ret.push({ id=13, type="text", icon="ui/icons/special.png",
			text = "Earned by the one who broke the dead curse." });
		return ret;
	}

	function onUpdate(_properties) {
		_properties.Bravery             += 5;
		_properties.Initiative          += 3;
		_properties.FatigueEffectiveMax += 5;
	}
});
