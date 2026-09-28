# Constructions dictionary

Layer 2 — **Construction** (garment type). **Compulsory** on every craft. Mods apply on top of slotted materials. Tags added once to the gear’s tag bag.

**Craft caps** (how many mats/runes): see **[12b-craft-slots](12b-craft-slots.md)** — default **2 materials + 1 rune**, raised by owner/staff skills. The old per-row slot counts are not the runtime budget.

| id | Name | Slot fantasy | HP | ATK | DEF | RES | MOB | PRE | Tags | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---|
| `con_robe` | Robe | Body, flowing | +1 | 0 | 0 | +1 | 0 | +1 | Silk | Mage default |
| `con_armor` | Armor | Body, hard | +2 | 0 | +2 | 0 | −2 | 0 | Metal | Heavy soak |
| `con_cloak` | Cloak | Outer | 0 | 0 | +1 | +1 | +1 | 0 | Silent | Metal stacks hurt (neg syn) |
| `con_coat` | Coat | Outer, tailored | +1 | 0 | +1 | 0 | 0 | +1 | Royal | Street court |
| `con_tunic` | Tunic | Body, light | 0 | +1 | 0 | 0 | +1 | 0 | Soft | Adventurer basic |
| `con_boots` | Boots | Feet | 0 | 0 | +1 | 0 | +2 | 0 | Earth | Footing |
| `con_gloves` | Gloves | Hands | 0 | +1 | 0 | +1 | 0 | 0 | Sharp | Grip / craft |
| `con_hood` | Hood | Head | 0 | 0 | 0 | +1 | +1 | −1 | Silent | Conceals |
| `con_crownveil` | Crownveil | Head, ceremony | 0 | 0 | 0 | +1 | −1 | +3 | Royal, Solar | Wedding / court |
| `con_mantle` | Mantle | Shoulders | +1 | 0 | +1 | +1 | −1 | +1 | Royal | Command |
| `con_wraps` | Wraps | Body, binding | +1 | 0 | 0 | 0 | +1 | 0 | Sticky | Compact |
| `con_cape` | Cape | Outer, flourish | 0 | +1 | 0 | 0 | +1 | +1 | Silk | Drama |

## Construction rules (Phase-1)

- Exactly **one** construction per craft (compulsory).
- Materials / runes count from **[12b](12b-craft-slots.md)** (default 2m1r).
- Same material id may repeat within the mat budget.
- Phase-1 garment focus for art: **armor** first when 1C opens.
