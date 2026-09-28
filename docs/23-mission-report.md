# Adventure / mission report

Jonathan lock (2026-09-22): the adventure report is a **mission result**, not only flavor lines.

**Win / clear:** see **[24-win-conditions](24-win-conditions.md)** — one gate: `hp_remaining > 0` ∧ `rating ∈ {S,A,B,C}`.

## Mission result card

| Field | Type | Notes |
|---|---|---|
| `rating` | enum **`S\|A\|B\|C\|D\|F`** | **Primary harness grade — locked.** |
| `rating_score` | number 0..100 optional | Secondary UI/debug only — **not** asserted |
| `hp_remaining` | 0..1 or int | Adventurer / gear soak left |
| `damage_aid_pct` | 0..100 | Feeds rating; **not** a win gate |
| `skill_effectiveness` | 1..5 ★ | Feeds rating; **not** a win gate |
| `cleared` | bool | Derived: HP > 0 ∧ rating ∈ {S,A,B,C} |
| `outcome` | win \| lose \| mixed | Coarse trend; align with `cleared` when possible |
| `favor_tags_hit` | tags[] | |
| `punish_tags_hit` | tags[] | |
| `powers_noted` | ids[] | |

```
function build_mission_result(gear, threat, sim) -> MissionResult:
  ...
  rating = grade_letter(...)               # S|A|B|C|D|F
  cleared = (hp_left > 0) and (rating in {S,A,B,C})
  return MissionResult(..., cleared=cleared)
```

## Adventurer letter (special events only)

| Trigger | Letter tone (draft) |
|---|---|
| Sold / delivered gear with **neg syn** | Complaint / dark comedy |
| Delivered **rare** | Impressed |
| Delivered **legendary** / unique | Awe |
| **Client possess** event | Weird / haunted |
| Boss clear with S/A | Victory note (optional) |

Letters may fire on **fail** missions too (e.g. neg-syn delivery).

Harness: `23` fields + `cleared` + `letter_id`. See `20` / `24`.
