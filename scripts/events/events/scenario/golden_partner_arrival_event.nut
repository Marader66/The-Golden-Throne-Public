this.golden_partner_arrival_event <- this.inherit("scripts/events/event", {
	m = {
		PartnerName = "Valeria of the Dawn Court"
	},

	function create() {
		this.m.ID = "event.golden_partner_arrival";
		this.m.Title = "The Old Pass";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_29.png[/img]"
				+ "{You find it where the scholar said it would be — higher than "
				+ "the maps remember, older than the stones around it. A shrine, "
				+ "or what was once a shrine. The door is a seam in the rock and "
				+ "you know how to open it; you opened it, once, in a life that "
				+ "is now a legend the scholar will never tell accurately.\n\n"
				+ "Your brothers form up behind you. They do not know whom they are "
				+ "about to meet. You do not tell them. They will know soon enough.\n\n"
				+ "You put your hand to the seam. The stone remembers you and moves.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Go in.",
				function getResult(_event) { return "B"; }
			}],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_158.png[/img]"
				+ "{The shrine opens into a crypt. The air inside has not moved in "
				+ "an age of the world. Cold gold lies on every surface the way "
				+ "dust lies on ordinary places — you know this gold, you wore it, "
				+ "you ordered it hammered out for a wedding that is in no history "
				+ "any living scholar has read.\n\n"
				+ "At the far end of the crypt, a figure stands. Armoured. Holy. "
				+ "The blade in their hand is one you remember.\n\n"
				+ "They turn. The helm has eye-slits and what is behind the eye-slits "
				+ "is not a living light. A voice you buried in yourself for an age "
				+ "speaks your true name — cracked, thin, certain.\n\n"
				+ "'%partnername%,' you say.\n\n"
				+ "'Is that… you?' they answer, as though they are the one who has "
				+ "been waiting. The blade comes up.\n\n"
				+ "There is nothing more to say that is not said with steel.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Fight.",
				function getResult(_event) { return "C"; }
			}],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_145.png[/img]"
				+ "{You meet in the middle of the crypt. They are better than they "
				+ "have any right to be, after an age of stillness — whatever holds "
				+ "them holds them in the form they had on the last day they drew "
				+ "breath. Your brothers do not interfere; they do not know that "
				+ "they are watching you fight a ghost.\n\n"
				+ "You are better than they are. You always were, by half a step. "
				+ "They taught you that half-step, kindly. You trade cuts. You read "
				+ "the pattern of their guard the way you read it a thousand "
				+ "tournament afternoons ago.\n\n"
				+ "You find the opening.\n\n"
				+ "The blade is poised. The decision is yours — or it is fate's, or "
				+ "it is the quiet arithmetic of everything you are and everything "
				+ "this age has made you. Either way, you act.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Let what comes, come.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenThronePartnerArrived", true);
				::World.Flags.set("GoldenThronePartnerBossKilled", true);
			}
		});
	}

	function onPrepare() {
		local emperorIsFemale = ::World != null && ::World.Flags.get("GoldenEmperorIsFemale") == true;
		this.m.PartnerName = emperorIsFemale
			? "Aldric the Oathsworn"
			: "Valeria of the Dawn Court";

		foreach (screen in this.m.Screens) {
			if ("Text" in screen) {
				screen.Text = ::MSU.String.replace(screen.Text, "%partnername%", this.m.PartnerName);
			}
		}
	}

	function isValid() {
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne") return false;
		if (!::World.Flags.get("GoldenThronePartnerRumored")) return false;
		if (::World.Flags.get("GoldenThronePartnerArrived")) return false;
		if (::World.Flags.get("GoldenThronePartnerResolved")) return false;
		local renown = 0;
		try { renown = ::World.Assets.getBusinessReputation(); } catch (e) {}
		if (renown < 750) return false;
		return true;
	}

	function onUpdateScore() {
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
