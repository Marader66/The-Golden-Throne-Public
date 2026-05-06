// v2.14.0-alpha — D4 Phase A, Beat 1.
//
// Fires Day +30 after the Usurper falls AND the player chose "raise the banner
// again" on the v2.7.0 finale event AND a key-holder is present in the roster.
//
// Key-holder gate (either path qualifies):
//   - Cinderwatch loaded + cinderwarden_background in roster (uses
//     ::Cinderwatch._hasCinderwardenInRoster, defined in mod_cinderwatch.nut)
//   - Emperor (GoldenEmperor flag) at Mandate tier 4+ (Exalted)
//
// Narrative hook: a desert caravan-trader speaks of a black pyramid in the
// dunes. Older than the empire. Older than the dead madness. Something there
// has spoken the Emperor's name.
//
// Sets GoldenPyramidRumored = true; routes to one of three sub-flags
// (GoldenPyramidApproach in {"push","dismiss","pray"}) for later beats to vary
// flavor against.
this.golden_pyramid_rumor_event <- this.inherit("scripts/events/event", {
	m = {},

	function create() {
		this.m.ID = "event.golden_pyramid_rumor";
		this.m.Title = "A Tale Older Than the Throne";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_154.png[/img]"
				+ "{The Usurper has been dead a month. The world has not noticed.\n\n"
				+ "A desert caravan-trader rests at your camp tonight. He has come a long way "
				+ "across the dunes — too long to be welcome anywhere but a fire that asks no "
				+ "questions. He drinks slowly. He speaks little. When he does speak, your "
				+ "brothers fall quiet without being told to.\n\n"
				+ "He talks of a place no map shows. A black pyramid in the deep south, "
				+ "half-sunk in the sand, far older than the Usurper's castle. Older, he says, "
				+ "than your empire. The light dies near it. The dust there is the wrong colour.\n\n"
				+ "He does not know what it is. But he heard a name spoken on the wind there, "
				+ "by something that was not human and not yet dead.\n\n"
				+ "Your name.\n\n"
				+ "Spoken by something that was you, once. Before you were anyone.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Push the trader for more. Sketch me the location.",
					function getResult(_event) { return "PUSH"; }
				},
				{
					Text = "This age is full of voices that speak names. Dismiss it.",
					function getResult(_event) { return "DISMISS"; }
				},
				{
					Text = "Pray over it. Whatever this is, it is mine to face.",
					function getResult(_event) { return "PRAY"; }
				}
			],
			function start(_event) {
				::World.Flags.set("GoldenPyramidRumored", true);
			}
		});

		this.m.Screens.push({
			ID = "PUSH",
			Text = "[img]gfx/ui/events/event_56.png[/img]"
				+ "{You sit closer to the trader. You lower your voice. You give him gold he "
				+ "did not expect, and time he had not been given anywhere else in this age.\n\n"
				+ "He sketches what he can. He has not been there. No-one has been there. "
				+ "But men he trusted, men who do not lie about such things, have spoken of a "
				+ "shape on the southern horizon at dusk — a shape that is not a hill, that "
				+ "casts no shadow at noon, that has been there since before any wall in the "
				+ "world was raised.\n\n"
				+ "He marks the rough quarter on a folded square of parchment. He warns you "
				+ "the dunes shift. He warns you the heat is wrong there. He warns you that "
				+ "no caravan that has set out for it has come back.\n\n"
				+ "Then he asks, very quietly, whether you intend to go.\n\n"
				+ "You tell him the truth.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "South. We turn south.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenPyramidRumored", true);
				::World.Flags.set("GoldenPyramidApproach", "push");
				try { ::GoldenThrone.spawnPyramidLocation(true); } catch (e) {}
			}
		});

		this.m.Screens.push({
			ID = "DISMISS",
			Text = "[img]gfx/ui/events/event_18.png[/img]"
				+ "{You wave the trader off. You make a joke at his expense your brothers "
				+ "laugh at, and the moment passes, and the fire crackles, and the wine is "
				+ "good.\n\n"
				+ "But that night you do not sleep. You stare up at the sky you fought a war "
				+ "to give back to the living, and the name the trader spoke walks the inside "
				+ "of your skull, and the south is a direction you cannot stop your mind "
				+ "drifting toward.\n\n"
				+ "Whatever it was, it has heard of you. Sooner or later you will have to "
				+ "answer. You have not decided when. But it will be your decision.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Some other day. Not yet.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenPyramidRumored", true);
				::World.Flags.set("GoldenPyramidApproach", "dismiss");
				// Spawn but don't reveal — player can stumble onto it later.
				try { ::GoldenThrone.spawnPyramidLocation(false); } catch (e) {}
			}
		});

		this.m.Screens.push({
			ID = "PRAY",
			Text = "[img]gfx/ui/events/event_18.png[/img]"
				+ "{You leave the fire. You walk out past the picket-line, past the last of "
				+ "the camp's noise, until there is only sand and the cold of a desert night.\n\n"
				+ "You do not pray to a god. You did not pray to a god when you lay dying the "
				+ "first time, and you will not pray to one now. But you stand there a long "
				+ "while in the silence, and you listen to whatever it is that is listening "
				+ "back, and you allow it to know that you have heard it.\n\n"
				+ "When you walk back to camp, your brothers do not ask. They have learned. "
				+ "They have a fire ready, and a place at it, and they do not need to be told "
				+ "that tomorrow the column turns south.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "South. We turn south.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenPyramidRumored", true);
				::World.Flags.set("GoldenPyramidApproach", "pray");
				try { ::GoldenThrone.spawnPyramidLocation(true); } catch (e) {}
			}
		});
	}

	// Key-holder presence check. Either path qualifies:
	//   1. Cinderwatch loaded + cinderwarden_background in roster
	//   2. Emperor (GoldenEmperor flag) at Mandate tier 4+ (Exalted)
	function _hasKeyHolder() {
		if (::World == null) return false;
		try {
			// Path 1 — Cinderwarden in roster (uses Cinderwatch's own helper)
			if ("Cinderwatch" in ::getroottable()
				&& "_hasCinderwardenInRoster" in ::Cinderwatch
				&& ::Cinderwatch._hasCinderwardenInRoster()) {
				return true;
			}
			// Path 2 — Emperor at Mandate tier 4+
			local roster = ::World.getPlayerRoster();
			if (roster == null) return false;
			foreach (b in roster.getAll()) {
				if (b == null || !b.isAlive()) continue;
				local flags = b.getFlags();
				if (flags == null || !flags.has("GoldenEmperor")) continue;
				local mandate = b.getSkills().getSkillByID("trait.golden_mandate");
				if (mandate == null) return false;
				local tier = 0;
				try {
					if ("getTierLevel" in mandate) {
						tier = mandate.getTierLevel();
					} else if ("m" in mandate
							&& "TierStats" in mandate.m
							&& "TierLevel" in mandate.m.TierStats) {
						tier = mandate.m.TierStats.TierLevel;
					}
				} catch (e) {}
				return tier >= 4;
			}
		} catch (e) {}
		return false;
	}

	function isValid() {
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return false;

		// Already fired — don't refire.
		if (::World.Flags.get("GoldenPyramidRumored")) return false;

		// v2.14.0-alpha — debug bypass for testing. Set via dev console:
		//   World.Flags.set("GoldenPyramidDebugForceTrigger", true)
		// then wait one world tick (or open camp/move). Bypasses ALL gates
		// below (Usurper, FinaleContinued, day, key-holder).
		if (::World.Flags.get("GoldenPyramidDebugForceTrigger")) return true;

		// Hard-required upstream gates.
		if (!::World.Flags.get("GoldenThroneUsurperDown")) return false;
		if (!::World.Flags.get("GoldenThroneFinaleContinued")) return false;

		// Day-gate 280 — bumped from 250 to space the pyramid rumor away from
		// cinderwatch_approach (Day 250). Both were scoring 100 same-day in 3M
		// campaigns. Day 280 sits cleanly between cinderwatch_dim_ember (170-240)
		// and cinderwatch_dark_grows (270-305) without colliding.
		// Replace with a stored "FinaleContinuedAtDay" snapshot for v2.14.1+
		// for proper relative gating.
		if (::World.getTime().Days < 280) return false;

		// Key-holder presence.
		if (!this._hasKeyHolder()) return false;

		return true;
	}

	function onUpdateScore() {
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
