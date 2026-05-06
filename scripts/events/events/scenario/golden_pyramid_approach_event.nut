// v2.14.0-alpha — D4 Phase A, Beat 2. Pyramid entry-gate event.
//
// Triggered by the pyramid location's onEnter. Routes to:
//   - event.golden_pyramid_floor  (if a key-holder is present)
//   - exit                        (otherwise — door doesn't open)
//
// Key-holder rule (either path qualifies):
//   1. Cinderwatch loaded + cinderwarden_background in roster
//   2. Emperor at Mandate tier 4+
//
// On first successful entry, sets GoldenPyramidEntered flag (informational).
this.golden_pyramid_approach_event <- this.inherit("scripts/events/event", {
	m = {},

	function _hasKeyHolder() {
		if (::World == null) return false;
		// v2.14.0-alpha — debug bypass for testing.
		if (::World.Flags.get("GoldenPyramidDebugForceTrigger")) return true;
		try {
			if ("Cinderwatch" in ::getroottable()
				&& "_hasCinderwardenInRoster" in ::Cinderwatch
				&& ::Cinderwatch._hasCinderwardenInRoster()) {
				return true;
			}
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

	function create() {
		this.m.ID = "event.golden_pyramid_approach";
		this.m.Title = "The Pyramid";
		this.m.Cooldown = 0.0;
		this.m.IsSpecial = true;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_154.png[/img]"
				+ "{The pyramid is not a place. It is the suggestion of a place — a deeper black against "
				+ "the dunes, casting no shadow at noon. There is no door. There are five rectangular "
				+ "recesses cut into the south face, smooth-edged, head-high. The wind here does not "
				+ "move. The air is cold the way deep-water is cold.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start(_event) {
				if (_event._hasKeyHolder()) {
					this.Text = "[img]gfx/ui/events/event_154.png[/img]"
						+ "{The pyramid is not a place. It is the suggestion of a place — a deeper black "
						+ "against the dunes, casting no shadow at noon. There is no door. There are five "
						+ "rectangular recesses cut into the south face, smooth-edged, head-high.\n\n"
						+ "Then the brass lantern (or the gold in your eyes; or both) catches one of the "
						+ "recesses and the recess catches it back. The black stone slides on no hinge any "
						+ "of you can see, and an aperture appears that was not there a moment before, "
						+ "and the cold inside is the cold of a thing that has been waiting a long time.\n\n"
						+ "Your brothers wait for you. The aperture waits for you.}";
					this.Options.push({
						Text = "Enter.",
						function getResult(_event) {
							::World.Flags.set("GoldenPyramidEntered", true);
							return "B";
						}
					});
					this.Options.push({
						Text = "Not yet. Pull back.",
						function getResult(_event) {
							if (::World.State.getLastLocation() != null) {
								::World.State.getLastLocation().setVisited(false);
							}
							return 0;
						}
					});
				} else {
					this.Text += "\n\n{None of you know how to open it. Whatever key the pyramid wants, none of "
						+ "you carry it. The brothers exchange looks. The wind is still not moving.}";
					this.Options.push({
						Text = "Pull back. Find what is missing.",
						function getResult(_event) {
							if (::World.State.getLastLocation() != null) {
								::World.State.getLastLocation().setVisited(false);
							}
							return 0;
						}
					});
				}
			}
		});

		// Hand off to the floor event without making the player click through
		// twice. "B" just chains.
		this.m.Screens.push({
			ID = "B",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "...",
					function getResult(_event) { return 0; }
				}
			],
			function start(_event) {
				::World.Events.fire("event.golden_pyramid_floor");
			}
		});
	}
});
