// v2.14.0-alpha — D4 Phase A, Beat 4. The aftermath of the Original's death.
//
// Triggered after `GoldenPyramidComplete` is set (player won floor 5). Fires
// once. Does the heavy lifting:
//   - Terminates any live undead crisis (addGreaterEvilStrength(-9999))
//   - Sets `GoldenDeadCurseEnded` (the permanent flag — subsequent crises
//     should check this and refuse to spawn as Undead type)
//   - Removes Solar Ascension + Dawn's Rebirth from the Emperor
//   - Adds the Powers Spent passive marker
//   - Adds the Reclaimer trait
//   - Despawns wandering undead parties (cosmetic dramatic beat)
//   - Sets `GoldenPostFinaleScenariosUnlocked` for multi-protag unlock
//   - Offers the player End-Campaign or Continue (greenskin Phase B prep)
this.golden_pyramid_finale_event <- this.inherit("scripts/events/event", {
	m = {},

	function _findEmperor() {
		try {
			local roster = ::World.getPlayerRoster();
			if (roster == null) return null;
			foreach (b in roster.getAll()) {
				if (b == null || !b.isAlive()) continue;
				local flags = b.getFlags();
				if (flags != null && flags.has("GoldenEmperor")) return b;
			}
		} catch (e) {}
		return null;
	}

	function _consumePowersAndGrantReclaimer() {
		local emperor = this._findEmperor();
		if (emperor != null) {
			try {
				local skills = emperor.getSkills();
				// Remove the two ultimate miracles.
				skills.removeByID("actives.solar_ascension");
				skills.removeByID("actives.dawns_rebirth");
				// Add the Powers Spent informational passive.
				if (skills.getSkillByID("special.golden_powers_spent") == null) {
					skills.add(::new("scripts/skills/special/golden_powers_spent"));
				}
				// Add the Reclaimer identity trait.
				if (skills.getSkillByID("trait.golden_reclaimer") == null) {
					skills.add(::new("scripts/skills/traits/golden_reclaimer_trait"));
				}
			} catch (e) { ::logWarning("[gt finale] power consumption threw: " + e); }
			return;
		}

		// Emperor not alive. In Three Musketeers context the Maestro or
		// Cinderwarden may be the only surviving protag. Grant Reclaimer to
		// any surviving Mandate-bound brother as lawful inheritor of the
		// Emperor's mantle. Per the Davkul-only-resurrection rule, Davkul
		// brothers don't inherit the Reclaimer — that's the Order/Mandate
		// identity, not Chaos. Watch-bound qualify only as last resort.
		try {
			local roster = ::World.getPlayerRoster();
			if (roster == null) return;
			local fallback = null;
			foreach (b in roster.getAll()) {
				if (b == null || !b.isAlive()) continue;
				local skills = b.getSkills();
				if (skills == null) continue;
				if (skills.getSkillByID("trait.golden_mandate") != null) {
					if (skills.getSkillByID("trait.golden_reclaimer") == null) {
						skills.add(::new("scripts/skills/traits/golden_reclaimer_trait"));
					}
					::logInfo("[gt finale] Emperor dead; Reclaimer granted to Mandate-bound: " + b.getName());
					return;
				}
				if (fallback == null && skills.getSkillByID("trait.cinderwarden") != null) {
					fallback = b;
				}
			}
			if (fallback != null) {
				try {
					if (fallback.getSkills().getSkillByID("trait.golden_reclaimer") == null) {
						fallback.getSkills().add(::new("scripts/skills/traits/golden_reclaimer_trait"));
					}
					::logInfo("[gt finale] Emperor + Mandate brothers dead; Reclaimer fell to Watch-bound: " + fallback.getName());
				} catch (e) {}
				return;
			}
			::logWarning("[gt finale] Emperor dead and no Mandate/Watch survivor; Reclaimer not granted (Davkul-only roster left).");
		} catch (e) { ::logWarning("[gt finale] Reclaimer fallback threw: " + e); }
	}

	function _endUndeadCrisis() {
		try {
			local fm = ::World.FactionManager;
			if (fm == null) return;
			// Drop any live crisis to zero — vanilla loops detect this and
			// transition the GreaterEvil out of Live phase.
			if ("addGreaterEvilStrength" in fm) {
				fm.addGreaterEvilStrength(-9999);
			}
		} catch (e) { ::logWarning("[gt finale] crisis termination threw: " + e); }
	}

	function _despawnUndeadParties() {
		// Cosmetic dramatic beat: wandering corpses fall when the Original dies.
		try {
			if (!("EntityManager" in ::World)) return;
			local parties = ::World.EntityManager.getParties();
			if (parties == null) return;
			local removed = 0;
			foreach (party in parties) {
				if (party == null) continue;
				try {
					if (party.getFaction() == ::Const.Faction.Undead) {
						party.setStrengthVisible(0);
						party.removeFromMap();
						removed++;
					}
				} catch (e) {}
			}
			if (removed > 0) {
				::logInfo("[gt finale] despawned " + removed + " undead parties");
			}
		} catch (e) { ::logWarning("[gt finale] undead despawn threw: " + e); }
	}

	function create() {
		this.m.ID = "event.golden_pyramid_finale";
		this.m.Title = "What the Curse Was";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_18.png[/img]"
				+ "{The dust above the pyramid falls in a way dust has not fallen for an age. "
				+ "Without sound. Without weight.\n\n"
				+ "Across the dunes, far north and west, the dead stop walking. They had been "
				+ "walking for so long it had become the shape of the world; now they are not, and "
				+ "the world has to remember a different shape. Birds return to skies they had "
				+ "forgotten how to enter. A river the corpses had been damming begins, slowly, to "
				+ "move again. Cold places that should not have been cold begin, slowly, to warm.\n\n"
				+ "It will take years. But it has begun.\n\n"
				+ "And inside you — the part of you that was god-king, the part that pulled allies "
				+ "back across the line of dying, the part that called down the sun — that part is "
				+ "gone. Burned out. Spent. The fire in your hands remains, and the voice that rallies "
				+ "your brothers, and the presence that frightens lesser men. But the miracles are gone.\n\n"
				+ "The greatest things you carried were the price the world charged you to save it. "
				+ "It was a fair price.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Lay down the sword. The empire is yours, and the world is at peace. (End Campaign)",
					function getResult(_event) {
						::World.Flags.set("GoldenPyramidFinaleShown", true);
						::World.State.getMenuStack().pop(true);
						::World.State.showGameFinishScreen(true);
						return 0;
					}
				},
				{
					Text = "There is more work. The world is not done with us. (Continue)",
					function getResult(_event) {
						::World.Flags.set("GoldenPyramidFinaleShown", true);
						::World.Flags.set("GoldenPyramidContinued", true);
						::World.Flags.set("GoldenPostFinaleScenariosUnlocked", true);
						return 0;
					}
				}
			],
			function start(_event) {
				::World.Flags.set("GoldenDeadCurseEnded", true);
				_event._consumePowersAndGrantReclaimer();
				_event._endUndeadCrisis();
				_event._despawnUndeadParties();
			}
		});
	}

	function isValid() {
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return false;
		if (!::World.Flags.get("GoldenPyramidComplete")) return false;
		if (::World.Flags.get("GoldenPyramidFinaleShown")) return false;
		return true;
	}

	function onUpdateScore() {
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
