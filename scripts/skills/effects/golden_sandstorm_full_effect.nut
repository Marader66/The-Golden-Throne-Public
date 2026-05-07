// sandstorm severity-3 effect.
//
// Stat penalties (-10 RS / -3 MS / -4 Init / -3 Vision) PLUS turn-start
// per-actor effects:
//   - 1 stack of Blindness (FoTN if loaded, else golden_blinded_effect)
//     UNLESS the actor is undead/spirit OR wears a real helm (head
//     durability ≥ 100 = great helm, mail coif + helmet, etc; bare-headed
//     or hood-only takes the stack).
//   - 5 burning damage routed through the canonical damage pipeline.
//
// Written as a custom class instead of via InheritHelper.sandstormEffect
// because we need an onTurnStart hook, which the factory doesn't support.
// Light + heavy still use the factory.
this.golden_sandstorm_full_effect <- this.inherit("scripts/skills/skill", {
    m = {},

    function create() {
        this.m.ID = "effects.golden_sandstorm_full";
        this.m.Name = "Sandstorm";
        this.m.Description = "A wall of sand. Visibility collapses; weapon-grips slip in sweat and grit. Bare-headed brothers blind in the wind. The air burns. -10 Ranged Skill, -3 Melee Skill, -4 Initiative, -3 Vision. Each turn: bare-headed actors gain Blindness; everyone takes 5 burning damage.";
        // v2.14.6 — was status_effect_109 (BB's blizzard icon — read as
        // snow). Swapped to storm_circle (verified vanilla, used by
        // Legends's EvocationMagicTree) for a generic storm/wind theme.
        this.m.Icon = "ui/perks/storm_circle.png";
        this.m.IconMini = "perk_15_mini";
        this.m.Type = this.Const.SkillType.StatusEffect;
        this.m.Order = this.Const.SkillOrder.Perk;
        this.m.IsSerialized = false;
        this.m.IsActive = false;
        this.m.IsStacking = false;
        this.m.IsHidden = false;
        this.m.IsRemovedAfterBattle = true;
    }

    function onUpdate(_properties) {
        _properties.RangedSkill -= 10;
        _properties.MeleeSkill  -= 3;
        _properties.Initiative  -= 4;
        _properties.Vision      -= 3;
    }

    function onTurnStart() {
        local actor = null;
        try { actor = this.getContainer().getActor(); } catch (e) { return; }
        if (actor == null) return;
        try { if (!actor.isAlive() || !actor.isPlacedOnMap()) return; } catch (e) { return; }

        // Skip undead / spirits — they don't see, don't burn.
        try {
            local f = actor.getFlags();
            if (f.has("undead") || f.has("spirit")) return;
        } catch (e) {}

        // 1. Blindness — skip if actor wears a real helm.
        if (!this._hasRealHelm(actor)) {
            this._applyBlindnessStack(actor);
        }

        // 2. 5 burning damage through the damage pipeline.
        this._applyBurnDamage(actor, 5);
    }

    // Asymmetric helm thresholds (user spec 2026-05-02, refined post-survey):
    //   Players (Faction.Player) need ≥175 — a single great helm (175) clears
    //     the bar. Comfortable for any full-plate brother.
    //   Enemies (anyone else) need ≥200 — most armored enemy kits hit ~125-140
    //     median, so rank-and-file get blinded even in mid-armor. Boss-tier
    //     stacked-helm loadouts (Orc Elite ~280, legendary stacked 300+)
    //     ride out the storm. Standard enemy great helm (175) is a hair under
    //     the bar — by design, players' prepared brothers outlast the rabble.
    //   25-point gap (vs the original 125-point gap) keeps player advantage
    //     without making the storm a no-op for enemies.
    function _hasRealHelm(_actor) {
        try {
            local items = _actor.getItems();
            if (items == null) return false;
            local head = items.getItemAtSlot(::Const.ItemSlot.Head);
            if (head == null) return false;
            local dura = 0;
            try { dura = head.getArmorMax(); } catch (e) {}
            if (dura == 0) {
                try { dura = head.getConditionMax(); } catch (e) {}
            }
            local threshold = 200;
            try {
                if (_actor.getFaction() == ::Const.Faction.Player) threshold = 175;
            } catch (e) {}
            return dura >= threshold;
        } catch (e) {}
        return false;
    }

    function _applyBlindnessStack(_actor) {
        // Prefer FoTN's stacking blindness if the mod is loaded. Signature:
        // ::FOTN.applyBlindness(_attacker, _target, _stacks). Pass the actor
        // as both attacker + target — environmental damage with no caster.
        if ("FOTN" in ::getroottable() && "applyBlindness" in ::FOTN) {
            try { ::FOTN.applyBlindness(_actor, _actor, 1); return; } catch (e) {}
        }
        // Fallback: GT's golden_blinded_effect (used by Solar Ascension).
        try {
            if (_actor.getSkills().getSkillByID("effects.golden_blinded") == null) {
                _actor.getSkills().add(::new("scripts/skills/effects/golden_blinded_effect"));
            }
        } catch (e) {}
    }

    function _applyBurnDamage(_actor, _dmg) {
        try {
            local hitInfo = clone ::Const.Tactical.HitInfo;
            hitInfo.DamageRegular      = _dmg;
            hitInfo.DamageDirect       = 1.0;  // ignores armor
            hitInfo.DamageType         = ::Const.Damage.DamageType.Burning;
            hitInfo.BodyPart           = ::Const.BodyPart.Body;
            hitInfo.BodyDamageMult     = 1.0;
            hitInfo.FatalityChanceMult = 0.5;
            // Pass null attacker — environmental damage. Most damage hooks
            // null-guard the attacker, but wrap in try/catch as belt-and-
            // suspenders for any third-party hook that doesn't.
            _actor.onDamageReceived(null, this, hitInfo);
        } catch (e) {
            // Pipeline hook threw on null attacker. Fallback: direct HP
            // subtract, floored at 1 (don't kill via env damage cleanup).
            try {
                local hp = _actor.getHitpoints();
                _actor.setHitpoints(::Math.max(1, hp - _dmg));
            } catch (e2) {}
        }
    }
});
