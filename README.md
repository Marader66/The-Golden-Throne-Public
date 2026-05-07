# The Golden Throne

A custom Battle Brothers scenario where you play the reawakened Emperor of the old world — a divine warrior-king dragged out of his tomb into a plague-struck age. Your party starts wildly overpowered and grows into full divine casting by level 35. The campaign is win-or-lose: if the Emperor falls a second time, the run ends.

## Install

Grab the latest zip from the [Releases page](https://github.com/Marader66/The-Golden-Throne-Public/releases) and drop it into your Battle Brothers `data/` folder. No extraction needed.

Two editions ship with every release:

- **Main edition** — `zmod_golden_throne_<version>_INN.zip`. The standard build. Pick this unless you specifically want the Lewd-mod-gated Imperial Charisma perks.
- **Lewd Edition** — `zmod_golden_throne_<version>_LEWD.zip`. Same scenario, plus four `mod_lewd` perks granted on the Emperor's existing milestone unlocks.

Both editions register as the same mod ID. **Install one or the other, never both.**

## Required mods

| Mod | Minimum version |
|-----|-----------------|
| Modern Hooks | 0.6.0 |
| stdlib | 2.5 |
| MSU | 1.8.0 |
| Legends | 19.3.18 |
| ROTU Core | 2.1.2 |

**Battle Brothers DLC:** Legends needs the main DLC to run — Beasts & Exploration, Warriors of the North, Blazing Deserts, and Of Flesh and Faith. The Lindwurm Support Edition is recommended but not strictly required. The Golden Throne itself doesn't gate content on any specific DLC.

**Optional integrations** (all soft-detected, no hard requires):
- **Fury of the Northmen (FoTN)** — adds the Swordmaster perk tree to the Emperor; layers gender-paired endgame perks on the Bring Back partner.
- **Path of the Vattghern (PoV)** — 40% chance of a base mutagen on each Golden Knight summon; 100% mutagen on the Bring Back partner.
- **Magic Concept (MC)** — Emperor's Faith / Immortal trees integrate with MC's spell pipeline.
- **Cinderwatch** — if both are installed, GT spawns a 5th brother (the Cinderwarden) as a test wire-in.
- **mod_lewd** — Lewd Edition only, adds Imperial Charisma perks on the Emperor's existing milestones.

---

## What's in it

### The Emperor

Pre-built origin character. **HP 90 / Stamina 80 / MS 75 / RS 20 / MD 15 / RD 10 / Bravery 90 / Init 60** with 3-star talents in HP, MS, Bravery. Comes with Battle Forged, Inspiring Presence, Steel Brow, Colossus, Rally the Troops, Indomitable, and Overwhelm already picked. Permanent traits: Tough, Talented, **Petals Must Fall** (-50% melee skill, +50% melee damage, 100% stagger-on-miss with 2H — built to make him a decisive front-line lever, not a 1-tile shredder).

Access to **23 perk trees** — every weapon class, every Legends class tree the Emperor canonically reaches for, plus the trait + enemy-knowledge trees that reinforce his identity. Past level 12 he picks up an extra perk point every three levels.

Player chooses gender at scenario start — male **Emperor** or female **Empress**. Both have identical mechanics; voice / body / sprite swap on the Empress branch with custom background art.

### Imperial Aura

Passive 10-tile aura. Allies inside get +10 Resolve, +5 MD, +5 RD. Undead enemies inside can't rise as corpses. Hidden enemies in the aura are revealed at Purge tier I.

### Tier Powers

Unlock automatically on Emperor level:

- **L5 — Pillar of Light.** AoE smite (2-tile radius), 35-65 holy damage, +50% vs undead / beast / monstrous. 3-turn cooldown.
- **L10 — Golden Command.** Target an ally to fully restore their AP and 50 fatigue. Once per battle.
- **L15 — Radiant Judgement.** Single-target, 60-110 holy damage, ×2 vs undead / beast / monstrous. 2-turn cooldown.
- **L20 — Solar Ascension.** **Once per campaign.** Revives every fallen ally at 50% HP, refreshes every living ally (full AP, zero fatigue, all cooldowns reset, including the Emperor's own), blinds every sighted enemy.
- **L35 — Ascended Sovereign.** Permanent capstone. Adds **Dawn's Rebirth** (once-per-battle, heal every ally within 15 tiles for 30% max HP) and +5 tiles to the Imperial Aura.

### Purge Meter

Killing unholy enemies (undead / beast / monstrous) builds Purge charges. Four tiers — utility upgrades, not stat bumps:

- 25 — **Farseer.** Hidden enemies in the aura auto-reveal.
- 100 — **Frozen Consecration.** Consecration also stacks Stagger.
- 250 — **Martyr's Light.** Allies dying inside the aura heal the Emperor for their level.
- 500 — **Expanded Presence.** Aura range +1 permanently.

### Golden Knights summon

Active skill on the Emperor. Once per battle. Spawns 1-2 ghost knights on adjacent empty tiles. Stats bracket-scale with Emperor level (×1.0 → ×5.0 from L1 to L25+). Each rolls one of six mutations. Knights are guests — don't show in post-battle screens, drop no loot, don't appear in the obituary.

### Brother progression — every hire gets four traits

- **Divine Mandate.** 6-tier kill-XP ladder (Untested → Saint of the Throne). Lower tiers care about day/night; tier 4+ transcends. At tier 3, the brother earns the **Golden Brand** — +30% HP, -20% fatigue, +10 MD vs adjacent, plus three combat layers (Holy Wrath stacks on damage taken, Martyr's Fury stacks on adjacent ally death, Sacred Smite consecrates every melee hit).
- **Oath of the Throne.** Random of **8 oaths** at hire — Steel, Stone, Light, Fists, Vigilance, Defiance, Fury, Faith. Each oath scales with the brother's Mandate tier, so an Exalted brother's oath hits harder than an Initiate's. Oath examples: *Fists* triggers when both hands are empty (+25% damage, +20% direct damage, +20% armour penetration); *Vigilance* grants a per-turn dodge charge while not surrounded; *Faith* doubles the Imperial Aura's benefits while you stand inside it.
- **Emperor's Chosen.** 4-tier fight-count ladder (Sworn → Battle-Tested → Veteran → Exemplar). Cannot rout from the moment sworn. Stat bumps and full morale immunity at tier 3.
- **Undying Compact.** Awarded at level 20. One-shot resurrection per career.

### Partner Quest Chain (Day 80+)

Three-beat narrative arc — the Emperor remembers a name from before his long sleep. Beat 1 (rumor) at Day 80+; Beat 2 (arrival) at Renown 750+; Beat 3 (resolution) rolls one of three weighted outcomes:

- **Bring Back.** The partner joins the company as a Saint-tier brother — Mandate tier 6, Light Oath, Chosen tier 3, the_beloved_trait, beloved_presence_aura that buffs the Emperor specifically. Equipped with gender-paired endgame loadout including the Light Countenance gold-mask helm, Emperor's Armor, and the named sword Dawn's Edge.
- **Put to Rest.** Emperor gains the resolved_trait (+15 Resolve, +10 Initiative, +10% damage vs undead). +1000 gold, +100 renown. The named sword Mourningsteel drops to stash.
- **Shade.** Emperor gains the memory_burden_trait. +300 gold, **−50 renown**. The named sword The Still-Known Blade drops to stash.

The roll is nudged by Beat 1 choice, by Mandate-tier-3+ brothers in roster, by Brand-holders, and by the Emperor's Purge Count.

### Pyramid Arc (post-Usurper)

A four-event chain unlocking after the main Usurper questline is dealt with: **Rumor → Approach → Floor (5-floor pyramid dungeon) → Finale.** Custom Pyramid location appears on the world map. Boss at the bottom is **The Original** — ROTU-champion-tier scaling, miasma aura, multi-phase fight. On victory, Emperor earns the Reclaimer trait and the Powers Spent passive marker.

### Ghost Dog companion chain

Five-event chain (Ruins → Offer → Battle → Betrayal → Farewell) granting a player-allied entity that follows the Emperor on the world map and into combat. Atmospheric and short.

### Weather systems

- **Snow** — on snow / tundra / mountain combat tiles, rolls 35% clear / 30% light / 20% heavy / 15% blizzard. Effects apply to every combatant. Night + Blizzard stacks an additional layer.
- **Sandstorm** — desert-biome counterpart with the same severity split. Nomad enemies are exempt from the stat penalties (narratively they live in the dust) but still see the visual.

### Usurper Castle Finale

Clearing all 19 floors of ROTU's Usurper Castle gates a two-event chain: a "the dead still walk" cleanup bridge if a crisis is active, then **The Throne Reclaimed** — choose to **end the campaign** (credits) or **continue post-story** with all systems still running.

### MSU settings page

Seven user-tunable knobs in the in-game mod-settings UI: Imperial Aura base radius, Purge Tier I-IV thresholds, Oath Mandate-tier scaling intensity, and a verbose-log toggle. Tune the experience to your taste.

---

## For the deep walkthrough

Stat numbers, exact thresholds, the full 8-oath registry with each oath's stat block, weighted-roll formulas, every named-sword variant, and complete starting-resource numbers live in [`docs/golden_throne_summary.md`](docs/golden_throne_summary.md).

## Save compatibility

Save files from version 2.8.0 forward load on this build. Older Golden Throne campaigns from earlier majors aren't supported on this version — start a fresh run.

## Repo layout

- [`scripts/`](scripts/) — Main edition source
- [`gfx/`](gfx/) — Sprite assets used by Main edition
- [`lewd-overlay/`](lewd-overlay/) — Files that diverge for the Lewd Edition (overlaid on top of Main at build time)
- [`docs/`](docs/) — Feature walkthroughs and design notes
- [`CHANGELOG.md`](CHANGELOG.md) — Version history

## License

MIT. See [`LICENSE`](LICENSE).
