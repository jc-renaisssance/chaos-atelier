# Craft layers + tag engine

## Materials as deck
Materials are **cards**. Limited hand / inventory. Multiples of the same card may be spent into one craft (e.g. Armor + Stone ×3). Between beats, shop → craft/task → shop reshapes the deck toward the **announced chapter boss**.

## Three layers
| Layer | Role | Doc |
|---|---|---|
| 1 — Material (1..N cards) | Stats + tags; families incl. **Metal** | [11-materials](11-materials.md) |
| 2 — Construction | Garment type + `material_slots` | [12-constructions](12-constructions.md) |
| 3 — Enchantment / Rune | Extra tags / powers (0..1) | [13-enchantments](13-enchantments.md) |

## Tag + synergy engine (data-driven)
- Schema + tags: [10-catalog-overview](10-catalog-overview.md)
- Positive **and negative** synergies + outlook_order: [14-synergies](14-synergies.md)
- Outlook gen combo list: [15-outlook-gen-list](15-outlook-gen-list.md)
- Prefer **one catalog + one resolver** over bespoke if/else for most gear.

## Rules (Phase-1)
- One Construction + **1..material_slots** Materials + 0..1 Enchantment.
- Same material id may repeat.
- Negatives stamp like positives.
- Unique named recipes are rare exceptions.
