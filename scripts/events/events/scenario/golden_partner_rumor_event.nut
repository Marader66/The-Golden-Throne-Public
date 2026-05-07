this.golden_partner_rumor_event <- this.inherit("scripts/events/event", {
	m = {
		PartnerName = "Valeria of the Dawn Court"
	},

	function create() {
		this.m.ID = "event.golden_partner_rumor";
		this.m.Title = "A Name From Before";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_145.png[/img]"
				+ "{The camp is quiet. You have walked a long road since you woke — "
				+ "too long to still be surprised by a name, and yet.\n\n"
				+ "A wandering scholar has been paid to share his stories. "
				+ "He speaks of ruins, of towers the old maps do not name, of "
				+ "cold places that should not still be cold. Your brothers listen "
				+ "for the entertainment. You listen for something else.\n\n"
				+ "And then he says it.\n\n"
				+ "%partnername%.\n\n"
				+ "The name your beloved carried in life. A name you had not allowed "
				+ "yourself to say — not in this world, not in this age — since the "
				+ "morning you woke to ruin.\n\n"
				+ "'The shrine in the old pass,' the scholar says, unaware of what he "
				+ "has struck. 'They say a figure moves there. Armoured. Holy. "
				+ "Waiting for someone. It is a tale older than the Usurper, my Lord. "
				+ "Older than this whole sorry age.'}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Pray for their return. Whatever walks there, let it be them.",
					function getResult(_event) { return "PRAY"; }
				},
				{
					Text = "Prepare yourself. If it is them, they are no longer them. Ready the mercy.",
					function getResult(_event) { return "MOURN"; }
				},
				{
					Text = "Say nothing. Let the scholar move on. Deal with this in your own time.",
					function getResult(_event) { return "WAIT"; }
				}
			],
			function start(_event) {
				::World.Flags.set("GoldenThronePartnerRumored", true);
			}
		});

		this.m.Screens.push({
			ID = "PRAY",
			Text = "[img]gfx/ui/events/event_18.png[/img]"
				+ "{You say nothing aloud. You do not need to. The prayer is older than "
				+ "the words that would frame it — older than you — and the shape of "
				+ "it in your chest is the same shape hope has always had.\n\n"
				+ "A direction. A decision. The road will take you where it takes you. "
				+ "Tomorrow you will ask your brothers to turn northward.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "I am coming.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenThronePartnerRumored", true);
				::World.Flags.set("GoldenThronePartnerChoice", "pray");
			}
		});

		this.m.Screens.push({
			ID = "MOURN",
			Text = "[img]gfx/ui/events/event_49.png[/img]"
				+ "{You have watched enough of this age to know what the dead usually "
				+ "become. If it is them — it is not them. You cannot let yourself "
				+ "want what it would mean if it were.\n\n"
				+ "You accept, quietly, the shape of the mercy you will probably have "
				+ "to offer. You ready yourself to be the one to give it. The road "
				+ "will take you where it takes you. Tomorrow you will ask your "
				+ "brothers to turn northward.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Let us be quick, and let us be kind.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenThronePartnerRumored", true);
				::World.Flags.set("GoldenThronePartnerChoice", "mourn");
			}
		});

		this.m.Screens.push({
			ID = "WAIT",
			Text = "[img]gfx/ui/events/event_154.png[/img]"
				+ "{You press a coin into the scholar's hand to keep him moving. You "
				+ "will not let your brothers see what has just happened on your face.\n\n"
				+ "You carry the name with you. You do not speak of it. You do not yet "
				+ "know what you will do — but the road has bent northward in your mind "
				+ "whether you will it or not.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "I will decide when I must.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				::World.Flags.set("GoldenThronePartnerRumored", true);
				::World.Flags.set("GoldenThronePartnerChoice", "wait");
			}
		});
	}

	function onPrepare() {
		if (::World != null) {
			::World.Flags.set("GoldenThronePartnerRumored", true);
		}

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
		if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return false;
		if (::World.getTime().Days < 80) return false;
		if (::World.Flags.get("GoldenThronePartnerRumored")) return false;
		return true;
	}

	function onUpdateScore() {
		this.m.Score = this.isValid() ? 100 : 0;
	}
});
