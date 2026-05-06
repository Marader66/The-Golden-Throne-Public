// golden_brand — Holy Wrath + Martyr's Fury + Sacred Smite for the Brand bearer.
//
// v2.11.3: Wrath stacks moved to Stack Skills lib (::StackLib). Stack id is
// "goldenthrone.holywrath" registered in mod_golden_throne.nut. Lib handles
// the cap (max 5), the reset on combatStart/combatEnd, and storage. This
// file just calls ::StackLib.add/get/consume.
//
// Soft-fallback: if StackLib isn't loaded, the helper functions degrade to
// hand-rolled m.WrathStacks state (preserves behavior on installs that
// dropped the lib).

this.golden_brand <- ::inherit("scripts/skills/skill", {
	m = {
		// Legacy field — kept for save-compat fallback when StackLib absent.
		// Real source of truth in v2.11.3+ is ::StackLib.
		WrathStacks = 0,
		WrathStacksMax = 5,
		SoundWrath = ["sounds/combat/pov_holy_fire_01.wav"]
	},

	function create() {
		this.m.ID = "special.golden_brand";
		this.m.Name = "The Golden Brand";
		this.m.Icon = "ui/perks/fire_circle.png";
		this.m.IconMini = "status_effect_01_mini";
		this.m.Type = ::Const.SkillType.Special | ::Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsSerialized = true;
	}

	function getDescription() {
		return "The Emperor's mark burns in this brother's chest. It does not heal him — it enrages him. Every wound feeds the fire. Every fallen comrade feeds it further. The Brand demands one thing in return for its gifts: that the bearer strike back harder than he was struck.";
	}

	// ── Internal: read/write/consume Wrath, with StackLib-or-legacy fallback ──

	function getWrath() {
		local actor = this.getContainer().getActor();
		if (actor == null) return this.m.WrathStacks;
		if ("StackLib" in ::getroottable()) {
			try { return ::StackLib.get(actor, "goldenthrone.holywrath"); } catch (e) {}
		}
		return this.m.WrathStacks;
	}

	function addWrath(_n) {
		local actor = this.getContainer().getActor();
		if (actor == null) return this.m.WrathStacks;
		if ("StackLib" in ::getroottable()) {
			try { return ::StackLib.add(actor, "goldenthrone.holywrath", _n); } catch (e) {}
		}
		// Legacy fallback — same logic as pre-2.11.3
		this.m.WrathStacks = ::Math.min(this.m.WrathStacksMax, this.m.WrathStacks + _n);
		return this.m.WrathStacks;
	}

	function consumeWrath() {
		local actor = this.getContainer().getActor();
		if (actor == null) return this.m.WrathStacks;
		if ("StackLib" in ::getroottable()) {
			try { return ::StackLib.consume(actor, "goldenthrone.holywrath"); } catch (e) {}
		}
		local prev = this.m.WrathStacks;
		this.m.WrathStacks = 0;
		return prev;
	}

	function getTooltip() {
		local wrath = this.getWrath();
		return [
			{ id=1, type="title", text = this.getName() },
			{ id=2, type="description", text = this.getDescription() },
			{ id=3, type="text", icon="ui/icons/health.png",
				text = "[color=#FFD700]+30%[/color] Hitpoints" },
			{ id=4, type="text", icon="ui/icons/fatigue.png",
				text = "All skills cost [color=#FFD700]20%[/color] less fatigue" },
			{ id=5, type="text", icon="ui/icons/melee_defense.png",
				text = "[color=#FFD700]+10[/color] Melee Defense vs adjacent attackers" },
			{ id=6, type="text", icon="ui/icons/special.png",
				text = "[color=#FFD700]Holy Wrath:[/color] Taking damage builds Wrath stacks (max "
					+ this.m.WrathStacksMax + "). Each stack adds [color=#FFD700]+3[/color] Melee Skill "
					+ "and [color=#FFD700]+3%[/color] damage to the next attack, then resets. "
					+ "Current stacks: [color=#FFD700]" + wrath + "[/color]." },
			{ id=7, type="text", icon="ui/icons/special.png",
				text = "[color=#FFD700]Martyr's Fury:[/color] When a friendly ally within 5 tiles is killed, "
					+ "instantly gain [color=#FFD700]3[/color] Wrath stacks." },
			{ id=8, type="text", icon="ui/icons/special.png",
				text = "[color=#FFD700]Sacred Smite:[/color] Every melee hit applies Consecration "
					+ "(8-20 holy damage/turn, 3 turns). Two-handed weapons: 15-30." },
			{ id=9, type="text", icon="ui/icons/asset_money.png",
				text = "No longer receives wages" },
		];
	}

	function onUpdate(_properties) {
		_properties.HitpointsMult *= 1.3;
		_properties.FatigueEffectMult *= 0.8;

		local wrath = this.getWrath();
		if (wrath > 0) {
			_properties.MeleeSkill += wrath * 3;
			_properties.DamageTotalMult *= 1.0 + (wrath * 0.03);
		}

		this.updateVisuals();
	}

	function onAfterUpdate(_properties) {
		_properties.DailyWageMult = 0.0;
	}

	function onBeingAttacked(_attacker, _skill, _properties) {
		local actor = this.getContainer().getActor();
		if (::MSU.isNull(actor) || ::MSU.isNull(_attacker)) return;
		if (_attacker.getTile().getDistanceTo(actor.getTile()) <= 1) {
			_properties.MeleeDefense += 10;
		}
	}

	function onDamageReceived(_attacker, _damageHitpoints, _damageArmor) {
		if (_damageHitpoints <= 0 && _damageArmor <= 0) return;
		if (::MSU.isNull(_attacker)) return;
		if (this.getContainer().getActor().isAlliedWith(_attacker)) return;

		local prev = this.getWrath();
		local now  = this.addWrath(1);

		if (now > prev) {
			local actor = this.getContainer().getActor();
			if (!actor.isHiddenToPlayer()) {
				this.Tactical.EventLog.log("[color=#FFD700]" + this.Const.UI.getColorizedEntityName(actor) + " — Holy Wrath: " + now + "/" + this.m.WrathStacksMax + "[/color]");
			}
		}
	}

	function onAllyKilled(_ally) {
		if (::MSU.isNull(_ally)) return;
		local actor = this.getContainer().getActor();
		if (!actor.isPlacedOnMap() || !_ally.isPlacedOnMap()) return;
		if (actor.getTile().getDistanceTo(_ally.getTile()) > 5) return;

		local cur = this.getWrath();
		local gained = ::Math.min(this.m.WrathStacksMax - cur, 3);
		if (gained <= 0) return;

		local now = this.addWrath(gained);
		if (!actor.isHiddenToPlayer()) {
			if (this.m.SoundWrath.len() > 0) {
				this.Sound.play(this.m.SoundWrath[0], this.Const.Sound.Volume.RacialEffect, actor.getPos());
			}
			this.Tactical.EventLog.log("[color=#FFD700]" + this.Const.UI.getColorizedEntityName(actor) + " — Martyr's Fury ignites! Wrath: " + now + "/" + this.m.WrathStacksMax + "[/color]");
		}
	}

	function onTargetHit(_skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor) {
		if (::MSU.isNull(_targetEntity)) return;
		if (!_targetEntity.isAlive() || _targetEntity.isDying()) return;
		if (_damageInflictedHitpoints <= 0 && _damageInflictedArmor <= 0) return;

		local actor = this.getContainer().getActor();
		local wrath = this.getWrath();

		if (wrath > 0) {
			if (!actor.isHiddenToPlayer()) {
				this.Tactical.EventLog.log("[color=#FFD700]" + this.Const.UI.getColorizedEntityName(actor) + " releases Holy Wrath (" + wrath + " stacks)![/color]");
			}
			this.consumeWrath();
		}

		local weapon = actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		local is2H = (weapon != null && weapon.isItemType(::Const.Items.ItemType.TwoHanded));
		local dmgMin = is2H ? 15 : 8;
		local dmgMax = is2H ? 30 : 20;

		local effectID = ::Legends.Effects.getID(::Legends.Effect.LegendConsecratedEffect);
		local existing = _targetEntity.getSkills().getSkillByID(effectID);
		if (existing != null) {
			existing.m.TurnsLeft = ::Math.max(existing.m.TurnsLeft, 3);
			existing.m.DamageMin = ::Math.max(existing.m.DamageMin, dmgMin);
			existing.m.DamageMax = ::Math.max(existing.m.DamageMax, dmgMax);
		} else {
			local effect = ::new("scripts/skills/effects/legend_consecrated_effect");
			effect.setActor(actor);
			effect.m.TurnsLeft = 3;
			effect.m.DamageMin = dmgMin;
			effect.m.DamageMax = dmgMax;
			_targetEntity.getSkills().add(effect);
		}
	}

	function updateVisuals() {
		local actor = this.getContainer().getActor();
		if (::MSU.isNull(actor)) return;

		if (actor.hasSprite("quiver")) {
			local wings = actor.getSprite("quiver");
			wings.setBrush("bust_shadow_wings_big");
			wings.Color = this.createColor("#FFD700");
			wings.Saturation = 1.5;
			wings.Visible = true;
		}
		if (actor.hasSprite("permanent_injury_4") && !actor.getSkills().hasSkill("trait.golden_mandate")) {
			local eyes = actor.getSprite("permanent_injury_4");
			eyes.setBrush("undead_rage_eyes");
			eyes.Color = this.createColor("#FFD700");
			eyes.Saturation = 1.5;
			eyes.Visible = true;
			actor.setSpriteOffset("permanent_injury_4", this.createVec(0, -2.8));
		}
		actor.setDirty(true);
	}

	function onAdded() { this.updateVisuals(); }

	// v2.11.3: combat-start/finish reset is now handled by StackLib's combat_hooks.
	// We keep the legacy m.WrathStacks reset for fallback-mode installs.
	function onCombatStarted() { this.updateVisuals(); this.m.WrathStacks = 0; }
	function onCombatFinished() { this.m.WrathStacks = 0; }

	function onRemoved() {
		local actor = this.getContainer().getActor();
		if (actor.hasSprite("quiver")) actor.getSprite("quiver").resetBrush();
		if (actor.hasSprite("permanent_injury_4")) actor.getSprite("permanent_injury_4").resetBrush();
		actor.getItems().updateAppearance();
	}

	// Save-compat: keep the i32 slot for m.WrathStacks. Existing campaigns
	// have it serialized; removing it would break save reads. v2.12+ can
	// drop the slot once we cycle through enough campaigns.
	function onSerialize(_out) {
		this.skill.onSerialize(_out);
		_out.writeI32(this.m.WrathStacks);
	}

	function onDeserialize(_in) {
		this.skill.onDeserialize(_in);
		this.m.WrathStacks = _in.readI32();
	}
});
