// The Original. D4 Phase A boss.
//
// A god-fragment from before the empire — older than the Usurper, older than
// the dead curse. Splintered across the world; the Usurper was one shard,
// Cinderwatch's Extinguisher another. This is the prime piece. Killing him
// severs every soul-bind he ever spawned.
//
// Mirror-paired gender: opposite of the Emperor (same pattern as Fallen
// Partner). Where the Fallen Partner is the protagonist's beloved twin, the
// Original is the protagonist's pre-self — what existed in their place
// before they were anyone.
//
// Stats: Usurper-peer-tier. ~1.8× the Fallen Partner's ROTU scaling
// multiplier. ~10 AP (vs FP 9). Champion package + ROTU racial. Gold-shadow
// tint (#7A6650 — sun-scorched gold, not the FP's pale violet).
this.golden_the_original <- this.inherit("scripts/entity/tactical/player", {
	m = {
		IsFemale = true,
		IsEnraged = false   // flips at <=50% HP
	},

	function create() {
		this.player.create();
		this.m.Name = "The Original";
		this.m.BloodType = ::Const.BloodType.Dark;
		this.m.XP = 5000;
		this.m.IsSummoned = false;
		this.m.IsControlledByPlayer = false;
	}

	function isGuest() { return true; }
	function addXP(_xp, _scale = true) {}

	function onDeath(_killer, _skill, _tile, _fatalityType) {
		this.player.onDeath(_killer, _skill, _tile, _fatalityType);
		if (::World != null) {
			::World.Flags.set("GoldenOriginalDown", true);
		}
		local name = this.getName();
		::Tactical.EventLog.log("[color=#FFD700]" + name + " falls. The wind in the chamber stops. Far above, the dead in the world cease their walking.[/color]");
	}

	function onInit() {
		this.player.onInit();

		this.setFaction(::Const.Faction.Undead);

		// Mirror-pair gender to Emperor.
		local emperorIsFemale = ::World != null && ::World.Flags.get("GoldenEmperorIsFemale") == true;
		this.m.IsFemale = !emperorIsFemale;

		local originalName = this.m.IsFemale
			? "She Who Was First"
			: "He Who Was First";

		local bg = this.m.IsFemale ? "paladin_background" : "legend_crusader_background";
		this.setStartValuesEx([bg], false, 0, false);
		this.setName(originalName);

		this.m.Talents = [];
		this.m.Attributes = [];
		for (local i = 0; i < this.Const.Attributes.COUNT; i++) {
			this.m.Talents.push(0);
			this.m.Attributes.push([]);
		}

		local bp = this.m.BaseProperties;
		// base HP 400 × 1.8 ROTU scaling at Day 250 → ~1080 HP.
		// Comfortably clears the 1000-HP "feels like a real capstone" floor.
		bp.Hitpoints = 400;
		bp.Bravery = 300;
		bp.Stamina = 220;
		bp.MeleeSkill = 95;
		bp.RangedSkill = 10;
		bp.MeleeDefense = 50;
		bp.RangedDefense = 30;
		bp.Initiative = 110;
		bp.Vision = 7;
		bp.ActionPoints = 10;
		bp.IsImmuneToBleeding = true;
		bp.IsImmuneToPoison = true;
		bp.IsImmuneToBleedingInjury = true;
		bp.IsImmuneToStun = true;
		bp.IsImmuneToDaze = true;
		bp.SurvivesAsUndead = false;

		this._applyROTUScaling(bp);

		this.m.CurrentProperties = clone bp;
		this.m.Hitpoints = bp.Hitpoints;
		this.m.ActionPoints = bp.ActionPoints;

		this.getFlags().add("undead");
		this.getFlags().add("monstrous");

		local items = this.m.Items;
		items.removeAllItems();

		// Greatsword — primal authority weapon.
		local sword = ::new("scripts/items/weapons/legend_greatsword");
		sword.m.IsDroppedAsLoot = false;
		items.equip(sword);

		local body = ::new("scripts/items/legend_armor/cloth/legend_armor_gambeson");
		body.m.IsDroppedAsLoot = false;
		local mail = ::new("scripts/items/legend_armor/chain/legend_armor_hauberk_full");
		mail.m.IsDroppedAsLoot = false;
		body.setUpgrade(mail);
		local plate = ::new("scripts/items/legend_armor/legendary/legend_emperors_armor");
		plate.m.IsDroppedAsLoot = false;
		body.setUpgrade(plate);
		local cloak = ::new("scripts/items/legend_armor/cloak/legend_armor_cloak_crusader");
		cloak.m.IsDroppedAsLoot = false;
		body.setUpgrade(cloak);
		items.equip(body);

		local head = ::new("scripts/items/legend_helmets/hood/legend_helmet_chain_hood");
		head.m.IsDroppedAsLoot = false;
		local helm = ::new("scripts/items/legend_helmets/legendary/legend_emperors_countenance");
		helm.m.IsDroppedAsLoot = false;
		head.setUpgrade(helm);
		items.equip(head);

		this._applyOriginalTint();
		this._applyROTUChampionPackage();
		this._applyOriginalPerks();
		this._applyFoTNEndgame();
		this._applyPoVMutagen(100);
	}

	// ROTU scaling, doubled multiplier vs Fallen Partner. The Original is
	// meant to be the hardest fight in the campaign — Usurper-peer-tier.
	function _applyROTUScaling(_bp) {
		if (::World == null) return;

		local userMult = 1.0;
		try {
			local setting = ::Mod_ROTU.Mod.ModSettings.getSetting("DifficultyScaling");
			if (setting != null) userMult = setting.getValue() / 100.0;
		} catch (e) {}

		// 1.8× the Fallen Partner's curve. Day 250 (post-Usurper) → scale ~5.0
		// → +25% MS, +12.5% MD, +100% HP, +100% Init.
		local scale = ::Math.minf(10.0, ::World.getTime().Days / 50.0 * 1.8 * userMult);
		if (scale <= 0) return;

		_bp.MeleeSkill    = ::Math.floor(_bp.MeleeSkill    * (1 + 0.05 * scale));
		_bp.RangedSkill   = ::Math.floor(_bp.RangedSkill   * (1 + 0.05 * scale));
		_bp.MeleeDefense  = ::Math.floor(_bp.MeleeDefense  * (1 + 0.025 * scale));
		_bp.RangedDefense = ::Math.floor(_bp.RangedDefense * (1 + 0.025 * scale));
		_bp.Hitpoints     = ::Math.floor(_bp.Hitpoints     * (1 + 0.2 * scale));
		_bp.Initiative    = ::Math.floor(_bp.Initiative    * (1 + 0.2 * scale));
		_bp.Stamina       = ::Math.floor(_bp.Stamina       * (1 + 0.1 * scale));
		_bp.Bravery       = ::Math.floor(_bp.Bravery       * (1 + 0.2 * scale));
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
			champ.Color = this.createColor("#FFD700");
			champ.Saturation = 1.0;
		}
		if (this.hasSprite("miniboss")) {
			this.getSprite("miniboss").setBrush("bust_miniboss");
		}
	}

	function _applyOriginalPerks() {
		local perks = [
			"scripts/skills/perks/perk_battle_forged",
			"scripts/skills/perks/perk_colossus",
			"scripts/skills/perks/perk_steel_brow",
			"scripts/skills/perks/perk_indomitable",
			"scripts/skills/perks/perk_overwhelm",
			"scripts/skills/perks/perk_legend_composure",
			"scripts/skills/perks/perk_legend_battleheart",
			"scripts/skills/perks/perk_legend_anchor",
			"scripts/skills/perks/perk_killing_frenzy",
			"scripts/skills/perks/perk_crippling_strikes",
			"scripts/skills/perks/perk_coup_de_grace",
			"scripts/skills/perks/perk_pathfinder",
			"scripts/skills/perks/perk_fast_adaption",
			"scripts/skills/perks/perk_anticipation",
			"scripts/skills/perks/perk_relentless",
			"scripts/skills/perks/perk_underdog",
			"scripts/skills/perks/perk_berserk",
			"scripts/skills/perks/perk_legend_terrifying_visage"
		];

		foreach (path in perks) {
			local tail = path.slice(path.find("perk_") + 5);
			local id = "perk." + tail;
			if (this.m.Skills.getSkillByID(id) != null) continue;
			try { this.m.Skills.add(::new(path)); } catch (e) {}
		}
	}

	function _applyFoTNEndgame() {
		if (!("FOTN" in ::getroottable())) return;

		local paths = [
			"scripts/skills/perks/perk_fotn_bulwark",
			"scripts/skills/perks/perk_fotn_stun_resistance",
			"scripts/skills/perks/perk_fotn_blinding_speed"
		];

		foreach (path in paths) {
			local tail = path.slice(path.find("perk_fotn_") + 10);
			local id = "perk.fotn_" + tail;
			if (this.m.Skills.getSkillByID(id) != null) continue;
			try { this.m.Skills.add(::new(path)); } catch (e) {}
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
			&& ::Tactical.isActive()) {
			effect.onCombatStarted();
		}
	}

	// Sun-scorched gold — like a statue of the Emperor left in the desert
	// for ten thousand years. Not pale, not corrupt; just very old.
	function _applyOriginalTint() {
		local gold = this.createColor("#7A6650");
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
			if (this.hasSprite(id)) this.getSprite(id).Color = gold;
		}
		this.setDirty(true);
	}

	function onUpdateInjuryLayer() {
		this.player.onUpdateInjuryLayer();
		this._applyOriginalTint();
	}

	function onCombatStarted() {
		this.player.onCombatStarted();
		local name = this.getName();
		::Tactical.EventLog.log("[color=#FFD700]" + name + " regards you across the throne-chamber. \"You came back. The wheel turned. I knew it would.\"[/color]");
	}

	function onTurnStart() {
		this.player.onTurnStart();
		// FoTN stack caps (existing safety from Fallen Partner pattern).
		local vigor = this.m.Skills.getSkillByID("effects.fotn_vigor");
		if (vigor != null && vigor.m.StackCount > 5) vigor.m.StackCount = 5;
		local ironwill = this.m.Skills.getSkillByID("effects.fotn_iron_will");
		if (ironwill != null && ironwill.m.StackCount > 10) ironwill.m.StackCount = 10;
		// refresh miasma on the boss's tile + 6 adjacent at
		// every turn-start. Pattern lifted from ROTU's usurper_boss miasma
		// (lines 411-483). 2-round timeout on each tile so corruption follows
		// him as he moves.
		this._applyMiasma();
	}

	// DAMAGE-TYPE RESISTANCE.
	// Resistant to Cutting + Piercing (50% damage taken). Full damage from
	// Blunt + Burning (the carve-out). Forces players to bring hammers,
	// flails, or holy actives — narrative fits "the Original's flesh is
	// older than steel; only earth and fire still touch it."
	function onBeforeDamageReceived(_attacker, _skill, _hitInfo, _properties) {
		this.player.onBeforeDamageReceived(_attacker, _skill, _hitInfo, _properties);
		try {
			switch (_hitInfo.DamageType) {
				case ::Const.Damage.DamageType.Cutting:
					_properties.DamageReceivedRegularMult *= 0.5;
					break;
				case ::Const.Damage.DamageType.Piercing:
					_properties.DamageReceivedRegularMult *= 0.5;
					break;
				// Blunt + Burning fall through — full damage.
			}
		} catch (e) {}
	}

	// HP-50% PHASE FLIP.
	// One-time enrage when boss drops to half HP. Adds 20% damage mult,
	// switches tint from sun-scorched gold to active red-gold (the dust
	// stops; the wind shifts; he is no longer waiting). Idempotent flag
	// prevents re-trigger.
	function onDamageReceived(_attacker, _skill, _hitInfo) {
		local ret = this.player.onDamageReceived(_attacker, _skill, _hitInfo);
		try {
			if (!this.m.IsEnraged && this.getHitpointsPct() <= 0.5 && this.isAlive()) {
				this.m.IsEnraged = true;
				this.m.CurrentProperties.DamageTotalMult *= 1.20;
				// Red-gold tint overlay across all the tinted layers.
				local red = this.createColor("#A03020");
				local layers = ["body", "head", "armor", "armor_layer_chain",
					"armor_layer_plate", "armor_layer_tabbard", "helmet",
					"helmet_helm", "helmet_helm_lower"];
				foreach (id in layers) {
					if (this.hasSprite(id)) this.getSprite(id).Color = red;
				}
				this.setDirty(true);
				::Tactical.EventLog.log(
					"[color=#FFD700]"
					+ this.getName()
					+ " stops smiling. The dust in the chamber stops with him.[/color]"
				);
			}
		} catch (e) { ::logWarning("[gt original] enrage hook threw: " + e); }
		return ret;
	}

	// MIASMA AURA.
	// Refreshes a 7-tile miasma footprint (boss + 6 hex neighbors) at every
	// turn-start. Tile-tagged via vanilla BB Const.Tactical.Common.onApplyMiasma
	// callback, 2-round timeout per refresh. Filters undead + monstrous so
	// floor-5 minions are safe.
	function _applyMiasma() {
		try {
			if (!this.isPlacedOnMap() || !this.isAlive()) return;
			local center = this.getTile();
			if (center == null) return;
			local tiles = [center];
			for (local i = 0; i < 6; i++) {
				if (!center.hasNextTile(i)) continue;
				tiles.push(center.getNextTile(i));
			}
			foreach (tile in tiles) {
				if (tile == null) continue;
				if (tile.Properties != null && tile.Properties.Effect != null) {
					try { ::Tactical.Entities.removeTileEffect(tile); } catch (e) {}
				}
				local p = {
					Type = "miasma",
					Tooltip = "Miasma — the Original's presence corrupts this ground. Living things take damage at turn-end and on entry.",
					IsPositive = false,
					IsAppliedAtRoundStart = false,
					IsAppliedAtTurnEnd = true,
					IsAppliedOnMovement = true,
					IsAppliedOnEnter = true,
					IsByPlayer = false,
					Timeout = ::Time.getRound() + 2,
					Callback = ::Const.Tactical.Common.onApplyMiasma,
					function Applicable(_a) {
						local f = _a.getFlags();
						return !f.has("undead") && !f.has("monstrous");
					}
				};
				try { ::Tactical.Entities.addTileEffect(tile, p); } catch (e) {}
			}
		} catch (e) { ::logWarning("[gt original] miasma hook threw: " + e); }
	}
});
