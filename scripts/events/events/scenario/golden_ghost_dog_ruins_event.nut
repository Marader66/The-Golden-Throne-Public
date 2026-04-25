// Beat 2. A few days after accepting the patron's contract, the company
// reaches the ruin. No brigands, no bones, no signs of fight. Just a
// hound shaped out of pale fog, watching the gate and not afraid of you.
//
// You stay the night. You learn what he is. Tomorrow you ride home and
// tell the patron the work is done.

this.golden_ghost_dog_ruins_event <- this.inherit("scripts/events/event", {
	m = {},

	function create()
	{
		this.m.ID = "event.golden_ghost_dog_ruins";
		this.m.Title = "What Walks the Ruin";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_18.png[/img]"
				+ "{The ruin sits on a low rise, half-eaten by grass, half-still-itself. "
				+ "No smoke. No watchfires. No tracks newer than a winter's worth of rain.\n\n"
				+ "Your scouts circle and come back shaking their heads. Nobody home. "
				+ "Then one of them goes very still and points, and you see it too.\n\n"
				+ "A hound, sat at the gate. Pale enough you can see the stones through "
				+ "him. Big — half again the size of any wolfhound you've ever ridden "
				+ "with. He is not afraid. He is not aggressive. He is watching you the "
				+ "way a sentry watches a known officer who has finally arrived.\n\n"
				+ "Your hand goes to your hilt and stops there. You do not draw. The "
				+ "hound does not draw either, in whatever way ghosts draw.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Approach. Slowly. Hand open.",
					function getResult(_event) { return "STAY"; }
				}
			],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "STAY",
			Text = "[img]gfx/ui/events/event_140.png[/img]"
				+ "{You spend the day inside the ruin and the hound spends the day with "
				+ "you. He does not speak, of course. He does not need to. You watch "
				+ "him chase a man-sized shadow off the wall before sunset and you "
				+ "understand the shape of it.\n\n"
				+ "He has been here a long time. He has been guarding this place a long "
				+ "time. The brigands the patron mentioned never made it past the gate, "
				+ "and the captains he hired before you — well. The hound is well-fed "
				+ "in whatever way ghosts get well-fed.\n\n"
				+ "You stay the night. He sleeps at the foot of your bedroll without "
				+ "weight, without warmth, without sound. In the morning he is at the "
				+ "gate again, watching the road south. You are sorry, briefly, that "
				+ "you have to go and tell a man this place is ours now, and his isn't.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Ride home. Collect the coin. Come back.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenGhostDogPhase", 2);
				::World.Flags.set("GoldenGhostDogPhase2Day", ::World.getTime().Days);
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
		if (phase != 1) return false;
		local startDay = ::World.Flags.getAsInt("GoldenGhostDogPhase1Day");
		if (::World.getTime().Days - startDay < 3) return false;
		return true;
	}

	function onUpdateScore()
	{
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
