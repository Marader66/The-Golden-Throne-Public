// Beat 4. The patron is dead in his own hall. The company rides hard
// for the ruin. The patron's "real men" are already there, and so is
// the hound, and the fight is already on by the time you make the gate.

this.golden_ghost_dog_battle_event <- this.inherit("scripts/events/event", {
	m = {},

	function create()
	{
		this.m.ID = "event.golden_ghost_dog_battle";
		this.m.Title = "The Hound at the Gate";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_31.png[/img]"
				+ "{You ride for the ruin. You ride hard. The horses are foaming "
				+ "by the time the rise comes back into view, and you can hear "
				+ "the fight before you can see it.\n\n"
				+ "He is at the gate again. He is not a sentry now. He is a "
				+ "weapon. There are bodies in the grass already and more men "
				+ "still standing, and the hound is tearing through the line of "
				+ "them like a man who has been waiting a very long time to be "
				+ "useful.\n\n"
				+ "He sees you. He does not break stride. He simply makes room "
				+ "in the line, the way a soldier does when his officer arrives.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Form up. Take the gate.",
					function getResult(_event) {
						_event._launchRuinsBattle();
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
		if (phase != 3) return false;
		local startDay = ::World.Flags.getAsInt("GoldenGhostDogPhase3Day");
		if (::World.getTime().Days - startDay < 1) return false;
		return true;
	}

	function onUpdateScore()
	{
		this.m.Score = this.isValid() ? 100 : 0;
	}

	function _launchRuinsBattle()
	{
		::World.Flags.set("GoldenGhostDogPhase", 4);
		::World.Flags.set("GoldenGhostDogPhase4Day", ::World.getTime().Days);

		local playerPos = ::World.State.getPlayer().getPos();
		local properties = ::World.State.getLocalCombatProperties(playerPos);
		properties.CombatID = "GoldenGhostDogRuins";
		properties.IsAutoAssigningBases = true;
		properties.Entities = [];

		// Hostile band — bandits + a heavier element since these are
		// "real men, the ones I trust to actually haul something out."
		local picks = ["BanditLeader", "BanditRaider", "BanditRaider", "BanditMarksman", "BanditMarksman", "BanditThug", "BanditThug", "BanditThug", "Footman", "Footman"];
		foreach (key in picks) {
			if (!(key in ::Const.World.Spawn.Troops)) continue;
			local spec = clone ::Const.World.Spawn.Troops[key];
			spec.Faction <- this.Const.Faction.Enemy;
			properties.Entities.push(spec);
		}

		// Spectral Hound ally. Registered Troop spec wraps our entity script.
		if ("GoldenGhostDog_Spec" in ::Const.World.Spawn.Troops) {
			local hound = clone ::Const.World.Spawn.Troops.GoldenGhostDog_Spec;
			hound.Faction <- this.Const.Faction.PlayerAnimals;
			properties.Entities.push(hound);
		}

		::World.State.startScriptedCombat(properties, false, false, true);
	}
});
