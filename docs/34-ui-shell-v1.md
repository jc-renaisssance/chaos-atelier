# Steam-demo UI shell v1 — craft + order

**Doc id: `34`.** **Status: Shipped** for palette, bust, and the craft frame. Jonathan stamp **A A B** (palette **A** / order-panel bust **A** / planner chips **B**) on Design #76 (`daa0280`). Client landed (#77, `c8a5a1a`). `dev` tip is **`4d9fa19`**. The letter tables below are the shell record. Do not reopen palette or bust. PR #71 stays held: Solenne ×4 art **HOLD** until the PixelLab reset **2026-11-02**; Halden + Vex **KEEP**; shop **ACCEPT**. Do not open a Solenne pass. Posture art stays **Nov 2**. Does not revive #62.

**Demo override (2026-10-23).** Planner chips **B** shipped as text interim, icon chips Later. That interim is **not** live law for the Steam demo. Chips are icons. The files are **not** on the tip — source letter is [35](35-steam-demo-cut.md) Decision 2. Outlook art on Current / Potential, the title screen, graph commit, one fight, and Brief / Estimate sentences live in `35`. This file does not reopen them as shell letters.

This file is the **presentation** law for the dedicated craft screen. Rules stay in [27](27-craft-mode-stamina.md) and [30](30-interactive-order.md). A stamp here does not retune stamina, unlocks, estimate cutoffs, or `M2_JOB_POOL`.

---

## Jonathan GO — locked (2026-10-23 HKT)

**A A A A.** Recorded. Not re-asked on the card below.

