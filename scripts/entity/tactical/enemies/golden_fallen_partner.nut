this.golden_fallen_partner <- this.inherit("scripts/entity/tactical/player", {
	m = {
		IsFemale = true
	},

	function create() {
		this.player.create();
		this.m.Name = "The Fallen";
		this.m.BloodType = ::Const.BloodType.Dark;
		this.m.XP = 2500;
		this.m.IsSummoned = false;
		this.m.IsControlledByPlayer = false;
	}

	function isGuest() { return true; }
	function addXP(_xp, _scale = true) {}

	function onDeath(_killer, _skill, _tile, _fatalityType) {
		this.player.onDeath(_killer, _skill, _tile, _fatalityType);
		if (::World != null) {
			::World.Flags.set("GoldenThronePartnerBossKilled", true);
		}
		local name = this.getName();
		::Tactical.EventLog.log("[color=#FFD700]" + name + " falls silent. The fighting is done.[/color]");
	}

	function onInit() {
		this.player.onInit();

		this.setFaction(::Const.Faction.Undead);

		local emperorIsFemale = ::World != null && ::World.Flags.get("GoldenEmperorIsFemale") == true;
		this.m.IsFemale = !emperorIsFemale;

		local partnerName = this.m.IsFemale
			? "Valeria of the Dawn Court"
			: "Aldric the Oathsworn";

		local bg = this.m.IsFemale ? "paladin_background" : "legend_crusader_background";
		this.setStartValuesEx([bg], false, 0, false);
		this.setName(partnerName);

		this.m.Talents = [];
		this.m.Attributes = [];
		for (local i = 0; i < this.Const.Attributes.COUNT; i++) {
			this.m.Talents.push(0);
			this.m.Attributes.push([]);
		}

		local bp = this.m.BaseProperties;
		bp.Hitpoints = 220;
		bp.Bravery = 200;
		bp.Stamina = 150;
		bp.MeleeSkill = 85;
		bp.RangedSkill = 10;
		bp.MeleeDefense = 35;
		bp.RangedDefense = 25;
		bp.Initiative = 90;
		bp.Vision = 7;
		bp.ActionPoints = 9;
		bp.IsImmuneToBleeding = true;
		bp.IsImmuneToPoison = true;
		bp.IsImmuneToBleedingInjury = true;
		bp.SurvivesAsUndead = false;

		this._applyROTUScaling(bp);

		this.m.CurrentProperties = clone bp;
		this.m.Hitpoints = bp.Hitpoints;
		this.m.ActionPoints = bp.ActionPoints;

		this.getFlags().add("undead");

		local items = this.m.Items;
		items.removeAllItems();

		local sword = ::new("scripts/items/weapons/named/named_partner_sword");
		sword.m.IsDroppedAsLoot = false;
		items.equip(sword);

		local body = ::new("scripts/items/legend_armor/cloth/legend_armor_gambeson");
		body.m.IsDroppedAsLoot = false;
		if (this.m.IsFemale) {
			local plate = ::new("scripts/items/legend_armor/legendary/legend_emperors_armor");
			plate.m.IsDroppedAsLoot = false;
			body.setUpgrade(plate);
		} else {
			local mail = ::new("scripts/items/legend_armor/chain/legend_armor_hauberk_full");
			mail.m.IsDroppedAsLoot = false;
			body.setUpgrade(mail);
			local plate = ::new("scripts/items/legend_armor/legendary/legend_emperors_armor");
			plate.m.IsDroppedAsLoot = false;
			body.setUpgrade(plate);
		}
		local cloak = ::new("scripts/items/legend_armor/cloak/legend_armor_cloak_crusader");
		cloak.m.IsDroppedAsLoot = false;
		body.setUpgrade(cloak);
		items.equip(body);

		local head = ::new("scripts/items/legend_helmets/hood/legend_helmet_chain_hood");
		head.m.IsDroppedAsLoot = false;
		if (this.m.IsFemale) {
			local helm = ::new("scripts/items/helmets/named_partner_golden_countenance");
			helm.m.IsDroppedAsLoot = false;
			head.setUpgrade(helm);
		} else {
			local helm = ::new("scripts/items/legend_helmets/legendary/legend_emperors_countenance");
			helm.m.IsDroppedAsLoot = false;
			head.setUpgrade(helm);
		}
		items.equip(head);

		this._applyFallenTint();
		this._applyROTUChampionPackage();
		this._applyVariantPerks();
		this._applyFoTNEndgame();
		this._applyPoVMutagen(100);
	}

	function _applyROTUScaling(_bp) {
		if (::World == null) return;

		local userMult = 1.0;
		local setting = ::Mod_ROTU.Mod.ModSettings.getSetting("DifficultyScaling");
		if (setting != null) userMult = setting.getValue() / 100.0;

		local scale = ::Math.minf(10.0, ::World.getTime().Days / 50.0 * 1.0 * userMult);
		if (scale <= 0) return;

		_bp.MeleeSkill = ::Math.floor(_bp.MeleeSkill * (1 + 0.05 * scale));
		_bp.RangedSkill = ::Math.floor(_bp.RangedSkill * (1 + 0.05 * scale));
		_bp.MeleeDefense = ::Math.floor(_bp.MeleeDefense * (1 + 0.025 * scale));
		_bp.RangedDefense = ::Math.floor(_bp.RangedDefense * (1 + 0.025 * scale));
		_bp.Hitpoints = ::Math.floor(_bp.Hitpoints * (1 + 0.2 * scale));
		_bp.Initiative = ::Math.floor(_bp.Initiative * (1 + 0.2 * scale));
		_bp.Stamina = ::Math.floor(_bp.Stamina * (1 + 0.1 * scale));
		_bp.Bravery = ::Math.floor(_bp.Bravery * (1 + 0.2 * scale));
		_bp.FatigueRecoveryRate += scale;
	}

	function _applyROTUChampionPackage() {
		this.m.XP = ::Math.floor(this.m.XP * 1.5);
		this.m.IsMiniboss = true;
		this.m.IsGeneratingKillName = false;

		if (this.m.Skills.getSkillByID("racial.champion") == null) {
			this.m.Skills.add(::new("scripts/skills/racial/rotu_low_champion_racial"));
		}

		if (this.hasSprite("before_socket")) {
			local champ = this.getSprite("before_socket");
			champ.setBrush("champion_glow");
			champ.Color = this.createColor("#ff0000");
			champ.Saturation = 0.7;
		}
		if (this.hasSprite("miniboss")) {
			this.getSprite("miniboss").setBrush("bust_miniboss");
		}
	}

	function _applyVariantPerks() {
		local perks = this.m.IsFemale
			? [
				"scripts/skills/perks/perk_dodge",
				"scripts/skills/perks/perk_nimble",
				"scripts/skills/perks/perk_pathfinder",
				"scripts/skills/perks/perk_anticipation",
				"scripts/skills/perks/perk_legend_quick_step",
				"scripts/skills/perks/perk_backstabber",
				"scripts/skills/perks/perk_legend_slaughterer"
			]
			: [
				"scripts/skills/perks/perk_battle_forged",
				"scripts/skills/perks/perk_colossus",
				"scripts/skills/perks/perk_steel_brow",
				"scripts/skills/perks/perk_indomitable",
				"scripts/skills/perks/perk_legend_composure",
				"scripts/skills/perks/perk_legend_battleheart",
				"scripts/skills/perks/perk_legend_anchor"
			];

		foreach (path in perks) {
			local tail = path.slice(path.find("perk_") + 5);
			local id = "perk." + tail;
			if (this.m.Skills.getSkillByID(id) != null) continue;
			this.m.Skills.add(::new(path));
		}
	}

	function _applyFoTNEndgame() {
		if (!("FOTN" in ::getroottable())) return;

		local paths = this.m.IsFemale
			? [
				"scripts/skills/perks/perk_fotn_small_target",
				"scripts/skills/perks/perk_fotn_blinding_speed"
			]
			: [
				"scripts/skills/perks/perk_fotn_bulwark",
				"scripts/skills/perks/perk_fotn_stun_resistance"
			];

		foreach (path in paths) {
			local tail = path.slice(path.find("perk_fotn_") + 10);
			local id = "perk.fotn_" + tail;
			if (this.m.Skills.getSkillByID(id) != null) continue;
			this.m.Skills.add(::new(path));
		}
	}

	function _applyPoVMutagen(_chancePercent) {
		if (!("HasPoV" in ::getroottable()) || !::HasPoV) return;
		if (!("TLW" in ::getroottable()) || !("PlayerMutation" in ::TLW)) return;
		if (::Math.rand(1, 100) > _chancePercent) return;

		local pool = [];
		foreach (key, mut in ::TLW.PlayerMutation) {
			if (!("Limit" in mut) || !mut.Limit) continue;
			if (!("Script" in mut) || mut.Script == "") continue;
			pool.push(mut);
		}
		if (pool.len() == 0) return;

		local picked = pool[::Math.rand(0, pool.len() - 1)];
		local effect = ::new(picked.Script);
		this.getSkills().add(effect);

		if ("onCombatStarted" in effect
			&& "Tactical" in ::getroottable()
			&& ::Tactical != null
			&& ::Tactical.State != null
			&& ::Tactical.isActive())
		{
			effect.onCombatStarted();
		}
	}

	function _applyFallenTint() {
		local pale = this.createColor("#8A7FA2");
		local layers = [
			"body", "head",
			"armor",
			"armor_layer_chain", "armor_layer_plate", "armor_layer_tabbard",
			"armor_layer_cloak", "armor_layer_cloak_front",
			"armor_upgrade_back", "armor_upgrade_back_top", "armor_upgrade_front",
			"helmet",
			"helmet_helm", "helmet_helm_lower",
			"helmet_top", "helmet_top_lower",
			"helmet_vanity", "helmet_vanity_2", "helmet_vanity_lower"
		];
		foreach (id in layers) {
			if (this.hasSprite(id)) this.getSprite(id).Color = pale;
		}
		this.setDirty(true);
	}

	function onUpdateInjuryLayer() {
		this.player.onUpdateInjuryLayer();
		this._applyFallenTint();
	}

	function onCombatStarted() {
		this.player.onCombatStarted();
		local name = this.getName();
		::Tactical.EventLog.log("[color=#FFD700]" + name + " raises a blade that once guarded the old empire. \"Is that… you?\"[/color]");
	}

	function onTurnStart() {
		this.player.onTurnStart();
		local vigor = this.m.Skills.getSkillByID("effects.fotn_vigor");
		if (vigor != null && vigor.m.StackCount > 5) vigor.m.StackCount = 5;
		local ironwill = this.m.Skills.getSkillByID("effects.fotn_iron_will");
		if (ironwill != null && ironwill.m.StackCount > 10) ironwill.m.StackCount = 10;
	}
});
