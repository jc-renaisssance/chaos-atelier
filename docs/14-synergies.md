# Synergies — powers, negatives, outlook order

Resolver input: **tag counts** + **construction id**. Output: `powers[]` (positive + negative) for the adventure sim + report, and **outlook_id** for art.

## Outlook rule (Jonathan lock)

- **Every** synergy that should change look — **positive and negative** — has an `outlook_order` (integer).
- Final look = synergy with the **highest** `outlook_order` among **all** fired outlook-bearing rows (negatives compete in the same ladder).
- If none → `plain` (default / construction base color).
- A “bad” look can beat a “good” look when its order is higher (readable failures).
- Gen matrix: `docs/15-outlook-gen-list.md`.

## Positive tag-count powers

Thresholds are **minimum counts**. Draft: higher tiers **stack** with lower unless noted.

| id | When | Power | Effect (draft) | Report hint | outlook_order |
|---|---|---|---|---|---:|
| `syn_fire_2` | Fire ≥ 2 | Dragon Affinity | +ATK vs scaled / beast; ignore 1 Frost penalty | “Cloth drank the heat.” | 90 |
| `syn_fire_3` | Fire ≥ 3 | Living Ember | First offensive: bonus; fail → 1 HP chip | “Seams smoking.” | 100 |
| `syn_frost_2` | Frost ≥ 2 | Stillblood | +RES vs heat; −MOB ignored once | “Cold held.” | 50 |
| `syn_storm_2` | Storm ≥ 2 | Sky Step | +MOB first-move; Shock vulnerability | “Static in the hem.” | 55 |
| `syn_earth_2` | Earth ≥ 2 | Rooted | +DEF; no high-MOB escape same beat | “Feet like stone.” | 20 |
| `syn_earth_3` | Earth ≥ 3 | Living Stone | +DEF again; MOB hard-capped low | “Moved like a cairn.” | 25 |
| `syn_lunar_2` | Lunar ≥ 2 | Night Favor | Bonus in dark / omen; Solar punishes | “Silver answers.” | 80 |
| `syn_solar_2` | Solar ≥ 2 | Day Favor | Bonus in open / glory; Lunar punishes | “Cloth caught the sun.” | 75 |
| `syn_royal_2` | Royal ≥ 2 | Court Weight | +PRE; stealth harder | “They looked like authority.” | 70 |
| `syn_silent_2` | Silent ≥ 2 | Hush | +stealth; PRE suffers | “Even footsteps faded.” | 35 |
| `syn_sticky_2` | Sticky ≥ 2 | Bind | Enemy MOB suffers; wearer −MOB | “Everything clung.” | 40 |
| `syn_sharp_2` | Sharp ≥ 2 | Thorns | Reflect chip on physical hit | “Edges bit back.” | 45 |
| `syn_soft_2` | Soft ≥ 2 | Comfort | Ignore 1 panic; ATK softer | “Gentle as sleep.” | 12 |
| `syn_wild_2` | Wild ≥ 2 | Beast-Blood | +ATK vs beasts; Royal may frown | “Something feral.” | 60 |
| `syn_occult_2` | Occult ≥ 2 | Hexed Stitch | +RES vs holy-blind; Pure spikes | “The seams muttered.” | 85 |
| `syn_pure_2` | Pure ≥ 2 | Cleanse | Ignore 1 Occult debuff; Occult muted | “Light in the weave.” | 65 |
| `syn_metal_2` | Metal ≥ 2 | Iron Song | +DEF; Silent harder (noise) | “Rang like a bell.” | 30 |
| `syn_metal_3` | Metal ≥ 3 | Full Plate Song | +DEF again; MOB −; Silent nearly impossible | “A walking forge.” | 32 |
| `syn_silk_2` | Silk ≥ 2 | Flow | +MOB in social/grace beats | “Moved like water.” | 10 |

## Cross-tag positives

| id | When | Power | Effect (draft) | outlook_order |
|---|---|---|---|---:|
| `syn_fire_frost_clash` | Fire ≥ 1 ∧ Frost ≥ 1 | Temper | +1 RES; −1 HP (steam) | 15 |
| `syn_royal_silent` | Royal ≥ 1 ∧ Silent ≥ 1 | Masked Crown | +PRE on intrigue; fail-open if spotted | 72 |
| `syn_sticky_sharp` | Sticky ≥ 1 ∧ Sharp ≥ 1 | Snaretooth | First ambush: bind + chip | 48 |
| `syn_lunar_occult` | Lunar ≥ 1 ∧ Occult ≥ 1 | Pale Hex | Strong vs undead; Pure risk | 88 |
| `syn_solar_pure` | Solar ≥ 1 ∧ Pure ≥ 1 | Dawn Vestment | Bonus vs Occult / dark | 78 |
| `syn_wild_earth` | Wild ≥ 1 ∧ Earth ≥ 1 | Greenmail | +DEF outdoors; −MOB in cities | 22 |

