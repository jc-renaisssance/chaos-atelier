# Shop owners (Balatro-style)

Jonathan lock (2026-09-21): shops are **owned**. Different owners sell different **material families / pools**, or sell **skills only** (grind / play-hours). Each owner has a distinct **shop outlook** (art). Art gen + Client multi-owner wiring = **Later** except **one basic owner** in Phase-1.

## Rules

- At each shop visit the player meets **one** owner (chapter / unlock / random — TBD).
- **Pool owners** stock materials from their family list (weights TBD).
- **Skill owners** sell no mats (or a tiny junk stub); they sell **run skills** that stack for the chapter/run (rerolls, income floor, etc.).
- Unlockable owners extend play hours without needing more Client loops.
- Encyclopedia / scars stay separate from owner unlocks.

## Owner roster (draft)

| id | Name | Kind | Material pool / skill | Shop outlook (art) | Phase |
|---|---|---|---|---|---|
| `own_basic` | Atelier Clerk | Pool | Starter commons: Cloth, Leather, Metal scrap, Stone shard, basic Silk | Clean wooden counter, warm lamp | **Phase-1** |
| `own_forge` | Scale Merchant | Pool | Metal family heavy (iron → steel, chainlace); some Stone | Ember forge, sparks | Later |
| `own_voodoo` | Bone & Leaf | Pool | Plants + animal skins (lizard, frog, dire fur, ivy, tar, occult-adjacent) | Dried herbs, jars, fetish masks | Later |
| `own_tech` | Chassis Vendor | Pool | **Sci‑fi / high-tech** mats (see stub below) | Neon glass, clean chrome | Later |
| `own_moon` | Night Loom | Pool | Lunar / Silent / Silk rare | Silver thread, moth lamps | Later |
| `own_skill_reroll` | Deck Broker | **Skill** | Free **reroll** of shop offers **once per visit** (stacks TBD) | Card table, green felt | Later |
| `own_skill_income` | Tithe Clerk | **Skill** | **Min income +1** gold on every client payout this chapter | Abacus, ledger | Later |
| `own_skill_storage` | Pack Rat | **Skill** | +1 material hand / storage for the run | Overstuffed packs | Later |

## Sci‑fi / high-tech material stubs (Later — `own_tech` pool)

Docs-only placeholders; **not** in Phase-1 starter hand. Stats TBD when that owner unlocks.

| id | Name | Tags (draft) | Notes |
|---|---|---|---|
| `mat_carbon_mesh` | Carbon Mesh | Metal, Silent | Light hard shell |
| `mat_plasma_thread` | Plasma Thread | Fire, Storm, Metal | Unstable glow |
| `mat_nullfoam` | Nullfoam | Soft, Occult | Absorbs signal |
| `mat_holo_silk` | Holo-Silk | Silk, Solar, Lunar | Shifts color |
| `mat_servo_leather` | Servo Leather | Wild, Metal | Fake hide + actuators |

## Voodoo / wild-skin stubs (Later — `own_voodoo` pool)

Some already exist in `11`; owner weights them up and adds skins:

| id | Name | Tags (draft) | Notes |
|---|---|---|---|
| `mat_lizard_skin` | Lizard Skin | Wild, Earth | Dry scale |
| `mat_frog_hide` | Frog Hide | Wild, Sticky | Slick |
| `mat_snake_shed` | Snake Shed | Wild, Silent, Sharp | Paperthin |
| `mat_root_fetish` | Root Fetish Cord | Earth, Occult, Wild | Knotted |
| (+ existing ivy, dire fur, tar, grave silk, etc.) | | | |

## Phase-1 lock

- Ship **`own_basic` only** — one shop outlook, one pool (commons from `11`).
- No art gen for other owners; no Client owner-switch UI beyond a stub id if needed.
- Skill owners and unlock trees = Later (play-hours / meta).

## Harness / Client notes

- Stamp `shop_owner_id` on shop visits when multi-owner lands.
- Pool filter = owner’s allowed `mat_*` set (or family weights).
