// Beat 5. The fight at the ruin is over. The hound is sat at the gate
// again — solid this time, not see-through. He waits for you to come
// to him.

this.golden_ghost_dog_farewell_event <- this.inherit("scripts/events/event", {
	m = {},

	function create()
	{
		this.m.ID = "event.golden_ghost_dog_farewell";
		this.m.Title = "Until I'm Called";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_140.png[/img]"
				+ "{When the last of them is down, the hound sits. He is solid now. "
				+ "Whatever held him here through the fight is letting him go, slow, "
				+ "and what's left is the dog he was — big, brindle-grey, watching "
				+ "you with the patience animals have always had for the people "
				+ "they trust.\n\n"
				+ "You go to him. He puts his head in your hand. He is warm. He is "
				+ "real. You have not had a friend you did not have to give orders "
				+ "to in a very long time. He licks your face once and the brothers "
				+ "do you the courtesy of pretending not to see the Emperor laugh.\n\n"
				+ "He stands. He looks at the gate, at the road south, at you. "
				+ "He has waited long enough. The work is finished and the place "
				+ "is yours and there is no need for him to stand at the door any "
				+ "more.\n\n"
				+ "He fades the way a long breath fades. Not gone. Not yet, and "
				+ "not all the way. You feel him decide, somewhere quiet, that "
				+ "he will be at your side again the next time you need him.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Until I call. Good boy.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenGhostDogPhase", 5);
				::World.Flags.set("GoldenGhostDogResolved", true);
				try {
					::World.Assets.addBusinessReputation(50);
				} catch (e) {}
			}
		});
	}

	function isValid()
	{
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne") return false;
		local phase = ::World.Flags.get("GoldenGhostDogPhase");
		if (phase != 4) return false;
		return true;
	}

	function onUpdateScore()
	{
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
