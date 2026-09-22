# Harness stamp fields (Phase-1 lock)

1A lock for Test / Client headless **client × threat × build** dumps. Same job as DARE WR stamps: readable, assertable, one row per run.

## Required fields (every dump)

| Field | Type | Notes |
|---|---|---|
| `run_id` | string | Unique dump id |
| `player_owner_id` | string | Phase-1 always `own_basic` |
| `player_skills` | string[] | Phase-1 `[]` |
| `chapter_id` | int | 1..3 |
| `chapter_boss_id` | string | e.g. `boss_ash_drake` |
| `phase` | enum | `shop` \| `craft_task` \| `boss` |
| `construction` | string | `con_*` |
| `material_ids` | string[] | Order = slot order; repeats allowed |
| `stack_counts` | object | map `mat_id → count` |
| `enchantment_id` | string\|null | `enc_*` or null |
| `tag_counts` | object | map tag → int |
| `craft_rarity` | enum | `common` \| `uncommon` \| `rare` \| `legendary` |
| `powers_positive` | string[] | `syn_*` / `uniq_*` ids fired |
| `powers_negative` | string[] | `syn_neg_*` fired; **must be []** if rarity ∈ {rare, legendary} |
| `outlook_id` | string | Winner look id or `plain` |
| `outlook_order` | int | Winner order (0 if plain) |
| `stats` | object | `HP, ATK, DEF, RES, MOB, PRE` finals |
| `threat_id` | string | Client or boss threat key |
| `outcome` | enum | `win` \| `lose` \| `mixed` (draft) |
| `report_lines` | string[] | Human hints that fired |
| `favor_tags_hit` | string[] | Boss favor tags present on build |
| `punish_tags_hit` | string[] | Boss punish tags present on build |

## Asserts (Test)

1. `player_owner_id == own_basic` in Phase-1.
2. If `craft_rarity` ∈ {rare, legendary} → `powers_negative` empty.
3. If `powers_negative` non-empty → `outlook_order` equals max among fired outlook-bearing rows (neg may win).
4. `sum(stack_counts values) == len(material_ids)`.
5. `len(material_ids)` ∈ 1..`construction.material_slots`.

## Pass look

Overall adventure **trend** vs the announced boss — not every matrix cell non-cliff. Smoke Mid/Mid only after Design stamps a lever.

## Doc pointers

- Boss stubs: `17-chapter-bosses.md`
- Rarity: `18-rarity.md`
- Starter / shop: `19-own-basic-starter.md`
- Synergies / outlook: `14`, `15`
