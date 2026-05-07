this.golden_emperor_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {
		HasTriggeredResurrection = false,
		LastMilestoneCredited = 12,
		LastPowerUnlockLevel = 0,
		PurgeCount = 0,
		PurgeMilestonesHit = 0
	},

	function create() {
		character_trait.create();
		m.ID = "trait.golden_emperor";
		m.Name = "Undying Sovereign";
		m.Icon = "ui/perks/gt_golden_emperor.png";
		m.Description = "An ancient power stirs within. This warrior has cheated death before — and may do so once more. But the second death is final.";
		m.Titles = ["the Undying", "the Golden", "the Sovereign"];
		m.Type = m.Type | ::Const.SkillType.Trait;
	}

	function getTooltip() {
		local resUsed = ::World != null && ::World.Flags.get("GoldenEmperorResurrected");
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.m.Description },
			{ id = 11, type = "text", icon = "ui/icons/special.png",
				text = resUsed
					? "[color=" + ::Const.UI.Color.NegativeValue + "]Resurrection expended. The Emperor falls for good next time.[/color]"
					: "[color=" + ::Const.UI.Color.PositiveValue + "]Resurrection available. The Emperor will rise once from a mortal wound.[/color]"
			},
			{ id = 12, type = "text", icon = "ui/icons/special.png",
				text = "Cannot be raised as undead under any circumstances."
			}
		];

		local level = this.getContainer() != null && !::MSU.isNull(this.getContainer().getActor())
			? this.getContainer().getActor().getLevel() : 0;
		ret.push({
			id = 20, type = "text", icon = "ui/icons/leveled_up.png",
			text = "[color=#FFD700]Personal Powers[/color]: "
				+ (level >= 5  ? "[color=" + ::Const.UI.Color.PositiveValue + "]Pillar of Light[/color]"    : "Pillar of Light (lv 5)") + ", "
				+ (level >= 10 ? "[color=" + ::Const.UI.Color.PositiveValue + "]Golden Command[/color]"     : "Golden Command (lv 10)") + ", "
				+ (level >= 15 ? "[color=" + ::Const.UI.Color.PositiveValue + "]Radiant Judgement[/color]"  : "Radiant Judgement (lv 15)") + ", "
				+ (level >= 20 ? "[color=" + ::Const.UI.Color.PositiveValue + "]Dawn's Rebirth[/color]"     : "Dawn's Rebirth (lv 20)") + ", "
				+ (level >= 35 ? "[color=" + ::Const.UI.Color.PositiveValue + "]Ascended Sovereign[/color]" : "Ascended Sovereign (lv 35)")
		});

		local tier = this.m.PurgeMilestonesHit;
		// v2.13.0 — thresholds pulled from MSU settings.
		local thresh = ::GoldenThrone.purgeThresholds();
		thresh.push(9999);  // sentinel for tier 4 "no next"
		local next = thresh[tier];
		ret.push({
			id = 21, type = "text", icon = "ui/icons/kills.png",
			text = "[color=#FFD700]Purge Meter[/color]: "
				+ this.m.PurgeCount + " unholy kills"
				+ (tier < 4 ? " — next milestone at " + next : " — final milestone reached")
		});
		if (tier >= 1) ret.push({ id = 22, type = "text", icon = "ui/icons/vision.png",
			text = "[color=#FFD700]I — Farseer[/color]: hidden enemies in aura are revealed." });
		if (tier >= 2) ret.push({ id = 23, type = "text", icon = "ui/icons/special.png",
			text = "[color=#FFD700]II — Frozen Consecration[/color]: Emperor's Consecration also chills the target." });
		if (tier >= 3) ret.push({ id = 24, type = "text", icon = "ui/icons/health.png",
			text = "[color=#FFD700]III — Martyr's Light[/color]: Emperor heals for ally's level when an ally dies within the aura." });
		if (tier >= 4) ret.push({ id = 25, type = "text", icon = "ui/icons/special.png",
			text = "[color=#FFD700]IV — Expanded Presence[/color]: Imperial Presence aura radius +1 permanently." });

		return ret;
	}

	function onUpdate(_properties) {
		_properties.SurvivesAsUndead = false;

		local container = this.getContainer();
		if (container == null) return;
		local actor = container.getActor();
		if (actor == null) return;

		// v2.14.5 — self-heal for saves where the aura got dropped (3M
		// scenario flow with the old `if (m.IsNew)` gate sometimes spawned
		// the Emperor without it). If the trait exists but the aura skill
		// is missing, re-add it on the next property recalc. Idempotent.
		if (container.getSkillByID("actives.golden_emperor_aura") == null) {
			try {
				container.add(::new("scripts/skills/aura/golden_emperor_aura"));
				::logInfo("[golden_throne] self-heal: re-added Imperial Presence aura to " + actor.getName());
			} catch (e) { ::logWarning("[golden_throne] aura self-heal failed: " + e); }
		}

		local level = actor.getLevel();

		if (level >= 15 && (level - 12) % 3 == 0 && level > this.m.LastMilestoneCredited) {
			actor.m.PerkPoints += 1;
			this.m.LastMilestoneCredited = level;
			if (!actor.isHiddenToPlayer() && ::Tactical.isActive()) {
				::Tactical.EventLog.log("[color=#FFD700]" + ::Const.UI.getColorizedEntityName(actor) + " claims another perk from his veteran reign.[/color]");
			}
		}

		// v2.14.11: call unconditionally — _unlockLevelPowers is hasSkill-guarded
		// and idempotent. Self-heals existing saves where the L20 grant was the
		// pre-swap Solar Ascension, by adding any missing skills next tick.
		this._unlockLevelPowers(actor, level);

		if (level > this.m.LastPowerUnlockLevel) {
			this.m.LastPowerUnlockLevel = level;
			this.onApplyAppearance();
		}
	}

	function onCombatStarted() {
		this.onApplyAppearance();
	}

	function onAdded() {
		this.onApplyAppearance();
	}

	function onApplyAppearance() {
		local container = this.getContainer();
		if (container == null) return;
		local actor = container.getActor();
		if (actor == null) return;
		this._setEmperorGrowthScale(actor);
		try { actor.setDirty(true); } catch (e) {}
	}

	function _setEmperorGrowthScale(_actor) {
		// Linear scale ramp from 1.00 at level 0 to 1.35 at level 20.
		// Capped at 1.35 thereafter — chosen as the sweet spot where the
		// silhouette reads bigger but BB's pixel-art atlases don't get
		// visibly chunky from upscaling. Higher caps (1.45-1.65) showed
		// pixel-blockiness on the layered armor stack. 2026-04-28 final.
		local lvl = ::Math.min(_actor.getLevel(), 20);
		local mult = 1.0 + (lvl / 20.0) * 0.35;
		local parts = [
			"body", "head", "armor", "surcoat",
			"armor_layer_chain", "armor_layer_plate", "armor_layer_tabbard",
			"armor_layer_cloak", "armor_layer_cloak_front",
			"armor_upgrade_back", "armor_upgrade_back_top", "armor_upgrade_front",
			"helmet",
			"helmet_helm", "helmet_helm_lower", "helmet_top", "helmet_top_lower",
			"helmet_vanity", "helmet_vanity_2", "helmet_vanity_lower",
			"hair", "beard", "beard_top",
			"tattoo_body", "tattoo_head",
			"injury", "injury_body",
			"accessory", "accessory_special",
			"quiver", "shaft"
		];
		foreach (part in parts) {
			try {
				if (_actor.hasSprite(part)) _actor.getSprite(part).Scale = mult;
			} catch (e) {}
		}
	}

	function _unlockLevelPowers(_actor, _level) {
		local granted = [];
		if (_level >= 5 && !_actor.getSkills().hasSkill("actives.pillar_of_light")) {
			_actor.getSkills().add(::new("scripts/skills/actives/pillar_of_light_skill"));
			granted.push("Pillar of Light");
		}
		if (_level >= 10 && !_actor.getSkills().hasSkill("actives.golden_command")) {
			_actor.getSkills().add(::new("scripts/skills/actives/golden_command_skill"));
			granted.push("Golden Command");
		}
		if (_level >= 15 && !_actor.getSkills().hasSkill("actives.radiant_judgement")) {
			_actor.getSkills().add(::new("scripts/skills/actives/radiant_judgement_skill"));
			granted.push("Radiant Judgement");
		}
		if (_level >= 20 && !_actor.getSkills().hasSkill("actives.dawns_rebirth")) {
			_actor.getSkills().add(::new("scripts/skills/actives/dawns_rebirth_skill"));
			granted.push("Dawn's Rebirth");
		}
		if (_level >= 35 && !_actor.getSkills().hasSkill("trait.ascended_sovereign")) {
			_actor.getSkills().add(::new("scripts/skills/traits/ascended_sovereign_trait"));
			granted.push("Ascended Sovereign");
		}
		if (granted.len() > 0 && !_actor.isHiddenToPlayer() && ::Tactical.isActive()) {
			local list = granted[0];
			for (local i = 1; i < granted.len(); i++) {
				list = list + ", " + granted[i];
			}
			::Tactical.EventLog.log("[color=#FFD700]The Emperor's reign unfolds — " + ::Const.UI.getColorizedEntityName(_actor) + " gains: " + list + ".[/color]");
		}
	}

	function onTurnStart() {
		local actor = this.getContainer().getActor();
		if (!actor.isAlive()) return;

		local injuries = actor.getSkills().query(::Const.SkillType.Injury | ::Const.SkillType.SemiInjury);
		if (!::World.Flags.get("GoldenEmperorResurrected") && injuries.len() > 0 && !this.m.HasTriggeredResurrection) {
			this.m.HasTriggeredResurrection = true;
			::World.Flags.set("GoldenEmperorResurrected", true);
			if (!actor.isHiddenToPlayer()) {
				::Tactical.EventLog.log("[color=#FFD700]" + ::Const.UI.getColorizedEntityName(actor) + " blazes with undying light — death recoils! The resurrection is spent.[/color]");
				this.spawnIcon("active_128", actor.getTile());
			}
		}
	}

	function onTargetKilled(_targetEntity, _skill) {
		if (_targetEntity == null) return;
		local actor = this.getContainer().getActor();
		if (actor == null || actor.isAlliedWith(_targetEntity)) return;

		local flags = _targetEntity.getFlags();
		if (!(flags.has("undead") || flags.has("beast") || flags.has("monstrous"))) return;

		// v2.11.3: Purge Count moves to StackLib. Lib handles tier-callback
		// dispatch automatically via its OnTier registration. Legacy fallback
		// when lib absent: replicate the hand-rolled tier-advance dispatch.
		if ("StackLib" in ::getroottable()) {
			try { ::StackLib.add(actor, "goldenthrone.purge", 1); return; } catch (e) {}
		}
		this.m.PurgeCount += 1;
		local newTier = this._computePurgeTier();
		if (newTier > this.m.PurgeMilestonesHit) {
			this.m.PurgeMilestonesHit = newTier;
			this._announcePurgeMilestone(newTier, actor);
			if (newTier >= 4 && ::World != null) {
				local bonus = ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
				::World.Flags.set("GoldenEmperorAuraBonus", bonus + 1);
			}
		}
	}

	function _computePurgeTier() {
		// v2.13.0 — thresholds pulled from MSU settings.
		local t = ::GoldenThrone.purgeThresholds();
		if (this.m.PurgeCount >= t[3]) return 4;
		if (this.m.PurgeCount >= t[2]) return 3;
		if (this.m.PurgeCount >= t[1]) return 2;
		if (this.m.PurgeCount >= t[0]) return 1;
		return 0;
	}

	function _announcePurgeMilestone(_tier, _actor) {
		if (_actor.isHiddenToPlayer() || !::Tactical.isActive()) return;
		local text;
		switch (_tier) {
			case 1: text = "Farseer — hidden things cannot hide from the Emperor's gaze."; break;
			case 2: text = "Frozen Consecration — the Emperor's holy fire bites with winter's cold."; break;
			case 3: text = "Martyr's Light — the blood of fallen allies feeds the Emperor's strength."; break;
			case 4: text = "Expanded Presence — the Emperor's light reaches further than before."; break;
			default: return;
		}
		::Tactical.EventLog.log("[color=#FFD700]Purge Meter milestone " + _tier + ": " + text + "[/color]");
	}

	function getPurgeTier() {
		// v2.11.3: lib is source of truth when loaded. Legacy fallback otherwise.
		local actor = this.getContainer().getActor();
		if (actor != null && "StackLib" in ::getroottable()) {
			try { return ::StackLib.getTier(actor, "goldenthrone.purge"); } catch (e) {}
		}
		return this.m.PurgeMilestonesHit;
	}

	function onAllyKilled(_ally) {
		if (this.getPurgeTier() < 3) return;
		if (_ally == null) return;

		local actor = this.getContainer().getActor();
		if (actor == null || !actor.isAlive()) return;
		if (!actor.isPlacedOnMap() || !_ally.isPlacedOnMap()) return;

		local range = 10;
		if (::World != null) range += ::World.Flags.getAsInt("GoldenEmperorAuraBonus");
		if (actor.getTile().getDistanceTo(_ally.getTile()) > range) return;

		local heal = _ally.getLevel();
		if (heal <= 0) return;
		actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + heal));

		if (!actor.isHiddenToPlayer()) {
			::Tactical.EventLog.log("[color=#FFD700]Martyr's Light — the Emperor draws " + heal + " HP from the fallen.[/color]");
		}
	}

	function onSerialize(_out) {
		character_trait.onSerialize(_out);
		_out.writeBool(this.m.HasTriggeredResurrection);
		_out.writeI32(this.m.LastMilestoneCredited);
		_out.writeI32(this.m.LastPowerUnlockLevel);
		_out.writeI32(this.m.PurgeCount);
		_out.writeI32(this.m.PurgeMilestonesHit);
	}

	function onDeserialize(_in) {
		character_trait.onDeserialize(_in);
		this.m.HasTriggeredResurrection = _in.readBool();
		this.m.LastMilestoneCredited = _in.readI32();
		this.m.LastPowerUnlockLevel = _in.readI32();
		this.m.PurgeCount = _in.readI32();
		this.m.PurgeMilestonesHit = _in.readI32();
	}
});
