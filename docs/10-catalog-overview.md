# Catalog overview

Status: Design draft + 1A/flow locks (Jonathan 2026-09-21 → 09-22).

## Schema (data-first)

```
Craft =
  1 Construction                         # compulsory
  + 1..max_materials Materials           # default max=2; skills/staff raise
  + 0..max_runes Enchantments            # default max=1

Final gear:
  stats  = Σ(Material.stats) + Construction + Σ(Rune.stats)
  tags   = bag-count(all layers)
  rarity = compute_rarity(...)           # 18
  powers = resolve(tag_counts, construction_id, rarity)  # 14 — neg skipped if rare/leg
  outlook = highest outlook_order among fired rows (neg can win)
```

See **[12b-craft-slots](12b-craft-slots.md)** for caps. One resolver — `14`.

## Primary stats

| Stat | Code | Meaning |
|---|---|---|
| Hit Points soak | `HP` | Punishment before ruin |
| Attack aid | `ATK` | Offensive checks / damage aid % |
| Defense | `DEF` | Physical soak |
| Resist | `RES` | Elemental / magic / weather |
| Mobility | `MOB` | Escape / footing |
| Presence | `PRE` | Social / royal |

## Tag vocabulary

Fire · Frost · Storm · Earth · Lunar · Solar · Royal · Silent · Sticky · Sharp · Soft · Wild · Occult · Pure · Metal · Silk — details in materials / synergies docs.

## Run structure (pointer)

- Boss pools 3×3 → 27 paths: `17`
- Missions before boss: `22`
- Mission report + letter: `23`
- App pseudocode: `21`

## ID conventions

`mat_*` · `con_*` · `enc_*` · `syn_*` / `syn_neg_*` · `uniq_*` · `boss_*` · `cli_*` · `evt_*` · `look_*`
