# Materials dictionary

Layer 1 — **Material**. Cards in the deck. A craft may spend **multiple** material cards into one construction (see `material_slots` on constructions).

Cost band (draft): **1** scrap · **2** common · **3** uncommon · **4** rare · **5** forbidden.

## Material families (for shop filters / stacking)

| Family | Role | Example mats |
|---|---|---|
| Cloth | Soft baselines | hemp, cotton, wool, linen |
| Silk | Luxury flow | pale silk, ember silk, grave silk |
| Leather / hide | Wild soak | tan leather, dusk leather, glacier hide |
| **Metal** | Hard clang / armor stack | iron scrap, bronze scale, wirecloth, steel plate, chainlace |
| Stone / earth | Heavy rooted stack | clayweave, stone shard, stonefiber |
| Odd | Sticky / occult / lunar… | tar, moonlace, null-ink |

## Starter / shop commons

| id | Name | Family | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_hemp_plain` | Plain Hemp | Cloth | 1 | 1 | 0 | 1 | 0 | 0 | 0 | Soft | Safe baseline |
| `mat_cotton_spring` | Spring Cotton | Cloth | 2 | 1 | 0 | 0 | 1 | 0 | 0 | Soft, Pure | Clean / light |
| `mat_wool_grey` | Grey Wool | Cloth | 2 | 2 | 0 | 1 | 1 | −1 | 0 | Soft, Earth | Warm, heavy |
| `mat_silk_pale` | Pale Silk | Silk | 3 | 0 | 0 | 0 | 1 | 1 | 1 | Silk | Luxury flow |
| `mat_leather_tan` | Tan Leather | Leather | 2 | 1 | 0 | 2 | 0 | 0 | 0 | Wild | Basic hide |
| `mat_leather_dusk` | Dusk Leather | Leather | 3 | 1 | 0 | 1 | 0 | 2 | 0 | Silent, Wild | Stealth hide |
| `mat_linen_storm` | Storm Linen | Cloth | 3 | 1 | 1 | 0 | 1 | 1 | 0 | Storm | Crackles faintly |
| `mat_velvet_court` | Court Velvet | Silk | 4 | 1 | 0 | 0 | 0 | 0 | 3 | Royal, Silk | Ceremony |

## Metal family (expanded)

| id | Name | Family | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_iron_scrap` | Iron Scrap | Metal | 1 | 1 | 0 | 1 | 0 | −1 | 0 | Metal | Noisy scrap pile |
| `mat_bronze_scale` | Bronze Scale | Metal | 2 | 2 | 0 | 2 | 0 | −1 | 0 | Metal | Scale mail bits |
| `mat_wirecloth` | Wirecloth | Metal | 3 | 2 | 1 | 2 | 0 | −1 | 0 | Metal | Jingles |
| `mat_steel_plate` | Steel Plate | Metal | 4 | 3 | 0 | 3 | 0 | −2 | 0 | Metal | Heavy plate scrap |
| `mat_chainlace` | Chainlace | Metal | 4 | 2 | 0 | 3 | 0 | −2 | 1 | Metal, Royal | Court mail-lace |
| `mat_skyiron_filigree` | Skyiron Filigree | Metal | 5 | 1 | 1 | 2 | 1 | 0 | 1 | Metal, Storm | Rare light metal |

## Stone / earth (stack example: Armor ×3 Stone)

