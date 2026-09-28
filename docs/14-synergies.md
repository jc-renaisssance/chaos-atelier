# Synergies — powers, negatives, outlook order

Resolver input: **tag counts** + **construction id** + **craft rarity**. Output: `powers[]` (positive + negative) for the adventure sim + report, and **outlook_id** for art.

## Outlook rule (Jonathan lock)

- **Every** synergy that should change look — **positive and negative** — has an `outlook_order` (integer).
- **Negatives sit above** their positive peers on the ladder so a live neg syn **wins the look** when both fire.
- Final look = synergy with the **highest** `outlook_order` among all fired outlook-bearing rows.
- If none → `plain` (default / construction base color).
- Gen matrix: `docs/15-outlook-gen-list.md`.

## Rarity vs negative synergies (Jonathan lock)

| Craft rarity | Negative synergies |
|---|---|
| Common / Uncommon | Resolve normally |
| **Rare** | **Cannot** gain `syn_neg_*` — skip all negative rows |
| **Legendary** (named uniques / legendary craft) | **Cannot** gain `syn_neg_*` — skip all negative rows |

**How rarity is computed:** locked algorithm in **[18-rarity](18-rarity.md)** (max material $, stack count, enchantment $, unique match). Uniques below are legendary-class.

## Threshold policy (Jonathan stamp 2026-09-28 — stamina craft)

Retuned for infinite monostack under stamina craft ([27](27-craft-mode-stamina.md)). Source stamp: [14-synergies-RETUNE](14-synergies-RETUNE.md). Outlook rule, rarity→neg skip, and resolver order **unchanged**.

| Old | New | Notes |
|---|---|---|
| ≥2 | **≥3** | Readable first breakpoint under infinite stack |
| ≥3 | **≥5** | Mid monostack |
| (new) | **≥8 apex** | Fire / Metal / Earth only in Phase-1 |
| After apex | soft return | Further copies feed rarity / weak diminishing — **no** new full power row |

Cross-tag pair minimums stay **≥1 each** unless noted.
## Positive tag-count powers

Thresholds are **minimum counts** (retuned 2026-09-28). Draft: higher tiers **stack** with lower unless noted. Soft return: Fire/Metal/Earth count **> 8** → no additional `syn_*` row; excess tags still count for rarity / report flavor only.

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

## Cross-tag positives

| id | When | Power | Effect (draft) | outlook_order |
|---|---|---|---|---:|
| `syn_fire_frost_clash` | Fire ≥ 1 ∧ Frost ≥ 1 | Temper | +1 RES; −1 HP (steam) | 15 |
| `syn_royal_silent` | Royal ≥ 1 ∧ Silent ≥ 1 | Masked Crown | +PRE on intrigue; fail-open if spotted | 72 |
| `syn_sticky_sharp` | Sticky ≥ 1 ∧ Sharp ≥ 1 | Snaretooth | First ambush: bind + chip | 48 |
| `syn_lunar_occult` | Lunar ≥ 1 ∧ Occult ≥ 1 | Pale Hex | Strong vs undead; Pure risk | 88 |
| `syn_solar_pure` | Solar ≥ 1 ∧ Pure ≥ 1 | Dawn Vestment | Bonus vs Occult / dark | 78 |
| `syn_wild_earth` | Wild ≥ 1 ∧ Earth ≥ 1 | Greenmail | +DEF outdoors; −MOB in cities | 22 |

## Negative synergies (higher outlook than peers)

Always stamp when they fire. **Skipped entirely** on Rare / Legendary crafts.

Orders sit **above** the related positive look so the bad chrome wins.

