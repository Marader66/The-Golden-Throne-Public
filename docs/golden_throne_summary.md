# The Golden Throne — Full Summary

The Golden Throne is a custom scenario where you play the reawakened Emperor of the old world in a plague-struck land. Your party starts wildly overpowered and grows into full divine casting by level 35. The campaign is win-or-lose — if the Emperor dies and no resurrection is left, the run ends.

This file covers everything the scenario adds. For the install instructions and tone notes, see `README.md`.

---

## The Emperor (origin)

Base stats: **HP 90 / Stamina 80 / MS 75 / RS 20 / MD 15 / RD 10 / Bravery 90 / Init 60.** Talent stars: 3-star HP, MS, Bravery; 2-star Fatigue; 1-star MD.

Comes with seven perks already picked: **Battle Forged, Inspiring Presence, Steel Brow, Colossus, Rally the Troops, Indomitable, Overwhelm.**

Permanent traits on spawn: **Tough, Talented, Petals Must Fall** (see below).

Has access to **23 perk trees** — every weapon class (Sword, Hammer, Axe, Spear, Polearm, plus Swordmaster if FoTN is loaded), the heavy plate / shield / armour discipline trees, every Legends class tree the Emperor canonically reaches for (Longsword, Hammer, Captain Magic, Faith, Immortal), plus the trait trees that reinforce his identity (Indestructible, Inspirational, Fit, Calm, Large, Intelligent, Giant) and the enemy-knowledge trees (Undead, Occult).

Past level 12 he picks up an extra perk point every three levels — small steady reward for long campaigns past the canonical perk-cap.

## Player gender choice

The intro event prepends a **GENDER** screen offering "I am the Emperor" / "I am the Empress." The Empress branch swaps voice pack, body silhouette, hair, and the `GoldenEmperorIsFemale` world flag. The title shifts to "The Empress" but the mechanics are otherwise identical. v2.7.1 fixed a save-load crash on this branch where VoiceSet could land out-of-range; both branches save cleanly now. Custom Empress background art ships in v2.6.4+.

## Imperial Aura

Passive aura around the Emperor. **Base range 10 tiles** (configurable via the MSU settings page). Stacks with Purge tier IV (+1) and Ascended Sovereign (+5).

- **Allies** inside: +10 Resolve, +5 MD, +5 RD.
- **Undead enemies** inside: cannot rise as undead corpses.
- **Hidden enemies** in the aura: revealed once you unlock Purge tier I (Farseer).

## Consecration

Every melee skill the Emperor uses applies a divine bleed to the target via Legends's `legend_consecrated_effect`.

- 1H weapons: 10-20 damage per turn for 3 turns.
- 2H weapons: 18-35 damage per turn for 3 turns.
- Ranged skills don't consecrate.
- At Purge tier II (Frozen Consecration), every consecration also stacks Stagger on the target.

## Petals Must Fall

Permanent Emperor trait. Hard discipline trade:
- `MeleeSkillMult ×0.5` (Emperor swings at half melee skill).
- `MeleeDamageMult ×1.5` (when he hits, hits hard).
- On a 2H melee miss: 100% chance to apply Stagger to the target.

Designed to make the Emperor a rare-but-decisive front-line lever rather than a 1-tile shredder. Pairs with Pillar of Light + Radiant Judgement when MS misses are biting.

## Tier Powers

Unlock automatically on Emperor level — one per milestone:

- **L5 — Pillar of Light.** AoE smite, 2-tile radius. 35-65 holy damage, +50% vs undead / beast / monstrous. Damage routes through `onDamageReceived` so kills trigger death properly. 8 AP / 30 fatigue / 3-turn cooldown.
- **L10 — Golden Command.** Target an ally to restore them to full AP and 50 fatigue. 4 AP / 20 fatigue. Once per battle.
- **L15 — Radiant Judgement.** Single-target smite. 60-110 holy damage, ×2 vs undead / beast / monstrous. 6 AP / 25 fatigue / 2-turn cooldown.
- **L20 — Solar Ascension.** **Once per campaign.** Revives every fallen ally at 50% HP, refreshes every living ally (full AP, zero fatigue, all active-skill cooldowns reset, including the Emperor's own), and blinds every sighted enemy for 2 turns (FoTN's blindness if loaded, custom fallback otherwise — skeletons + spirits skip the blind). 9 AP / 50 fatigue.
- **L35 — Ascended Sovereign.** Permanent capstone trait. Adds **Dawn's Rebirth** (once-per-battle: heal every ally within 15 tiles for 30% max HP. 6 AP / 30 fatigue) and +5 tiles to the Imperial Aura.

