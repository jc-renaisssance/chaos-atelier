# Harness stamp fields (Phase-1 lock)

Headless **mission × build** dumps. Assertable one row per craft→sim.

## Required fields

| Field | Type | Notes |
|---|---|---|
| `run_id` | string | |
| `player_owner_id` | string | Phase-1 `own_basic` |
| `player_skills` | string[] | Phase-1 `[]` |
| `max_materials` | int | Default 2 |
| `max_runes` | int | Default 1 |
| `chapter_id` | int | 1..3 |
| `boss_pool_id` | string | `c1` \| `c2` \| `c3` |
| `chapter_boss_id` | string | |
| `phase` | enum | `shop` \| `craft_task` \| `boss` |
| `mission_kind` | enum\|null | `client` \| `event` \| `boss` |
| `threat_id` | string | |
| `construction` | string\|null | null if can’t-craft auto-fail |
| `material_ids` | string[] | |
| `stack_counts` | object | |
| `rune_ids` | string[] | |
| `tag_counts` | object | |
| `craft_rarity` | enum\|null | |
| `powers_positive` | string[] | |
| `powers_negative` | string[] | **[]** if rare/legendary |
| `outlook_id` | string\|null | |
| `outlook_order` | int\|null | |
| `stats` | object\|null | |
| `rating` | enum | **`S\|A\|B\|C\|D\|F`** |
| `rating_score` | number\|null | Optional; not asserted |
| `hp_remaining` | number | |
| `damage_aid_pct` | number | 0 if can’t-craft |
| `skill_effectiveness` | int | 1..5 |
| `cleared` | bool | **Derived** from HP + rating (`24`) |
| `mission_failed` | bool | Mid-fail continue flag |
| `run_over` | bool | True on boss fail |
| `outcome` | enum | win \| lose \| mixed |
| `report_lines` | string[] | |
| `letter_id` | string\|null | |
| `favor_tags_hit` | string[] | |
| `punish_tags_hit` | string[] | |
| `cant_craft` | bool | Auto-fail path |

## Asserts

1. `player_owner_id == own_basic` in Phase-1.
2. Rare/legendary → `powers_negative` empty.
3. Neg outlook may win when negatives fire.
4. Mats/runes vs `max_materials` / `max_runes` only (never legacy `material_slots`).
5. `sum(stack_counts) == len(material_ids)` when crafted.
6. `skill_effectiveness` ∈ 1..5.
7. `chapter_boss_id` ∈ pool for `boss_pool_id`.
8. `rating` ∈ {S,A,B,C,D,F}.
9. `cleared == (hp_remaining > 0 ∧ rating ∈ {S,A,B,C})`.
10. Boss row with `cleared == false` → `run_over == true`.
11. `cant_craft` → `damage_aid_pct == 0` and full row still emitted.

## Pointers

`24` win-con · `23` mission · `22` chapter · `12b` caps · `14` synergies
