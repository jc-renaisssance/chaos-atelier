> **Note (2026-10-12):** Live chapter = **Day planner** ([22-chapter-schedule](22-chapter-schedule.md)). `CHAPTER_DAY_COUNT` = `map.day_count` (current map **8** — not global law). **Piece cap / `crafts_max` GONE.** Win/loss outcomes still apply. Old 1-of-3 lineup wording below is history.

# Win conditions (Phase-1 lock)

**Mission clear gate (one only):**

```
cleared = (hp_remaining > 0) AND (rating ∈ {S, A, B, C})
```

Clear floor **C** — pending Test tune.

## Mission / order

| Result | Rules |
|---|---|
| **Clear** | HP > 0 ∧ rating ∈ {S,A,B,C} → +reps (rating × difficulty) |
| **Fail** | HP ≤ 0 or D/F → −reps; HP ≤ 0 mid → large −reps |
| **Can’t craft** | `F`, `hp_remaining>0`, aid 0 — normal fail Δ, no death Δ. **Not** a piece-cap. `crafts_max` is **GONE**; `cant_craft` because `crafts_done == crafts_max` does **not** exist. Other session-open fails may still emit this row. |
| Mid-fail | Continue; newspaper headline |

## Chapter

| Event | Effect |
|---|---|
| Days | **Live:** Day planner, ``CHAPTER_DAY_COUNT = map.day_count`` (current map **8**) ([22](22-chapter-schedule.md)). Player assigns D1..(N−2); last 2 reserved. **No piece cap.** **Legacy:** 3 lineups of 3 cards / pick 1 — superseded. Round board / `CHAPTER_ROUND_COUNT=8` as law — superseded. |
| Order pick | shop → craft → report |
| Event pick | resolve event (ends day) |
| After days | `reps < reps_gate` → `run_over` (`reps_gate_miss`) |
| Boss fail | Adventurer dead → `run_over`, no retry |

## Run

Win = clear C1–C3 bosses. `run_over` = boss death or reps gate miss.

## Pointers

`25` reps · `26` newspaper · `22` Day planner · `23` report · `20` stamps · `17` bosses · `28` boss-client pool
