this.golden_emperor_background <- ::inherit("scripts/skills/backgrounds/character_background", {
	m = {
		ConsecrateDamageMin = 10,
		ConsecrateDamageMax = 20,
		ConsecrateDamageMin2H = 18,
		ConsecrateDamageMax2H = 35
	},

	function create() {
		character_background.create();
		m.ID = "background.golden_emperor";
		m.Name = "The Golden Throne";
		m.Icon = "ui/backgrounds/background_emperor.png";
		m.BackgroundDescription = "Once the undying ruler of a golden age, now stirring from an ageless slumber. The Usurper's corruption tears at the veil — and through it, something ancient remembers its purpose.";
		m.GoodEnding = "The Usurper's fortress lay shattered, its dungeon purged of the corruption that had festered for generations. The Emperor — barely a man in the eyes of those who followed him, yet ancient beyond reckoning — surveyed the ruin with calm golden eyes. The world would not remember his name. It never did. But it would live, and that was enough.";
		m.BadEnding = "The second death was quiet. No thunder. No golden light. The ancient power that had stirred within him simply... ceased. The Usurper walked free, and the tainted world grew darker still.";
		m.HiringCost = 9999999999;
		m.DailyCost = 0;
		m.Excluded = [
			"trait.fear_undead",
			"trait.fear_beasts",
			"trait.fear_greenskins",
			"trait.legend_fear_nobles",
			"trait.legend_fear_dark",
			"trait.ailing",
			"trait.weasel",
			"trait.clubfooted",
			"trait.irrational",
			"trait.hesitant",
			"trait.tiny",
			"trait.fragile",
			"trait.clumsy",
			"trait.fainthearted",
			"trait.craven",
			"trait.fat",
			"trait.greedy",
			"trait.pessimist",
			"trait.gluttonous",
			"trait.superstitious",
			"trait.short_sighted",
			"trait.paranoid",
			"trait.bleeder",
			"trait.cocky",
			"trait.disloyal",
			"trait.dumb",
			"trait.night_blind",
			"trait.night_owl",
			"trait.dastard",
			"trait.insecure",
			"trait.drunkard",
			"trait.asthmatic",
			"trait.impatient",
			"trait.loyal",
			"trait.addict",
			"trait.deathwish",
			"trait.mad",
			"trait.bloodthirsty",
			"trait.old",
			"trait.legend_slack",
			"trait.legend_unpredictable",
			"trait.legend_double_tongued",
			"trait.legend_cannibalistic",
			"trait.legend_heavy",
			"trait.legend_light",
			"trait.eagle_eyes",
			"trait.legend_steady_hands",
			"trait.legend_sureshot"
		];
		m.ExcludedTalents = [
			::Const.Attributes.RangedSkill,
			::Const.Attributes.RangedDefense
		];
		m.Bodies = ::Const.Bodies.Muscular;
		this.m.Faces = this.Const.Faces.AllHuman;
		this.m.Hairs = null;
		this.m.HairColors = this.Const.HairColors.All;
		m.BeardChance = 50;
		m.Modifiers.Ammo = ::Const.LegendMod.ResourceModifiers.Ammo[0];
		m.AlignmentMax = ::Const.LegendMod.Alignment.Saintly;
		m.AlignmentMin = ::Const.LegendMod.Alignment.Chivalrous;

		local weaponTrees = [
			this.Const.Perks.SwordTree,
			this.Const.Perks.HammerTree,
			this.Const.Perks.AxeTree,
			this.Const.Perks.SpearTree,
			this.Const.Perks.PolearmTree
		];
		if ("SwordmasterTree" in this.Const.Perks) {
			weaponTrees.push(this.Const.Perks.SwordmasterTree);
		}

		m.PerkTreeDynamic = {
			Weapon = weaponTrees,
			Defense = [
				this.Const.Perks.HeavyArmorTree,
				this.Const.Perks.MediumArmorTree,
				this.Const.Perks.ShieldTree
			],
			Traits = [
				this.Const.Perks.IndestructibleTree,
				this.Const.Perks.InspirationalTree,
				this.Const.Perks.FitTree,
				this.Const.Perks.CalmTree,
				this.Const.Perks.LargeTree,
				this.Const.Perks.IntelligentTree,
				this.Const.Perks.GiantTree
			],
			Enemy = [
				this.Const.Perks.UndeadTree,
				this.Const.Perks.OccultTree
			],
			Class = [
				this.Const.Perks.LongswordClassTree,
				this.Const.Perks.HammerClassTree
			],
			Magic = [
				this.Const.Perks.CaptainMagicTree,
				this.Const.Perks.FaithClassTree,
				this.Const.Perks.ImmortalMagicTree
			]
		};
	}

	function getName() {
		return this.Const.UI.getColorized(this.character_background.getName(), "#FFD700");
	}

	function getTooltip() {
		local ret = this.character_background.getTooltip();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/melee_skill.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+5[/color] Melee Skill, [color=" + ::Const.UI.Color.PositiveValue + "]+5[/color] Melee Defense at all times"
		});
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Every attack applies [color=" + ::Const.UI.Color.PositiveValue + "]Consecration[/color] to the target, dealing " + this.m.ConsecrateDamageMin + "-" + this.m.ConsecrateDamageMax + " holy damage per turn. Two-handed weapons deal [color=" + ::Const.UI.Color.PositiveValue + "]" + this.m.ConsecrateDamageMin2H + "-" + this.m.ConsecrateDamageMax2H + "[/color] instead."
		});
		ret.push({
			id = 12,
			type = "text",
			icon = "ui/icons/days_wounded.png",
			text = "Will [color=" + ::Const.UI.Color.PositiveValue + "]resurrect once[/color] upon fatal injury. After that, death is permanent. Cannot be raised as undead under any circumstances."
		});
		ret.push({
			id = 13,
			type = "text",
			icon = "ui/icons/morale.png",
			text = "Immune to morale checks. Immune to injuries affecting combat performance."
		});
		ret.push({
			id = 14,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Gains [color=" + ::Const.UI.Color.PositiveValue + "]+1 perk point every 3 levels past 12[/color] (15, 18, 21, ...) — the veteran reign grows richer with time."
		});
		return ret;
	}

	function onBuildDescription() {
		return this.m.BackgroundDescription;
	}

	function onAdded() {
		if (m.IsNew) {
			getContainer().add(::new("scripts/skills/traits/player_character_trait"));
			getContainer().add(::new("scripts/skills/traits/iron_lungs_trait"));
			getContainer().add(::new("scripts/skills/traits/golden_emperor_trait"));
			getContainer().add(::new("scripts/skills/aura/golden_emperor_aura"));
			getContainer().add(::new("scripts/skills/actives/summon_golden_knights_skill"));
			getContainer().getActor().getFlags().set("IsPlayerCharacter", true);
			getContainer().getActor().getFlags().set("GoldenEmperor", true);
		}
		character_background.onAdded();
		local actor = this.getContainer().getActor().get();
		actor.getFlags().set("IsRotuBackground", true);
	}

	function onAddEquipment() {}

	function onUpdate(_properties) {
		_properties.MeleeSkill += 5;
		_properties.MeleeDefense += 5;
		_properties.MoraleEffectMult = 0.0;
		_properties.IsAffectedByInjuries = false;
		_properties.IsImmuneToPoison = true;
	}

	function onAfterUpdate(_properties) {
		_properties.DailyWageMult = 0.0;
		_properties.SurvivesAsUndead = false;

		if (!::World.Flags.get("GoldenEmperorResurrected")) {
			_properties.SurviveWithInjuryChanceMult = _properties.SurviveWithInjuryChanceMult * 99.0;
		}

		local actor = this.getContainer().getActor();
		if (actor.getMoraleState() != ::Const.MoraleState.Ignore) {
			actor.setMoraleState(::Const.MoraleState.Ignore);
		}
	}

	function onAnySkillExecuted(_skill, _targetTile, _targetEntity, _forFree) {
		if (_skill == null || !_skill.isAttack() || _skill.isRanged()) {
			return;
		}
		if (_targetEntity == null || !_targetEntity.isAlive()) {
			return;
		}
		if (this.getContainer().getActor().isAlliedWith(_targetEntity)) {
			return;
		}

		local damageMin = this.m.ConsecrateDamageMin;
		local damageMax = this.m.ConsecrateDamageMax;

		local weapon = this.getContainer().getActor().getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (weapon != null && weapon.isItemType(::Const.Items.ItemType.TwoHanded)) {
			damageMin = this.m.ConsecrateDamageMin2H;
			damageMax = this.m.ConsecrateDamageMax2H;
		}

		local effectID = ::Legends.Effects.getID(::Legends.Effect.LegendConsecratedEffect);
		local existing = _targetEntity.getSkills().getSkillByID(effectID);

		if (existing != null) {
			existing.onRefresh();
			existing.m.TurnsLeft = 3;
			existing.m.DamageMin = damageMin;
			existing.m.DamageMax = damageMax;
		} else {
			local effect = ::new("scripts/skills/effects/legend_consecrated_effect");
			effect.setActor(this.getContainer().getActor());
			effect.m.TurnsLeft = 3;
			effect.m.DamageMin = damageMin;
			effect.m.DamageMax = damageMax;
			_targetEntity.getSkills().add(effect);
		}

		local emperorTrait = this.getContainer().getActor().getSkills().getSkillByID("trait.golden_emperor");
		if (emperorTrait != null && ("getPurgeTier" in emperorTrait) && emperorTrait.getPurgeTier() >= 2) {
			if (_targetEntity.getSkills().getSkillByID("effects.staggered") == null) {
				_targetEntity.getSkills().add(::new("scripts/skills/effects/staggered_effect"));
			}
		}
	}

	function onCombatStarted() {
		local actor = this.getContainer().getActor();
		actor.m.BloodType = this.Const.BloodType.Red;
	}

	function onTargetKilled(_targetEntity, _skill) {
		if (this.getContainer().getActor().isAlliedWith(_targetEntity)) return;
		local actor = this.getContainer().getActor();
		if (!actor.isHiddenToPlayer()) {
			this.spawnIcon("active_128", actor.getTile());
		}
	}

	function onSerialize(_out) {
		this.character_background.onSerialize(_out);
		_out.writeI32(this.m.ConsecrateDamageMin);
		_out.writeI32(this.m.ConsecrateDamageMax);
		_out.writeI32(this.m.ConsecrateDamageMin2H);
		_out.writeI32(this.m.ConsecrateDamageMax2H);
	}

	function onDeserialize(_in) {
		this.character_background.onDeserialize(_in);
		this.m.ConsecrateDamageMin = _in.readI32();
		this.m.ConsecrateDamageMax = _in.readI32();
		this.m.ConsecrateDamageMin2H = _in.readI32();
		this.m.ConsecrateDamageMax2H = _in.readI32();
	}
});
