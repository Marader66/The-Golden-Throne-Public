this.solar_ascension_skill <- this.inherit("scripts/skills/skill", {
	m = { UsedThisCampaign = false },

	function create() {
		this.m.ID = "actives.solar_ascension";
		this.m.Name = "Solar Ascension";
		this.m.Description = "The Emperor ascends for one terrible moment, becoming a second sun. The fallen rise, borrowed from death for as long as this light endures. The living are remade — vigor returned, exhaustion lifted, every blade and prayer ready again. This miracle is given only once in a reign.";
		this.m.Icon = "ui/perks/gt_solar_ascension.png";
		this.m.IconDisabled = "ui/perks/holyfire_circle.png";
		this.m.Overlay = "active_128";
		this.m.SoundOnUse = ["sounds/combat/pov_holy_fire_04.wav"];
		this.m.SoundVolume = 2.0;
		this.m.Type = ::Const.SkillType.Active;
		this.m.Order = ::Const.SkillOrder.UtilityTargeted;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 9;
		this.m.FatigueCost = 50;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
	}

	function onCombatStarted() {
		this.m.UsedThisCampaign = ::World != null && ::World.Flags.get("GoldenThroneSolarAscensionUsed") == true;
		this.skill.onCombatStarted();
	}

	function getTooltip() {
		local used = this.m.UsedThisCampaign || (::World != null && ::World.Flags.get("GoldenThroneSolarAscensionUsed"));
		local ret = this.getDefaultTooltip();

		ret.insert(1, {
			id = 9, type = "text", icon = "ui/icons/special.png",
			text = used
				? "[color=" + ::Const.UI.Color.NegativeValue + "]ONCE PER CAMPAIGN — SPENT[/color]"
				: "[color=" + ::Const.UI.Color.NegativeValue + "]ONCE PER CAMPAIGN[/color]"
		});

		ret.push({
			id = 10, type = "text", icon = "ui/icons/health.png",
			text = "Revives every fallen ally on the battlefield at [color=" + ::Const.UI.Color.PositiveValue + "]50%[/color] of their max HP."
		});
		ret.push({
			id = 11, type = "text", icon = "ui/icons/melee_skill.png",
			text = "Sears the eyes of every sighted enemy: [color=" + ::Const.UI.Color.NegativeValue + "]2 stacks of Blindness[/color]."
		});
		ret.push({
			id = 12, type = "text", icon = "ui/icons/action_points.png",
			text = "Refreshes every living ally: [color=" + ::Const.UI.Color.PositiveValue + "]Action Points restored[/color], [color=" + ::Const.UI.Color.PositiveValue + "]Fatigue cleared[/color], [color=" + ::Const.UI.Color.PositiveValue + "]all skill cooldowns reset[/color]."
		});
		return ret;
	}

	function isUsable() {
		if (this.m.UsedThisCampaign) return false;
		if (::World != null && ::World.Flags.get("GoldenThroneSolarAscensionUsed")) return false;
		if (!this.skill.isUsable()) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null) {
			if (actor.getActionPoints() < this.m.ActionPointCost) return false;
			if (actor.getFatigue() + this.m.FatigueCost > actor.getFatigueMax()) return false;
		}
		return true;
	}

	function onUse(_user, _targetTile) {
		local userTile = _user.getTile();
		local particles = ::Const.Tactical.HolyFlameParticles;
		for (local i = 0; i < particles.len(); i++) {
			::Tactical.spawnParticleEffect(
				false, particles[i].Brushes, userTile,
				particles[i].Delay, particles[i].Quantity * 3,
				particles[i].LifeTimeQuantity, particles[i].SpawnRate,
				particles[i].Stages
			);
		}

		local casualties = ::Tactical.getCasualtyRoster().getAll();
		local revived = 0;
		foreach (dead in casualties) {
			if (dead == null) continue;
			if (dead.getFlags().get("GoldenEmperor")) continue;
			if (dead.getFlags().get("golden_knight_summon")) continue;
			if (!("setIsAlive" in dead)) continue;
			dead.setIsAlive(true);
			dead.setHitpoints(::Math.floor(dead.getHitpointsMax() * 0.5));
			dead.setFatigue(0);
			local placed = this._placeAdjacentIfDown(dead, userTile);
			if (placed) revived += 1;
		}

		local useFotn = ("FOTN" in ::getroottable()) && ("applyBlindness" in ::FOTN);
		local blinded = 0;
		local allInstances = ::Tactical.Entities.getAllInstances();
		foreach (bucket in allInstances) {
			foreach (target in bucket) {
				if (target == null || !target.isAlive() || target.isDying()) continue;
				if (target.isAlliedWith(_user)) continue;
				if (!this._canBeBlinded(target)) continue;
				if (useFotn) {
					::FOTN.applyBlindness(_user, target, 2);
				} else {
					this._applyBlindFallback(target, 2);
				}
				blinded += 1;
			}
		}

		// v2.9.0 — team refresh. Every living ally on the player's faction
		// (caster included) gets AP restored to max, fatigue cleared, and
		// every active skill's cooldown reset. Pairs with the once-per-
		// campaign cap so the power is contained.
		local refreshed = 0;
		local livingAllies = ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.Player);
		foreach (ally in livingAllies) {
			if (ally == null) continue;
			if (!ally.isAlive()) continue;
			if (ally.isDying()) continue;

			try { ally.setActionPoints(ally.getCurrentProperties().ActionPoints); } catch (e) {}
			try { ally.setFatigue(0); } catch (e) {}

			local skills = ally.getSkills().query(::Const.SkillType.Active);
			foreach (sk in skills) {
				if (sk == null) continue;
				try { sk.setCooldown(0); } catch (e) {}
			}
			refreshed += 1;
		}

		::World.Flags.set("GoldenThroneSolarAscensionUsed", true);
		this.m.UsedThisCampaign = true;

		if (!_user.isHiddenToPlayer()) {
			::Tactical.EventLog.log("[color=#FFD700]The Emperor ascends. " + revived + " of the fallen return to the light. " + blinded + " enemies reel, blinded. " + refreshed + " allies are remade.[/color]");
		}
		return true;
	}

	function _canBeBlinded(_target) {
		local flags = _target.getFlags();
		if (flags.get("skeleton")) return false;
		if (flags.get("spirit")) return false;
		return true;
	}

	function _applyBlindFallback(_target, _stacks) {
		local effectID = "effects.golden_blinded";
		local existing = _target.getSkills().getSkillByID(effectID);
		if (existing != null) {
			existing.m.Stacks = ::Math.min(existing.m.MaxStacks, existing.m.Stacks + _stacks);
			existing.m.TurnsLeft = ::Math.max(existing.m.TurnsLeft, 3);
			return;
		}
		local effect = ::new("scripts/skills/effects/golden_blinded_effect");
		effect.m.Stacks = ::Math.min(effect.m.MaxStacks, _stacks);
		effect.m.TurnsLeft = 3;
		_target.getSkills().add(effect);
	}

	function _placeAdjacentIfDown(_entity, _origin) {
		if (_entity.isPlacedOnMap()) return true;
		local frontier = [_origin];
		for (local ring = 0; ring < 4; ring++) {
			local next = [];
			foreach (tile in frontier) {
				for (local i = 0; i < 6; i++) {
					if (!tile.hasNextTile(i)) continue;
					local t = tile.getNextTile(i);
					if (t.IsEmpty && !t.IsOccupiedByActor) {
						_entity.setTile(t);
						return true;
					}
					next.push(t);
				}
			}
			frontier = next;
		}
		return false;
	}
});
