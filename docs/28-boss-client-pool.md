# Shared boss-client pool (adventurer jobs)

Jonathan lock (2026-10-02). **Doc id: `28`.** Design only — no Client / Godot / art this stamp.

## Pool law

One **shared adventurer / boss-client pool for all bosses and all chapters**. **Not** a fixed client per boss.

- Organized by **job title** (knight, mage, lagoon, wizard, blade dancer, …).
- At the **boss beat**, draw **one** adventurer from this pool (seeded). That draw is **independent** of which chapter boss was announced (`17`).
- The drawn adventurer’s **order constructions** (`con_*`) **+ requirement tags** are what the player crafts for.
- The drawn adventurer **fights** the announced chapter boss. Player is the clothier, not the fighter.
- Mid-chapter appointments / walk-ins (`appt_*`, schedule `22`) are **not** this pool. Scrap Duelist stays an **appointment** — never the boss-client; do not pin to reserved rounds or the boss beat.

Example: C1 may draw Ash Drake as boss; C1 (or C2 / C3) may still draw a knight or a mage. Different jobs → different **order constructions** and different requirement tags. Knight orders armor + gauntlet; mage orders robe + hood. Ash Drake’s favor / punish (`17`) is the threat axis.

Portraits / UI wire / named individuals = **Later**. Phase-1 identity = job title.

## Draw

```
function pick_boss_client(seed):
  return seeded_choice(SHARED_BOSS_CLIENT_POOL, seed)
  # SHARED_BOSS_CLIENT_POOL = job rows below
  # do not pass chapter_boss_id — draws are independent
```

| Rule | Phase-1 |
|---|---|
| When | Boss beat (after reserved rounds / final prep) — not chapter-start newspaper |
| What | One `job_*` → `adv_*` + that job’s **order constructions** |
| Vs boss | Independent of `chapter_boss_id` |
| Repeat | Same job may recur across chapters |
| Unique-per-run | Later |
| Telegraph job before beat | Later |
| Newspaper | Announces the **boss** (`26`), not the client |

## Job catalog

Ids: `job_*` = title in the pool. `adv_*` = adventurer / `boss_client_id` when that job is drawn. Default order id = `ord_<job slug>`.

**Order constructions are law.** Every job lists the exact `con_*` pieces the player must craft — not flavor, not a picker. Ids from [12-constructions](12-constructions.md) only; do not invent `con_*`. Multi-piece OK (Phase-1: **2** pieces, ≤4 per `27`). On the boss beat, `construction_ids` **equals** that job’s order-constructions list, in sequence.

Requirement tags = **order taste** (what this job wants on the garment). Not the same list as boss favor / punish (`17`). A Metal-leaning knight vs a C3 boss that punishes Metal is a legal hard draw.

### Catalog (order constructions required)

| job id | Display | `boss_client_id` | `order_id` | **Order constructions** (`con_*`) | N | Requirement tags |
|---|---|---|---|---|---:|---|
| `job_knight` | Knight | `adv_knight` | `ord_knight` | `con_armor` + `con_gloves` (armor + gauntlet) | 2 | Metal, Sharp |
| `job_mage` | Mage | `adv_mage` | `ord_mage` | `con_robe` + `con_hood` (robe + hood) | 2 | Silk, Pure, Lunar |
| `job_lagoon` | Lagoon | `adv_lagoon` | `ord_lagoon` | `con_cloak` + `con_boots` (cloak + boots) | 2 | Frost, Sticky, Storm |
| `job_wizard` | Wizard | `adv_wizard` | `ord_wizard` | `con_robe` + `con_mantle` (robe + mantle) | 2 | Occult, Lunar, Royal |
| `job_blade_dancer` | Blade Dancer | `adv_blade_dancer` | `ord_blade_dancer` | `con_tunic` + `con_cape` (tunic + cape) | 2 | Sharp, Silk, Silent |
| `job_hexer` | Hexer | `adv_hexer` | `ord_hexer` | `con_wraps` + `con_hood` (wraps + hood) | 2 | Occult, Sticky, Silent |
| `job_outrider` | Outrider | `adv_outrider` | `ord_outrider` | `con_coat` + `con_boots` (coat + boots) | 2 | Wild, Storm, Silent |
| `job_oathbound` | Oathbound | `adv_oathbound` | `ord_oathbound` | `con_armor` + `con_mantle` (armor + mantle) | 2 | Royal, Solar, Pure |

N = 2 → one parallel session, `stamina_start = 12 * 2` (`27`). Finish-only / StS hand cycle unchanged. N > 4 = Later.

### Per-job order (explicit)

Each block is the **order**. Craft these constructions, in listed sequence (zone 1..N).

