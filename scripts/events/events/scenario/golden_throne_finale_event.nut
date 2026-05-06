this.golden_throne_finale_event <- this.inherit("scripts/events/event", {
	m = {},

	function create() {
		this.m.ID = "event.golden_throne_finale";
		this.m.Title = "The Throne Reclaimed";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_144.png[/img]"
				+ "{The Usurper's body lies at your feet. Nineteen floors of the dark "
				+ "castle are behind you — nineteen floors of men who wore the crown "
				+ "that was not theirs, of beasts that answered to a name that was "
				+ "not your own, of undead things that walked because he let them. "
				+ "And above it all, at the top, the one who took your throne.\n\n"
				+ "He fell like any other mortal.\n\n"
				+ "Your brothers have found a room to sit in. They are quiet. The "
				+ "fire is good. Someone is singing, poorly, a song that was popular "
				+ "a thousand years ago in a city that is now a ruin under the ice.\n\n"
				+ "This moment — this quiet room, these tired men, this body that "
				+ "has come through — is the nearest you have been, for an age of "
				+ "the world, to being at peace.\n\n"
				+ "You have a decision.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Lay down the sword. The empire is yours again. (End Campaign)",
					function getResult(_event) {
						::World.Flags.set("GoldenThroneFinaleShown", true);
						::World.State.getMenuStack().pop(true);
						::World.State.showGameFinishScreen(true);
						return 0;
					}
				},
				{
					Text = "The work is never done. Raise the banner again.",
					function getResult(_event) {
						::World.Flags.set("GoldenThroneFinaleShown", true);
						::World.Flags.set("GoldenThroneFinaleContinued", true);
						return 0;
					}
				}
			],
			function start(_event) {}
		});
	}

	function isValid() {
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return false;
		if (!::World.Flags.get("GoldenThroneUsurperDown")) return false;
		if (::World.Flags.get("GoldenThroneFinaleShown")) return false;
		local evil = ::World.FactionManager.m.GreaterEvil;
		if (evil != null
			&& evil.Type == ::Const.World.GreaterEvilType.Undead
			&& evil.Phase == ::Const.World.GreaterEvilPhase.Live) {
			return false;
		}
		return true;
	}

	function onUpdateScore() {
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
