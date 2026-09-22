# Win conditions (Phase-1 lock)

Team stamp + Jonathan reps/route/newspaper amend (2026-09-22).

**Mission clear gate (one only):** ★ / damage-aid feed `rating` only.

```
cleared = (hp_remaining > 0) AND (rating ∈ {S, A, B, C})
```

Clear floor **C** OK — pending Test tune.

## Mission

| Result | Rules |
|---|---|
| **Clear** | HP > 0 and rating ∈ {S,A,B,C} → **+reps** by rating × difficulty (`25`) |
| **Fail** | HP ≤ 0 or rating D/F → **−reps**; if HP ≤ 0 (adventurer died mid) → **large −reps** |
| Always | Full result card; partial gold on fail; letters may fire |
| Can’t craft | Auto-fail, `damage_aid_pct=0`, full stamp |
| Mid-fail UI | Continue chapter; **newspaper** mid-fail headline (`26`) |

## Chapter

| Event | Effect |
|---|---|
| Route | Player **picks** 3 mission nodes (StS-like) (`22`) |
| After route | If `reps < reps_gate` → **`run_over`** (`reps_gate_miss`) — competitors / shop broken |
| Boss offered | Only if reps gate met |
| Boss clear | Chapter clear; newspaper chapter result |
| Boss fail | Adventurer **died** → **`run_over`**, **no retry** |

## Run

| Event | Effect |
|---|---|
| **Win** | Clear C1–C3 bosses (27 paths) |
| **`run_over`** | Boss death **or** reps gate miss |

## Harness

- `cleared` derived from HP + rating only
- `reps_*`, `node_difficulty`, `run_over_reason`
- `newspaper_event` when paper prints
- Pass look = overall trend vs announced boss + reps trajectory

## Pointers

`25` reps · `26` newspaper · `22` route · `23` report · `20` stamps
