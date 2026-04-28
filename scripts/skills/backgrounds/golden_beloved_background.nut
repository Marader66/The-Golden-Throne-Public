this.golden_beloved_background <- ::inherit("scripts/skills/backgrounds/character_background", {
	m = {},

	function create() {
		this.character_background.create();
		this.m.ID = "background.golden_beloved";
		this.m.BackgroundDescription = "Once lost, now returned. Your beloved from the old empire stands with you again — the bond that bound you in life proved stronger than the grave.";

		// v2.9.7: removed `this.m.RosterTier = this.Const.CharacterRosterTier.Legendary;`
		// — `Const.CharacterRosterTier` is phantom (doesn't exist in vanilla,
		// Legends, or anywhere). Background API doesn't have a RosterTier
		// field anyway. Guess from v2.5.0 that never resolved because the
		// background was never instantiated until v2.9.6 fixed _grantBringBack.
		// Kabu's 22:28 log: 7× `the index 'CharacterRosterTier' does not exist`
		// at line 9 — blocked brother creation. Delete; background works fine
		// without it.
		this.m.IsCombatBackground = true;
		this.m.IsNewCompanyBackground = false;
		this.m.HireCost = 0;
		this.m.DailyCost = 0;
		this.m.DailyFoodCost = 2;

		this.m.BackgroundStatModifiers = {
			Hitpoints = 20,
			Bravery = 20,
			Stamina = 10,
			MeleeSkill = 15,
			RangedSkill = -10,
			MeleeDefense = 12,
			RangedDefense = 5,
			Initiative = 0,
			FatigueRecoveryRate = 0,
			Vision = 0,
			MeleeSkillTalent = 2,
			RangedSkillTalent = 0,
			HitpointsTalent = 2,
			BraveryTalent = 2,
			FatigueTalent = 1,
			MeleeDefenseTalent = 2
		};

		this.m.Modifiers = { Ammo = 0, Meds = 0, Stash = 0, Tools = 0 };

		this.m.Excluded = [
			"trait.coward", "trait.fragile", "trait.fainthearted",
			"trait.superstitious", "trait.pessimist", "trait.asthmatic",
			"trait.clubfooted", "trait.pacifist", "trait.craven",
			"trait.dumb", "trait.greedy", "trait.hesitant"
		];
		this.m.ExcludedTalents = [
			this.Const.Attributes.RangedSkill,
			this.Const.Attributes.RangedDefense
		];

		this.m.PerkTreeDynamic = {
			Weapon = [
				this.Const.Perks.SwordTree,
				this.Const.Perks.PolearmTree
			],
			Defense = [
				this.Const.Perks.HeavyArmorTree,
				this.Const.Perks.MediumArmorTree,
				this.Const.Perks.ShieldTree
			],
			Traits = [
				this.Const.Perks.InspirationalTree,
				this.Const.Perks.FitTree,
				this.Const.Perks.IndestructibleTree,
				this.Const.Perks.CalmTree
			],
			Enemy = [
				this.Const.Perks.UndeadTree,
				this.Const.Perks.OccultTree
			],
			Class = [
				this.Const.Perks.LongswordClassTree,
				this.Const.Perks.FaithClassTree
			],
			Magic = [
				this.Const.Perks.CaptainMagicTree
			]
		};
	}

	function getName() {
		return this.Const.UI.getColorized("The Beloved", "#FFD700");
	}

	function onBuildDescription() {
		return this.m.BackgroundDescription;
	}

	function onAfterUpdate(_properties) {
		this.character_background.onAfterUpdate(_properties);

		local actor = this.getContainer().getActor();
		if (actor == null) return;

		local emperorIsFemale = ::World != null && ::World.Flags.get("GoldenEmperorIsFemale") == true;
		actor.setGender(emperorIsFemale ? 0 : 1);

		if (actor.getSkills().getSkillByID("trait.the_beloved") == null) {
			actor.getSkills().add(::new("scripts/skills/traits/the_beloved_trait"));
		}

		if (actor.getSkills().getSkillByID("actives.beloved_presence") == null) {
			actor.getSkills().add(::new("scripts/skills/aura/beloved_presence_aura"));
		}

		if (actor.getSkills().getSkillByID("trait.golden_mandate") == null) {
			local mandate = ::new("scripts/skills/traits/golden_mandate_trait");
			if ("TierStats" in mandate.m) mandate.m.TierStats.TierLevel = 5;
			actor.getSkills().add(mandate);
		}

		if (actor.getSkills().getSkillByID("trait.golden_oath") == null) {
			local oath = ::new("scripts/skills/traits/golden_oath_trait");
			oath.setOathType(2);
			actor.getSkills().add(oath);
		}

		if (actor.getSkills().getSkillByID("trait.golden_chosen") == null) {
			local chosen = ::new("scripts/skills/traits/golden_chosen_trait");
			if ("TierLevel" in chosen.m) chosen.m.TierLevel = 3;
			actor.getSkills().add(chosen);
		}

		_properties.SurvivesAsUndead = false;
	}
});
