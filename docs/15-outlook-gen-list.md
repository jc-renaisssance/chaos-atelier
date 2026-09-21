# Outlook gen list — construction × synergy

Jonathan lock (2026-09-21): image gen produces **combination outcomes** per **construction × synergy**. Plain/default color when no outlook synergy. Each synergy — **positive and negative** — has an **order**; the finished garment uses **only the highest-order** synergy’s look.

**No gens until** Finance stamps a Phase-1 gen ask against this list. This doc is the contract.

## Rules

1. Base asset per construction: `look_{con}_plain` (default palette / no synergy chrome).
2. One asset per `(construction, outlook_synergy)` that Design marks **gen-ready**.
3. Runtime: pick the fired synergy with max `outlook_order` (negatives included); if none → plain.
4. Named uniques (`outlook_order=200`) may use a dedicated asset later; Phase-1 can fall back to their dominant tag look.
5. **Shop owner** outlooks are separate assets (`shop_{owner}`) — see `docs/16-shop-owners.md`; Phase-1 = `shop_basic` only.

## Outlook synergies (from `14`) — order ascending for scan; highest wins at runtime

| outlook_id | syn id | order | polarity |
|---|---|---:|---|
| `plain` | — | 0 | — |
| `silk_2` | `syn_silk_2` | 10 | + |
| `soft_2` | `syn_soft_2` | 12 | + |
| `temper` | `syn_fire_frost_clash` | 15 | + |
| `earth_2` | `syn_earth_2` | 20 | + |
| `greenmail` | `syn_wild_earth` | 22 | + |
| `earth_3` | `syn_earth_3` | 25 | + |
| `metal_2` | `syn_metal_2` | 30 | + |
| `neg_metal_silk` | `syn_neg_metal_silk` | 31 | − |
| `metal_3` | `syn_metal_3` | 32 | + |
| `neg_hood_metal` | `syn_neg_hood_metal` | 33 | − |
| `neg_cloak_metal` | `syn_neg_cloak_metal` | 34 | − |
| `silent_2` | `syn_silent_2` | 35 | + |
| `neg_metal_silent` | `syn_neg_metal_silent` | 38 | − |
| `sticky_2` | `syn_sticky_2` | 40 | + |
| `neg_soft_sharp` | `syn_neg_soft_sharp` | 42 | − |
| `sharp_2` | `syn_sharp_2` | 45 | + |
| `snaretooth` | `syn_sticky_sharp` | 48 | + |
| `frost_2` | `syn_frost_2` | 50 | + |
| `storm_2` | `syn_storm_2` | 55 | + |
| `wild_2` | `syn_wild_2` | 60 | + |
| `pure_2` | `syn_pure_2` | 65 | + |
| `royal_2` | `syn_royal_2` | 70 | + |
| `neg_sticky_royal` | `syn_neg_sticky_royal` | 71 | − |
| `masked_crown` | `syn_royal_silent` | 72 | + |
| `solar_2` | `syn_solar_2` | 75 | + |
| `dawn` | `syn_solar_pure` | 78 | + |
| `lunar_2` | `syn_lunar_2` | 80 | + |
| `occult_2` | `syn_occult_2` | 85 | + |
| `neg_occult_pure` | `syn_neg_occult_pure` | 86 | − |
| `pale_hex` | `syn_lunar_occult` | 88 | + |
| `fire_2` | `syn_fire_2` | 90 | + |
| `neg_fire_soft` | `syn_neg_fire_soft` | 95 | − |
| `fire_3` | `syn_fire_3` | 100 | + |

## Full matrix size (garment outlooks)

| constructions | outlook rows (incl. plain + negs) | cells |
|---:|---:|---:|
| 12 | 34 | **408** |

Do **not** gen all 408 in Phase-1.

## Phase-1 gen batch (starter modular set) — still **50**

Constructions: `armor`, `robe`, `cloak`, `coat`, `tunic` (5).

Outlooks: `plain`, `metal_2`, `metal_3`, `earth_2`, `earth_3`, `fire_2`, `silent_2`, `royal_2`, `silk_2`, `frost_2` (10).

→ **50** garment assets. **Negative outlook assets** and multi-owner shop art = **Later** (Finance: keep first ask at 50 + `shop_basic` only).

Optional +1: `shop_own_basic` (one shop chrome). Count separately from the 50 if stamped.

### Explicit combo ids (Phase-1 batch)

Format: `look_{con}_{outlook}`

**armor:** `look_armor_plain`, `look_armor_metal_2`, `look_armor_metal_3`, `look_armor_earth_2`, `look_armor_earth_3`, `look_armor_fire_2`, `look_armor_silent_2`, `look_armor_royal_2`, `look_armor_silk_2`, `look_armor_frost_2`

**robe:** `look_robe_plain`, `look_robe_metal_2`, `look_robe_metal_3`, `look_robe_earth_2`, `look_robe_earth_3`, `look_robe_fire_2`, `look_robe_silent_2`, `look_robe_royal_2`, `look_robe_silk_2`, `look_robe_frost_2`

**cloak:** `look_cloak_plain`, `look_cloak_metal_2`, `look_cloak_metal_3`, `look_cloak_earth_2`, `look_cloak_earth_3`, `look_cloak_fire_2`, `look_cloak_silent_2`, `look_cloak_royal_2`, `look_cloak_silk_2`, `look_cloak_frost_2`

**coat:** `look_coat_plain`, `look_coat_metal_2`, `look_coat_metal_3`, `look_coat_earth_2`, `look_coat_earth_3`, `look_coat_fire_2`, `look_coat_silent_2`, `look_coat_royal_2`, `look_coat_silk_2`, `look_coat_frost_2`

**tunic:** `look_tunic_plain`, `look_tunic_metal_2`, `look_tunic_metal_3`, `look_tunic_earth_2`, `look_tunic_earth_3`, `look_tunic_fire_2`, `look_tunic_silent_2`, `look_tunic_royal_2`, `look_tunic_silk_2`, `look_tunic_frost_2`

Until neg outlook assets exist, runtime may fall back: if winner is a `neg_*` with no asset, use nearest positive look or `plain` — Client placeholder OK.

## Later batches (park until stamped)

- Negative outlooks × Phase-1 constructions (e.g. `look_cloak_neg_cloak_metal`, `look_*_neg_fire_soft`)
- Remaining constructions × outlooks
- Remaining positive outlooks (`storm_2`, `wild_2`, `occult_2`, …)
- Unique overrides (`uniq_*` @ 200)
- Shop owners beyond `own_basic` (`shop_own_voodoo`, `shop_own_tech`, skill shops, …)

## Harness stamp fields (for Test)

Every dump should include: `construction`, `material_ids[]`, `tag_counts`, `powers_fired[]` (pos+neg), `outlook_id`, `outlook_order`, `shop_owner_id` (when shops multi-owner).
