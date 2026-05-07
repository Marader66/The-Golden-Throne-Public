// passive marker on the Emperor after the Original falls.
// The two ultimate miracles (Solar Ascension, Dawn's Rebirth) were burned
// out in the breaking of the dead curse. The Emperor still carries the
// fire in his hands — Pillar of Light, Radiant Judgement, Golden Command
// remain — but the world-bending powers are gone.
//
// Purely informational; the actual skill removal happens in the finale
// event (event.golden_pyramid_finale.start). This special exists so the
// player has a visible marker explaining why the skills disappeared.
this.golden_powers_spent <- ::inherit("scripts/skills/skill", {
	m = {},

	function create() {
		this.m.ID = "special.golden_powers_spent";
		this.m.Name = "Powers Spent";
		this.m.Description = "The greatest miracles you carried are gone — burned out in the breaking of the curse. The fire in your hands and the voice that rallies brothers remain. You traded the world's salvation for what made you a god.";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.IconMini = "status_effect_01_mini";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.Last;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
		this.m.IsRemovedAfterBattle = false;
	}

	function getName() {
		return this.Const.UI.getColorized(this.m.Name, "#888888");
	}

	function getTooltip() {
		return [
			{
				id = 1,
				type = "title",
				text = this.m.Name
			},
			{
				id = 2,
				type = "description",
				text = this.m.Description
			},
			{
				id = 10, type = "text", icon = "ui/icons/special.png",
				text = "[color=#888888]Solar Ascension and Dawn's Rebirth are gone.[/color]"
			},
			{
				id = 11, type = "text", icon = "ui/icons/special.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]Pillar of Light, Radiant Judgement, and Golden Command remain.[/color]"
			}
		];
	}
});
