# Catalog overview

Status: Design draft + 1A/flow locks (Jonathan 2026-09-21 → 09-22).

## Schema (data-first)

```
Craft =
  1 Construction                         # compulsory
  + 1..max_materials Materials           # default max=2; M2 staff_* raise (12b / 32)
  + 0..max_runes Enchantments            # default max=1; M2 staff_* raise

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
- Shared boss-client / job pool: `28`
- M1 named adventurers: `29`
- Interactive-order slices 1–3: `30`
- Dex (profile collection): `31`
- Missions before boss: `22` (route map, `N*` nodes; free `E*` board superseded)
- Market visit + event resolve: `32` (display Market; wire `kind=shop`; M1 materials / **M2** `staff_*` · `sk_*` · `artifact_*` tabs; material enchant `mat_ench_*`; `evt_*` catalog)
- Mission report + letter: `23`
- App pseudocode: `21`

## ID conventions

`mat_*` · `con_*` · `enc_*` (craft runes, `13`) · **`mat_ench_*`** (material enchant on the M1 market tab — [32](32-shop-and-events.md); **not** `enc_*`) · **`staff_*`** (M2 market Staffs tab — [32](32-shop-and-events.md); raises `max_materials` / `max_runes` per `12b`) · **`sk_*`** (owner craft skills, `27`; M2 Skills tab sells these into the `own_basic` kit) · **`artifact_*`** (M2 market Gear tab — owner utility; **not** `gear_*`; crafted garment “gear” below stays the resolver output) · `syn_*` / `syn_neg_*` · `uniq_*` · `boss_*` · `cli_*` · `evt_*` (M1 catalog in `32`; node `ref_id`) · **`N*`** (route-map nodes, `22`; windowed **`E*`** superseded) · `look_*` · `job_*` · `adv_*` · `ord_*` · `appt_*` · `ask_*` (adventurer battle / estimate skill — **new** in `29`; distinct from `sk_*` owner craft skills) · `choice_*` (event picks, `32`)
