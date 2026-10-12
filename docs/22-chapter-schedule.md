# Chapter day planner — travelling atelier (Jonathan stamp 2026-10-12)

**Status:** Design stamped. **LOCKED** (Aizen / Jonathan 2026-10-12). **Doc id: `22`.** Filename kept; live name is **Day planner**. **Supersedes** the 2026-09-28 **Round / schedule board** shell (`CHAPTER_ROUND_COUNT=8` as global law, R1..R8, `crafts_max=4`, chapter-start appointment pins as the only assign UX).

Kept: travelling atelier (not a path map). Craft = stamina ([27](27-craft-mode-stamina.md)). Boss-client draw unchanged (`28` / `29`). Scrap Duelist / `appt_*` stay appointments — **not** Dex Adventurers ([31](31-dex.md)).

## Fiction

The atelier rides a **horse-car / wagon** (or other transport). The shop moves with the road. Each chapter is one stretch: **days** on the road → destination **chapter boss**.

## Constants (Phase-1)

| Key | Value | Notes |
|---|---|---|
| Chapters per run | 3 | Unchanged |
| Day count | **`map.day_count`** / dump **`CHAPTER_DAY_COUNT`** | **Map setting — not global law.** Current map = **8**. Later maps may be **3** or **12**. Example tables below use 8 for the current map. |
| Piece cap / `crafts_max` | **GONE** | Unlimited pieces per chapter. Stamina per craft session **stays** ([27](27-craft-mode-stamina.md)). |
| Boss telegraph | Chapter start | Boss announced before spend |
| Reserved days | Last **2** relative to `N = map.day_count` | Player assigns **D1..(N−2)** only. Current 8-day map: **D7** travel / final prep, **D8** boss approach. Appointments cannot claim reserved days. |

### Reserved last-2 (relative to map length)

```
N = map.day_count
assignable = D1 .. D(N-2)
reserved   = D(N-1)  travel / final prep
             D(N)    boss approach
```

| Map `day_count` | Assignable | Reserved |
|---:|---|---|
| **8** (current) | D1..D6 | D7 travel / final prep · D8 boss approach |
| 3 (later map) | D1 | D2 travel / final prep · D3 boss approach |
| 12 (later map) | D1..D10 | D11 travel / final prep · D12 boss approach |

Do **not** hardcode 8 as law. Do **not** hardcode “rounds 7–8”. Fixed-window events may still pin **inside assignable days** — they cannot pin onto reserved days.

## Day planner (not a path map, not a Round board)

Labels are **D1, D2, … DN** — never R1. At **chapter start** the UI shows a **timeline of days 1..N**. Skill is previewing the pool, then **assigning the chapter**, then updating remaining days as the road unfolds.

### Chapter-start UX (LOCKED)

1. Kingdom newspaper announces the **boss** (`26`) — not the boss-client.
2. **Day planner** opens with every day D1..N visible.
3. Player **previews all possible options per day** via **expand / popup** on that day (options whose window includes the day).
4. Player **assigns the chapter schedule** — one primary option per assignable day D1..(N−2).
5. Reserved last-2 are visible but **not assignable**.
6. **Fixed-window** events pin themselves inside their window (cannot move). Player still assigns the rest.

### Mid-chapter update (LOCKED)

The planner **can be updated mid-chapter**. Only **remaining unplayed assignable days**. Past days are frozen. Reserved days stay reserved. Fixed-window events stay pinned inside their window (player cannot drag them off).

Phase-1: **one** primary action per day. Later: dual actions via skills.

### Day action kinds (from the assigned event)

| Kind | What it does |
|---|---|
| **Appointment** (`appt_*`) | Named / important order. Scrap Duelist stays here. **Not** Dex Adventurers. |
| **Adventurer** (`adv_*`) | Walk-in / listed adventurer order that day |
| **Wagon shop** | Buy / sell / reshape material deck (stock rotates with travel) |
| **Wagon event** | Travel / road event |
| **Prep craft** | Enter craft mode without a live adventurer — ready rack for a later appointment |
| **Rest / dig** | Recover light stamina meta Later; or inventory dig outside craft (optional Phase-1) |

Taking an order / prep **enters craft mode once** for that order. Multi-piece = **one** parallel session ([27](27-craft-mode-stamina.md)). **No piece cap** — `crafts_done_this_chapter` may increment (telemetry) but **never** gates craft. Decline: Phase-1 once per chapter at −reps (Later: reschedule at rep cost).

