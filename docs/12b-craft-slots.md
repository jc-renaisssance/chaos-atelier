> **Superseded (2026-09-28 Jonathan stamp):** default **2m1r** slot UI is replaced by stamina craft ([27-craft-mode-stamina](27-craft-mode-stamina.md)). Keep for historical harness asserts until Test retargets.
# Craft slot caps

Jonathan lock (2026-09-22):

- **Construction is compulsory** (exactly one).
- Default craft budget: **2 materials + 1 rune** (`2m1r`).
- Max materials / max runes rise via **owner skill** and/or **staff skill**. **M2 staff unlock** = market-sold `staff_*` on the Staffs tab — [32](32-shop-and-events.md). Owner-skill Extra Seam / Second Rune stay Later.

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

## Skill raises

| Source | Effect | Status |
|---|---|---|
| Owner skill `Extra Seam` | +1 `max_materials` | **Later** (not an M2 `sk_*`) |
| Owner skill `Second Rune` | +1 `max_runes` | **Later** (not an M2 `sk_*`) |
| Staff `staff_apprentice` (Apprentice Hands) | +1 `max_materials` while equipped | **M2** — [32](32-shop-and-events.md) |
| Staff `staff_rune_desk` (Rune Desk) | +1 `max_runes` while equipped | **M2** |
| Staff `staff_loom_pair` / `staff_third_seam` / `staff_rune_pair` | +1/+1, +2 materials, +2 runes | **M2** catalog |

Phase-1 `own_basic` starts with **no staff** → stay at **2 / 1**. Buy / equip from the market Staffs tab ([32](32-shop-and-events.md)). **One** staff equipped. Live craft stays stamina ([27](27-craft-mode-stamina.md)) — do **not** revive 2m1r slot-fill UI. M2 Client treats these numbers as **per-zone bag limits**.

Cairnplate unique (`stone_shard`×3 + armor) requires `max_materials ≥ 3` — **unparked** when a staff raises materials to ≥ 3 (`staff_apprentice`, `staff_loom_pair`, or `staff_third_seam`).

## Construction table note

`12-constructions.md` garment rows are stats/tags only. Any old slot-count text is legacy and must not drive Client or harness.
