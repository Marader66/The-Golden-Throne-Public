// Beat 3. The company rides home. The patron is in his hall, drinking
// and smug. He listens to the report, laughs, and tells you the truth —
// you were never the real raid. He sent another band on your heels to
// haul out whatever the ruin was actually hiding while you cleared the
// gate.
//
// You do not get the contract money. You get a fight.

this.golden_ghost_dog_betrayal_event <- this.inherit("scripts/events/event", {
	m = {},

	function create()
	{
		this.m.ID = "event.golden_ghost_dog_betrayal";
		this.m.Title = "The Patron's Smile";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_82.png[/img]"
				+ "{The patron is in his hall, drinking, when you ride up. He hears "
				+ "you out, and the smile he gives you is older than the room. "
				+ "He raises his cup.\n\n"
				+ "'I knew you'd manage. I told the others you'd manage. So they're "
				+ "already in the place — my real men, the ones I trust to actually "
				+ "haul something out — and by sundown they'll have it, and we'll "
				+ "all have done well. Don't look so sour. The thousand crowns was "
				+ "a tip, not a wage. The work was the diversion.'\n\n"
				+ "He gestures to his guards. They come up from the long table easy. "
				+ "Six of them, well-fed too. He keeps drinking.\n\n"
				+ "'You should have refused. The ones who refuse, I let leave.'}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Cut him down where he sits.",
					function getResult(_event) {
						_event._launchContractorCombat();
						return 0;
					}
				}
			],
			function start(_event) {}
		});
	}

	function isValid()
	{
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return false;
		local phase = ::World.Flags.get("GoldenGhostDogPhase");
		if (phase != 2) return false;
		local startDay = ::World.Flags.getAsInt("GoldenGhostDogPhase2Day");
		if (::World.getTime().Days - startDay < 2) return false;
		return true;
	}

	function onUpdateScore()
	{
		this.m.Score = this.isValid() ? 100 : 0;
	}

	function _launchContractorCombat()
	{
		::World.Flags.set("GoldenGhostDogPhase", 3);
		::World.Flags.set("GoldenGhostDogPhase3Day", ::World.getTime().Days);

		local playerPos = ::World.State.getPlayer().getPos();
		local properties = ::World.State.getLocalCombatProperties(playerPos);
		properties.CombatID = "GoldenGhostDogContractor";
		properties.IsAutoAssigningBases = true;
		properties.Entities = [];

		local picks = ["BanditLeader", "BanditRaider", "BanditRaider", "BanditMarksman", "BanditMarksman", "BanditThug", "BanditThug"];
		foreach (key in picks) {
			if (!(key in ::Const.World.Spawn.Troops)) continue;
			local spec = clone ::Const.World.Spawn.Troops[key];
			spec.Faction <- this.Const.Faction.Enemy;
			properties.Entities.push(spec);
		}

		::World.State.startScriptedCombat(properties, false, false, true);
	}
});
