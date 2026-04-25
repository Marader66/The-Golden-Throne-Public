# The Golden Throne

A custom Battle Brothers scenario where you play the reawakened Emperor of the old world — a divine warrior-king dragged out of his tomb into a plague-struck age. Your party starts wildly overpowered and grows into full divine casting by level 35. The campaign is win-or-lose: if the Emperor falls a second time, the run ends.

## Install

Grab the latest zip from the [Releases page](https://github.com/Marader66/The-Golden-Throne-Public/releases) and drop it into your Battle Brothers `data/` folder. No extraction needed.

Two editions ship with every release:

- **Main edition** — `zmod_golden_throne_<version>.zip`. The standard build. Pick this unless you specifically want the Lewd-mod-gated Imperial Charisma perks.
- **Lewd Edition** — `zmod_golden_throne_lewd_<version>.zip`. Same scenario, plus four `mod_lewd` perks granted on the Emperor's existing milestone unlocks.

Both editions register as the same mod ID. **Install one or the other, never both.**

## Required mods

| Mod | Minimum version |
|-----|-----------------|
| Modern Hooks | 0.6.0 |
| stdlib | 2.5 |
| MSU | 1.8.0 |
| Legends | 19.3.18 |
| ROTU Core Inn | 2.1.2 |

All Battle Brothers DLC are optional. The scenario uses what's installed and skips what isn't. Beasts & Exploration, Warriors of the North, and Blazing Deserts give the broadest content.

## Full feature list

The short version: the Emperor wakes, the dead rise, and you have until your second death to break the Usurper's hold on the realm. Along the way you unlock divine tier powers at levels 5 / 10 / 15 / 20 / 35, gather a brother roster that progresses through the Mandate / Oath / Chosen / Compact stack, and earn capstone gear from a partner-quest arc and a haunted-ruin event chain.

For the complete walkthrough — the Emperor's kit, tier-power details, Purge meter, Golden Knight summon, brother progression mechanics, partner quest, Spectral Hound chain, endgame Usurper Castle finale, and starting resources — see [`docs/golden_throne_summary.md`](docs/golden_throne_summary.md).

## Save compatibility

Save files from version 2.8.0 forward load on this build. Older Golden Throne campaigns from earlier majors aren't supported on this version — start a fresh run.

## Variants and the mod ID

Both Main and Lewd Edition register as `mod_golden_throne` with the same scenario ID. Battle Brothers won't let you load both at once. The Lewd Edition's only addition over Main is the Imperial Charisma block, which only activates when `mod_lewd` is also installed and registered.

## Repo layout

- [`scripts/`](scripts/) — Main edition source
- [`gfx/`](gfx/) — Sprite assets used by Main edition
- [`lewd-overlay/`](lewd-overlay/) — Files that diverge for the Lewd Edition (overlaid on top of Main at build time)
- [`docs/`](docs/) — Feature walkthroughs and design notes
- [`CHANGELOG.md`](CHANGELOG.md) — Version history

## License

MIT. See [`LICENSE`](LICENSE).
