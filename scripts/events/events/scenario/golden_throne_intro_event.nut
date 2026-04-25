this.golden_throne_intro_event <- this.inherit("scripts/events/event", {
	m = {},

	function create() {
		this.m.ID = "event.golden_throne_intro";
		this.m.IsSpecial = true;

		this.m.Screens.push({
			ID = "GENDER",
			Text = "[img]gfx/ui/events/event_145.png[/img]"
				+ "{Before the waking there is a question. "
				+ "Before even the waking — a small, personal truth the world "
				+ "requires of you before it gives you back your shape.\n\n"
				+ "You have been many things across the ages. But in the age "
				+ "that is about to begin, what will you be?}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "I am the Emperor.",
					function getResult(_event) { return "A"; }
				},
				{
					Text = "I am the Empress.",
					function getResult(_event) {
						_event.setOriginGender(true);
						return "A";
					}
				}
			],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_145.png[/img]"
				+ "{You do not remember waking. You remember a throne. "
				+ "Cold gold. A hall that stretched beyond sight. "
				+ "A thousand faces looking up at you, afraid and faithful in equal measure.\n\n"
				+ "Then: nothing. An age of nothing.\n\n"
				+ "Until the screaming started — not voices, but the world itself. "
				+ "Something has torn a wound in the order of things. "
				+ "You can feel it from whatever dark place you have slept in. "
				+ "It pulls at you. Insistent. Wrong.\n\n"
				+ "You open your eyes.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "Where am I?",
				function getResult(_event) { return "B"; }
			}],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_29.png[/img]"
				+ "{You are in a field. The soil is grey. "
				+ "The trees at the edges are black and bare — it is neither winter nor drought. "
				+ "They are dead in the way only corruption makes things dead.\n\n"
				+ "A man in a tattered robe sees you rise and falls to his knees. "
				+ "He says a name you do not recognise. "
				+ "He says it like a prayer.\n\n"
				+ "'The Usurper,' he says, when he finds words. "
				+ "'He has opened the dungeon. He has made himself a god. "
				+ "The dead walk. Nothing holds. We thought — we prayed — we hoped "
				+ "someone would come. Something old enough to remember what the world "
				+ "was supposed to be.'\n\n"
				+ "You look at your hands. Gold-clad. Heavy. Familiar.\n\n"
				+ "You remember what you are.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "I remember my purpose.",
				function getResult(_event) { return "C"; }
			}],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/rotu_intro_moon.png[/img]"
				+ "{You have died before. Not like men die — not one final darkness — "
				+ "but a long diminishing. Each age you lived through, "
				+ "some piece of what you were became legend, then myth, then silence.\n\n"
				+ "Now you are here again. Smaller than you were. "
				+ "Still golden. Still burning with something the dark cannot extinguish.\n\n"
				+ "But you are not invincible. Not this time. "
				+ "The compact you hold with whatever made you was not infinite. "
				+ "It will shield you once more from the killing blow — "
				+ "but after that, you are mortal. After that, there is no coming back.\n\n"
				+ "The man in the robe is still kneeling. He is weeping.\n\n"
				+ "'Will you stand?' he asks.\n\n"
				+ "You look toward the horizon. Somewhere beyond it, a dungeon. "
				+ "A pretender. A wound that must be closed.\n\n"
				+ "'Yes,' you say. 'One more time.'}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "The Usurper will be destroyed.",
				function getResult(_event) { return "D"; }
			}],
			function start(_event) {}
		});

		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/rotu_intro_deets.png[/img]"
				+ "{[color=#FFD700]The Golden Throne — Scenario Details[/color]\n\n"
				+ "[color=#bcad8c]The Emperor:[/color] A dormant warrior-king, now stirring. "
				+ "Melee-focused with warrior stat talents. His divine presence buffs "
				+ "nearby allies and prevents undead from rising within 10 tiles. "
				+ "Every attack he makes consecrates his target, burning them with holy flame. "
				+ "Two-handed weapons burn hotter still.\n\n"
				+ "[color=#bcad8c]Resurrection:[/color] The Emperor will survive the first killing blow. "
				+ "The second death ends the campaign. He cannot be raised as undead.\n\n"
				+ "[color=#bcad8c]Summon Knights:[/color] He can call two Golden Knights from the divine compact, "
				+ "each bearing a random martial blessing: Ironclad, Wrath, Stalwart, "
				+ "Zealous, Swift, or Sovereign.\n\n"
				+ "[color=#bcad8c]Crisis Sequence:[/color] The undead stir from the moment you begin — "
				+ "a pale shadow of what is coming. Survive the mounting tide, "
				+ "and the world will eventually demand a Holy War.\n\n"
				+ "[color=#bcad8c]Objective:[/color] Find the Usurper's dungeon. Purge it. "
				+ "All 19 floors. This is what you woke up for.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [{
				Text = "For the Throne. For the World.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {}
		});
	}

	function onUpdateScore() { return; }
	function onPrepare() { this.m.Title = "The Golden Throne Awakens..."; }
	function onPrepareVariables(_vars) {}
	function onClear() {}

	function onDetermineStartScreen() {
		return "GENDER";
	}

	function setOriginGender(_isFemale) {
		if (!_isFemale) return;
		if (::World == null) return;
		local roster = ::World.getPlayerRoster();
		if (roster == null) return;

		local emperor = null;
		foreach (bro in roster.getAll()) {
			if (bro == null) continue;
			if (bro.getFlags().get("GoldenEmperor")) { emperor = bro; break; }
		}
		if (emperor == null) return;

		emperor.setGender(1, true);
		emperor.setName("The Empress");
		::World.Flags.set("GoldenEmperorIsFemale", true);

		local bg = emperor.getBackground();
		if (bg != null) {
			bg.m.Icon = "ui/backgrounds/background_empress.png";
			bg.m.BackgroundDescription = "Born into the royal family, the princess has been practicing martial arts since childhood. She grew up with a free and unrestrained spirit, refusing to be confined by the trivial etiquette of the palace. After her beloved father and elder brothers were tragically killed at the hands of the usurpers, she resolutely put on a golden mask, discarded her delicate royal robes, and dressed in a sharp military uniform. With a sword in her hand and courage in her heart, she went to the people, rallied the remaining loyal soldiers and patriotic people, and formed an army to fight against the usurpers who had seized the throne.";
		}
	}
});
