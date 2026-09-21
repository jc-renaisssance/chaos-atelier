# Craft layers + tag engine

## Materials as deck
Materials function like **cards**. Limited hand / inventory size. Between clients, the player budgets gold to buy new materials, staff, or power-ups.

## Three layers
| Layer | Role | Doc |
|---|---|---|
| 1 — Material | Stats + tags | [11-materials](11-materials.md) |
| 2 — Construction | Garment type | [12-constructions](12-constructions.md) |
| 3 — Enchantment / Rune | Extra tags / powers | [13-enchantments](13-enchantments.md) |

## Tag + synergy engine (data-driven)
- Full tag list + schema: [10-catalog-overview](10-catalog-overview.md)
- Tag-count powers + rare named gear: [14-synergies](14-synergies.md)
- Prefer **one catalog + one resolver** over bespoke if/else for most gear.

## Rules (Phase-1)
- Exactly one Material + one Construction; 0–1 Enchantment.
- Unique named recipes are rare exceptions, not the everyday path.
