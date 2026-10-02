# Jonathan stamp — 2026-09-28 (Chaos Atelier)

## Locked

1. **Travelling atelier** (wagon/horse-car) + **schedule board** (not path map).
2. **3 chapter bosses** kept; **`CHAPTER_ROUND_COUNT = 8`** (band 6–10).
3. **Appointments** on future rounds (elite telegraph).
4. **Craft mode** = stamina hand game; construction **from order** (multi-piece OK).
5. Hand = **materials + enchantments + owner skills** only (no construction cards).
6. Hand **does not auto-refill**; stamina refresh digs inventory.
7. Craft ends on **stamina empty** or **early finish**.
8. **Infinite monostack** allowed; gated by stamina/skills/refresh.
9. Synergies + outlook art kept; thresholds **retuned** (3 / 5 / apex 8 for Fire·Metal·Earth).

## Files in this drop

| File | Action |
|---|---|
| `docs/22-chapter-schedule.md` | **Add** (canonical `22` — schedule only) |
| `docs/27-craft-mode-stamina.md` | **Add** (renamed from provisional `23-craft-mode-stamina.md`; `23` stays mission-report) |
| `docs/14-synergies-RETUNE.md` | Stamp source; **merged** into `docs/14-synergies.md` (replace thresholds) |
| Update README / `00-doc-categories` / `01` / `02` / `21` / `12` / `20` | Point at new spine; mark 2m1r / node clock / construction picker / 1-of-3 **superseded** |
| `docs/22-chapter-flow.md` | Kept as history; **superseded** by schedule |

## Blocked

Cursor cloud agent launch refused: **Cursor usage exhausted** (on-demand required). Docs written locally for manual apply or relaunch after on-demand / monthly reset.

## Supersedes

- `CHAPTER_NODE_BUDGET=3` shop↔craft clock
- Construction picker in craft UI
- Default 2m1r as hard craft shape
- PR #7 chapter shell assumptions (appointments/schedule replace card lineup)
- Doc-id collision: provisional craft `23` → `27` so `23-mission-report` stays stable

---

# Jonathan stamp — 2026-09-29 (synergy tier extension)

## Locked (docs only)

1. **Most positive monostack tags** use **≥3 / ≥5 / ≥8** (extend beyond Fire·Metal·Earth).
2. **Frost:** `syn_frost_5` mid + `syn_frost_8` apex; mid art `look_armor_frost_3` → `frost_5`; apex art Later.
3. **Royal stamped armor = APEX** (`look_armor_royal` → `royal_8` / `syn_royal_8`), not low.
4. **Silent / silk:** mid + apex syn rows added; art Later (stamped unnumbered assets map to low `_3` for now).
5. **Cross-tags:** ≥1∧≥1 power + single outlook; no monostack tiers — reviewed in `14`.
6. Docs only — no PixelLab, no game code this pass.

## Files in this drop

| File | Action |
|---|---|
| `docs/14-synergies.md` | Tier table + frost mid/apex + royal apex lock + cross-tag review |
| `docs/14-synergies-RETUNE.md` | Append 2026-09-29 extension note |
| `docs/15-outlook-gen-list.md` | Replace stale 10-id list; remap legacy filenames; art gaps |
| `docs/STAMP.md` | This note |

## Art gaps (armor) — superseded evening

Morning gaps for frost/silent/silk/royal mid+apex are **closed** by the stamped pack (see evening stamp below). Remaining: cross-tag + neg outlooks; other-owner-pool tags.

---

# Jonathan stamp — 2026-09-29 evening (armor pack complete + owner pool)

## Locked