## One Resurrection

The Emperor survives the first fatal injury he takes (modeled via `SurviveWithInjuryChanceMult ×99.0` until the first injury fires). After that, he's vulnerable like any brother. If the Emperor dies and the resurrection is already spent, the campaign ends.

Post-resurrection (i.e., after Ascended Sovereign), the survival multiplier becomes ×10.0 — the Emperor remains harder to kill than his brothers, but no longer literally untouchable.

## Purge Meter

Killing unholy enemies (`undead` / `beast` / `monstrous` flags) builds Purge charges. Four tiers give permanent utility upgrades, not raw stats:

- **25 — Farseer.** Hidden enemies inside the Imperial Aura are revealed automatically.
- **100 — Frozen Consecration.** Consecration also stacks Stagger on the target.
- **250 — Martyr's Light.** When an ally dies inside the Aura, the Emperor heals for that ally's level.
- **500 — Expanded Presence.** Imperial Aura range +1 permanently. Stacks with Ascended Sovereign's +5 (so a fully-built Emperor at L35 + Purge IV runs a 16-tile aura).

The four thresholds are configurable via the MSU settings page.

## Golden Knights

Active summon skill on the Emperor. Once per battle. Spawns 1 or 2 Golden Knights on adjacent empty tiles depending on space available. 6 AP / 40 fatigue.

Stats bracket-scale with Emperor level on a multiplier:
- Levels 1-4: ×1.0
- Levels 5-14: ×1.5
- Levels 15-24: ×3.5
- Levels 25+: ×5.0

Each knight rolls one of six mutations at spawn: **Ironclad / Wrath / Stalwart / Zealous / Swift / Sovereign.** If you're running PoV, there's a 40% chance to additionally stack a PoV mutagen on top.

Knights are guests — they don't show up in post-battle screens, don't level up, drop no loot when they despawn, and don't appear in the Fallen Brothers obituary if they die.

## Brother Progression

Every brother you hire gets four traits on spawn:

### Divine Mandate (6-tier kill-XP ladder)

Automatic, based on cumulative kill XP. Tiers: **Untested → Initiate → Devoted → Consecrated → Exalted → Saint of the Throne.** Lower tiers are affected by day/night modifiers (penalties at night); tier 4+ transcend day/night entirely.

Tier 1+ adds gold glowing eyes; brightness scales with tier.

At tier 3, the brother earns the **Golden Brand**.

The kill-XP thresholds match Davkul's progression numbers in ROTU.

### The Golden Brand (Mandate tier 3 reward)

Earned, not rolled. Permanent passive bonuses: +30% HP, -20% fatigue, +10 MD vs adjacent enemies. No wages (brother still consumes food).

Three combat layers:
- **Holy Wrath.** Taking damage builds stacks (max 5). Each stack = +3 MS + +3% damage on next attack, then resets.
- **Martyr's Fury.** When an ally dies within 5 tiles → instant +3 Wrath stacks.
- **Sacred Smite.** Every melee hit applies consecration. 1H 8-20/turn for 3 turns; 2H 15-30/turn. +50% damage vs undead / beast / monstrous.

Tier 3 visual: golden wings on the brother's quiver layer, gold eyes if Mandate hasn't already provided them.

### Oath of the Throne (random of 8 at hire, permanent)

Each oath scales with the brother's Mandate tier — at higher tiers, the oath grows stronger (the multiplier curve is configurable via MSU's "Oath Mandate-tier scaling intensity" setting; default 1.0 = standard curve).

- **Steel** — +8 MS, +10% melee damage, +1 AP.
- **Stone** — +15% body and head armour, +8 MD, +8 RD, -10% damage received.
- **Light** — +15 Resolve, halved morale-effect, +20% damage vs undead / beast / monstrous.
- **Fists** — while both hands are empty: +25% damage, +20% direct (armour-bypass) damage, +20% armour penetration. No effect when wielding a weapon.
- **Vigilance** — +1 Vision, +5 RS, +10 Initiative, +10 maximum fatigue, immune to friendly fire. At the start of each turn (if not surrounded by 3+ enemies) gains a charge of *Untouchable* — the next attack auto-dodges. At range ≥ 3, +15% damage.
- **Defiance** — immune to Stun and Bleeding, +5 Fatigue Recovery, -10% damage received.
- **Fury** — every time hit, gains a stack (cap 20 in combat, retains up to 10 between combats, decays 1/day). Per stack: +3% damage, -2 MD, -2 RD.
- **Faith** — when standing inside the Imperial Aura, doubles its benefit: +20 Resolve, +10 MD, +10 RD.