| id | Name | Family | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_clayweave` | Clayweave | Stone | 2 | 2 | 0 | 2 | 0 | −1 | 0 | Earth | Dusty |
| `mat_stone_shard` | Stone Shard | Stone | 2 | 2 | 0 | 2 | 0 | −2 | 0 | Earth, Metal | Chip inlays — **stack staple** |
| `mat_stonefiber` | Stonefiber | Stone | 3 | 3 | 0 | 3 | 1 | −2 | 0 | Earth, Metal | Almost armor |

## Elemental / niche

| id | Name | Family | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_ember_silk` | Ember Silk | Silk | 3 | 0 | 2 | 0 | −1 | 1 | 0 | Fire, Silk | Hot to touch |
| `mat_magma_thread` | Magma Thread | Odd | 4 | 1 | 2 | 1 | −2 | 0 | 0 | Fire, Metal | Forge waste |
| `mat_frostwool` | Frostwool | Cloth | 3 | 1 | 0 | 1 | 2 | −1 | 0 | Frost, Soft | Always cool |
| `mat_glacier_hide` | Glacier Hide | Leather | 4 | 2 | 0 | 2 | 2 | −2 | 0 | Frost, Wild | Rigid cold |
| `mat_moonlace` | Moonlace | Silk | 4 | 0 | 0 | 0 | 2 | 1 | 2 | Lunar, Silk | Silver sheen |
| `mat_silver_moth` | Silver Moth Silk | Silk | 5 | 0 | 1 | 0 | 2 | 2 | 1 | Lunar, Silent, Silk | Night-only loom |
| `mat_suncloth` | Suncloth | Cloth | 3 | 1 | 1 | 0 | 1 | 0 | 1 | Solar | Daybright |
| `mat_aureate_foil` | Aureate Foil | Metal | 4 | 0 | 0 | 1 | 0 | 0 | 3 | Solar, Metal, Royal | Leaf gold |
| `mat_ivy_cord` | Ivy Cord | Odd | 2 | 1 | 1 | 0 | 1 | 1 | 0 | Wild, Earth | Living twist |
| `mat_dire_fur` | Dire Fur | Leather | 4 | 2 | 2 | 1 | 0 | 0 | −1 | Wild, Sharp | Smells of hunt |

## Odd / dangerous

| id | Name | Family | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_whisper_gauze` | Whisper Gauze | Cloth | 3 | 0 | 0 | 0 | 1 | 3 | 0 | Silent, Soft | Tears easy |
| `mat_tar_thread` | Tar Thread | Odd | 2 | 2 | 0 | 1 | 0 | −2 | −1 | Sticky, Earth | Binds |
| `mat_resin_silk` | Resin Silk | Silk | 3 | 1 | 0 | 1 | 1 | −1 | 0 | Sticky, Silk | Glossy trap |
| `mat_needlegrass` | Needlegrass Cloth | Cloth | 3 | 0 | 3 | 0 | 0 | 1 | −1 | Sharp, Wild | Cuts hands |
| `mat_bladewool` | Bladewool | Cloth | 4 | 1 | 3 | 1 | 0 | 0 | 0 | Sharp, Metal | Woven edges |
| `mat_downcloud` | Downcloud | Cloth | 3 | 1 | 0 | 0 | 1 | 1 | 1 | Soft, Solar | Comfort |
| `mat_milkfleece` | Milkfleece | Cloth | 2 | 1 | 0 | 0 | 2 | 0 | 1 | Soft, Pure | Soothing |
| `mat_grave_silk` | Grave Silk | Silk | 4 | 0 | 1 | 0 | 2 | 0 | −2 | Occult, Silk | Whispers |
| `mat_null_ink_cloth` | Null-Ink Cloth | Odd | 5 | 1 | 0 | 1 | 3 | 0 | −1 | Occult, Pure | Cancels dyes |
| `mat_altar_linen` | Altar Linen | Cloth | 3 | 1 | 0 | 1 | 2 | 0 | 2 | Pure, Soft | Ceremony clean |
| `mat_skybone_weave` | Skybone Weave | Odd | 5 | 1 | 2 | 0 | 2 | 2 | 0 | Storm, Wild | Hollow bones |

## Multi-stack rules

- Materials are **cards**. You may spend several into one craft up to the construction’s `material_slots`.
- **Same id may repeat** (Armor + Stone Shard ×3 is valid).
- Stats and tags **sum / bag-count** — three Stone Shards = Earth×3 and Metal×3 from materials alone.
- Deck removes spent cards until shop / rewards return them.

## Draft shop rules

- Phase-1 starter hand: `mat_hemp_plain`, `mat_cotton_spring`, `mat_leather_tan`, `mat_wool_grey`, `mat_iron_scrap` + 1 random common.
- Forbidden ($5) unlocked via shop room / scars — not day-one free pile.
