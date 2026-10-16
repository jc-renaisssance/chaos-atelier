# Reps meter (atelier trust)

Jonathan lock (2026-09-22): **reps / trust** meter. Mid picks move it; chapter has a **reps gate** within the **day budget**. Miss → **run fail** (competitors / shop broken). Live days = [22 route map](22-chapter-schedule.md) (`map.day_count`; current map **8**).

## Meter

| Field | Notes |
|---|---|
| `reps` | Integer trust (start **0**; floor 0) |
| `reps_gate` | Minimum before boss |
| `days_left` | Day-planner days remaining *(was `rounds_left` / card-lineup; live = [22](22-chapter-schedule.md))* |

### Phase-1 draft numbers (tune in Test)

| Chapter | `reps_gate` | Days (live) |
|---|---:|---|
| C1 | **8** | `map.day_count` (current map **8**; old table **3** was 1-of-3) |
| C2 | **14** | same — not a hardcoded 3 |
| C3 | **20** | same |

## Delta

```
rating_mult = {S:3, A:2, B:1.5, C:1, D:0, F:0}
# card.difficulty: 1 easy · 2 normal · 3 hard

if cleared:
  Δreps = round(rating_mult[rating] * card.difficulty)
else:
  Δreps = -card.difficulty
  if hp_remaining <= 0:             # death on order mid ONLY
    Δreps = -3 * card.difficulty
  # cant_craft: F + hp>0 → normal fail Δ only

reps = max(0, reps + Δreps)
```

Always `apply_reps` after an order mission (including cant_craft from **other** session-open fails). `cant_craft` at piece-cap does **not** exist (`crafts_max` GONE). **Route-map events** apply smaller Δ from the M1 catalog — **[32](32-shop-and-events.md)** (typically ±1; floor `reps` at 0). Not the order rating formula. No run-kill from a single M1 event pick.

## Gates

| Check | Fail |
|---|---|
| After last day, `reps < reps_gate` | `run_over` / competitors |
| Boss fail | `run_over` / adventurer dead — no retry |

## Stamps

`reps_before/after/delta`, `reps_gate`, `days_left` (not `rounds_left`), `card_difficulty` (was node_difficulty), `run_over_reason`.
