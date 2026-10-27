# Solenne height / body — Soft lock

**Doc id: `38`.** **Status: Open.** Grimmjow stamp-ask. Written off `d51d47e` (Soft chrome #91). Docs only. No `src/`. No assets. No PixelLab. No gens. No burn. No edit to PR #71 or to any file under `assets/adv/posture/`. Silence is not **A**.

Jonathan (via Aizen), before the **2026-11-02** PixelLab reset: Soft Design locks **character height and body shape** before Nnoitra Phase A full-body **front + back**. A bust ACCEPT is not that lock. The #71 chibi read is not the scale.

---

## Locks this file does not reopen

| Lock | Where |
|---|---|
| Soft chrome **Node A′ · Brief A · Event A** | [37](37-player-facing-chrome.md) #91. Soft QC on that Client stays Ulquiorra’s lane. This card does not hold it and does not release it |
| Soft A′AAAA hand / drag / drop / mat path / placeholder | [36](36-craft-hand-cards.md) #83–#85 |
| Tag chrome **A** | [36](36-craft-hand-cards.md) §6. #87 / #89 |
| Drop clear, cost caption, N=2 as one fight | Client #88 (`e9f503f`) |
| IO4 Gate **A** / Surface **A** / Socket **A** | [30](30-interactive-order.md) docs #69 / Client #70. Playback stays closed |
| Posture canvas | Pro Flash **64×64 soft-stipple**, one frame, full figure. That size is not the **96** bust. Portrait socket stays `assets/adv/<adv_id>.png` |
| Halden KEEP | #71 tip `12f50ee`. Five `adv_halden_rook_*.png`. Do not reburn |
| Vex KEEP | #71 tip `2cb74a4`. Five `adv_vex_bramble_*.png`. Do not reburn |
| #71 shop ACCEPT | Record of that pass (`dbffee2` in_shop, then `9fcd221` ×4). It does not skip the shop loop on the next `character_id` |
| Solenne ×4 **HOLD** | `in_fight` / `ult` / `defend` / `attack` on #71 stay **HOLD** until **2026-11-02**, and until the phase order below is actually at the ×4 step |
| Portrait uniqueness #63 / redraws #64 / #65 | [29](29-adventurer-catalog.md). Do not regen. Do not revive #62 |
| Hand / AP / synergy mechanism review | Parked. Not this file |

---

## Problem

PR #71 Solenne posture reads **chibi / short** next to the Halden and Vex KEEP figures. Jonathan REDO **2026-10-22** on Solenne tip `0ae24bb` (FULL REDO, character path ×5). The next commit on that PR is `d20bbfa` (**proportion REDO** ×5). Shop-only style then replaced `in_shop` (`dbffee2`). The four fight states after shop ACCEPT are `9fcd221`. Those four stay **HOLD**.

The 96 bust of Dame Solenne Ward can be accepted and the body can still be wrong. Bust crop is head and shoulders. Height is the full figure in the 64 cell. Soft will not clear Phase A front + back until this height / body card is stamped.

`29` and `30` and the #71 commit subjects do not print a head-count. Solenne’s portrait row is face, hair, and mouth (high elf, court braid, clean court plate). `30` locks the posture canvas at 64×64 full figure and says the 96 file is the wrong crop. The fraction below is Jonathan’s proportion target for the `0ae24bb` REDO, checked against the KEEP tips named on #71, and written here so the next burn has a lock.

---

## Soft check (frame scale)

Compare **in_shop** (standing, weapon lowered). Attack width includes the weapon and is not the scale. Painted bounds are the opaque figure; empty margin is ignored. Canvas is 64×64.

| Still | Tip | Painted height | Painted width |
|---|---|---:|---:|
| Halden `in_shop` KEEP | `12f50ee` | 57 | 32 |
| Vex `in_shop` KEEP | `2cb74a4` | 61 | 30 |
| Solenne `in_shop` (the REDO’d read) | `0ae24bb` | 55 | 26 |
| Solenne `in_shop` proportion pass | `d20bbfa` | 56 | 25 |
| Solenne `in_shop` shop ACCEPT (`dbffee2` = `9fcd221`) | `9fcd221` | 57 | 24 |

Crown-to-feet ink on the shop ACCEPT meets Halden’s height and stays narrow (24 against 30–32). Matching the bottom of the cell is not the lock. Head-to-body and limb scale are the lock. `0ae24bb` is the short, large-head read. `d20bbfa` and the shop ACCEPT are not a height stamp.

---

## Reference bar

**Height A (Design recommend).** In the 64×64 full-figure frame, Solenne’s standing figure is **3 to 3.5 heads** tall, crown to feet.

- At **3** heads the head is **one third** of the figure.
- At **3.5** heads the head is a little under a third.
- That band is the adult adventurer scale of Halden KEEP `12f50ee` and Vex KEEP `2cb74a4`.
- It is not a fashion 7-head drawing. It is not the #71 chibi read: a larger head on a shorter, narrower body than those KEEP stills (`0ae24bb` painted 55×26; shop ACCEPT still 57×24 against Halden 57×32 and Vex 61×30).

**Body shape is inside Height A.** No second letter. `29` does not offer Solenne a lean-versus-stocky fork. Her race row is high elf. Her outfit row is clean court plate. The knight silhouette lock is plate and gauntlet for Halden, Vex, and Solenne together. Halden’s dwarf bust is his portrait, not a Solenne body to pick. Vex’s “lean” cell is the face. Court-knight lean is allowed when the head-count and the crown-to-feet scale match the two KEEP in_shop stills. A slimmer torso than Halden’s plate is that lean. A smaller doll in the cell is the chibi fail.

**Height B.** Jonathan writes a different head-count, or a different crown-to-feet scale, on the line. The line names the number. A face note is not B. Silence is not **A**.

---

## What this stamp locks

- Overall character height in the 64×64 full-figure frame (crown-to-feet in the KEEP in_shop band: Halden 57, Vex 61 on that canvas).
- Torso and limb proportion.
- Head-to-body ratio (3–3.5 heads under Height A).
- Stance scale against Halden `12f50ee` and Vex `2cb74a4`.

## What this stamp leaves open

- Face likeness.
- Hair and outfit chrome.
- Kit details (sword, pauldron, trim).
- Shop art-style ACCEPT. That stays the **in_shop** iterate, after the height stamp and after Jonathan stamps front + back, on the new `character_id`. The #71 shop ACCEPT does not carry over.
- The front + back burn itself. This card authorizes the gate. It does not burn.
- The four fight states.
- Any png already on #71.

---

## Method (IO4, unchanged)

PixelLab **character-creation** path, the path that produced the KEEP figures. Not Pro Flash freeform.

1. `create_character_pro_flash` at **64×64**, low top-down (the camera on Halden `12f50ee` and Vex `2cb74a4`).
2. Portrait `style_image` = the landed bust `assets/adv/adv_solenne_ward.png`. Same pattern as Halden’s own bust on `12f50ee`. The bust is the style image. It is not the height lock, and it is not a face ACCEPT.
3. `create_character_state` ×5 only after shop ACCEPT, from that same `character_id`.

Facing on those later states stays the #71 process: shop, fight, ult, and defend face southeast; attack faces east. This card does not reopen that facing.

---

## Phase order after the letter

Ulquiorra, Nnoitra, and Szayelaporro **hold gens** until the letter, the letter PASS, and Aizen RELEASE. Ulquiorra has no Client on this card. Szayelaporro does not smoke a gen. Nnoitra does not burn in this PR.

1. **Jonathan** writes **Height A** or **Height B** (B names the count).
2. **Soft letter PASS.** Grimmjow passes the letter when it locks height and body. A face-only reply fails. Silence fails.
3. **Aizen RELEASE** (merge).
4. On or after **2026-11-02**, Aizen soft-gates **Harribel** if a burn is next.
5. **Nnoitra Phase A is front + back only.** Two full-body frames, front and back, from `create_character_pro_flash` on one `character_id`. No `create_character_state`. No `in_shop`. No `in_fight`, `ult`, `defend`, or `attack`.
6. **Soft QC** those two frames against Halden `12f50ee` and Vex `2cb74a4` in_shop. QC line: 3–3.5 heads under Height A (or the count Jonathan wrote), crown-to-feet in that KEEP band, court-knight lean allowed, chibi shrink fails. Face, hair, and outfit are not this QC.
7. **Jonathan stamps** the front + back.
8. **in_shop only**, character path, same `character_id`, until Jonathan ACCEPTS art style.
9. **Then** the four remaining states from that `character_id`.

Do not burn all five while height is open or shop style is open. Do not edit the #71 pngs to sneak the burn forward. The reset date does not block this docs stamp. It blocks step 5.

---

## Stamp card

### 1. Files to review

| File | Section |
|---|---|
| `docs/38-solenne-height-body.md` | This law. Problem, KEEP bar, Height A / B, phase order |
| `docs/30-interactive-order.md` | Pointer only. Gate / Surface / Socket stay **A**. Canvas stays 64. Bust is not the height |
| `docs/05-art.md` | Pointer only. No gens |
| `docs/29-adventurer-catalog.md` | Read only. Solenne row has no body-shape fork. Do not edit the catalog in this PR |
| `docs/pm/phase-1-plan.md` | Open card. #71 ×4 stays **HOLD** |
| `docs/STAMP.md` | This card |
| `docs/README.md` · `docs/00-doc-categories.md` | Index |

### 2. Decisions

1. **Height — A or B.** **A (Design recommend):** Solenne matches Halden `12f50ee` and Vex `2cb74a4` adult scale in the 64×64 full figure. **3–3.5 heads**, crown to feet (head about one third of the figure at 3 heads). Court-knight lean is inside A when that count and that crown-to-feet scale match. Soft QC the later front + back against those two in_shop KEEP stills before any further Solenne posture burn. **B:** Jonathan writes a different head-count or crown-to-feet scale on the line. Write **A** or **B**. Silence is not **A**. Design recommends **A**.

Body shape is not a second letter. The catalog has no lean-versus-stocky choice for Solenne. A stocky letter would invent one.

### 3. Questions

None.

### 4. Blockers

An unanswered Height line (**A** or **B**). Silence is not **A**. **B** without a number on the line does not stamp.

Harribel’s soft-gate is before the front + back burn, not before this docs stamp.

The **2026-11-02** reset blocks the burn. It does not block this stamp.

PR #71 does not block. Solenne ×4 stays **HOLD**. Halden + Vex stay **KEEP**. Shop ACCEPT stays the record of that pass. No png in this PR.

Nothing else blocks. No PixelLab in this PR. No `src/` in this PR. Soft chrome, Soft A′AAAA, tag chrome **A**, and IO4 playback stay landed. Do not revive #62. Mechanism review stays parked.

## Design recommends

**Height A.** Body shape folded in: match the Halden / Vex adult silhouette; court-knight lean is allowed when the head-count matches.
