this.radiant_judgement_skill <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown = 0,
		CooldownMax = 2
	},

	function create() {
		this.m.ID = "actives.radiant_judgement";
		this.m.Name = "Radiant Judgement";
		this.m.Description = "A verdict delivered in gold. The Emperor's gaze marks the target, and holy fire answers — piercing steel, scouring flesh, unmaking the unclean.";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.IconDisabled = "ui/perks/holyfire_circle.png";
		this.m.Overlay = "active_128";
		this.m.SoundOnUse = ["sounds/combat/pov_holy_fire_03.wav"];
		this.m.SoundVolume = 1.5;
		this.m.Type = ::Const.SkillType.Active;
		this.m.Order = ::Const.SkillOrder.OffensiveTargeted;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsTargetingActor = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 25;
		this.m.MinRange = 1;
		this.m.MaxRange = 5;
	}

	function getTooltip() {
		local ret = this.getDefaultTooltip();
		ret.push({
			id = 10, type = "text", icon = "ui/icons/damage_dealt.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]60-110[/color] holy damage."
		});
		ret.push({
			id = 11, type = "text", icon = "ui/icons/special.png",
			text = "Ignores armor entirely."
		});
		ret.push({
			id = 12, type = "text", icon = "ui/icons/special.png",
			text = "Deals [color=" + ::Const.UI.Color.PositiveValue + "]double damage[/color] against undead, beasts, or monstrous targets."
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
		if (!_targetTile.IsOccupiedByActor) return false;
		local user = this.getContainer().getActor();
		return !user.isAlliedWith(_targetTile.getEntity());
	}

	function onUse(_user, _targetTile) {
		if (!_targetTile.IsOccupiedByActor) return false;
		local target = _targetTile.getEntity();

		local particles = ::Const.Tactical.HolyFlameParticles;
		for (local i = 0; i < particles.len(); i++) {
			::Tactical.spawnParticleEffect(
				false, particles[i].Brushes, _targetTile,
				particles[i].Delay, particles[i].Quantity,
				particles[i].LifeTimeQuantity, particles[i].SpawnRate,
				particles[i].Stages
			);
		}

		local dmg = ::Math.rand(60, 110);
		local flags = target.getFlags();
		if (flags.has("undead") || flags.has("beast") || flags.has("monstrous")) {
			dmg *= 2;
		}
		local hitInfo = clone ::Const.Tactical.HitInfo;
		hitInfo.DamageRegular = dmg;
		hitInfo.DamageDirect = 1.0;
		hitInfo.BodyPart = ::Const.BodyPart.Body;
		hitInfo.BodyDamageMult = 1.0;
		hitInfo.FatalityChanceMult = 1.0;
		target.onDamageReceived(_user, this, hitInfo);

		if (!_user.isHiddenToPlayer()) {
			::Tactical.EventLog.log("[color=#FFD700]Radiant Judgement[/color] strikes " + ::Const.UI.getColorizedEntityName(target) + " for [color=" + ::Const.UI.Color.NegativeValue + "]" + dmg + "[/color] holy damage.");
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