1. **Armor image lineup DONE** for traveler / atelier default: stamped pack covers plain + metal/earth/fire/frost ladders + silent/silk/royal ladders + freestanding frost apex. **Do not** plan more monostack armor gens for storm / lunar / solar / sticky / sharp / soft / wild / occult / pure.
2. **Tomorrow focus:** cross-tag positive syn + negative syn (art/docs as needed).
3. **Other syn lines** (lunar, solar, storm, sticky, sharp, soft, wild, occult, pure, …) → **other shop owner pool** — not traveler/atelier default armor outlooks. Power rows stay in `14`; armor outlook gen parks under other owners ([15](15-outlook-gen-list.md)).
4. **Stamped filenames:** silent/silk/royal use `_3` / `_5` / `_8`; metal/earth/fire/frost low+mid still legacy `*_2` / mid `*_3`; all apex `*_8` including frost. `04-syn/` may only have `look_armor_royal` alias (or empty).

## Files in this drop

| File | Action |
|---|---|
| `docs/14-synergies.md` | Locks + open: armor DONE, other-owner pool, next = cross-tag/neg |
| `docs/14-synergies-RETUNE.md` | Note frost apex stamped; evening sync appendix |
| `docs/15-outlook-gen-list.md` | Reflect stamped `_3`/`_5`/`_8`; complete default armor table; other-owner pool; next = cross/neg |
| `docs/STAMP.md` | This note |
| `armor-stamped-2026-09-29/` | Local stamped pack (untracked or local-only unless added) |

## Next

- Cross-tag positive + negative syn art/docs
- Other shop owner armor outlooks when that shop work starts

---

# Jonathan stamp — 2026-10-02 (stamina 0 ≠ finish + boss-client)

## Locked (docs only)

1. **Stamina 0 ≠ finish.** Piece **stays open**. Cards do **not** disappear / auto-resolve. Only **Finish** crafts and runs the resolver.
2. **Supersedes** `27` / `20` auto-finish on `stamina_0` / `finish_reason: stamina_0` as the craft-end trigger. If `stamina_0` remains, it is a **session state flag** (`stamina_remaining == 0`) — **not** auto-craft.
3. Phase-1 `finish_reason` = **`player_finish`** (Finish button only). `early_finish` is not a second path.
4. StS cycle (play→discard, dig dump, reshuffle) + Current/Potential readout **unchanged**.
5. **0-cost cards** and further owner abilities at 0 stamina = **Later**. Do not invent catalog.
6. **Boss-client:** a client is responsible for the boss event. Player crafts **for that client**; the **client fights** the boss. Sim uses that client's gear. Roster / UI widgets Later.

## Files in this drop

| File | Action |
|---|---|
| `docs/27-craft-mode-stamina.md` | Stamina 0 ≠ finish; Finish-only; supersedes auto-finish |
| `docs/20-harness-stamp.md` | `finish_reason: player_finish`; assert 14; boss-client mission lock |
| `docs/17-chapter-bosses.md` | Boss-client Design lock |
| `docs/22-chapter-schedule.md` | Boss beat = craft for boss-client |
| `docs/03-clients-and-adventure.md` | Pointer |
| `docs/01-core-loop.md` | Boss beat: craft for boss-client |
| `docs/STAMP.md` | This note |

## Supersedes

- Craft ends on stamina empty or early finish (`STAMP` 2026-09-28 §7)
- `finish_reason: stamina_0` as auto-craft / resolver trigger
- Player-as-fighter reading of the chapter boss beat

---

# Jonathan stamp — 2026-10-02 (cross-tag positive armor)

`armor-cross-tag-locked-2026-10-02/` — locked Storm / Beastbloom / Snaretooth / Masked Crown / Dawn Vestment / Pale Hex (`_3` / `_5` / `_8`).

---

# Jonathan stamp — 2026-10-02 (multi-piece craft UI)

## Locked (docs only)

