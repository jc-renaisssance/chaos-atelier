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

---

# Jonathan stamp — 2026-10-12 (Day planner + drop `crafts_max`) — Aizen locked

## Locked (docs only)

1. **Remove `crafts_max` / piece cap entirely.** Unlimited pieces per chapter. Stamina per craft session **stays**. `cant_craft` because `crafts_done == crafts_max` is **GONE**. Mid-fail from other session-open causes may stay.
2. **Schedule → Day planner.** Round → **Day** (R1 → **D1**). At chapter start the player **previews all possible options per day** (expand / popup), then **assigns** the chapter. Planner **can be updated mid-chapter**. Some events have **fixed windows** (cannot move).
3. **Day count is a map setting** — `CHAPTER_DAY_COUNT` / `map.day_count`. Current map = **8**. Later maps may be **3** or **12**. Do **not** hardcode 8 as global law.
4. **Last 2 days reserved** relative to map length (8-day map: **D7** travel / final prep, **D8** boss approach). Player assigns **D1..(N−2)** only. Fixed-window events may still pin inside assignable days.
5. **Event pool `E*`.** Keep `adv_*` / `appt_*` on the row when they exist. Windows e.g. E1 shop D2; E2 adv D2; E3 event D2–D3; E4 adv D2 & D6. M1 / current test: **2–4 options per day**. D1 may only list first-customer adventurer option(s). **Scrap Duelist / `appt_*` stay appointments**, not Dex Adventurers.
6. Client needs + Test logs sketched in `22` / `20` (no piece cap; Day labels; options panel; assign at start; mid-chapter update; fixed windows; reserved last-2).
7. **M1 `E*` panel = type + id** (Jonathan 2026-10-12). Type ∈ {shop, adventurer, appointment, event}. Fancy titles **Later**. Do not invent title copy. Display-title lock **held** — closed.

## Files in this drop

| File | Action |
|---|---|
| `docs/22-chapter-schedule.md` | **Rewrite** — Day planner (filename kept; Round board superseded) |
| `docs/20-harness-stamp.md` | Drop `crafts_max`; `day_*` / `CHAPTER_DAY_COUNT`; event pool / assignments |
| `docs/24-win-conditions.md` · `27-craft-mode-stamina.md` | No piece cap; cant_craft-at-max GONE |
| `docs/01-core-loop.md` · `03` · `21` · `22-chapter-flow` | Day planner pointers; 1-of-3 / Round board superseded |
| `docs/25-reps-meter.md` · `17` · `28` · `29` · `31` | Days not rounds; `appt_*` not Dex |
| `docs/README.md` · `00-doc-categories.md` · `pm/phase-1-plan.md` · `STAMP.md` | Indexes |
| `docs/02` · `10` · `11` | Day-generated consumables; `E*` id |

## Supersedes

- Round / schedule board as live UX (`CHAPTER_ROUND_COUNT=8` as **global** law, R1..R8) — `STAMP` 2026-09-28 §1–2
- `crafts_max=4` garments / chapter; `cant_craft` at cap — `20` / `22` / `24`
- Chapter-start 2–4 appointment pins as the only assign UX

---

# Jonathan stamp — 2026-10-13 (route map with forks — sample C1)

## Locked (docs only)