**Knight** — `job_knight` / `adv_knight` / `ord_knight`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_armor` | Armor | Body, hard |
| 2 | `con_gloves` | **Gauntlet** (catalog name: Gloves) | Hands |

Requirement tags: Metal, Sharp. Favor: hard clang and an edge; Soft reads as a squire. Flavor: oath steel — takes the field against whoever the paper named.

**Mage** — `job_mage` / `adv_mage` / `ord_mage`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_robe` | Robe | Body, flowing |
| 2 | `con_hood` | Hood | Head |

Requirement tags: Silk, Pure, Lunar. Favor: flow and a clean hood; plate is the wrong brief. Flavor: scholar of the road — robe first, then the threat.

**Lagoon** — `job_lagoon` / `adv_lagoon` / `ord_lagoon`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_cloak` | Cloak | Outer |
| 2 | `con_boots` | Boots | Feet |

Requirement tags: Frost, Sticky, Storm. Favor: brine-ready outer + footing; solar / dry cloth peel. Flavor: tide-hired — walks docks and mires the same. Jonathan-named title. Not an appointment; not Salt Widow.

**Wizard** — `job_wizard` / `adv_wizard` / `ord_wizard`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_robe` | Robe | Body, flowing |
| 2 | `con_mantle` | Mantle | Shoulders |

Requirement tags: Occult, Lunar, Royal. Favor: signed occult / lunar / court weight — not a mage’s study robe alone. Flavor: court-adjacent caster — signs the order in three inks.

**Blade Dancer** — `job_blade_dancer` / `adv_blade_dancer` / `ord_blade_dancer`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_tunic` | Tunic | Body, light |
| 2 | `con_cape` | Cape | Outer, flourish |

Requirement tags: Sharp, Silk, Silent. Favor: light body + flourish; will not wear plate. Flavor: edge and hem — moves like a cut.

**Hexer** — `job_hexer` / `adv_hexer` / `ord_hexer`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_wraps` | Wraps | Body, binding |
| 2 | `con_hood` | Hood | Head |

Requirement tags: Occult, Sticky, Silent. Favor: knots, veil, bind; Pure / solar wash the work out. Flavor: names and cords — the bog already knows them.

**Outrider** — `job_outrider` / `adv_outrider` / `ord_outrider`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_coat` | Coat | Outer, tailored |
| 2 | `con_boots` | Boots | Feet |

Requirement tags: Wild, Storm, Silent. Favor: a road coat and boots; heavy armor is the wrong brief. Flavor: wagon-side sellsword — sleeps in the coat.

**Oathbound** — `job_oathbound` / `adv_oathbound` / `ord_oathbound`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_armor` | Armor | Body, hard |
| 2 | `con_mantle` | Mantle | Shoulders |

Requirement tags: Royal, Solar, Pure. Favor: sworn plate and a mantle; peasant staples look like contempt. Flavor: sworn to the paper’s name — ceremony and plate.

**Mage vs wizard:** mage orders robe + hood (`con_robe`, `con_hood`). Wizard orders robe + mantle (`con_robe`, `con_mantle`). Do not collapse the two.

Do **not** add Scrap Duelist (or `cli_c1_scrap_duelist`) to this catalog. That name stays an appointment (`appt_scrap_duelist` when the appointment catalog is stamped).

## Craft lock (unchanged)

Boss-client order is a normal order:

- Construction **from the order constructions list** — not a player construction pick (`27`).
- Multi-piece = **one** session, N zones, `stamina_start = 12 * N`.
- **Finish-only** — stamina 0 ≠ finish (`27`, `20`).
- StS play → discard / dig dump / reshuffle unchanged.
- Sim uses **this** adventurer’s resolved gear vs `chapter_boss_id`.

## Harness

On `mission_kind=boss` (`20`):

| Field | Value |
|---|---|
| `chapter_boss_id` | Announced pool draw (`17`) |
| `boss_pool_id` | Pool the boss was drawn from |
| `boss_client_id` | `adv_*` from this catalog |
| `boss_job_id` | matching `job_*` |
| `order_id` | that job’s `ord_*` |
| `construction_ids` | **that job’s order constructions** (listed `con_*`, in sequence) |
| `threat_id` | announced `chapter_boss_id` |

`boss_client_id` is **never** an `appt_*`. Appointments use `appointment_id` on the schedule board.

Portraits / Client widgets / extra UI = **Later**.

## Explicit non-goals

- Fixed client per boss
- Scrap Duelist (or any `appt_*`) as boss-client
- Pinning an appointment to R6 / reserved rounds / the boss beat
- Inventing `con_*`, Godot scenes, or portraits
- Per-chapter client pools for the **boss** beat (mid-chapter pools stay schedule / appointments)
- Flavor-only job rows with no order constructions

## Pointers

- Bosses / starter-tag law: [17-chapter-bosses](17-chapter-bosses.md)
- Schedule: [22-chapter-schedule](22-chapter-schedule.md)
- Harness: [20-harness-stamp](20-harness-stamp.md)
- Constructions: [12-constructions](12-constructions.md)
- Craft: [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Starter tags: [19-own-basic-starter](19-own-basic-starter.md)
