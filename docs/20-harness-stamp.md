# Harness stamp fields (Phase-1 lock)

Headless **mission × build** dumps. Assertable one row per craft→sim.

## Required fields

| Field | Type | Notes |
|---|---|---|
| `run_id` | string | Unique dump id |
| `player_owner_id` | string | Phase-1 `own_basic` |
| `player_skills` | string[] | Phase-1 `[]` |
| `max_materials` | int | Default 2 |
| `max_runes` | int | Default 1 |
| `chapter_id` | int | 1..3 |
| `boss_pool_id` | string | `c1` \| `c2` \| `c3` |
| `chapter_boss_id` | string | Drawn boss |
| `phase` | enum | `shop` \| `craft_task` \| `boss` |
| `mission_kind` | enum\|null | `client` \| `event` \| `boss` |
| `threat_id` | string | client / event / boss id |
| `construction` | string | `con_*` (required) |
| `material_ids` | string[] | 1..max_materials |
| `stack_counts` | object | mat_id → count |
| `rune_ids` | string[] | 0..max_runes |
| `tag_counts` | object | tag → int |
| `craft_rarity` | enum | common..legendary |
| `powers_positive` | string[] | |
| `powers_negative` | string[] | **[]** if rare/legendary |
| `outlook_id` | string | |
| `outlook_order` | int | |
| `stats` | object | HP ATK DEF RES MOB PRE |
| `rating` | string\|number | Mission grade |
| `hp_remaining` | number | |
| `damage_aid_pct` | number | 0..100 |
| `skill_effectiveness` | int | 1..5 stars |
| `outcome` | enum | win \| lose \| mixed |
| `report_lines` | string[] | |
| `letter_id` | string\|null | Adventurer letter if any |
| `favor_tags_hit` | string[] | |
| `punish_tags_hit` | string[] | |

## Asserts

1. `player_owner_id == own_basic` in Phase-1.
2. Rare/legendary → `powers_negative` empty.
3. If negatives fire → outlook may be that higher order.
4. `len(material_ids)` ∈ 1..`max_materials`; `len(rune_ids)` ∈ 0..`max_runes`.
5. `sum(stack_counts) == len(material_ids)`.
6. `skill_effectiveness` ∈ 1..5.
7. `chapter_boss_id` ∈ pool for `boss_pool_id`.

## Pointers

`17` bosses · `22` chapter flow · `23` mission report · `12b` craft caps · `14` synergies
