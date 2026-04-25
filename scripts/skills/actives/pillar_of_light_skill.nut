this.pillar_of_light_skill <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown = 0,
		CooldownMax = 3
	},

	function create() {
		this.m.ID = "actives.pillar_of_light";
		this.m.Name = "Pillar of Light";
		this.m.Description = "A shaft of divine fire descends on the target, scorching the ground around it. Undead, beasts, and monstrous creatures burn hotter.";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.IconDisabled = "ui/perks/holyfire_circle.png";
		this.m.Overlay = "active_128";
		this.m.SoundOnUse = ["sounds/combat/pov_holy_fire_01.wav"];
		this.m.SoundVolume = 1.5;
		this.m.Type = ::Const.SkillType.Active;
		this.m.Order = ::Const.SkillOrder.OffensiveTargeted;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsTargetingActor = false;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = 8;
		this.m.FatigueCost = 30;
		this.m.MinRange = 1;
		this.m.MaxRange = 4;
	}

	function getTooltip() {
		local ret = this.getDefaultTooltip();
		ret.push({
			id = 10, type = "text", icon = "ui/icons/damage_dealt.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]35-65[/color] holy damage to all enemies in a 2-tile radius."
		});
		ret.push({
			id = 11, type = "text", icon = "ui/icons/special.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+50%[/color] damage against undead, beasts, and monstrous enemies."
		});
		ret.push({
			id = 12, type = "text", icon = "ui/icons/special.png",
			text = "Ignores armor."
		});
		ret.push({
			id = 13, type = "text", icon = "ui/icons/special.png",
			text = "Cooldown: " + this.m.CooldownMax + " turns (" + ::Math.max(0, this.m.Cooldown) + " remaining)."
		});
		return ret;
	}

	function isUsable() {
		if (!this.skill.isUsable()) return false;
		if (this.m.Cooldown > 0) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null) {
			if (actor.getActionPoints() < this.m.ActionPointCost) return false;
			if (actor.getFatigue() + this.m.FatigueCost > actor.getFatigueMax()) return false;
		}
		return true;
	}

	function onVerifyTarget(_originTile, _targetTile) {
		return true;
	}

	function onUse(_user, _targetTile) {
		local particles = ::Const.Tactical.HolyFlameParticles;
		if (particles.len() > 0) {
			local p = particles[0];
			::Tactical.spawnParticleEffect(
				false, p.Brushes, _targetTile,
				p.Delay,
				::Math.max(1, p.Quantity * 0.5),
				::Math.max(1, p.LifeTimeQuantity * 0.5),
				p.SpawnRate,
				p.Stages
			);
		}

		local targets = [];
		if (_targetTile.IsOccupiedByActor) targets.push(_targetTile.getEntity());
		for (local i = 0; i < 6; i++) {
			if (!_targetTile.hasNextTile(i)) continue;
			local t1 = _targetTile.getNextTile(i);
			if (t1.IsOccupiedByActor) targets.push(t1.getEntity());
			for (local j = 0; j < 6; j++) {
				if (!t1.hasNextTile(j)) continue;
				local t2 = t1.getNextTile(j);
				if (t2.ID == _targetTile.ID) continue;
				if (t2.IsOccupiedByActor) {
					local e = t2.getEntity();
					if (targets.find(e) == null) targets.push(e);
				}
			}
		}

		foreach (enemy in targets) {
			if (_user.isAlliedWith(enemy)) continue;
			local dmg = ::Math.rand(35, 65);
			local flags = enemy.getFlags();
			if (flags.has("undead") || flags.has("beast") || flags.has("monstrous")) {
				dmg = ::Math.floor(dmg * 1.5);
			}
			local hitInfo = clone ::Const.Tactical.HitInfo;
			hitInfo.DamageRegular = dmg;
			hitInfo.DamageDirect = 1.0;
			hitInfo.BodyPart = ::Const.BodyPart.Body;
			hitInfo.BodyDamageMult = 1.0;
			hitInfo.FatalityChanceMult = 1.0;
			enemy.onDamageReceived(_user, this, hitInfo);
			if (!_user.isHiddenToPlayer()) {
				::Tactical.EventLog.log("[color=#FFD700]Pillar of Light[/color] scorches " + ::Const.UI.getColorizedEntityName(enemy) + " for [color=" + ::Const.UI.Color.NegativeValue + "]" + dmg + "[/color] damage.");
			}
		}

		this.m.Cooldown = this.m.CooldownMax + 1;
		return true;
	}

	function onTurnStart() {
		if (this.m.Cooldown > 0) this.m.Cooldown -= 1;
	}

	function onCombatFinished() {
		this.m.Cooldown = 0;
	}

	function onSerialize(_out) {
		this.skill.onSerialize(_out);
		_out.writeI32(this.m.Cooldown);
	}

	function onDeserialize(_in) {
		this.skill.onDeserialize(_in);
		this.m.Cooldown = _in.readI32();
	}
});
