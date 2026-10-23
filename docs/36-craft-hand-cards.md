# Craft hand — card fan, drag, mat faces

**Doc id: `36`.** **Status: Stamped A′AAAA** on Design #83 (2026-10-23). Hand **A′**, Drag **A**, Drop **A**, Mat path **A**, Placeholder **A**. Written off `dev` tip **`2c338ed`** (Client #82). No `src/` in this PR. No png copy. No PixelLab gen. No burn. The motion Client and the 38-file export are not on the tip yet. Placeholder **A** still closes the asset lane only when those files land.

The craft screen on that tip already runs the stamped rules ([27](27-craft-mode-stamina.md), shell [34](34-ui-shell-v1.md)). The lower band is five equal text panels in a row (`148×120`, gap 8). A drag preview is a `Label` of the display name. There is no fan, no arc, no overlap, no lift, no tilt, no ghost card, and no settle. Jonathan (2026-10-23 HKT): redo that hand so it reads as a card game, with production motion even while the face is still a placeholder, and put `mat_*` icons on the card and on the materials shelf.

AAAA ([35](35-steam-demo-cut.md), docs #79 / chips #80 / outlook #81 / Client #82) left material shelf faces outside that stamp. This file supersedes that exclusion for **hand card faces** and the **materials shelf** only. Outlook sockets stay `look_armor_*.png`. A mat file is not an outlook. Planner chips and the ×28 outlook copies stay as landed. Do not regen them. PR #71 stays held.

---

## Locks this file does not reopen

| Lock | Where |
|---|---|
| StS cycle: play leaves the hand → discard; dig dumps the remaining hand, then draws; short draw reshuffles discard into draw | `27` |
| One session, stamina **`12 × N`**, hand-size setting **5**, dig cost **2**. The fan reads that setting. It does not write a new integer | `27`, [33](33-until-m2-tuning.md) |
| Regions: order upper left, zones upper right, hand lower. Max **4** zones. N > 4 stays Later | `27`, `34` |
| Play by drag onto a zone, or select a zone and press **1–5**. **D** digs. N = 1 does not require a drag | `27` |
| One **Finish** resolves every zone in listed order. Stamina 0 stays open | `27` |
| Click under **8px** of movement plays the slot. **8px** or more is a drag | tip `CraftHandSlot` |
| Palette **A**, bust **A**, planner chips already icons | `34`, #80, #82 |
| Market tab chrome stays the text strip | UI GO item 3 |
| Shiny is code-only modulate / gold border / shine bar | `32`, `34` |
| `look_armor_*` is outlook art. It is not a `mat_*` face | `35` |

A letter below changes presentation. It does not change a row in that table.

---

## What the player sees

The lower band keeps **Dig · 2** and **Finish** where they are, to the right of the hand. The equal `HBox` of text panels becomes a hand of portrait cards along the bottom, center-aligned. The fan shows the cards in the hand this frame. It does not keep an empty frame for a card that has left.

```
┌────────┐
│ 3      │
│ [face] │
│ name   │
│ cost   │
└────────┘
```

Card size is fixed: **108×148**. It does not `SIZE_EXPAND_FILL`. The face well is **88×88**, nearest, keep-aspect, centered in the upper part of the card. Under it: display name (13, `ink`) and one caption (12, `muted`) for type, cost, and tags, or the skill blurb. The slot index (11, `gold`) sits in the top-left corner. Keys are `1` through `max_hand`. Key `k` plays the card at index `k - 1` when `k` is at most the number of cards in the fan. A higher key does nothing. After a play, the remaining cards move to the new poses from the formula below.

Shell colors stay the stamped set (`chip` fill, `border`, shiny gold). This file adds no color token.

---

## 1. Hand geometry — stamped A′

**Taken.** Jonathan amended letter **A**. The picture of a full hand is still that arc fan. The per-step angle is not a constant. **±8° is not in the Client.** At the live setting `max_hand = 5` and a full hand, the formula below evaluates to 8° per step and ±16° at the ends. That 8 is an output. A later change to the hand-size setting recomputes the step, the overlap, and the arc.

Letter **B** (flat row, no rotation) is **not taken**.

There is no scroll. The fan never draws more cards than `max_hand`. Hover does not change which key a card is. Rest z-order is the slot index (the right card paints over the card to its left). A hovered card paints above the row. Pivot is the bottom center of each card.

### Names

| Name | Meaning |
|---|---|
| `max_hand` | The hand-size **setting**. Until-M2 lock is **5** ([33](33-until-m2-tuning.md)). Client reads the setting. The fan function does not contain the literal `5` |
| `n` | Cards in the hand **this frame**. `0 ≤ n ≤ max_hand`. A card that has left is not a slot. `n` is not padded out to `max_hand` |
| `i` | Index of a card in that fan, `0 .. n-1`, left to right |

### Constants (full-hand picture, not per-step angles)

These three numbers are the letter A arc at a full hand. They do not change when `max_hand` changes. The steps derived from them do.

| Constant | Value | Full hand at `max_hand = 5` |
|---|---:|---|
| `FAN_SPAN_DEG` | **32** | End card to end card, −16° to +16° |
| `FAN_STRIDE_PX` | **312** | Origin of the left end card to origin of the right end card. Neighbor gap 78px on a 108px card, about **28%** overlap |
| `FAN_ARC_PX` | **20** | How far each end card sits below the center card |

### Formula

Use float division. `max_hand <= 1` or `n <= 1` is the upright single-card case (or an empty hand).

```
denom    = max_hand - 1
step_deg = 0 if (n <= 1 or denom <= 0) else FAN_SPAN_DEG / denom
x_step   = 0 if (n <= 1 or denom <= 0) else FAN_STRIDE_PX / denom
arc_step = 0 if (n <= 1 or denom <= 0) else (2 * FAN_ARC_PX) / denom
center   = (n - 1) / 2
rotation(i) = (i - center) * step_deg
x(i)        = (i - center) * x_step
y(i)        = abs(i - center) * arc_step
```

`step_deg` is keyed off **`max_hand`**, not off `n`. Neighbors keep the spacing a full hand would use at this setting. A short hand is that same step, centered, so its total span is `(n - 1) / (max_hand - 1)` of the full span. Changing `max_hand` changes `denom`, and every step changes with it. Changing `n` recenters the same step. It does not stretch two cards out to ±16°.

| `max_hand` | `n` | `step_deg` | `x_step` | `arc_step` | End rotation |
|---:|---:|---:|---:|---:|---|
| 5 | 5 | 8 | 78 | 10 | ±16° |
| 5 | 2 | 8 | 78 | 10 | ±4° |
| 5 | 1 | 0 | 0 | 0 | 0° |
| 7 | 7 | 32/6 | 52 | 20/3 | ±16° |

The first row is the letter A picture. Client checks the fan against that row. A literal `8` in the fan function fails the stamp even when `max_hand` is 5.

### Hover and reflow

Hover is the letter A motion, applied on top of the formula pose. 80ms. `y − 16`, rotation → 0, scale **1.06**. Neighbors do not move during the hover. Hover out returns to that card’s formula pose in 80ms.

When a play commits, `n` drops by one and the remaining cards tween to the new formula poses in **80ms** (quad ease-out). That reflow runs with the zone settle. It does not wait for it to finish. Dig’s deal-in from the drag table targets these formula poses, not a fixed five-slot row.

```
            [3]
         [2]    [4]
      [1]          [5]
```

That sketch is a full hand at `max_hand = 5`. Fewer cards use the same neighbor step and sit in the center.

---

## 2. Drag animation

Pickup spends nothing. The play commits on a successful drop, a click, or **1–5**, through the same `play` the tip already calls. Cancel spends nothing and does not call `play`. The StS move (hand → discard, tagged to that zone) happens at commit, after the settle starts. Dig’s dump rule is unchanged; letter **A** only draws the dump.

The tip’s drag preview is a `Label`. Letter **A** is **taken**. It replaces that preview with the card. The follow tilt clamp of ±8° in the table below is drag motion. It is not the fan step. The fan step is the Hand A′ formula.

### Letter A — production motion (taken)

Tweens use a quad ease-out. The follower is a full card (face or placeholder well), mouse-ignore, on a layer above the zones. A `Label` preview does not meet this letter.

| Beat | Motion |
|---|---|
| Pickup | 120ms. Scale 1 → **1.12**. Tilt **+6°** when the grab is right of the card center, **−6°** when it is left. Shadow offset `(0, 6)`, alpha 0.35. The source slot becomes a ghost: same frame, alpha **0.35**, no face. The other cards stay on their formula poses until the play commits |
| Follow | Card origin sits **24px** above the pointer. Tilt = clamp(horizontal velocity × 0.04, **−8°**, **+8°**) |
| Legal zone | While the pointer is inside a visible zone: that zone’s border goes 2px `gold`, an inner well at gold alpha 0.12 shows, and the zone scales to **1.03** over 80ms. Leaving reverses it. Illegal targets (order panel, the other cards, Dig, Finish, the bar) get none of this |
| Drop | 160ms. The follower settles onto a **32×32** icon slot in that zone’s played stack, scale 1.12 → 1, tilt → 0. Then the hand slot clears. The zone becomes the selected zone |
| Cancel | Release outside every zone, **Esc**, or drop back on the hand. 180ms snap to that card’s formula pose, scale → 1. The ghost fills back in. `n` does not change |
| Click / **1–5** | 200ms fly from the slot to the selected zone’s icon slot, same settle, then the play. N = 1 still does not require a drag. No selected visible zone means no play |
| Dig | Remaining cards move down 48px and fade over 200ms, stagger **30ms** left to right. The new hand deals from scale 0.9 and `y + 24` to rest, stagger **40ms**. Then the piles are whatever the dig rule already produced |

### Letter B — instant

**Not taken.**

Keep a drag that follows the pointer and a drop that plays. No scale, no tilt, no shadow, no ghost alpha, no zone pulse, no settle tween, no dig stagger. Snap is one frame. Click and **1–5** play with no fly.

---

## 3. Drop targets

Zones stay the upper-right row. Count, order, hide-when-unused, click-to-select, and “drop selects” stay. The hit target stays the zone panel. There is no fifth zone. A drop on the inner well and a drop on the rest of the panel are the same play.

### Letter A — card well (taken)

During a drag, the zone draws the inner well from letter 2. After a play, the zone keeps the text line it already shows (name, type, cost) and adds the **32×32** face to the left of that line. Empty zone keeps the construction-only sentence. The face is the same texture as the hand card. A missing file leaves the text line and a 32×32 `chip` square.

### Letter B — hit rect only

**Not taken.**

No inner well, no zone scale, no played icon. The panel receives the drop. Played rows stay text, which is the #77 surface.

---

## 4. Material icons — Soft path

Live catalog is the **38** ids in [11](11-materials.md) and `craft_catalog.gd`. No `mat_*.png` is on the tip. No `mat-stamped-*` folder is on the tip. The bytes are the PixelLab creator gallery, dated **2026-10-13**, 96×96, one frame. Prompts do not store the `mat_*` id. Soft read each picture in the 27-image pack on 2026-10-23. The 11-image pack carries the material name in the gallery title; Skybone Weave and Tar Thread were checked against the pixels.

Two packs make the table. A third, same-day pack (prompt prefix `Chaos Atelier craft MATERIAL icon`, **16** images) is an earlier pass. It is not a second row. Do not land it beside these files.

**Count.** 38 live ids, 38 faces. **Gap 0** on the live catalog.

**Out of this socket.** Nine other-owner ids in [16](16-shop-owners.md) have no face in either pack: `mat_carbon_mesh`, `mat_plasma_thread`, `mat_nullfoam`, `mat_holo_silk`, `mat_servo_leather`, `mat_lizard_skin`, `mat_frog_hide`, `mat_snake_shed`, `mat_root_fetish`. They are not in `craft_catalog.gd` and not in the M1 market bank. This stamp does not gen them.

**Not mat faces.** `look_armor_*` stays the outlook socket. Do not map one onto a card. Skill cards use the landed `assets/m2-market/<sk_id>.png` when that file exists, otherwise the placeholder well. Rune cards (`enc_*`) use the placeholder well. No rune gen in this stamp. Shiny stays the code tint on top of whatever face is showing.

One file feeds the hand well, the zone’s 32×32 icon, and the materials-shelf row. Shelf row: **32×32**, nearest, beside the text the market already shows (name, `$`, count). Tab chips stay off. A missing file leaves the text.

### Letter A — export this table (taken)

Dest root `assets/mat/<id>.png`. Art copies the gallery bytes (same pixels, no regen, no recompress). Client loads `res://assets/mat/<id>.png`.

| `mat_*` id | Source gallery | Dest |
|---|---|---|
| `mat_hemp_plain` | `gallery:dc1e9d0e-26a1-5d9e-94b2-bbd153b77103` | `assets/mat/mat_hemp_plain.png` |
| `mat_cotton_spring` | `gallery:c336d16d-fee7-5559-838a-f4cb7c3bbe0e` | `assets/mat/mat_cotton_spring.png` |
| `mat_wool_grey` | `gallery:4023f23f-eea4-551a-8066-16ef9b8f62b9` | `assets/mat/mat_wool_grey.png` |
| `mat_silk_pale` | `gallery:94c79bed-5277-58ab-858a-ecfeeef0a5b3` | `assets/mat/mat_silk_pale.png` |
| `mat_leather_tan` | `gallery:2ca0dd47-c9db-5efc-ad1f-c0a4109e209b` | `assets/mat/mat_leather_tan.png` |
| `mat_leather_dusk` | `gallery:89011e74-88af-50e4-93ca-7400840e0f76` | `assets/mat/mat_leather_dusk.png` |
| `mat_linen_storm` | `gallery:7e28fbee-819e-5569-a540-8e52a6da6db2` | `assets/mat/mat_linen_storm.png` |
| `mat_velvet_court` | `gallery:14cb591a-e774-599e-81e5-28e61711ca7a` | `assets/mat/mat_velvet_court.png` |
| `mat_iron_scrap` | `gallery:74e5a976-ce5a-5bfc-827d-69a4fe269132` | `assets/mat/mat_iron_scrap.png` |
| `mat_bronze_scale` | `gallery:ca515149-130d-5e03-8978-43b9c7d3154b` | `assets/mat/mat_bronze_scale.png` |
| `mat_wirecloth` | `gallery:dacfd912-3ace-50ce-aadf-6d781f09c1cf` | `assets/mat/mat_wirecloth.png` |
| `mat_steel_plate` | `gallery:38901076-66ad-5957-b738-a13614c675fa` | `assets/mat/mat_steel_plate.png` |
| `mat_chainlace` | `gallery:b1f2de30-535b-58ea-be86-a9ad84409003` | `assets/mat/mat_chainlace.png` |
| `mat_skyiron_filigree` | `gallery:f3405a14-eb95-5258-b1dd-04417b84f45b` | `assets/mat/mat_skyiron_filigree.png` |
| `mat_clayweave` | `gallery:913733f2-a14d-5149-bc0d-3495fdefd0fb` | `assets/mat/mat_clayweave.png` |
| `mat_stone_shard` | `gallery:569bb681-0424-525c-970e-7ca7af60c9bf` | `assets/mat/mat_stone_shard.png` |
| `mat_stonefiber` | `gallery:7841ec29-82c3-5757-a10b-a3088eafd717` | `assets/mat/mat_stonefiber.png` |
| `mat_ember_silk` | `gallery:c4404a52-4c4a-5385-bc6a-c151d954027e` | `assets/mat/mat_ember_silk.png` |
| `mat_magma_thread` | `gallery:640533cc-2c35-5370-b241-6c26815c8ff6` | `assets/mat/mat_magma_thread.png` |
| `mat_frostwool` | `gallery:af6dd5b2-34ca-5eb6-808a-1e9d8e98d341` | `assets/mat/mat_frostwool.png` |
| `mat_glacier_hide` | `gallery:1131981c-8fde-5ad2-9416-a1d76b27ddc9` | `assets/mat/mat_glacier_hide.png` |
| `mat_moonlace` | `gallery:c3f5cc1b-5e7d-5926-88a9-97412c9c89c4` | `assets/mat/mat_moonlace.png` |
| `mat_silver_moth` | `gallery:70a031e5-1ff4-541a-a114-dd60a24be891` | `assets/mat/mat_silver_moth.png` |
| `mat_suncloth` | `gallery:e256d870-9df6-59b2-a4a8-d3f1907c7276` | `assets/mat/mat_suncloth.png` |
| `mat_aureate_foil` | `gallery:45b5d015-76c8-54b1-a395-d7234821f7fd` | `assets/mat/mat_aureate_foil.png` |
| `mat_ivy_cord` | `gallery:b53c55dd-1c66-5873-851f-efb58f251d8c` | `assets/mat/mat_ivy_cord.png` |
| `mat_dire_fur` | `gallery:31cc86a3-27cc-541e-988a-9823147ab1fc` | `assets/mat/mat_dire_fur.png` |
| `mat_whisper_gauze` | `gallery:92841316-9894-5f41-a9a8-03e8db805e9a` | `assets/mat/mat_whisper_gauze.png` |
| `mat_tar_thread` | `gallery:213f41a9-9956-55ef-a010-2c0bff141a6a` | `assets/mat/mat_tar_thread.png` |
| `mat_resin_silk` | `gallery:4afe496f-5e58-5bb5-a98a-f5ea88f57ca8` | `assets/mat/mat_resin_silk.png` |
| `mat_needlegrass` | `gallery:a070e985-d34f-50eb-9c5c-8e3c21295110` | `assets/mat/mat_needlegrass.png` |
| `mat_bladewool` | `gallery:8ab34105-1eed-5b39-afad-64925cc0b42b` | `assets/mat/mat_bladewool.png` |
| `mat_downcloud` | `gallery:60961c3f-644f-5c9b-a167-046014964531` | `assets/mat/mat_downcloud.png` |
| `mat_milkfleece` | `gallery:e1e20e07-191d-542d-acef-ce0404cfa0b6` | `assets/mat/mat_milkfleece.png` |
| `mat_grave_silk` | `gallery:518587b6-a705-5ee8-aca9-8ca0857e0f22` | `assets/mat/mat_grave_silk.png` |
| `mat_null_ink_cloth` | `gallery:9a98bb78-44e7-5e89-b6ff-ae9c0dbc0793` | `assets/mat/mat_null_ink_cloth.png` |
| `mat_altar_linen` | `gallery:094f8950-f270-5138-a59e-e94e05b9a629` | `assets/mat/mat_altar_linen.png` |
| `mat_skybone_weave` | `gallery:4c4829bb-19a2-5e68-b97e-20515e74a443` | `assets/mat/mat_skybone_weave.png` |

The last eleven rows are the titled pack (`Item-only material swatch icon: …`). The first twenty-seven are the pack whose prompt starts `Chaos Atelier MATERIAL icon`.

Close pairs, if a row should swap: wirecloth (woven mesh) and chainlace (rings with a gold edge); clayweave (terracotta tiles), stone shard (loose chips), and stonefiber (grey woven stone); ember silk (red cloth with embers) and magma thread (orange strands); grey wool, frostwool, and steel plate. A swap is two gallery ids on the stamp line. It is not a gen.

### Letter B — different root

**Not taken.** Dest root is `assets/mat/<id>.png`. This stamp does not copy the files.

---

## 5. Placeholder vs land

The face well, when the png is missing, is a `ColorRect` / `StyleBoxFlat` in the stamped `chip` fill, 1px `border`, with the name still set. Nearest filter once a texture exists. A failed load keeps the well. It does not crash. It does not borrow an outlook torso.

**Stamp-closes-on-Art-PR.** This stamp closes the presentation law, including Hand A′. It does not close the asset lane. The asset lane closes when an Art PR has put the 38 files on `dev` and the tip SHA contains them. This doc has no tip SHA for those pngs, so the faces are not done.

### Letter A — motion now, files after (taken)

Ulquiorra may ship the fan, the drag, and the zone well with placeholder faces before the pngs exist. Nnoitra’s copy is a later PR. The motion Client does not wait on that copy. After the files land, the same sockets show them. No second motion stamp.

### Letter B — wait for the files

**Not taken.**

---

## After the stamp

| Who | Does | Holds |
|---|---|---|
| Nnoitra | If path is **A** (or **B** with a root): copy the 38 gallery ids into that root. Same pixels | A gen. The 16-image earlier pass. The nine owner ids. Any `look_armor_*`. A rune sheet. A shiny overlay |
| Ulquiorra | Fan from the Hand A′ formula, drag **A**, drop **A**, wells, shelf `TextureRect`, skill face from `assets/m2-market/` when present | A hardcoded fan step. A rule change. A fifth zone. A new hand-size integer. Loading a mat png into Current / Potential |
| Szayelaporro | After that Client | This docs PR |

Harribel has nothing to gate in this PR. Nothing is burned. A later gen (the nine owner ids, or a rune face) is a different stamp, and Harribel gates that one.

---

## Stamp card

### Review

| File | Section |
|---|---|
| `docs/36-craft-hand-cards.md` | This law. Five letters, motion table, 38-row path, gap note |
| `docs/27-craft-mode-stamina.md` | Pointer. Rules stay |
| `docs/34-ui-shell-v1.md` | Pointer. Palette stays. #77 text hand is the record this file redoes |
| `docs/35-steam-demo-cut.md` | AAAA stays stamped. Mat-as-outlook stays forbidden. Shelf/hand faces move here |
| `docs/11-materials.md` | Face pointer |
| `docs/32-shop-and-events.md` | Shelf uses the same png. Text-strip chrome stays |
| `docs/15-outlook-gen-list.md` | Outlook wire landed. Mat png is still not an outlook |
| `docs/05-art.md` | No gen in this PR |
| `docs/pm/phase-1-plan.md` | Stamp recorded. Client and the export are the next seats |
| `docs/README.md` · `docs/00-doc-categories.md` · `docs/STAMP.md` | Index and this card |

### Decisions

The lines below are the ask as written. They are not open.

1. **Hand — A or B.** **A:** arc fan. **B:** flat row. Jonathan wrote **A′**: the arc fan, with the step computed in section 1. `step_deg = FAN_SPAN_DEG / (max_hand - 1)` with `FAN_SPAN_DEG = 32`. `n` is the cards in hand this frame. A full hand at `max_hand = 5` evaluates to 8° per step. That 8 is not a constant.

2. **Drag — A or B.** **A:** the motion table. **B:** instant. Jonathan wrote **A**.

3. **Drop — A or B.** **A:** inner well and 32×32 played face. **B:** hit rect, text only. Jonathan wrote **A**.

4. **Mat path — A or B.** **A:** 38 rows → `assets/mat/<id>.png`. **B:** another directory. Jonathan wrote **A**.

5. **Placeholder — A or B.** **A:** motion on `chip` wells; asset lane closes on the Art PR. **B:** hold the motion for the files. Jonathan wrote **A**.

### Questions

None.

### Blocks

The five letters are answered. Nothing on this card blocks the motion Client or the export. The asset lane stays open until the 38 files are on `dev`.

**Holds.** PR **#71**: Solenne ×4 art **HOLD** until the PixelLab reset **2026-11-02**. Halden + Vex **KEEP**. Shop **ACCEPT**. Do not open a Solenne pass. Do not revive **#62**. Posture art stays **Nov 2**. Outlook ×28 and the sixteen planner chips stay landed. Do not regen them. No gens in this PR. No `src/` in this PR.

### Stamp

**A′AAAA.** Hand A′. Drag A. Drop A. Path A. Placeholder A.