## Event pool (`E*`)

Events are **`E*`**. Keep **adventurer / appointment ids** on the row when they exist (`adv_*`, `appt_*`). Each event has **day window(s)**:

| Shape | Example |
|---|---|
| Single day | E1 shop **D2** |
| Inclusive range | E3 event **D2–D3** |
| Discrete days | E4 adv **D2 & D6** |

**Fixed window** = cannot move (pins inside that window, still on assignable days only).

UI **options panel** lists the events whose window includes the inspected day. **M1 / current test: 2–4 options per day.** Exception: **D1 may only list the first-customer adventurer option(s)**.

### Current map (N=8) — M1 / Test sketch

Assignable D1..D6. Reserved D7 / D8. Titles are Test stubs; **windows / kinds / 2–4-per-day / D1 exception / Scrap Duelist as `appt_*` are LOCKED** for this map’s sketch.

| id | Kind | Window | Fixed | Ref | Stub title |
|---|---|---|---|---|---|
| **E5** | adventurer | **D1** | yes | `adv_*` first customer | First customer |
| **E1** | shop | **D2** | yes | — | Wagon shop |
| **E2** | adventurer | **D2** | no | `adv_*` | Road walk-in |
| **E3** | event | **D2–D3** | no | — | Road event |
| **E4** | adventurer | **D2 & D6** | no | `adv_*` | Repeat caller |
| **E6** | shop | **D3–D4** | no | — | Wayside stall |
| **E8** | appointment | **D3** | yes | `appt_scrap_duelist` | Scrap Duelist |
| **E13** | event | **D3** | no | — | Wagon trouble |
| **E7** | event | **D4** | no | — | Crossroads |
| **E9** | adventurer | **D4–D5** | no | `adv_*` | Named walk-in |
| **E14** | prep | **D4 & D5** | no | — | Prep craft |
| **E10** | shop | **D5–D6** | no | — | Last stall |
| **E11** | event | **D5** | no | — | Weather |
| **E12** | adventurer | **D6** | no | `adv_*` | Late walk-in |

Options per day (current map):

| Day | Options (2–4; D1 exception) | Assignable |
|---|---|---|
| **D1** | E5 only — first-customer adventurer | yes |
| **D2** | E1, E2, E3, E4 | yes |
| **D3** | E3, E6, E8, E13 | yes |
| **D4** | E6, E7, E9, E14 | yes |
| **D5** | E9, E10, E11, E14 | yes |
| **D6** | E4, E10, E12 | yes |
| **D7** | *(none — travel / final prep)* | **reserved** |
| **D8** | *(none — boss approach)* | **reserved** |

E1 / E2 / E3 / E4 match the stamp examples (shop D2; adv D2; event D2–D3; adv D2 & D6). E5 is the D1 first-customer exception. E8 is Scrap Duelist — **appointment**, not Dex Adventurers.

Later maps stamp their own `E*` pool + `map.day_count`. Do not reuse this table as law for a 3-day or 12-day map.

## Piece cap — GONE (LOCKED)

- **No** `crafts_max`. **No** garments-per-chapter ceiling.
- Stamina per craft session **unchanged** (`12 * N` draft, Finish-only, [27](27-craft-mode-stamina.md)).
- `cant_craft` because `crafts_done == crafts_max` is **GONE**. Do not emit that fail.
- Mid-fail from **other** causes may stay (`24`: F + hp>0 + aid 0 for a true session-open fail). Empty zone at Finish is **not** `cant_craft` (`27`).

## Boss

- Announced at chapter start (favor / punish / environment from `17`). Newspaper announces the **boss**, not the client (`26`).
- After the day budget (including reserved last-2), **draw one adventurer from the M1 4-job pool** (`28` / `29`: Knight, Mage, Blade Dancer, Lagoon — **LOCKED** Jonathan 2026-10-08) → **craft that job’s order constructions** → that **adventurer** fights the announced boss. Sim uses **that client's gear**. Player is not the fighter (`03`, `17`, `28`). Do **not** draw Wizard / Hexer / Outrider / Oathbound in M1.
- Pool is **shared across all bosses / chapters**, by **job title**. Draw is **independent** of `chapter_boss_id`. Order constructions are the listed `con_*` for that job.
- Boss fail (boss-client / adventurer dead / hard loss): **`run_over`**, no retry (Phase-1 hardcore).
- **Appointments stay appointments.** Scrap Duelist and other mid-chapter named clients are `appt_*`. They are **not** the boss-client. Do not pin Scrap Duelist to reserved days or the boss beat. Do **not** put `appt_*` on the Dex Adventurers tab (`31`).
- Portraits / UI widgets = **Later**. Job catalog is stamped in `28` — do not invent Godot scenes or art.

