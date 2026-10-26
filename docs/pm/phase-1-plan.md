# Roadmap — Chaos Atelier

Updated **2026-10-26**. `dev` tip is **`274a8d6`** (Client #89). Soft #87 (`ebf6583`) stamped craft-card tag chrome **A**. Client #88 (`e9f503f`) landed drop clear, the cost caption, and N=2 as one fight. Client #89 (`274a8d6`) wired Soft A tag chips. Do not read #87, #88, or #89 as open. Steam-demo cut **AAAA** landed (#79 docs / #80 chips / #81 outlook ×28 / #82 Client `2c338ed`). Craft hand **landed** ([36](../36-craft-hand-cards.md)): Design #83 (`187911f`) Soft A′AAAA — Hand A′ (`step_deg = 32 / (max_hand - 1)`), Drag A, Drop A, Path A, Placeholder A; art #84 (`bff62c8`) `assets/mat/<id>.png` ×38; Client #85 (`1b49dd1`) fan / drag / drop + MatFace ×38 gap 0. Do not read #83, #84, or #85 as open. Route/Dex Client tip stays **`1765a29`**. **M1 ugly full-experience is operationally exit-ready** at that Client tip. **M2 four-job catalog** (Wizard / Hexer / Outrider / Oathbound) is **stamped** (Jonathan 2026-10-21, #61, draw B) in [29](../29-adventurer-catalog.md). `M2_JOB_POOL` is those four only, disjoint from `M1_JOB_POOL`. **Client wire landed** (#75, `873e7b2`). Do not read #72, #73, #74, or #75 as open. **Portrait uniqueness** is stamped (#63 ACCEPT all 24). Redraws landed: M1 #64, M2 #65. Do not regen. Do not revive #62. **Elite telegraph N5 shipped** (#66 Design / #67 art / #68 Client, Marker **A**, Scope **A**). Do not reopen. **Until-M2 stat / event tuning shipped** (Design #72 / Client #73, accept **A A A A**) in [33](../33-until-m2-tuning.md). Do not reopen. Interactive-order slice 4 docs are #69 and Client is #70. Sockets shipped. Posture art stays **Nov 2**. Do not reopen playback. Market + events M1 (#44 Design / #45 Client) and Market M2 tabs (#46 Design / #47 Client) plus 13 stamped `staff_*` + `artifact_*` icons (#48 art / #49 Client wire) are **shipped** — do not mark them pending. Skills shelf Design #51 / art #52 / Client #53 and adventurer portraits art #54 / Client #55 are **shipped**. Tab chrome is stamped **A** (no gens). Route-board + Dex art Design #57 (`ddbe8b5`) / art #58 (`d432fc2`) / Client #59 (`1765a29`) are **shipped** — do not mark them pending. Shiny stays code-only. **`main` is not promoted** (`353f1d4`, README seed only). Jonathan remaining-to-M2 cut **A A B** (2026-10-23) is **done** (lane 1 docs #74, lane 2 Client #75). Jonathan UI GO **A A A A** (2026-10-23 HKT) is locked. Steam-demo UI shell v1 **shipped** ([34](../34-ui-shell-v1.md), Design #76 `daa0280`, Client #77 `c8a5a1a`, stamp **A A B**: palette **A** / bust **A** / planner chips **B** as text on #77). Do not read #76 or #77 as open. The shell is not an open card. The demo cut **AAAA** has landed (#79–#82). Craft hand **landed** (#83 `187911f` / #84 `bff62c8` / #85 `1b49dd1`, [36](../36-craft-hand-cards.md)). Tag chrome **landed A** (#87 `ebf6583` / #89 `274a8d6`). Client #88 (`e9f503f`) is on this tip. Do not revive #62. PR #71 stays held: Solenne ×4 art **HOLD** until the PixelLab reset **2026-11-02**; Halden + Vex **KEEP**; shop **ACCEPT**.

Prior stamps still hold as history: **2026-10-13** route map with forks (free per-day `E*` board from #36/#37 superseded); **2026-10-05** M1 / M2 framing + **adventurers** terminology. **Supersedes** the 2026-09-28 Cursor-reset / Phase-0–1C framing in this file. **Supersedes** Round / schedule board (`CHAPTER_ROUND_COUNT=8` as global law) and `crafts_max=4`. Display name **Wombaste**.

See also: [STAMP](../STAMP.md) (historical record; live law is this file), [00-doc-categories](../00-doc-categories.md), [README](../README.md).

---

## Terminology

Call shop / walk-in / appointment / boss-pool people **adventurers**. Do **not** call them “clients.”

**Client** = the Godot **Client** seat / codebase only.

The 2026-10-05 stamp locks the term in PM + STAMP. It does **not** mass-rename historical bible docs. Grimmjow owns deeper bible renames Later. One-line pointers: [03](../03-clients-and-adventure.md), [28](../28-boss-client-pool.md).

---

## Already on `dev`

HEAD **`274a8d6`** (`origin/dev` at this writing; Client #89). AAAA Client shell is **`2c338ed`** (#82). Earlier shell commit **`c8a5a1a`** (#77) is the palette/bust record. Route/Dex Client art is **`1765a29`**. On this tip: catalog #61, uniqueness #63, portrait redraws #64 / #65, Elite telegraph #66 / #67 / #68, interactive-order slice 4 docs #69 / Client #70 (`f083b09`), until-M2 tuning Design #72 (`5adae28`) / Client #73 (`9f03c16`), docs tip catch-up #74 (`7f82483`), M2 four-job Client wire #75 (`873e7b2`), UI shell Design #76 (`daa0280`) / Client #77 (`c8a5a1a`), Steam-demo cut docs #79 / chips #80 / outlook #81 / Client #82 (`2c338ed`), craft hand Design #83 (`187911f`) / art #84 (`bff62c8`) / Client #85 (`1b49dd1`), docs tip catch-up #86 (`0deeaa3`), tag chrome Soft #87 (`ebf6583`), Client #88 (`e9f503f`) drop clear / cost / N=2 one fight, Client #89 (`274a8d6`) Soft A tag chips. `main` stays at `353f1d4`. #72, #73, #74, #75, #76, #77, #83, #84, #85, #87, #88, and #89 are **landed**. Do not mark them open.

### Shipped PR track (closed — do not re-queue)

| Track | PRs | On tip |
|--------|-----|--------|
| Market + events M1 (materials, refresh, chapter bank, material enchant, text `evt_*`) | #44 Design / #45 Client | Shipped |
| Market M2 tabs Staffs / Skills / Gear | #46 Design / #47 Client | Shipped. Catalog law in [32](../32-shop-and-events.md) |
| 13 stamped `staff_*` + `artifact_*` icons | #48 art / #49 Client wire | Shipped. Shiny **code-only** |
| Skills shelf (`sk_*` faces) | #51 Design / #52 art / #53 Client | Shipped. Tab chrome stamped **A** (no gens) |
| Adventurer portraits (12 M1 `adv_*`) | #54 art / #55 Client | Shipped. Do not gen a second set |
| Route-graph board art + Dex art sockets | #57 Design (`ddbe8b5`) / #58 art (`d432fc2`) / #59 Client (`1765a29`) | Shipped. Route canvas **B** (48×48 kind faces). Dex tabs 96×96; enemy icons **A** (nine `boss_*`). Adv rows reuse `assets/adv/`. Do not reopen |
| Route-graph Client (ugly nodes + edges) | #40 Design / #41 Client | Shipped (`144c151`). Mid-pick card fix #43. Kind faces are the #57 / #58 / #59 track |
| Interactive-order slices **1–3** + Dex | Design #28 · stamp #29 · Client #30 (slice 1) · #31 (Dex save) · #33 (slices 2–3) · #35 (Dex list) | Shipped ugly / text-first. Dex **art** is the #57 / #58 / #59 track |
| Elite telegraph N5 (appointment badge) | #66 Design / #67 art (`080c9e5`) / #68 Client (`8bc8844`) | Shipped. Marker **A**, Scope **A**. `assets/route/elite_mark.png`. Do not reopen |
| Interactive-order slice 4 (playback + posture sockets) | #69 Design / #70 Client (`f083b09`) | On this tip. Sockets shipped. Posture art stays **Nov 2**. Do not reopen playback |
| Until-M2 stat / event tuning | #72 Design (`5adae28`) / #73 Client (`9f03c16`) | Shipped. Accept **A A A A** (tables, elite **0.64**, mission gold, reps C1 **8** / C2 **14** / C3 **20**, event-pool draw). Do not reopen |
| Docs tip catch-up | #74 (`7f82483`) | Landed. Pointed the plan at `9f03c16` and named the M2 wire as next. That “next” is closed by #75. Do not reopen #74 |
| M2 four-job Client wire | #75 (`873e7b2`) | Landed. Live Steam-demo draws use `M2_JOB_POOL`. M1 path stays for historical smokes. Do not reopen |
| Steam-demo UI shell v1 (craft + order) | #76 Design (`daa0280`) / #77 Client (`c8a5a1a`) | Shipped. Stamp **A A B** (palette **A** / bust **A** / planner chips **B** as text on #77). Playback chrome included. Do not reopen the shell. Demo law for chips is [35](../35-steam-demo-cut.md) |
| Craft hand Soft A′AAAA (fan, drag, drop, mat faces) | #83 Design (`187911f`) / #84 art (`bff62c8`) / #85 Client (`1b49dd1`) | Landed. Hand A′ (`step_deg = 32 / (max_hand - 1)`), Drag A, Drop A, Path A (`assets/mat/<id>.png` ×38), Placeholder A. MatFace ×38 gap 0. Do not reopen |
| Craft drop clear, cost caption, N=2 one fight | #88 Client (`e9f503f`) | Landed. A successful drop clears the follower and leaves the fan. Caption line 2 is `cost N`. N=2 is two vignettes and one fight. Do not reopen |
| Craft-card tag chrome Soft A | #87 Soft (`ebf6583`) / #89 Client (`274a8d6`) | Landed **A**. Native 16×16 `chip_<tag>.png` on the hand and the zone played row. Tag names leave the caption. Do not reopen |
| Adventurer catalog Design **M1 4×3** plus M2 draw | #28 · [29](../29-adventurer-catalog.md) · Client #75 (`873e7b2`) | Design shipped. M2 4×3 stamped (draw B). **Client wire landed** (#75): live Steam-demo draws use `M2_JOB_POOL`. M1 path stays for historical smokes. Do not reopen |

Earlier systems still on this tip (through `1082ef5` and the route-map rewrite):

| Landed | Where |
|--------|--------|
| Travelling atelier + **route map with forks** (`CHAPTER_DAY_COUNT` = `map.day_count`; current map **8**; last 2 reserved; C1 sample graph; free `E*` board superseded) | `22-chapter-schedule` |
| **No piece cap** (`crafts_max` GONE; stamina per craft stays) | `22` / `20` / `27` / `24` |
| Craft = stamina hand game; construction from order | `27` |
| **Finish-only** (stamina 0 ≠ finish) | `27` / Client |
| **StS** cycle (play→discard, dig dump, reshuffle) + Current/Potential | `27` / Client |
| **Multi-piece** parallel session (dedicated UI, `12 × N` stamina, ≤4 zones) | `27` / Client |
| Shared boss-adventurer pool by job + C1–C3 rewrite | `28` / `17` / Client |
| Synergy thresholds, pos+neg, rarity skip-neg | `14` / `18` |
| Owner = player clothier; Phase-1 = `own_basic` | `16` / `19` |
| Win-con / reps / newspaper / mission report (docs) | `24` / `25` / `26` / `23` |

**History (2026-10-05):** Jonathan confirmed C1 **craft path works**. Shop systems and events were not done yet **then**. That hole is closed on this tip (market M1 + M2 tabs above). Do not read “Client still holds” from the 2026-10-05 note.

**Superseded (history only):** 1-of-3 card lineup, `CHAPTER_NODE_BUDGET=3` shop↔craft clock, default 2m1r slot UI, construction picker in craft, sequential per-piece stamina, auto-finish on `stamina_0`, fixed-client-per-boss, Round / schedule board as live UX (`CHAPTER_ROUND_COUNT=8` as global law, R1..R8), `crafts_max=4` / cant_craft-at-max, free per-day `E*` options board (#36/#37), “hold Client until Cursor monthly reset.”

---

## Milestone 1 — Ugly full-experience Client (limited options)

**Exit:** operationally **ready** at `1765a29`. Fully developed **ugly** Client that ships the **full experience** with **limited content options**. No open M1 Design or M1 Client hold.

| Lock | Note |
|------|------|
| Limited **adventurer jobs** | **LOCKED (Jonathan 2026-10-08):** M1 draw = **`M1_JOB_POOL`**, **4 jobs** — Knight, Mage, Blade Dancer, Lagoon (`28` / `29`). That lock does not move. **LOCKED (Jonathan 2026-10-21, draw B):** M2 / Steam-demo draw = **`M2_JOB_POOL`**, the other **4** — Wizard, Hexer, Outrider, Oathbound. The pools are disjoint. |
| Limited **enemy types** | Same — Design stamps the cut. |
| Shop adventurers | **More than one adventurer per job/class.** Met by the 4×3 catalog in `29`. |
| Catalog before wire | Define **stats / skills / requirement tags** first. M1 catalog is [29](../29-adventurer-catalog.md). Client wires people from that catalog. |
| Market + events | **Shipped.** M1 #44 / #45 — materials tab + refresh + chapter bank + **material enchant** + text `evt_*`. M2 tabs #46 / #47 — Staffs / Skills / Gear (`staff_*` / `sk_*` / `artifact_*`). Shelf icons #48 / #49 — 13 stamped `staff_*` + `artifact_*`. Skills shelf #51 / #52 / #53. Tab chrome stamped **A** (no gens). |
| Art | Panels / partial armor fallbacks OK for M1. Skills shelf and adventurer portraits shipped (#51–#55; chrome **A**). Route-board + Dex art shipped (#57–#59). Not an M1 blocker. |
| Demo seed | Pinned demo seed = **optional**. |

### Interactive order pack (2026-10-05, text-first)

| Slice | What | Tip |
|------:|------|-----|
| 1 | Adventurer **stats/skills panel** on the order | Shipped (Client #30) |
| 2 | **Unlocked syn-target draft** under that panel — persist unlocks **across runs** | Shipped (Client #33; Dex save #31) |
| 3 | **Enemy quest brief** + estimate/outcome window (extends Current/Potential; unlocked items shown, `?` if locked) | Shipped (Client #33) |
| 4 | After-craft **battle playback** (deterministic from mission resolver) then **posture art slots** | Docs #69 / Client #70. Sockets shipped. Posture art **Nov 2**. Not an M1 blocker. Do not reopen |

Slices 1–3 are Design-then-Client and are on `dev`. Slice 4 docs #69 / Client #70 are on `dev`. Do not reopen.

### Parked — not M1 blockers

- **Elite telegraph N5** — **Shipped** (#66 / #67 / #68). It was not required to call M1 exit-ready. Do not reopen.
- **Interactive-order slice 4** — docs #69 / Client #70. Sockets shipped. Posture art stays **Nov 2**. Not required to call M1 exit-ready. Do not reopen playback.

---

## Milestone 2 — Steam demo

Ugly full-experience M1 is the base. Steam demo is **not** a new gameplay system. **Not** shipping the full game. PixelLab / Cursor treated as **fine** for this plan. Harribel watches burn.

### Until-M2 queue (items 1–4 closed)

The four rows are **closed**. Do not pull one back open. Route-graph board art + Dex art sockets are **shipped** (#57 / #58 / #59) — not in this queue. Market chrome and M1 portraits stay closed. The M2 four-job **Client** wire **landed** (#75). UI shell v1 **shipped** (#76 / #77). Neither of those is an open card. The Steam-demo **cut** landed **AAAA** (#79–#82, `2c338ed`). Tip `274a8d6`. Craft hand **landed** (#83 `187911f` / #84 `bff62c8` / #85 `1b49dd1`, [36](../36-craft-hand-cards.md)). Tag chrome on that card is **landed A** (Soft #87 `ebf6583` / Client #89 `274a8d6`, section 6). Client #88 (`e9f503f`) landed drop clear, the cost caption, and N=2 as one fight. Do not read #87, #88, or #89 as open.

| # | Item | Note |
|---:|------|------|
| 1 | M2 four-job catalog expansion | **Closed.** **Stamped** (Jonathan 2026-10-21, #61). Roster accepted. `M2_JOB_POOL` = Wizard, Hexer, Outrider, Oathbound only (draw B), disjoint from `M1_JOB_POOL`. Boss beat and shop walk-in on M2 content use that pool, then 3 named people. **Client wire landed** (#75, `873e7b2`). Portrait uniqueness stamped (#63). Art #64 / #65 landed |
| 2 | Elite telegraph N5 | **Closed.** **Shipped** (#66 / #67 / #68). Marker **A**, Scope **A**. Badge `assets/route/elite_mark.png`. Law in [22](../22-chapter-schedule.md). Do not reopen |
| 3 | Interactive-order slice 4 | **Closed.** Docs #69 / Client #70 (`f083b09`). Sockets shipped. Posture art stays **Nov 2**. Do not reopen playback |
| 4 | Stat / event tuning | **Closed.** Design #72 / Client #73 (`9f03c16`). Accept **A A A A**. [33](../33-until-m2-tuning.md). Do not reopen |

---

## Sequence (until M2)

**Aizen** owns the until-M2 queue.

Jonathan stamps art and mechanism **1:1** (one stamp, one change).

Seat order for each open item:

1. **Grimmjow** — Design
2. **Jonathan** — stamp
3. **Nnoitra** — art (**Harribel** soft-gate before gens)
4. **Ulquiorra** — Client
5. **Szayelaporro** — smoke
6. **Aizen** — merge

Already through that lane on this tip (do not re-hold): market M1 #44 → #45; market M2 tabs #46 → #47; `staff_*` / `artifact_*` icons #48 → #49; skills shelf #51 → #52 → #53; adventurer portraits #54 → #55 (tab chrome stamped **A**, no gens); route-board art + Dex art sockets #57 (`ddbe8b5`) → #58 (`d432fc2`) → #59 (`1765a29`); Elite telegraph N5 #66 → #67 (`080c9e5`) → #68 (`8bc8844`); interactive-order slice 4 #69 → #70 (`f083b09`); until-M2 tuning #72 (`5adae28`) → #73 (`9f03c16`, accept **A A A A**); M2 four-job Client wire #75 (`873e7b2`); UI shell v1 #76 (`daa0280`) → #77 (`c8a5a1a`, stamp **A A B**); craft hand #83 (`187911f`) → #84 (`bff62c8`) → #85 (`1b49dd1`, Soft A′AAAA); tag chrome #87 (`ebf6583`) → #89 (`274a8d6`, Soft A); drop clear / cost / N=2 one fight #88 (`e9f503f`). Ulquiorra does **not** hold a Client on those lanes.

**Catalog lane:** M2 four-job Design is **stamped** (roster accepted; draw B). Portrait uniqueness is stamped and the redraws are on the tip (#63 / #64 / #65). Do not regen. Do not revive #62. The M2 four-job **Client** wire **landed** (#75). Do not re-hold it.

**Slice 4** is on the tip (docs #69 / Client #70). Sockets shipped. Do not re-hold playback. Posture art stays **Nov 2**. Playback **chrome** is in the shipped shell ([34](../34-ui-shell-v1.md)) because it is cheap. Gate / Surface / Socket stay **A**.

**Queue 4** is closed. Until-M2 stat / event tuning shipped (#72 / #73). Do not re-hold that lane. Docs catch-up #74 landed. Do not re-open it.

The shell drop is **docs only** and has shipped. This cut is also **docs only**. No game Client code. UI shell v1 is **shipped** (#76 / #77, stamp **A A B**). Ulquiorra does not hold a shell Client. He does not hold the demo-cut Client: **AAAA** landed (#82). The craft-hand lane **landed** (#83 `187911f` / #84 `bff62c8` / #85 `1b49dd1`). Ulquiorra does not hold that Client. Tag chrome ([36](../36-craft-hand-cards.md) section 6) is **landed A** (Soft #87 `ebf6583` / Client #89 `274a8d6`). Ulquiorra does not hold that wire. Client #88 (`e9f503f`) landed drop clear, the cost caption, and N=2 as one fight. Ulquiorra does not hold that Client. Nnoitra has no seat on the tag-chrome letter. Nnoitra does not gen on the shell lane. The tag-chip letter **B** already landed (#80). Do not regen those chips. The 38 `mat_*` files in [36](../36-craft-hand-cards.md) landed on #84. Do not revive #62. PR #71 stays held: Solenne ×4 art **HOLD** until the PixelLab reset **2026-11-02**; Halden + Vex **KEEP**; shop **ACCEPT**.

---

## Shipped — Steam-demo UI shell v1

**Closed.** Design #76 (`daa0280`). Client #77 (`c8a5a1a`). Law: [34](../34-ui-shell-v1.md). Jonathan GO **A A A A** (2026-10-23 HKT) is locked: open now, craft + order first, market text strip stays, playback chrome included because it is cheap. Stamp **A A B**: palette **A**, order-panel bust **A**, planner chips **B** (text on #77). Do not reopen the shell. The text interim is not the demo law. The demo cut below has since stamped **AAAA** and landed (#79–#82). Craft hand **landed** (#83 / #84 / #85, [36](../36-craft-hand-cards.md)).

Replaces the M1 debug captions on the craft screen. Does not retune craft rules, stamina ints, unlock keys, estimate cutoffs, or `M2_JOB_POOL`. Does not restyle the route board, market, Dex, newspaper, or HUD. Does not touch PR #71 or posture pngs. Posture art stays **Nov 2** (PixelLab reset **2026-11-02**). Solenne ×4 art on #71 stays **HOLD** until that reset. Halden + Vex **KEEP**. Shop **ACCEPT** stays. Do not open a Solenne pass.

---

## Shipped — Steam-demo cut AAAA

**Closed.** Law: [35](../35-steam-demo-cut.md). Jonathan **AAAA**: Current **A**, tag source **B**, vignettes **A**, copy **A**. Docs #79, chips #80, outlook ×28 #81, Client #82 (`2c338ed`). Do not reopen the four letters. Mat shelf faces were outside that stamp. The craft hand below **landed** (#83 / #84 / #85). `look_armor_*` stays the outlook socket.

---

## Landed — Craft hand cards A′AAAA

**Landed.** Design #83 (`187911f`). Art #84 (`bff62c8`). Client #85 (`1b49dd1`). Law: [36](../36-craft-hand-cards.md). Stamp card: [STAMP](../STAMP.md). Tip at the ask was **`2c338ed`**. Live tip is **`274a8d6`**.

Jonathan: Hand **A′**, Drag **A**, Drop **A**, Mat path **A** (`assets/mat/<id>.png` ×38), Placeholder **A**.

Hand A′ is the arc fan. The per-step angle is not ±8°. `step_deg = 32 / (max_hand - 1)`. `n` is the cards in the hand this frame. A full hand at `max_hand = 5` evaluates to 8° per step and a 78px stride. That 8 is an output. Client reads `max_hand` from the setting (the until-M2 lock stays 5).

Art #84 copied the 38 gallery files to `assets/mat/<id>.png`. Client #85 wires the fan, the drag, the drop, and MatFace ×38 (gap 0). Do not reopen. Nine other-owner ids stay uncovered and are not a gen in this stamp.

---

## Landed — Craft card tag chrome

**Landed A.** Jonathan, 2026-10-26 HKT. Soft #87 (`ebf6583`). Client #89 (`274a8d6`). Law: [36](../36-craft-hand-cards.md) section 6. Stamp card: [STAMP](../STAMP.md). Written off docs tip **`0deeaa3`**. Live tip is **`274a8d6`**. Do not read this letter as open. Do not read #87 or #89 as open. Jonathan RED 2026-10-26: the hand reads as tag-less faces. Steam-demo UI should show the tags. That wire is on the tip.

**A (taken):** the sixteen landed `assets/ui/planner/chip_<tag>.png` files at native **16×16**, on the hand (bottom of the **88×88** face well) and on the zone played row (between the **32×32** face and the text). Tags leave the caption. Type and cost stay. **B** and **C** are not taken.

Cost stays the #83 caption. Client #88 (`e9f503f`) landed that line (line 2 is `cost N`), the drop clear, and N=2 as one fight. Hand A′ / Drag A / Drop A / Path A / Placeholder A stay. No gen. No PixelLab. The chip files stay the #80 pixels. Do not regen them. Ulquiorra wired **A** on #89. Nnoitra did not copy. Harribel did not gate.

---

## Park / Later (not M1 exit)

- Elite N5 is shipped — do not list it here. Slice 4 docs #69 / Client #70 are on the tip — do not list playback as open. Posture art stays **Nov 2** (PixelLab reset **2026-11-02**). PR #71: Solenne ×4 art **HOLD** until that reset; Halden + Vex **KEEP**; shop **ACCEPT**. Do not open a Solenne pass
- M2 four-job **Client** wire **landed** (#75, `873e7b2`). Not a Later bullet. Portrait redraws landed (#64 / #65). Do not regen. Do not revive #62
- UI shell v1 **shipped** (#76 / #77, stamp **A A B**). Not a Later bullet. The shell letters are not an open card
- Market restyle, route-board restyle, Dex / newspaper / HUD chrome, and posture gens stay Later. Planner icon chips and outlook ×28 **landed** (#80 / #81 / #82). Do not regen them. Craft hand **landed** (#83 / #84 / #85). The 38 `mat_*` files are on `dev` at `assets/mat/<id>.png` (#84). That export is not a gen. Tag chrome **landed** (#87 / #89). Client #88 drop clear, cost, and N=2 one fight are on the tip. Do not reopen them
- Stat / event tuning is **shipped** (#72 / #73, accept **A A A A**, [33](../33-until-m2-tuning.md)), not a Later bullet
- Unlockable player-owners, encyclopedia, scars, named-unique art, full outlook matrix
- Full game ship (beyond Steam demo)
- Grimmjow deeper bible “client” → adventurer renames
- 0-cost cards / further owner abilities at 0 stamina
- N > 4 zones / split orders

---

## Spend envelope (tools)

| Line | Cap |
|------|-----|
| Cursor / PixelLab | **Fine** for this plan (2026-10-05). Harribel watches burn. |
| Grok | Quiet |

**Supersedes** 2026-09-28: “no Cursor add-on until monthly reset” / “0 PixelLab from Client” / hold 1B until reset.
