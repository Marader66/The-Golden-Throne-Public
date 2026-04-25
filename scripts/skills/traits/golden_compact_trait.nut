this.golden_compact_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {
		HasTriggeredCompact = false
	},

	function create() {
		this.character_trait.create();
		this.m.ID = "trait.golden_compact";
		this.m.Name = "The Undying Compact";
		this.m.Icon = "ui/perks/holyfire_circle.png";
		this.m.Description = "A veteran who has witnessed the Emperor's resurrection first-hand carries a fragment of that divine defiance. Once per campaign death turns aside. After that, the compact is spent.";
	}

	function getTooltip() {
		local spent = this.m.HasTriggeredCompact;
		return [
			{ id=1, type="title", text = this.getName() },
			{ id=2, type="description", text = this.m.Description },
			{ id=11, type="text", icon="ui/icons/special.png",
				text = spent
					? "[color=" + ::Const.UI.Color.NegativeValue + "]Compact expended. This veteran falls like any other.[/color]"
					: "[color=" + ::Const.UI.Color.PositiveValue + "]Compact available. This veteran will survive one killing blow.[/color]" },
			{ id=12, type="text", icon="ui/icons/special.png",
				text = "Cannot be raised as undead." }
		];
	}

	function onUpdate(_properties) {
		_properties.SurvivesAsUndead = false;

		if (!this.m.HasTriggeredCompact) {
			_properties.SurviveWithInjuryChanceMult = _properties.SurviveWithInjuryChanceMult * 50.0;
		}
	}

	function onTurnStart() {
		if (this.m.HasTriggeredCompact) return;

		local actor = this.getContainer().getActor();
		if (!actor.isAlive()) return;

		local injuries = actor.getSkills().query(::Const.SkillType.Injury | ::Const.SkillType.SemiInjury);
		if (injuries.len() > 0) {
			this.m.HasTriggeredCompact = true;
			if (!actor.isHiddenToPlayer()) {
				::Tactical.EventLog.log("[color=#FFD700]" + ::Const.UI.getColorizedEntityName(actor) + " invokes the Undying Compact — death is denied! The compact is now spent.[/color]");
				this.spawnIcon("active_128", actor.getTile());
			}
		}
	}

	function onSerialize(_out) {
		this.character_trait.onSerialize(_out);
		_out.writeBool(this.m.HasTriggeredCompact);
	}

	function onDeserialize(_in) {
		this.character_trait.onDeserialize(_in);
		this.m.HasTriggeredCompact = _in.readBool();
	}
});
