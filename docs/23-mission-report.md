# Adventure / mission report

Jonathan lock (2026-09-22): the adventure report is a **mission result**, not only flavor lines.

## Mission result card

| Field | Type | Notes |
|---|---|---|
| `rating` | enum **`S\|A\|B\|C\|D\|F`** | **Primary harness grade — locked.** One scale only. |
| `rating_score` | number 0..100 optional | Secondary UI/debug only — **not** asserted by Test |
| `hp_remaining` | 0..1 or int | Adventurer / gear soak left after mission |
| `damage_aid_pct` | 0..100 | How much the garment aided offensive checks |
| `skill_effectiveness` | 1..5 ★ | Cap **5 stars** — tag/power fit vs threat |
| `outcome` | win \| lose \| mixed | Coarse pass look (overall trend) |
| `favor_tags_hit` | tags[] | From boss/client favors |
| `punish_tags_hit` | tags[] | From punishes |
| `powers_noted` | ids[] | Which syns mattered in the writeup |

```
function build_mission_result(gear, threat, sim) -> MissionResult:
  favor_hits  = gear.tags ∩ threat.favors
  punish_hits = gear.tags ∩ threat.punishes
  skill_stars = clamp(1..5, score_tag_fit(favor_hits, punish_hits, gear.powers))
  damage_aid  = pct_from_atk_checks(sim)
  hp_left     = sim.hp_remaining
  rating      = grade_letter(skill_stars, hp_left, damage_aid, outcome)
                # → S|A|B|C|D|F only
  rating_score = optional_0_to_100(...)   # never replaces rating in stamps
  return MissionResult(...)
```

## Adventurer letter (special events only)

A short **letter from the adventurer** appends when a special event fires. Not every mission.

| Trigger | Letter tone (draft) |
|---|---|
| Client wore / you **sold** gear that had **negative synergies** | Complaint / dark comedy — cloth misbehaved |
| Delivered **rare** craft | Impressed; tip or rumor |
| Delivered **legendary** / unique | Awe; may unlock rumor / encyclopedia Later |
| **Client possess** event (client pool flag) | Weird / haunted / possessed narration |
| Boss clear with S/A rating | Victory note (optional) |

```
function maybe_letter(gear, mission, event_flags) -> Letter|null:
  if gear.powers_neg non-empty and event_flags.sold_or_delivered:
    return letter_neg_syn(gear, mission)
  if gear.rarity == rare: return letter_rare(...)
  if gear.rarity == legendary: return letter_legendary(...)
  if event_flags.client_possess: return letter_possess(...)
  return null
```

UI: mission result card always; letter as second panel / envelope when non-null.

Harness: stamp `rating` as letter grade (+ optional `rating_score`); `letter_id` or null. See `20`.
