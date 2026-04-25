// Beat 1 of the Spectral Hound chain. A would-be patron rides into camp
// with a contract to clear a haunted ruin — the place is "lousy with
// brigands" and pays well. Accepting sets phase=1 and starts the timer
// for Beat 2 to fire.
//
// Phase tracker: ::World.Flags.get("GoldenGhostDogPhase")
//   0 / null  — not yet offered
//   1         — offer accepted; ruins-arrival event armed (Beat 2)
//   2         — ruins visited; betrayal event armed (Beat 3)
//   3         — contractor confronted + dead; race-back armed (Beat 4)
//   4         — ruins fight won; farewell armed (Beat 5)
//   5         — done

this.golden_ghost_dog_offer_event <- this.inherit("scripts/events/event", {
	m = {},

	function create()
	{
		this.m.ID = "event.golden_ghost_dog_offer";
		this.m.Title = "A Patron at the Camp";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_55.png[/img]"
				+ "{A man rides into camp before dawn — well-fed, well-dressed, "
				+ "and impressed enough with himself for two. He says his name "
				+ "with weight you do not recognise, asks for the Emperor with "
				+ "weight he assumes you do.\n\n"
				+ "He has a problem. A ruin in the back country, brigand-haunted, "
				+ "no use to anyone. He's offered fair coin to half a dozen "
				+ "captains already — none of them came back. He's heard of you. "
				+ "He's heard you do not lose.\n\n"
				+ "'I will pay one thousand crowns. The place is on the old map, "
				+ "north fork of the river. Burn it out. Bring me back the head "
				+ "of whoever's still alive. Easy work for the man who broke "
				+ "the Usurper, surely.'}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Accept the contract. A thousand crowns is a thousand crowns.",
					function getResult(_event) { return "ACCEPT"; }
				},
				{
					Text = "Refuse. There's something he isn't saying.",
					function getResult(_event) { return "REFUSE"; }
				}
			],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "ACCEPT",
			Text = "[img]gfx/ui/events/event_77.png[/img]"
				+ "{You take the contract. The man bows too deeply to be sincere "
				+ "and rides off in the direction he came from, already bored of "
				+ "you.\n\n"
				+ "Your brothers strike camp. The old map is unrolled. The ruin "
				+ "is a few days' march to the north, off any trade road, in "
				+ "country no honest farmer would clear. Easy work, the patron "
				+ "said. You have lived long enough to know what easy work tends "
				+ "to mean.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Northward, then. We'll be back inside the week.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenGhostDogPhase", 1);
				::World.Flags.set("GoldenGhostDogPhase1Day", ::World.getTime().Days);
			}
		});

		this.m.Screens.push({
			ID = "REFUSE",
			Text = "[img]gfx/ui/events/event_82.png[/img]"
				+ "{You watch him too long, and he sees you watching, and he leaves "
				+ "before he meant to. Whatever was on offer was not on offer for "
				+ "you. The brothers ask after him for a day or two, and then they "
				+ "stop asking.\n\n"
				+ "You do not hear of him again, except in passing — a man who pays "
				+ "captains to walk into ruined places, and seems unbothered when "
				+ "they do not walk back out.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Some doors are not for opening.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenGhostDogPhase", -1);
			}
		});
	}

	function isValid()
	{
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne") return false;
		if (::World.getTime().Days < 40) return false;
		local phase = ::World.Flags.get("GoldenGhostDogPhase");
		if (phase != null && phase != false && phase != 0) return false;
		return true;
	}

	function onUpdateScore()
	{
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
