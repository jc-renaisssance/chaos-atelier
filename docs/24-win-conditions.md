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
| **Can’t craft** | `F`, `hp_remaining>0`, aid 0 — normal fail Δ, no death Δ |
| Mid-fail | Continue; newspaper headline |

## Chapter

| Event | Effect |
|---|---|
| Rounds | **3** lineups of **3 cards**; pick **1** each (order or event) — not a path map |
| Order pick | shop → craft → report |
| Event pick | resolve event (ends round) |
| After rounds | `reps < reps_gate` → `run_over` (`reps_gate_miss`) |
| Boss fail | Adventurer dead → `run_over`, no retry |

## Run

Win = clear C1–C3 bosses. `run_over` = boss death or reps gate miss.

## Pointers

`25` reps · `26` newspaper · `22` round picks · `23` report · `20` stamps
