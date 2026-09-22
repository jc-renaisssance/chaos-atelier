# `own_basic` starter deck + shop weights

Phase-1 player clothier = **`own_basic`** only (see `16-shop-owners.md`).

## Starter deck (run start)

Fixed hand — 8 cards:

| mat id | qty | Notes |
|---|---:|---|
| `mat_hemp_plain` | 2 | Soft baseline |
| `mat_cotton_spring` | 1 | Soft, Pure |
| `mat_leather_tan` | 1 | Wild |
| `mat_wool_grey` | 1 | Soft, Earth |
| `mat_iron_scrap` | 1 | Metal |
| `mat_stone_shard` | 1 | Earth, Metal — stack staple |
| `mat_silk_pale` | 1 | Silk |

Starting gold (draft): **12**.
Starting constructions unlocked: `con_tunic`, `con_cloak`, `con_armor`, `con_robe`, `con_coat` (matches Phase-1 outlook batch).
Starting enchantments unlocked: none in hand; shop may sell common runes (`enc_rune_*` $2 only) at low weight.

## Atelier shop — `own_basic` pool weights

Each shop visit rolls **5** material offers from the weighted table (replacement). Prices = material `$` from `11`.

| mat id | weight | Family |
|---|---:|---|
| `mat_hemp_plain` | 10 | Cloth |
| `mat_cotton_spring` | 8 | Cloth |
| `mat_wool_grey` | 8 | Cloth |
| `mat_leather_tan` | 8 | Leather |
| `mat_iron_scrap` | 8 | Metal |
| `mat_stone_shard` | 8 | Stone |
| `mat_clayweave` | 6 | Stone |
| `mat_silk_pale` | 5 | Silk |
| `mat_leather_dusk` | 4 | Leather |
| `mat_linen_storm` | 4 | Cloth |
| `mat_bronze_scale` | 4 | Metal |
| `mat_wirecloth` | 3 | Metal |
| `mat_milkfleece` | 3 | Cloth |
| `mat_tar_thread` | 3 | Odd |
| `mat_ember_silk` | 2 | Silk |
| `mat_frostwool` | 2 | Cloth |
| `mat_ivy_cord` | 2 | Odd |
| `mat_whisper_gauze` | 2 | Cloth |
| `mat_velvet_court` | 1 | Silk |
| `mat_steel_plate` | 1 | Metal |
| `mat_stonefiber` | 1 | Stone |

**Excluded from `own_basic` shop** (other owners Later): $5 forbidden, sci‑fi stubs, voodoo skins (`lizard` / `frog` / …), `mat_grave_silk`, `mat_null_ink_cloth`, `mat_silver_moth`, `mat_skybone_weave`, `mat_skyiron_filigree`, sigils ($5 enc).

### Enchantment offers (optional 6th slot, 40% chance)

| enc id | weight |
|---|---:|
| any `enc_rune_*` with $ = 2 | 10 each |
| `enc_rune_moon` / `sun` / `beast` / `crown` / `ward` ($3) | 3 each |
| $4–5 enc / sigils | **0** in Phase-1 basic |

### Sell-back

Player may sell owned mats for **⌊$ / 2⌋** gold (min 1 if $ ≥ 2, else 0 for $1 scraps — draft).

## Harness note

Stamp `starter_deck_hash` or explicit `material_ids` at run start; shop rolls may be seeded for Mid/Mid smoke.
