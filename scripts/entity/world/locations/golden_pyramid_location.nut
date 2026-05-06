// v2.14.0-alpha — Golden Throne D4 Phase A pyramid location.
//
// Lives at a random desert tile after Beat 1 rumor commits to PUSH or PRAY.
// Routes onEnter to event.golden_pyramid_approach (Beat 2). Approach gates
// the actual dungeon entry on key-holder presence; this location is just
// the world-map handle.
//
// Pattern lifted from mod_rotucore_inn's usurpercastle_location.nut +
// mod_Black_Pyramid's black_pyramid_location.nut. Sprite brush set in
// onInit (final brush selection awaits research-agent return; placeholder
// uses Black Pyramid's existing brush which is already in our stack).
this.golden_pyramid_location <- this.inherit("scripts/entity/world/location", {
	m = {},

	function getDescription() {
		return "A black pyramid half-buried in the dunes. Older than the empire. Older than the dead madness.";
	}

	function create() {
		this.location.create();
		this.m.Name = "The Original's Pyramid";
		this.m.TypeID = "location.golden_pyramid";
		this.m.LocationType = this.Const.World.LocationType.Unique;
		this.m.IsShowingDefenders = false;
		this.m.IsDespawningDefenders = false;
		this.m.IsShowingBanner = false;
		this.m.IsAttackable = false;
		this.m.VisibilityMult = 1.0;
		this.m.Resources = 0;
		this.m.OnEnter = "event.golden_pyramid_approach";
	}

	function onSpawned() {
		this.location.onSpawned();
	}

	function onInit() {
		this.location.onInit();
		// Vanilla Legends pyramid sprite — already used by legend_mummy_location;
		// no extra mod dep required.
		local body = this.addSprite("body");
		body.setBrush("legend_pyramid");
	}

	function onDeserialize(_in) {
		this.location.onDeserialize(_in);
	}
});
