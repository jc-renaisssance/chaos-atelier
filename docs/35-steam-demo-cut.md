# Steam-demo cut — M2 ship bar

**Doc id: `35`.** **Status: Stamped AAAA** (Current **A**, tag source **B**, vignettes **A**, copy **A**). Docs #79, chips #80, outlook ×28 #81, Client #82. Tip **`2c338ed`**. The decision text below is the ask as written. It is not open. Material shelf faces were outside this stamp. Hand faces and the materials shelf are [36](36-craft-hand-cards.md). This file still does not load a `mat_*.png` as an outlook.

M2 **is** the Steam demo ship bar. A missing picture may stay a placeholder. Placeholder layout chrome is legal where art is missing. Flow, wiring, controls, map UX, boot, the 2-piece order, planner chips, outlook sockets, and the words on Brief / Estimate are **production-ready**. They are not a scaffold left for a later milestone.

Shell palette, order bust, and the craft frame stay the shipped **A A** ([34](34-ui-shell-v1.md), #76 / #77). This cut does not retune stamina, unlock keys, estimate weights, S–F cutoffs, or `M2_JOB_POOL`.

---

## Five locks

Design recommends **accept** on each lock. The letters under [Decisions](#decisions) are the only forks.

### 1. Outlook sockets

Wire the stamped armor already at the repo root into craft **Potential**, and into **Current** when Decision 1 is **A**. Zero scripts reference these files today. This PR does not add a `.gd` load and does not move bytes.

Client may copy (same pixels, no regen, no recompress) into `res://assets/outlook/<filename>.png` so Godot can load them. The source column is the byte source. A missing copy hides the `TextureRect`. The text line stays. Do not load any `mat_*.png` as an outlook. Material shelf faces were not this stamp. Hand card faces and the materials shelf are [36](36-craft-hand-cards.md). Neither armor folder contains a `mat_*.png`.

`TextureRect`, **96×96**, nearest. One file per winning outlook. Locked outlook: **hide the art**. No dimmed preview. No name past “locked”. `plain` is not locked. The lock predicate is the one Potential already uses ([27](27-craft-mode-stamina.md)): hidden until that outlook is unlocked.

The key is the winning `outlook_id` the readout already returns (`plain` or a `syn_*` id). Higher `14` ids that the live row table does not emit yet keep their file on disk. Showing them is this same map on the day that id wins. This PR does not add resolver rows.

`armor-stamped-2026-09-29/04-syn/look_armor_royal.png` is the apex **alias**. It is not a slot. `syn_royal_8` uses the ladder file.

Cross-tag power is one chrome (`14`, `30`). The pack still has `_3` / `_5` / `_8` files. The slot is the **mid** file (`_5`). Low and apex cross files stay in the folder. They are not slots and not a second unlock key.

`look_armor_cross_storm_*` is Temper (`syn_fire_frost_clash`) only. It is not the Storm monostack. Storm, Lunar, Solar, Sticky, Sharp, Soft, Wild, Occult, and Pure monostacks have **no** file in either pack. Those wins hide the art and keep the text. Do not borrow a cross file. Do not gen a stand-in.

| Winning `outlook_id` | Slot | Source file |
|---|---|---|
| `plain` | base | `armor-stamped-2026-09-29/00-base/look_armor_plain.png` |
| `syn_metal_3` | Metal low | `armor-stamped-2026-09-29/01-low/look_armor_metal_2.png` |
| `syn_metal_5` | Metal mid | `armor-stamped-2026-09-29/02-mid/look_armor_metal_3.png` |
| `syn_metal_8` | Metal apex | `armor-stamped-2026-09-29/03-apex/look_armor_metal_8.png` |
| `syn_earth_3` | Earth low | `armor-stamped-2026-09-29/01-low/look_armor_earth_2.png` |
| `syn_earth_5` | Earth mid | `armor-stamped-2026-09-29/02-mid/look_armor_earth_3.png` |
| `syn_earth_8` | Earth apex | `armor-stamped-2026-09-29/03-apex/look_armor_earth_8.png` |
| `syn_fire_3` | Fire low | `armor-stamped-2026-09-29/01-low/look_armor_fire_2.png` |
| `syn_fire_5` | Fire mid | `armor-stamped-2026-09-29/02-mid/look_armor_fire_3.png` |
| `syn_fire_8` | Fire apex | `armor-stamped-2026-09-29/03-apex/look_armor_fire_8.png` |
| `syn_frost_3` | Frost low | `armor-stamped-2026-09-29/01-low/look_armor_frost_2.png` |
| `syn_frost_5` | Frost mid | `armor-stamped-2026-09-29/02-mid/look_armor_frost_3.png` |
| `syn_frost_8` | Frost apex | `armor-stamped-2026-09-29/03-apex/look_armor_frost_8.png` |
| `syn_silent_3` | Silent low | `armor-stamped-2026-09-29/01-low/look_armor_silent_3.png` |
| `syn_silent_5` | Silent mid | `armor-stamped-2026-09-29/02-mid/look_armor_silent_5.png` |
| `syn_silent_8` | Silent apex | `armor-stamped-2026-09-29/03-apex/look_armor_silent_8.png` |
| `syn_royal_3` | Royal low | `armor-stamped-2026-09-29/01-low/look_armor_royal_3.png` |
| `syn_royal_5` | Royal mid | `armor-stamped-2026-09-29/02-mid/look_armor_royal_5.png` |
| `syn_royal_8` | Royal apex | `armor-stamped-2026-09-29/03-apex/look_armor_royal_8.png` |
| `syn_silk_3` | Silk low | `armor-stamped-2026-09-29/01-low/look_armor_silk_3.png` |
| `syn_silk_5` | Silk mid | `armor-stamped-2026-09-29/02-mid/look_armor_silk_5.png` |
| `syn_silk_8` | Silk apex | `armor-stamped-2026-09-29/03-apex/look_armor_silk_8.png` |
| `syn_fire_frost_clash` | Temper | `armor-cross-tag-locked-2026-10-02/02-mid/look_armor_cross_storm_5.png` |
| `syn_wild_earth` | Beastbloom | `armor-cross-tag-locked-2026-10-02/02-mid/look_armor_cross_beastbloom_5.png` |
| `syn_sticky_sharp` | Snaretooth | `armor-cross-tag-locked-2026-10-02/02-mid/look_armor_cross_snaretooth_5.png` |
| `syn_royal_silent` | Masked Crown | `armor-cross-tag-locked-2026-10-02/02-mid/look_armor_cross_masked_crown_5.png` |
| `syn_solar_pure` | Dawn Vestment | `armor-cross-tag-locked-2026-10-02/02-mid/look_armor_cross_dawn_vestment_5.png` |
| `syn_lunar_occult` | Pale Hex | `armor-cross-tag-locked-2026-10-02/02-mid/look_armor_cross_pale_hex_5.png` |

On disk and **not** a slot: the royal alias above; each cross tag’s `01-low/*_3.png` and `03-apex/*_8.png` (12 files). 41 stamped `look_armor_*.png` files. 28 slots. 13 files stay packed.

Neg syn ids and `uniq_*` have no file in these folders. Hide the art. Do not gen.

### 2. Planner chips are icons

[34](34-ui-shell-v1.md) Decision 3 letter **B** shipped as **text interim** (icon chips Later). That interim is **not** live law for the demo. The chip is an icon. The sixteen controls stay `PlannerCatalog.MONOSTACK_TAGS` (Fire, Frost, Storm, Earth, Lunar, Solar, Royal, Silent, Sticky, Sharp, Soft, Wild, Occult, Pure, Metal, Silk). Click behavior stays `30` (low → mid → apex, then the cross rule). A cross plan is a state on the two tags (`· cross`). It is not a seventeenth chip.

**These icons are not asset-ready.** Tip has no discrete planner tag-chip PNG. `assets/m2-market/` is staff, skill, and artifact shelf art. Route kind faces, Dex tabs, and the armor torsos above are other jobs. Do not point the chip at an armor look (that file is the outlook socket, 96×96). Do not point it at a market icon unless Decision 2 names that path.

### 3. Map — graph click commits

The player path is the route graph ([22](22-chapter-schedule.md)). A click on a node the board can confirm commits that node into `route_path`. A click that is only a legal future draft still drafts. The **FORK OPTIONS** panel is not on the player screen. Its rows are not a second commit control. `fork_options` may stay in the test log. No new `20` key. Kind faces and the elite badge stay.

### 4. Title screen

Boot is a title screen. It is not `schedule_board`. Client sets `project.godot` `run/main_scene` to `res://src/ui/title/title_screen.tscn` and adds that scene. The board scene stays the board. New run opens the chapter the way a run starts today (newspaper, then the graph). Continue resumes the existing profile save and is disabled when there is no save. Quit leaves the process. Buttons: **New run**, **Continue**, **Quit**. Title word: **Wombaste**.

Dex, **Reroll this chapter**, **Demo next chapter**, and the STAMP JSON dump leave the player screen. They sit behind `dev_tools`, default **false**. When false they are not in the tree. When true they may show on the board for a smoke. They do not show on the title screen.

### 5. One order, one craft, one fight

A 2-piece order is **one** adventure order: **N = 2** constructions, **one** craft session (`stamina_start = 12 * 2`, one Finish). Finish stamps each zone, then plays Gate A, then runs **one** fight.

`grade_piece` per zone is a piece stamp. It is not a fight. Gate **A** shows one vignette per piece: playback, then that piece’s report (`30`). After the last piece report, `resolve_order` (or the boss resolve) grades the **combined** gear **once**. That grade is the fight. N = 2 is two vignettes and **one** fight. It is not two fights.

---

## Demo-facing Brief and Estimate

Letter under Decision 4. Same gates as slice 3. Weight integers stay in the test log. They stay off the label.

**Brief**, when the enemy is seen. Three lines. No threat id. No `seen` / `fought` word.

```
{display name}
{environment}
{flavor}
```

Unseen: the body is `?`.

A `cli_*` row on this tip has a name and no `environment` or `flavor` (23 rows). Printing the three-line shape there is a header over blank lines. That hollow poster is [37](37-player-facing-chrome.md) letter 2. Boss rows keep the three lines above. Copy **A** is not open.

**Estimate.** One field per line. A locked field is `?` on that line only.

| Line | Unlocked text |
|---|---|
| Plan | `Metal mid` (outlook name + tier) |
| Favors | Tag names, or `None` |
| Punishes | Tag names, or `None` |
| Skill | `Fires. {skill name}. {one clause}.` or `Does not fire.` No `ask_*` id |
| Watch | Neg **name** from [14](14-synergies.md), or `None`. No `syn_neg_*` id |
| Read | `S` `A` `B` `C` `D` or `F` |

Neg names already in `14`: Ragged Mail, Bucket Head, Iron Mantle Fail, Clanging Hush, Frayed Comfort, Tar at Court, Schism Stitch, Scorched Down.

---

## Client (after the stamp — not this PR)

Ulquiorra holds until Jonathan writes the letters. Szayelaporro holds until that Client. Nnoitra holds. A gen seat opens only if Decision 2 is **B**, and only after Harribel’s soft-gate. This PR does not burn.

| After the letters | Holds still |
|---|---|
| Copy the 28 slot files into `res://assets/outlook/`. Potential `TextureRect` per the table. Current too if Decision 1 is **A**. Hide when locked | A new gen. A `mat_*.png` load. Using the royal alias as a slot. Using a cross `_3` or `_8` as the slot |
| Icon chips once Decision 2 names files (**A**) or the gen lands (**B**) | Shipping the text interim as the demo. Pointing a chip at an armor torso |
| Remove the FORK OPTIONS panel from the player tree. Graph click still confirms or drafts | A second commit control. A new `20` key |
| Title scene. `run/main_scene` points at it. `dev_tools` default false hides Dex, Reroll, Demo next chapter, and the stamp dump | Booting `schedule_board.tscn` |
| One Finish, Gate A vignettes, one combined fight | A second fight per piece |
| Decision 4 **A**: the sentences above | Dropping `?` gates or moving weights onto the label |

---

## Stamp card

### Review

| File | Section |
|---|---|
| `docs/35-steam-demo-cut.md` | This law. Five locks, path table, tag-icon blocker, vignettes, Brief / Estimate sentences |
| `docs/34-ui-shell-v1.md` | Override banner. Text interim is not live demo law. Palette and bust stay **A** |
| `docs/22-chapter-schedule.md` | **Graph commit (2026-10-23).** FORK OPTIONS is not the player path |
| `docs/21-app-flow.md` | Boot. Title scene. `dev_tools` |
| `docs/15-outlook-gen-list.md` | Pointer at the path table. No new gen list |
| `docs/30-interactive-order.md` | One fight. Two vignettes under Gate A. Not two fights |
| `docs/27-craft-mode-stamina.md` | Pointer. Current / Potential art follows this cut |
| `docs/pm/phase-1-plan.md` | Tip `4d9fa19` is not demo-ready. This cut is the open card |
| `docs/05-art.md` | Pointer. No gens in this PR |
| `docs/README.md` · `docs/00-doc-categories.md` · `docs/STAMP.md` | Index and this card |

### Decisions

Design recommends **accept** on the five locks above. Write the four letters. Silence is not a letter except where a line says silence keeps the shipped rule.

1. **Current outlook — A or B.** The path table is the lock either way. **A (Design default):** the same png on **Current** and **Potential** when the outlook is unlocked. One load. Hide both when locked. Current’s stat line stays. **B:** Potential only. Current stays the stat line with no picture. Write **A** or **B**. Silence is not **A**. Design recommends **A**. The second `TextureRect` is the same file the Potential socket already loads.

2. **Tag-icon source — A or B. Blocker.** No planner tag-chip PNG exists on the tip. **A:** the reply names existing files, one path per monostack tag in the list of sixteen. Design does not see a set that is a tag chip. Armor looks stay on the outlook socket. Market, route, and Dex files are the wrong subjects unless the reply names them anyway. **B:** open a small gen seat after this stamp. Sixteen chips. Flat **16×16** Pro Flash, one frame, a tag glyph, no word, no armor torso. Cross stays a state on two chips, not a file. Harribel soft-gate, then Nnoitra. This PR does not gen. Write **A** plus paths, or **B**. Silence is not a path list and is not a gen. Design does not recommend a file. Icons are not asset-ready. Jonathan picks **A** or **B**. The ship bar wants icon chips in the demo. Text interim is not a third letter. If the reply names no files, **B** is how the chips become real.

3. **Vignettes — A or B.** The one-fight lock stands either way. **A (Design default):** keep Gate A. N = 2 plays two vignettes, then one fight. **B:** one combined playback (the old slice-4 Gate B shape), then the reports, then the one fight. Write **A** or **B**. Silence keeps **A**. Gate A is already on the tip. Design recommends **A**. Two vignettes are the production playback. They are not a second fight.

4. **Brief / Estimate copy — A or B.** **A (Design default):** the sentences in this file. Drop the id dump. Keep every `?` gate. **B:** leave the current dump strings. Write **A** or **B**. Silence is not **A**. Design recommends **A**. The strings are a label rewrite. The gates and the weights do not move. The ship bar wants demo-facing copy.

Map, title, the outlook path table, and one-fight are accepts. They are not extra letters.

### Questions

None.

### Blocks

An unanswered Current line (**A** or **B**). Silence is not **A**.

An unanswered tag-icon line (**A** with paths, or **B**). Silence is not a file and is not a gen. This line blocks the chip wire only. It does not block the outlook copy, the graph, the title, or the one-fight lock once those are accepted. Letter **B** does not gen inside this PR. The seat opens after the stamp, and after Harribel.

An unanswered copy line (**A** or **B**). Silence is not **A**.

The vignette line does not block. Silence keeps Gate **A**.

**Holds.** PR **#71**: Solenne ×4 art **HOLD** until the PixelLab reset **2026-11-02**. Halden + Vex **KEEP**. Shop **ACCEPT**. Do not open a Solenne pass. Do not revive **#62**. Posture art stays **Nov 2**. Nnoitra, Ulquiorra, and Szayelaporro **hold** until Jonathan stamps this card. No gens in this PR.

### Design recommends

**Accept** the outlook path, the graph commit, the title screen, and one fight. **Current A. Vignettes A. Copy A.** Tag icons are **not** asset-ready: Jonathan picks **A** or **B**, and **B** if he names no files. Text chips are not the demo law.
