# The Golden Throne — Changelog

Mod ID: `mod_golden_throne`
Deliverable: `zmod_golden_throne_<version>.zip` + `zmod_golden_throne_lewd_<version>.zip` (Lewd Edition)

Versions follow semver: **MAJOR.MINOR.PATCH**. Patch = tweaks/fixes, minor = new feature, major = structural overhaul. Source folder name lags the current version by design — it's a working-copy label, not a version number.

Newest first.

---

## 2.8.8 — 2026-04-25

**Hotfix — Spectral Hound failed to spawn.** The ghost dog ally introduced in v2.8.6 inherited from the wrong vanilla parent class, so the game could not load it. Three "failed to load script" errors appeared in the log on every campaign start, and the Spectral Hound never appeared in its event chain. Corrected the inherit path; the hound now spawns as intended.

## 2.8.5 — 2026-04-24

**Dep-check — dropped hard `Hooks.require()` gate.** Matches the 11.9 change across the stack. Deps stay in the table as documentation; nothing blocks load on version mismatch.

## 2.8.4 — 2026-04-24

**Hotfix — dep-check false-positive drift + MSU non-semver warning.** Helper guard updated to match 11.8 / 2.0.7 / 1.3.16 fix. String-equality short-circuit first, then `isSemVer` pre-check before any SemVer call. Silences MSU's warning on non-semver versions and fixes the false "you're older" drift on exact-match versions.

## 2.8.3 — 2026-04-24

**Hotfix — dep-check convention (2.8.2) used wrong mod IDs + wrong getMod contract.** Two bugs in yesterday's 2.8.2 shipping version:

1. `Deps.Required`/`TestedAgainst` used zip filenames as mod IDs. Actual registered IDs differ: `mod_rotucore_inn` → **`mod_ROTUC`**, `mod_fotn` → **`mod_fury_of_the_northmen`**, `mod_Path_of_the_Vattghern` → **`mod_PoV`**.
2. `::Hooks.getMod(id)` throws when the mod isn't registered — it doesn't return null. The `if (mod == null) continue;` guard never ran. Replaced with `if (!::Hooks.hasMod(id)) continue;` before the getMod call.

Combined effect of the two bugs: the `Hooks.queue(">mod_ROTUC", ...)` function threw during checkDeps, skipping scenario registration. Campaigns on 2.8.2 couldn't use the Golden Throne origin. 2.8.3 restores working load + correct drift-detection.

Source folder kept at `zmod_golden_throne_2.8.2/` for this hotfix — will catch up to the folder-tracks-version convention on the next minor bump.

## 2.8.2 — 2026-04-24

**Convention — dependency declaration block.** New `::GoldenThrone.Deps` table in the preload declares hard requires, soft tested-against versions, and a save-compat range. Modern Hooks' native `Hooks.require(...)` gate enforces the hard list (same pattern Jimmy's Tooltips uses in Legends); the soft list logs one info line summarising the stack I tested with, plus one warning per drift the player has. Zero gameplay impact — transparency only. Applied as a shared convention across my four BB mods.

Save-compat: unchanged from 2.8.0. No serialization touches.

## 2.8.1 — 2026-04-24

