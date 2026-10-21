# Roadmap — Chaos Atelier

Updated **2026-10-21**. `dev` tip is **`27df8cc`** (art #65). Route/Dex Client tip stays **`1765a29`**. **M1 ugly full-experience is operationally exit-ready** at that Client tip. **M2 four-job catalog** (Wizard / Hexer / Outrider / Oathbound) is **stamped** (Jonathan 2026-10-21, #61, draw B) in [29](../29-adventurer-catalog.md). `M2_JOB_POOL` is those four only, disjoint from `M1_JOB_POOL`. Not Client. **Portrait uniqueness** is stamped (#63 ACCEPT all 24). Redraws landed: M1 #64, M2 #65. Do not regen. Do not revive #62. That lane does not move the until-M2 queue. **This Design** is Elite telegraph N5 ([22](../22-chapter-schedule.md)). Market + events M1 (#44 Design / #45 Client) and Market M2 tabs (#46 Design / #47 Client) plus 13 stamped `staff_*` + `artifact_*` icons (#48 art / #49 Client wire) are **shipped** — do not mark them pending. Skills shelf Design #51 / art #52 / Client #53 and adventurer portraits art #54 / Client #55 are **shipped**. Tab chrome is stamped **A** (no gens). Route-board + Dex art Design #57 (`ddbe8b5`) / art #58 (`d432fc2`) / Client #59 (`1765a29`) are **shipped** — do not mark them pending. Shiny stays code-only. **`main` is not promoted** (`353f1d4`, README seed only).

Prior stamps still hold as history: **2026-10-13** route map with forks (free per-day `E*` board from #36/#37 superseded); **2026-10-05** M1 / M2 framing + **adventurers** terminology. **Supersedes** the 2026-09-28 Cursor-reset / Phase-0–1C framing in this file. **Supersedes** Round / schedule board (`CHAPTER_ROUND_COUNT=8` as global law) and `crafts_max=4`. Display name **Wombaste**.

See also: [STAMP](../STAMP.md) (historical record; live law is this file), [00-doc-categories](../00-doc-categories.md), [README](../README.md).

---

## Terminology

Call shop / walk-in / appointment / boss-pool people **adventurers**. Do **not** call them “clients.”

**Client** = the Godot **Client** seat / codebase only.

The 2026-10-05 stamp locks the term in PM + STAMP. It does **not** mass-rename historical bible docs. Grimmjow owns deeper bible renames Later. One-line pointers: [03](../03-clients-and-adventure.md), [28](../28-boss-client-pool.md).

---

## Already on `dev`

HEAD **`27df8cc`** (`origin/dev`). Route/Dex Client art is **`1765a29`**. Later on this tip: catalog #61, uniqueness #63, portrait redraws #64 / #65. `main` stays at `353f1d4`.

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
| Adventurer catalog Design **M1 4×3** | #28 · [29](../29-adventurer-catalog.md) | Design shipped (Knight, Mage, Blade Dancer, Lagoon × 3). Portraits are the #54 / #55 track. M2 4×3 is the open Design below, not this row |

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
| 4 | After-craft **battle playback** (deterministic from mission resolver) then **posture art slots** | **Parked.** Not an M1 blocker |

Slices 1–3 are Design-then-Client and are on `dev`. Slice 4 waits until Jonathan opens that lane.

### Parked — not M1 blockers

- **Elite telegraph N5** — Design proposal is in [22](../22-chapter-schedule.md) (2026-10-21). It was not required to call M1 exit-ready. It is still not an M1 blocker. Stamp, then one badge gen, then Client.
- **Interactive-order slice 4** — battle playback + posture slots. Not required to call M1 exit-ready.

---

## Milestone 2 — Steam demo

Ugly full-experience M1 is the base. Steam demo is **not** a new gameplay system. **Not** shipping the full game. PixelLab / Cursor treated as **fine** for this plan. Harribel watches burn.

### Open queue (until M2)

Order is fixed. Do not pull a later row forward. Route-graph board art + Dex art sockets are **shipped** (#57 / #58 / #59) — not in this queue. Market chrome and M1 portraits stay closed.

| # | Item | Note |
|---:|------|------|
| 1 | M2 four-job catalog expansion | **Stamped** (Jonathan 2026-10-21, #61). Roster accepted. `M2_JOB_POOL` = Wizard, Hexer, Outrider, Oathbound only (draw B), disjoint from `M1_JOB_POOL`. Boss beat and shop walk-in on M2 content use that pool, then 3 named people. Client still Later. Portrait uniqueness stamped (#63). Art #64 / #65 landed |
| 2 | Elite telegraph N5 | **This Design.** Proposal in [22](../22-chapter-schedule.md) **Elite telegraph (2026-10-21)**. Default: ahead-of-time badge on every `kind=appointment` (C1 = **N5**). Kind face stays. Awaiting Jonathan stamp. Not Client. Not a gen |
| 3 | Interactive-order slice 4 | After N5. Battle playback + posture slots. Not this PR |
| 4 | Stat / event tuning | **Last.** Knobs stay knobs until a stamp says otherwise |

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

Already through that lane on this tip (do not re-hold): market M1 #44 → #45; market M2 tabs #46 → #47; `staff_*` / `artifact_*` icons #48 → #49; skills shelf #51 → #52 → #53; adventurer portraits #54 → #55 (tab chrome stamped **A**, no gens); route-board art + Dex art sockets #57 (`ddbe8b5`) → #58 (`d432fc2`) → #59 (`1765a29`). Ulquiorra does **not** hold a Client on that lane.

**Catalog lane:** M2 four-job Design is **stamped** (roster accepted; draw B). Portrait uniqueness is stamped and the redraws are on the tip (#63 / #64 / #65). Do not regen. Do not revive #62. Ulquiorra does **not** wire a portrait Client on this Design. Next open item on the until-M2 queue is **Elite telegraph N5** (this Design) → interactive-order slice 4 → stat/event last.

This drop is **docs only**. No game Client code.

---

## Park / Later (not M1 exit)

- Elite telegraph N5 (open Design in `22`; not an M1 exit hole)
- Interactive-order slice 4 (battle playback + posture art)
- M2 four-job **Client** wire (people and draw B are stamped in `29`). Portrait redraws landed (#64 / #65). Do not regen. Do not revive #62
- Stat / event retune (last in the until-M2 queue — after catalog, Elite N5, and slice 4)
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
