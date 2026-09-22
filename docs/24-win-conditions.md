# Win conditions (Phase-1 lock)

Team stamp (Jonathan ask + Aizen draft + Design/Client/Test/Finance +1, 2026-09-22).

**One gate only** for mission clear. Skill ★ and damage-aid % feed `rating` — they are **not** a second win check.

## Mission (client / event / boss sim row)

```
cleared = (hp_remaining > 0) AND (rating ∈ {S, A, B, C})
failed  = NOT cleared
```

| Result | Rules |
|---|---|
| **Clear** | HP > 0 and rating ≥ **C** (i.e. S/A/B/C) |
| **Fail** | HP ≤ 0 **or** rating **D/F** |
| Always | Emit full mission result card; fail still gets **partial gold**; letters may still fire on specials |
| Can’t craft | If `len(deck mats usable) < min_materials` (1) → **auto-fail**: `damage_aid_pct=0`, still full stamp row, **no soft-lock** |

## Chapter

| Event | Effect |
|---|---|
| Mid-mission fail | **Continue** — set `mission_failed`; chapter stays open; player is weaker into the boss (StS-style) |
| Chapter clear | Chapter **boss** cleared (`cleared == true` on boss row) |
| “2 mid-fails → chapter loss” | **Parked** (not Phase-1) |

## Run

| Event | Effect |
|---|---|
| **Win** | Clear C1 → C2 → C3 bosses (one path through the 27) |
| **Lose / `run_over`** | **Boss fail** (not cleared) — instant run-over |
| Boss retry shop | **No** in Phase-1 |
| Bankrupt | Covered by can’t-craft auto-fail; no separate soft-lock |

## Harness

- Stamp `cleared: bool` **derived** from `hp_remaining` + `rating` (don’t invent a third gate).
- Stamp `mission_failed` when mid-mission failed but chapter continues.
- Stamp `run_over` when boss fail ends the run.
- Pass look = overall clear **trend** vs announced boss (same spirit as DARE overall WR).

## Pointers

Mission card: `23` · Stamps: `20` · Flow: `21`/`22`
