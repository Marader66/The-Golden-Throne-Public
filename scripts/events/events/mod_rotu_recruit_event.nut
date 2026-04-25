//////////////////////////////////////////////////////////////////////////////////
// Concept: Abyss Authors: Abyss & Lone Mind insofar as the og code for RotuMod //
// not to be used elsewhere or tampered with, 2024.                             //
//////////////////////////////////////////////////////////////////////////////////
this.mod_rotu_recruit_event <- this.inherit("scripts/events/event", {
	m = {
		LastCombatID = 0,
		Dude = null,
		CandidateIndex = 0,
		SortedCandidates = null,
		HasGivenFirstRecruit = false
	},
	function create() {
		local function sacrificeDude( _event )
		{

		}

		local function showBrotherStats( _list, _event )
		{
			local talents = _event.m.Dude.getTalents();
			local baseProperties = _event.m.Dude.getBaseProperties();
			local function getTalentsIcon( _talent )
			{
				switch (_talent) {
					case 0:
						return "";
					case 1:
						return "[img]gfx/ui/icons/talent_1.png[/img]";
					case 2:
						return "[img]gfx/ui/icons/talent_2.png[/img]";
					case 3:
						return "[img]gfx/ui/icons/talent_3.png[/img]";
					default:
						return "";
				}
			}
			_list.extend([
				{
					id = 9,
					icon = _event.m.Dude.getBackground().getIconColored(),
					text = _event.m.Dude.getBackground().getName()
				},
				{
					id = 9,
					text = "Brother Stats:"
				},
				{
					id = 10,
					icon = "ui/icons/health.png",
					text = "Hitpoints: " + baseProperties.Hitpoints + getTalentsIcon(talents[::Const.Attributes.Hitpoints])
				},
				{
					id = 10,
					icon = "ui/icons/fatigue.png",
					text = "Fatigue: " + baseProperties.Stamina + getTalentsIcon(talents[::Const.Attributes.Fatigue])
				},
				{
					id = 10,
					icon = "ui/icons/bravery.png",
					text = "Resolve: " + baseProperties.Bravery + getTalentsIcon(talents[::Const.Attributes.Bravery])
				},
				{
					id = 10,
					icon = "ui/icons/initiative.png",
					text = "Initiative: " + baseProperties.Initiative + getTalentsIcon(talents[::Const.Attributes.Initiative])
				},
				{
					id = 10,
					icon = "ui/icons/melee_skill.png",
					text = "Melee Skill: " + baseProperties.MeleeSkill + getTalentsIcon(talents[::Const.Attributes.MeleeSkill])
				},
				{
					id = 10,
					icon = "ui/icons/ranged_skill.png",
					text = "Ranged Skill: " + baseProperties.RangedSkill + getTalentsIcon(talents[::Const.Attributes.RangedSkill])
				},
				{
					id = 10,
					icon = "ui/icons/melee_defense.png",
					text = "Melee Defense: " + baseProperties.MeleeDefense + getTalentsIcon(talents[::Const.Attributes.MeleeDefense])
				},
				{
					id = 10,
					icon = "ui/icons/ranged_defense.png",
					text = "Ranged Defense: " + baseProperties.RangedDefense + getTalentsIcon(talents[::Const.Attributes.RangedDefense]) + "\n"
				},
				{
					id = 10,
					text = "\n"
				}
			])
		}

		local function gachaItem()
		{
			local items;
			if (this.World.Assets.getBusinessReputation() >= 3600)
			{
				items = [
					//mythic items = 0.3% / 1%
					[5, "scripts/items/weapons/named/mythic_greatsword"],
					[5, "scripts/items/weapons/named/mythic_axe"],

					//named items = 25% / 26%
					[2500 + 260, "named"],

					//loot = 34% = 34000 / 100%
					[1000, "scripts/items/loot/jeweled_crown_item"], //1250
					[1100, "scripts/items/loot/lindwurm_hoard_item"], //1200
					[2500, "scripts/items/loot/gemstones_item"], //1100
					[2500, "scripts/items/loot/golden_chalice_item"], //980
					[2900, "scripts/items/loot/ancient_gold_coins_item"], //875
					[3200, "scripts/items/loot/white_pearls_item"], //770
					[4400, "scripts/items/loot/ornate_tome_item"], //595
					[4300, "scripts/items/loot/silver_bowl_item"], //490
					[3200, "scripts/items/loot/looted_valuables_item"], //450
					[2900, "scripts/items/loot/jade_broche_item"], //400
					[2300, "scripts/items/loot/silverware_item"], //350
					[2000, "scripts/items/loot/soul_splinter_item"], //300
					[1500, "scripts/items/loot/bead_necklace_item"], //250
					[1000, "scripts/items/loot/growth_pearls_item"], //200
				];
			}
			else if (this.World.Assets.getBusinessReputation() >= 2400)
			{
				items = [
					[1600 + 260, "named"],

					//loot = 44% / 100%
					[1000, "scripts/items/loot/jeweled_crown_item"], //1250
					[1100, "scripts/items/loot/lindwurm_hoard_item"], //1200
					[2500, "scripts/items/loot/gemstones_item"], //1100
					[2600, "scripts/items/loot/golden_chalice_item"], //980
					[3000, "scripts/items/loot/ancient_gold_coins_item"], //875
					[3300, "scripts/items/loot/white_pearls_item"], //770
					[4500, "scripts/items/loot/ornate_tome_item"], //595
					[4400, "scripts/items/loot/silver_bowl_item"], //490
					[3300, "scripts/items/loot/looted_valuables_item"], //450
					[3000, "scripts/items/loot/jade_broche_item"], //400
					[2400, "scripts/items/loot/silverware_item"], //350
					[2100, "scripts/items/loot/soul_splinter_item"], //300
					[1600, "scripts/items/loot/bead_necklace_item"], //250
					[1000, "scripts/items/loot/growth_pearls_item"], //200
				];
			}
			else
			{
				items = [
					//named items = 1% / 1%
					[100 + 260, "named"],

					//loot = 59% / 100%
					[1100, "scripts/items/loot/jeweled_crown_item"], //1250
					[1200, "scripts/items/loot/lindwurm_hoard_item"], //1200
					[2600, "scripts/items/loot/gemstones_item"], //1100
					[2700, "scripts/items/loot/golden_chalice_item"], //980
					[3100, "scripts/items/loot/ancient_gold_coins_item"], //875
					[3400, "scripts/items/loot/white_pearls_item"], //770
					[4600, "scripts/items/loot/ornate_tome_item"], //595
					[4600, "scripts/items/loot/silver_bowl_item"], //490
					[3400, "scripts/items/loot/looted_valuables_item"], //450
					[3100, "scripts/items/loot/jade_broche_item"], //400
					[2500, "scripts/items/loot/silverware_item"], //350
					[2200, "scripts/items/loot/soul_splinter_item"], //300
					[1700, "scripts/items/loot/bead_necklace_item"], //250
					[1100, "scripts/items/loot/growth_pearls_item"], //200
				];
			}
			local totalWeight = 0;
			local result;
			foreach(item in items) {
				totalWeight += item[0];
			}
			local r = this.Math.rand(0, totalWeight);
			foreach(item in items) {
				r = r - item[0];
				if (r <= 0) {
					if (item[1] == "named")
					{
						local rand_named = this.Math.rand(1, 100);
						if (r <= 40) {
							local weapons = clone::Const.Items.NamedWeapons;
							result = ::new("scripts/items/" + ::MSU.Array.rand(weapons));

						} else if (r <= 60) {
							local shields = clone::Const.Items.NamedShields;
							result = ::new("scripts/items/" + ::MSU.Array.rand(shields));

						} else if (r <= 80) {
							local weightName = ::Const.World.Common.convNameToList(clone ::Const.Items.NamedHelmets);
							result = ::Const.World.Common.pickHelmet(weightName);

						} else {
							local weightName = ::Const.World.Common.convNameToList(clone ::Const.Items.NamedArmors);
							result = ::Const.World.Common.pickArmor(weightName);
						}
					}
					else
					{
						result = ::new(item[1]);
					}
					break;
				}
			}
			return result;
		}

		local backgroundCache = {};
		local function backgroundExists(_id)
		{
			if (_id in backgroundCache) return backgroundCache[_id];
			local ok = false;
			try {
				::new("scripts/skills/backgrounds/" + _id);
				ok = true;
			} catch (e) { ok = false; }
			backgroundCache[_id] <- ok;
			return ok;
		}

		local function gachaBackgrounds(_event)
		{
			if (!_event.m.HasGivenFirstRecruit)
			{
				_event.m.HasGivenFirstRecruit = true;
				local legendaries = [
					"fallen_background",
					"dark_guard_background",
					"dark_wraith_background",
					"livingdead_background",
					"raven_bow_background",
					"rotu_skinwalker_background",
					"legend_beggar_commander_op_background",
					"legend_assassin_commander_background",
					"oldling_background"
				];
				local available = legendaries.filter(@(_i, _id) backgroundExists(_id));
				if (available.len() == 0) return ["sellsword_background"];
				return [available[this.Math.rand(0, available.len() - 1)]];
			}

			// Quality scales with campaign days. Every 30 days = +1 bonus point, cap 10.
			local days = this.World.getTime().Days;
			local bonus = days / 30;
			if (bonus > 10) bonus = 10;

			local wApprentice = 12 - bonus * 2;   // 12 → 2
			if (wApprentice < 2) wApprentice = 2;
			local wLegendary  = 1 + bonus * 3;    // 1  → 31
			local wRare       = 2 + bonus * 2;    // 2  → 22
			local wRare3      = 3 + bonus * 2;    // 3  → 23  (crusader — slightly above other rares)

			local backgrounds = [
				[wApprentice, "apprentice_background"]
			];

			// Legendary tier (scaled)
			backgrounds.extend([
				[wLegendary, "fallen_background"],
				[wLegendary, "dark_guard_background"],
				[wLegendary, "dark_wraith_background"],
				[wLegendary, "livingdead_background"],
				[wLegendary, "raven_bow_background"],
				[wLegendary, "rotu_skinwalker_background"],
				[wLegendary, "legend_beggar_commander_op_background"],
				[wLegendary, "legend_assassin_commander_background"],
				[wLegendary, "oldling_background"]
			]);

			// Rare tier (scaled)
			backgrounds.extend([
				[wRare,  "hedge_knight_background"],
				[wRare,  "legend_berserker_commander_background"],
				[wRare,  "swordmaster_background"],
				[wRare3, "crusader_background"]
			]);

			// Uncommon/common tiers — 2.2.1's flat weights preserved.
			backgrounds.extend([
				[10, "squire_background"],
				[8,  "gladiator_background"],
				[8,  "legend_shieldmaiden_background"],
				[7,  "hunter_background"],
				[9,  "paladin_background"],
				[9,  "legend_berserker_background"],
				[10, "assassin_background"],
				[10, "assassin_southern_background"],
				[10, "anatomist_background"],
				[10, "adventurous_noble_background"],
				[12, "wildman_background"],
				[12, "bastard_background"],
				[12, "monk_background"],
				[12, "retired_soldier_background"],
				[12, "thief_background"],
				[12, "vagabond_background"],
				[11, "beast_hunter_background"],
				[11, "killer_on_the_run_background"],
				[11, "bowyer_background"],
				[11, "sellsword_background"],
				[11, "witchhunter_background"],
				[11, "barbarian_background"],
				[12, "militia_background"],
				[12, "nomad_background"],
				[12, "houndmaster_background"],
				[11, "raider_background"]
			]);

			// Filter to only backgrounds actually loaded in this install.
			local filtered = [];
			foreach (bg in backgrounds) {
				if (backgroundExists(bg[1])) filtered.push(bg);
			}
			if (filtered.len() == 0) return ["sellsword_background"];

			local totalWeight = 0;
			foreach (bg in filtered) totalWeight += bg[0];
			local r = this.Math.rand(0, totalWeight);
			local result = [];
			foreach (bg in filtered) {
				r = r - bg[0];
				if (r <= 0) {
					result.push(bg[1]);
					break;
				}
			}
			return result;
		}

		this.m.ID = "event.mod_rotu_recruit";
		this.m.Title = "After the battle...";
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "Bandits",
			Text = "[img]gfx/ui/events/rotu_post_bandits.png[/img]{ Bandits, they seem to be getting stronger as your pursuit to find the lair of the Usurper goes forward. You nod to your band of warriors to go through the dead and search for any loot that might be found.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Yes, join us.",
				function getResult(_event) {
					if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
					}
					else
					{
						return "RosterFull";
					}
					return 0;
				}
			},
			{
				Text = "Dismiss him",
				function getResult(_event) {
					return "Sacrifice";
				}
			}
			],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);

				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}
		});

		this.m.Screens.push({
			ID = "BanditsSoutherner",
			Text = "[img]gfx/ui/events/event_10.png[/img]{ Bandits, they seem to be getting stronger as your pursuit to find the lair of the Usurper goes forward. You nod to your band of warriors to go through the dead and search for any loot that might be found.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Yes, join us.",
				function getResult(_event) {
					if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
					}
					else
					{
						return "RosterFull";
					}
					return 0;
				}
			},
			{
				Text = "Dismiss him",
				function getResult(_event) {
					return "Sacrifice";
				}
			}
			],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);

				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Barbarians",
			Text = "[img]gfx/ui/events/event_145.png[/img]{ You contemplate the fallen bodies of these sons of the North, these Barbarians who fight as wild as they look. Your warband knows what to do, they have started to plunder the dead for gear or trinkets.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Yes, join us.",
				function getResult(_event) {
					if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
					}
					else
					{
						return "RosterFull";
					}
					return 0;
				}
			},
			{
				Text = "Dismiss him",
				function getResult(_event) {
					return "Sacrifice";
				}
			}
			],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);

				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "BarbariansNortherner",
			Text = "[img]gfx/ui/events/event_145.png[/img]{ You contemplate the fallen bodies of these sons of the North, these Barbarians who fight as wild as they look. Your warband knows what to do, they have started to plunder the dead for gear or trinkets.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Yes, join us.",
				function getResult(_event) {
					if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
					}
					else
					{
						return "RosterFull";
					}
					return 0;
				}
			},
			{
				Text = "Dismiss him",
				function getResult(_event) {
					return "Sacrifice";
				}
			}
			],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);

				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Nomads",
			Text = "[img]gfx/ui/events/event_168.png[/img]{ Another hard fought battle versus the hot blooded nomadic warriors of the South. They must have weapons and gold on their slain bodies you command your troops to search.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Yes, join us.",
				function getResult(_event) {
					if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
					}
					else
					{
						return "RosterFull";
					}
					return 0;
				}
			},
			{
				Text = "Dismiss him",
				function getResult(_event) {
					return "Sacrifice";
				}
			}
			],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);

				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});

		this.m.Screens.push({
			ID = "NomadsNortherner",
			Text = "[img]gfx/ui/events/event_168.png[/img]{ Another hard fought battle versus the hot blooded nomadic warriors of the South. They must have weapons and gold on their slain bodies you command your troops to search.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Yes, join us.",
				function getResult(_event) {
					if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
					}
					else
					{
						return "RosterFull";
					}
					return 0;
				}
			},
			{
				Text = "Dismiss him",
				function getResult(_event) {
					return "Sacrifice";
				}
			}
			],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);

				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Citymen",
			Text = "[img]gfx/ui/events/event_168.png[/img]{ Another hard fought battle versus the hot blooded nomadic warriors of the South. They must have weapons and gold on their slain bodies you command your troops to search.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Yes, join us.",
				function getResult(_event) {
					if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
					}
					else
					{
						return "RosterFull";
					}
					return 0;
				}
			},
			{
				Text = "Dismiss him",
				function getResult(_event) {
					return "Sacrifice";
				}
			}
			],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);

				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Undead",
			Text = "[img]gfx/ui/events/event_29.png[/img]{ Will these hordes of undead never stop? They must be fueled by the Usurper to pillage and destroy the lands. Let us see if they have any treasure or captives among there destroyed corpses.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
					Text = "Yes, join us.",
					function getResult(_event) {
						if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
						{
							this.World.getPlayerRoster().add(_event.m.Dude);
							this.World.getTemporaryRoster().clear();
							_event.m.Dude.onHired();
							_event.m.Dude = null;
						}
						else
						{
							return "RosterFull";
						}
						return 0;
					}
				},
				{
					Text = "Dismiss him",
					function getResult(_event) {
						return "Sacrifice";
					}
				}
				],
			function start(_event) {
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");

				_event.m.Dude.setStartValuesEx(gachaBackgrounds(_event));
				this.Characters.push(_event.m.Dude.getImagePath());
				showBrotherStats( this.List, _event);



				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.addAmmo(50);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = "You gain 50 Ammo"
				});

				local item = gachaItem();

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "RosterFull",
			Text = "{Your company is full. You will need to let someone go before this man can join your warband. Review your brothers below and decide who to release.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Review brothers from weakest to strongest.",
					function getResult(_event) {
						_event.m.CandidateIndex = 0;
						return "DismissCandidate";
					}
				},
				{
					Text = "Dismiss the recruit instead.",
					function getResult(_event) {
						return "Sacrifice";
					}
				}
			],
			function start(_event) {
				// Build and cache the roster sorted weakest-first by total base stats
				local brothers = this.World.getPlayerRoster().getAll();
				local scored = [];
				foreach (brother in brothers) {
					local p = brother.getBaseProperties();
					local score = p.Hitpoints + p.Stamina + p.Bravery + p.Initiative
								+ p.MeleeSkill + p.RangedSkill + p.MeleeDefense + p.RangedDefense;
					scored.push({ brother = brother, score = score });
				}
				scored.sort(function(a, b) { return a.score <=> b.score; });
				_event.m.SortedCandidates = scored;
			}
		});
		this.m.Screens.push({
			ID = "DismissCandidate",
			Text = "{Who will you dismiss to make room?}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Dismiss this brother and recruit the new man.",
					function getResult(_event) {
						local candidate = _event.m.SortedCandidates[_event.m.CandidateIndex].brother;
						this.World.getPlayerRoster().remove(candidate);
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
						_event.m.SortedCandidates = null;
						_event.m.CandidateIndex = 0;
						return 0;
					}
				},
				{
					Text = "Show next brother.",
					function getResult(_event) {
						_event.m.CandidateIndex = (_event.m.CandidateIndex + 1) % _event.m.SortedCandidates.len();
						return "DismissCandidate";
					}
				},
				{
					Text = "Dismiss the recruit instead.",
					function getResult(_event) {
						_event.m.SortedCandidates = null;
						_event.m.CandidateIndex = 0;
						return "Sacrifice";
					}
				}
			],
			function start(_event) {
				this.List.clear();
				this.Characters.clear();
				local entry = _event.m.SortedCandidates[_event.m.CandidateIndex];
				local brother = entry.brother;
				local p = brother.getBaseProperties();
				local talents = brother.getTalents();
				local function getTalentsIcon( _talent )
				{
					switch (_talent) {
						case 0: return "";
						case 1: return "[img]gfx/ui/icons/talent_1.png[/img]";
						case 2: return "[img]gfx/ui/icons/talent_2.png[/img]";
						case 3: return "[img]gfx/ui/icons/talent_3.png[/img]";
						default: return "";
					}
				}
				local total = _event.m.SortedCandidates.len();
				local idx = _event.m.CandidateIndex + 1;
				this.Characters.push(brother.getImagePath());
				this.List.extend([
					{
						id = 9,
						icon = brother.getBackground().getIconColored(),
						text = brother.getName() + " (" + idx + " of " + total + ")"
					},
					{
						id = 9,
						text = brother.getBackground().getName()
					},
					{
						id = 9,
						text = "Brother Stats:"
					},
					{
						id = 10,
						icon = "ui/icons/health.png",
						text = "Hitpoints: " + p.Hitpoints + getTalentsIcon(talents[::Const.Attributes.Hitpoints])
					},
					{
						id = 10,
						icon = "ui/icons/fatigue.png",
						text = "Fatigue: " + p.Stamina + getTalentsIcon(talents[::Const.Attributes.Fatigue])
					},
					{
						id = 10,
						icon = "ui/icons/bravery.png",
						text = "Resolve: " + p.Bravery + getTalentsIcon(talents[::Const.Attributes.Bravery])
					},
					{
						id = 10,
						icon = "ui/icons/initiative.png",
						text = "Initiative: " + p.Initiative + getTalentsIcon(talents[::Const.Attributes.Initiative])
					},
					{
						id = 10,
						icon = "ui/icons/melee_skill.png",
						text = "Melee Skill: " + p.MeleeSkill + getTalentsIcon(talents[::Const.Attributes.MeleeSkill])
					},
					{
						id = 10,
						icon = "ui/icons/ranged_skill.png",
						text = "Ranged Skill: " + p.RangedSkill + getTalentsIcon(talents[::Const.Attributes.RangedSkill])
					},
					{
						id = 10,
						icon = "ui/icons/melee_defense.png",
						text = "Melee Defense: " + p.MeleeDefense + getTalentsIcon(talents[::Const.Attributes.MeleeDefense])
					},
					{
						id = 10,
						icon = "ui/icons/ranged_defense.png",
						text = "Ranged Defense: " + p.RangedDefense + getTalentsIcon(talents[::Const.Attributes.RangedDefense]) + "\n"
					}
				]);
			}
		});

		this.m.Screens.push({
			ID = "Sacrifice",
			Text = "{You Dismissed him}",
			Image = "",
			List = [],
			Characters = [],
			Options = [{
					Text = "Continue.",
					function getResult(_event) {
						return 0;
					}
				}
				],
			function start(_event) {
				this.World.Assets.getStash().makeEmptySlots(1);
			}

		});

	}

	function isValid() {
		if (!::Mod_ROTU.Scenario.isRecruitEventEnabled()) {
			return;
		}

		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		/*if (this.World.getTime().Days < 30) // maybe add a day limit to begin?
		{
			return;
		}*/

		if (this.World.Statistics.getFlags().getAsInt("LastCombatID") <= this.m.LastCombatID) {
			return;
		}

		local f = this.World.FactionManager.getFaction(this.World.Statistics.getFlags().getAsInt("LastCombatFaction"));

		if (f == null) {
			return false;
		}

		this.m.LastCombatID = this.World.Statistics.getFlags().get("LastCombatID");
		return true;
	}

	function onUpdateScore() {
		return;
	}

	function onPrepare() {}

	function onPrepareVariables(_vars) {

	}

	function onDetermineStartScreen() {
		local f = this.World.FactionManager.getFaction(this.World.Statistics.getFlags().getAsInt("LastCombatFaction"));

		if (f.getType() == this.Const.FactionType.Bandits) {
			if (this.Math.rand(1, 100) <= 60) {
				return "Bandits";
			} else {
				return "BanditsSoutherner";
			}
		} else if (f.getType() == this.Const.FactionType.Barbarians) {
			if (this.Math.rand(1, 100) <= 60) {
				return "Barbarians";
			} else {
				return "BarbariansNortherner";
			}
		} else if (f.getType() == this.Const.FactionType.OrientalBandits) {
			if (this.Math.rand(1, 100) <= 60) {
				return "Nomads";
			} else {
				return "NomadsNortherner";
			}
		}else if (f.getType() == this.Const.FactionType.OrientalCityState) {
			return "Citymen";
		}
		else if (f.getType() == this.Const.FactionType.Zombies) {
			return "Undead";
		}
		else
		{
			return "Bandits";
		}
	}

	function onClear() {
		this.m.Dude = null;
		this.m.CandidateIndex = 0;
		this.m.SortedCandidates = null;
	}

	function onSerialize(_out) {
		this.event.onSerialize(_out);
		_out.writeU32(this.m.LastCombatID);
	}

	function onDeserialize(_in) {
		this.event.onDeserialize(_in);

		if (_in.getMetaData().getVersion() >= 54) {
			this.m.LastCombatID = _in.readU32();
		}
	}
});
