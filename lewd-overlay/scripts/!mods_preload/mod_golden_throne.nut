::GoldenThrone <- {
	ID = "mod_golden_throne",
	Version = "2.9.2",
	Name = "The Golden Throne — Lewd Edition"
};

::GoldenThrone.Hooks <- ::Hooks.register(::GoldenThrone.ID, ::GoldenThrone.Version, ::GoldenThrone.Name);

// ── Dependencies (shared convention across my mods) ───────────────────
// Lewd Edition mirrors main but adds mod_lewd to TestedAgainst.
::GoldenThrone.Deps <- {
	Required = {
		mod_legends      = "19.3.17",
		mod_ROTUC        = "2.1.2",
		mod_msu          = "1.2.7",
		mod_modern_hooks = "0.4.0"
	},
	TestedAgainst = {
		mod_fury_of_the_northmen = "0.5.43",
		mod_PoV                  = "4.1.0",
		mod_nggh_magic_concept   = "3.0.0-beta.90",
		mod_lewd                 = "1.9.0"
	},
	SaveCompatFrom = "2.8.0"
};

// Deps.Required stays as documentation but no hard-require call —
// testers mix versions to diagnose bugs; blocking load at version
// mismatch gets in the way. Missing deps surface at use-time.

::GoldenThrone.checkDeps <- function () {
	local prefix = "[" + ::GoldenThrone.ID + " v" + ::GoldenThrone.Version + "]";
	local tested = [];
	local drifts = [];
	foreach (modID, wantVer in ::GoldenThrone.Deps.TestedAgainst) {
		if (!::Hooks.hasMod(modID)) continue;
		local mod = ::Hooks.getMod(modID);
		local haveVer   = mod.getVersionString();
		local shortName = modID.find("mod_") == 0 ? modID.slice(4) : modID;
		tested.push(shortName + " " + wantVer);
		// String-equality short-circuit + isSemVer pre-check. Fixes
		// same-version false-positive drift + silences MSU's warning
		// on non-semver versions (Abyss 11.7 log 2026-04-24).
		local matched = (haveVer == wantVer);
		if (!matched) {
			local bothSemver = false;
			try { bothSemver = ::MSU.SemVer.isSemVer(haveVer) && ::MSU.SemVer.isSemVer(wantVer); } catch (e) {}
			if (bothSemver) {
				try { matched = ::MSU.SemVer.compareVersionWithOperator(haveVer, "==", wantVer); } catch (e) {}
			}
		}
		if (!matched) {
			local note = "version compare inconclusive";
			local bothSemver = false;
			try { bothSemver = ::MSU.SemVer.isSemVer(haveVer) && ::MSU.SemVer.isSemVer(wantVer); } catch (e) {}
			if (bothSemver) {
				try {
					note = ::MSU.SemVer.compareVersionWithOperator(haveVer, ">", wantVer)
						? "you're newer, probably fine"
						: "you're older, could miss fixes";
				} catch (e) {}
			}
			drifts.push(modID + ": you have " + haveVer + ", I tested with " + wantVer + " (" + note + ").");
		}
	}
	local summary = "";
	for (local i = 0; i < tested.len(); i++) summary += (i > 0 ? ", " : "") + tested[i];
	if (summary == "") summary = "no soft-tracked mods present";
	::logInfo(prefix + " Tested against " + summary + ". Save-compat from v" + ::GoldenThrone.Deps.SaveCompatFrom + ".");
	foreach (d in drifts) ::logWarning(prefix + " " + d);
};

// ── Snow weather system (v2.8.0) ──────────────────────────────────────
// On Golden Throne combat start, if the world tile is appropriate for
// snow (Snow / SnowHills / Tundra / Mountains), roll severity:
//   45% Light, 30% Heavy, 25% Blizzard.
// If the roll hits Blizzard AND combat starts at night, also apply the
// night-bonus effect (double-dip). All effects apply to every combatant
// on the field, ally and enemy alike — snow doesn't pick sides.

