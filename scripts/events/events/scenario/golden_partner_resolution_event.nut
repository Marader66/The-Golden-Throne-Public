this.golden_partner_resolution_event <- this.inherit("scripts/events/event", {
	m = {
		Outcome = "",
		PartnerName = "Valeria of the Dawn Court"
	},

	function create() {
		this.m.ID = "event.golden_partner_resolution";
		this.m.Title = "The Crypt's Silence";
		this.m.Cooldown = 9999.0 * ::World.getTime().SecondsPerDay;

		// No "ROUTER" / "A" entry-point screen — the event jumps directly
		// to one of the three outcome screens via onDetermineStartScreen.
		// (v2.9.4: vanilla onDetermineStartScreen returns "A", but our
		// outcome screen IDs are BRING_BACK / PUT_TO_REST / SHADE — no
		// "A" existed, getScreen("A") returned null, setScreen(null) was
		// a no-op, ActiveScreen stayed null/stale, and the render loop
		// threw "the index 'Text' does not exist" every frame. Fix is
		// the override below; ROUTER screen removed since it's bypassed.)

		this.m.Screens.push({
			ID = "BRING_BACK",
			Text = "[img]gfx/ui/events/event_144.png[/img]"
				+ "{The blade in your hand is steady. The figure in the crypt is not.\n\n"
				+ "You remember, at the last instant, not to strike.\n\n"
				+ "Whatever bound them here — corruption, vow, grief — breaks. Not with "
				+ "a crash, not with a cry: with a breath. They draw breath, which they "
				+ "have not done in an age of the world.\n\n"
				+ "They look at you.\n\n"
				+ "'%partnername%,' you say.\n\n"
				+ "'I heard you coming,' they say, 'for longer than you have been alive "
				+ "in this age. I have been waiting to stop waiting.'\n\n"
				+ "They take your hand.}",
			Image = "", Banner = "", List = [], Characters = [],
			Options = [{
				Text = "Come home.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				_event._grantBringBack();
			}
		});

		this.m.Screens.push({
			ID = "PUT_TO_REST",
			Text = "[img]gfx/ui/events/event_49.png[/img]"
				+ "{The blade falls. They do not try to stop it.\n\n"
				+ "For a moment — only a moment, and you will argue with yourself about "
				+ "it for the rest of your unnaturally long life — their eyes clear. "
				+ "Whatever held them lifts. They are themselves again, in the brief "
				+ "space it takes a breath to finish.\n\n"
				+ "'Thank you,' they say. '%partnername%' — they say your own name, as "
				+ "though they are the one being released — 'thank you.'\n\n"
				+ "Then they are gone, and the crypt is quiet, and your hand does not "
				+ "shake, because you are a very old soul and you have been ready for "
				+ "this since you woke.\n\n"
				+ "You take the sword. You will carry it. That, at least, is yours to do.}",
			Image = "", Banner = "", List = [], Characters = [],
			Options = [{
				Text = "Rest now. The world will keep without you.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				_event._grantPutToRest();
			}
		});

		this.m.Screens.push({
			ID = "SHADE",
			Text = "[img]gfx/ui/events/event_158.png[/img]"
				+ "{The fallen figure crumbles, and a wrongness goes out of the crypt.\n\n"
				+ "You stand over the bones for a long time before you understand. "
				+ "The armour is wrong. The skeleton is smaller than they were, or "
				+ "larger — you cannot tell in the dim, but you know, the way the "
				+ "body knows.\n\n"
				+ "It was not them.\n\n"
				+ "Whatever it was had worn them like a second garment — a shade, a "
				+ "memory, a thing that knew your beloved's face because it had eaten "
				+ "the memory of them. %partnername% has been dust since an age that "
				+ "does not remember itself, and you have just killed a scavenger that "
				+ "had learned to smile the way your love once did.\n\n"
				+ "You take the sword. It is not theirs. It was near theirs. That will "
				+ "have to be enough.}",
			Image = "", Banner = "", List = [], Characters = [],
			Options = [{
				Text = "So that is what we are fighting. Noted.",
				function getResult(_event) { return 0; }
			}],
			function start(_event) {
				_event._grantShade();
			}
		});
	}

	function onPrepare() {
		local emperorIsFemale = ::World != null && ::World.Flags.get("GoldenEmperorIsFemale") == true;
		this.m.PartnerName = emperorIsFemale
			? "Aldric the Oathsworn"
			: "Valeria of the Dawn Court";

		this.m.Outcome = this._rollOutcome();
		::World.Flags.set("GoldenThronePartnerOutcome", this.m.Outcome);

		foreach (screen in this.m.Screens) {
			if ("Text" in screen) {
				screen.Text = ::MSU.String.replace(screen.Text, "%partnername%", this.m.PartnerName);
			}
		}
	}

	function onDetermineStartScreen() {
		switch (this.m.Outcome) {
			case "bring_back": return "BRING_BACK";
			case "put_to_rest": return "PUT_TO_REST";
			case "shade":       return "SHADE";
		}
		return "BRING_BACK"; // safety fallback if Outcome got dropped somehow
	}

	function _rollOutcome() {
		local bringBack = 40;
		local putToRest = 40;
		local shade = 20;

		local choice = "";
		try { choice = "" + ::World.Flags.get("GoldenThronePartnerChoice"); } catch (e) {}
		if (choice == "pray") bringBack += 10;
		if (choice == "mourn") putToRest += 10;

		local mandate3Count = 0;
		local brandCount = 0;
		try {
			local bros = ::World.State.getPlayer().getTroops();
			foreach (bro in bros) {
				local e = bro.getEntity();
				if (e == null) continue;
				local skills = e.getSkills();
				if (skills == null) continue;
				local mandate = skills.getSkillByID("trait.golden_mandate");
				if (mandate != null) {
					local tier = 0;
					if ("TierStats" in mandate.m) tier = mandate.m.TierStats.TierLevel;
					if (tier >= 3) mandate3Count++;
				}
				if (skills.getSkillByID("special.golden_brand") != null) brandCount++;
			}
		} catch (e) {}
		bringBack += ::Math.min(15, mandate3Count * 3);
		bringBack += ::Math.min(10, brandCount * 2);

		local purgeCount = 0;
		try {
			local bros = ::World.State.getPlayer().getTroops();
			foreach (bro in bros) {
				local e = bro.getEntity();
				if (e == null) continue;
				local trait = e.getSkills().getSkillByID("trait.golden_emperor");
				if (trait != null) {
					if ("PurgeCount" in trait.m) purgeCount = trait.m.PurgeCount;
					break;
				}
			}
		} catch (e) {}
		if (purgeCount >= 100) putToRest += 5;
		if (purgeCount >= 250) putToRest += 10;
		if (purgeCount >= 500) putToRest += 10;

		local total = bringBack + putToRest + shade;
		local roll = ::Math.rand(1, total);
		if (roll <= bringBack) return "bring_back";
		if (roll <= bringBack + putToRest) return "put_to_rest";
		return "shade";
	}

	function _grantBringBack() {
		// v2.9.6: rewrote with canonical hire pattern. Original v2.5.0 code
		// called `::World.State.getPlayer().hireBrother(...)` — both wrong:
		// getPlayer() returns the world-state party wrapper (Table), not
		// the roster, and `hireBrother` is a phantom method that doesn't
		// exist in vanilla or Legends. Repro from Kabu's 2026-04-27 logs:
		// 6× `[mod_golden_throne] bring_back grant partial: the index
		// 'hireBrother' does not exist`. Brother never spawned; the
		// catch silently swallowed each throw. Canonical pattern verified
		// against ROTU's mod_rotu_recruit_event.nut and the Knight summon.
		try {
			local roster = ::World.getPlayerRoster();
			if (roster == null) return;

			local bro = roster.create("scripts/entity/tactical/player");
			if (bro == null) return;
			bro.setStartValuesEx(["golden_beloved_background"]);
			bro.setName(this.m.PartnerName);

			// 14 × 2500 XP = ~levels 1 -> ~13 (matches original v2.5.0 intent).
			// Background's onAfterUpdate auto-grants the_beloved_trait,
			// beloved_presence_aura, Mandate tier 5, Light Oath, Chosen tier 3.
			for (local i = 0; i < 14; i++) {
				bro.addXP(2500, false);
			}

			// Equip Dawn's Edge — named_partner_sword display name flips to
			// "Dawn's Edge" because GoldenThronePartnerOutcome == "bring_back"
			// (set in onPrepare before this method runs). Original v2.5.0
			// missed this entirely; design doc had it in the reward column.
			try {
				bro.getItems().equip(::new("scripts/items/weapons/named/named_partner_sword"));
			} catch (e) {
				::logWarning("[mod_golden_throne] bring_back sword-equip partial: " + e);
			}

			roster.add(bro);
		} catch (e) {
			::logWarning("[mod_golden_throne] bring_back grant partial: " + e);
		}
		::World.Flags.set("GoldenThronePartnerRestored", true);
	}

	function _grantPutToRest() {
		local roster = ::World.State.getPlayer().getTroops();
		foreach (bro in roster) {
			local e = bro.getEntity();
			if (e == null) continue;
			local trait = e.getSkills().getSkillByID("trait.golden_emperor");
			if (trait != null) {
				if (e.getSkills().getSkillByID("trait.resolved") == null) {
					e.getSkills().add(::new("scripts/skills/traits/resolved_trait"));
				}
				if ("PurgeCount" in trait.m) trait.m.PurgeCount += 50;
				break;
			}
		}
		::World.Assets.addMoney(1000);
		::World.Assets.addBusinessReputation(100);
		::World.Assets.getStash().add(::new("scripts/items/weapons/named/named_partner_sword"));
		::World.Flags.set("GoldenThronePartnerAtPeace", true);
	}

	function _grantShade() {
		local roster = ::World.State.getPlayer().getTroops();
		foreach (bro in roster) {
			local e = bro.getEntity();
			if (e == null) continue;
			local trait = e.getSkills().getSkillByID("trait.golden_emperor");
			if (trait != null) {
				if (e.getSkills().getSkillByID("trait.memory_burden") == null) {
					e.getSkills().add(::new("scripts/skills/traits/memory_burden_trait"));
				}
				break;
			}
		}
		::World.Assets.addMoney(300);
		::World.Assets.addBusinessReputation(-50);
		::World.Assets.getStash().add(::new("scripts/items/weapons/named/named_partner_sword"));
		::World.Flags.set("GoldenThronePartnerShadeRevealed", true);
	}

	function isValid() {
		if (::World == null) return false;
		local scenarioID = "";
		try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return false; }
		if (scenarioID != "scenario.golden_throne" && scenarioID != "scenario.three_musketeers") return false;
		if (!::World.Flags.get("GoldenThronePartnerBossKilled")) return false;
		if (::World.Flags.get("GoldenThronePartnerResolved")) return false;
		return true;
	}

	function onUpdateScore() {
		this.m.Score = this.isValid() ? 100 : 0;
	}

	function onFinish() {
		::World.Flags.set("GoldenThronePartnerResolved", true);
	}
});
