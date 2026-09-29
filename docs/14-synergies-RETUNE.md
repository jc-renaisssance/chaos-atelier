# Synergies — retune for stamina craft (Jonathan stamp 2026-09-28)

**APPLIED into [`docs/14-synergies.md`](14-synergies.md)** (2026-09-28). Keep this file as the stamp source for the threshold retune. Outlook rule, rarity→neg skip, and resolver order **unchanged**.

## Threshold policy

| Old | New | Notes |
|---|---|---|
| ≥2 | **≥3** | Readable first breakpoint under infinite stack |
| ≥3 | **≥5** | Mid monostack |
| (new) | **≥8 apex** | Fire / Metal / Earth only in Phase-1 |
| After apex | soft return | Further copies feed rarity / weak diminishing — **no** new full power row |

Cross-tag pair minimums stay **≥1 each** unless noted.

## Positive tag-count powers (retuned)

| id | When | Power | Effect (draft) | Report hint | outlook_order |
|---|---|---|---|---|---:|
| `syn_fire_3` | Fire ≥ 3 | Dragon Affinity | +ATK vs scaled / beast; ignore 1 Frost penalty | “Cloth drank the heat.” | 90 |
| `syn_fire_5` | Fire ≥ 5 | Living Ember | First offensive: bonus; fail → 1 HP chip | “Seams smoking.” | 100 |
| `syn_fire_8` | Fire ≥ 8 | Ash Crown *(apex)* | Once/fight ignore boss Fire-punish; new look | “They wore a kiln.” | 110 |
| `syn_frost_3` | Frost ≥ 3 | Stillblood | +RES vs heat; −MOB ignored once | “Cold held.” | 50 |
| `syn_storm_3` | Storm ≥ 3 | Sky Step | +MOB first-move; Shock vulnerability | “Static in the hem.” | 55 |
| `syn_earth_3` | Earth ≥ 3 | Rooted | +DEF; no high-MOB escape same beat | “Feet like stone.” | 20 |
| `syn_earth_5` | Earth ≥ 5 | Living Stone | +DEF again; MOB hard-capped low | “Moved like a cairn.” | 25 |
| `syn_earth_8` | Earth ≥ 8 | Mountain Guest *(apex)* | First Break ignored; new look | “The road made room.” | 28 |
| `syn_lunar_3` | Lunar ≥ 3 | Night Favor | Bonus in dark / omen; Solar punishes | “Silver answers.” | 80 |
| `syn_solar_3` | Solar ≥ 3 | Day Favor | Bonus in open / glory; Lunar punishes | “Cloth caught the sun.” | 75 |
| `syn_royal_3` | Royal ≥ 3 | Court Weight | +PRE; stealth harder | “They looked like authority.” | 70 |
| `syn_silent_3` | Silent ≥ 3 | Hush | +stealth; PRE suffers | “Even footsteps faded.” | 35 |
| `syn_sticky_3` | Sticky ≥ 3 | Bind | Enemy MOB suffers; wearer −MOB | “Everything clung.” | 40 |
| `syn_sharp_3` | Sharp ≥ 3 | Thorns | Reflect chip on physical hit | “Edges bit back.” | 45 |
| `syn_soft_3` | Soft ≥ 3 | Comfort | Ignore 1 panic; ATK softer | “Gentle as sleep.” | 12 |
| `syn_wild_3` | Wild ≥ 3 | Beast-Blood | +ATK vs beasts; Royal may frown | “Something feral.” | 60 |
| `syn_occult_3` | Occult ≥ 3 | Hexed Stitch | +RES vs holy-blind; Pure spikes | “The seams muttered.” | 85 |
| `syn_pure_3` | Pure ≥ 3 | Cleanse | Ignore 1 Occult debuff; Occult muted | “Light in the weave.” | 65 |
| `syn_metal_3` | Metal ≥ 3 | Iron Song | +DEF; Silent harder (noise) | “Rang like a bell.” | 30 |
| `syn_metal_5` | Metal ≥ 5 | Full Plate Song | +DEF again; MOB −; Silent nearly impossible | “A walking forge.” | 32 |
| `syn_metal_8` | Metal ≥ 8 | Bell Titan *(apex)* | +DEF spike; first Silent attempt auto-fail on foe; new look | “The wagon heard them coming.” | 34 |
| `syn_silk_3` | Silk ≥ 3 | Flow | +MOB in social/grace beats | “Moved like water.” | 10 |

## Cross-tag positives (unchanged gates)

Keep existing cross-tag rows from current `14` (Fire∧Frost, Royal∧Silent, etc.) with ≥1∧≥1.

## Negative synergies

Keep existing `syn_neg_*` rows; **raise Metal/Silk style dual counts from ≥2 to ≥3** where they mirrored old positives:

| id | When (retune) |
|---|---|
| `syn_neg_metal_silk` | Metal ≥ 3 ∧ Silk ≥ 3 |
| others | keep construction gates; tag floors ≥1 unless they were ≥2 mirroring old tiers → bump those to ≥3 |

Rarity skip on rare/legendary unchanged.

## Uniques

- `uniq_cairnplate`: was Stone×3 + armor → retarget to **Stone×5** (Earth≥5 path) or keep ×3 as early unique exception — **Design draft: Stone×5 + `con_armor`**, outlook 200.
- Other uniques: leave recipes; re-check after stamina economy playtest.

## Soft return after apex

If Fire/Metal/Earth count **> 8**: no additional `syn_*` row; excess tags still count for rarity / report flavor only.

## 2026-09-29 tier extension (applied into `14`)

Jonathan ask 2026-09-29 — **applied** into [`docs/14-synergies.md`](14-synergies.md) + [`docs/15-outlook-gen-list.md`](15-outlook-gen-list.md):

1. **Frost mid + apex:** `syn_frost_5` (Rime Veins) + `syn_frost_8` (Glacier Crown). Mid art = `look_armor_frost_3` → outlook `frost_5`. Apex art **Later**.
2. **Most positive tags** now have **≥3 / ≥5 / ≥8** monostack rows (silent, silk, royal, storm, lunar, solar, sticky, sharp, soft, wild, occult, pure) — not Fire·Metal·Earth only.
3. **Royal stamped = apex:** `look_armor_royal` → `royal_8` / `syn_royal_8` (Throne Mail), **not** low.
4. Cross-tags remain ≥1∧≥1 **power + single outlook** (no monostack tiers) — reviewed in-doc in `14`.
5. Soft return after apex now applies to **any** tag with an apex row (count > 8).

This RETUNE file stays the 2026-09-28 stamina-threshold stamp source; live syn table is `14`.
