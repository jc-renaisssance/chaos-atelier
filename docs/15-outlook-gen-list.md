# Outlook gen list — construction × synergy

Jonathan lock (2026-09-21): image gen produces **combination outcomes** per **construction × synergy**. Plain/default color when no outlook synergy. Each outlook synergy has an **order**; the finished garment uses **only the highest-order** synergy’s look.

**No gens until** Finance stamps a Phase-1 gen ask against this list. This doc is the contract.

## Rules

1. Base asset per construction: `look_{con}_plain` (default palette / no synergy chrome).
2. One asset per `(construction, outlook_synergy)` that Design marks **gen-ready**.
3. Runtime: pick the fired synergy with max `outlook_order`; if none → plain.
4. Negatives do **not** get outlook assets.
5. Named uniques (`outlook_order=200`) may use a dedicated asset later; Phase-1 can fall back to their dominant tag look.

## Outlook synergies (from `14`) — order descending

| outlook_id | syn id | order |
|---|---|---:|
| `plain` | — | 0 |
| `silk_2` | `syn_silk_2` | 10 |
| `soft_2` | `syn_soft_2` | 12 |
| `earth_2` | `syn_earth_2` | 20 |
| `greenmail` | `syn_wild_earth` | 22 |
| `earth_3` | `syn_earth_3` | 25 |
| `metal_2` | `syn_metal_2` | 30 |
| `metal_3` | `syn_metal_3` | 32 |
| `silent_2` | `syn_silent_2` | 35 |
| `sticky_2` | `syn_sticky_2` | 40 |
| `sharp_2` | `syn_sharp_2` | 45 |
| `snaretooth` | `syn_sticky_sharp` | 48 |
| `frost_2` | `syn_frost_2` | 50 |
| `storm_2` | `syn_storm_2` | 55 |
| `wild_2` | `syn_wild_2` | 60 |
| `pure_2` | `syn_pure_2` | 65 |
| `royal_2` | `syn_royal_2` | 70 |
| `masked_crown` | `syn_royal_silent` | 72 |
| `solar_2` | `syn_solar_2` | 75 |
| `dawn` | `syn_solar_pure` | 78 |
| `lunar_2` | `syn_lunar_2` | 80 |
| `occult_2` | `syn_occult_2` | 85 |
| `pale_hex` | `syn_lunar_occult` | 88 |
| `fire_2` | `syn_fire_2` | 90 |
| `fire_3` | `syn_fire_3` | 100 |

## Full matrix size

| constructions | outlook rows (incl. plain) | cells |
|---:|---:|---:|
| 12 | 26 | **312** |

Do **not** gen all 312 in Phase-1. Use the **Phase-1 batch** below; expand by stamp.

## Phase-1 gen batch (starter modular set)

Constructions: `armor`, `robe`, `cloak`, `coat`, `tunic` (5).

Outlooks: `plain`, `metal_2`, `metal_3`, `earth_2`, `earth_3`, `fire_2`, `silent_2`, `royal_2`, `silk_2`, `frost_2` (10).

→ **50** assets. Matches Finance soft cap headroom (≤100 gens incl. retries / rejects).

### Explicit combo ids (Phase-1 batch)

Format: `look_{con}_{outlook}`

**armor:** `look_armor_plain`, `look_armor_metal_2`, `look_armor_metal_3`, `look_armor_earth_2`, `look_armor_earth_3`, `look_armor_fire_2`, `look_armor_silent_2`, `look_armor_royal_2`, `look_armor_silk_2`, `look_armor_frost_2`

**robe:** `look_robe_plain`, `look_robe_metal_2`, `look_robe_metal_3`, `look_robe_earth_2`, `look_robe_earth_3`, `look_robe_fire_2`, `look_robe_silent_2`, `look_robe_royal_2`, `look_robe_silk_2`, `look_robe_frost_2`

**cloak:** `look_cloak_plain`, `look_cloak_metal_2`, `look_cloak_metal_3`, `look_cloak_earth_2`, `look_cloak_earth_3`, `look_cloak_fire_2`, `look_cloak_silent_2`, `look_cloak_royal_2`, `look_cloak_silk_2`, `look_cloak_frost_2`

**coat:** `look_coat_plain`, `look_coat_metal_2`, `look_coat_metal_3`, `look_coat_earth_2`, `look_coat_earth_3`, `look_coat_fire_2`, `look_coat_silent_2`, `look_coat_royal_2`, `look_coat_silk_2`, `look_coat_frost_2`

**tunic:** `look_tunic_plain`, `look_tunic_metal_2`, `look_tunic_metal_3`, `look_tunic_earth_2`, `look_tunic_earth_3`, `look_tunic_fire_2`, `look_tunic_silent_2`, `look_tunic_royal_2`, `look_tunic_silk_2`, `look_tunic_frost_2`

Note: `look_cloak_metal_*` exists so the **wrong** Metal-on-cloak build still has a readable look even while `syn_neg_cloak_metal` punishes gameplay.

## Later batches (park until stamped)

- Remaining constructions (`boots`, `gloves`, `hood`, `crownveil`, `mantle`, `wraps`, `cape`) × same 10 outlooks
- Remaining outlooks (`storm_2`, `wild_2`, `occult_2`, cross-tags, `fire_3`, …)
- Unique overrides (`uniq_*` @ order 200)

## Harness stamp fields (for Test)

Every dump should include: `construction`, `material_ids[]`, `tag_counts`, `powers_fired[]` (pos+neg), `outlook_id`, `outlook_order`.
