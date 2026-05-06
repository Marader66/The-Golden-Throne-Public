// v2.14.0-alpha — D4 Phase A, Beat 3. The 5-floor pyramid dungeon.
//
// Single event with progress flag pattern. Lifted from ROTU's Usurper Castle
// (`usurpercastle_enter_event.nut`) but compressed to 5 floors. The lobby
// screen "A" reads `GoldenPyramidProgress` and routes to the right floor.
//
// Floor design:
//   1: 6× LegendMummyLight                                    (tactical.desert_camp)
//   2: 4× LegendMummyLight + 2× LegendMummyMedium             (tactical.desert_camp)
//   3: 4× LegendMummyMedium + 2× LegendMummyHeavy             (tactical.desert_camp)
//   4: 4× LegendMummyHeavy + 2× LegendMummyPriest             (tactical.sunken_library)
//   5: 1× The Original + 1× LegendMummyQueen + 2× LegendMummyHeavy
//                                                              (tactical.sunken_library)
//
// On floor 5 victory, fires "FinalVictory" screen which sets
// `GoldenPyramidComplete = true` and chains into the finale event.
this.golden_pyramid_floor_event <- this.inherit("scripts/events/event", {
	m = {},

	function getNextScreenID(_progress) {
		switch (_progress) {
			case 0: return "B";
			case 1: return "C";
			case 2: return "D";
			case 3: return "E";
			case 4: return "F";
			default: return 0;
		}
	}

	function _buildEntities(_specs) {
		local out = [];
		foreach (s in _specs) {
			for (local i = 0; i < s.count; i++) {
				out.push({
					ID = s.id,
					Variant = 0,
					Row = ::Math.rand(0, 2),
					Script = s.script,
					Faction = ::Const.Faction.Enemy
				});
			}
		}
		return out;
	}

	function prepareCombatProperties(_specs, _template = "tactical.desert_camp", _music = "music/undead_01.ogg") {
		local pp = ::World.State.getLocalCombatProperties(::World.State.getPlayer().getPos());
		pp.CombatID = "EventGoldenPyramid_f"
			+ (::World.Statistics.getFlags().getAsInt("GoldenPyramidProgress") + 1);
		pp.Music = [_music];
		pp.LocationTemplate = clone ::Const.Tactical.LocationTemplate;
		pp.LocationTemplate.Template[0] = _template;
		pp.PlayerDeploymentType = ::Const.Tactical.DeploymentType.Line;
		pp.EnemyDeploymentType = ::Const.Tactical.DeploymentType.Line;
		pp.IsAutoAssigningBases = false;
		pp.Loot = [];
		// Random named-item drop per floor (lifted from Usurper Castle).
		local items = clone ::Const.Items.NamedWeapons;
		items.extend(clone ::Const.Items.NamedShields);
		items.extend(clone ::Const.Items.LegendNamedArmorLayers);
		items.extend(clone ::Const.Items.LegendNamedHelmetLayers);
		pp.Loot.push("scripts/items/" + items[::Math.rand(0, items.len() - 1)]);
		pp.Entities = this._buildEntities(_specs);
		return pp;
	}

	function create() {
		this.m.ID = "event.golden_pyramid_floor";
		this.m.Title = "The Original's Pyramid";
		this.m.Cooldown = 0.0;
		this.m.IsSpecial = true;

		// LOBBY — reads progress flag, branches to current floor.
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_154.png[/img]"
				+ "{The pyramid waits. The dust here is the wrong colour, the way the trader said it would be. "
				+ "The light dies a few feet inside the doorway. Your brothers stand close together without "
				+ "being told to, and you cannot decide if they are protecting you or the other way around.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start(_event) {
				local progress = ::World.Statistics.getFlags().getAsInt("GoldenPyramidProgress");
				local labels = [
					"Enter the pyramid. (Floor 1)",
					"Continue. (Floor 2)",
					"Continue. (Floor 3)",
					"Continue. (Floor 4)",
					"Climb to the throne. (Floor 5)"
				];
				if (progress < 0 || progress > 4) progress = 0;
				this.Options.push({
					Text = labels[progress],
					function getResult(_event) {
						return _event.getNextScreenID(::World.Statistics.getFlags().getAsInt("GoldenPyramidProgress"));
					}
				});
				this.Options.push({
					Text = "Fall back for now.",
					function getResult(_event) { return _event.onResetVisited(); }
				});
			}
		});

		// FLOOR 1 — outer chambers. Light mummies.
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_56.png[/img]"
				+ "{The outer chambers. The walls bear writing in a script no scribe alive could read. "
				+ "Sand-wrapped figures rise from alcoves you did not know were occupied. They move with the "
				+ "stuttering grace of things that have not had bodies for a long time and have remembered "
				+ "in the last few seconds how it is done.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Prepare for battle.",
					function getResult(_event) {
						local specs = [
							{ id = ::Const.EntityType.LegendMummyLight, script = "scripts/entity/tactical/enemies/legend_mummy_light", count = 6 }
						];
						local pp = _event.prepareCombatProperties(specs, "tactical.desert_camp");
						_event.registerToShowAfterCombat("Victory", "Defeat");
						::World.State.startScriptedCombat(pp, false, false, true);
						return 0;
					}
				},
				{
					Text = "Fall back.",
					function getResult(_event) { return _event.onResetVisited(); }
				}
			],
			function start(_event) { _event.m.Title = "The Pyramid : First Chamber"; }
		});

		// FLOOR 2 — descending hall. Mixed light + medium.
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_56.png[/img]"
				+ "{A descending hall. The air gets older as you walk. Stronger figures here — armoured, "
				+ "wrapped in linens that have not turned to dust because nothing in this place has been "
				+ "permitted to. They look at you with eyes that do not exist and they know who you are.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Prepare for battle.",
					function getResult(_event) {
						local specs = [
							{ id = ::Const.EntityType.LegendMummyLight, script = "scripts/entity/tactical/enemies/legend_mummy_light", count = 4 },
							{ id = ::Const.EntityType.LegendMummyMedium, script = "scripts/entity/tactical/enemies/legend_mummy_medium", count = 2 }
						];
						local pp = _event.prepareCombatProperties(specs, "tactical.desert_camp");
						_event.registerToShowAfterCombat("Victory", "Defeat");
						::World.State.startScriptedCombat(pp, false, false, true);
						return 0;
					}
				},
				{
					Text = "Fall back.",
					function getResult(_event) { return _event.onResetVisited(); }
				}
			],
			function start(_event) { _event.m.Title = "The Pyramid : Second Chamber"; }
		});

		// FLOOR 3 — sand-choked vault. Medium + heavy.
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_56.png[/img]"
				+ "{A sand-choked vault. Heavier guardians here, their wrappings covering plate that should "
				+ "have rusted to nothing centuries ago. Whatever holds this place together holds them too. "
				+ "There is a name carved over the doorway behind them. You stop yourself reading it.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Prepare for battle.",
					function getResult(_event) {
						local specs = [
							{ id = ::Const.EntityType.LegendMummyMedium, script = "scripts/entity/tactical/enemies/legend_mummy_medium", count = 4 },
							{ id = ::Const.EntityType.LegendMummyHeavy, script = "scripts/entity/tactical/enemies/legend_mummy_heavy", count = 2 }
						];
						local pp = _event.prepareCombatProperties(specs, "tactical.desert_camp");
						_event.registerToShowAfterCombat("Victory", "Defeat");
						::World.State.startScriptedCombat(pp, false, false, true);
						return 0;
					}
				},
				{
					Text = "Fall back.",
					function getResult(_event) { return _event.onResetVisited(); }
				}
			],
			function start(_event) { _event.m.Title = "The Pyramid : Third Chamber"; }
		});

		// FLOOR 4 — inner sanctum. Heavy + priests.
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_56.png[/img]"
				+ "{The inner sanctum. The light is cold here, blue at its edges, the way the dawn looks "
				+ "an hour before it actually arrives. Robed figures stand among the heavy guardians — "
				+ "priests of nothing, attendants of a throne not yet sat upon. Their voices are the "
				+ "rustle of pages turning by themselves. They do not look surprised that you have come.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Prepare for battle.",
					function getResult(_event) {
						local specs = [
							{ id = ::Const.EntityType.LegendMummyHeavy, script = "scripts/entity/tactical/enemies/legend_mummy_heavy", count = 4 },
							{ id = ::Const.EntityType.LegendMummyPriest, script = "scripts/entity/tactical/enemies/legend_mummy_priest", count = 2 }
						];
						local pp = _event.prepareCombatProperties(specs, "tactical.sunken_library");
						_event.registerToShowAfterCombat("Victory", "Defeat");
						::World.State.startScriptedCombat(pp, false, false, true);
						return 0;
					}
				},
				{
					Text = "Fall back.",
					function getResult(_event) { return _event.onResetVisited(); }
				}
			],
			function start(_event) { _event.m.Title = "The Pyramid : Inner Sanctum"; }
		});

		// FLOOR 5 — throne. The Original. Final fight.
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_154.png[/img]"
				+ "{The throne chamber.\n\n"
				+ "The figure on the throne stands as you enter. Armour without a nation's heraldry. "
				+ "A face that is your face, almost. A voice older than the world that has stopped "
				+ "and is listening, now, for the first time in an age.\n\n"
				+ "[color=#FFD700]\"You came back. The wheel turned. I knew it would.\"[/color]\n\n"
				+ "The Original. The first piece. The shape from which the Usurper was a copy, and the "
				+ "Cinderwatch's enemy was a copy, and a thousand small horrors in this age were copies. "
				+ "You will not get another chance.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "End it.",
					function getResult(_event) {
						local specs = [
							{ id = ::Const.EntityType.HedgeKnight, script = "scripts/entity/tactical/enemies/golden_the_original", count = 1 },
							{ id = ::Const.EntityType.LegendMummyQueen, script = "scripts/entity/tactical/enemies/legend_mummy_queen", count = 1 },
							{ id = ::Const.EntityType.LegendMummyHeavy, script = "scripts/entity/tactical/enemies/legend_mummy_heavy", count = 2 }
						];
						local pp = _event.prepareCombatProperties(specs, "tactical.sunken_library", "music/undead_01.ogg");
						_event.registerToShowAfterCombat("FinalVictory", "Defeat");
						::World.State.startScriptedCombat(pp, false, false, true);
						return 0;
					}
				},
				{
					Text = "Fall back.",
					function getResult(_event) { return _event.onResetVisited(); }
				}
			],
			function start(_event) { _event.m.Title = "The Pyramid : The Throne"; }
		});

		// VICTORY — generic post-floor (1-4) handler.
		this.m.Screens.push({
			ID = "Victory",
			Text = "[img]gfx/ui/events/event_132.png[/img]"
				+ "{The chamber falls quiet. Your brothers regroup. Whatever waits below has heard you "
				+ "now, and is no longer pretending otherwise.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Onwards. Deeper.",
					function getResult(_event) {
						::World.Statistics.getFlags().increment("GoldenPyramidProgress");
						return _event.getNextScreenID(::World.Statistics.getFlags().getAsInt("GoldenPyramidProgress"));
					}
				},
				{
					Text = "Pull back. Recover. Return.",
					function getResult(_event) {
						::World.Statistics.getFlags().increment("GoldenPyramidProgress");
						return _event.onResetVisited();
					}
				}
			],
			function start(_event) {}
		});

		// FINAL VICTORY — floor 5 cleared. Sets curse-end flags, chains to finale.
		this.m.Screens.push({
			ID = "FinalVictory",
			Text = "[img]gfx/ui/events/event_132.png[/img]"
				+ "{The Original falls.\n\n"
				+ "The wind in the throne-chamber stops, all at once, the way a held breath stops. The "
				+ "blue cold fades from the walls. A name you did not allow yourself to think for an age "
				+ "of the world settles, somewhere inside you, and stays settled.\n\n"
				+ "Far above the pyramid, in the world you fought for — wherever the dead were walking, "
				+ "they are not walking now. The thing that held them up has been pulled out of them.\n\n"
				+ "It is done. The age that killed the world is over. What follows is yours to make.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Walk back to the light.",
					function getResult(_event) {
						::World.Flags.set("GoldenPyramidComplete", true);
						::World.Flags.set("GoldenPyramidProgress", 5);
						return _event.onResetVisited();
					}
				}
			],
			function start(_event) {
				_event.m.Title = "The Pyramid : The Original Falls";
			}
		});

		// DEFEAT — combat lost; player can return.
		this.m.Screens.push({
			ID = "Defeat",
			Text = "[img]gfx/ui/events/event_99.png[/img]"
				+ "{Defeat. The pyramid has not let you in. Not yet.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Pull what is left of us out.",
					function getResult(_event) { return _event.onResetVisited(); }
				}
			],
			function start(_event) { _event.m.Title = "After the battle..."; }
		});
	}

	function onResetVisited() {
		if (::World.State.getLastLocation() != null) {
			::World.State.getLastLocation().setVisited(false);
		}
		return 0;
	}
});
