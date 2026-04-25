// Spectral hound — ghost dog ally that appears in the Beat 4 ruins combat
// and the Beat 5 farewell. Inherits vanilla direwolf, overlays ghost-fog on
// top of the body sprite for the ethereal look. Pure-vanilla composition
// (vanilla direwolf body + bust_ghost_fog overlay), public-portable.
//
// Faction: PlayerAnimals (ally, not summon-controlled like a knight — moves
// on its own AI). Buffed stats scale with the Emperor's level so it stays
// relevant late campaign.

this.golden_ghost_dog_ally <- this.inherit("scripts/entity/tactical/enemies/direwolf", {
	m = {
		EmperorLevel = 1
	},

	function isGuest()
	{
		return true;
	}

	function addXP(_xp) {}

	function _findEmperorLevel()
	{
		try {
			local roster = ::World.getPlayerRoster().getAll();
			foreach (bro in roster) {
				if (bro == null) continue;
				if ("GoldenEmperor" in bro.m && bro.m.GoldenEmperor) {
					return bro.m.Level;
				}
			}
		} catch (e) {}
		return 1;
	}

	function onInit()
	{
		this.direwolf.onInit();

		this.setFaction(this.Const.Faction.PlayerAnimals);

		this.m.EmperorLevel = this._findEmperorLevel();
		local lvl = this.m.EmperorLevel;

		local b = this.m.BaseProperties;
		local scale = 1.0;
		if (lvl >= 25) scale = 4.0;
		else if (lvl >= 15) scale = 2.5;
		else if (lvl >= 5) scale = 1.5;

		b.Hitpoints      = (90 + lvl * 4) * scale;
		b.Stamina        = (140 + lvl * 2) * scale;
		b.MeleeSkill     = 80 + lvl;
		b.MeleeDefense   = 30 + lvl / 3;
		b.RangedDefense  = 30;
		b.Bravery        = 200;
		b.Initiative     = 110 + lvl;

		b.IsImmuneToBleeding = true;
		b.IsImmuneToPoison = true;
		b.IsImmuneToKnockBackAndGrab = true;
		b.IsImmuneToStun = true;
		b.MoraleEffectMult = 0.0;

		this.m.CurrentProperties = clone b;
		this.m.Hitpoints = b.Hitpoints;

		// Swap the direwolf brushes for vanilla wardog (bust_hound_*) —
		// matches the shaggy-warhound silhouette user referenced. Pure
		// vanilla art — same atlas BB uses for the DLC4 adopt-warhound
		// event and Legends' sighthound entities, just code-rerouted.
		local houndVariant = this.Math.rand(1, 2);
		try {
			local body = this.getSprite("body");
			if (body != null) {
				body.setBrush("bust_hound_0" + houndVariant + "_body_0" + this.Math.rand(1, 2));
				// Slight-brown warm tint per user direction. Push red + green,
				// drop blue, ease saturation so ghost-fog overlay reads.
				body.varyColor(0.08, 0.04, -0.04);
				body.Saturation = 0.7;
			}
		} catch (e) {}

		try {
			local head = this.getSprite("head");
			if (head != null) {
				head.setBrush("bust_hound_0" + houndVariant + "_head_0" + this.Math.rand(1, 2));
				head.varyColor(0.08, 0.04, -0.04);
				head.Saturation = 0.7;
			}
		} catch (e) {}

		try {
			local fog = this.addSprite("ghost_fog");
			fog.setBrush("bust_ghost_fog_02");
			fog.Alpha = 200;
			fog.Visible = true;
		} catch (e) {}

		try { this.m.Name = "Spectral Hound"; } catch (e) {}
	}

	function onDeath(_killer, _skill, _tile, _fatalityType)
	{
		// Suppress obituary entry — pattern from golden_knight_ally v2.7.2
		try {
			local addFallenOriginal = ::World.Statistics.addFallen;
			::World.Statistics.addFallen = function(...) { return; };
			this.direwolf.onDeath(_killer, _skill, _tile, _fatalityType);
			::World.Statistics.addFallen = addFallenOriginal;
		} catch (e) {
			this.direwolf.onDeath(_killer, _skill, _tile, _fatalityType);
		}
	}
});