| # | Letter | Lock |
|---:|---|---|
| 1 | **A** | Open the shell now. Placeholders, Godot `StyleBox` / `ColorRect` / `Label`, and existing bust sockets are enough. Do not wait on PixelLab or the Nov 2 posture wave. |
| 2 | **A** | First lane is **craft + order**. |
| 3 | **A** | Market chrome **stays the text strip**. Do not reopen fancy tab chips. |
| 4 | **A** | Playback chrome is in this shell **because it is cheap**. Same frames as craft. Skip stays. Resolved under [Playback](#playback-chrome--included) below. |

---

## What the shell replaces

The live craft screen already implements `27` / `30`: upper-left order, upper-right zones, lower hand, Dig, Finish, Current / Potential, slice 1–3 text, and the slice 4 playback step (Client #70). The M1 surface is still the ugly build: debug captions (`UPPER LEFT`, `SLICE 2`, `RESOLVER`), default Godot buttons, a raw stamp-JSON panel, and the same color literals copied per script.

Shell v1 keeps that screen and that input. It replaces the debug chrome with one frame language. It does not add a scene, a combat pass, or a texture.

---

## One screen

Craft stays its own screen. It is not the route board.

```
┌──────────────────────────────────────────────────────────┐
│ Craft                         Stamina  remaining / start │
├────────────────────────────┬─────────────────────────────┤
│ Order                      │ Zones (≤4)                  │
│  name · job · six stats    │  [1] [2] [3] [4]            │
│  one ask_*                 │                             │
│ Plan       (text on #77)   │ Current    Potential       │
│ Brief                      │ (selected zone only)        │
│ Estimate                   │                             │
├────────────────────────────┴─────────────────────────────┤
│ Hand  1  2  3  4  5              Dig · 2        Finish   │
└──────────────────────────────────────────────────────────┘
```

After **Finish**, the playback step uses this same frame, then the mission report the Client already shows (`23`). Playback is not a fourth block on the order panel.

The Plan cell is what #77 shipped (tag name on the button). The demo cut replaces that cell with an icon ([35](35-steam-demo-cut.md)). #77 did not load a chip file.

| Region | Shows | Does not show |
|---|---|---|
| Header | Screen title **Craft**. One stamina pool, `remaining / start`, bar. | A second pool. A piece cap. |
| Upper left | Slices 1–3. | Current / Potential. The stamp JSON. Weight integers. |
| Upper right | Up to 4 zone cards. Current and Potential for the **selected** zone. | A fifth zone. A readout on every zone at once. |
| Lower | Five hand slots. **Dig**. **Finish**. Draw / discard counts as a caption. | Construction cards. An auto-finish. |
| After Finish | Playback in this frame, then the existing report. | A new resolver. |

Enter session: zone **1** selected. Stamina 0 stays open. Only **Finish** crafts. Empty zone at Finish stays the construction-only path. Keys **1–5** and **D** stay. Drag into a zone stays. N = 1 does not require a drag.

Player-facing titles are the words in the diagram. They replace the debug captions. They are not lore titles. Fancy titles stay Later.

---

## Palette and type

**Decision 1.** The colors below are the literals already painted on the craft screen and the playback step (`WOOD`, `PANEL`, `INK`, `GOLD`, `MUTED`, `BORDER`, hand `CHIP`, playback `PLATE`). Letter **A** names them once and applies them to frames, cards, hand, buttons, the stamina bar, and playback. Letter **B** drops those overrides for the Godot default theme on this shell only.

Ground is **dark wood**. Type is **parchment ink**. This is not a light paper page and not a texture.

### Letter A — named colors

One const block, shared by the craft screen, zone cards, hand slots, and the playback step. Godot 4.7: `Color(r, g, b)` literals, not `Color.html`. No theme-texture file. No font file. Default font, size overrides only.

| Token | RGB | Use |
|---|---|---|
| `wood` | `0.102, 0.078, 0.063` | Full-screen `ColorRect` |
| `panel` | `0.165, 0.129, 0.094` | Frame and card fill |
| `chip` | `0.227, 0.173, 0.094` | Hand-card fill |
| `plate` | `0.240, 0.200, 0.160` | Playback actor plate |
| `border` | `0.239, 0.204, 0.173` | Idle 1px border |
| `gold` | `0.788, 0.635, 0.153` | Titles, selected border, primary button, stamina fill |
| `ink` | `0.910, 0.835, 0.690` | Body |
| `muted` | `0.710, 0.643, 0.541` | Captions |

| Role | px | Token |
|---|---:|---|
| Screen title | 22 | `gold` |
| Person name | 16 | `gold` |
| Section title | 13 | `gold` |
| Body | 13 | `ink` |
| Caption, meta, `?` | 12 | `muted` |
| Slot index | 11 | `gold` |

`StyleBoxFlat` set. Corner radius **8** on every box in the set.

| Box | Fill | Border | Content margin L/R/T/B |
|---|---|---|---|
| Frame | `panel` | 1px `border` | 10 / 10 / 8 / 8 |
| Zone card, idle | `panel` | 1px `border` | 10 / 10 / 8 / 8 |
| Zone card, selected | `panel` | 2px `gold` | same |
| Hand card | `chip` | 1px `border` | 8 / 8 / 8 / 8 |
| Hand card, shiny | existing shiny fill and gold border | 2px `gold` | same |
| Button, primary (**Finish**) | `panel` | 2px `gold` | 10 / 10 / 6 / 6 |
| Button, secondary (**Dig**, **Skip**, **Return**, planner chip) | `panel` | 1px `border` | same |

Stamina `ProgressBar`: track `wood`, fill `gold`, percentage hidden. Height 16, as the bar already is.

Shiny stays the code tint already on an enchanted material (`mat_enchant_id`, modulate, gold border). No shiny texture.

Widgets on this shell: `StyleBoxFlat`, `ColorRect`, `Label`, `TextureRect`, `Button`, `ProgressBar`, `PanelContainer`, box containers. `TextureRect` only for a file that already exists (bust, posture). Nearest filter. No new generated texture.

### Letter B — Godot default

**Not taken.** Jonathan wrote **A**.

Same layout, same labels, same controls. Remove the custom color and `StyleBoxFlat` overrides on the craft screen, zone cards, hand slots, and playback step. Default Button, default panel, default progress bar. No wood tokens. No new texture. Sockets still follow Decision 2.

---

## Zone cards

Max **4**. An unused zone stays hidden when the order has fewer pieces. Zone *i* is `construction_ids[i - 1]`. Title is the construction’s display name. Caption is the index. Selected reads as the gold border (letter A) or the control’s selected state (letter B). The word “selected” is not a debug suffix.

Body: empty zone keeps the construction-only sentence already on the card. A played card stays a text line (display name, type, cost). The #77 surface has no card art. A 32×32 played face, if [36](36-craft-hand-cards.md) Drop is **A**, sits beside that line. It is not outlook art.

Click selects. A drop plays into that zone and selects it. No zoneless play. No fifth zone. N > 4 stays Later / split.

---

## Hand, Dig, Finish

Five slots, left to right, keys **1–5**. An empty slot is still a frame: index, no name. A filled slot shows display name, type, cost, and tags (or the skill blurb). Play leaves the hand. The slot does not keep the card.

**Card fan (open, 2026-10-23).** This section is the #77 record: five frames in a row, text on the chip fill. The redo is [36](36-craft-hand-cards.md). Palette tokens stay. Do not reopen the shell letters.

**Dig** spends **2**. Label `Dig · 2`. **D** still digs. Dig dumps the hand, then draws. It does not end the session.

**Finish** is the only end. Label `Finish`. One click resolves every zone in listed order. Stamina 0 does not press it and does not hide the hand.

**Return** (back to the route graph, after the report path the Client already has) stays a secondary button. It is not a second finish.

Draw-pile and discard-pile counts may stay one muted caption under the row. No pile pictures.

---

## Order panel — slices 1–3

Content is `30`. This shell only sets frames and type. Upper left, in this order:

1. **Order.** Display name and job. Six stats `HP ATK DEF RES MOB PRE`. One `ask_*` name and its short line. Listed constructions. That adventurer’s requirement-taste line. Boss beat: the drawn named `adv_*`, fighting the announced boss. Job aliases resolve to the named row, as they do now.
2. **Plan.** Unlocked outlook + tier as text. Locked stays `?`. Fresh profile stays only `?`. Click a tag chip cycles low → mid → apex, then the cross rule in `30`. The chip does not change `construction_ids`.
3. **Brief.** Guild-quest text already built for slice 3. No poster illustration.
4. **Estimate.** The gated fields already computed: planned outlook, favor hits, punish hits, skill, neg warnings, band. `?` until the Dex says the row is known. The weight integers (`FAVOR_W` and the rest) stay in code and in the test log. They leave the player label.

The raw stamp JSON panel leaves the player screen. Test logs in `20` stay. No new Required key.

### Planner chips

**Decision 3 — record.** **A:** each chip is the tag name on a secondary button. No icon. **B:** icon chips. Design recommended **A**. Jonathan wrote **B**. Client #77 painted the tag name (text interim) because no chip file was in that lane.

**Live demo law** is [35](35-steam-demo-cut.md): the chip is an icon. Text interim is not the ship bar. No discrete tag-chip PNG is on the tip. Do not treat this record as “icons already exist.”

### Order-panel bust

**Decision 2.** Slice 1 (2026-10-05) says do not show portraits. The Client already has a 96 socket, and slice 4 socket **A** puts `in_shop` beside that bust. This letter picks the shell.

| Letter | Order head |
|---|---|
| **A (Design default)** | When `assets/adv/<adv_id>.png` exists for the resolved named id, a `TextureRect` at **96×96**, nearest, sits beside the text. A missing file hides the socket. Name, job, and the rest of the panel stay. |
| **B** | Text only on this shell. Do not show the bust. The file stays on disk. **Not taken.** |

`in_shop` (`30` socket **A**) stays beside the bust under **A**, and beside the text under **B**. A missing posture file hides that slot. Do not scale the 96 bust into the posture slot. Do not crop a bust into a posture. `appt_*` has no bust file: text, and playback actor id null. No Scrap Duelist face.

**A** is the stamp (Client #77). It supersedes the slice 1 line “do not show portraits” for this order panel only. It does not regen a portrait. It does not open a second canvas.

---

## Current and Potential

Required by `27`. They sit in the **upper right**, under the zone row, for the **selected** zone only. Two frames, titles **Current** and **Potential**, bodies the strings the readout already builds. Locked outlook stays locked / hidden. No name spoiler past “locked”.

**Outlook art** is the open cut in [35](35-steam-demo-cut.md): stamped `look_armor_*.png` from `armor-stamped-2026-09-29/` and `armor-cross-tag-locked-2026-10-02/`, Potential required, Current if Decision 1 is **A**, locked hides the picture. The “no outlook art” line in the shell record is the #77 surface. It is not the demo law.

Per-zone simultaneous readouts stay Later. Moving the pair out of the order column does not change the bag they read.

---

## Playback chrome — included

GO item 4 is include **if cheap**. It is cheap, so it is in this shell. Not a letter. The stamp kept it. Client #77 uses this frame. Do not pull it back out.

- Same screen frame, type scale, and button roles as craft (letter A or B, whichever stamps).
- **Skip** stays. Gate **A** behavior stays: Skip ends this playback and opens this piece’s report. It does not skip the report or a later piece.
- Beat list, actor slot, and placeholder rules stay Client #70 (Gate **A**, Surface **A**, Socket **A**). A missing png keeps the row and the flat placeholder. A failed load stays the 1×1 stand-in. No crash.
- Titles: **Playback**, **Skip**. Beat rows stay the labels #70 already draws.
- No new beat. No duration stamp. No HP tween. No enemy posture. No second sim.

Writing **defer** on the card pulls this chrome out of the Client follow. Playback then keeps the #70 frame until a later UI lane. Silence keeps it here.

---

## Out of this shell

- Route board, market, events, Dex, mission-report layout, newspaper, HUD.
- Market tab strip stays **Materials | Staffs | Skills | Gear** text. No chip gens.
- New people. #62. Portrait regen. Posture gens. Nov 2 stays Nov 2.
- **PR #71** and any file under `assets/adv/posture/`. Solenne ×4 art stays **HOLD** until the PixelLab reset **2026-11-02**. Halden + Vex **KEEP**. Shop **ACCEPT** stays. Do not edit that PR. Do not replace those pngs. Do not open a Solenne pass.
- Craft rules, `12 * N`, hand **5**, dig **2**, play costs, zone max **4**, unlock keys, `unlocked_builds`, estimate weights, S–F cutoff table, `M1_JOB_POOL`, `M2_JOB_POOL`.
- Elite N5 letters. IO4 Gate / Surface / Socket letters. Those are shipped.
- A new `20` Required key.

---

## Nnoitra

The graphic seat did not open. Client #77 used placeholders, `StyleBoxFlat`, and existing bust files. **No gens on this lane.** No PixelLab. No new textures. Existing bust files and existing posture files stay read-only. Placeholders stay legal. Harribel has nothing to soft-gate here because nothing is burned. Do not open a graphic pass.

---

## Client (landed — #77)

Not open work. Ulquiorra followed this file on #77 (`c8a5a1a`), stamp **A A B**. Szayelaporro smoked. No art seat. Do not re-queue this shell.

Theme tokens and scene chrome only. No mechanism retune.

| What #77 followed | Holds still |
|---|---|
| Letter **A**: one shared color block and the `StyleBoxFlat` set on craft, zones, hand, and playback | A new texture, a font file, PixelLab, a switch to letter **B** |
| Player titles from the diagram. Debug captions and the stamp-JSON panel leave the player screen | Dropping test logs. A new `20` key |
| Zone cards ≤4, five hand frames, Dig, Finish, Return, keys 1–5 and D | Changing `12 * N`, dig 2, hand size, zone max, Finish-only, empty-zone path |
| Order column is slices 1–3 text. Estimate label drops the weight-integer suffix | Changing `ask_*`, unlock, `?` gates, weights, or S–F cutoffs |
| Bust letter **A**. `in_shop` hide-if-missing stays. Planner chips letter **B** painted as text on #77 | Regen, a #71 edit, a posture png. Icon files are the open cut in [35](35-steam-demo-cut.md), not a shell reopen |
| Current / Potential under the selected zone | A readout on every zone at once |
| Playback uses the same frame. Skip stays | A new beat, a second sim, hiding Skip |
| Market, route, Dex, newspaper, HUD untouched | A restyle of those screens |

---

## Stamp card

### Review

| File | What |
|---|---|
| `docs/34-ui-shell-v1.md` | This law. Palette, bust, planner chips. Playback included because it is cheap |
| `docs/27-craft-mode-stamina.md` | Pointer only. Layout, stamina, Finish-only, zones, hand, Current / Potential do not move |
| `docs/30-interactive-order.md` | Pointer only. Slice rules stay. Bust **A** supersedes “do not show portraits” on the order panel only |
| `docs/05-art.md` | Pointer only. No gens. #71 hold stays |
| `docs/pm/phase-1-plan.md` | Tip `c8a5a1a`. This shell is shipped. #72–#77 are landed |
| `docs/README.md` | Index |
| `docs/STAMP.md` | This card |

### Decisions

**Record:** **A / A / B** (Jonathan, Design #76). Palette **A**. Bust **A**. Planner chips **B** — text interim on Client #77; icon chips Later. Client #77 (`c8a5a1a`). The three lines below are the ask as written. They are not an open ask. Design had recommended planner chips **A**. Jonathan wrote **B**.

The GO **A A A A** is already written. These three were the remaining letters.

1. **Palette / type — A or B.** **A (Design default):** dark wood ground, parchment ink, the named color block and `StyleBoxFlat` set in this file, including buttons and the stamina bar. No textures. **B:** Godot default theme on this shell. Same layout and labels. Write **A** or **B**. Silence is not **A**. Design recommends **A**.

2. **Order-panel bust — A or B.** **A (Design default):** show the existing 96 bust beside the text when `assets/adv/<adv_id>.png` exists. Missing file → text. `in_shop` stays beside it and hides when its own file is missing. **B:** text only until a later lane. Write **A** or **B**. Silence is not **A**. Design recommends **A**. **A** supersedes `30` slice 1 “do not show portraits” for this panel only.

3. **Planner chips — A or B.** **A (Design default):** tag name on a text button. No icon. **B:** icon chips. **B** waits on art and is outside this lane. Write **A** or **B**. Silence is not **B**. Design recommends **A**.

Playback chrome is **not** one of these letters. It is in the shell (GO item 4, cheap). Market text strip is **not** one of these letters (GO item 3).

### Questions

None.

### Blocks stamp

**Stamped.** The lines below are the ask as written. They are not open.

An unanswered palette line (**A** or **B**). Silence is not **A**.

An unanswered bust line (**A** or **B**). Silence is not **A**.

An unanswered planner-chip line (**A** or **B**). Silence is not **B**.

Playback inclusion does not block. **Defer** was not written. Client #77 kept this chrome. It is not a fourth open question.

Nothing else blocks. No PixelLab. No `src/` in this PR. PR #71 is not in this PR (Solenne ×4 stays **HOLD** until **2026-11-02**; Halden + Vex **KEEP**; shop **ACCEPT**). Elite N5 is not in this PR. Slice 4’s gate, surface, and socket are not in this PR. #72, #73, #74, #75, #76, and #77 are not open. Do not revive #62.

### Design recommends

**Palette A. Bust A. Planner chips A.** Playback chrome stays in this shell. Jonathan’s stamp is **A A B** (chips **B**, text interim on #77). The recommendation is the shell record. It is not an open shell ask. The Steam-demo cut ([35](35-steam-demo-cut.md)) overrides the text interim: chips are icons, and the icon files are not on the tip.
