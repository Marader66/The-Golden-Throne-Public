this.golden_command_skill <- this.inherit("scripts/skills/skill", {
	m = {
		UsedThisBattle = false
	},

	function create() {
		this.m.ID = "actives.golden_command";
		this.m.Name = "Golden Command";
		this.m.Description = "The Emperor barks a word of divine authority. The chosen ally snaps to attention, ready to act anew.";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.IconDisabled = "ui/perks/holyfire_circle.png";
		this.m.Overlay = "active_128";
		this.m.SoundOnUse = ["sounds/combat/pov_holy_fire_02.wav"];
		this.m.SoundVolume = 1.5;
		this.m.Type = ::Const.SkillType.Active;
		this.m.Order = ::Const.SkillOrder.UtilityTargeted;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsTargetingActor = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 3;
	}

	function getTooltip() {
		local ret = this.getDefaultTooltip();
		ret.push({
			id = 10, type = "text", icon = "ui/icons/action_points.png",
			text = "Refreshes target ally's [color=" + ::Const.UI.Color.PositiveValue + "]Action Points[/color] to full."
		});
		ret.push({
			id = 11, type = "text", icon = "ui/icons/fatigue.png",
			text = "Restores [color=" + ::Const.UI.Color.PositiveValue + "]50[/color] Fatigue to the ally."
		});
		ret.push({
			id = 12, type = "text", icon = "ui/icons/special.png",
			text = this.m.UsedThisBattle
				? "[color=" + ::Const.UI.Color.NegativeValue + "]Already spoken this battle.[/color]"
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

	function onVerifyTarget(_originTile, _targetTile) {
		if (!_targetTile.IsOccupiedByActor) return false;
		local target = _targetTile.getEntity();
		local user = this.getContainer().getActor();
		if (target.getID() == user.getID()) return false;
		return user.isAlliedWith(target);
	}

	function onUse(_user, _targetTile) {
		if (!_targetTile.IsOccupiedByActor) return false;
		local ally = _targetTile.getEntity();
		if (!_user.isAlliedWith(ally) || ally.getID() == _user.getID()) return false;

		ally.setActionPoints(ally.getActionPointsMax());
		ally.setFatigue(::Math.max(0, ally.getFatigue() - 50));

		local particles = ::Const.Tactical.HolyFlameParticles;
		for (local i = 0; i < particles.len(); i++) {
			::Tactical.spawnParticleEffect(
				false, particles[i].Brushes, ally.getTile(),
				particles[i].Delay, particles[i].Quantity,
				particles[i].LifeTimeQuantity, particles[i].SpawnRate,
				particles[i].Stages
			);
		}

		this.m.UsedThisBattle = true;

		if (!_user.isHiddenToPlayer()) {
			::Tactical.EventLog.log("[color=#FFD700]The Emperor commands — " + ::Const.UI.getColorizedEntityName(ally) + " stands ready.[/color]");
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
