# Craft slot caps

Jonathan lock (2026-09-22):

- **Construction is compulsory** (exactly one).
- Default craft budget: **2 materials + 1 rune** (`2m1r`).
- Max materials / max runes rise via **owner skill** and/or **staff skill** (Later unlocks).

## Runtime rule (Client / Test — locked)

```
assert len(materials) in 1..player.max_materials
assert len(runes)     in 0..player.max_runes
```

**Ignore** any legacy `construction.material_slots` column — it is **not** a runtime cap. Do not assert against it.

## Default (`own_basic`, no staff)

| Cap | Value |
|---|---:|
| `player.max_materials` | **2** |
| `player.max_runes` | **1** |
| `min_materials` | 1 |
| `min_runes` | 0 (rune optional) |
| constructions | exactly **1** (required) |

```
Craft =
  1 Construction   # compulsory
  + 1..player.max_materials Materials   # same id may repeat (stacks)
  + 0..player.max_runes Enchantments/runes
```

## Skill raises (draft — Later content)

| Source | Effect |
|---|---|
| Owner skill `Extra Seam` | +1 `max_materials` |
| Owner skill `Second Rune` | +1 `max_runes` |
| Staff skill `Apprentice Hands` | +1 `max_materials` while staff assigned |
| Staff skill `Rune Desk` | +1 `max_runes` while staff assigned |

Phase-1 `own_basic`: skills empty → stay at **2m1r**.

Cairnplate unique (`stone_shard`×3 + armor) requires `max_materials ≥ 3` — **parked** until a skill / staff unlocks the third mat slot (or treat as Later recipe).

## Construction table note

`12-constructions.md` garment rows are stats/tags only. Any old slot-count text is legacy and must not drive Client or harness.
