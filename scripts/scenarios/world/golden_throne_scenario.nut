this.golden_throne_scenario <- this.inherit("scripts/scenarios/world/tainted_world_scenario", {

	m = {
		ChaosPlagueChance = 20,
		RavenMarkChance = 3,
		IntroEvent = "event.golden_throne_intro"
	},

	function create() {
		this.m.ID = "scenario.golden_throne";
		this.m.Name = "The Golden Throne";
		this.m.Description =
			"[p=c][img]gfx/ui/events/event_145.png[/img][/p]"
			+ "[p]Something ancient stirs beneath the tainted soil. "
			+ "An Emperor long thought dead opens his golden eyes — "
			+ "and the dead take notice.\n\n"
			+ "[color=#FFD700]The Emperor:[/color] Start as a warrior-king of the old age. "
			+ "Melee-focused, near-immune to fear, bearing divine gifts that no mage could match.\n"
			+ "[color=#FFD700]Imperial Presence:[/color] A 10-tile aura that buffs allies and prevents "
			+ "the undead from rising within his reach.\n"
			+ "[color=#FFD700]Consecration:[/color] Every blow he lands burns the target with holy flame. "
			+ "Two-handed weapons burn fiercer.\n"
			+ "[color=#FFD700]One Resurrection:[/color] The Emperor will rise once from a mortal wound. "
			+ "The second death ends the campaign. He cannot become undead.\n"
			+ "[color=#FFD700]Undead Rising:[/color] The dead stir from the very first day. "
			+ "They will grow stronger. Survive long enough and a Holy War will be called.\n"
			+ "[color=#FFD700]Summon Knights:[/color] Call two Golden Knights from the divine compact, "
			+ "each bearing a random martial blessing.[/p]";
		this.m.Difficulty = 4;
		this.m.Order = 12;
		this.m.IsFixedLook = true;
		this.m.StartingRosterTier = this.Const.Roster.getTierForSize(5);
		this.m.StartingBusinessReputation = 150;
		this.m.RosterTierMax = this.Const.Roster.getTierForSize(27);
		this.m.RosterTierMaxCombat = this.Const.Roster.getTierForSize(27);
		this.setRosterReputationTiers(this.Const.Roster.createReputationTiers(this.m.StartingBusinessReputation));
	}

	function onSpawnAssets() {
		local roster = this.World.getPlayerRoster();

		// The Emperor
		local emperor = roster.create("scripts/entity/tactical/player");
		emperor.m.HireTime = this.Time.getVirtualTimeF();
		emperor.setStartValuesEx(["golden_emperor_background"]);
		emperor.getBackground().buildDescription(true);

		local isFemale = emperor.getGender() == 1;
		emperor.setName(isFemale ? "The Empress" : "The Emperor");
		emperor.setTitle("of the Golden Throne");
		emperor.getSkills().removeByID("trait.rotu_davkul_champion");

		emperor.getSkills().add(::new("scripts/skills/traits/tough_trait"));
		emperor.getSkills().add(::new("scripts/skills/traits/legend_talented_trait"));
		emperor.getSkills().add(::new("scripts/skills/traits/petals_must_fall_trait"));

		emperor.setPlaceInFormation(4);
		emperor.getFlags().set("IsPlayerCharacter", true);
		emperor.getFlags().set("GoldenEmperor", true);
		emperor.getSprite("socket").setBrush("bust_base_crusader");
		emperor.getSprite("miniboss").setBrush("bust_miniboss_crusader");

		emperor.m.Level = 1;
		emperor.setVeteranPerks(2);

		local b = emperor.getBaseProperties();
		b.Hitpoints = 90;
		b.Stamina = 80;
		b.MeleeSkill = 75;
		b.RangedSkill = 20;
		b.MeleeDefense = 15;
		b.RangedDefense = 10;
		b.Bravery = 90;
		b.Initiative = 60;

		emperor.m.Talents = [];
		emperor.m.Attributes = [];
		local talents = emperor.getTalents();
		talents.resize(this.Const.Attributes.COUNT, 0);
		talents[this.Const.Attributes.Hitpoints] = 3;
		talents[this.Const.Attributes.MeleeSkill] = 3;
		talents[this.Const.Attributes.Bravery] = 3;
		talents[this.Const.Attributes.Fatigue] = 2;
		talents[this.Const.Attributes.MeleeDefense] = 1;
		emperor.fillAttributeLevelUpValues(this.Const.XP.MaxLevelWithPerkpoints - 1);

		local items = emperor.getItems();
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));

		local body = this.new("scripts/items/legend_armor/cloth/legend_armor_gambeson");
		body.setUpgrade(this.new("scripts/items/legend_armor/chain/legend_armor_hauberk_full"));
		body.setUpgrade(this.new("scripts/items/legend_armor/plate/legend_armor_heavy_iron_armor"));
		body.setUpgrade(this.new("scripts/items/legend_armor/cloak/legend_armor_cloak_crusader"));
		items.equip(body);

		local head = this.new("scripts/items/legend_helmets/hood/legend_helmet_chain_hood");
		head.setUpgrade(this.new("scripts/items/legend_helmets/helm/legend_helmet_great_helm"));
		head.setUpgrade(this.new("scripts/items/legend_helmets/vanity/legend_helmet_crown"));
		items.equip(head);

		items.equip(this.new("scripts/items/weapons/greatsword"));

		addScenarioPerk(emperor.getBackground(), ::Const.Perks.PerkDefs.BattleForged, 0);
		addScenarioPerk(emperor.getBackground(), ::Const.Perks.PerkDefs.InspiringPresence, 1);
		addScenarioPerk(emperor.getBackground(), ::Const.Perks.PerkDefs.SteelBrow, 2);
		addScenarioPerk(emperor.getBackground(), ::Const.Perks.PerkDefs.Colossus, 3);
		addScenarioPerk(emperor.getBackground(), ::Const.Perks.PerkDefs.RallyTheTroops, 4);
		addScenarioPerk(emperor.getBackground(), ::Const.Perks.PerkDefs.Indomitable, 5);
		addScenarioPerk(emperor.getBackground(), ::Const.Perks.PerkDefs.Overwhelm, 6);

		local grantEmperorTraits = function (bro) {
			bro.getSkills().add(::new("scripts/skills/traits/golden_mandate_trait"));
			local oath = ::new("scripts/skills/traits/golden_oath_trait");
			oath.setOathType(::Math.rand(0, 2));
			bro.getSkills().add(oath);
			bro.getSkills().add(::new("scripts/skills/traits/golden_chosen_trait"));
		};

		local crusader = roster.create("scripts/entity/tactical/player");
		crusader.setStartValuesEx(["legend_crusader_background"]);
		crusader.getBackground().buildDescription(true);
		grantEmperorTraits(crusader);
		crusader.m.HireTime = this.Time.getVirtualTimeF();
		crusader.setPlaceInFormation(3);

		for (local i = 0; i < 2; i++) {
			local paladin = roster.create("scripts/entity/tactical/player");
			paladin.setStartValuesEx(["paladin_background"]);
			paladin.getBackground().buildDescription(true);
			grantEmperorTraits(paladin);
			paladin.m.HireTime = this.Time.getVirtualTimeF();
			paladin.setPlaceInFormation(5 + i);
		}

		local monk = roster.create("scripts/entity/tactical/player");
		monk.setStartValuesEx(["monk_background"]);
		monk.getBackground().buildDescription(true);
		grantEmperorTraits(monk);
		monk.m.HireTime = this.Time.getVirtualTimeF();
		monk.setPlaceInFormation(8);

		this.World.Assets.addBusinessReputation(this.m.StartingBusinessReputation);
		::World.Assets.getStash().resize(::World.Assets.getStash().getCapacity() + 20);
		this.World.Assets.m.Money += 500;
		this.World.Assets.m.ArmorParts += 300;
		this.World.Assets.m.Medicine += 200;
		this.World.Assets.m.Ammo += 200;
	}

	function onSpawnPlayer() {
		local randomVillage;
		for (local i = 0; i != this.World.EntityManager.getSettlements().len(); ++i) {
			randomVillage = this.World.EntityManager.getSettlements()[i];
			if (!randomVillage.isMilitary()
				&& !randomVillage.isIsolatedFromRoads()
				&& randomVillage.getSize() == 1)
			{
				break;
			}
		}
		local tile = randomVillage.getTile();
		do {
			local x = this.Math.rand(
				this.Math.max(2, tile.SquareCoords.X - 1),
				this.Math.min(this.Const.World.Settings.SizeX - 2, tile.SquareCoords.X + 1));
			local y = this.Math.rand(
				this.Math.max(2, tile.SquareCoords.Y - 1),
				this.Math.min(this.Const.World.Settings.SizeY - 2, tile.SquareCoords.Y + 1));
			if (!this.World.isValidTileSquare(x, y)) continue;
			local t = this.World.getTileSquare(x, y);
			if (t.Type == this.Const.World.TerrainType.Ocean
				|| t.Type == this.Const.World.TerrainType.Shore) continue;
			if (t.getDistanceTo(tile) == 0) continue;
			if (!t.HasRoad) continue;
			tile = t;
			break;
		} while (1);

		this.World.State.m.Player = this.World.spawnEntity("scripts/entity/world/player_party", tile.Coords.X, tile.Coords.Y);

		::World.Flags.set("ModCustomPartyLook", "figure_player_crusader");
		::World.Assets.updateLook();
		::World.Ambitions.getAmbition("ambition.make_nobles_aware").setDone(true);
		this.World.getCamera().setPos(this.World.State.m.Player.getPos());

		::World.Flags.set("GoldenThronecrisisPhase", 0);
		::World.FactionManager.setGreaterEvilType(::Const.World.GreaterEvilType.Undead);
		::World.FactionManager.setGreaterEvilPhase(::Const.World.GreaterEvilPhase.Live);
		::World.FactionManager.addGreaterEvilStrength(this.Math.round(::Const.Factions.GreaterEvilStartStrength * 0.25));
		::World.Statistics.addNews("crisis_undead_start", ::World.Statistics.createNews());

		local introEvent = this.m.IntroEvent;
		this.Time.scheduleEvent(this.TimeUnit.Real, 1000, function (_tag) {
			this.Music.setTrackList(["music/undead_01.ogg"], this.Const.Music.CrossFadeTime);
			if (introEvent != null) {
				this.World.Events.fire(introEvent);
			}
		}, null);
	}

	function onInit() {
		this.starting_scenario.onInit();
		this.World.Assets.m.BrothersMaxInCombat = 27;
		this.World.Assets.m.BrothersScaleMax = 22;
		this.World.Assets.m.FoodAdditionalDays += 5;
		this.World.Assets.m.ExtraLootChance = 7;
		this.World.Assets.m.ChampionChanceAdditional += 5;
		this.World.Events.addSpecialEvent("event.mod_rotu_recruit");
		this.World.Events.addSpecialEvent("event.golden_partner_rumor");
		this.World.Events.addSpecialEvent("event.golden_partner_arrival");
		this.World.Events.addSpecialEvent("event.golden_partner_resolution");
		this.World.Events.addSpecialEvent("event.golden_throne_cleanup");
		this.World.Events.addSpecialEvent("event.golden_throne_finale");
		this.World.Events.addSpecialEvent("event.golden_ghost_dog_offer");
		this.World.Events.addSpecialEvent("event.golden_ghost_dog_ruins");
		this.World.Events.addSpecialEvent("event.golden_ghost_dog_betrayal");
		this.World.Events.addSpecialEvent("event.golden_ghost_dog_battle");
		this.World.Events.addSpecialEvent("event.golden_ghost_dog_farewell");
	}

	function onCombatFinished() {
		if (::World.Events != null && "addSpecialEvent" in ::World.Events) {
			::World.Events.addSpecialEvent("event.golden_throne_cleanup");
			::World.Events.addSpecialEvent("event.golden_throne_finale");
			::World.Events.addSpecialEvent("event.golden_ghost_dog_offer");
			::World.Events.addSpecialEvent("event.golden_ghost_dog_ruins");
			::World.Events.addSpecialEvent("event.golden_ghost_dog_betrayal");
			::World.Events.addSpecialEvent("event.golden_ghost_dog_battle");
			::World.Events.addSpecialEvent("event.golden_ghost_dog_farewell");
		}

		if (!::World.Flags.get("GoldenThroneUsurperDown")) {
			local progress = 0;
			try { progress = ::World.Statistics.getFlags().getAsInt("UsurperCastleProgress"); } catch (e) {}
			if (progress >= 19) {
				::World.Flags.set("GoldenThroneUsurperDown", true);
			}
		}

		local phase = ::World.Flags.getAsInt("GoldenThronecrisisPhase");
		if (phase < 3) {
			local evil = ::World.FactionManager.m.GreaterEvil;
			if (evil != null) {
				local isEnded = (evil.Strength <= 0)
					|| (evil.Phase == null)
					|| (evil.Phase != ::Const.World.GreaterEvilPhase.Live);
				if (isEnded) {
					phase += 1;
					::World.Flags.set("GoldenThronecrisisPhase", phase);
					switch (phase) {
						case 1:
							::World.FactionManager.setGreaterEvilType(::Const.World.GreaterEvilType.Undead);
							::World.FactionManager.setGreaterEvilPhase(::Const.World.GreaterEvilPhase.Live);
							::World.FactionManager.addGreaterEvilStrength(::Const.Factions.GreaterEvilStartStrength);
							::World.Statistics.addNews("crisis_undead_start", ::World.Statistics.createNews());
							break;
						case 2:
							::World.FactionManager.setGreaterEvilType(::Const.World.GreaterEvilType.HolyWar);
							::World.FactionManager.setGreaterEvilPhase(::Const.World.GreaterEvilPhase.Live);
							::World.FactionManager.addGreaterEvilStrength(::Const.Factions.GreaterEvilStartStrength);
							break;
						default:
							break;
					}
				}
			}
		}

		foreach (bro in this.World.getPlayerRoster().getAll()) {
			if (bro.getFlags().get("IsPlayerCharacter")) continue;
			if (bro.getLevel() >= 20 && !bro.getSkills().hasSkill("trait.golden_compact")) {
				bro.getSkills().add(::new("scripts/skills/traits/golden_compact_trait"));
				if ("EventLog" in this.Tactical && this.Tactical.isActive()) {
					this.Tactical.EventLog.log("[color=#FFD700]" + this.Const.UI.getColorizedEntityName(bro) + " has earned the Undying Compact.[/color]");
				}
			}
		}

		foreach (bro in this.World.getPlayerRoster().getAll()) {
			if (bro.getFlags().get("IsPlayerCharacter")) {
				return true;
			}
		}
		return false;
	}

	function onHiredByScenario(bro) {
		if (bro.getFlags().get("IsPlayerCharacter")) return;

		bro.getSkills().add(this.new("scripts/skills/traits/golden_mandate_trait"));
		local oath = ::new("scripts/skills/traits/golden_oath_trait");
		oath.setOathType(::Math.rand(0, 2));
		bro.getSkills().add(oath);
		bro.getSkills().add(this.new("scripts/skills/traits/golden_chosen_trait"));
		bro.improveMood(3.0, "For the Emperor and the Golden Throne!");

		if (bro.getFlags().has("human")) {
			bro.getSkills().add(::new("scripts/skills/traits/legend_deathly_spectre_trait"));
		}
	}

	function onUpdateHiringRoster(_roster) {
		this.addBroToRoster(_roster, "legend_crusader_background", 20);
		this.addBroToRoster(_roster, "paladin_background", 20);
		this.addBroToRoster(_roster, "monk_background", 15);
		this.addBroToRoster(_roster, "hedge_knight_background", 15);
		this.addBroToRoster(_roster, "squire_background", 12);
		this.addBroToRoster(_roster, "swordmaster_background", 10);
		this.addBroToRoster(_roster, "witchhunter_background", 10);
		this.addBroToRoster(_roster, "legend_man_at_arms_background", 10);
		this.addBroToRoster(_roster, "gladiator_background", 8);
		this.addBroToRoster(_roster, "legend_shieldmaiden_background", 8);
		this.addBroToRoster(_roster, "retired_soldier_background", 8);
		this.addBroToRoster(_roster, "sellsword_background", 8);
		this.addBroToRoster(_roster, "adventurous_noble_background", 7);
		this.addBroToRoster(_roster, "bastard_background", 7);
		this.addBroToRoster(_roster, "hunter_background", 7);
		this.addBroToRoster(_roster, "beast_hunter_background", 7);
		this.addBroToRoster(_roster, "barbarian_background", 7);
		this.addBroToRoster(_roster, "legend_berserker_background", 7);
		this.addBroToRoster(_roster, "assassin_background", 6);
		this.addBroToRoster(_roster, "killer_on_the_run_background", 6);
		this.addBroToRoster(_roster, "flagellant_background", 6);
		this.addBroToRoster(_roster, "bowyer_background", 6);
		this.addBroToRoster(_roster, "legend_assassin_commander_background", 25);
		this.addBroToRoster(_roster, "legend_ranger_commander_background", 25);
		this.addBroToRoster(_roster, "legend_beggar_commander_op_background", 20);
		this.addBroToRoster(_roster, "raven_bow_background", 30);
		this.addBroToRoster(_roster, "dark_guard_background", 20);
		this.addBroToRoster(_roster, "fallen_background", 20);
		this.addBroToRoster(_roster, "livingdead_background", 20);
		this.addBroToRoster(_roster, "oldling_background", 25);

		if (::HasFB) {
			this.addBroToRoster(_roster, "xxhero_baku_background", 20);
			this.addBroToRoster(_roster, "xxhero_female_background", 20);
			this.addBroToRoster(_roster, "xxhero_male_background", 20);
		}
		if (::HasPoV) {
			this.addBroToRoster(_roster, "pov_vattghern_background", 25);
			this.addBroToRoster(_roster, "pov_forsaken_background", 20);
			this.addBroToRoster(_roster, "pov_seer_background", 20);
		}
	}
});
