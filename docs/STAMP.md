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

---

# Jonathan stamp — 2026-10-05 (roadmap + adventurers + M1/M2)

## Locked (docs only)

1. **Terminology:** shop / walk-in / appointment / boss-pool people are **adventurers**, not “clients.” **Client** = Godot Client seat / codebase only. Do not mass-rename historical bible docs in this drop — Grimmjow owns deeper bible renames Later.
2. **M1 — Ugly full-experience Client (limited options).** Fully developed ugly Client that ships the **full experience** with limited content: limited adventurer **jobs** + limited **enemy types**. Shop adventurers: **more than one per job/class**. Define **stats / skills / requirement tags** first (Design catalog before Client wire).
3. **Interactive order pack** (text-first, discussed 2026-10-05):
   1. Adventurer stats/skills panel on order
   2. Unlocked syn-target draft (persist unlocks across runs) under that panel
   3. Enemy quest brief + estimate/outcome window (extends Current/Potential; unlocked items shown, `?` if locked)
   4. After-craft battle playback (deterministic from mission resolver) then posture art slots — can follow 1–3
4. Shop systems and events are **not done yet** and remain required for “full experience” under M1. C1 craft path **works** (Jonathan confirmed). Art may stay panels / partial armor fallbacks for M1. Pinned demo seed = optional.
5. **M2 — Steam demo.** Ugly UI replaced / handled. Adventurer (and related Client) arts mostly done. Remaining: stat/event tuning + art gen fill. **Not** shipping the full game this month. PixelLab / Cursor budget treated as **fine** for this plan (Harribel watches burn).
6. **Sequence after merge:** Grimmjow Design (limited M1 job set + multi-adventurer-per-job catalog + interactive-order slices 1–3) → Ulquiorra Client PRs after those stamps → Szayelaporro Godot re-smoke each Client land → slice 4 art when Jonathan opens that lane for M1 or defers to M2.

## Files in this drop

| File | Action |
|---|---|
| `docs/pm/phase-1-plan.md` | **Rewrite** — current 2026-10-05 roadmap (supersedes 2026-09-28 Cursor-reset / Phase-0–1C framing) |
| `docs/STAMP.md` | This note |
| `docs/README.md` · `00-doc-categories.md` | Index / findability for the live PM roadmap |
| `docs/03-clients-and-adventure.md` · `28-boss-client-pool.md` | One-line terminology pointers only |

## Supersedes

- 2026-09-28 PM framing: hold Client until Cursor monthly reset; Phase-1A/1B/1C as the live plan
- Calling shop / walk-in / appointment / boss-pool people “clients”
- “0 PixelLab from Client” / “no Cursor add-on until monthly reset” as the live spend envelope

---

# Grimmjow stamp — 2026-10-05 (M1 adventurer catalog + interactive-order 1–3)

## Locked (docs only)

1. **M1 people:** 4 jobs (Knight, Mage, Blade Dancer, Lagoon) × 3 named `adv_*` = 12. Other `28` jobs = Later / M2. Job-stubs (`adv_knight`, …) stay as aliases.
2. **Stats** = existing `HP / ATK / DEF / RES / MOB / PRE` (knobs). Exactly one `ask_*` per person (**new** prefix; not `sk_*`).
3. **Draw:** boss beat still `28` (independent of boss). M1 pool = 4 jobs, then one of that job’s 3.
4. **Unlock (slice 2):** key = outlook + tier, not item / `con_*`. Apex also unlocks lower tiers of that outlook. Counts on piece **Finish** with threshold met. Abandon does not count. Order win/lose does not matter. **Meta / profile** `unlocked_builds: {outlook_id, tier}[]` — **LOCKED cross-run** (Jonathan confirmed 2026-10-05); never resets on death. Fresh profile empty → planner is `?`.
5. Slices 1–3 text-first, ugly-Client, no art. Slice 4 Later (one paragraph).

## Files in this drop

| File | Action |
|---|---|
| `docs/29-adventurer-catalog.md` | **Add** — 12 people, draw, harness |
| `docs/30-interactive-order.md` | **Add** — slices 1–3 + unlock save |
| `docs/28-boss-client-pool.md` | Pointer to `29` |
| `docs/README.md` · `00-doc-categories.md` · `10-catalog-overview.md` | Index + `ask_*` |
| `docs/STAMP.md` | This note |

---

# Grimmjow stamp — 2026-10-05 (Dex + cross-run lock)

## Locked (docs only)

1. **Cross-run unlock LOCKED** (Jonathan confirmed). `unlocked_builds` is a profile / meta save. Never resets on run end or death. Removed from open questions.
2. **Dex** — same save layer. Tabs: **Builds** (reads `unlocked_builds`, no duplicate), **Crafts** (`dex_crafts`: first `con_*` × outlook-tier Finish + run/day), **Adventurers** (`dex_adventurers`: met = order received; `orders_completed` on Finish), **Enemies** (`dex_enemies`: brief/newspaper = seen; boss beat = fought; favor/punish only once fought). Fresh profile = all `?`.
3. Slice 2 / 3 `?` rules **read the Dex**. Ugly list/grid from shop/menu. Art + lore = Later / M2.

## Files in this drop

| File | Action |
|---|---|
| `docs/31-dex.md` | **Add** — Dex spec |
| `docs/30-interactive-order.md` | Cross-run LOCKED; `?` gates → Dex |
| `docs/README.md` · `00-doc-categories.md` · `10` · `04` · `29` · `pm/phase-1-plan.md` | Index / pointers |
| `docs/STAMP.md` | This note |

---

# Jonathan stamp — 2026-10-08 (M1 4-job draw + estimate bands as knobs)

## Locked (docs only)

1. **M1 boss-draw pool = 4 jobs only** (Jonathan 2026-10-08). Knight, Mage, Blade Dancer, Lagoon. Do **not** draw Wizard / Hexer / Outrider / Oathbound in M1. Those four stay Later/M2 until their adventurer catalog exists. Closes PR #28 open question 1 (restrict to 4 vs 8-job draw + job-stub fallback).
2. **Estimate S–F letter bands stay Test knobs.** Do **not** lock the cutoff table for the first Client wire. Working cutoffs (tunable): ≥10=S, ≥7=A, ≥4=B, ≥1=C, ≥−2=D, else F. **LOCKED** decision is **leave as knobs**. Closes PR #28 open question 2.

Both items **removed from open questions**. Client can proceed on Ulquiorra PR 1.

## Files in this drop

| File | Action |
|---|---|
| `docs/28-boss-client-pool.md` | M1 draw filters to 4 jobs (`M1_JOB_POOL`); Later jobs out of draw |
| `docs/29-adventurer-catalog.md` | Draw lock stamp; no stub-fallback |
| `docs/30-interactive-order.md` | S–F cutoff table = Test knobs; leave-as-knobs LOCKED |
| `docs/17-chapter-bosses.md` · `22` · `20` · `27` · `03` · `01` | Draw-rule pointers |
| `docs/pm/phase-1-plan.md` · `docs/README.md` | Client-can-proceed / stamp pointer |
| `docs/STAMP.md` | This note |

## Supersedes

- PR #28 open questions (2) — both closed
- `28` / `17` Phase-1 draw from the full 8-job `SHARED_BOSS_CLIENT_POOL`