### Emperor's Chosen (4-tier fight-count ladder)

**Sworn (0) → Battle-Tested (25) → Veteran (75) → Exemplar (150).** Once sworn, the brother can never rout (`MoraleEffectMult = 0` from the moment of swearing).

- T1 (Battle-Tested): +15 HP, +5 MS.
- T2 (Veteran): +10% armour, +5 MD.
- T3 (Exemplar): +20 Resolve, full morale immunity.

### The Undying Compact

Awarded automatically at level 20 per brother. One-shot resurrection — the brother survives the first fatal injury of their career (modeled via `SurviveWithInjuryChanceMult ×50.0` until spent).

---

## Partner Quest Chain (Day 80+)

Three-beat narrative arc. The Emperor remembers a name from before his long sleep.

- **Beat 1 — Rumor (Day ≥ 80).** Three options nudge the outcome roll: pray (+10 toward Bring Back), mourn (+10 toward Put to Rest), or wait (no nudge).
- **Beat 2 — Arrival (Renown ≥ 750, post-Rumor).** Three-screen arrival narration. Gates Beat 3.
- **Beat 3 — Resolution.** A weighted roll picks one of three outcomes — base 40 Bring Back / 40 Put to Rest / 20 Shade, nudged by the Beat 1 choice, by Mandate-tier-3+ brothers in roster (+3 each toward Bring Back, capped +15), by Brand-holders (+2 each, capped +10), and by Emperor Purge Count (≥100 → +5 toward Put to Rest; ≥250 → +10; ≥500 → +10).

The partner is **Valeria of the Dawn Court** (paired with male Emperor) or **Aldric the Oathsworn** (paired with female Empress).

### Outcome rewards

