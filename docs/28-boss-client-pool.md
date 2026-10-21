# Shared boss-client pool (adventurer jobs)

**Terminology (2026-10-05):** people in this pool are **adventurers**. **Client** = Godot Client seat / codebase. Filename / `boss_client_id` stay until Grimmjow’s bible rename Later. See [STAMP](STAMP.md) · [pm/phase-1-plan](pm/phase-1-plan.md).

Jonathan lock (2026-10-02). **M1 4-job draw LOCKED (Jonathan 2026-10-08):** Knight, Mage, Blade Dancer, Lagoon. **M2 / Steam-demo draw LOCKED (Jonathan 2026-10-21, draw B):** Wizard, Hexer, Outrider, Oathbound only. The two pools are **disjoint**. **Doc id: `28`.** Design only — no Client / Godot / art this stamp.

## Pool law

One **shared adventurer / boss-client pool for all bosses and all chapters**. **Not** a fixed client per boss.

- Organized by **job title** (knight, mage, lagoon, wizard, blade dancer, …).
- At the **boss beat**, draw **one** adventurer from this pool (seeded). That draw is **independent** of which chapter boss was announced (`17`).
- **Catalog vs filter.** The table below is the **construction catalog** (every job’s order). A draw is a filter over it. Do not delete a row to express a pool, and do not draw every row at once.
- **M1 draw filter — LOCKED (Jonathan 2026-10-08):** `M1_JOB_POOL` is **4 jobs only** — Knight, Mage, Blade Dancer, Lagoon. Do **not** draw Wizard / Hexer / Outrider / Oathbound on M1 content or historical smokes. Do **not** stub-fallback.
- **M2 / Steam-demo filter — LOCKED (Jonathan 2026-10-21, draw B):** `M2_JOB_POOL` (= `STEAM_DEMO_JOB_POOL`) is **4 jobs only** — Wizard, Hexer, Outrider, Oathbound. Then one of that job’s 3 named people in [29](29-adventurer-catalog.md). Boss beat and shop walk-in on M2 content. Does **not** include the M1 four. The pools stay disjoint.
- The drawn adventurer’s **order constructions** (`con_*`) **+ requirement tags** are what the player crafts for.
- The drawn adventurer **fights** the announced chapter boss. Player is the clothier, not the fighter.
- Mid-chapter appointments / walk-ins (`appt_*`, route map `22`) are **not** this pool. Scrap Duelist stays an **appointment** (C1 elite node) — never the boss-client, never Dex Adventurers; do not pin to reserved **days** or the boss beat.

Example: C1 may draw Ash Drake as boss; C1 (or C2 / C3) may still draw a knight or a mage. Different jobs → different **order constructions** and different requirement tags. Knight orders armor + gauntlet; mage orders robe + hood. Ash Drake’s favor / punish (`17`) is the threat axis.

Named people (3 per job, M1 and M2) supersede job-title-only identity: **[29-adventurer-catalog](29-adventurer-catalog.md)**. M1 portrait files have landed. M2 portrait files are not stamped. **Portrait uniqueness** in `29` locks Race / Visual / Outfit / Character / Hook on all 24. ACCEPT soft-gates 12 M2 redraws only (`assets/adv/<adv_id>.png`). M1 regen needs a separate stamp. Constructions in this file stay the job lists.

## Draw

**LOCKED (Jonathan 2026-10-08):** M1 boss-draw pool = **4 jobs only**. Closes PR #28 open question 1 (restrict to 4 vs keep a draw of every construction row plus job-stub fallback). **LOCKED (Jonathan 2026-10-21, draw B):** M2 does not revive a union of both fours. `M2_JOB_POOL` is Wizard, Hexer, Outrider, Oathbound only.

