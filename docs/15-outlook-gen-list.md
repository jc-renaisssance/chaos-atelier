# Outlook gen list — construction × synergy

Jonathan lock (2026-09-21): image gen produces **combination outcomes** per **construction × synergy**. Plain/default when no outlook synergy. Each synergy — **positive and negative** — has an **order**; finished garment uses **only the highest-order** look. **Neg orders sit above** related positives so bad looks win when live. Rare/legendary crafts never fire neg syn (see `14`).

**No gens until** Finance stamps a Phase-1 gen ask against this list.

## Rules

1. Base asset per construction: `look_{con}_plain`.
2. One asset per `(construction, outlook_synergy)` marked gen-ready.
3. Runtime: max `outlook_order` among fired rows (negs included, except rare/legendary which skip negs).
4. Named uniques @ 200; Phase-1 may fall back to dominant tag look.
5. **Player-owner** atelier art (`atelier_{owner}`) — see `docs/16-shop-owners.md`; Phase-1 = `own_basic` only. (Owner = **player clothier**, not a shop NPC.)

## Outlook ladder (order ascending; highest wins)

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
| `metal_3` | `syn_metal_3` | 32 | + |
| `silent_2` | `syn_silent_2` | 35 | + |
| `neg_metal_silk` | `syn_neg_metal_silk` | 36 | − |
| `neg_hood_metal` | `syn_neg_hood_metal` | 39 | − |
| `sticky_2` | `syn_sticky_2` | 40 | + |
| `neg_cloak_metal` | `syn_neg_cloak_metal` | 41 | − |
| `neg_metal_silent` | `syn_neg_metal_silent` | 44 | − |
| `sharp_2` | `syn_sharp_2` | 45 | + |
| `snaretooth` | `syn_sticky_sharp` | 48 | + |
| `frost_2` | `syn_frost_2` | 50 | + |
| `neg_soft_sharp` | `syn_neg_soft_sharp` | 52 | − |
| `storm_2` | `syn_storm_2` | 55 | + |
| `wild_2` | `syn_wild_2` | 60 | + |
| `pure_2` | `syn_pure_2` | 65 | + |
| `royal_2` | `syn_royal_2` | 70 | + |
| `masked_crown` | `syn_royal_silent` | 72 | + |
| `solar_2` | `syn_solar_2` | 75 | + |
| `dawn` | `syn_solar_pure` | 78 | + |
| `lunar_2` | `syn_lunar_2` | 80 | + |
| `neg_sticky_royal` | `syn_neg_sticky_royal` | 82 | − |
| `occult_2` | `syn_occult_2` | 85 | + |
| `pale_hex` | `syn_lunar_occult` | 88 | + |
| `fire_2` | `syn_fire_2` | 90 | + |
| `neg_occult_pure` | `syn_neg_occult_pure` | 92 | − |
| `fire_3` | `syn_fire_3` | 100 | + |
| `neg_fire_soft` | `syn_neg_fire_soft` | 105 | − |

## Full matrix size (garment outlooks)

| constructions | outlook rows (incl. plain + negs) | cells |
|---:|---:|---:|
| 12 | 34 | **408** |

## Phase-1 gen batch — still **50**

Constructions: `armor`, `robe`, `cloak`, `coat`, `tunic` (5).

Outlooks: `plain`, `metal_2`, `metal_3`, `earth_2`, `earth_3`, `fire_2`, `silent_2`, `royal_2`, `silk_2`, `frost_2` (10).

→ **50** garment assets. Neg outlook assets + multi-owner atelier art = **Later**. Optional +1: `atelier_own_basic`.

### Explicit combo ids (Phase-1 batch)

**armor:** `look_armor_plain`, `look_armor_metal_2`, `look_armor_metal_3`, `look_armor_earth_2`, `look_armor_earth_3`, `look_armor_fire_2`, `look_armor_silent_2`, `look_armor_royal_2`, `look_armor_silk_2`, `look_armor_frost_2`

**robe:** `look_robe_plain`, `look_robe_metal_2`, `look_robe_metal_3`, `look_robe_earth_2`, `look_robe_earth_3`, `look_robe_fire_2`, `look_robe_silent_2`, `look_robe_royal_2`, `look_robe_silk_2`, `look_robe_frost_2`

**cloak:** `look_cloak_plain`, `look_cloak_metal_2`, `look_cloak_metal_3`, `look_cloak_earth_2`, `look_cloak_earth_3`, `look_cloak_fire_2`, `look_cloak_silent_2`, `look_cloak_royal_2`, `look_cloak_silk_2`, `look_cloak_frost_2`

**coat:** `look_coat_plain`, `look_coat_metal_2`, `look_coat_metal_3`, `look_coat_earth_2`, `look_coat_earth_3`, `look_coat_fire_2`, `look_coat_silent_2`, `look_coat_royal_2`, `look_coat_silk_2`, `look_coat_frost_2`

**tunic:** `look_tunic_plain`, `look_tunic_metal_2`, `look_tunic_metal_3`, `look_tunic_earth_2`, `look_tunic_earth_3`, `look_tunic_fire_2`, `look_tunic_silent_2`, `look_tunic_royal_2`, `look_tunic_silk_2`, `look_tunic_frost_2`

Until neg assets exist: if winner is `neg_*` with no asset → placeholder / nearest positive / `plain`.

## Later batches (park)

- Negative outlooks × constructions
- Remaining constructions / outlooks / uniques
- Atelier art for owners beyond `own_basic`

## Harness stamp fields

`construction`, `material_ids[]`, `tag_counts`, `powers_fired[]` (pos+neg), `outlook_id`, `outlook_order`, `craft_rarity`, `player_owner_id`.