::GoldenThrone.isSnowAppropriateTerrain <- function (_tile) {
	if (_tile == null) return false;
	local t = null;
	try { t = _tile.Type; } catch (e) { return false; }
	local appropriate = [];
	local tt = this.Const.World.TerrainType;
	try { if ("Snow" in tt) appropriate.push(tt.Snow); } catch (e) {}
	try { if ("SnowHills" in tt) appropriate.push(tt.SnowHills); } catch (e) {}
	try { if ("Tundra" in tt) appropriate.push(tt.Tundra); } catch (e) {}
	try { if ("Mountains" in tt) appropriate.push(tt.Mountains); } catch (e) {}
	foreach (ok in appropriate) {
		if (t == ok) return true;
	}
	return false;
};

::GoldenThrone.applySnowVisuals <- function (_severity) {
	try {
		local weather = this.Tactical.getWeather();
		local rain = weather.createRainSettings();
		local clouds = weather.createCloudSettings();

		if (_severity == "light") {
			weather.setAmbientLightingColor(this.createColor(this.Const.Tactical.AmbientLightingColor.LightRain));
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.LightRain);
			rain.MinDrops = 150; rain.MaxDrops = 200;
			rain.NumSplats = 0;
			rain.MinVelocity = 150.0; rain.MaxVelocity = 300.0;
			rain.MinAlpha = 0.4; rain.MaxAlpha = 0.7;
			rain.MinScale = 1.0; rain.MaxScale = 2.5;
		}
		else if (_severity == "heavy") {
			weather.setAmbientLightingColor(this.createColor(this.Const.Tactical.AmbientLightingColor.LightRain));
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.LightRain);
			rain.MinDrops = 300; rain.MaxDrops = 350;
			rain.NumSplats = 0;
			rain.MinVelocity = 250.0; rain.MaxVelocity = 450.0;
			rain.MinAlpha = 0.6; rain.MaxAlpha = 0.9;
			rain.MinScale = 1.0; rain.MaxScale = 3.0;
		}
		else {
			weather.setAmbientLightingColor(this.createColor(this.Const.Tactical.AmbientLightingColor.Storm));
			weather.setAmbientLightingSaturation(this.Const.Tactical.AmbientLightingSaturation.Storm);
			rain.MinDrops = 500; rain.MaxDrops = 500;
			rain.NumSplats = 0;
			rain.MinVelocity = 400.0; rain.MaxVelocity = 600.0;
			rain.MinAlpha = 0.9; rain.MaxAlpha = 1.0;
			rain.MinScale = 1.5; rain.MaxScale = 3.5;
		}
		rain.clearDropBrushes();
		rain.addDropBrush("snow_particle_02");
		rain.addDropBrush("snow_particle_03");
		rain.addDropBrush("snow_particle_04");
		weather.buildRain(rain);

		clouds.Type = this.getconsttable().CloudType.Custom;
		clouds.MinClouds = (_severity == "blizzard") ? 220 : (_severity == "heavy" ? 150 : 80);
		clouds.MaxClouds = clouds.MinClouds;
		clouds.MinVelocity = 400.0; clouds.MaxVelocity = 500.0;
		clouds.MinAlpha = 0.6; clouds.MaxAlpha = 1.0;
		clouds.MinScale = 1.0; clouds.MaxScale = 4.0;
		clouds.Sprite = "wind_01";
		clouds.RandomizeDirection = false;
		clouds.RandomizeRotation = false;
		clouds.Direction = this.createVec(-1.0, -0.7);
		weather.buildCloudCover(clouds);

		this.Sound.setAmbience(0, this.Const.SoundAmbience.Blizzard, this.Const.Sound.Volume.Ambience * (_severity == "blizzard" ? 1.4 : 1.1), 0);
	} catch (e) {}
};