| Outcome | Grant |
|---|---|
| **Bring Back** | +1 roster brother via the Beloved background. Mandate tier 6 (Saint of the Throne), Light Oath, Chosen tier 3, the_beloved_trait (+25 Resolve, +5 MS, +10 MD/RD, can't rout), beloved_presence_aura (+20 Resolve & +8 MD to Emperor within 6 tiles, +5 Resolve to other allies). Equipped: gender-paired endgame loadout — Light Countenance gold-mask helm + Emperor's Armor + the named sword **Dawn's Edge**. |
| **Put to Rest** | Emperor gains the `resolved_trait` (+15 Resolve, +10 Initiative, +10% damage vs undead). +1000 gold, +100 renown, +50 Purge Count. The named sword **Mourningsteel** drops into the stash. |
| **Shade (middle)** | Emperor gains the `memory_burden_trait` (-5 Initiative, +5 Resolve, +15% damage vs undead). +300 gold, **−50 renown**. The named sword **The Still-Known Blade** drops into the stash. |

The named sword (`named_partner_sword`) is the same base item with a display-name swap per outcome — late-game 2H longsword, 55-80 regular damage, +15% damage / +10% armour damage vs undead.

If you Bring Back, the partner's endgame kit also layers FoTN endgame perks (gender-paired: Valeria gets `perk_fotn_small_target` + `perk_fotn_blinding_speed`; Aldric gets `perk_fotn_bulwark` + `perk_fotn_stun_resistance`) and a guaranteed 100% PoV mutagen.

---

## Pyramid Arc (Phase A — Day 250+, post-finale)

A four-event chain unlocking after the Usurper has been dealt with: **Rumor → Approach → Floor (5-floor pyramid dungeon) → Finale.** Custom Pyramid location appears on the world map. The boss at the bottom is **The Original** — ROTU-champion-tier scaling, gender-paired loot, multi-phase fight (HP-50% phase flip, miasma aura at the boss's tile + 6 adjacent tiles, damage-type resistance pattern).

On boss defeat, the Emperor earns the `golden_reclaimer_trait` (Reclaimer) and the `golden_powers_spent` passive marker (depending on choices made during the floor sequence).

## Ghost Dog companion chain

Five-event chain (Ruins → Offer → Battle → Betrayal → Farewell) that grants a player-allied entity (`golden_ghost_dog_ally`) which follows the Emperor on the world map and into combat. Atmospheric and short — mostly narrative with one combat beat.

## Snow Weather System (v2.8.0)

On every Golden Throne tactical combat, if the world tile is snow / snow hills / tundra / mountains, roll severity:

| Severity | Probability | RS | MS | Init | Vision |
|---|---|---|---|---|---|
| Clear | 35% | — | — | — | — |
| Light | 30% | -3 | — | — | -1 |
| Heavy | 20% | -6 | — | -2 | -2 |
| Blizzard | 15% | -10 | -3 | -4 | -3 |

If Blizzard rolls AND combat starts at night, an additional Night-Blizzard layer stacks on top: -3 RS, -1 Init, -2 Vision (for total -13 RS, -3 MS, -5 Init, -5 Vision).

Effects apply to *every combatant*, ally and enemy. Snow doesn't pick sides. Visuals: snow particles, scaled cloud cover, ambient lighting palette, blizzard sound ambience.

## Sandstorm Weather System

Desert-biome counterpart to snow. Same 35 / 30 / 20 / 15 probability split for clear / light / heavy / full sandstorm. Stat penalties mirror the snow severity ladder but lean more on visibility than initiative. **Nomad enemies** are exempt from the stat penalties — narratively they live in the dust — but still see the visual effect.

## Usurper Castle Finale

Clearing all 19 floors of ROTU's Usurper Castle sets the world flag `GoldenThroneUsurperDown`, which gates two follow-up events:

- **The Host Without Its Master.** Fires only if an undead crisis is active when the Usurper falls. Bridge narrative — the dead still walk, the crown can wait.
- **The Throne Reclaimed.** Fires once the undead crisis (if any) is over. Two options:
  - **End the campaign** — credits roll.
  - **Continue post-story.** All existing systems keep running. Survival / denouement.

## MSU Settings Page

Seven tunable knobs accessible from the in-game mod-settings UI:

- **Imperial Aura base radius** (range 6-15, default 10). Read at combat start.
- **Purge Tier I-IV thresholds** (defaults 25 / 100 / 250 / 500). Read by tier-checks and tooltip "next milestone" text.
- **Oath Mandate-tier scaling intensity** (range 0.0-2.0 in 0.1 steps, default 1.0). Multiplier on the (mult-1.0) delta of every Mandate-tier oath bonus. 0.0 = oaths stay flat across tiers; 2.0 = oaths grow twice as fast with Mandate.
- **Verbose log toggle.**

Settings are read via `::GoldenThrone.getSetting(_key, _default)` with static-default fallback.

## Optional integrations

All soft-detected. Golden Throne runs without any of these; if any are present, you get extra layering:

- **Fury of the Northmen (FoTN).** Adds the SwordmasterTree to the Emperor's perk list. Adds endgame FoTN perks to the Bring Back partner brother.
- **Path of the Vattghern (PoV).** 40% chance for a PoV mutagen on each Golden Knight summon. 100% mutagen on the Bring Back partner.
- **Magic Concept (MC).** Compatible — the Emperor's Faith / Immortal magic trees integrate cleanly with MC's spell pipeline.
- **mod_lewd.** See the Lewd Edition variant — adds four lewd-mod perks across the Emperor's existing milestone unlocks.

## Starting resources

500 gold, 300 armour parts, 200 medicine, 200 ammo, +150 renown, +20 stash slots. Difficulty 4 (hardest). `ChaosPlagueChance = 20`, `RavenMarkChance = 3`. Starting party is one crusader, two paladins, and one monk — all already carrying Mandate + Oath + Chosen on spawn.

If Cinderwatch is also installed, a 5th brother (the Cinderwarden) joins the starting party as a test wire-in.

## Variants

- **Main edition** — `zmod_golden_throne_<version>_INN.zip`. The standard build.
- **Lewd Edition** — `zmod_golden_throne_<version>_LEWD.zip`. Same scenario, plus an Imperial Charisma hook that ties into four `mod_lewd` perks on the Emperor's existing milestones (Purge I, L20, L35, Purge IV). Same mod ID, mutually exclusive — install one or the other, never both.

## Requires

Modern Hooks + stdlib + MSU + Legends + ROTU Core.
