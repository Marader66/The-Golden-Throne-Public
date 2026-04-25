this.golden_oath_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {
		OathType = 0
	},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.golden_oath";
		this.m.Icon = "ui/perks/holyfire_circle.png";
	}

	function getOathName() {
		switch (this.m.OathType) {
			case 0: return "Oath of Steel";
			case 1: return "Oath of Stone";
			case 2: return "Oath of Light";
		}
		return "Oath of the Throne";
	}

	function getName() {
		return this.Const.UI.getColorized(this.getOathName(), "#FFD700");
	}

	function getDescription() {
		switch (this.m.OathType) {
			case 0: return "Sworn to the edge. This brother has pledged his blade to the Emperor's cause — every strike carries the weight of that oath.";
			case 1: return "Sworn to hold. This brother has pledged to stand between the Emperor's enemies and those in his care, no matter the cost.";
			case 2: return "Sworn to the light. This brother has pledged to carry the Emperor's divine fire, burning back the darkness wherever it stirs.";
		}
		return "";
	}

	function getTooltip() {
		local ret = this.character_trait.getTooltip();
		switch (this.m.OathType) {
			case 0:
				ret.push({ id=10, type="text", icon="ui/icons/melee_skill.png",
					text = "[color=#FFD700]+8[/color] Melee Skill" });
				ret.push({ id=11, type="text", icon="ui/icons/damage_dealt.png",
					text = "[color=#FFD700]+10%[/color] Melee damage" });
				ret.push({ id=12, type="text", icon="ui/icons/special.png",
					text = "[color=#FFD700]+1[/color] Action Point" });
				break;
			case 1:
				ret.push({ id=10, type="text", icon="ui/icons/armor_body.png",
					text = "[color=#FFD700]+15%[/color] Armour (body and head)" });
				ret.push({ id=11, type="text", icon="ui/icons/melee_defense.png",
					text = "[color=#FFD700]+8[/color] Melee Defense, [color=#FFD700]+8[/color] Ranged Defense" });
				ret.push({ id=12, type="text", icon="ui/icons/damage_received.png",
					text = "[color=#FFD700]-10%[/color] damage received" });
				break;
			case 2:
				ret.push({ id=10, type="text", icon="ui/icons/bravery.png",
					text = "[color=#FFD700]+15[/color] Resolve" });
				ret.push({ id=11, type="text", icon="ui/icons/morale.png",
					text = "Morale effects reduced by [color=#FFD700]50%[/color]. Cannot rout." });
				ret.push({ id=12, type="text", icon="ui/icons/special.png",
					text = "Deals [color=#FFD700]+20%[/color] damage to undead. Immune to undead fear effects." });
				break;
		}
		return ret;
	}

	function setOathType(_type) {
		this.m.OathType = _type;
	}

	function onUpdate(_properties) {
		switch (this.m.OathType) {
			case 0:
				_properties.MeleeSkill += 8;
				_properties.MeleeDamageMult *= 1.1;
				_properties.ActionPoints += 1;
				break;
			case 1:
				_properties.ArmorMult[0] *= 1.15;
				_properties.ArmorMult[1] *= 1.15;
				_properties.MeleeDefense += 8;
				_properties.RangedDefense += 8;
				_properties.DamageReceivedTotalMult *= 0.9;
				break;
			case 2:
				_properties.Bravery += 15;
				_properties.MoraleEffectMult *= 0.5;
				break;
		}
	}

	function onAnySkillUsed(_skill, _targetEntity, _properties) {
		if (this.m.OathType == 2 && !::MSU.isNull(_targetEntity) && _targetEntity.getFlags().has("undead")) {
			_properties.DamageTotalMult *= 1.2;
		}
	}

	function onSerialize(_out) {
		this.character_trait.onSerialize(_out);
		_out.writeI32(this.m.OathType);
	}

	function onDeserialize(_in) {
		this.character_trait.onDeserialize(_in);
		this.m.OathType = _in.readI32();
	}
});
