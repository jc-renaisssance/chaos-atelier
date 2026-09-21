# Craft layers + tag engine

## Materials as deck
Materials function like **cards**. Limited hand / inventory size. Between clients, the player budgets gold to buy new materials, staff, or power-ups.

## Three layers
| Layer | Role | Examples |
|---|---|---|
| 1 — Material | Stats + tags | fabrics, metals, odd reagents |
| 2 — Construction | Garment type | Robe, Armor, Cloak, Boots, … |
| 3 — Enchantment / Rune | Extra tags / powers | Fire, Lunar, Sticky, … |

## Tag + synergy engine (data-driven)
- Materials, constructions, and runes carry **tags** (Fire, Royal, Silent, Sticky, Lunar, etc.).
- **Tag counts** trigger powers (e.g. Fire ×2 = Dragon Affinity).
- Specific **rare** combinations can create **unique named equipment**.
- Prefer **one catalog + one resolver** over bespoke if/else recipes for most gear.

## Open (not locked yet)
- Full tag list, count thresholds, and named unique recipes — TBD when Design stamps them.
- Do **not** invent unique named recipes until tag counts prove most gear.
