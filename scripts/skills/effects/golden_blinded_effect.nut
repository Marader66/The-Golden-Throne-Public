this.golden_blinded_effect <- ::inherit("scripts/skills/skill", {
	m = {
		Stacks = 1,
		MaxStacks = 2,
		TurnsLeft = 3
	},

	function create() {
		this.m.ID = "effects.golden_blinded";
		this.m.Name = "Blinded by the Light";
		this.m.Icon = "skills/status_effect_52.png";
		this.m.IconMini = "status_effect_52_mini";
		this.m.Overlay = "status_effect_52";
		this.m.Type = ::Const.SkillType.StatusEffect;
		this.m.Order = ::Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = true;
	}

	function getTooltip() {
		local penaltyPct = this.m.Stacks * 20;
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description",
				text = "The afterimage of the Emperor's ascension burns in this one's eyes. They cannot see clearly." },
			{ id = 3, type = "text", icon = "ui/icons/melee_skill.png",
				text = "[color=" + ::Const.UI.Color.NegativeValue + "]-" + penaltyPct + "%[/color] Melee Skill" },
			{ id = 4, type = "text", icon = "ui/icons/ranged_skill.png",
				text = "[color=" + ::Const.UI.Color.NegativeValue + "]-" + penaltyPct + "%[/color] Ranged Skill" },
			{ id = 5, type = "text", icon = "ui/icons/special.png",
				text = "Stacks: [color=" + ::Const.UI.Color.NegativeValue + "]" + this.m.Stacks + "/" + this.m.MaxStacks + "[/color]" },
			{ id = 6, type = "text", icon = "ui/icons/initiative.png",
				text = "Remaining: [color=" + ::Const.UI.Color.NegativeValue + "]" + this.m.TurnsLeft + "[/color] turn" + (this.m.TurnsLeft == 1 ? "" : "s") }
		];
	}

	function onUpdate(_properties) {
		local mult = 1.0 - (this.m.Stacks * 0.20);
		if (mult < 0.0) mult = 0.0;
		_properties.MeleeSkillMult *= mult;
		_properties.RangedSkillMult *= mult;
	}

	function onTurnStart() {
		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0) {
			this.removeSelf();
		}
	}

	function onSerialize(_out) {
		this.skill.onSerialize(_out);
		_out.writeI32(this.m.Stacks);
		_out.writeI32(this.m.TurnsLeft);
	}

	function onDeserialize(_in) {
		this.skill.onDeserialize(_in);
		this.m.Stacks = _in.readI32();
		this.m.TurnsLeft = _in.readI32();
	}
});
