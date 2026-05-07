this.golden_chosen_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {
		FightsSurvived = 0,
		TierLevel = 0,
		Levels = ["Sworn", "Battle-Tested", "Veteran", "Exemplar"]
	},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.golden_chosen";
		this.m.Name = "Emperor's Chosen";
		this.m.Icon = "ui/perks/gt_emperors_chosen.png";
		this.m.Description = "This brother has sworn himself to the Emperor's cause above all else. He will not retreat. He will not surrender. As battles stack up the Emperor's favour grows heavier in him — and so does his resolve to see this through.";
	}

	function getTooltip() {
		local tier = this.m.TierLevel;
		local fights = this.m.FightsSurvived;
		local thresholds = [0, 25, 75, 150];
		local ret = this.character_trait.getTooltip();

		ret.push({ id=3, type="text", icon="ui/icons/kills.png",
			text = "Battles survived: [color=#FFD700]" + fights + "[/color]"
				+ (tier < 3 ? " / " + thresholds[tier + 1] + " for next tier." : " — final tier reached.") });

		ret.push({ id=9, type="text", icon="ui/icons/morale.png",
			text = "[color=#FFD700]Cannot rout or flee[/color] under any circumstances." });

		switch (tier) {
			case 3:
				ret.push({ id=15, type="text", icon="ui/icons/bravery.png",
					text = "[color=#FFD700]+20[/color] Resolve. Completely immune to morale." });
			case 2:
				ret.push({ id=13, type="text", icon="ui/icons/armor_body.png",
					text = "[color=#FFD700]+10%[/color] Armour. [color=#FFD700]+5[/color] Melee Defense." });
			case 1:
				ret.push({ id=11, type="text", icon="ui/icons/health.png",
					text = "[color=#FFD700]+15[/color] Hitpoints. [color=#FFD700]+5[/color] Melee Skill." });
				break;
			case 0:
				ret.push({ id=11, type="text", icon="ui/icons/special.png",
					text = "Survive [color=#FFD700]25[/color] battles to become Battle-Tested." });
				break;
		}

		return ret;
	}

	function onUpdate(_properties) {
		local tier = this.m.TierLevel;

		_properties.MoraleEffectMult = 0.0;

		if (tier >= 1) {
			_properties.Hitpoints += 15;
			_properties.MeleeSkill += 5;
		}
		if (tier >= 2) {
			_properties.ArmorMult[0] *= 1.1;
			_properties.ArmorMult[1] *= 1.1;
			_properties.MeleeDefense += 5;
		}
		if (tier >= 3) {
			_properties.Bravery += 20;
		}
	}

	function onCombatFinished() {
		if (this.m.TierLevel >= 3) return;

		this.m.FightsSurvived += 1;

		local thresholds = [25, 75, 150];
		local next = thresholds[this.m.TierLevel];

		if (this.m.FightsSurvived >= next) {
			this.advanceTier();
		}
	}

	function advanceTier() {
		if (this.m.TierLevel >= 3) return;
		this.m.TierLevel += 1;

		local actor = this.getContainer().getActor();
		local name = this.m.Levels[this.m.TierLevel];

		if (!::MSU.isNull(actor)) {
			if ("EventLog" in this.Tactical) {
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(actor) + " is now the Emperor's [color=#FFD700]" + name + "[/color]!");
			}
			if (actor.getHitpoints() < actor.getHitpointsMax()) {
				actor.setHitpoints(actor.getHitpointsMax());
			}
		}
	}

	function onSerialize(_out) {
		this.character_trait.onSerialize(_out);
		_out.writeI32(this.m.FightsSurvived);
		_out.writeI32(this.m.TierLevel);
	}

	function onDeserialize(_in) {
		this.character_trait.onDeserialize(_in);
		this.m.FightsSurvived = _in.readI32();
		this.m.TierLevel = _in.readI32();
	}
});