```
# construction rows stay below — each draw is one 4-job pool
M1_JOB_POOL = job_knight, job_mage, job_blade_dancer, job_lagoon
# LOCKED Jonathan 2026-10-08. M1 content / historical smokes. Unchanged.

M2_JOB_POOL = job_wizard, job_hexer, job_outrider, job_oathbound
# STEAM_DEMO_JOB_POOL = M2_JOB_POOL
# LOCKED Jonathan 2026-10-21 — draw B.
# Disjoint from M1_JOB_POOL. Do not union the two lists.

function pick_boss_client(seed):
  job = seeded_choice(M1_JOB_POOL, seed)
  # do not pass chapter_boss_id — draws are independent
  # named person: 29 (one of that job's 3)
  return job

function pick_boss_client_m2(seed):
  job = seeded_choice(M2_JOB_POOL, seed)
  # do not pass chapter_boss_id
  # named person: 29 (one of that M2 job's 3) — stubs are aliases, not extra people
  return job
```

| Rule | M1 (`M1_JOB_POOL`) | M2 / Steam demo (`M2_JOB_POOL`) |
|---|---|---|
| When | Boss beat (after reserved last-2 **days** / final prep) — not chapter-start newspaper. M1 shop / walk-in uses the M1 12 | Same boss beat **and** shop / walk-in, when the content is M2 / Steam demo |
| What | One `job_*` from **Knight, Mage, Blade Dancer, Lagoon** → named `adv_*` from that job (`29`) + that job’s **order constructions** | One `job_*` from **Wizard, Hexer, Outrider, Oathbound** → named `adv_*` from that job’s 3 + the same job constructions |
| Vs boss | Independent of `chapter_boss_id` | Independent of `chapter_boss_id` |
| Repeat | Same job may recur across chapters | Same |
| Unique-per-run | Later | Later |
| Telegraph job before beat | Later | Later |
| Newspaper | Announces the **boss** (`26`), not the adventurer | Same |
| The other four | **Out of this pool (LOCKED).** Do not draw; do not stub-fallback | **Out of this pool (LOCKED, draw B).** Do not draw the M1 four here |

## Job catalog

Ids: `job_*` = title in the pool. The `boss_client_id` cell in the table is the **job-default alias**. The drawn id is a named person in `29` (the alias resolves to that job’s monostack). Default order id = `ord_<job slug>`.

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

**M1 draw (LOCKED Jonathan 2026-10-08):** Knight / Mage / Blade Dancer / Lagoon only. Wizard / Hexer / Outrider / Oathbound stay in this table for constructions. They are **out of `M1_JOB_POOL`**. They are **in `M2_JOB_POOL`**. Named people: `29`. `boss_client_id` on a job row above is the **alias**, not a fourth person.

### Per-job order (explicit)

Each block is the **order**. Craft these constructions, in listed sequence (zone 1..N).

**Knight** — `job_knight` / `adv_knight` → `adv_halden_rook` (`29`) / `ord_knight`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_armor` | Armor | Body, hard |
| 2 | `con_gloves` | **Gauntlet** (catalog name: Gloves) | Hands |

Requirement tags: Metal, Sharp. Favor: hard clang and an edge; Soft reads as a squire. Flavor: oath steel — takes the field against whoever the paper named.

**Mage** — `job_mage` / `adv_mage` → `adv_quill_lumen` (`29`) / `ord_mage`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_robe` | Robe | Body, flowing |
| 2 | `con_hood` | Hood | Head |

Requirement tags: Silk, Pure, Lunar. Favor: flow and a clean hood; plate is the wrong brief. Flavor: scholar of the road — robe first, then the threat.

**Lagoon** — `job_lagoon` / `adv_lagoon` → `adv_tide_glass` (`29`) / `ord_lagoon`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_cloak` | Cloak | Outer |
| 2 | `con_boots` | Boots | Feet |

Requirement tags: Frost, Sticky, Storm. Favor: brine-ready outer + footing; solar / dry cloth peel. Flavor: tide-hired — walks docks and mires the same. Jonathan-named title. Not an appointment; not Salt Widow.

**Wizard** — `job_wizard` / `adv_wizard` → `adv_vesper_cant` (`29`) / `ord_wizard`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_robe` | Robe | Body, flowing |
| 2 | `con_mantle` | Mantle | Shoulders |

