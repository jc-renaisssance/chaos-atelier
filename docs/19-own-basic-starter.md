# `own_basic` starter deck + shop weights

Phase-1 player clothier = **`own_basic`** only (see `16-shop-owners.md`).

## Starter deck (run start)

> **Replaced in flight — [38](38-starter-deck.md).** The eight rows below were written as a fixed hand. Jonathan (2026-10-27): the starter deck composition is tagged mats / no-tag mats / skills at about **3 / 4 / 3**, and the hand of **5** is a draw from that deck. Soft’s recommend is the **10-card** starter deck in `38`, which replaces this list. Bought cards join that same deck. The rows stay as the record until letter B is stamped. Shop weights further down stay the offer table.

**Historical list — 8 mats:**

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

> **M1 route-node market is not this roll.** Live visit = chapter-shared `market_bank_c1` + shelf draw + refresh + **material enchant** — **[32](32-shop-and-events.md)** (display Market; wire `kind=shop`). **M2** adds Staffs / Skills / Gear tabs on that shell. This table stays **owner-pool / Later weights** (other owners, forbidden rooms). Do not implement the roll-5 as the C1 market.

Each shop visit **used to** roll **5** material offers from the weighted table (replacement). Prices = material `$` from `11`.

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

**M1 live ([32](32-shop-and-events.md)):** **⌊$ / 2⌋**, **min 1** (including $1 scraps). Soft floor **≥ 3** material cards after sell. **Supersedes** the draft below for route-node shops.

Historical draft (not live): sell owned mats for **⌊$ / 2⌋** gold (min 1 if $ ≥ 2, else 0 for $1 scraps).

## Harness note

Stamp `starter_deck_hash` or explicit `material_ids` at run start; shop rolls may be seeded for Mid/Mid smoke.

Starter tags on these mats: **Soft, Earth, Metal, Wild, Silk, Pure**. C1 bosses may still be approachable on those staples. **C2 / C3 de-favor them** — punish Soft / Earth / Metal / Wild / Silk / Pure and/or favor tags outside this set (`17`). That de-favor sentence stays. Which of these tags the M2 starter deck feeds, and which rows `own_basic` may buy, is [38](38-starter-deck.md).
