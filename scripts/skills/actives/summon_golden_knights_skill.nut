this.summon_golden_knights_skill <- this.inherit("scripts/skills/skill", {
	m = {
		UsedThisCombat = false
	},

	function create() {
		this.m.ID = "actives.summon_golden_knights";
		this.m.Name = "Summon Knights";
		this.m.Description = "The Emperor raises his sword and calls upon the divine compact. Two golden knights materialise from light itself, each bearing a different blessing of battle.";
		this.m.Icon = "skills/active_128.png";
		this.m.IconDisabled = "skills/active_128.png";
		this.m.Overlay = "active_128";
		this.m.SoundOnUse = [
			"sounds/combat/pov_holy_fire_02.wav",
			"sounds/combat/pov_holy_fire_03.wav"
		];
		this.m.SoundVolume = 1.5;
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted + 5;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsTargetingActor = false;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 40;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
	}

	function getTooltip() {
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 3, type = "text", text = this.getCostString() },
			{
				id = 10, type = "text",
				icon = "ui/icons/special.png",
				text = "Spawns [color=" + ::Const.UI.Color.PositiveValue + "]2 Golden Knights[/color] at the target tile, each with a random martial blessing."
			},
			{
				id = 11, type = "text",
				icon = "ui/icons/special.png",
				text = "Possible blessings: [color=" + ::Const.UI.Color.PositiveValue + "]Ironclad, Wrath, Stalwart, Zealous, Swift, Sovereign[/color]"
			}
		];
		ret.push({
			id = 12,
			type = "text",
			icon = "ui/icons/special.png",
			text = "[color=" + ::Const.UI.Color.NegativeValue + "]Once per battle.[/color]"
		});
		if (this.m.UsedThisCombat) {
			ret.push({
				id = 13,
				type = "text",
				icon = "ui/tooltips/warning.png",
				text = "[color=" + ::Const.UI.Color.NegativeValue + "]Already summoned this battle.[/color]"
			});
		}
		return ret;
	}

	function isUsable() {
		if (this.m.UsedThisCombat) return false;
		if (!this.skill.isUsable()) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null) {
			if (actor.getActionPoints() < this.m.ActionPointCost) return false;
			if (actor.getFatigue() + this.m.FatigueCost > actor.getFatigueMax()) return false;
		}
		return true;
	}

	function onCombatStarted() {
		this.m.UsedThisCombat = false;
		this.skill.onCombatStarted();
	}

	function onCombatFinished() {
		this.m.UsedThisCombat = false;
		this.skill.onCombatFinished();
	}

	function onVerifyTarget(_originTile, _targetTile) {
		return this.skill.onVerifyTarget(_originTile, _targetTile) && _targetTile.IsEmpty;
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

		local spawnTiles = [];
		spawnTiles.push(_targetTile);

		for (local i = 0; i < 6; i++) {
			if (!_targetTile.hasNextTile(i)) continue;
			local n = _targetTile.getNextTile(i);
			if (n.IsEmpty && !n.IsOccupiedByActor) {
				spawnTiles.push(n);
				break;
			}
		}

		local mutations = [];
		local picked = {};
		while (mutations.len() < spawnTiles.len()) {
			local roll = this.Math.rand(0, 5);
			if (roll in picked) continue;
			picked[roll] <- true;
			mutations.push(roll);
		}

		for (local i = 0; i < spawnTiles.len(); i++) {
			local tile = spawnTiles[i];
			local entity = ::Tactical.spawnEntity(
				"scripts/entity/tactical/player/golden_knight_ally",
				tile.Coords.X,
				tile.Coords.Y
			);
			entity.setFaction(::Const.Faction.PlayerAnimals);
			entity.applyMutation(mutations[i]);
			entity.riseFromGround(0.75);

			if (!_user.isHiddenToPlayer()) {
				::Tactical.EventLog.log("[color=#FFD700]A Golden Knight rises — " + entity.getName() + "![/color]");
			}
		}

		if (spawnTiles.len() == 1 && !_user.isHiddenToPlayer()) {
			::Tactical.EventLog.log("[color=#FFD700]Only one knight could manifest — the target had no room for a second.[/color]");
		}

		this.m.UsedThisCombat = true;
		return true;
	}

	function onSerialize(_out) {
		this.skill.onSerialize(_out);
		_out.writeBool(this.m.UsedThisCombat);
	}

	function onDeserialize(_in) {
		this.skill.onDeserialize(_in);
		this.m.UsedThisCombat = _in.readBool();
	}
});