1. **Supersede** the free per-day `E*` options board from Design [#36](https://github.com/jc-renaisssance/chaos-atelier/pull/36) / Client [#37](https://github.com/jc-renaisssance/chaos-atelier/pull/37). No more “every windowed event whose day includes today” / assign all of D1..(N−2) from that list.
2. **Hand-authored route map with forks** (StS-like, **not** seed-generated sprawl). Combos = **bound multi-day blocks** on the graph. One-combo vs stack = **corridor + forks** (path through overlapping choices), not stacked arbitrary combos.
3. **M1:** one concrete map for current wagon `day_count` = **8**. Last 2 reserved: D7 travel / final prep, D8 boss approach. D1 = fixed first-customer adventurer. Sample graph + paths in `22`.
4. At forks: player chooses among **2–4 visible next options** (not an identical list under every day). Bound days = **no** free options panel. Unbound days = limited free picks from that day’s remaining outgoing options. **No choice → no panel.**
5. Shop visits **1–3** come from **graph design** (reachable shop nodes on a complete path), not a hard UI ban on picking shop. C1 sample complete paths: **2 / 1 / 1** shops.
6. Appointment = **StS-elite analog**. Scrap Duelist / `appt_*` stay appointments, not Dex Adventurers.
7. **M1 panel = type + id** (`shop · N2`). Fancy titles **Later**. Dump `phase=schedule` kept.
8. Product display name **Wombaste** (repo `chaos-atelier`).
9. Piece cap stays **GONE**. `map.day_count` stays a map setting. Boss-client draw unchanged (`28` / `29`).

## Files in this drop

| File | Action |
|---|---|
| `docs/22-chapter-schedule.md` | **Rewrite** — route-map law + C1 sample graph (filename kept; free `E*` board superseded) |
| `docs/20-harness-stamp.md` | `route_nodes` / `route_edges` / `route_path` / `fork_options`; drop live `event_pool` windows |
| `docs/01-core-loop.md` · `03` | Route-map pointers |
| `docs/README.md` · `00-vision.md` · `00-doc-categories.md` | Display name **Wombaste**; `22` = route map |
| `docs/21-app-flow.md` · `22-chapter-flow.md` · `10` · `24` · `25` · `27` · `28` · `31` · `17` · `pm/phase-1-plan.md` | Pointers: live spine is the route map |
| `docs/STAMP.md` | This note |

## Open questions (Jonathan) — ≤2

1. After leaving a fork, may the player **re-route unbound future days**, or is the next pick only when that day is current?
2. Does appointment-elite get a distinct ahead-of-time marker (StS elite telegraph), or is M1 type + id in the graph enough?

## Supersedes

- Free per-day `E*` options board (`STAMP` 2026-10-12 §2, §5–7) — windows, 2–4 options every assignable day, chapter-start assign from that pool
- “Not a path map” as live law (`STAMP` 2026-09-28 §1; Day planner 2026-10-12)
- Chaos Atelier as live **display name** (`00-vision` temporary lock) — product is **Wombaste**

---

# Jonathan stamp — 2026-10-13 (draft-only future + graph board)

Follow-up on the route-map stamp (same day). Docs only. Same PR.

## Locked

1. **Future unbound days are draft only.** Player may preview / draft a legal remaining path. The **real pick is confirmed when that day is current.** Past and current / entered **bound blocks stay frozen.** Closes open question 1 (re-route vs pick-when-current).
2. **M1 Client = simple route-graph layout** (nodes + edges, ugly) so later art / UI can plug in. **Not** a day strip. **Graph board now, art Later (Nnoitra).**
3. Elite telegraph stays **open**. M1 default = type + id on the graph (no distinct StS-elite marker this stamp).

## Files

| File | Action |
|---|---|
| `docs/22-chapter-schedule.md` | Draft-future law; graph-board Client need; OQ1 closed |
| `docs/20-harness-stamp.md` | Optional `draft_path`; confirm ≠ draft |
| `docs/01-core-loop.md` | Draft-only + graph board pointer |
| `docs/STAMP.md` | This note |

---

# Grimmjow stamp — 2026-10-13 (shop visit + event resolve M1)

Docs only. Ready for **Jonathan to stamp**. Ulquiorra **holds**. Szayelaporro after the shop/event Client PR. Elite telegraph N5 and adventurer catalog stay parked. Material icons stay Nnoitra 1:1.

## Locked (docs only — Grimmjow intent)

1. **Enter shop** only from current route node `kind=shop`. No auto opening-shop (`21` shell is historical).
2. **M1 actions = Buy + Sell only.** Reshape = **Later**.
3. **Stock** = authored 4–6 `mat_*` from `11` per shop node on `map_m1` (N2, N7, N12, N15, N16). Rotate by travel fiction, not a live ban.
4. **Buy:** pay `$` from `11`; add one copy to the run deck (`WagonStock` / `27`). **Sell:** ⌊$ / 2⌋ min 1; soft floor **≥ 3** material cards after sell.
5. **Exit** with no buy is legal. Day resolves like other primary actions.
6. Shop visits **1–3** stay **graph law** (`22`). Client must **not** grey-out shop picks.
7. **Enter event** from current `kind=event`. M1 = text resolve. Catalog `evt_*` with `ref_id` on C1 nodes N4 / N6 / N10 / N17. Outcomes: ±gold / ±1 mat / small reps. No craft. No run-kill.
8. **One gold purse** (start 12 from `19` — Test knob). Ugly UI only. Dump keys in `20` / `32`.
9. **Later:** shop owners (`16`), forbidden rooms, reshape, unique stock UI, PixelLab icons (Nnoitra parallel), event art / trees.

## Files in this drop

| File | Action |
|---|---|
| `docs/32-shop-and-events.md` | **Add** — canonical shop-visit + event-resolve M1 |
| `docs/22-chapter-schedule.md` | Shop/event “what it does” → `32`; C1 `evt_*` refs; Client need 14 |
| `docs/20-harness-stamp.md` | Shop / event / gold dump keys + asserts 24–26 |
| `docs/01-core-loop.md` · `21-app-flow.md` · `24-win-conditions.md` | Pointers; `21` opening-shop = historical |
| `docs/11-materials.md` · `25-reps-meter.md` · `10` · `19` · `16` · `03` · `04` · `27` | Shop / event / deck pointers |
| `docs/README.md` · `00-doc-categories.md` · `pm/phase-1-plan.md` | Index `32`; PM = Design in this PR, Ulquiorra holds |
| `docs/STAMP.md` | This note |

## Supersedes

- “Shop systems and events are not done yet” as the live hole (`STAMP` / PM 2026-10-05) — Design now in `32` (Jonathan stamp pending; Client still holds)
- Auto opening-shop / last-shop-before-boss as live M1 (`21` shell)
- Weighted roll-5 atelier shop (`19`) as the live route-node visit
- Sell-back “$1 scraps → 0 gold” (`19`) — M1 sell is ⌊$ / 2⌋ min 1
- Old `22-chapter-flow` event-pool outcomes as live law (ids may be reused)

## Open questions (Jonathan)

None this pass. Sell rate, shared gold, and C1 stock / `evt_*` rows are M1 defaults / Test knobs.
