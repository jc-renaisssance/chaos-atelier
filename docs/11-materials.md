# Materials dictionary

Layer 1 — **Material**. Each entry: id, name, cost (shop gold, draft), primary stats, tags, notes.

Cost band (draft): **1** scrap · **2** common · **3** uncommon · **4** rare · **5** forbidden.

## Starter / shop commons

| id | Name | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_hemp_plain` | Plain Hemp | 1 | 1 | 0 | 1 | 0 | 0 | 0 | Soft | Safe baseline cloth |
| `mat_cotton_spring` | Spring Cotton | 2 | 1 | 0 | 0 | 1 | 0 | 0 | Soft, Pure | Clean / light |
| `mat_wool_grey` | Grey Wool | 2 | 2 | 0 | 1 | 1 | −1 | 0 | Soft, Earth | Warm, heavy |
| `mat_silk_pale` | Pale Silk | 3 | 0 | 0 | 0 | 1 | 1 | 1 | Silk | Luxury flow |
| `mat_leather_tan` | Tan Leather | 2 | 1 | 0 | 2 | 0 | 0 | 0 | Wild | Basic hide |
| `mat_leather_dusk` | Dusk Leather | 3 | 1 | 0 | 1 | 0 | 2 | 0 | Silent, Wild | Stealth hide |
| `mat_linen_storm` | Storm Linen | 3 | 1 | 1 | 0 | 1 | 1 | 0 | Storm | Crackles faintly |
| `mat_velvet_court` | Court Velvet | 4 | 1 | 0 | 0 | 0 | 0 | 3 | Royal, Silk | Ceremony |

## Elemental / niche

| id | Name | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_ember_silk` | Ember Silk | 3 | 0 | 2 | 0 | −1 | 1 | 0 | Fire, Silk | Hot to touch |
| `mat_magma_thread` | Magma Thread | 4 | 1 | 2 | 1 | −2 | 0 | 0 | Fire, Metal | Forge waste |
| `mat_frostwool` | Frostwool | 3 | 1 | 0 | 1 | 2 | −1 | 0 | Frost, Soft | Always cool |
| `mat_glacier_hide` | Glacier Hide | 4 | 2 | 0 | 2 | 2 | −2 | 0 | Frost, Wild | Rigid cold |
| `mat_moonlace` | Moonlace | 4 | 0 | 0 | 0 | 2 | 1 | 2 | Lunar, Silk | Silver sheen |
| `mat_silver_moth` | Silver Moth Silk | 5 | 0 | 1 | 0 | 2 | 2 | 1 | Lunar, Silent, Silk | Night-only loom |
| `mat_suncloth` | Suncloth | 3 | 1 | 1 | 0 | 1 | 0 | 1 | Solar | Daybright |
| `mat_aureate_foil` | Aureate Foil | 4 | 0 | 0 | 1 | 0 | 0 | 3 | Solar, Metal, Royal | Leaf gold |
| `mat_clayweave` | Clayweave | 2 | 2 | 0 | 2 | 0 | −1 | 0 | Earth | Dusty |
| `mat_stonefiber` | Stonefiber | 3 | 3 | 0 | 3 | 1 | −2 | 0 | Earth, Metal | Almost armor |
| `mat_ivy_cord` | Ivy Cord | 2 | 1 | 1 | 0 | 1 | 1 | 0 | Wild, Earth | Living twist |
| `mat_dire_fur` | Dire Fur | 4 | 2 | 2 | 1 | 0 | 0 | −1 | Wild, Sharp | Smells of hunt |

## Odd / dangerous

| id | Name | $ | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `mat_whisper_gauze` | Whisper Gauze | 3 | 0 | 0 | 0 | 1 | 3 | 0 | Silent, Soft | Tears easy |
| `mat_tar_thread` | Tar Thread | 2 | 2 | 0 | 1 | 0 | −2 | −1 | Sticky, Earth | Binds |
| `mat_resin_silk` | Resin Silk | 3 | 1 | 0 | 1 | 1 | −1 | 0 | Sticky, Silk | Glossy trap |
| `mat_needlegrass` | Needlegrass Cloth | 3 | 0 | 3 | 0 | 0 | 1 | −1 | Sharp, Wild | Cuts hands |
| `mat_bladewool` | Bladewool | 4 | 1 | 3 | 1 | 0 | 0 | 0 | Sharp, Metal | Woven edges |
| `mat_downcloud` | Downcloud | 3 | 1 | 0 | 0 | 1 | 1 | 1 | Soft, Solar | Comfort |
| `mat_milkfleece` | Milkfleece | 2 | 1 | 0 | 0 | 2 | 0 | 1 | Soft, Pure | Soothing |
| `mat_grave_silk` | Grave Silk | 4 | 0 | 1 | 0 | 2 | 0 | −2 | Occult, Silk | Whispers |
| `mat_null_ink_cloth` | Null-Ink Cloth | 5 | 1 | 0 | 1 | 3 | 0 | −1 | Occult, Pure | Cancels dyes |
| `mat_altar_linen` | Altar Linen | 3 | 1 | 0 | 1 | 2 | 0 | 2 | Pure, Soft | Ceremony clean |
| `mat_wirecloth` | Wirecloth | 3 | 2 | 1 | 2 | 0 | −1 | 0 | Metal | Jingles |
| `mat_chainlace` | Chainlace | 4 | 2 | 0 | 3 | 0 | −2 | 1 | Metal, Royal | Court mail-lace |
| `mat_skybone_weave` | Skybone Weave | 5 | 1 | 2 | 0 | 2 | 2 | 0 | Storm, Wild | Hollow bones |

## Draft shop rules

- Phase-1 starter hand: `mat_hemp_plain`, `mat_cotton_spring`, `mat_leather_tan`, `mat_wool_grey` + 1 random common.
- Forbidden ($5) materials unlocked via shop room / scars — not day-one free pile.