**Compat bump — ROTU 3.0.2.** No code changes. API audit against ROTU 3.0.2 confirmed all five ROTU entry points we use (`::Mod_ROTU.Scenario`, `ValidOriginIDs`, `Scenario.isRecruitEventEnabled()`, `Mod.ModSettings.getSetting("DifficultyScaling")`, `SecondSpike`) exist in 3.0.2 unchanged. Legends dependency floor implicitly bumped to **19.3.17+** (inherited from ROTU's new minimum). Requires fresh campaign because ROTU 3.0.2 is a full replacement, not a patch.

## 2.6.5 — 2026-04-23

**Fix (partner-event crash):** All 3 partner quest events (`rumor`, `arrival`, `resolution`) were calling `::MSU.Text.replace(...)` — wrong namespace. MSU's actual helper lives at `::MSU.String.replace(...)` (confirmed in `mod_msu-1.8.0/msu/utils/string.nut:8`). Every time any of the 5 call-sites (1 in rumor, 1 in arrival, 3 in resolution) fired, it threw `"the index 'replace' does not exist"`, aborted the event's screen start-function mid-execution. Same class of bug that caused the Cinderwatch Road Shrine loop — screen renders incompletely, event can re-queue, event pool gets gummed up and starves other special events (e.g. skillbook events) from firing.

Kabu's log `greatkabuSkillbookseventsnot firing.html` captured 3 hits at 16:05, 17:15, 17:16 — confirmed the loop behavior, and the filename matches kabu's complaint about skillbook events not firing (starved by the partner rumor's error cycle).

Fix: `::MSU.Text.replace` → `::MSU.String.replace` across all 5 call sites. Zero gameplay change when working correctly; unblocks the partner quest chain + unblocks the event pool for skillbook and other special events.

## 2.6.4 — 2026-04-22

**Feat:** Custom Emperor + Empress background art. Ported from contributor wuxiangjinxing's commit `f9cb867` (landed on `Golden-Throne-v16` while our work was on `cinderwatch-v1`). Two new PNGs in `gfx/ui/backgrounds/`: `background_emperor.png` (golden-laurel portrait) and `background_empress.png` (golden-mask portrait). Default `m.Icon` on `golden_emperor_background` swapped `crusader.png` → `background_emperor.png`.

**Feat:** Empress-branch narrative merge. On the GENDER-screen's Empress path, `setOriginGender(true)` now also swaps the background icon to `background_empress.png` and overrides `m.BackgroundDescription` with the contributor's warrior-princess flavor text: *"Born into the royal family, the princess has been practicing martial arts since childhood…"*. Combines their art + narrative with our player-choice gender flow (v2.6.0 intro screen).

## 2.6.3 — 2026-04-22

**Fix:** `golden_brand.nut:108` onDamageReceived signature was wrong — used `(_attacker, _skill, _hitInfo)` and tried `_hitInfo.DamageRegular`. BB's canonical signature is `(_attacker, _damageHitpoints, _damageArmor)` — three ints. Every Brand-carrier hit threw `"the index 'DamageRegular' does not exist"`, broke the skill-container dispatch mid-iteration, killed AI coroutines (`resuming dead generator` spam), and made combat chunky/unresponsive. Swapped to canonical signature; Holy Wrath stacks now actually build.

## 2.6.2 — 2026-04-22

**Fix:** `golden_brand.nut:27` IconMini was `"active_128_mini"` — a brush that doesn't exist. Every Brand-carrier triggered an "Unknown Brush requested" probe per UI repaint (turn transitions, tooltip hovers, character-screen opens). Thought at first to be the Pillar slowdown; fixed here. Swapped to `status_effect_01_mini` (verified vanilla buff-circle).

## 2.6.1 — 2026-04-22

**Perf:** Pillar of Light particle cost reduction. Was looping the full `HolyFlameParticles` array (3 emitters). Cut to first emitter + Quantity×0.5 + LifeTimeQuantity×0.5. ~60-70% render-cost reduction. Pattern mirrors Legends' `legend_charge_skill.nut:138`.

## 2.6.0 — 2026-04-22

**Feat:** Player-facing gender choice. New `GENDER` screen prepended to the intro event — "I am the Emperor" / "I am the Empress". Female branch invokes `setOriginGender(true)` which finds the `GoldenEmperor`-flagged roster member, sets `actor.m.Gender = 1`, renames to "The Empress", writes `GoldenEmperorIsFemale` world flag. **Caveat:** body sprite reflects BB's roll at spawn time; swapping the sprite post-hoc was out of scope for this version. Mechanically the flip works for pronouns + gender-aware rolls + display name.

## 2.5.8 — 2026-04-22

**Change:** Split into **main + Lewd Edition** variants via overlay pattern. Main source is source of truth; `zmod_golden_throne_lewd_overlay/` holds only files that diverge. Two build scripts. Non-Lewd edits flow main→Lewd automatically; Lewd-only changes live in the overlay.

**Feat (Lewd Edition only):** Imperial Charisma — four mod_lewd perks unlocked by the Emperor's existing milestone ladders:
- Purge I (25 kills) → `perk_lewd_alluring_presence`
- Level 20 (Solar Ascension) → `perk_lewd_conqueror`
- Level 35 (Ascended Sovereign) → `perk_lewd_transcendence`
- Purge IV (500 kills) → `perk_lewd_soul_harvest`

All four gates independent + idempotent. Zero change for players without mod_lewd.

## 2.5.7 — 2026-04-22

**Fix (retreat-safe outcome gate):** Resolution event now keys off `GoldenThronePartnerBossKilled` instead of `...Arrived`. Narrated arrival screen C sets both flags so the two code paths converge.

**Fix (Fallen Partner stack caps):** Added `onTurnStart` override capping Vigor at 5 stacks, Iron Will at 10 stacks — prevents long boss fights from sliding into damage-reduction plateau.

**Fix:** Dropped the `"human"` flag on the Fallen Partner. Sprite-layer appearance comes from `setStartValuesEx` brushes, not the flag. Removed to prevent third-party mods' `getFlags().has("human")` buffs from affecting the boss.

## 2.5.6 — 2026-04-22

**Feat:** Endgame FoTN + PoV integration on the Fallen Partner boss.
- Light variant (Valeria): `perk_fotn_small_target` + `perk_fotn_blinding_speed`
- Heavy variant (Aldric): `perk_fotn_bulwark` + `perk_fotn_stun_resistance`
- Guaranteed PoV base mutagen (100%, vs 40% on rolled summons).

Both paths guarded on their mod loading; FoTN/PoV remain optional.

## 2.5.5 — 2026-04-22

**Change:** Fallen Partner's Heavy perk kit swapped to Legends-native variants where strictly better — `perk_fortified_mind → perk_legend_composure` (stun-immune), `perk_underdog → perk_legend_battleheart` (surround-immune), `perk_brawny → perk_legend_anchor` (stacking stats + stagger-immune while stationary). Dropped defensive `"Mod_ROTU" in getroottable()` guards since ROTU + Legends are declared baseline deps.

## 2.5.4 — 2026-04-22

**Feat:** The Dawn Countenance — custom legendary helm combining `legend_helmet_golden_helm`'s gold-mask sprite with `legend_emperors_countenance`'s mechanics (25% melee reflect) and legendary tier. Used by Valeria (Light variant).

**Feat:** Fallen Partner gender-paired perk kits. Light = dodge/mobility (`dodge`, `nimble`, `pathfinder`, `anticipation`, `legend_quick_step`, `backstabber`, `legend_slaughterer`). Heavy = bulwark (`battle_forged`, `colossus`, `steel_brow`, `indomitable`, `fortified_mind`, `underdog`, `brawny`). The racial already adds `fast_adaption` + `legend_escape_artist` so those aren't in the kit.

## 2.5.3 — 2026-04-22

**Balance:** Fallen Partner base MD 25→35, RD 20→25. Armor swapped to gender-paired Legendary Gold sets — Light (gambeson + Emperor's Armor + cloak / chain_hood + golden_helm) for Valeria, Heavy (+ hauberk_full / + Emperor's Countenance helm) for Aldric. Uses Legends `setUpgrade()` layering. Emperor's Armor applies Dazed on turn start within 2 tiles; Countenance reflects 25% melee back.

## 2.5.2 — 2026-04-22

**Balance:** Fallen Partner boss scaling re-tuned to ROTU **champion** tier (was bigppboss). `_applyROTUScaling` difficulty mult reduced 2→1. Added `_applyROTUChampionPackage`: `rotu_low_champion_racial` skill, IsMiniboss flag, champion_glow red halo, 1.5× XP. Full ROTU champion package.

## 2.5.1 — 2026-04-22

**Balance:** `resolved_trait` re-tuned — morale-penalty reduction dropped as redundant with Emperor's stacked morale immunity; replaced with +10 Initiative + +10% anti-undead damage, Resolve bumped to +15. Fallen Partner boss first scaling pass (bigppboss tier — re-tuned to champion in v2.5.2).

## 2.5.0 — 2026-04-22

**Feat:** **Partner quest chain** — 3-beat narrative arc (Rumor Day 80 → Arrival Renown ≥ 750 → Resolution). Stat-weighted random outcome (Bring Back 40 / Put to Rest 40 / Shade 20, nudged by roster + Purge Count + Beat 1 prayer/mourn choice). 10 new files. Tactical combat stubbed for v2.5.2+ (later became the Fallen Partner boss work above).

## 2.4.4 — 2026-04-21

**Feat:** SwordmasterTree (FoTN-only) conditionally gated in the Emperor's perk list. Golden Throne no longer hard-requires FoTN. Without FoTN, Emperor gets 5 weapon trees instead of 6.

## 2.4.3 — 2026-04-21

**Fix:** Solar Ascension grey-out after use via `m.UsedThisCampaign` instance mirror (world flag alone doesn't trigger skill-bar UI refresh). Mirror re-synced at onCombatStarted.

## 2.4.1 — 2026-04-21

**Change:** Enemy Inspector spun out to its own standalone mod (see `mod_enemy_inspector` CHANGELOG). Golden Throne no longer ships inspector code.

## 2.4.0 — 2026-04-21

**Feat:** Enemy Inspector keybind — hover + press I for a full dossier. Later spun out to standalone mod.

## 2.3.8 — 2026-04-21

**Fix:** FoTN 0.5.43 create-time `BaseProperties.ArmorDamageMult` read throws on named-weapon spawn. Coordinated fix with `zzmod_unified_stack_patch_11.2`. Also: explicit AP gates on Emperor tier powers so BB greys the skill button reliably when Emperor can't afford the cost.

## 2.3.7 — 2026-04-21

**Fix:** Golden Knight tint now covers all 19 Legends armor layer sprites (plate/chain/tabbard/cloak/cloak_front, armor_upgrade_back/back_top/front, helmet_helm/helm_lower/top/top_lower/vanity/vanity_2/vanity_lower). Was only tinting base `armor`/`helmet` — left layered gear uncolored.

## 2.3.6 — 2026-04-21

**Fix (4 bugs from dry run):**
- Aura super-call missing — `golden_emperor_aura.onCombatStarted` didn't call `rotu_mod_aura_abstract.onCombatStarted()`, so turnOnAura never ran, applyOnUpdate never fired. Silent since v1.7.
- Phantom `perk_captain` path (doesn't exist in vanilla or Legends) → swapped to `perk_rally_the_troops`. Affected Emperor scenario perks + Sovereign mutation on Golden Knights.
- Pillar of Light / Radiant Judgement damage — was flooring at 1 HP and bypassing the damage pipeline. Swapped to `onDamageReceived(hitInfo)` with `DamageDirect=1.0` so kills actually land.
- Second Golden Knight spawn-tile fix — 2nd knight could stack on 1st tile when no adjacent empty. Now spawn count matches available tiles.

## 2.3.5 — 2026-04-21

**Change:** Recruit event override re-based on ROTU 2.2.1 — preserves 2.2.1's expanded uncommon/common roster (26 new entries) + new `getIconColored()` UI, layered with our additions (`HasGivenFirstRecruit`, `backgroundExists()`, day-scaled tier weights).

## 2.3.4 — earlier

**Feat:** Knight scaling brackets (1×, 1.5×, 3.5×, 5× by Emperor level). Once-per-battle Summon with `m.UsedThisCombat` flag (was 4-turn CD). Solar Ascension overhaul.

## 2.0 — earlier

Knight stats tuned for layered armor fatigue (Stamina bumped to 175).

## 1.9 — earlier

Knights wear layered Legends armor. IsDroppedAsLoot=false on everything to prevent loot-spill on summon expiry.

## 1.7 — earlier

Purge Meter system — wired effects through aura + background + trait.

## 1.6 — earlier

Emperor tier powers (Pillar, Command, Judgement, Ascension, Sovereign) + Purge Meter framework.

## 1.0 — 2026-04-19

Initial Golden Throne scenario release.

---

Full git log for this mod: `git log --all -- 'zmod_golden_throne_*' 'zmod_golden_throne_lewd_overlay'`.
Known-bug fixes + valid-constants reference: `../CLAUDE.md`.
Current-version mod-specific spec: `./CLAUDE.md`.
