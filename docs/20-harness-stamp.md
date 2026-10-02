# Harness stamp fields (Phase-1 lock)

**Status:** Design stamped 2026-10-02. **Doc id: `20`.** Assert-ready field list for **Szayelaporro (Test)** / Client **1B**. One dump = one stamp. Live chapter = schedule board ([22](22-chapter-schedule.md)). Live craft = stamina ([27](27-craft-mode-stamina.md)).

> **Not live — do not assert.** `lineup_card_ids`, `picked_card_id`, and `max_materials` / `max_runes` (2m1r) track the superseded 1-of-3 / slot-fill shell. They are **not** Required. See [Superseded](#superseded).

Headless **client × threat × build** dumps — same job as the 1A row: readable, assertable. Multi-piece order = **N sessions, one stamp each**.

## Constants (Phase-1 draft)

| Key | Value | Notes |
|---|---:|---|
| `CHAPTER_ROUND_COUNT` | **8** | Rounds 1..8 |
| `crafts_max` | **4** | Garments / chapter |
| Appointment pins | **2–4** | At chapter start; not on last 2 rounds |
| Reserved rounds | last **2** | No appointments (rounds 7–8) |
| Primary actions / round | **1** | Phase-1 |
| `stamina_start` | **12** | Per piece |
| `hand_size` | **5** | No auto-refill |
| `dig_refresh_cost` | **2** | Stamina |
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

### Schedule board

| Field | Type | Notes |
|---|---|---|
| `CHAPTER_ROUND_COUNT` | int | Always **8** |
| `round_index` | int\|null | 1..8 on schedule / craft stamps; null on chapter-start newspaper |
| `rounds_left` | int | Remaining schedule rounds (includes reserved) |
| `round_action` | enum\|null | `appointment` \| `walk_in` \| `wagon_shop` \| `wagon_event` \| `prep_craft` \| `rest_dig` — the **one** primary action this round |
| `appointment_pins` | object[] | Chapter-start pins: `{ appointment_id, order_id, pinned_round }` — length **2..4**; each `pinned_round` ∈ 1..6 |
| `appt_decline_used` | bool | Phase-1: decline allowed **once** / chapter (−reps) |
| `crafts_done_this_chapter` | int | Finished garments this chapter (0..4). Increments per finished **piece**, not per order |
| `crafts_max` | int | Always **4** |
| `phase` | enum | `schedule` \| `craft` \| `boss` \| `newspaper` |

**Lock:** `crafts_done_this_chapter` / `crafts_max=4` counts **pieces** (each construction in a multi-piece order), not whole orders. Example: armor + gloves = 2 of 4.

`phase` **does not** include `shop` or `craft_task` (old lineup shell). Wagon shop is a `round_action` on `phase=schedule`. Travel events are `round_action=wagon_event`. Boss beat: craft **for the boss-client** (`phase=craft` + `mission_kind=boss`), then `phase=boss` for the sim — that **client** fights, not the player (`17`).

### Mission (when `phase=craft` or `phase=boss`)

| Field | Type | Notes |
|---|---|---|
| `mission_kind` | enum\|null | `order` \| `event` \| `boss` \| `prep` — null on pure schedule / newspaper stamps |
| `order_id` | string\|null | Client / appointment / walk-in / prep / **boss-client** order |
| `threat_id` | string\|null | Client or event or boss threat key |
| `construction_ids` | string[] | Order-fixed list (`con_*`); **not** player-picked |
| `construction_id` | string\|null | Current piece = `construction_ids[piece_index-1]` |
| `card_difficulty` | int\|null | 1..3 — reps Δ input (`25`); not a lineup card |

Prep (`mission_kind=prep`) still runs the resolver on finish; mission-sim fields may be null (ready-rack, no live client). Walk-in / appointment enter craft as `order`. Wagon event that does not enter craft stays `phase=schedule` with session fields null.

**Boss-client (Jonathan 2026-10-02):** a **client is responsible for the boss event**. Player crafts **for that client**; the **client fights** the announced boss — player is not the fighter. On the boss beat: `mission_kind=boss`; `order_id` = the **boss-client's order**; `threat_id` = announced `chapter_boss_id`; `construction_ids` from that order. Sim uses **that client's gear**. Boss-client roster / ids = **Later** — do not invent catalog this stamp. No extra Client UI widgets this stamp.

### Stamina craft session (when `phase=craft`)

| Field | Type | Notes |
|---|---|---|
| `piece_index` | int | 1-based; this stamp's piece |
| `piece_count` | int | `len(construction_ids)` — N pieces → N stamps |
| `stamina_start` | int | Phase-1 draft **12** per piece |
| `stamina_remaining` | int | ≥ 0 at stamp |
| `stamina_spent` | int | Plays + digs (after modifiers) |
| `hand_size` | int | Phase-1 draft **5** |
| `dig_refresh_cost` | int | Phase-1 draft **2** |
| `dig_count` | int | Refresh / dig calls this piece |
| `cards_played` | object[] | `{ id, type, cost }` — `type` ∈ {`material`, `rune`, `skill`}; `cost` ≥ 0 after modifiers. Play of any type **leaves the hand** → discard (unless a special card says otherwise) |
| `early_finish` | bool | **Superseded as a distinct end.** If emitted: player clicked Finish (same as `player_finish`). Not “stop before empty.” |
| `finish_reason` | enum | **`player_finish` only** — Finish button. Phase-1 legal end. |

Null the session block when not in craft (schedule shop / event / rest, newspaper). `cant_craft` stamps have no legal session — see asserts.

Skills in `cards_played` are owner skills (manipulate the session, then leave). They are not sewn into the garment unless a skill explicitly says so (none in Phase-1 draft).

**Finish only (supersedes stamina_0 auto-finish):** piece ends when the player clicks **Finish** — `finish_reason == player_finish`. `stamina_remaining == 0` / `stamina_0` is **state**, not end. Cards stay; resolver waits. `finish_reason: stamina_0` and “empty stamina auto-crafts” are **superseded**. Prefer `player_finish` over `early_finish` — Finish is the only button, whether stamina is 0 or not. **0-cost cards** / further owner abilities at 0 stamina = **Later** (`27`) — do not invent catalog or assert them.

**Hand cycle (supersedes durable-in-hand, #17):** play any card → it **leaves the hand** → **discard** (unless a special card says otherwise). Refresh / dig: remaining hand drops to discard, then draw up to `hand_size` from the **draw** pile; if draw is short mid-draw, **shuffle discard into draw** and continue. Cards remain in the **run deck** via reshuffle — not deleted from the atelier, and **not** “stay in hand after play.” Stamina still costs on play. Hand / draw / discard pile arrays are Design law in [27](27-craft-mode-stamina.md) — not extra Required dump fields unless Test later stamps them.

Round-generated **consumable** cards (Later; distinct type, **not** in this enum) **burn** on use when stamped. Do not emit a fake consumable field.

**Live item readout** (Design UX in [27](27-craft-mode-stamina.md)): Current stats + Potential outlook (locked / hidden if outlook not unlocked). Not a Phase-1 dump assert — no extra stamp fields. Unchanged from stamp 2.

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
| `cant_craft` | bool | Could not open a legal craft session |

`rating_score` (0..100) is UI/debug only — **not** asserted (`23`).

## Asserts

Test checks these. Lineup length / pick-1-of-3 / 2m1r slot caps are **not** asserts.

### Identity / resolver spine

1. `player_owner_id == "own_basic"` in Phase-1.
2. If `craft_rarity` ∈ {rare, legendary} → `powers_negative == []`.
3. If `powers_negative` non-empty → `outlook_order` equals max among fired outlook-bearing rows (neg may win the look).
4. `cleared == (hp_remaining > 0 ∧ rating ∈ {S,A,B,C})`.
5. Boss fail (boss-client / adventurer dead / hard loss) → `run_over == true` ∧ `run_over_reason == "boss_death"` — no retry.

### Schedule board

6. `CHAPTER_ROUND_COUNT == 8`; on schedule / craft stamps `round_index` ∈ 1..8.
7. Phase-1: exactly **one** `round_action` per round (null only before the player picks, or on non-schedule stamps).
8. Every `appointment_pins[].pinned_round` ∈ 1..6 — **not** rounds 7–8.
9. `len(appointment_pins)` ∈ 2..4 at chapter start; pins do not move onto reserved rounds.
10. `crafts_done_this_chapter ≤ crafts_max` and `crafts_max == 4`. `cant_craft` does not increment `crafts_done_this_chapter`.
11. `phase` ∈ {`schedule`, `craft`, `boss`, `newspaper`} — never `shop` or `craft_task`.

### Stamina craft

12. `construction_id` / `construction_ids` come from the **order**, not a player construction pick. No construction cards in `cards_played`.
13. `cards_played[].type` ∈ {`material`, `rune`, `skill`} only. Play of any type **leaves the hand** → discard (unless a special card says otherwise). The card stays in the run deck via discard→reshuffle — not deleted from the atelier. Consumable type is Later — do not assert a field that is not in the enum.
14. Piece ends iff the player clicks **Finish** — `finish_reason == player_finish`. `stamina_remaining == 0` does **not** end the piece or run the resolver. `finish_reason: stamina_0` is **superseded** (must not mean auto-craft). Empty hand / empty stamina is legal until Finish. If `early_finish` is still emitted, it must agree with `player_finish` (Finish click) — not a second path.
15. Each dig spends `dig_refresh_cost` stamina. `stamina_spent` includes play costs + `dig_count * dig_refresh_cost` (after skill modifiers). Hand does **not** auto-refill. On dig: remaining hand cards drop to discard, then draw up to `hand_size` from the draw pile; if draw is short mid-draw, shuffle discard into draw and continue. Empty hand is legal until a dig or finish.
16. `piece_count` ≥ 1; multi-piece orders emit **one stamp per piece** (`piece_index` 1..`piece_count`). Resolve piece N before starting N+1.
17. Phase-1 draft knobs on the session: `stamina_start == 12`, `hand_size == 5`, `dig_refresh_cost == 2` unless a skill this piece changed a cost.

### cant_craft / reps / newspaper (prior intent kept)

18. `cant_craft` → `rating == F` ∧ `hp_remaining > 0` ∧ `damage_aid_pct == 0` ∧ `cleared == false` ∧ normal fail reps Δ (not death Δ). No stamina session / no construction pick required.
19. After last schedule round, `reps_after < reps_gate` → `run_over` ∧ `run_over_reason == "reps_gate_miss"`.
20. Mid death (`hp_remaining ≤ 0`, not `cant_craft`) → large −reps (`−3 * card_difficulty` per `25`).
21. Always `apply_reps` after an order mission (including `cant_craft`).
22. Newspaper fields set when the beat applies (`26`): chapter start → `boss_announce`; mid fail → `mid_fail`; chapter end / run over as listed.

## Superseded

| Field / assert | Why |
|---|---|
| `lineup_card_ids` | 1-of-3 chapter shell — [22-chapter-flow](22-chapter-flow.md) |
| `picked_card_id` | Same |
| Assert: `len(lineup_card_ids)==3` ∧ pick ∈ lineup | Same |
| `max_materials` / `max_runes` (defaults 2 / 1) | 2m1r slot UI — [12b-craft-slots](12b-craft-slots.md) |
| Assert: `len(materials)` ∈ 1..`max_materials` / `construction.material_slots` | Stamina + order-fixed construction replace slot caps |
| `phase` ∈ {`shop`, `craft_task`} | Wagon shop is a schedule action; craft is stamina |
| Assert: `material` play does not decrement inventory / stock | Durable-in-hand (#17) — superseded: play → discard; persist via reshuffle ([27](27-craft-mode-stamina.md)) |
| `finish_reason: stamina_0` as craft-end / auto-resolver | **Stamina 0 ≠ finish** — piece stays open; only Finish crafts ([27](27-craft-mode-stamina.md)) |
| `early_finish` as a distinct end path vs `stamina_0` | Finish is the only legal Phase-1 end (`player_finish`) |

Do **not** emit these as Required. History only.

## Pass look

Overall adventure **trend** vs the announced boss — not every matrix cell non-cliff. Smoke Mid/Mid only after Design stamps a lever.

## Pointers

- Live: [22-chapter-schedule](22-chapter-schedule.md) · [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Resolver / report: [23-mission-report](23-mission-report.md) · [24-win-conditions](24-win-conditions.md) · [25-reps-meter](25-reps-meter.md) · [26-newspaper](26-newspaper.md) · [14-synergies](14-synergies.md) (RETUNE merged)
- Legacy (not live): [22-chapter-flow](22-chapter-flow.md) · [12b-craft-slots](12b-craft-slots.md)
