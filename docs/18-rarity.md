# Craft rarity band rule

1A lock: how **common / uncommon / rare / legendary** is computed so the resolver can **skip `syn_neg_*`** on rare and legendary (see `14-synergies.md`).

## Inputs

From a finished craft:

- `materials[]` — each has shop cost band `$` ∈ {1,2,3,4,5} (from `11-materials.md`)
- `enchantment?` — cost band `$` (from `13`; treat missing as 0)
- `unique_match?` — true if an exact `uniq_*` recipe matched

## Algorithm (locked for Phase-1)

```
max_mat_cost = max($ of each slotted material)   // empty craft illegal
enc_cost     = enchantment.$ or 0
stack_n      = number of material cards spent

if unique_match:
    rarity = legendary
elif max_mat_cost >= 5 or (max_mat_cost >= 4 and enc_cost >= 4):
    rarity = legendary
elif max_mat_cost >= 4 or (max_mat_cost >= 3 and stack_n >= 3 and enc_cost >= 3):
    rarity = rare
elif max_mat_cost >= 3 or stack_n >= 3 or enc_cost >= 3:
    rarity = uncommon
else:
    rarity = common
```

## Neg-syn gate

| rarity | `syn_neg_*` |
|---|---|
| common | apply |
| uncommon | apply |
| rare | **skip all** |
| legendary | **skip all** |

## Examples

| Build | Result |
|---|---|
| Hemp ×1 + Tunic, no enc | common |
| Stone Shard ×3 + Armor, no enc | uncommon (stack_n ≥ 3) |
| Steel Plate ($4) ×1 + Armor | rare |
| Null-Ink ($5) + Robe + Hex | legendary |
| `uniq_cairnplate` (Stone ×3 + Armor) | legendary (unique) |

## Open (do not block 1B)

- Whether construction type can bump rarity (draft: **no**).
- Shop sell price multipliers by rarity (Later).
