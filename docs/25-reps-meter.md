# Reps meter (atelier trust)

Jonathan lock (2026-09-22): **reps / trust** meter. Mid picks move it; chapter has a **reps gate** within **round limit**. Miss → **run fail** (competitors / shop broken).

## Meter

| Field | Notes |
|---|---|
| `reps` | Integer trust (start **0**; floor 0) |
| `reps_gate` | Minimum before boss |
| `rounds_left` | Card-lineup rounds remaining |

### Phase-1 draft numbers (tune in Test)

| Chapter | `reps_gate` | Rounds |
|---|---:|---:|
| C1 | **8** | **3** |
| C2 | **14** | **3** |
| C3 | **20** | **3** |

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

Always `apply_reps` after an order mission (including cant_craft). Events may apply smaller Δ per event table.

## Gates

| Check | Fail |
|---|---|
| After last round, `reps < reps_gate` | `run_over` / competitors |
| Boss fail | `run_over` / adventurer dead — no retry |

## Stamps

`reps_before/after/delta`, `reps_gate`, `rounds_left`, `card_difficulty` (was node_difficulty), `run_over_reason`.
