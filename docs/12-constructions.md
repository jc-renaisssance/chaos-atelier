# Constructions dictionary

Layer 2 — **Construction** (garment type). Mods apply on top of **all** slotted materials. Tags added once to the gear’s tag bag.

| id | Name | Slot fantasy | material_slots | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `con_robe` | Robe | Body, flowing | 2 | +1 | 0 | 0 | +1 | 0 | +1 | Silk | Mage default |
| `con_armor` | Armor | Body, hard | **3** | +2 | 0 | +2 | 0 | −2 | 0 | Metal | Heavy soak — **3-stone stack home** |
| `con_cloak` | Cloak | Outer | 2 | 0 | 0 | +1 | +1 | +1 | 0 | Silent | Travel / cover — Metal stacks **hurt** (see neg syn) |
| `con_coat` | Coat | Outer, tailored | 2 | +1 | 0 | +1 | 0 | 0 | +1 | Royal | Street court |
| `con_tunic` | Tunic | Body, light | 2 | 0 | +1 | 0 | 0 | +1 | 0 | Soft | Adventurer basic |
| `con_boots` | Boots | Feet | 2 | 0 | 0 | +1 | 0 | +2 | 0 | Earth | Footing |
| `con_gloves` | Gloves | Hands | 2 | 0 | +1 | 0 | +1 | 0 | 0 | Sharp | Grip / craft |
| `con_hood` | Hood | Head | 1 | 0 | 0 | 0 | +1 | +1 | −1 | Silent | Conceals |
| `con_crownveil` | Crownveil | Head, ceremony | 2 | 0 | 0 | 0 | +1 | −1 | +3 | Royal, Solar | Wedding / court |
| `con_mantle` | Mantle | Shoulders | 2 | +1 | 0 | +1 | +1 | −1 | +1 | Royal | Command |
| `con_wraps` | Wraps | Body, binding | 2 | +1 | 0 | 0 | 0 | +1 | 0 | Sticky | Compact |
| `con_cape` | Cape | Outer, flourish | 2 | 0 | +1 | 0 | 0 | +1 | +1 | Silk | Drama |

## Construction rules (Phase-1)

- Exactly **one** construction per craft.
- Fill **1..material_slots** material cards (same id allowed).
- Slot conflicts (two body pieces) out of scope — Phase-1 = one garment per adventure.
- Construction tags still apply once even if materials already share that tag (counts stack).
