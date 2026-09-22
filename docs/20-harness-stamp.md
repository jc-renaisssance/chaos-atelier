# Harness stamp fields (Phase-1 lock)

## Required fields

| Field | Type | Notes |
|---|---|---|
| `run_id` | string | |
| `player_owner_id` | string | `own_basic` |
| `max_materials` / `max_runes` | int | 2 / 1 default |
| `chapter_id` / `boss_pool_id` / `chapter_boss_id` | | |
| `phase` | enum | shop \| craft_task \| event \| boss \| newspaper |
| `mission_kind` | enum\|null | `order` \| `event` \| `boss` |
| `threat_id` | string | client or event id |
| `lineup_card_ids` | string[3]\|null | The 3 offered that round |
| `picked_card_id` | string\|null | The one chosen |
| `card_difficulty` | int\|null | 1..3 |
| `reps_before` / `reps_after` / `reps_delta` / `reps_gate` / `rounds_left` | int | |
| craft / tags / rarity / powers / outlook / stats | | as before |
| `rating` | S\|A\|B\|C\|D\|F | |
| `hp_remaining` / `damage_aid_pct` / `skill_effectiveness` | | |
| `cleared` / `mission_failed` / `run_over` / `run_over_reason` | | |
| `newspaper_event` / `newspaper_headline_id` / `letter_id` | | |
| `cant_craft` | bool | |

## Asserts

1–10 as prior (owner, neg, caps, cleared derive, boss death → run_over).
11. `cant_craft` → F ∧ hp>0 ∧ aid 0 ∧ normal fail reps Δ.
12. After last round, `reps_after < reps_gate` → `reps_gate_miss`.
13. Mid death (hp≤0, not cant_craft) → large −reps.
14. Newspaper flags when applicable.
15. Each mid round: `len(lineup_card_ids)==3` and `picked_card_id ∈ lineup`.

## Pointers

`22` lineup · `24` · `25` · `26` · `23` · `12b` · `14`
