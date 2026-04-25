this.named_partner_sword <- this.inherit("scripts/items/weapons/named/named_weapon", {
	m = {},

	function create() {
		this.named_weapon.create();
		this.m.ID = "weapon.named_partner_sword";
		this.m.Name = "Dawn's Edge";
		this.m.NameList = null;
		this.m.Description = "The longsword your beloved carried into their last battle. The grip still remembers a hand that is no longer here. It is lighter than it has any right to be — as though something of the one who held it lingers in the steel.";
		this.m.Categories = "Sword, Two-Handed, Named";
		this.m.WeaponType = this.Const.Items.WeaponType.Sword;
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Named
			| this.Const.Items.ItemType.Weapon
			| this.Const.Items.ItemType.MeleeWeapon
			| this.Const.Items.ItemType.TwoHanded;
		this.m.IsAgainstShields = false;
		this.m.IsAoE = false;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = true;
		this.m.Value = 4500;
		this.m.Condition = 80.0;
		this.m.ConditionMax = 80.0;
		this.m.StaminaModifier = -6;
		this.m.RegularDamage = 55;
		this.m.RegularDamageMax = 80;
		this.m.ArmorDamageMult = 0.9;
		this.m.DirectDamageMult = 0.3;
		this.m.ChanceToHitHead = 5;

		this.m.Variants = [1, 2, 3];
		this.setVariant(this.m.Variants[this.Math.rand(0, this.m.Variants.len() - 1)]);
		this.randomizeValues();
		this._applyOutcomeRename();
	}

	function updateVariant() {
		this.m.Icon = "weapons/melee/named_longsword_0" + this.m.Variant + "_70x70.png";
		this.m.IconLarge = "weapons/melee/named_longsword_0" + this.m.Variant + ".png";
		this.m.ArmamentIcon = "icon_named_longsword_0" + this.m.Variant;
	}

	function _applyOutcomeRename() {
		if (::World == null) return;
		local outcome = ::World.Flags.get("GoldenThronePartnerOutcome");
		if (outcome == null) return;
		switch (outcome) {
			case "bring_back":
				this.m.Name = "Dawn's Edge";
				break;
			case "put_to_rest":
				this.m.Name = "Mourningsteel";
				this.m.Description = "Your beloved's longsword. You laid them to rest; the blade stayed. Light catches differently along its edge now — as if a little of the dawn they never lived to see has been trapped in the steel.";
				break;
			case "shade":
				this.m.Name = "The Still-Known Blade";
				this.m.Description = "A longsword you thought you knew. Whatever wore your beloved's face in that crypt had carried this — or something that looked like this. You keep it because putting it down would feel like giving up on something you don't yet understand.";
				break;
		}
	}

	function onEquip() {
		this.named_weapon.onEquip();
		if ("Legends" in ::getroottable() && "Actives" in ::Legends) {
			::Legends.Actives.grant(this, ::Legends.Active.Slash, function (_skill) {
				_skill.m.IsGreatSlash = true;
			}.bindenv(this));
			::Legends.Actives.grant(this, ::Legends.Active.Riposte);
			::Legends.Actives.grant(this, ::Legends.Active.Puncture, function (_skill) {
				_skill.m.IsHalfsword = true;
			}.bindenv(this));
			::Legends.Actives.grant(this, ::Legends.Active.Hammer, function (_skill) {
				_skill.m.IsMordhau = true;
			}.bindenv(this));
		}
	}

	function onAnySkillUsed(_skill, _targetEntity, _properties) {
		this.named_weapon.onAnySkillUsed(_skill, _targetEntity, _properties);
		if (_targetEntity == null) return;
		if (_skill == null || !_skill.isAttack()) return;
		local flags = _targetEntity.getFlags();
		if (flags != null && flags.has("undead")) {
			_properties.DamageRegularMult *= 1.15;
			_properties.DamageArmorMult *= 1.10;
		}
	}

	function getTooltip() {
		local ret = this.named_weapon.getTooltip();
		ret.push({
			id = 20,
			type = "text",
			icon = "ui/icons/damage_dealt.png",
			text = "[color=" + ::Const.UI.Color.PositiveValue + "]+15%[/color] damage and [color=" + ::Const.UI.Color.PositiveValue + "]+10%[/color] armour damage against undead"
		});
		return ret;
	}
});
