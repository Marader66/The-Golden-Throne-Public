this.pillar_of_light_skill <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown = 0,
		CooldownMax = 3
	},

	function create() {
		this.m.ID = "actives.pillar_of_light";
		this.m.Name = "Pillar of Light";
		this.m.Description = "A shaft of divine fire descends on the target, scorching the ground around it. Undead, beasts, and monstrous creatures burn hotter.";
		this.m.Icon = "ui/perks/holyfire_square.png";
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
		local pos = ::Const.UI.Color.PositiveValue;
		local neg = ::Const.UI.Color.NegativeValue;

		ret.push({ id = 10, type = "text", icon = "ui/icons/damage_dealt.png",
			text = "[color=" + pos + "]35–65[/color] holy fire damage to every enemy in a [color=" + pos + "]2-tile radius[/color] of the target." });
		ret.push({ id = 11, type = "text", icon = "ui/icons/special.png",
			text = "[color=" + pos + "]+50%[/color] damage vs. [color=" + pos + "]undead[/color], [color=" + pos + "]beasts[/color], and [color=" + pos + "]monstrous[/color] enemies." });
		ret.push({ id = 12, type = "text", icon = "ui/icons/special.png",
			text = "Damage type: [color=" + pos + "]Burning[/color] — half lands on armor, half on health. Ignores Cutting/Piercing resistance." });
		ret.push({ id = 13, type = "text", icon = "ui/icons/special.png",
			text = (this.m.Cooldown <= 0)
				? "[color=" + pos + "]Ready[/color] — " + this.m.CooldownMax + "-turn cooldown after use."
				: "[color=" + neg + "]Cooldown: " + this.m.Cooldown + " turn(s) remaining[/color]." });
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
		// v2.9.5 (C): particle quantity reduced from 50% to 25% of vanilla
		// HolyFlameParticles[0] for AoE perf. Visual is still recognizable
		// as a holy-flame burst, just briefer.
		local particles = ::Const.Tactical.HolyFlameParticles;
		if (particles.len() > 0) {
			local p = particles[0];
			::Tactical.spawnParticleEffect(
				false, p.Brushes, _targetTile,
				p.Delay,
				::Math.max(1, p.Quantity * 0.25),
				::Math.max(1, p.LifeTimeQuantity * 0.25),
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

		// v2.9.5 (B): aggregate per-target log lines into a single summary
		// when more than 3 targets are hit. 1-3 targets keep individual
		// lore-friendly lines; 4+ collapse to one summary line to reduce
		// UI scroll churn. Same buckets used for the warning dedupe (D).
		local hitNames = [];
		local totalDamage = 0;
		local hookThrowFired = false; // (D) one warning per cast, not per entity

		foreach (enemy in targets) {
			if (_user.isAlliedWith(enemy)) continue;
			local dmg = ::Math.rand(35, 65);
			local flags = enemy.getFlags();
			if (flags.has("undead") || flags.has("beast") || flags.has("monstrous")) {
				dmg = ::Math.floor(dmg * 1.5);
			}
			local hitInfo = clone ::Const.Tactical.HitInfo;
			hitInfo.DamageRegular = dmg;
			hitInfo.DamageDirect = 0.5;
			hitInfo.DamageType = ::Const.Damage.DamageType.Burning;  // v2.14.0 — holy fire counts as Burning
			hitInfo.BodyPart = ::Const.BodyPart.Body;
			hitInfo.BodyDamageMult = 1.0;
			hitInfo.FatalityChanceMult = 1.0;
			// v2.9.2 / v2.9.5 (D): wrap onDamageReceived in try/catch.
			// Third-party onDamageReceived hooks (Floating Combat Text mods,
			// etc.) can throw on dying entities mid-removal during AoE
			// chains. Damage was already applied; the throw is downstream
			// hook noise. v2.9.5 collapses the per-entity logWarning into
			// a single per-cast warning to avoid disk-sync chunking when
			// 6+ AoE targets all throw the same hook.
			try {
				enemy.onDamageReceived(_user, this, hitInfo);
			} catch (e) {
				if (!hookThrowFired) {
					::logWarning("[Pillar of Light] downstream onDamageReceived hook threw (suppressing further cast warnings): " + e);
					hookThrowFired = true;
				}
			}

			hitNames.push(::Const.UI.getColorizedEntityName(enemy));
			totalDamage += dmg;
		}

		// v2.9.5 (A/B): single summary for 4+ hits, individual lines for 1-3.
		if (!_user.isHiddenToPlayer() && hitNames.len() > 0) {
			if (hitNames.len() >= 4) {
				::Tactical.EventLog.log("[color=#FFD700]Pillar of Light[/color] scorches " + hitNames.len() + " enemies for [color=" + ::Const.UI.Color.NegativeValue + "]" + totalDamage + "[/color] total damage.");
			} else {
				for (local i = 0; i < hitNames.len(); i++) {
					::Tactical.EventLog.log("[color=#FFD700]Pillar of Light[/color] scorches " + hitNames[i] + ".");
				}
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
