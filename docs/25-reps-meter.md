# Reps meter (atelier trust)

Jonathan lock (2026-09-22): a **reps / trust** meter for the shop. Mid missions move it; chapter has a **reps gate** within a **round limit**. Miss the gate → **run fail** (competitors take the street / shop broken).

## Meter

| Field | Notes |
|---|---|
| `reps` | Integer trust (start draft **0**; floor 0) |
| `reps_gate` | Per-chapter minimum to face boss / clear chapter economy |
| `rounds_left` | Mission picks remaining this chapter (route nodes) |

### Phase-1 draft numbers (tune in Test)

| Chapter | `reps_gate` | Route nodes (`rounds`) |
|---|---:|---:|
| C1 | **8** | **3** |
| C2 | **14** | **3** |
| C3 | **20** | **3** |

Start-of-chapter: `rounds_left = 3`. Each mission pick consumes one round (success or fail).

## Delta from mission result

```
rating_mult = {S:3, A:2, B:1.5, C:1, D:0, F:0}
# difficulty on the route node: 1 easy · 2 normal · 3 hard

if cleared:
  Δreps = round(rating_mult[rating] * node.difficulty)
else:
  Δreps = -node.difficulty          # fail lowers
  if hp_remaining <= 0:             # adventurer died on mid mission
    Δreps = -3 * node.difficulty    # large hit

reps = max(0, reps + Δreps)
```

Clear floor stays **C** (`24`) — pending Test tune.

## Gates

| Check | When | Fail fiction |
|---|---|---|
| After last mid-route node | `reps < reps_gate` | Competitors bury the shop / lease broken → **`run_over`** (not a boss death) |
| Boss fail | Adventurer died on boss | **`run_over`** — no retry (`24`) |

Boss is only offered if `reps >= reps_gate` after the route. If gate missed, newspaper prints the shutdown headline (`26`) and run ends.

## Harness stamps

`reps_before`, `reps_after`, `reps_delta`, `reps_gate`, `rounds_left`, `node_difficulty`, `run_over_reason` ∈ {`boss_death`, `reps_gate_miss`, …}.
