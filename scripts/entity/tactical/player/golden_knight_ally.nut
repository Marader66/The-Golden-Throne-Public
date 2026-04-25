this.golden_knight_ally <- this.inherit("scripts/entity/tactical/player", {
	m = {},

	function create() {
		this.player.create();
		this.m.Name = "Golden Knight";
		this.m.IsSummoned = true;
		this.m.IsControlledByPlayer = true;
		this.m.BloodType = ::Const.BloodType.Red;
	}

	function isGuest() {
		return true;
	}

	function addXP(_xp, _scale = true) {}

	function onDeath(_killer, _skill, _tile, _fatalityType) {
		local origAddFallen = ::World.Statistics.addFallen;
		::World.Statistics.addFallen = function (_fallen) {};
		this.player.onDeath(_killer, _skill, _tile, _fatalityType);
		::World.Statistics.addFallen = origAddFallen;
	}

	function applyGoldenTint() {
		local gold = this.createColor("#FFD700");
		local layers = [
			"body",
			"head",
			"armor",
			"armor_layer_chain",
			"armor_layer_plate",
			"armor_layer_tabbard",
			"armor_layer_cloak",
			"armor_layer_cloak_front",
			"armor_upgrade_back",
			"armor_upgrade_back_top",
			"armor_upgrade_front",
			"helmet",
			"helmet_helm",
			"helmet_helm_lower",
			"helmet_top",
			"helmet_top_lower",
			"helmet_vanity",
			"helmet_vanity_2",
			"helmet_vanity_lower"
		];
		foreach (id in layers) {
			if (this.hasSprite(id)) this.getSprite(id).Color = gold;
		}
		this.setDirty(true);
	}

	function onUpdateInjuryLayer() {
		this.player.onUpdateInjuryLayer();
		this.applyGoldenTint();
	}

	function onInit() {
		this.player.onInit();

		this.setFaction(::Const.Faction.PlayerAnimals);

		this.setStartValuesEx(["sellsword_background"], false, 0, false);
		this.setName("Golden Knight");

		this.m.Talents = [];
		this.m.Attributes = [];
		for (local i = 0; i < this.Const.Attributes.COUNT; i++) {
			this.m.Talents.push(0);
			this.m.Attributes.push([]);
		}

		local p = this.getBaseProperties();
		p.Hitpoints = 110;
		p.Stamina = 175;
		p.MeleeSkill = 75;
		p.RangedSkill = 0;
		p.MeleeDefense = 20;
		p.RangedDefense = 10;
		p.Bravery = 90;
		p.Initiative = 55;
		p.ActionPoints = 9;

		this._scaleToEmperor(p);

		this.m.Hitpoints = p.Hitpoints;
		this.m.ActionPoints = p.ActionPoints;

		this.getFlags().set("human", true);
		this.getFlags().set("golden_knight_summon", true);

		local items = this.getItems();
		local body = ::new("scripts/items/legend_armor/cloth/legend_armor_gambeson");
		body.setUpgrade(::new("scripts/items/legend_armor/chain/legend_armor_hauberk_full"));
		body.setUpgrade(::new("scripts/items/legend_armor/plate/legend_armor_heavy_iron_armor"));
		items.equip(body);

		local head = ::new("scripts/items/legend_helmets/hood/legend_helmet_chain_hood");
		head.setUpgrade(::new("scripts/items/legend_helmets/helm/legend_helmet_great_helm"));
		items.equip(head);

		items.equip(::new("scripts/items/weapons/greatsword"));

		foreach (item in items.getAllItems()) {
			if (item != null) item.m.IsDroppedAsLoot = false;
		}

		this.applyGoldenTint();

		this.getSkills().add(::new("scripts/skills/perks/perk_battle_forged"));
		this.getSkills().add(::new("scripts/skills/perks/perk_steel_brow"));
		this.getSkills().add(::new("scripts/skills/perks/perk_colossus"));
		this.getSkills().add(::new("scripts/skills/perks/perk_overwhelm"));
		this.getSkills().add(::new("scripts/skills/perks/perk_fearsome"));
		this.getSkills().add(::new("scripts/skills/traits/iron_lungs_trait"));
	}

	function applyMutation(_mutationRoll) {
		local p = this.getBaseProperties();
		switch (_mutationRoll) {
			case 0:
				p.Hitpoints += 30;
				p.Initiative -= 10;
				this.setName("Ironclad Knight");
				this.getSkills().add(::new("scripts/skills/perks/perk_indomitable"));
				break;
			case 1:
				p.MeleeSkill += 15;
				p.Stamina -= 15;
				this.setName("Wrathful Knight");
				this.getSkills().add(::new("scripts/skills/perks/perk_legend_slaughterer"));
				break;
			case 2:
				p.MeleeDefense += 15;
				p.RangedDefense += 15;
				this.setName("Stalwart Knight");
				this.getSkills().add(::new("scripts/skills/perks/perk_fortified_mind"));
				break;
			case 3:
				p.Bravery += 25;
				this.setName("Zealous Knight");
				this.getSkills().add(::new("scripts/skills/perks/perk_inspiring_presence"));
				break;
			case 4:
				p.Initiative += 20;
				p.Hitpoints -= 20;
				this.setName("Swift Knight");
				this.getSkills().add(::new("scripts/skills/perks/perk_legend_quick_step"));
				break;
			default:
				p.MeleeSkill += 8;
				p.MeleeDefense += 8;
				p.Hitpoints += 15;
				this.setName("Sovereign Knight");
				this.getSkills().add(::new("scripts/skills/perks/perk_rally_the_troops"));
				break;
		}

		if (!this.getFlags().get("golden_knight_scaled")) {
			this._scaleToEmperor(p);
		}

		this.m.Hitpoints = p.Hitpoints;

		this.tryApplyPoVMutation(40);
	}

	function _scaleToEmperor(_p) {
		if (this.getFlags().get("golden_knight_scaled")) return;

		if (!("Entities" in ::Tactical) || ::Tactical.Entities == null) return;

		local emperorLevel = 0;
		foreach (e in ::Tactical.Entities.getAllInstancesAsArray()) {
			if (e == null || !e.isAlive()) continue;
			if (e.getFlags().get("GoldenEmperor")) {
				emperorLevel = e.getLevel();
				break;
			}
		}
		if (emperorLevel <= 0) return;

		_p.Hitpoints += emperorLevel * 2;
		_p.Stamina += emperorLevel;
		_p.MeleeSkill += ::Math.floor(emperorLevel / 3);
		_p.MeleeDefense += ::Math.floor(emperorLevel / 5);
		_p.Bravery += ::Math.floor(emperorLevel / 2);

		local mult;
		if (emperorLevel >= 25) mult = 5.0;
		else if (emperorLevel >= 15) mult = 3.5;
		else if (emperorLevel >= 5) mult = 1.5;
		else mult = 1.0;

		if (mult > 1.0) {
			_p.Hitpoints = ::Math.floor(_p.Hitpoints * mult);
			_p.Stamina = ::Math.floor(_p.Stamina * mult);
			_p.MeleeSkill = ::Math.floor(_p.MeleeSkill * mult);
			_p.MeleeDefense = ::Math.floor(_p.MeleeDefense * mult);
			_p.RangedDefense = ::Math.floor(_p.RangedDefense * mult);
			_p.Bravery = ::Math.floor(_p.Bravery * mult);
			_p.Initiative = ::Math.floor(_p.Initiative * mult);
		}

		this.getFlags().set("golden_knight_scaled", true);
	}

	function tryApplyPoVMutation(_chancePercent) {
		if (!("HasPoV" in ::getroottable()) || !::HasPoV) return;
		if (!("TLW" in ::getroottable()) || !("PlayerMutation" in ::TLW)) return;
		if (this.Math.rand(1, 100) > _chancePercent) return;

		local pool = [];
		foreach (key, mut in ::TLW.PlayerMutation) {
			if (!("Limit" in mut) || !mut.Limit) continue;
			if (!("Script" in mut) || mut.Script == "") continue;
			pool.push(mut);
		}
		if (pool.len() == 0) return;

		local picked = pool[this.Math.rand(0, pool.len() - 1)];
		local effect = ::new(picked.Script);
		this.getSkills().add(effect);

		if ("onCombatStarted" in effect) effect.onCombatStarted();

		if (!this.isHiddenToPlayer()) {
			::Tactical.EventLog.log("[color=#FFD700]" + this.getName() + " is infused with the blood of the " + picked.Name + "![/color]");
		}
	}
});
