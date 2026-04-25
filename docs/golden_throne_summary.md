# The Golden Throne

The Golden Throne is a custom scenario where you play the reawakened Emperor of the old world in a plague-struck land. Your party starts wildly overpowered and grows into full divine casting by level 35. The campaign is win-or-lose — if the Emperor dies and no resurrection is left, the run ends.

## The Emperor

Your origin character starts with 90 HP, 80 Stamina, 75 Melee Skill, 15 MD, 90 Bravery. Talent stars in HP, MS, and Bravery. Comes with Battle Forged, Inspiring Presence, Steel Brow, Colossus, Rally the Troops, Indomitable, and Overwhelm already picked. Permanent traits: Tough, Talented, Petals Must Fall. Has access to 23 perk trees — every weapon tree, every Legends class tree, plus Imperial and faith-themed ones. Past level 12, he picks up an extra perk point every three levels.

## Imperial Aura

Passive aura around the Emperor. Base range is 10 tiles. Allies inside get +10 Resolve, +5 MD, +5 RD. Enemies inside can't rise as undead. Hidden enemies in the aura get revealed once you unlock Purge tier 1.

## Consecration

Every melee skill the Emperor uses applies a divine bleed to the target. 1H weapons are 10-20 dmg/turn for 3 turns. 2H weapons are 18-35 dmg/turn for 3 turns. Ranged skills don't consecrate.

## Tier Powers

Unlock at Emperor level — one per milestone, automatic on level-up:

- **L5 — Pillar of Light** — AoE smite, 2-tile radius. 35-65 holy damage. More damaging against undead, beast, monstrous. 3-turn cooldown.
- **L10 — Golden Command** — target an ally to restore them to full AP and 50 fatigue. Once per battle.
- **L15 — Radiant Judgement** — single-target smite. 60-110 holy damage, double against undead / beast / monstrous. 2-turn cooldown.
- **L20 — Solar Ascension** — once per campaign. Revives every fallen ally at 50% HP and blinds every sighted enemy for 2 turns.
- **L35 — Ascended Sovereign** — permanent capstone. Adds Dawn's Rebirth (once per battle: heal every ally within 15 tiles for 30% max HP) and +5 tiles to your aura.

## One Resurrection

The Emperor survives the first fatal injury once per campaign. After that, vulnerable like any brother. If the Emperor dies and the resurrection is already spent, the campaign ends.

## Purge Meter

Killing unholy enemies (undead / beast / monstrous) builds Purge charges. Four tiers give permanent utility upgrades, not raw stats:

- **25 — Farseer** — hidden enemies in the aura are revealed.
- **100 — Frozen Consecration** — consecration staggers the target on apply.
- **250 — Martyr's Light** — when an ally dies inside the aura, the Emperor heals for the ally's level.
- **500 — Expanded Presence** — aura range +1 permanently. Stacks with Ascended Sovereign.

## Golden Knights

Active summon skill. Once per battle. Spawns 1 or 2 Golden Knights on adjacent empty tiles depending on space. Stats bracket-scale with Emperor level:

- levels 1-4: 1x
- levels 5-14: 1.5x
- levels 15-24: 3.5x
- levels 25+: 5x

Each knight rolls one of six mutations at spawn: Ironclad / Wrath / Stalwart / Zealous / Swift / Sovereign. If you're running PoV, there's a 40% chance to stack a PoV mutagen on top. Knights are guests — they don't show up in post-battle screens, don't level up, and drop no loot when they despawn.

## Brother Progression

Every bro you hire gets four traits on spawn.

**Divine Mandate.** 6-tier xp kill progression. The progression is automatic and based on kill thresholds. Tiers: Untested → Initiate → Devoted → Consecrated → Exalted → Saint of the Throne. Day/night modifier affects lower tier bros while 4+ don't care about it. At tier 3 the bro earns the Golden Brand.

**Golden Brand.** Passive bonuses: +30% HP, -20% fatigue, +10 MD vs adjacent. No wages, still eats food. Three combat abilities:

- **Holy Wrath** — take damage to obtain a stack (cap 5). Each stack is +3 MS and +3% damage on next hit.
- **Martyr's Fury** — ally dies within 5 tiles for instant +3 Wrath stacks.
- **Sacred Smite** — every melee hit consecrates the target. 1H is 8-20 dmg/turn for 3 turns, 2H is 15-30/turn for 3 turns. More damaging against undead, beast, monstrous.

Tier 3 visual: golden wings on the bro's back, gold eyes.

**Oath of the Throne.** Random roll on hire, permanent. One of three:

- **Steel** — +8 MS, +10% melee damage, +1 AP.
- **Stone** — +15% armor both slots, +8 MD, +8 RD, -10% damage received.
- **Light** — +15 Resolve, halved morale-effect, +20% damage against undead.

**Emperor's Chosen.** 4-tier fight-count progression: Sworn (0) → Battle-Tested (25) → Veteran (75) → Exemplar (150). Once sworn, the bro can never rout. Tier bumps add HP, MS, armor, MD, Resolve, and eventually full morale immunity.

**The Undying Compact.** Awarded at level 20. One-shot resurrection — the bro survives the first fatal injury of their career.

## Partner Quest Chain

Day 80+ with enough renown triggers a rumor of a name from the Emperor's past. At renown 750+ you arrive at a shrine to reckon with what your beloved has become. Three outcomes roll stat-weighted:

- **Bring Back** — the partner joins your company as a new brother.
- **Put to Rest** — the Emperor gains a new permanent trait.
- **Shade (middle)** — a named sword with linked lore drops into the stash.

## Endgame

After all 19 floors of the Usurper Castle are cleared, a post-victory "reclaim the throne" finale fires.

## Starting resources

500 gold, 300 armor parts, 200 medicine, 200 ammo, +150 renown, +20 stash slots. Difficulty 4 (hardest). ChaosPlagueChance 20, RavenMarkChance 3. Starting party is one crusader, two paladins, and a monk — all already carrying Mandate + Oath + Chosen.

## Variants

- **Main** — the standard Golden Throne.
- **Lewd Edition** — same mod, plus an Imperial Charisma hook that ties into four mod_lewd perks on the Emperor's existing milestones. Same mod ID, so install one or the other, never both.

## Requires

Modern Hooks + stdlib + MSU + Legends + ROTU Core Inn. FoTN / PoV / MC / Magic Concept / FB ROTU / MWU all optional — the scenario degrades gracefully when any are missing. v2.8.0 adds a snow weather system that rolls on snow-terrain fights.
