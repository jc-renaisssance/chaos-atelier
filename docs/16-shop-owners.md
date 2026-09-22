# Player owners (clothier characters)

Jonathan lock (2026-09-21, corrected): an **owner is the player character** — the clothier you play — **not** a shop-encounter NPC.

- Owner **material pool** = which material families **you** can access / stock in your atelier.
- Owner **skills** = **player skills** (free reroll, min income +1, storage, etc.) — permanent or run-long kit for that clothier.
- Each owner has a distinct **atelier / UI outlook** (art). Art gen + Client multi-owner = **Later** except **one basic owner** in Phase-1.

## Rules

- The run is played **as** one unlocked owner.
- Pool owners (all current drafts) define starting deck filters + shop stock weights from **their** family list.
- Skills are on the **player** (rerolls, income floor, hand size) — not a separate vendor visit.
- Unlockable owners extend play hours / fantasy without needing more Client loop systems.
- Shop UI still exists (buy/sell mats) but it is **your** atelier stock, gated by the active owner’s pool.

## Owner roster (draft)

| id | Name | Fantasy | Material pool (player access) | Player skills (draft) | Atelier outlook (art) | Phase |
|---|---|---|---|---|---|---|
| `own_basic` | Atelier Clerk | Everyday clothier | Starter commons: Cloth, Leather, Metal scrap, Stone shard, basic Silk | none (baseline) | Clean wooden atelier, warm lamp | **Phase-1** |
| `own_forge` | Scale Tailor | Forge-side armorer | Metal family heavy (iron → steel, chainlace); some Stone | — | Ember bench, sparks | Later |
| `own_voodoo` | Bone & Leaf | Voodoo / fetish stitcher | Plants + animal skins (lizard, frog, dire fur, ivy, tar, occult-adjacent) | — | Dried herbs, jars, fetish masks | Later |
| `own_tech` | Chassis Clothier | Sci‑fi / high-tech | Sci‑fi mats (see stubs below) | — | Neon glass, chrome | Later |
| `own_moon` | Night Loom | Lunar silk | Lunar / Silent / Silk rare | — | Silver thread, moth lamps | Later |
| `own_broker` | Deck Broker | Gambler clothier | Same as basic (or slight Soft/Royal lean) | **Free reroll** of atelier offers **once per shop visit** | Card-table atelier | Later |
| `own_tithe` | Tithe Clerk | Ledger clothier | Same as basic | **Min income +1** gold on every client payout this chapter | Abacus, ledger | Later |
| `own_packrat` | Pack Rat | Hoarder | Same as basic + junk commons | **+1 material hand / storage** for the run | Overstuffed packs | Later |

Skill-leaning owners still have a pool (usually basic); their fantasy is the **player skill**, not a different shopkeeper.

**Phase-1 numbers:** starter deck + shop weights for `own_basic` → **[19-own-basic-starter](19-own-basic-starter.md)**.

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

Some already exist in `11`; this owner weights them up and adds skins:

| id | Name | Tags (draft) | Notes |
|---|---|---|---|
| `mat_lizard_skin` | Lizard Skin | Wild, Earth | Dry scale |
| `mat_frog_hide` | Frog Hide | Wild, Sticky | Slick |
| `mat_snake_shed` | Snake Shed | Wild, Silent, Sharp | Paperthin |
| `mat_root_fetish` | Root Fetish Cord | Earth, Occult, Wild | Knotted |
| (+ existing ivy, dire fur, tar, grave silk, etc.) | | | |

## Phase-1 lock

- Ship **`own_basic` only** — one player clothier, one atelier outlook, commons pool from `11` / `19`.
- No art gen for other owners; no Client owner-select beyond a stub id if needed.
- Unlock trees / skill owners = Later (play-hours / meta).

## Harness / Client notes

- Stamp `player_owner_id` on runs / dumps (Phase-1 always `own_basic`).
- Pool filter = active owner’s allowed `mat_*` set (or family weights).
- Player skills modify shop/craft economy — not a second encounter type.
