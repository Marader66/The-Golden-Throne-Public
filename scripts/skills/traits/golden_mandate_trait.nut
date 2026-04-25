this.golden_mandate_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {
		TierStats = {
			TierLevel = 0,
			KillsExp = 0,
			ChampKillsExp = 0
		},
		Levels = [
			"Untested",
			"Initiate",
			"Devoted",
			"Consecrated",
			"Exalted",
			"Saint of the Throne"
		]
	},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.golden_mandate";
		this.m.Name = "Divine Mandate";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.IconMini = "mini_fire_circle";
		this.m.Description = "This brother serves under the Emperor's divine light. Through blood and battle the mandate grows stronger, burning away weakness and fear until only something radiant remains.";
	}

	function getTooltip() {
		local tier = this.getTierLevel();
		local kills_exp = this.m.TierStats.KillsExp;
		local champ_exp = this.m.TierStats.ChampKillsExp;
		local result = this.character_trait.getTooltip();

		switch (tier) {
			case 0:
				result.push({ id=3, type="text",
					text = "[u]Mandate [color=#FFD700]Untested I[/color]:[/u]\nThe light has touched this brother, but he has not yet proven himself." });
				result.push({ id=20, type="text", icon="ui/icons/vision.png",
					text = "[color=#FFD700]Day:[/color] +10% Melee Skill, +10 Resolve, +2 Fatigue Recovery, +1 Vision. "
						+ "[color=" + ::Const.UI.Color.NegativeValue + "]Night:[/color] -20% Melee/Ranged Skill, "
						+ "-20%%/-15%% Defenses, -3 Fatigue Recovery, -15 Resolve, -2 Vision. "
						+ "[color=#FFD700]Halved within 10 tiles of the Emperor.[/color]" });
				result.push({ id=18, type="text", icon="ui/icons/kills.png",
					text = "Chance to become an [color=#FFD700]Initiate[/color] on kill: [color=#FFD700]"
						+ ::Math.min(100, ::Math.floor(kills_exp / 150)) + "%[/color]." });
				break;
			case 1:
				result.push({ id=3, type="text",
					text = "[u]Mandate [color=#FFD700]Initiate II[/color]:[/u]\nThe mandate hardens him. He endures what others cannot." });
				result.push({ id=18, type="text", icon="ui/icons/kills.png",
					text = "Chance to become [color=#FFD700]Devoted[/color] on kill: [color=#FFD700]"
						+ ::Math.min(80, ::Math.floor(kills_exp / 500)) + "%[/color]." });
				break;
			case 2:
				result.push({ id=3, type="text",
					text = "[u]Mandate [color=#FFD700]Devoted III[/color]:[/u]\nHis conviction sharpens him. The Emperor's purpose flows through his strikes." });
				result.push({ id=18, type="text", icon="ui/icons/kills.png",
					text = "Chance to become [color=#FFD700]Consecrated[/color] on kill: [color=#FFD700]"
						+ ::Math.min(50, ::Math.floor(kills_exp / 1000)) + "%[/color]." });
				break;
			case 3:
				result.push({ id=3, type="text",
					text = "[u]Mandate [color=#FFD700]Consecrated IV[/color]:[/u]\nHoly fire moves through him. Champions will fall to earn the next tier." });
				result.push({ id=18, type="text", icon="ui/icons/kills.png",
					text = "Chance to become [color=#FFD700]Exalted[/color] on champion kill: [color=#FFD700]"
						+ (::Math.min(20, ::Math.floor(kills_exp / 2000)) + ::Math.min(25, ::Math.floor(champ_exp / 1000))) + "%[/color]." });
				break;
			case 4:
				result.push({ id=3, type="text",
					text = "[u]Mandate [color=#FFD700]Exalted V[/color]:[/u]\nBeyond ordinary human limits. The final tier demands the greatest champions fall." });
				result.push({ id=18, type="text", icon="ui/icons/kills.png",
					text = "Chance to become a [color=#FFD700]Saint[/color] on champion kill: [color=#FFD700]"
						+ (::Math.min(5, ::Math.floor(kills_exp / 3000)) + ::Math.min(10, ::Math.floor(champ_exp / 2000))) + "%[/color]." });
				break;
			case 5:
				result.push({ id=3, type="text",
					text = "[u]Mandate [color=#FFD700]Saint of the Throne VI[/color]:[/u]\nThe Emperor's light burns in this warrior's eyes. He has transcended the mortal path." });
				break;
		}

		switch (tier) {
			case 5:
				result.push({ id=15, type="text", icon="ui/icons/damage_received.png",
					text = "Immune to [color=#FFD700]bleeding[/color] and [color=#FFD700]fresh injuries[/color]. Regenerates [color=#FFD700]3%[/color] HP per turn." });
				result.push({ id=16, type="text", icon="ui/icons/armor_body.png",
					text = "Armor increased by [color=#FFD700]10%[/color]." });
			case 4:
				result.push({ id=13, type="text", icon="ui/icons/damage_received.png",
					text = "Receives [color=#FFD700]20%[/color] less damage. Immune to night, surrounding and morale penalties." });
				result.push({ id=14, type="text", icon="ui/icons/asset_money.png",
					text = "No longer needs wages or food." });
			case 3:
				result.push({ id=9, type="text", icon="ui/icons/melee_skill.png",
					text = "Melee skill [color=#FFD700]+10[/color]. Deals [color=#FFD700]10%[/color] more damage." });
				result.push({ id=10, type="text", icon="ui/icons/special.png",
					text = "[color=#FFD700]Carries the Golden Brand[/color] — a mark of the Emperor's recognition." });
			case 2:
				result.push({ id=6, type="text", icon="ui/icons/leveled_up.png",
					text = "Resolve, Initiative and Stamina increased by [color=#FFD700]20%[/color]." });
				result.push({ id=7, type="text", icon="ui/icons/fatigue.png",
					text = "Movement fatigue cost reduced by [color=#FFD700]50%[/color]. Armour fatigue penalty reduced [color=#FFD700]20%[/color]." });
			case 1:
				result.push({ id=4, type="text", icon="ui/icons/health.png",
					text = "Hitpoints [color=#FFD700]+40%[/color]. Melee and Ranged Defense [color=#FFD700]+20%[/color]. Immune to poison." });
				result.push({ id=5, type="text", icon="ui/icons/morale.png",
					text = "No longer affected by allies dying or fleeing. Ignores hitpoint loss morale." });
				break;
			case 0:
				break;
		}

		return result;
	}

	function getTierLevel() { return this.m.TierStats.TierLevel; }
	function getKillsExp() { return this.m.TierStats.KillsExp; }
	function getChampKillsExp() { return this.m.TierStats.ChampKillsExp; }
	function setKillsExp(_v) { this.m.TierStats.KillsExp = _v; }
	function setChampKillsExp(_v) { this.m.TierStats.ChampKillsExp = _v; }

	function isInEmperorPresence() {
		if (!::Tactical.isActive()) return false;
		local actor = this.getContainer().getActor();
		if (!actor.isPlacedOnMap()) return false;
		foreach (entity in ::Tactical.Entities.getAllInstancesAsArray()) {
			if (entity.getFlags().get("GoldenEmperor") && entity.isAlive() && entity.isPlacedOnMap()) {
				if (actor.getTile().getDistanceTo(entity.getTile()) <= 10) {
					return true;
				}
			}
		}
		return false;
	}

	function onUpdate(_properties) {
		local tier = this.getTierLevel();

		if (tier >= 1) {
			_properties.HitpointsMult *= 1.4;
			_properties.MeleeDefenseMult *= 1.2;
			_properties.RangedDefenseMult *= 1.2;
			_properties.IsImmuneToPoison = true;
			_properties.IsAffectedByFleeingAllies = false;
			_properties.IsAffectedByDyingAllies = false;
			_properties.IsAffectedByLosingHitpoints = false;
		}
		if (tier >= 2) {
			_properties.MovementFatigueCostMult = 0.5;
			_properties.Bravery *= 1.2;
			_properties.InitiativeMult *= 1.2;
			local actor = this.getContainer().getActor();
			local fat = actor.getItems().getStaminaModifier([::Const.ItemSlot.Body, ::Const.ItemSlot.Head]);
			_properties.Stamina += this.Math.floor(actor.getFatigueMax() * 0.2) - fat * 0.2;
			_properties.FatigueToInitiativeRate *= 0.8;
		}
		if (tier >= 3) {
			_properties.DamageTotalMult *= 1.1;
			_properties.MeleeSkill += 10;
		}
		if (tier >= 4) {
			_properties.DamageReceivedTotalMult *= 0.8;
			_properties.IsImmuneToSurrounding = true;
			_properties.IsAffectedByNight = false;
			_properties.DailyWageMult *= 0;
			_properties.DailyFood = 0;
			_properties.MoraleEffectMult = 0.0;
		}
		if (tier >= 5) {
			_properties.IsAffectedByFreshInjuries = false;
			_properties.IsImmuneToBleeding = true;
			_properties.HitpointsRecoveryRateMult *= 1.03;
			_properties.ArmorMult[0] *= 1.1;
			_properties.ArmorMult[1] *= 1.1;
		}

		_properties.SurvivesAsUndead = false;

		if (tier >= 4) return;

		if (this.World.getTime().IsDaytime) {
			_properties.MeleeSkillMult *= 1.10;
			_properties.Bravery += 10;
			_properties.FatigueRecoveryRate += 2;
			_properties.Vision += 1;
		} else {
			local inAura = this.isInEmperorPresence();
			local m = inAura ? 0.5 : 1.0;

			_properties.Vision -= this.Math.round(2 * m);
			_properties.MeleeSkillMult *= (1.0 - (0.20 * m));
			_properties.RangedSkillMult *= (1.0 - (0.20 * m));
			_properties.MeleeDefenseMult *= (1.0 - (0.20 * m));
			_properties.RangedDefenseMult *= (1.0 - (0.15 * m));
			_properties.FatigueRecoveryRate -= this.Math.round(3 * m);
			_properties.Bravery -= this.Math.round(15 * m);
		}
	}

	function setTierLevel(_level) {
		if (_level < 0 || _level > 5 || _level <= this.getTierLevel()) return;

		local actor = this.getContainer().getActor();
		local tile = actor.isPlacedOnMap() ? actor.getTile() : null;

		for (local tier = this.getTierLevel(); ++tier <= _level; ) {
			local name = this.m.Levels[tier];
			if ("EventLog" in this.Tactical) {
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(actor) + " is now a [color=#FFD700]" + name + "[/color] of the Emperor's Mandate!");
			}

			if (tier == 3 && !actor.getSkills().hasSkill("special.golden_brand")) {
				actor.getSkills().add(::new("scripts/skills/special/golden_brand"));
			}

			if (tile != null) {
				for (local i = 0; i < this.Const.Tactical.DarkflightStartParticles.len(); i++) {
					this.Tactical.spawnParticleEffect(
						true,
						this.Const.Tactical.DarkflightStartParticles[i].Brushes,
						tile,
						this.Const.Tactical.DarkflightStartParticles[i].Delay,
						this.Const.Tactical.DarkflightStartParticles[i].Quantity,
						this.Const.Tactical.DarkflightStartParticles[i].LifeTimeQuantity * 2,
						this.Const.Tactical.DarkflightStartParticles[i].SpawnRate,
						this.Const.Tactical.DarkflightStartParticles[i].Stages
					);
				}
			}
		}

		if (actor.getHitpoints() < actor.getHitpointsMax()) {
			actor.setHitpoints(actor.getHitpointsMax());
		}

		this.m.TierStats.TierLevel = _level;
		this.onApplyAppearance();
	}

	function onApplyAppearance() {
		local actor = this.getContainer().getActor();
		local tier = this.getTierLevel();

		if (tier >= 1 && actor.hasSprite("permanent_injury_4")) {
			local eyes = actor.getSprite("permanent_injury_4");
			eyes.setBrush("undead_rage_eyes");
			eyes.Visible = true;
			switch (tier) {
				case 5: eyes.Color = this.createColor("#FFD700"); eyes.Saturation = 1.5; break;
				case 4: eyes.Color = this.createColor("#FFC200"); eyes.Saturation = 1.2; break;
				case 3: eyes.Color = this.createColor("#FFAA00"); eyes.Saturation = 1.0; break;
				case 2: eyes.Color = this.createColor("#FF8800"); eyes.Saturation = 0.8; break;
				case 1: eyes.Color = this.createColor("#FF6600"); eyes.Saturation = 0.6; break;
			}
			actor.setSpriteOffset("permanent_injury_4", this.createVec(0, -2.8));
		}
		actor.setDirty(true);
	}

	function onTargetKilled(_targetEntity, _skill) {
		if (!::Tactical.isActive()) return;
		if (::Tactical.State.m.StrategicProperties != null && ::Tactical.State.m.StrategicProperties.IsArenaMode) return;

		local tier = this.getTierLevel();
		if (tier >= 5) return;

		local kills_exp = this.getKillsExp();
		local champ_exp = this.getChampKillsExp();
		local xp_gain = _targetEntity.getXPValue() * this.getContainer().getActor().getCurrentProperties().XPGainMult;
		local is_champ = _targetEntity.m.IsMiniboss;

		if (tier >= 3) {
			kills_exp += xp_gain;
			if (is_champ) champ_exp += xp_gain;

			local thresholds = [[2000, 1000, 20, 25], [3000, 2000, 5, 10]];
			local t = tier - 3;
			if (kills_exp >= thresholds[t][0] && champ_exp >= thresholds[t][1]) {
				local chance = ::Math.min(thresholds[t][2], ::Math.floor(kills_exp / thresholds[t][0]))
				             + ::Math.min(thresholds[t][3], ::Math.floor(champ_exp / thresholds[t][1]));
				if (is_champ && ::Math.rand(1, 100) <= chance) {
					this.updateKillsNeeded();
					return;
				}
			}
			this.setKillsExp(kills_exp);
			this.setChampKillsExp(champ_exp);
		} else {
			kills_exp += _targetEntity.getXPValue();
			local mins = [150, 500, 1000];
			local maxchance = [100, 80, 50];
			if (kills_exp >= mins[tier]) {
				local chance = ::Math.min(maxchance[tier], ::Math.floor(kills_exp / mins[tier]));
				if (::Math.rand(1, 100) <= chance) {
					this.updateKillsNeeded();
					return;
				}
			}
			this.setKillsExp(kills_exp);
		}
	}

	function updateKillsNeeded() {
		this.setTierLevel(this.getTierLevel() + 1);
		this.setKillsExp(0);
		this.setChampKillsExp(0);
	}

	function onCombatStarted() {
		this.onApplyAppearance();
	}

	function onAdded() {
		this.onApplyAppearance();
	}

	function onSerialize(_out) {
		::MSU.Utils.serialize(this.m.TierStats, _out);
	}

	function onDeserialize(_in) {
		::MSU.Utils.deserializeInto(this.m.TierStats, _in);
	}
});