## Client needs (Ulquiorra)

Docs only this stamp — sketch for the next Client PR. No `src/` here.

1. **No piece cap.** Do not block craft when `crafts_done` is high. Do not show a 4/4 garments meter. Do not emit `crafts_max`. Do not fire `cant_craft` because of piece count.
2. **Day labels.** Timeline says **D1..DN** (N = `map.day_count`). Never R1. Current map N=8.
3. **Options panel.** Expand / popup on a day lists that day’s `E*` (2–4; D1 may be first-customer only). Show kind + stub title + window + fixed flag. Keep `adv_*` / `appt_*` on the row when present.
4. **Assign at chapter start.** After the boss newspaper, player assigns one option per D1..(N−2). Reserved last-2 visible, not clickable-to-assign.
5. **Mid-chapter update.** Remaining unplayed assignable days can be reassigned. Past days frozen.
6. **Fixed windows pin.** Fixed events cannot be moved off their window. Player cannot drop them on reserved days.
7. **Reserved last-2.** Current map: D7 travel / final prep, D8 boss approach. Relative to N on other maps.
8. Scrap Duelist stays an appointment row — not Dex Adventurers.

## Test logs (Szayelaporro)

Log on chapter-start assign, on mid-chapter update, and on each day resolve. **Not** all of these must become `20` Required — Required list is in [20](20-harness-stamp.md).

| Key | When / what |
|---|---|
| `CHAPTER_DAY_COUNT` | = `map.day_count` (current map **8**) |
| `day_index` / `days_left` | Live day; remaining including reserved |
| `event_pool` | Full `E*` rows `{ event_id, kind, windows, fixed, ref_id }` |
| `day_assignments` | `{ day_index, event_id }[]` after start assign and after each mid-update |
| `day_action` | Assigned kind this day (null before pick / on newspaper) |
| `crafts_done_this_chapter` | Unbounded piece counter (optional telemetry) |
| `cant_craft` | Only true session-open fail — **never** because of piece count |
| `appt_*` / `adv_*` | On the event row; Scrap Duelist is `appt_*` |

**Asserts (planner)**

1. No `crafts_max` field. No `cant_craft` from `crafts_done`.
2. `CHAPTER_DAY_COUNT == map.day_count` — current-map dumps use **8**; do not assert 8 on a later 3- or 12-day map.
3. Player assignments only on `1 .. CHAPTER_DAY_COUNT-2`.
4. Labels / dump ids use **D** / `day_*`, not R / `round_*`.
5. Fixed events: assigned `day_index` ∈ that event’s window, and that day is assignable.
6. Reserved last-2: no appointment / player `E*` assignment.
7. D1 current-map sketch: options ⊆ {E5} (first-customer). Other assignable days: 2–4 options from the pool.
8. `appt_scrap_duelist` is never `boss_client_id` and never a Dex Adventurers `adv_*`.

## Explicit non-goals

- Branching StS path map
- Auto 3-node shop↔craft clock
- Forcing a craft every day
- `crafts_max` / piece cap / cant_craft-at-max
- Hardcoding 8 as global day-count law
- Putting Scrap Duelist / `appt_*` on Dex Adventurers
- R1..R8 labels

## Supersedes

- Round board / R1..R8 / `CHAPTER_ROUND_COUNT=8` as **global** law (2026-09-28 `22` / `20` / `STAMP`)
- Chapter-start **2–4 appointment pins** as the only assign UX
- `crafts_max=4` garments / chapter; `cant_craft` when `crafts_done == crafts_max`
- 1-of-3 card lineup ([22-chapter-flow](22-chapter-flow.md)) — still history

## Pointers

`20` stamps · `24` win-con (cant_craft not at-max) · `27` stamina · `25` reps · `26` newspaper · `17` bosses · `28` boss-client pool · `29` adventurers · `31` Dex · `01` loop · `03` people
