# Harness stamp fields (Phase-1 lock)

**Status:** Design stamped 2026-10-12 (Day planner + drop `crafts_max`). **Doc id: `20`.** Assert-ready field list for **Szayelaporro (Test)** / Client **1B**. One dump = one stamp. Live chapter = **Day planner** ([22](22-chapter-schedule.md)). Live craft = stamina ([27](27-craft-mode-stamina.md)). **Supersedes** Round-board dumps (`CHAPTER_ROUND_COUNT` as always-8, `round_*`, `crafts_max=4`).

> **Not live — do not assert.** `lineup_card_ids`, `picked_card_id`, and `max_materials` / `max_runes` (2m1r) track the superseded 1-of-3 / slot-fill shell. They are **not** Required. See [Superseded](#superseded).

Headless **client × threat × build** dumps — same job as the 1A row: readable, assertable. Multi-piece order = **one session**, **N stamps at Finish** (one per piece). **Supersedes** sequential N sessions.

## Constants (Phase-1 draft)

| Key | Value | Notes |
|---|---:|---|
| `CHAPTER_DAY_COUNT` | **`map.day_count`** | **Map setting — not global law.** Current map = **8**. Later maps may be 3 or 12. Example dumps use 8. |
| `crafts_max` | **GONE** | Unlimited pieces / chapter. Do **not** emit. |
| Event pool | `E*` | Windows per event; M1 / current test **2–4 options / day** (D1 may be first-customer only) |
| Reserved days | last **2** of N | Player assigns D1..(N−2) only. Current map: D7 travel / final prep, D8 boss approach |
| Primary actions / day | **1** | Phase-1 |
| `stamina_start` | **12 × N** | Session pool; N = `piece_count` (draft) |
| `zone_count_max` | **4** | Unused zones empty if N < 4; N > 4 = Later |
| `hand_size` | **5** | No auto-refill |
| `dig_refresh_cost` | **2** | Stamina (not × N) |
| Common / uncommon / rare mat cost | 1 / 2 / 3 | Play cost |
| Enchantment play cost | **2** | |
| Phase-1 owner | `own_basic` | |

## Required fields

### Identity

| Field | Type | Notes |
|---|---|---|
| `run_id` | string | Unique dump id |
| `player_owner_id` | string | Phase-1 always `own_basic` |
| `chapter_id` | int | 1..3 |
| `chapter_boss_id` | string | Announced at chapter start (`17`) |
| `boss_pool_id` | string | Pool the boss was drawn from |
| `boss_client_id` | string\|null | `adv_*` from the shared job pool (`28`). Required on `mission_kind=boss`; null otherwise |
| `boss_job_id` | string\|null | matching `job_*` title (`28`). Required on `mission_kind=boss`; null otherwise |

### Day planner

| Field | Type | Notes |
|---|---|---|
| `CHAPTER_DAY_COUNT` | int | = `map.day_count` this chapter. Current map **8**. **Not** always-8 law. |
| `day_index` | int\|null | 1..N on planner / craft stamps; null on chapter-start newspaper. Labels **D1..DN** |
| `days_left` | int | Remaining days (includes reserved) |
| `day_action` | enum\|null | `appointment` \| `walk_in` \| `wagon_shop` \| `wagon_event` \| `prep_craft` \| `rest_dig` — the **one** primary action this day (from the assigned `E*`) |
| `event_pool` | object[] | `{ event_id, kind, windows, fixed, ref_id }`. `event_id` = `E1`… ; `kind` ∈ {`shop`, `adventurer`, `appointment`, `event`}; `ref_id` = `adv_*` / `appt_*` / null. M1 panel = **type + id** — no title field. Current-map sketch in [22](22-chapter-schedule.md) |
| `day_assignments` | object[] | `{ day_index, event_id }` — player-assigned (and fixed pins). Only `day_index` ∈ 1..(N−2) |
| `appointment_pins` | object[] | `appt_*` rows still on the planner: `{ appointment_id, order_id, pinned_day }`. Scrap Duelist stays here. `pinned_day` ∈ 1..(N−2) |
| `appt_decline_used` | bool | Phase-1: decline allowed **once** / chapter (−reps) |
| `crafts_done_this_chapter` | int | Finished **pieces** this chapter — **unbounded** telemetry. Increments per finished piece, not per order. **Not a gate** |
| `phase` | enum | `schedule` \| `craft` \| `boss` \| `newspaper` — dump name `schedule` = **on the Day planner** (kept; do not invent `phase=planner` this stamp) |

**Do not emit `crafts_max`.** **Do not emit `CHAPTER_ROUND_COUNT` / `round_index` / `rounds_left` / `round_action` / `pinned_round`.** Those names are superseded.

**Lock:** no piece cap. `crafts_done_this_chapter` may count pieces (armor + gloves = +2) after the **one** Finish — it does **not** block the next craft. `cant_craft` because `crafts_done == crafts_max` is **GONE**.

`phase` **does not** include `shop` or `craft_task` (old lineup shell). Wagon shop is a `day_action` on `phase=schedule` (Day planner). Travel events are `day_action=wagon_event`. Boss beat: draw from the **M1 4-job pool** (`28` / `29` — Knight, Mage, Blade Dancer, Lagoon; **LOCKED** Jonathan 2026-10-08), then craft **that job’s order constructions** (`phase=craft` + `mission_kind=boss`), then `phase=boss` for the sim — that **adventurer** fights, not the player (`17`). Do not draw Wizard / Hexer / Outrider / Oathbound.

### Mission (when `phase=craft` or `phase=boss`)

| Field | Type | Notes |
|---|---|---|
| `mission_kind` | enum\|null | `order` \| `event` \| `boss` \| `prep` — null on pure Day-planner / newspaper stamps |
| `order_id` | string\|null | Client / appointment / walk-in / prep / **boss-client** order (`ord_*` from `28` on the boss beat) |
| `threat_id` | string\|null | Client or event or boss threat key |
| `construction_ids` | string[] | Order-fixed list (`con_*`); **not** player-picked |
| `construction_id` | string\|null | Current piece = `construction_ids[piece_index-1]` |
| `card_difficulty` | int\|null | 1..3 — reps Δ input (`25`); not a lineup card |

Prep (`mission_kind=prep`) still runs the resolver on finish; mission-sim fields may be null (ready-rack, no live client). Walk-in / appointment enter craft as `order`. Wagon event that does not enter craft stays `phase=schedule` with session fields null.

**Boss-client (Jonathan 2026-10-02):** a **client is responsible for the boss event**. Player crafts **for that client**; the **client fights** the announced boss — player is not the fighter. On the boss beat: `mission_kind=boss`; `boss_client_id` = named `adv_*` drawn from the **M1 4-job pool** (`28` / `29` — Knight, Mage, Blade Dancer, Lagoon; **LOCKED** Jonathan 2026-10-08); `boss_job_id` = matching `job_*`; `order_id` = that job’s `ord_*`; `construction_ids` = that job’s **order constructions** (listed `con_*`, in sequence — e.g. knight = `con_armor`, `con_gloves`); `threat_id` = announced `chapter_boss_id`. Draw is **independent** of which boss was announced. Do **not** draw Wizard / Hexer / Outrider / Oathbound in M1. Sim uses **that client's gear**. `boss_client_id` is **never** an `appt_*` (Scrap Duelist and other appointments stay on the **Day planner**, not Dex Adventurers). Finish-only / multi-piece / StS craft **unchanged**. Portraits / extra Client UI widgets = **Later**.

### Stamina craft session (when `phase=craft`)

| Field | Type | Notes |
|---|---|---|
| `piece_index` | int | 1-based; this stamp's piece (`construction_ids[piece_index-1]`) |
| `piece_count` | int | `len(construction_ids)` — N pieces → **N stamps, one session** |
| `zone_count` | int | Live drop zones this session. Phase-1: **`== piece_count`**, ∈ 1..4 |
| `stamina_start` | int | Phase-1 draft **`12 * piece_count`** — **session** pool, not per piece |
| `stamina_remaining` | int | ≥ 0 at stamp — **session** value (shared); repeated on each piece stamp |
| `stamina_spent` | int | Plays + digs (after modifiers) — **session** value |
| `hand_size` | int | Phase-1 draft **5** |
| `dig_refresh_cost` | int | Phase-1 draft **2** (not × N) |
| `dig_count` | int | Refresh / dig calls this **session** |
| `cards_played` | object[] | `{ id, type, cost, zone_index, construction_id }` — `type` ∈ {`material`, `rune`, `skill`}; `cost` ≥ 0 after modifiers; `zone_index` 1-based ∈ 1..`zone_count`; `construction_id` = `construction_ids[zone_index-1]`. Play of any type **leaves the hand** → discard (unless a special card says otherwise). Stamp may list the **session** plays or this piece's bag only; Test filters by `zone_index` for the bag |
| `early_finish` | bool | **Superseded as a distinct end.** If emitted: player clicked Finish (same as `player_finish`). Not “stop before empty.” |
| `finish_reason` | enum | **`player_finish` only** — one Finish ends the **session**. Every piece stamp from that Finish uses `player_finish`. |

Null the session block when not in craft (planner shop / event / rest, newspaper). `cant_craft` stamps have no legal session — see asserts. **`cant_craft` is not a piece-cap** — that fail is **GONE**.

Skills in `cards_played` are owner skills (manipulate the session, then leave). They are not sewn into the garment unless a skill explicitly says so (none in Phase-1 draft). Phase-1: skill plays still carry `zone_index` / `construction_id` (target bag). Skills that hit every zone = Later.

**Finish only (supersedes stamina_0 auto-finish):** session ends when the player clicks **Finish** — `finish_reason == player_finish`. **One Finish** resolves every zone in listed order and emits **one stamp per piece**. `stamina_remaining == 0` / `stamina_0` is **state**, not end. Cards stay; resolver waits. `finish_reason: stamina_0` and “empty stamina auto-crafts” are **superseded**. Prefer `player_finish` over `early_finish` — Finish is the only button, whether stamina is 0 or not. **0-cost cards** / further owner abilities at 0 stamina = **Later** (`27`) — do not invent catalog or assert them.

**Parallel multi-piece (supersedes sequential N sessions):** one shared stamina pool (`stamina_start == 12 * N`). Do **not** emit a stamp mid-session when piece N is “done” and then start N+1 with a fresh 12. Empty zone at Finish = construction-only bag for that stamp — **not** `cant_craft`. Do not invent a harsh empty-piece fail.

**Hand cycle (supersedes durable-in-hand, #17):** play any card → it **leaves the hand** → **discard** (unless a special card says otherwise). Refresh / dig: remaining hand drops to discard, then draw up to `hand_size` from the **draw** pile; if draw is short mid-draw, **shuffle discard into draw** and continue. Cards remain in the **run deck** via reshuffle — not deleted from the atelier, and **not** “stay in hand after play.” Stamina still costs on play. Hand / draw / discard pile arrays are Design law in [27](27-craft-mode-stamina.md) — not extra Required dump fields unless Test later stamps them.

Day-generated **consumable** cards (Later; distinct type, **not** in this enum) **burn** on use when stamped. Do not emit a fake consumable field.

**Live item readout** (Design UX in [27](27-craft-mode-stamina.md)): Current stats + Potential outlook for the **selected / active zone** (locked / hidden if outlook not unlocked). Not a Phase-1 dump assert — no extra stamp fields. Per-zone simultaneous readout = Later.

### Resolver outputs (craft finish / mission / boss)

| Field | Type | Notes |
|---|---|---|
| `tag_counts` | object | Tag → int (played mats + order construction + played runes) |
| `craft_rarity` | enum | `common` \| `uncommon` \| `rare` \| `legendary` (`18`) |
| `powers_positive` | string[] | `syn_*` / `uniq_*` fired |
| `powers_negative` | string[] | `syn_neg_*` fired; **must be []** if rarity ∈ {rare, legendary} |
| `outlook_id` | string | Winner look or `plain` |
| `outlook_order` | int | Winner order (0 if plain) |
| `stats` | object | `HP, ATK, DEF, RES, MOB, PRE` finals |
| `rating` | enum | **`S\|A\|B\|C\|D\|F`** — primary grade (`23`) |
| `hp_remaining` | 0..1 or int | Adventurer / gear soak left |
| `damage_aid_pct` | 0..100 | Feeds rating; not a win gate |
| `skill_effectiveness` | 1..5 | Feeds rating; not a win gate |
| `cleared` | bool | Derived: `hp_remaining > 0` ∧ `rating ∈ {S,A,B,C}` |
| `mission_failed` | bool | Fail trend (`24`) |
| `outcome` | enum\|null | `win` \| `lose` \| `mixed` — align with `cleared` when possible |
| `favor_tags_hit` | string[] | |
| `punish_tags_hit` | string[] | |
| `run_over` | bool | |
| `run_over_reason` | enum\|null | `reps_gate_miss` \| `boss_death` \| null |
| `reps_before` / `reps_after` / `reps_delta` | int | After `apply_reps` (`25`) |
| `reps_gate` | int | Chapter gate before boss |
| `newspaper_event` | enum\|null | `boss_announce` \| `mid_fail` \| `chapter_result` \| `run_over` |
| `newspaper_headline_id` | string\|null | Stable id (`26`) |
| `letter_id` | string\|null | Private letter (`23`) |
| `cant_craft` | bool | Could not open a legal craft session (**not** piece-cap — that cause is **GONE**) |

`rating_score` (0..100) is UI/debug only — **not** asserted (`23`).

## Asserts

Test checks these. Lineup length / pick-1-of-3 / 2m1r slot caps are **not** asserts.

### Identity / resolver spine

1. `player_owner_id == "own_basic"` in Phase-1.
2. If `craft_rarity` ∈ {rare, legendary} → `powers_negative == []`.
3. If `powers_negative` non-empty → `outlook_order` equals max among fired outlook-bearing rows (neg may win the look).
4. `cleared == (hp_remaining > 0 ∧ rating ∈ {S,A,B,C})`.
5. Boss fail (boss-client / adventurer dead / hard loss) → `run_over == true` ∧ `run_over_reason == "boss_death"` — no retry.

### Day planner

6. `CHAPTER_DAY_COUNT == map.day_count`. Current-map dumps use **8**; do **not** assert 8 as global law. On planner / craft stamps `day_index` ∈ 1..`CHAPTER_DAY_COUNT`. Do **not** emit `CHAPTER_ROUND_COUNT` / `round_index`.
7. Phase-1: exactly **one** `day_action` per day (null only before the player picks, or on non-planner stamps).
8. Every `day_assignments[].day_index` and `appointment_pins[].pinned_day` ∈ 1..(N−2) — **not** the reserved last 2. Current 8-day map: not D7–D8.
9. Fixed-window `E*` : assigned day ∈ that event’s window. Player cannot move a `fixed=true` event. Mid-chapter updates only change **unplayed** assignable days.
10. **No `crafts_max`.** Do not emit it. `crafts_done_this_chapter ≥ 0` unbounded — **not** a gate. `cant_craft` **must not** fire because of piece count. `cant_craft` (other causes) does not increment `crafts_done_this_chapter`.
11. `phase` ∈ {`schedule`, `craft`, `boss`, `newspaper`} — never `shop` or `craft_task`. `schedule` = on the Day planner.

### Stamina craft

12. `construction_id` / `construction_ids` come from the **order**, not a player construction pick. No construction cards in `cards_played`.
13. `cards_played[].type` ∈ {`material`, `rune`, `skill`} only. Each play has `zone_index` ∈ 1..`zone_count` and `construction_id == construction_ids[zone_index-1]`. Play of any type **leaves the hand** → discard (unless a special card says otherwise). The card stays in the run deck via discard→reshuffle — not deleted from the atelier. Consumable type is Later — do not assert a field that is not in the enum.
14. Session ends iff the player clicks **Finish** — `finish_reason == player_finish` on **every** piece stamp from that Finish. `stamina_remaining == 0` does **not** end the session or run the resolver. `finish_reason: stamina_0` is **superseded** (must not mean auto-craft). Empty hand / empty stamina is legal until Finish. If `early_finish` is still emitted, it must agree with `player_finish` (Finish click) — not a second path.
15. Each dig spends `dig_refresh_cost` stamina. `stamina_spent` includes play costs + `dig_count * dig_refresh_cost` (after skill modifiers). Hand does **not** auto-refill. On dig: remaining hand cards drop to discard, then draw up to `hand_size` from the draw pile; if draw is short mid-draw, shuffle discard into draw and continue. Empty hand is legal until a dig or finish. Dig is **session-wide** (not per zone).
16. `piece_count` ≥ 1; `zone_count == piece_count`; `zone_count` ∈ 1..4. Multi-piece = **one session**. Finish emits **one stamp per piece** (`piece_index` 1..`piece_count`) in **listed sequence**. Do **not** start a new session / new stamina pool per piece. `cards_played` entries carry `zone_index` + `construction_id`. N > 4 = Later — do not assert a fifth zone.
17. Phase-1 draft knobs on the session: `stamina_start == 12 * piece_count`, `hand_size == 5`, `dig_refresh_cost == 2` unless a skill this session changed a cost.

### cant_craft / reps / newspaper (prior intent kept)

18. `cant_craft` → `rating == F` ∧ `hp_remaining > 0` ∧ `damage_aid_pct == 0` ∧ `cleared == false` ∧ normal fail reps Δ (not death Δ). No stamina session / no construction pick required. **Cause is not piece cap** (`crafts_max` is GONE). Mid-fail from other session-open causes may stay.
19. After last day (including reserved), `reps_after < reps_gate` → `run_over` ∧ `run_over_reason == "reps_gate_miss"`.
20. Mid death (`hp_remaining ≤ 0`, not `cant_craft`) → large −reps (`−3 * card_difficulty` per `25`).
21. Always `apply_reps` after an order mission (including `cant_craft`).
22. Newspaper fields set when the beat applies (`26`): chapter start → `boss_announce`; mid fail → `mid_fail`; chapter end / run over as listed.
23. On `mission_kind=boss`: `boss_client_id` is a named `adv_*` from the **M1 4-job catalog** ([29](29-adventurer-catalog.md)) or that job’s default alias; `boss_job_id` ∈ `{job_knight, job_mage, job_blade_dancer, job_lagoon}` (**LOCKED** Jonathan 2026-10-08 — not Wizard / Hexer / Outrider / Oathbound); `construction_ids` equals that job’s **order constructions** (listed `con_*`, in sequence); `threat_id == chapter_boss_id`; `boss_client_id` is never an `appt_*`. Draw is independent of `chapter_boss_id`.

## Superseded

| Field / assert | Why |
|---|---|
| `lineup_card_ids` | 1-of-3 chapter shell — [22-chapter-flow](22-chapter-flow.md) |
| `picked_card_id` | Same |
| Assert: `len(lineup_card_ids)==3` ∧ pick ∈ lineup | Same |
| `max_materials` / `max_runes` (defaults 2 / 1) | 2m1r slot UI — [12b-craft-slots](12b-craft-slots.md) |
| Assert: `len(materials)` ∈ 1..`max_materials` / `construction.material_slots` | Stamina + order-fixed construction replace slot caps |
| `phase` ∈ {`shop`, `craft_task`} | Wagon shop is a Day-planner action; craft is stamina |
| `CHAPTER_ROUND_COUNT` always 8 / `round_index` / `rounds_left` / `round_action` / `pinned_round` | **Day planner** — `CHAPTER_DAY_COUNT` = `map.day_count`; `day_*` / `pinned_day` ([22](22-chapter-schedule.md)) |
| `crafts_max` / assert `crafts_done ≤ 4` / `cant_craft` at cap | **Piece cap GONE** — unlimited pieces; stamina still gates a session ([27](27-craft-mode-stamina.md)) |
| Chapter-start 2–4 `appointment_pins` as the only assign UX | Event pool `E*` + player assign D1..(N−2); fixed windows pin ([22](22-chapter-schedule.md)) |
| Assert: `material` play does not decrement inventory / stock | Durable-in-hand (#17) — superseded: play → discard; persist via reshuffle ([27](27-craft-mode-stamina.md)) |
| `finish_reason: stamina_0` as craft-end / auto-resolver | **Stamina 0 ≠ finish** — session stays open; only Finish crafts ([27](27-craft-mode-stamina.md)) |
| `early_finish` as a distinct end path vs `stamina_0` | Finish is the only legal Phase-1 end (`player_finish`) |
| Multi-piece = N sessions / `stamina_start == 12` per piece / resolve N then start N+1 | **One session**, `stamina_start == 12 * N`, one Finish → N stamps ([27](27-craft-mode-stamina.md)) |
| `cards_played` as `{ id, type, cost }` with no zone | Plays **must** target a zone: `{ id, type, cost, zone_index, construction_id }` |

Do **not** emit these as Required. History only.

## Pass look

Overall adventure **trend** vs the announced boss — not every matrix cell non-cliff. Smoke Mid/Mid only after Design stamps a lever.

## Pointers

- Live: [22-chapter-schedule](22-chapter-schedule.md) (Day planner) · [27-craft-mode-stamina](27-craft-mode-stamina.md) · [28-boss-client-pool](28-boss-client-pool.md) · [29-adventurer-catalog](29-adventurer-catalog.md) · [17-chapter-bosses](17-chapter-bosses.md)
- Resolver / report: [23-mission-report](23-mission-report.md) · [24-win-conditions](24-win-conditions.md) · [25-reps-meter](25-reps-meter.md) · [26-newspaper](26-newspaper.md) · [14-synergies](14-synergies.md) (RETUNE merged)
- Legacy (not live): [22-chapter-flow](22-chapter-flow.md) · [12b-craft-slots](12b-craft-slots.md)
