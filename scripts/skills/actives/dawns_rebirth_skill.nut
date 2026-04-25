this.dawns_rebirth_skill <- this.inherit("scripts/skills/skill", {
	m = {
		UsedThisBattle = false
	},

	function create() {
		this.m.ID = "actives.dawns_rebirth";
		this.m.Name = "Dawn's Rebirth";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.IconDisabled = "ui/perks/holyfire_circle.png";
		this.m.Overlay = "active_128";
		this.m.Description = "The Emperor opens the morning. Every soul sworn to his banner stirs back to strength within sight of his light.";
		this.m.SoundOnUse = ["sounds/combat/pov_holy_fire_05.wav"];
		this.m.SoundVolume = 1.8;
		this.m.Type = ::Const.SkillType.Active;
		this.m.Order = ::Const.SkillOrder.UtilityTargeted;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 30;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
	}

	function getTooltip() {
		local ret = this.getDefaultTooltip();
		ret.push({
			id = 10, type = "text", icon = "ui/icons/health.png",
			text = "Heals every ally within [color=" + ::Const.UI.Color.PositiveValue + "]15[/color] tiles for [color=" + ::Const.UI.Color.PositiveValue + "]30%[/color] of their max HP."
		});
		ret.push({
			id = 11, type = "text", icon = "ui/icons/special.png",
			text = this.m.UsedThisBattle
				? "[color=" + ::Const.UI.Color.NegativeValue + "]Already called this battle.[/color]"
				: "Once per battle."
		});
		return ret;
	}

	function isUsable() {
		if (!this.skill.isUsable()) return false;
		if (this.m.UsedThisBattle) return false;
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
				particles[i].Delay, particles[i].Quantity * 2,
				particles[i].LifeTimeQuantity, particles[i].SpawnRate,
				particles[i].Stages
			);
		}

		local healed = 0;
		foreach (entity in ::Tactical.Entities.getAllInstancesAsArray()) {
			if (entity == null || !entity.isAlive() || entity.isDying()) continue;
			if (!entity.isPlacedOnMap()) continue;
			if (!_user.isAlliedWith(entity)) continue;
			if (entity.getTile().getDistanceTo(userTile) > 15) continue;
			local heal = ::Math.floor(entity.getHitpointsMax() * 0.3);
			entity.setHitpoints(::Math.min(entity.getHitpointsMax(), entity.getHitpoints() + heal));
			healed += 1;
		}

		this.m.UsedThisBattle = true;

		if (!_user.isHiddenToPlayer()) {
			::Tactical.EventLog.log("[color=#FFD700]Dawn's Rebirth — " + healed + " allies are mended by the Emperor's light.[/color]");
		}
		return true;
	}

	function onCombatStarted() {
		this.m.UsedThisBattle = false;
	}

	function onSerialize(_out) {
		this.skill.onSerialize(_out);
		_out.writeBool(this.m.UsedThisBattle);
	}

	function onDeserialize(_in) {
		this.skill.onDeserialize(_in);
		this.m.UsedThisBattle = _in.readBool();
	}
});