Requirement tags: Occult, Lunar, Royal. Favor: signed occult / lunar / court weight — not a mage’s study robe alone. Flavor: court-adjacent caster — signs the order in three inks.

**Blade Dancer** — `job_blade_dancer` / `adv_blade_dancer` → `adv_kite_thornreel` (`29`) / `ord_blade_dancer`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_tunic` | Tunic | Body, light |
| 2 | `con_cape` | Cape | Outer, flourish |

Requirement tags: Sharp, Silk, Silent. Favor: light body + flourish; will not wear plate. Flavor: edge and hem — moves like a cut.

**Hexer** — `job_hexer` / `adv_hexer` → `adv_soot_cord` (`29`) / `ord_hexer`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_wraps` | Wraps | Body, binding |
| 2 | `con_hood` | Hood | Head |

Requirement tags: Occult, Sticky, Silent. Favor: knots, veil, bind; Pure / solar wash the work out. Flavor: names and cords — the bog already knows them.

**Outrider** — `job_outrider` / `adv_outrider` → `adv_harrow_gale` (`29`) / `ord_outrider`

| # | `con_*` | Prose | Slot |
|---:|---|---|---|
| 1 | `con_coat` | Coat | Outer, tailored |
| 2 | `con_boots` | Boots | Feet |

Requirement tags: Wild, Storm, Silent. Favor: a road coat and boots; heavy armor is the wrong brief. Flavor: wagon-side sellsword — sleeps in the coat.

**Oathbound** — `job_oathbound` / `adv_oathbound` → `adv_aurel_vow` (`29`) / `ord_oathbound`

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
| `boss_client_id` | `adv_*` from this catalog. **M1:** one of the 12 M1 named people or an M1 job alias (`29`). **M2 / Steam demo:** one of the 12 M2 named people or an M2 job alias (`adv_wizard`, `adv_hexer`, `adv_outrider`, `adv_oathbound`) |
| `boss_job_id` | matching `job_*` |
| `order_id` | that job’s `ord_*` |
| `construction_ids` | **that job’s order constructions** (listed `con_*`, in sequence) |
| `threat_id` | announced `chapter_boss_id` |

`boss_client_id` is **never** an `appt_*`. Appointments use `appointment_id` on the route map (`22`).

M1 portraits have landed (`29`). The redraw brief is **Portrait uniqueness** in `29` (24 rows; ACCEPT opens 12 M2 redraws only). Gens, extra Client widgets for the new 12, and Godot stay out of this doc. Do not treat this doc as a Client wire.

## Explicit non-goals

- Fixed client per boss
- Scrap Duelist (or any `appt_*`) as boss-client
- Pinning an appointment to reserved **days** / the boss beat (current map: not D7–D8)
- Inventing `con_*`, Godot scenes, or portraits
- Per-chapter client pools for the **boss** beat (mid-chapter people stay route-map nodes / appointments)
- Flavor-only job rows with no order constructions
- Drawing Wizard / Hexer / Outrider / Oathbound in **M1**
- Drawing Knight / Mage / Blade Dancer / Lagoon in **M2**
- Merging the two pools into one draw
- Job-stub fallback on either smoke
- Treating `M2_JOB_POOL` as a rewrite of the locked M1 filter

## Pointers

- Bosses / starter-tag law: [17-chapter-bosses](17-chapter-bosses.md)
- Route map: [22-chapter-schedule](22-chapter-schedule.md)
- Harness: [20-harness-stamp](20-harness-stamp.md)
- Constructions: [12-constructions](12-constructions.md)
- Craft: [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Starter tags: [19-own-basic-starter](19-own-basic-starter.md)
- Named adventurers (M1 12 + M2 12) and which pool is active: [29-adventurer-catalog](29-adventurer-catalog.md)
- Interactive-order slices 1–3: [30-interactive-order](30-interactive-order.md)
