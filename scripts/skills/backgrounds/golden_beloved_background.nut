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
		// v2.9.8: deleted four more phantom-suspect fields — IsCombatBackground,
		// IsNewCompanyBackground, HireCost, DailyFoodCost. None are referenced
		// in vanilla / Legends / mod-stack background sources; only DailyCost is
		// verified working (used in 20+ Legends backgrounds). Kabu's 22:55 log:
		// 4× `the index 'IsNewCompanyBackground' does not exist` blocked brother
		// creation. Same Squirrel `=` slot-doesn't-exist throw as the v2.5.0
		// guesses we keep peeling off this background. Defaults from
		// character_background.create() are fine for a quest-reward recruit.
		this.m.DailyCost = 0;

		// v2.9.9: deleted `this.m.BackgroundStatModifiers = {...}` block —
		// fifth phantom on this same file. The slot doesn't exist on
		// character_background; same Squirrel `=` slot-doesn't-exist throw
		// pattern as the previous four (RosterTier, IsCombatBackground,
		// IsNewCompanyBackground, HireCost, DailyFoodCost). The_beloved_trait's
		// onUpdate already grants the meaningful stat bonuses (+25 Resolve,
		// +5 MS, +10 MD/RD) so this block was redundant AND broken. Caught
		// during the 2026-04-28 cross-mod audit pass before Kabu retest.

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
