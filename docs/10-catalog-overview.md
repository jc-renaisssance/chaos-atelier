# Catalog overview

Status: **Design draft** (Jonathan 2026-09-21 — larger dictionary on paper; **amended** same day: Metal family, multi-stack materials, negative synergies, chapter boss reveal, outlook gen contract).

Numbers are first-pass for balance harness; expect Mid/Mid smoke then revise one lever at a time.

## Schema (data-first)

```
Craft =
  1 Construction
  + 1..N Materials   (N ≤ construction.material_slots; same mat may repeat)
  + 0..1 Enchantment

Final gear:
  stats  = Σ(Material.stats) + Construction.stat_mods + Enchantment.stats
  tags   = bag-count(all Material tags ∪ Construction tags ∪ Enchantment tags)
  powers = resolve(tag_counts, construction_id)   // positive + negative rows
  outlook = highest outlook_order among fired synergies that have one
            else plain/default
```

One **resolver** reads tables in `docs/14-synergies.md`. No bespoke if/else for normal gear.

**Example:** Armor (`material_slots=3`) + Stonefiber ×3 → Earth≥3, Metal≥3 before enchantment.

## Primary stats (linear, accountable)

| Stat | Code | Meaning in adventure sim |
|---|---|---|
| Hit Points soak | `HP` | How much punishment the garment can take before ruin |
| Attack aid | `ATK` | Helps the wearer win offensive checks |
| Defense | `DEF` | Physical soak / reduce wound checks |
| Resist | `RES` | Elemental / magic / weather soak |
| Mobility | `MOB` | Escape, chase, footing, first-move |
| Presence | `PRE` | Social / royal / quest impression (rare clients) |

## Tag vocabulary (Phase-1 dictionary)

| Tag | Fantasy | Typical sources |
|---|---|---|
| Fire | Heat, dragon, forge | Ember silk, magma thread, fire runes |
| Frost | Cold, ice, stillness | Frostwool, glacier hide |
| Storm | Lightning, wind, sky | Storm linen, skybone |
| Earth | Stone, weight, roots | Clayweave, stonefiber, stone shard |
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
| Metal | Hard, clang, forge | Iron scrap, wirecloth, chainlace, steel plate |
| Silk | Fine, flow, luxury | Base silk family |

**Metal** is both a **tag** and a **material family** (see `docs/11-materials.md`). Stacking Metal mats is intentional for armor builds and for **negative** Silent/cloak clashes.

## ID conventions

- Materials: `mat_*`
- Constructions: `con_*`
- Enchantments: `enc_*`
- Synergies: `syn_*` (prefix `syn_neg_` for negatives)
- Named uniques: `uniq_*`
- Outlook gens: `look_{construction}_{synergy_or_plain}`

## Balance notes

- Pass look = **overall adventure trend**, not every matrix cell non-cliff.
- Stamp which tags/stats/powers fired (incl. negatives) on every harness dump.
- New synergy mults need APPLYING confirm before dumps.
- Outlook art = **highest outlook_order only** — see `docs/15-outlook-gen-list.md`.
