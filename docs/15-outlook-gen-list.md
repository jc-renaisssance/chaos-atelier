# Outlook gen list — construction × synergy

Jonathan: after chapter-flow docs stamp → **1C starts with armor outlooks only** (not full 50 until said).

Each synergy (pos + neg) has `outlook_order`; highest wins. Rare/legendary skip neg syn (`14`).

**Retune 2026-09-29:** outlook ids prefer `{tag}_{3|5|8}` matching syn suffixes. Stale Phase-1 `*_2` / mid `*_3` asset filenames stay on disk until renamed; map below.

## Preferred outlook ids (armor)

| outlook_id | Syn that wins look | Tier | Art status (armor) |
|---|---|---|---|
| `plain` | *(none)* | base | **Exists** `look_armor_plain` |
| `metal_3` | `syn_metal_3` | low ≥3 | **Exists** as `look_armor_metal_2` (legacy name) |
| `metal_5` | `syn_metal_5` | mid ≥5 | **Exists** as `look_armor_metal_3` (legacy name) |
| `metal_8` | `syn_metal_8` | apex ≥8 | **Exists** `look_armor_metal_8` |
| `earth_3` | `syn_earth_3` | low ≥3 | **Exists** as `look_armor_earth_2` |
| `earth_5` | `syn_earth_5` | mid ≥5 | **Exists** as `look_armor_earth_3` |
| `earth_8` | `syn_earth_8` | apex ≥8 | **Exists** `look_armor_earth_8` |
| `fire_3` | `syn_fire_3` | low ≥3 | **Exists** as `look_armor_fire_2` |
| `fire_5` | `syn_fire_5` | mid ≥5 | **Exists** as `look_armor_fire_3` |
| `fire_8` | `syn_fire_8` | apex ≥8 | **Exists** `look_armor_fire_8` |
| `frost_3` | `syn_frost_3` | low ≥3 | **Exists** as `look_armor_frost_2` |
| `frost_5` | `syn_frost_5` | mid ≥5 | **Exists** as `look_armor_frost_3` *(Jonathan: frost mid art)* |
| `frost_8` | `syn_frost_8` | apex ≥8 | **Later** |
| `silent_3` | `syn_silent_3` | low ≥3 | **Exists** as `look_armor_silent` (unnumbered) |
| `silent_5` | `syn_silent_5` | mid ≥5 | **Later** |
| `silent_8` | `syn_silent_8` | apex ≥8 | **Later** |
| `royal_3` | `syn_royal_3` | low ≥3 | **Later** |
| `royal_5` | `syn_royal_5` | mid ≥5 | **Later** |
| `royal_8` | `syn_royal_8` | apex ≥8 | **Exists** as `look_armor_royal` *(Jonathan: stamped royal = APEX, not low)* |
| `silk_3` | `syn_silk_3` | low ≥3 | **Exists** as `look_armor_silk` (unnumbered) |
| `silk_5` | `syn_silk_5` | mid ≥5 | **Later** |
| `silk_8` | `syn_silk_8` | apex ≥8 | **Later** |
| `storm_3` / `_5` / `_8` | `syn_storm_*` | 3/5/8 | **Later** (all tiers) |
| `lunar_3` / `_5` / `_8` | `syn_lunar_*` | 3/5/8 | **Later** |
| `solar_3` / `_5` / `_8` | `syn_solar_*` | 3/5/8 | **Later** |
| `sticky_3` / `_5` / `_8` | `syn_sticky_*` | 3/5/8 | **Later** |
| `sharp_3` / `_5` / `_8` | `syn_sharp_*` | 3/5/8 | **Later** |
| `soft_3` / `_5` / `_8` | `syn_soft_*` | 3/5/8 | **Later** |
| `wild_3` / `_5` / `_8` | `syn_wild_*` | 3/5/8 | **Later** |
| `occult_3` / `_5` / `_8` | `syn_occult_*` | 3/5/8 | **Later** |
| `pure_3` / `_5` / `_8` | `syn_pure_*` | 3/5/8 | **Later** |

Cross-tag outlooks (Temper, Greenmail, Snaretooth, Masked Crown, Dawn Vestment, Pale Hex): **power + single chrome** — art **Later**; no 3/5/8 tiers ([14](14-synergies.md) Cross-tag review).

## Phase-1C batch — **armor stamped 2026-09-29**

Folder: `armor-stamped-2026-09-29/` (local; see its `README.txt`).

| Folder | Legacy filenames | Preferred outlook_id |
|---|---|---|
| `00-base/` | `look_armor_plain` | `plain` |
| `01-low/` | `look_armor_{metal,earth,fire,frost}_2` | `{tag}_3` (low ≥3) |
| `02-mid/` | `look_armor_{metal,earth,fire,frost}_3` | `{tag}_5` (mid ≥5) |
| `03-apex/` | `look_armor_{metal,earth,fire}_8` | `{tag}_8` (apex ≥8; **frost_8 missing**) |
| `04-syn/` | `look_armor_silent`, `look_armor_royal`, `look_armor_silk` | `silent_3`, **`royal_8`**, `silk_3` |

**Do not** treat `look_armor_royal` as low royal — it is **apex** (`royal_8` / `syn_royal_8`).

Stale 10-id list retired: `plain`, `metal_2`, `metal_3`, `earth_2`, `earth_3`, `fire_2`, `silent_2`, `royal_2`, `silk_2`, `frost_2`.

## Later (parked)

- Frost apex armor (`look_armor_frost_8`)
- Silent / silk mid + apex; royal low + mid
- Storm / lunar / solar / sticky / sharp / soft / wild / occult / pure armor 3/5/8
- Cross-tag outlook assets
- Remaining constructions × outlooks (toward prior 50)
- Neg outlook assets · full matrix · multi-owner atelier art

## Full ladder

Polarity / `outlook_order` values live in [14](14-synergies.md). Neg orders sit above peers.

## Harness

Stamp `outlook_id` / `outlook_order` per `20`. Prefer new `{tag}_{3|5|8}` ids; legacy filenames OK until asset rename pass.