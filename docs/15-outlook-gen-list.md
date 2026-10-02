# Outlook gen list — construction × synergy

Jonathan: after chapter-flow docs stamp — **1C starts with armor outlooks only** (not full 50 until said).

Each synergy (pos + neg) has `outlook_order`; highest wins. Rare/legendary skip neg syn (`14`).

**Retune 2026-09-29:** outlook ids prefer `{tag}_{3|5|8}` matching syn suffixes. Metal/earth/fire/frost low+mid still use legacy `*_2` / mid `*_3` filenames on disk; silent/silk/royal use stamped `_3`/`_5`/`_8`.

**Armor lineup DONE (Jonathan 2026-09-29 evening):** traveler / atelier default armor monostack art is complete for the listed tags below. **Do not** plan more monostack armor gens for storm / lunar / solar / sticky / sharp / soft / wild / occult / pure — those belong to the **other shop owner pool**. **Next:** cross-tag positive + negative syn (art/docs as needed).

## Preferred outlook ids (armor) — traveler / atelier default

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
| `frost_5` | `syn_frost_5` | mid ≥5 | **Exists** as `look_armor_frost_3` |
| `frost_8` | `syn_frost_8` | apex ≥8 | **Exists** `look_armor_frost_8` *(freestanding frost apex)* |
| `silent_3` | `syn_silent_3` | low ≥3 | **Exists** `look_armor_silent_3` |
| `silent_5` | `syn_silent_5` | mid ≥5 | **Exists** `look_armor_silent_5` |
| `silent_8` | `syn_silent_8` | apex ≥8 | **Exists** `look_armor_silent_8` |
| `royal_3` | `syn_royal_3` | low ≥3 | **Exists** `look_armor_royal_3` |
| `royal_5` | `syn_royal_5` | mid ≥5 | **Exists** `look_armor_royal_5` |
| `royal_8` | `syn_royal_8` | apex ≥8 | **Exists** `look_armor_royal_8` (+ optional `04-syn/look_armor_royal` alias) |
| `silk_3` | `syn_silk_3` | low ≥3 | **Exists** `look_armor_silk_3` |
| `silk_5` | `syn_silk_5` | mid ≥5 | **Exists** `look_armor_silk_5` |
| `silk_8` | `syn_silk_8` | apex ≥8 | **Exists** `look_armor_silk_8` |

## Other shop owner pool (not traveler / atelier default armor)

These monostack syn lines keep power rows in [14](14-synergies.md) but **armor outlook art is not** on the traveler/atelier default gen list. Park under **other shop owner** outlooks when that owner’s shop art starts:

| Tags | Syn rows | Armor outlook gen |
|---|---|---|
| storm, lunar, solar, sticky, sharp, soft, wild, occult, pure | `syn_{tag}_{3\|5\|8}` live in `14` | **Other owner pool** — do **not** monostack-gen for default atelier armor |

Cross-tag outlooks (Temper, Greenmail, Snaretooth, Masked Crown, Dawn Vestment, Pale Hex): **power + single chrome** — **next** (with neg outlooks); no 3/5/8 tiers ([14](14-synergies.md) Cross-tag review).

## Phase-1C batch — **armor stamped 2026-09-29** (complete)

Folder: `armor-stamped-2026-09-29/` (local; see its `README.txt`).

| Folder | Stamped filenames | Preferred outlook_id |
|---|---|---|
| `00-base/` | `look_armor_plain` | `plain` |
| `01-low/` | `look_armor_{metal,earth,fire,frost}_2`; `look_armor_{royal,silent,silk}_3` | `{tag}_3` (low ≥3) |
| `02-mid/` | `look_armor_{metal,earth,fire,frost}_3`; `look_armor_{royal,silent,silk}_5` | `{tag}_5` (mid ≥5) |
| `03-apex/` | `look_armor_{metal,earth,fire,frost,royal,silent,silk}_8` | `{tag}_8` (apex ≥8) |
| `04-syn/` | `look_armor_royal` only *(optional apex alias; may be empty later)* | `royal_8` |

**Do not** treat `look_armor_royal` (04-syn alias) as low royal — ladder uses `royal_3` / `royal_5` / `royal_8`; alias maps to **apex**.

Stale 10-id list retired: `plain`, `metal_2`, `metal_3`, `earth_2`, `earth_3`, `fire_2`, `silent_2`, `royal_2`, `silk_2`, `frost_2`.

## Next / parked

- **Next (tomorrow):** cross-tag positive syn + negative syn — art/docs as needed
- Neg outlook assets · remaining constructions × outlooks (toward prior 50)
- **Other shop owner pool** armor outlooks: storm / lunar / solar / sticky / sharp / soft / wild / occult / pure
- **No more** traveler/atelier default monostack armor gens for the complete tags above

## Full ladder

Polarity / `outlook_order` values live in [14](14-synergies.md). Neg orders sit above peers.

## Harness

Stamp `outlook_id` / `outlook_order` per `20`. Prefer new `{tag}_{3|5|8}` ids; legacy metal/earth/fire/frost `*_2`/`*_3` filenames OK until asset rename pass.