| id | When | Name | Effect (draft) | Report hint | outlook_order | Beats (examples) |
|---|---|---|---|---|---:|---|
| `syn_neg_metal_silk` | Metal ≥ 3 ∧ Silk ≥ 3 | Ragged Mail | Silk Flow disabled; −PRE | “Luxury that screamed.” | 36 | metal_3 (30), metal_5 (32), silk_3 (10) |
| `syn_neg_hood_metal` | `construction=con_hood` ∧ Metal ≥ 1 | Bucket Head | −PRE; Silent muted | “They heard the hood coming.” | 39 | silent_3 (35), metal_* |
| `syn_neg_cloak_metal` | `construction=con_cloak` ∧ Metal ≥ 1 | Iron Mantle Fail | Cloak loses Silent benefit; −MOB; PRE odd | “A cloak that rang like a pot lid.” | 41 | silent_3 (35), metal_* |
| `syn_neg_metal_silent` | Metal ≥ 1 ∧ Silent ≥ 1 | Clanging Hush | Silent powers **disabled**; Stealth worse; +noise | “Quiet died the moment metal moved.” | 44 | silent_3 (35), metal_* |
| `syn_neg_soft_sharp` | Soft ≥ 1 ∧ Sharp ≥ 1 | Frayed Comfort | Soft heal muted; chip on Soft triggers | “Cushion full of knives.” | 52 | soft_3 (12), sharp_3 (45), sticky_3 (40) |
| `syn_neg_sticky_royal` | Sticky ≥ 1 ∧ Royal ≥ 1 | Tar at Court | −PRE hard; Royal clients insulted | “Left fingerprints on the throne.” | 82 | royal_3 (70), sticky_3 (40), masked_crown (72) |
| `syn_neg_occult_pure` | Occult ≥ 1 ∧ Pure ≥ 1 | Schism Stitch | Occult + Pure tier powers muted; −1 HP | “The weave argued with itself.” | 92 | occult_3 (85), pure_3 (65), pale_hex (88) |
| `syn_neg_fire_soft` | Fire ≥ 1 ∧ Soft ≥ 1 | Scorched Down | Soft muted; HP chip at start | “Comfort went up in smoke.” | 105 | fire_3 (90), fire_5 (100), soft_3 (12) |

## Rare named gear (legendary-class — **no neg syn**)

Exact recipe match. Prefer few until tag counts prove the normal path. `outlook_order` **200**. Resolver **skips all `syn_neg_*`** on these crafts.

| id | Recipe | Name | Bonus | outlook_order |
|---|---|---|---|---:|
| `uniq_ashen_mantle` | `mat_ember_silk`×1+ + `con_mantle` + `enc_rune_ember` | Ashen Mantle | Grants Fire≥2 power at Fire 1 | 200 |
| `uniq_ghost_bride_veil` | `mat_silver_moth` + `con_crownveil` + `enc_sigil_ghost` | Ghost Bride’s Veil | Special-client magnet | 200 |
| `uniq_vowthread_coat` | `mat_velvet_court` + `con_coat` + `enc_sigil_vow` | Vowthread Coat | Wedding / oath | 200 |
| `uniq_tar_snare_wraps` | `mat_tar_thread`×2 + `con_wraps` + `enc_rune_bind` | Tar-Snare Wraps | Sticky focus | 200 |
| `uniq_null_choir_robe` | `mat_null_ink_cloth` + `con_robe` + `enc_rune_hex` | Null Choir Robe | Occult RES spike | 200 |
| `uniq_cairnplate` | `mat_stone_shard`×5 + `con_armor` | Cairnplate | Earth≥5 path + Metal≥3 auto; Living Stone look | 200 |

## Resolver order

1. Sum tag bag from all materials + construction + enchantment.
2. Determine **craft rarity** per **[18-rarity](18-rarity.md)**.
3. Apply **all** matching positive `syn_*` rows (count + cross-tag).
4. If rarity is **not** rare/legendary: apply **all** matching `syn_neg_*` rows. Else skip negatives.
5. If a `uniq_*` matches, add its bonus / outlook override (and treat as legendary for step 4).
6. **Outlook** = max `outlook_order` among fired outlook-bearing rows; else `plain`.
7. Emit powers + report lines + `outlook_id` + `rarity` for harness stamp.

## Open for balance

- Exact numeric bonuses — Client/Test after harness.
- Cap on simultaneous powers (draft: no cap; stamp all).
