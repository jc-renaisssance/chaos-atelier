# Catalog overview

Status: **Design draft** (Jonathan 2026-09-21 — larger dictionary on paper before Client/art). Numbers are first-pass for balance harness; expect Mid/Mid smoke then revise one lever at a time.

## Schema (data-first)

Every craft result = **1 Material + 1 Construction + 0–1 Enchantment** (Phase-1: at most one enchantment).

```
Final gear:
  stats = Material.stats + Construction.stat_mods + Enchantment.stats
  tags  = Material.tags ∪ Construction.tags ∪ Enchantment.tags  (counts stack)
  powers = resolve(tag_counts) + optional named_recipe match
```

One **resolver** reads tag counts from tables (`docs/14-synergies.md`). No bespoke if/else per combo for normal gear.

## Primary stats (linear, accountable)

| Stat | Code | Meaning in adventure sim |
|---|---|---|
| Hit Points soak | `HP` | How much punishment the garment can take before ruin |
| Attack aid | `ATK` | Helps the wearer win offensive checks |
| Defense | `DEF` | Physical soak / reduce wound checks |
| Resist | `RES` | Elemental / magic / weather soak |
| Mobility | `MOB` | Escape, chase, footing, first-move |
| Presence | `PRE` | Social / royal / quest impression (rare clients) |

Keep primary stats few. Special outcomes come from **tags**, not a dozen soft stats.

## Tag vocabulary (Phase-1 dictionary)

| Tag | Fantasy | Typical sources |
|---|---|---|
| Fire | Heat, dragon, forge | Ember silk, magma thread, fire runes |
| Frost | Cold, ice, stillness | Frostwool, glacier hide |
| Storm | Lightning, wind, sky | Storm linen, skybone |
| Earth | Stone, weight, roots | Clayweave, stonefiber |
| Lunar | Night, omen, silver | Moonlace, silver moth |
| Solar | Day, glory, gold | Suncloth, aureate foil |
| Royal | Court, law, ceremony | Velvet crownweave, gilded trim |
| Silent | Stealth, hush, shadow | Whisper gauze, dusk leather |
| Sticky | Glue, bind, cling | Tar thread, resin silk |
| Sharp | Cut, thorn, edge | Needlegrass, bladewool |
| Soft | Comfort, heal, gentle | Downcloud, milkfleece |
| Wild | Beast, untamed | Dire fur, ivy cord |
| Occult | Forbidden, hex | Grave silk, null ink |
| Pure | Cleanse, holy, clear | Altar linen, spring cotton |
| Metal | Hard, clang, forge | Wirecloth, chainlace |
| Silk | Fine, flow, luxury | Base silk family |

## ID conventions

- Materials: `mat_*`
- Constructions: `con_*`
- Enchantments: `enc_*`
- Synergies: `syn_*`
- Named uniques: `uniq_*`

## Balance notes

- Pass look = **overall adventure trend**, not every matrix cell non-cliff.
- Stamp which tags/stats fired on every harness dump.
- New synergy mults need APPLYING confirm before dumps.
