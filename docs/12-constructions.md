> **Superseded (2026-09-28):** live craft no longer picks construction from a hand/unlocked list or fills `2m1r` slots — construction is **order-fixed**; depth = stamina ([27-craft-mode-stamina](27-craft-mode-stamina.md)). Table below still defines garment stats/tags.
# Constructions dictionary

Layer 2 — **Construction** (garment type). **Compulsory** on every craft. Mods apply on top of slotted materials. Tags added once to the gear’s tag bag.

**Craft caps:** legacy **[12b-craft-slots](12b-craft-slots.md)** (2m1r) is **superseded** by stamina craft ([27](27-craft-mode-stamina.md)). Garment rows below are stats/tags only.

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

- Exactly **one** construction per **piece** (compulsory).
- Multi-construction orders: **one** parallel craft session, N zones ([27](27-craft-mode-stamina.md)). **Supersedes** sequential per-piece sessions.
- Materials / runes: **stamina plays** in live craft ([27](27-craft-mode-stamina.md)); legacy 12b 2m1r superseded.
- Same material id may repeat within the mat budget.
- Phase-1 garment focus for art: **armor** first when 1C opens.
