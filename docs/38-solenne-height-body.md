# Solenne height / body — Soft lock

**Doc id: `38`.** **Status: Stamped height-split** (Jonathan 2026-10-27, Soft #92 Soft amend). Written off tip **`207b20b`** (Client Soft #93 wire #95 / scrap_breath Soft #96). Docs only. No `src/`. No assets. No PixelLab. No gens. No burn. No edit to PR #71 or to any file under `assets/adv/posture/`. The Height A / B stamp card is **dropped**. There is no open A|B on this file.

Jonathan (2026-10-27), already Soft — no A/B stamp: Soft Design locks the **height-split** below before Nnoitra Phase A full-body **front + back**. A bust ACCEPT is not that lock. The #71 chibi read is not the scale.

---

## Locks this file does not reopen

| Lock | Where |
|---|---|
| Soft chrome **Node A′ · Brief A · Event A** | [37](37-player-facing-chrome.md) #91. Soft QC on that Client stays Ulquiorra’s lane. This card does not hold it and does not release it |
| Soft A′AAAA hand / drag / drop / mat path / placeholder | [36](36-craft-hand-cards.md) #83–#85 |
| Tag chrome **A** | [36](36-craft-hand-cards.md) §6. #87 / #89 |
| Drop clear, cost caption, N=2 as one fight | Client #88 (`e9f503f`) |
| Starter deck **A B C′ D′ E F G · scrap_breath A** | [39](39-starter-deck.md) #93 / #96. Soft QC on that fight stays that card’s bar |
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

The 96 bust of Dame Solenne Ward can be accepted and the body can still be wrong. Bust crop is head and shoulders. Height is the full figure in the 64 cell. Soft will not clear Phase A front + back until this height / body letter is Soft.

`29` and `30` and the #71 commit subjects do not print a head-count. Solenne’s portrait row is face, hair, and mouth (high elf, court braid, clean court plate). `30` locks the posture canvas at 64×64 full figure and says the 96 file is the wrong crop. The Soft letter below is Jonathan’s 2026-10-27 height-split. It is not a KEEP head-count stamp.

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

Crown-to-feet ink on the shop ACCEPT meets Halden’s height and stays narrow (24 against 30–32). Matching the bottom of the cell is not the lock. `0ae24bb` is the short, large-head / chibi read. `d20bbfa` and the shop ACCEPT are not a height stamp. The Soft letter does **not** lock a KEEP head-count bar.

---

## Soft letter — height-split (locked)

Jonathan (2026-10-27). Already Soft. **No A/B stamp.** Soft Design locks this split as the letter. Silence is not a reopen of Height A / B.

1. **Posture arts** follow Halden / Vex **64×64** scale.
2. **Full-body front + back** use real character settings (**cm / kg**), not the KEEP head-count / chibi bar.

Body shape is not a second letter. `29` does not offer Solenne a lean-versus-stocky fork. Her race row is high elf. Her outfit row is clean court plate. The knight silhouette lock is plate and gauntlet for Halden, Vex, and Solenne together. A smaller doll in the cell is the chibi fail. Soft does not invent a stocky letter, a head-count letter, or a cm / kg table Jonathan did not write.

---

## What this stamp locks

- The height-split Soft letter above.
- Posture arts (the five-slot posture path) scale against Halden KEEP `12f50ee` and Vex KEEP `2cb74a4` on the **64×64** canvas.
- Phase A full-body **front + back** drive from real character settings (**cm / kg**), not from a KEEP head-count / chibi bar.
- Chibi shrink fails Soft QC.

## What this stamp leaves open

- Face likeness.
- Hair and outfit chrome.
- Kit details (sword, pauldron, trim).
- Shop art-style ACCEPT. That stays the **in_shop** iterate, after Soft letter PASS, Aizen RELEASE, and after Jonathan stamps front + back, on the new `character_id`. The #71 shop ACCEPT does not carry over.
- The front + back burn itself. This card authorizes the gate. It does not burn.
- The four fight states.
- Any png already on #71.
- A numeric cm / kg table. Jonathan locked the setting class (**cm / kg**), not a Soft-invented number list.

---

## Method (IO4, unchanged)

PixelLab **character-creation** path, the path that produced the KEEP figures. Not Pro Flash freeform.

1. `create_character_pro_flash` at **64×64**, low top-down (the camera on Halden `12f50ee` and Vex `2cb74a4`). Full-body front + back use that path with real character settings (**cm / kg**).
2. Portrait `style_image` = the landed bust `assets/adv/adv_solenne_ward.png`. Same pattern as Halden’s own bust on `12f50ee`. The bust is the style image. It is not the height lock, and it is not a face ACCEPT.
3. `create_character_state` ×5 only after shop ACCEPT, from that same `character_id`. Those posture arts follow Halden / Vex **64×64** scale.

Facing on those later states stays the #71 process: shop, fight, ult, and defend face southeast; attack faces east. This card does not reopen that facing.

---

## Phase order after Soft letter PASS

Ulquiorra, Nnoitra, and Szayelaporro **hold gens** until Soft letter PASS and Aizen RELEASE. Ulquiorra has no Client on this card. Szayelaporro does not smoke a gen. Nnoitra does not burn in this PR.

1. **Jonathan** locked the height-split (2026-10-27). Already Soft. No Height A / B ask.
2. **Soft letter PASS** (this Soft Design amend). The letter locks the height-split. A face-only rewrite fails. An A/B reopen fails.
3. **Aizen RELEASE** (squash-merge Soft #92).
4. On or after **2026-11-02**, Aizen soft-gates **Harribel** if a burn is next.
5. **Nnoitra Phase A is front + back only.** Two full-body frames, front and back, from `create_character_pro_flash` on one `character_id`, using real character settings (**cm / kg**). No `create_character_state`. No `in_shop`. No `in_fight`, `ult`, `defend`, or `attack`.
6. **Soft QC** those two frames: real character settings (**cm / kg**), not KEEP head-count / chibi bar; crown-to-feet reads adult against Halden `12f50ee` and Vex `2cb74a4` in_shop scale on 64×64; chibi shrink fails. Face, hair, and outfit are not this QC.
7. **Jonathan stamps** the front + back.
8. **in_shop only**, character path, same `character_id`, until Jonathan ACCEPTS art style. Posture arts that follow stay on Halden / Vex **64×64** scale.
9. **Then** the four remaining states from that `character_id`.

Do not burn all five while Soft letter PASS / Aizen RELEASE are open or shop style is open. Do not edit the #71 pngs to sneak the burn forward. The reset date does not block this docs stamp. It blocks step 5.

---

## Soft Design PASS

Height-split Soft letter is locked. Height A / B stamp card is dropped. No new Soft letter. Soft Design **PASS**. Aizen squash-merges Soft #92.
