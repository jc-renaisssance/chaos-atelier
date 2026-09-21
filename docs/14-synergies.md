# Synergies — tag powers + rare named gear

Resolver input: **tag counts** on the finished garment. Output: list of `powers[]` for the adventure sim + report.

## Tag-count powers (data-driven, normal path)

Thresholds are **minimum counts**. Higher counts do not auto-upgrade unless a higher row exists.

| id | When | Power name | Adventure effect (draft) | Report hint |
|---|---|---|---|---|
| `syn_fire_2` | Fire ≥ 2 | Dragon Affinity | +ATK checks vs scaled / beast; ignore 1 Frost penalty | “Cloth drank the heat.” |
| `syn_fire_3` | Fire ≥ 3 | Living Ember | First offensive check: bonus die; wearer takes 1 HP chip if fail | “Seams smoking.” |
| `syn_frost_2` | Frost ≥ 2 | Stillblood | +RES vs heat; −MOB ignored once per adventure | “Cold held.” |
| `syn_storm_2` | Storm ≥ 2 | Sky Step | +MOB first-move; Shock vulnerability noted | “Static in the hem.” |
| `syn_earth_2` | Earth ≥ 2 | Rooted | +DEF; cannot use high-MOB escape same beat | “Feet like stone.” |
| `syn_lunar_2` | Lunar ≥ 2 | Night Favor | Bonus in dark / omen threats; Solar threats punish | “Silver answers.” |
| `syn_solar_2` | Solar ≥ 2 | Day Favor | Bonus in open / glory threats; Lunar threats punish | “Cloth caught the sun.” |
| `syn_royal_2` | Royal ≥ 2 | Court Weight | +PRE; intimidate / law checks; Stealth harder | “They looked like authority.” |
| `syn_silent_2` | Silent ≥ 2 | Hush | +stealth / ambush defense; PRE checks suffer | “Even footsteps faded.” |
| `syn_sticky_2` | Sticky ≥ 2 | Bind | Enemy MOB checks suffer; wearer −MOB | “Everything clung.” |
| `syn_sharp_2` | Sharp ≥ 2 | Thorns | Reflect chip on physical hit; Soft allies dislike | “Edges bit back.” |
| `syn_soft_2` | Soft ≥ 2 | Comfort | Heal/morale: ignore 1 panic; ATK softer | “Gentle as sleep.” |
| `syn_wild_2` | Wild ≥ 2 | Beast-Blood | +ATK vs beasts; Royal clients may frown | “Something feral.” |
| `syn_occult_2` | Occult ≥ 2 | Hexed Stitch | +RES vs holy-blind foes; Pure threats spike | “The seams muttered.” |
| `syn_pure_2` | Pure ≥ 2 | Cleanse | Ignore 1 Occult debuff; Occult powers muted | “Light in the weave.” |
| `syn_metal_2` | Metal ≥ 2 | Iron Song | +DEF; Silent harder (noise) | “Rang like a bell.” |
| `syn_silk_2` | Silk ≥ 2 | Flow | +MOB in social/grace beats | “Moved like water.” |

### Cross-tag pairs (still data rows, not bespoke items)

| id | When | Power name | Effect (draft) |
|---|---|---|---|
| `syn_fire_frost_clash` | Fire ≥ 1 and Frost ≥ 1 | Temper | +1 RES; −1 HP (steam stress) — “wrong but interesting” |
| `syn_royal_silent` | Royal ≥ 1 and Silent ≥ 1 | Masked Crown | +PRE on intrigue; fail-open if spotted |
| `syn_sticky_sharp` | Sticky ≥ 1 and Sharp ≥ 1 | Snaretooth | First ambush: bind + chip |
| `syn_lunar_occult` | Lunar ≥ 1 and Occult ≥ 1 | Pale Hex | Strong vs undead; Pure clients risk |
| `syn_solar_pure` | Solar ≥ 1 and Pure ≥ 1 | Dawn Vestment | Bonus vs Occult / dark bosses |
| `syn_wild_earth` | Wild ≥ 1 and Earth ≥ 1 | Greenmail | +DEF outdoors; −MOB in cities |

## Rare named gear (specific recipes)

Only fire when **exact** material + construction + optional enchantment match. Prefer few uniques until tag counts prove the normal path.

| id | Recipe | Name | Bonus |
|---|---|---|---|
| `uniq_ashen_mantle` | `mat_ember_silk` + `con_mantle` + `enc_rune_ember` | Ashen Mantle | Grants `syn_fire_2` even at Fire 1; report always mentions ash |
| `uniq_ghost_bride_veil` | `mat_silver_moth` + `con_crownveil` + `enc_sigil_ghost` | Ghost Bride’s Veil | Special-client magnet; Lunar/Silent focus |
| `uniq_vowthread_coat` | `mat_velvet_court` + `con_coat` + `enc_sigil_vow` | Vowthread Coat | Wedding / oath clients; Royal+Pure |
| `uniq_tar_snare_wraps` | `mat_tar_thread` + `con_wraps` + `enc_rune_bind` | Tar-Snare Wraps | Sticky focus; funny fail if worn to court |
| `uniq_null_choir_robe` | `mat_null_ink_cloth` + `con_robe` + `enc_rune_hex` | Null Choir Robe | Occult RES spike; Pure clients refuse |

## Resolver order

1. Sum tags from all layers.
2. Apply **all** matching `syn_*` count rows (and cross-tag rows).
3. If a `uniq_*` recipe matches exactly, add its bonus (may reinforce a syn).
4. Emit powers + human report lines for the harness stamp.

## Open for balance

- Exact numeric bonuses (dice vs flat) — Client/Test to propose once harness exists.
- Whether Fire ≥ 3 replaces or stacks with Fire ≥ 2 (draft: **stacks**).
- Caps on how many powers can fire (draft: **no cap**, report lists all — revisit if noisy).