1. Multi-item order → craft **all pieces in one session** with **higher initial stamina**. **Supersedes** sequential per-piece stamina pools (piece N then N+1 sessions).
2. **Dedicated craft UI** (not schedule): **lower** = hand + actions (cards display here); **upper left** = client order detail; **upper right** = up to **4** drop zones (unused if N < 4).
3. **Input:** drag into a zone when N > 1; **1–5** = hand slots; **D** = dig (StS dig still applies). Play **must** target a zone.
4. Keep: StS play→discard / dig dump / reshuffle; Finish-only (stamina 0 ≠ finish); Current/Potential for the **selected zone**.
5. **Draft knobs** (Jonathan may retune): stamina start **`12 * N`**; dig cost **2**; max zones **4**; N > 4 = Later / split. One Finish → resolve listed pieces in order (N stamps, one session). Empty zone at Finish = existing empty-piece path — hold if undefined; do not invent a harsh fail.

## Files in this drop

| File | Action |
|---|---|
| `docs/27-craft-mode-stamina.md` | Dedicated UI + parallel multi-piece; supersedes sequential |
| `docs/20-harness-stamp.md` | `zone_count`; `stamina_start = 12 * N`; `cards_played` zone/piece id; Finish = session end |
| `docs/12-constructions.md` | One construction per **piece**; parallel session pointer |
| `docs/22-chapter-schedule.md` | Enter craft **once** per order |
| `docs/STAMP.md` | This note |

## Supersedes

- Phase-1 sequential multi-piece (`27` old: own stamina pool per piece; resolve N before starting N+1)
- `20` old: multi-piece = N sessions; `stamina_start == 12` per piece; `cards_played` without zone target

---

# Jonathan stamp — 2026-10-02 (shared boss-client pool + chapter boss rewrite)

## Locked (docs only)

1. **Boss pool stays** — 3 bosses × 3 chapters → 27 paths. One boss drawn per chapter, announced via newspaper (`17`, `26`).
2. **Shared adventurer / boss-client pool** — **not** a fixed client per boss. One pool for all bosses / chapters, organized by **job title**. Catalog: `28`.
3. At the **boss beat**, seeded draw from that pool — **independent** of which boss was announced. That adventurer’s **order constructions** (`con_*`) + requirement tags are the craft brief; that adventurer **fights** the announced boss.
4. Every job lists **order constructions** with concrete `con_*` from `12` (e.g. knight → `con_armor` + `con_gloves` / gauntlet). Multi-piece ≤4. Requirement tags stay.
5. **Rewrite C1–C3 bosses** as big chapter threats (ids kept). **C2 / C3 de-favor** `own_basic` starter tags (Soft, Earth, Metal, Wild, Silk, Pure). C1 may still be approachable on those staples.
6. Scrap Duelist / mid-chapter appointments stay **`appt_*`**. They are **not** the boss-client. Do not pin Scrap Duelist to reserved rounds or the boss beat.
7. Harness: `boss_client_id` (`adv_*`), `boss_job_id` (`job_*`), `order_id` / `construction_ids` from the pool. Finish-only / multi-piece / StS craft **unchanged**.
8. Portraits / UI / Client / Godot = **Later**. Docs only.

## Files in this drop

| File | Action |
|---|---|
| `docs/28-boss-client-pool.md` | **Add** — shared pool law, 8 jobs, per-job order constructions |
| `docs/17-chapter-bosses.md` | Rewrite threats; replace roster-Later with shared pool + starter-tag law |
| `docs/03-clients-and-adventure.md` | Pointer to `28` |
| `docs/22-chapter-schedule.md` | Boss beat = shared-pool draw + order constructions; appointments ≠ boss-client |
| `docs/20-harness-stamp.md` | `boss_client_id` / `boss_job_id` / order-from-pool |
| `docs/19-own-basic-starter.md` | One-liner: C2/C3 de-favor starter tags |
| `docs/01-core-loop.md` · `27` · `26` · `10` | Pointers |
| `docs/README.md` · `00-doc-categories.md` | Index `28` |
| `docs/STAMP.md` | This note |

## Supersedes

- Boss-client **roster Later / do not invent catalog** (`17` / `20` / `22` / `STAMP` 2026-10-02 morning)
- Fixed-client-per-boss reading of the boss beat
- Scrap Duelist (or any appointment) as the boss-client
