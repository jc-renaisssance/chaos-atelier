# Craft layers + tag engine

## Materials as deck
Materials are **cards**. Limited hand / inventory. Multiples of the same card may be spent into one craft (e.g. Armor + Stone ×3). Between beats, atelier shop → craft/task → shop reshapes the deck toward the **announced chapter boss**. Active **player owner** gates which families you can stock.

## Three layers
| Layer | Role | Doc |
|---|---|---|
| 1 — Material (1..N cards) | Stats + tags; families incl. **Metal** | [11-materials](11-materials.md) |
| 2 — Construction | Garment type + `material_slots` | [12-constructions](12-constructions.md) |
| 3 — Enchantment / Rune | Extra tags / powers (0..1) | [13-enchantments](13-enchantments.md) |

## Tag + synergy engine (data-driven)
- Schema + tags: [10-catalog-overview](10-catalog-overview.md)
- Positives + **negatives** (higher outlook_order; blocked on rare/legendary): [14-synergies](14-synergies.md)
- Outlook gen list: [15-outlook-gen-list](15-outlook-gen-list.md)
- Player owners: [16-shop-owners](16-shop-owners.md)

## Rules (Phase-1)
- One Construction + **1..material_slots** Materials + 0..1 Enchantment.
- Same material id may repeat.
- Negatives stamp like positives **except** on rare/legendary crafts.
- Unique named recipes are rare exceptions.
