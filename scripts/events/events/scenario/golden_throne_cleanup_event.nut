this.golden_throne_cleanup_event <- this.inherit("scripts/events/event", {
	m = {},

	function create() {
		this.m.ID = "event.golden_throne_cleanup";
		this.m.Title = "The Host Without Its Master";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]"
				+ "{The Usurper fell. His body lies behind you in a room that is "
				+ "quieter now than any room has been for an age.\n\n"
				+ "The road back from the castle is not as quiet. The dead he "
				+ "raised — the ones he bound, the ones he called up from the old "
				+ "fields — they are still walking. They do not know their master "
				+ "is gone. They will not know for some time. They will keep "
				+ "walking until someone who is still alive makes them stop.\n\n"
				+ "That is going to be you, and your brothers, and whatever sword "
				+ "arm is still in working order by the end of it.\n\n"
				+ "The crown can wait one more season. The host cannot.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "First the host. Then the throne.",
				function getResult(_event) {
					::World.Flags.set("GoldenThroneCleanupShown", true);
					return 0;
				}
			}],
			function start(_event) {}
		});
	}

	function isValid() {
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne") return false;
		if (!::World.Flags.get("GoldenThroneUsurperDown")) return false;
		if (::World.Flags.get("GoldenThroneCleanupShown")) return false;
		local evil = ::World.FactionManager.m.GreaterEvil;
		if (evil == null) return false;
		if (evil.Type != ::Const.World.GreaterEvilType.Undead) return false;
		if (evil.Phase != ::Const.World.GreaterEvilPhase.Live) return false;
		return true;
	}

	function onUpdateScore() {
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