## Negative synergies (bad tags matter — same outlook ladder)

Always stamp on harness dumps. Gameplay downside **and** competing look.

| id | When | Name | Effect (draft) | Report hint | outlook_order |
|---|---|---|---|---|---:|
| `syn_neg_metal_silent` | Metal ≥ 1 ∧ Silent ≥ 1 | Clanging Hush | Silent powers **disabled**; Stealth worse; +noise | “Quiet died the moment metal moved.” | 38 |
| `syn_neg_cloak_metal` | `construction=con_cloak` ∧ Metal ≥ 1 | Iron Mantle Fail | Cloak loses Silent benefit; −MOB; PRE odd | “A cloak that rang like a pot lid.” | 34 |
| `syn_neg_hood_metal` | `construction=con_hood` ∧ Metal ≥ 1 | Bucket Head | −PRE; Silent muted | “They heard the hood coming.” | 33 |
| `syn_neg_soft_sharp` | Soft ≥ 1 ∧ Sharp ≥ 1 | Frayed Comfort | Soft heal muted; chip on Soft triggers | “Cushion full of knives.” | 42 |
| `syn_neg_sticky_royal` | Sticky ≥ 1 ∧ Royal ≥ 1 | Tar at Court | −PRE hard; Royal clients insulted | “Left fingerprints on the throne.” | 71 |
| `syn_neg_occult_pure` | Occult ≥ 1 ∧ Pure ≥ 1 | Schism Stitch | Occult + Pure tier powers muted; −1 HP | “The weave argued with itself.” | 86 |
| `syn_neg_fire_soft` | Fire ≥ 1 ∧ Soft ≥ 1 | Scorched Down | Soft muted; HP chip at start | “Comfort went up in smoke.” | 95 |
| `syn_neg_metal_silk` | Metal ≥ 2 ∧ Silk ≥ 2 | Ragged Mail | Silk Flow disabled; −PRE | “Luxury that screamed.” | 31 |

Example: Fire≥2 (90) + Soft≥1 → `syn_neg_fire_soft` (95) **wins the look** over Dragon Affinity — scorched “bad” chrome.

## Rare named gear

Exact recipe match. Prefer few until tag counts prove the normal path. Named uniques set `outlook_order` **200** (override look).

| id | Recipe | Name | Bonus | outlook_order |
|---|---|---|---|---:|
| `uniq_ashen_mantle` | `mat_ember_silk`×1+ + `con_mantle` + `enc_rune_ember` | Ashen Mantle | Grants Fire≥2 power at Fire 1 | 200 |
| `uniq_ghost_bride_veil` | `mat_silver_moth` + `con_crownveil` + `enc_sigil_ghost` | Ghost Bride’s Veil | Special-client magnet | 200 |
| `uniq_vowthread_coat` | `mat_velvet_court` + `con_coat` + `enc_sigil_vow` | Vowthread Coat | Wedding / oath | 200 |
| `uniq_tar_snare_wraps` | `mat_tar_thread`×2 + `con_wraps` + `enc_rune_bind` | Tar-Snare Wraps | Sticky focus | 200 |
| `uniq_null_choir_robe` | `mat_null_ink_cloth` + `con_robe` + `enc_rune_hex` | Null Choir Robe | Occult RES spike | 200 |
| `uniq_cairnplate` | `mat_stone_shard`×3 + `con_armor` | Cairnplate | Earth≥3 + Metal≥3 auto; Living Stone look | 200 |

## Resolver order

1. Sum tag bag from all materials + construction + enchantment.
2. Apply **all** matching positive `syn_*` rows (count + cross-tag).
3. Apply **all** matching `syn_neg_*` rows (tag and/or construction).
4. If a `uniq_*` matches, add its bonus / outlook override.
5. **Outlook** = max `outlook_order` among **all** fired outlook-bearing rows (pos + neg + uniq); else `plain`.
6. Emit powers + report lines + `outlook_id` for harness stamp.

## Open for balance

- Exact numeric bonuses — Client/Test after harness.
- Whether Metal≥3 should auto-apply `syn_neg_metal_silent` even without Silent tag (draft: **no**).
- Cap on simultaneous powers (draft: no cap; stamp all).