::GoldenThrone.rollAndApplySnow <- function () {
	if (::World == null) return;
	if (!("Assets" in ::World) || ::World.Assets == null) return;

	local scenarioID = "";
	try { scenarioID = ::World.Assets.getOrigin().getID(); } catch (e) { return; }
	if (scenarioID != "scenario.golden_throne") return;

	local tile = null;
	try { tile = ::World.State.getPlayer().getTile(); } catch (e) { return; }
	if (!::GoldenThrone.isSnowAppropriateTerrain.call(this, tile)) return;

	if (!("Tactical" in ::getroottable()) || ::Tactical == null) return;
	local flag = "GoldenSnowAppliedThisCombat";
	try {
		if (::Tactical.State != null && ::Tactical.State.m.StrategicProperties != null) {
			local props = ::Tactical.State.m.StrategicProperties;
			if (flag in props && props[flag] == true) return;
			props[flag] <- true;
		}
	} catch (e) {}

	local roll = ::Math.rand(1, 100);
	local effectScript = null;
	local severity = "";
	if (roll <= 45)       { severity = "light";    effectScript = "scripts/skills/effects/golden_snow_light_effect"; }
	else if (roll <= 75)  { severity = "heavy";    effectScript = "scripts/skills/effects/golden_snow_heavy_effect"; }
	else                  { severity = "blizzard"; effectScript = "scripts/skills/effects/golden_snow_blizzard_effect"; }

	local applyNight = false;
	if (severity == "blizzard") {
		try { applyNight = !::World.getTime().IsDaytime; } catch (e) {}
	}

	::GoldenThrone.applySnowVisuals.call(this, severity);

	try {
		local groups = ::Tactical.Entities.getAllInstances();
		foreach (group in groups) {
			foreach (e in group) {
				if (e == null) continue;
				try { e.getSkills().add(::new(effectScript)); } catch (ex) {}
				if (applyNight) {
					try { e.getSkills().add(::new("scripts/skills/effects/golden_snow_night_effect")); } catch (ex) {}
				}
			}
		}
	} catch (e) {}

	::logInfo("[GoldenThrone Lewd] snow weather applied: " + severity + (applyNight ? " + night" : ""));
};

::GoldenThrone.Hooks.queue(">mod_ROTUC", function () {
	::GoldenThrone.checkDeps();

	if (!("GoldenThrone" in ::Mod_ROTU.Scenario)) {
		::Mod_ROTU.Scenario.GoldenThrone <- "scenario.golden_throne";
	}
	if (::Mod_ROTU.ValidOriginIDs.find("scenario.golden_throne") == null) {
		::Mod_ROTU.ValidOriginIDs.push("scenario.golden_throne");
	}

	if ("World" in ::getroottable() && "Events" in ::World && ::World.Events != null) {
		::World.Events.register("event.golden_throne_intro", "scripts/events/events/scenario/golden_throne_intro_event");
		::World.Events.register("event.golden_partner_rumor", "scripts/events/events/scenario/golden_partner_rumor_event");
		::World.Events.register("event.golden_partner_arrival", "scripts/events/events/scenario/golden_partner_arrival_event");
		::World.Events.register("event.golden_partner_resolution", "scripts/events/events/scenario/golden_partner_resolution_event");
		::World.Events.register("event.golden_throne_cleanup", "scripts/events/events/scenario/golden_throne_cleanup_event");
		::World.Events.register("event.golden_throne_finale", "scripts/events/events/scenario/golden_throne_finale_event");
	}

	::mods_hookExactClass("states/tactical_state", function (o) {
		local originalOnShow = o.onShow;
		o.onShow = function () {
			originalOnShow.call(this);
			try { ::GoldenThrone.rollAndApplySnow.call(this); } catch (e) {
				::logWarning("[GoldenThrone] rollAndApplySnow threw: " + e);
			}
		};
	});

	::logInfo(::GoldenThrone.Name + " v" + ::GoldenThrone.Version + " registered.");
});
