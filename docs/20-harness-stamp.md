# Harness stamp fields (Phase-1 lock)

## Required fields (additions bolded for this amend)

| Field | Type | Notes |
|---|---|---|
| `run_id` | string | |
| `player_owner_id` | string | `own_basic` |
| `player_skills` | string[] | |
| `max_materials` / `max_runes` | int | Default 2 / 1 |
| `chapter_id` | int | |
| `boss_pool_id` | string | |
| `chapter_boss_id` | string | |
| `phase` | enum | shop \| craft_task \| boss \| newspaper |
| `mission_kind` | enum\|null | client \| event \| boss |
| `threat_id` | string | |
| **`node_difficulty`** | int\|null | 1..3 on route nodes |
| **`reps_before` / `reps_after` / `reps_delta`** | int | |
| **`reps_gate`** | int | Chapter gate |
| **`rounds_left`** | int | |
| `construction` | string\|null | |
| `material_ids` / `stack_counts` / `rune_ids` | | |
| `tag_counts` / rarity / powers / outlook / stats | | |
| `rating` | S\|A\|B\|C\|D\|F | |
| `rating_score` | number\|null | Not asserted |
| `hp_remaining` / `damage_aid_pct` / `skill_effectiveness` | | |
| `cleared` | bool | Derived HP∧rating≥C |
| `mission_failed` | bool | |
| `run_over` | bool | |
| **`run_over_reason`** | enum\|null | `boss_death` \| `reps_gate_miss` \| … |
| **`newspaper_event`** | enum\|null | boss_announce \| mid_fail \| chapter_result \| run_over |
| **`newspaper_headline_id`** | string\|null | |
| `letter_id` | string\|null | |
| `favor_tags_hit` / `punish_tags_hit` | | |
| `cant_craft` | bool | |

## Asserts

1–8 as before (owner, neg skip, caps, stacks, ★, boss∈pool, rating enum).
9. `cleared == (hp_remaining > 0 ∧ rating ∈ {S,A,B,C})`.
10. Boss `cleared == false` → `run_over` ∧ `run_over_reason == boss_death`.
11. `cant_craft` → `damage_aid_pct == 0`.
12. After final route node, if `reps_after < reps_gate` → `run_over_reason == reps_gate_miss`.
13. Mid fail with `hp_remaining <= 0` → `reps_delta` is the **large** death penalty path (`25`).
14. Boss announce / mid-fail / chapter end rows may set `newspaper_event` non-null.

## Pointers

`24` · `25` · `26` · `22` · `23` · `12b` · `14`
