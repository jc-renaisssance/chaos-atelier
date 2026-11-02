# M1 + M2 adventurer catalog

**Status:** M1 roster mechanics **unchanged** (2026-10-05 / 2026-10-08). M2 roster mechanics **stamped** (Jonathan 2026-10-21, #61): Wizard, Hexer, Outrider, Oathbound × 3 = **12** named `adv_*`. Character identity, backgrounds, and Public display names were expanded 2026-11-02 without changing ids, jobs, stats, skills, or constructions. Two **disjoint** 4-job draws. `M1_JOB_POOL` = Knight, Mage, Blade Dancer, Lagoon. `M2_JOB_POOL` = Wizard, Hexer, Outrider, Oathbound only (**draw B**). Text-first UI stays legal until a portrait file exists. Docs only — no `src/` / Godot / art gens. **M1 market is closed** ([32](32-shop-and-events.md)); this file does not reopen it. Portrait uniqueness on all **24** (Race / Visual / Outfit / Character / Hook) is **stamped** (Jonathan ACCEPT on #63). M1 redraws landed (#64). M2 redraws landed (#65) and replace the held #62 outlook. Do not regen. Do not revive #62. Elite telegraph is [22](22-chapter-schedule.md), not this catalog.

**Doc id: `29`.** Grimmjow 2026-10-05; M2 people 2026-10-21; portrait uniqueness 2026-10-21 (ACCEPT all 24 on #63; art #64 / #65); identity and background pass 2026-11-02. Interactive-order slices 1–3: **[30-interactive-order](30-interactive-order.md)**. Jobs / constructions: **[28-boss-client-pool](28-boss-client-pool.md)**.

**Terminology:** UI / prose says **adventurer**. **Client** = Godot Client seat / codebase. Internal ids stay (`boss_client_id`, `con_*`, `appt_*`, `adv_*`, `ord_*`, `job_*`) so saves and Test smokes do not churn. Do not mass-rename existing ids. Scrap Duelist stays `appt_*`.

---

## M1 cut

| Lock | Value |
|---|---|
| Jobs in M1 draw | **LOCKED (Jonathan 2026-10-08) — 4 only:** Knight, Mage, Blade Dancer, Lagoon. Closes PR #28 open question 1 |
| Adventurers / job | **3** (more than one per job — PM lock) |
| M1 roster | **12** named `adv_*` — **unchanged** this stamp |
| M2 roster | **12** more named `adv_*` (Wizard, Hexer, Outrider, Oathbound × 3). In `M2_JOB_POOL` only. Still **out of `M1_JOB_POOL`** |
| Constructions | Job-fixed from `28` — do not invent `con_*` |
| Target enemies | Existing `boss_*` from `17` (limited enemy types = the 9 chapter bosses) |
| Appointments | Not this catalog. Scrap Duelist stays `appt_scrap_duelist` |

Numbers in this doc (stats, estimate weights in `30`) are **test knobs**, not a hard lock. Jonathan may retune. **S–F estimate letter bands** in `30` stay Test knobs — **LOCKED leave-as-knobs** (Jonathan 2026-10-08); do not lock the cutoff table. [33](33-until-m2-tuning.md) accepts the six-stat cells (and the HP 8–16 / other 1–8 band) as the **until-M2** lock (Design #72 / Client #73). No cell in this file changes. Estimate weights and the S–F table stay knobs.

---

## IDs

Reuse existing prefixes. **New prefix (none existed for adventurer battle skills):** `ask_*` = one combat / estimate skill on an adventurer. Distinct from `sk_*` owner **craft** skills (`27`).

| Prefix | Role | Status |
|---|---|---|
| `job_*` | Job title | Reuse `28` |
| `adv_*` | Named adventurer; live `boss_client_id` | M1 12 + M2 12 below; job-stubs `adv_knight` / `adv_mage` / `adv_wizard` / … from `28` stay as **job-default aliases** (not people) |
| `ord_*` | Order id | Reuse job-level `ord_*` from `28`, including `ord_wizard` / `ord_hexer` / `ord_outrider` / `ord_oathbound` — constructions are identical per job |
| `con_*` | Order constructions | Reuse `28` / `12` |
| `boss_*` | Target enemy / brief | Reuse `17` |
| `appt_*` | Mid-chapter appointments | Unchanged; never `boss_client_id` |
| `ask_*` | Adventurer skill | **New** — say so here and in [10](10-catalog-overview.md) |
| `sk_*` | Owner craft skill | Unchanged; not this catalog |

No new harness **person** field. `boss_client_id` = the drawn named `adv_*`. `boss_job_id` = that job. `construction_ids` = that job’s list from `28`.

---

## Draw

**Boss beat stays `28`:** seeded, **independent** of `chapter_boss_id`. Player is the clothier; the drawn adventurer fights the announced boss.

`28` still lists every job’s constructions. The **draw** is never that whole list. Two pools, both **4 jobs**, **disjoint**. Do not merge them.

| Pool | Jobs | When it applies |
|---|---|---|
| `M1_JOB_POOL` | Knight, Mage, Blade Dancer, Lagoon (**4**) | **M1 content and historical / regression smokes.** LOCKED (Jonathan 2026-10-08). Unchanged |
| `M2_JOB_POOL` | Wizard, Hexer, Outrider, Oathbound (**4**) | **M2 / Steam-demo** boss beat **and** shop walk-in on M2 content. Alias: `STEAM_DEMO_JOB_POOL` = `M2_JOB_POOL`. **LOCKED draw B** (Jonathan 2026-10-21) |

Knight, Mage, Blade Dancer, and Lagoon are not in `M2_JOB_POOL`. Wizard, Hexer, Outrider, and Oathbound are not in `M1_JOB_POOL`.

### M1 — `M1_JOB_POOL` (LOCKED)

**LOCKED (Jonathan 2026-10-08):** M1 pool = **those 4 jobs**, then one of that job’s 3 named people. Wizard / Hexer / Outrider / Oathbound are **not** drawn in M1.

```
function pick_boss_client(seed):
  job = seeded_choice(M1_JOB_POOL, seed)
  # M1_JOB_POOL = job_knight, job_mage, job_blade_dancer, job_lagoon
  # NOT: job_wizard, job_hexer, job_outrider, job_oathbound
  # do not pass chapter_boss_id
  return seeded_choice(ADVENTURERS_BY_JOB[job], seed)
```

| Rule | M1 |
|---|---|
| When | Boss beat (after reserved last-2 **days** / final prep) — not chapter-start newspaper |
| What | One `job_*` from the **4-job M1 pool** → one named `adv_*` from that job’s **3** |
| Vs boss | Independent of `chapter_boss_id` |
| Order constructions | Still the **job** list from `28` (not per-person `con_*`) |
| Requirement tags | **Per adventurer** (this catalog) — not the job-row taste in `28` |
| `threat_id` on boss beat | Announced `chapter_boss_id` (`17`, `20`) — catalog `target_threat_id` is the **shop / brief** default, overridden here |
| Repeat | Same job or person may recur (Phase-1) |
| Unique-per-run | Later |
| Shop / walk-in | Draw from the same 12 (or from a job’s 3 when a job is offered). Same constructions + that person’s tags + that person’s `target_threat_id` |
| Wizard / Hexer / Outrider / Oathbound | **Not** in `M1_JOB_POOL` (**LOCKED**). Their named people exist for `M2_JOB_POOL`. Do not draw them on an M1 smoke. Do not stub-fallback |

### M2 / Steam demo — `M2_JOB_POOL`

Does **not** rewrite the M1 function above. M1 regression still calls `pick_boss_client(seed)` and stays on its own 4 jobs. This pool does not include them.

```
M2_JOB_POOL = job_wizard, job_hexer, job_outrider, job_oathbound
# STEAM_DEMO_JOB_POOL = M2_JOB_POOL
# LOCKED Jonathan 2026-10-21 — draw B. Disjoint from M1_JOB_POOL.
# NOT: job_knight, job_mage, job_blade_dancer, job_lagoon
# NOT a merged draw of every job in 28. NOT Scrap Duelist. NOT a stub as a person.

function pick_boss_client_m2(seed):
  job = seeded_choice(M2_JOB_POOL, seed)
  # do not pass chapter_boss_id
  # 3 named people for that M2 job only
  return seeded_choice(ADVENTURERS_BY_JOB[job], seed)
```

| Rule | M2 / Steam demo |
|---|---|
| When | Boss beat (same beat as M1 — after reserved last-2 **days**) **and** shop / walk-in, when the content is M2 / Steam demo |
| What | One `job_*` from these **4** → one named `adv_*` from that job’s **3** |
| Vs boss | Independent of `chapter_boss_id` |
| Order constructions | Still the **job** list from `28` |
| Requirement tags | **Per adventurer** in this catalog |
| `threat_id` on boss beat | Announced `chapter_boss_id` — catalog `target_threat_id` is the shop / brief default |
| Shop / walk-in | The **12** M2 named people (or a job’s 3 when a job is offered). Not the M1 12 |
| M1 smokes | Keep calling `M1_JOB_POOL`. A Steam-demo seed is not an M1 regression seed |

---

## Stats (test knobs)

Adventurer **base** stats use the existing six-stat set from [10](10-catalog-overview.md) / constructions (`12`) / harness `stats` (`20`). Not a new SPD axis.

| Stat | Code | Meaning |
|---|---|---|
| Hit Points soak | `HP` | Punishment before ruin |
| Attack aid | `ATK` | Offensive checks / damage aid % |
| Defense | `DEF` | Physical soak |
| Resist | `RES` | Elemental / magic / weather |
| Mobility | `MOB` | Escape / footing |
| Presence | `PRE` | Social / royal |

Scale (knob, not lock): **HP 8–16**, other stats **1–8**. Gear from the order (`12` + mats + runes) **adds** on top in the sim / estimate (`30`). These rows are the person, not the garment.

Exactly **one** `ask_*` per adventurer. Skill text is the battle / estimate hook Client implements in ugly UI — not a craft-hand `sk_*`.

---

## Character identity and reveal

The roster uses three player-facing name layers. Internal `adv_*` ids do not change.

| Layer | Use |
|---|---|
| **True name** | Birth name, legal name, order name, or construct designation. It may be unknown at first and is shown only when the fiction has earned it |
| **Public name** | The short, memorable name used on order cards, combat UI, reports, and ordinary dialogue |
| **Epithet** | Optional reputation text used for introductions, newspaper headlines, mastery results, or relationship moments. It is not appended to every UI label |

Only four people use a true middle or lineage name: **Halden Baruk Rook**, **Solenne Aurelia Ward**, **Kitarian Sableclaw Thornreel**, and **Pell Severin White**. Those names communicate clan or noble history. Everyone else stays shorter, uses an order-name, or has a construct designation.

### Presentation law

1. **First meeting:** show portrait, Public name, job, one-line Hook, and the immediate garment ask. Do not front-load biography.
2. **During the order:** reveal personality through requirement wording, inspection comments, and one reactive bark when a favored or refused trait enters the plan.
3. **Result:** show an epithet only when the outcome supports it. A successful signature build may earn the epithet as a Dex title; an ordinary result keeps the Public name.
4. **Trust or story reveal:** add the True name and one short background paragraph to the Dex. Secretive people and constructs reveal theirs through a specific event, not an automatic affinity level.
5. **Later encounters:** change one or two barks after the reveal. Do not replay the biography.

`Display` below is the intended **Public name**. Existing ids, jobs, stats, constructions, skills, and portrait sockets remain stable.

---

## M1 roster (12)

Every job: one **monostack** brief, one **cross-tag** brief, one **defensive / neg-avoid** brief. C2 / C3 punish starter tags (**Soft, Earth, Metal, Wild, Silk, Pure** — `17` / `19`). Non-starter briefs go to C2 / C3; one Silk-mid mage vs Ivory Judge is the **starter-tag trap**.

Outlook names / tiers from `14` / `15`. Cross-tags have **no** 3/5/8 power ladder — one chrome (`cross`). Storm / Beastbloom / Snaretooth / Masked Crown / Dawn / Pale Hex are the stamped cross / storm outlook set.

Each of these 12 has a **Portrait uniqueness** subsection: **Race**, **Visual**, **Outfit**, **Character**, **Hook**. That block is a docs lock on the landed files. It does not open an M1 regen. Gen rules and the stamp line: [M2 portrait uniqueness](#m2-portrait-uniqueness). Ids, jobs, and `construction_ids` stay as written; the identity pass changes text-facing Public names only.

### Knight — `job_knight` · `ord_knight` · `con_armor` + `con_gloves` (gauntlet)

Job-default alias: `adv_knight` → `adv_halden_rook`.

#### `adv_halden_rook` — Ser Halden

Oath steel who still thinks a gorge-wyrm is a siege problem.

| Identity | Value |
|---|---|
| True name | **Ser Halden Baruk Rook** — `Baruk` is the ancestor-name carried by Rookhold wall-oath heirs |
| Public name | **Ser Halden** |
| Epithet | **The Walking Keep** |

**Background.** Halden comes from Rookhold breach-engineers, a dwarf clan that measures courage in walls held rather than foes slain. He took his grandfather Baruk's name when he inherited an unpaid wall-oath, and now treats every monster as a siege problem that can be solved with preparation and enough plate.

**In-game presentation.** His first order arrives as a sealed military requisition with blunt diagrams instead of personal history. `Baruk Rook` appears on the oath-signature after the player absorbs a major physical punish for him; **The Walking Keep** becomes a result-card and Dex title after a successful Metal signature build.

| Field | Value |
|---|---|
| id | `adv_halden_rook` |
| Display | Ser Halden |
| Job | Knight (`job_knight`) |
| Build intent | **Monostack** — Metal mid |
| Requirement tags | Metal **mid** (≥5). Sharp welcome, not required |
| `construction_ids` | `con_armor`, `con_gloves` |
| `target_threat_id` | `boss_ash_drake` (C1; favors Metal / Earth / Frost / Pure; punishes Soft, Sticky) |
| Skill | `ask_plate_oath` — **Plate Oath.** If planned Metal ≥ mid, the estimate (and sim) ignores the **first** physical punish chip. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 14 | 4 | 6 | 3 | 2 | 4 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Dwarf (broad jaw, short thick neck visible at bust) |
| Visual | Mid-30s; warm brown beard cropped tight to plate; stubborn brow; scar on cheekbone; honest open eyes |
| Outfit | `con_armor` + `con_gloves`. Polished steel breastplate + gauntlet cuff in frame; rook/castle emboss on pauldron; no lace |
| Character | Brave & straight |
| Hook | Oath steel who still thinks a gorge-wyrm is a siege problem. |

#### `adv_vex_bramble` — Vex

Dock-hired plate who wants teeth in the hem, not a church bell.

| Identity | Value |
|---|---|
| True name | **Vexel Bramble** |
| Public name | **Vex** |
| Epithet | **Bramblebite** |

**Background.** Vexel was a dock runner and hired breaker before a Salt Widow raid left him holding a pier with a hooked mooring chain. The knight order gave him plate but never polished away the dock slang, opportunism, or delight he takes in making armor fight dirty.

**In-game presentation.** He scratches **Vex** across the printed name on his order and immediately comments on Sticky or Sharp materials. `Vexel Bramble` is revealed by an old dock warrant during a repeat visit; **Bramblebite** appears in dockside gossip and is earned in the Dex after Snaretooth succeeds.

| Field | Value |
|---|---|
| id | `adv_vex_bramble` |
| Display | Vex |
| Job | Knight (`job_knight`) |
| Build intent | **Cross-tag** — Snaretooth |
| Requirement tags | Sticky ≥1 ∧ Sharp ≥1 (`syn_sticky_sharp`) |
| `construction_ids` | `con_armor`, `con_gloves` |
| `target_threat_id` | `boss_salt_widow` (C1; favors Frost / Silent / Metal; punishes Soft, Solar) |
| Skill | `ask_thorn_latch` — **Thorn Latch.** If Sticky ∧ Sharp both present, estimate first-ambush **bind + chip** (Snaretooth). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 11 | 6 | 4 | 3 | 5 | 2 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Half-elf (subtle pointed ears under messy hair) |
| Visual | Mid-20s; small sharp eyes; weird half-smile; head lean; dark hair with thorn-braid; lean dangerous face (Gin/Hisoka read held from prior stamp notes) |
| Outfit | `con_armor` + `con_gloves`. Dock-scuffed plate; bramble/thorn motif on gauntlet hem; less polish than Halden |
| Character | Dangerous (playful menace) |
| Hook | Dock-hired plate who wants teeth in the hem, not a church bell. |

#### `adv_solenne_ward` — Dame Solenne

Court plate. Soft and scrap-metal read as mud on the tiles — she will not wear a clang.

| Identity | Value |
|---|---|
| True name | **Dame Solenne Aurelia Ward** — `Aurelia` marks her maternal court line |
| Public name | **Dame Solenne** |
| Epithet | **The Unclanging Ward** |

**Background.** House Ward protects court proceedings where one noisy step can become a political confession. Solenne inherited the Aurelia line's ceremonial obligations, but left the inner court after refusing to disguise compromised armor as pageantry; her severe taste is professional discipline, not simple vanity.

**In-game presentation.** Her first appearance is formal and gives **Dame Solenne**, House Ward's seal, and no family lecture. Her full style is spoken at a later court hearing; **The Unclanging Ward** is granted only when the player delivers a Royal build with no negative synergy.

| Field | Value |
|---|---|
| id | `adv_solenne_ward` |
| Display | Dame Solenne |
| Job | Knight (`job_knight`) |
| Build intent | **Defensive / neg-avoid** — Royal mid; no starter Soft / Metal dump |
| Requirement tags | Royal **mid** (≥5). **Avoid** Soft; **avoid** Metal≥3 ∧ Silk≥3 (Ragged Mail); **avoid** Metal ∧ Silent (Clanging Hush) |
| `construction_ids` | `con_armor`, `con_gloves` |
| `target_threat_id` | `boss_gilded_warden` (C3; punishes Soft / Earth / Wild / **Metal**; favors Royal / Solar / Fire / Sharp) |
| Skill | `ask_clean_court` — **Clean Court.** Any planned `syn_neg_*` is a hard estimate warning. If no neg and Royal ≥ low, +PRE vs court threats. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 12 | 3 | 5 | 4 | 3 | 6 |

C3 punishes Metal: a Metal-mid Halden brief vs Gilded Warden is a **legal hard draw** on the boss beat (`28`). Solenne is the person who asked for the court answer.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | High elf (long pointed ears clear of hair) |
| Visual | Late 20s; cool fair face; platinum hair in court braid; composed mouth; no smirk |
| Outfit | `con_armor` + `con_gloves`. Clean court plate; royal trim on gorget; zero scrap-metal clang; white/gold accents |
| Character | Cool composure (court-proud) |
| Hook | Court plate — soft and scrap-metal read as mud on the tiles. |

---

### Mage — `job_mage` · `ord_mage` · `con_robe` + `con_hood`

Job-default alias: `adv_mage` → `adv_quill_lumen`.

#### `adv_quill_lumen` — Quill

Road scholar. Wants the moon on the hood, not a clean-silk sermon.

| Identity | Value |
|---|---|
| True name | **Quillian Lumen** |
| Public name | **Quill** |
| Epithet | **The Moon-Scribe** |

**Background.** Quillian left a reputable observatory when its masters dismissed roadside omens as peasant superstition. He now walks the routes he once studied from a tower, recording how moonlight, weather, and ordinary people alter supposedly fixed magic.

**In-game presentation.** His order is written as annotated field notes, with **Quill** signed in the margin and Lunar materials receiving curious comments. `Quillian Lumen` appears in an academy rejection letter; **The Moon-Scribe** unlocks after his Lunar signature result and becomes his later newspaper byline.

| Field | Value |
|---|---|
| id | `adv_quill_lumen` |
| Display | Quill |
| Job | Mage (`job_mage`) |
| Build intent | **Monostack** — Lunar mid |
| Requirement tags | Lunar **mid** (≥5) |
| `construction_ids` | `con_robe`, `con_hood` |
| `target_threat_id` | `boss_pale_choir` (C2; favors Lunar / Occult / Silent / Frost; punishes Soft / Metal / Silk) |
| Skill | `ask_night_ledger` — **Night Ledger.** If planned Lunar ≥ mid, estimate applies the night / omen bonus; Solar punish is shown. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 9 | 3 | 2 | 6 | 4 | 5 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Moon elf (pale blue undertone; long ears) |
| Visual | Mid-20s; soft scholar face; ash-lilac hair; ink-stained cheek; gentle eyes |
| Outfit | `con_robe` + `con_hood`. Robe + **hood** (mage order); lunar stitch on hood; soft-stipple grain reference face |
| Character | Quiet curiosity (road scholar) |
| Hook | Road scholar — wants the moon on the hood, not a clean-silk sermon. |

#### `adv_neri_paleink` — Neri

Signs in two inks. The aisle is still in session.

| Identity | Value |
|---|---|
| True name | **Neria Pale-Ink** |
| Public name | **Neri** |
| Epithet | **The Two-Ink Clerk** |

**Background.** Neria once authenticated records for an aisle court that kept one lawful ledger and one occult ledger. She signed the same forbidden judgment in both inks, proving the court's public history false and leaving her simultaneously wanted as a forger and needed as its only credible witness.

**In-game presentation.** Her order card is stamped twice and she corrects the player's wording before discussing cloth. The full signature is visible from the start but its meaning enters the Dex only after a Pale Hex result; later court encounters recognize **The Two-Ink Clerk** before they recognize Neri.

| Field | Value |
|---|---|
| id | `adv_neri_paleink` |
| Display | Neri |
| Job | Mage (`job_mage`) |
| Build intent | **Cross-tag** — Pale Hex |
| Requirement tags | Lunar ≥1 ∧ Occult ≥1 (`syn_lunar_occult`). **Avoid** Pure (Schism Stitch / Pale Hex Pure risk) |
| `construction_ids` | `con_robe`, `con_hood` |
| `target_threat_id` | `boss_mire_bride` (C2; favors Silent / Occult / Lunar / Sticky; punishes Soft / Pure / Silk) |
| Skill | `ask_pale_signature` — **Pale Signature.** If Lunar ∧ Occult both present, estimate Pale Hex vs the brief; Pure on the bag is a risk flag. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 8 | 4 | 2 | 7 | 3 | 4 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Human (ink-marked; no ears/plating) |
| Visual | Mid-20s; pale skin with two-tone ink freckles; dark bob; flat assessing stare |
| Outfit | `con_robe` + `con_hood`. Robe + hood; two pale-ink seals on hood edge; aisle-clerk neatness |
| Character | Dark / clinical |
| Hook | Signs in two inks — the aisle is still in session. |

#### `adv_marrowveil` — Sister Marrowveil

Wants flow and a clean hood. Will not wear a bucket. Ivory still calls silk contempt.

| Identity | Value |
|---|---|
| True name | **Elowen Marrow** |
| Public name | **Sister Marrowveil** |
| Epithet | **The Gentle Heresy** |

**Background.** Elowen took the Marrowveil order-name after tending a plague convent where heavy ceremonial hoods trapped heat and cost lives. She teaches that grace and movement are forms of devotion, a merciful doctrine the Ivory Judge considers dangerously indulgent.

**In-game presentation.** She introduces herself only as **Sister Marrowveil**, and her gentle inspection barks make the restrictive brief feel caring before its trap becomes clear. `Elowen Marrow` is revealed in a damaged convent register during her personal event; **The Gentle Heresy** first appears as an accusation, then becomes an earned Dex title.

| Field | Value |
|---|---|
| id | `adv_marrowveil` |
| Display | Sister Marrowveil |
| Job | Mage (`job_mage`) |
| Build intent | **Defensive / neg-avoid** — Silk mid; hood must stay clean |
| Requirement tags | Silk **mid** (≥5). **Avoid** Metal ≥1 (Bucket Head on `con_hood`). **Avoid** Occult ∧ Pure (Schism Stitch) |
| `construction_ids` | `con_robe`, `con_hood` |
| `target_threat_id` | `boss_ivory_judge` (C3; punishes Soft / Metal / **Pure** / **Silk**; favors Royal / Lunar / Silent / Occult) |
| Skill | `ask_clean_hood` — **Clean Hood.** Estimate fail-warns if Metal ≥1 on this hood order, or if Occult ∧ Pure both present. Silk mid adds MOB on grace beats **only if** those warns are clear. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 10 | 2 | 3 | 5 | 5 | 5 |

Silk is a **starter tag**. This brief vs Ivory Judge is the M1 **trap row** — same job as Quill / Neri, wrong tags for C3. Estimate (`30`) should show the punish once that axis is unlocked.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Human |
| Visual | Late 20s; soft devout face; veil-adjacent hood framing; warm eyes that hide the trap brief |
| Outfit | `con_robe` + `con_hood`. Clean silk-forward robe + hood (**no metal bucket**); marrow-white trim |
| Character | Soft-spoken piety (surface gentle) |
| Hook | Wants flow and a clean hood — will not wear a bucket. |

---

### Blade Dancer — `job_blade_dancer` · `ord_blade_dancer` · `con_tunic` + `con_cape`

Job-default alias: `adv_blade_dancer` → `adv_kite_thornreel`.

#### `adv_kite_thornreel` — Kite

Edge and hem. Wants a choir of cuts, not a quiet bow.

| Identity | Value |
|---|---|
| True name | **Kitarian Sableclaw Thornreel** — `Sableclaw` is the hunting-clan name he theatrically pretends not to care about |
| Public name | **Kite** |
| Epithet | **The Catsassin** |

**Background.** Kitarian was raised by Sableclaw caravan hunters who expected him to inherit their patient stalking craft. He shortened the family form to Kite, turned the quiet techniques into an extravagant blade dance, and discovered that memorable entrances produce better contracts than anonymous kills.

**In-game presentation.** Kite interrupts his own introduction to demand **The Catsassin**, while other characters pointedly call him only Kite. His full name is revealed when an unimpressed clan letter reaches the atelier; the epithet becomes legitimate on the result screen only after a Sharp signature success.

| Field | Value |
|---|---|
| id | `adv_kite_thornreel` |
| Display | Kite |
| Job | Blade Dancer (`job_blade_dancer`) |
| Build intent | **Monostack** — Sharp mid |
| Requirement tags | Sharp **mid** (≥5) |
| `construction_ids` | `con_tunic`, `con_cape` |
| `target_threat_id` | `boss_rust_knave` (C1; favors Metal / Earth / Sharp; punishes Soft, Silk) |
| Skill | `ask_edge_count` — **Edge Count.** If planned Sharp ≥ mid, estimate reflect-chip vs physical threats (Razor Choir band). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 10 | 7 | 3 | 2 | 7 | 3 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Catfolk (visible soft ears + short muzzle cue at 96) |
| Visual | Early 20s; sharp grin; wind-cut hair; bright predatory eyes |
| Outfit | `con_tunic` + `con_cape`. Tunic + cape; thorn-hem cape; edge motifs; mobile shoulders |
| Character | Dangerous / kinetic |
| Hook | Edge and hem — wants a choir of cuts, not a quiet bow. |

#### `adv_mask_circlet` — Mask

A bow that is also a lie. Court hush, not a dancing bell.

| Identity | Value |
|---|---|
| True name | **Circlet Unit M-08** |
| Public name | **Mask** |
| Epithet | **The Borrowed Bow** |

**Background.** M-08 was built to stand in for a court envoy after an assassination, reproducing posture and etiquette while the court concealed the death. Years of performing a person who no longer existed taught the construct that identity can be both false and sincerely chosen.

**In-game presentation.** Ordinary UI says **Mask** and never treats the construct as a mystery box that must be solved immediately. The unit mark appears during an inspection animation; a court-memory event explains it, while **The Borrowed Bow** is used in intrigue reports after a clean Masked Crown result.

| Field | Value |
|---|---|
| id | `adv_mask_circlet` |
| Display | Mask |
| Job | Blade Dancer (`job_blade_dancer`) |
| Build intent | **Cross-tag** — Masked Crown |
| Requirement tags | Royal ≥1 ∧ Silent ≥1 (`syn_royal_silent`). **Avoid** Metal (Clanging Hush kills Silent) |
| `construction_ids` | `con_tunic`, `con_cape` |
| `target_threat_id` | `boss_ivory_judge` (C3; favors Royal / Lunar / Silent / Occult) |
| Skill | `ask_incognito_bow` — **Incognito Bow.** If Royal ∧ Silent both present, estimate Masked Crown +PRE on intrigue. Metal on the bag → fail-open (spotted / clang). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 9 | 5 | 3 | 3 | 6 | 6 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Construct (porcelain faceplate with circlet seam; optic slits) |
| Visual | Ageless; smooth mask-face; court circlet fused to pate; no soft flesh read |
| Outfit | `con_tunic` + `con_cape`. Fine tunic + cape; royal hush palette; no ringing metal trim |
| Character | Emotionless (court lie) |
| Hook | A bow that is also a lie — court hush, not a dancing bell. |

#### `adv_whisper_hem` — Whisper

Already gone. Soft knives and ringing plate both ruin the act.

| Identity | Value |
|---|---|
| True name | **Unknown** — deliberately erased |
| Public name | **Whisper** |
| Epithet | **The Vanishing Hem** |

**Background.** Whisper was a shadow-elf route courier until a failed extraction exposed everyone attached to the route. They burned the route book, removed their own name from its final page, and now accept only work that leaves no one else carrying the evidence.

**In-game presentation.** The first order appears without an arrival animation: it is simply already on the counter. Conflicting clues enter the Dex over repeat visits, but no canonical birth name is supplied; **The Vanishing Hem** is earned when a Silent result clears without spoiled-hush warnings.

| Field | Value |
|---|---|
| id | `adv_whisper_hem` |
| Display | Whisper |
| Job | Blade Dancer (`job_blade_dancer`) |
| Build intent | **Defensive / neg-avoid** — Silent mid; hush must survive |
| Requirement tags | Silent **mid** (≥5). **Avoid** Metal ≥1 (Clanging Hush). **Avoid** Soft ∧ Sharp (Frayed Comfort — tunic is Soft-tagged in `12`, so Sharp dump is the trap) |
| `construction_ids` | `con_tunic`, `con_cape` |
| `target_threat_id` | `boss_bog_king` (C2; favors Frost / Occult / Storm / Silent; punishes Soft / Earth / Metal / Wild) |
| Skill | `ask_hush_check` — **Hush Check.** Silent mid → stealth bonus in the estimate. Any Metal, or Soft ∧ Sharp, marks the hush **spoiled**. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 8 | 4 | 2 | 3 | 8 | 2 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Shadow elf (ash-grey skin; short pointed ears) |
| Visual | Early 20s; almost blank face; dark hair covering one eye; mouth closed |
| Outfit | `con_tunic` + `con_cape`. Matte tunic + cape; no shine; hem that reads “already gone” |
| Character | Emotionless / hush |
| Hook | Already gone — soft knives and ringing plate both ruin the act. |

---

### Lagoon — `job_lagoon` · `ord_lagoon` · `con_cloak` + `con_boots`

Job-default alias: `adv_lagoon` → `adv_tide_glass`. Jonathan-named title. Not Salt Widow. Not an appointment.

#### `adv_tide_glass` — Tide

Tide-hired. Wants the sky in the cloak, not a dry court.

| Identity | Value |
|---|---|
| True name | **Thalassa Glass** |
| Public name | **Tide** |
| Epithet | **Stormglass** |

**Background.** Thalassa piloted salvage crews through reef storms until a noble recovery contract ordered her to abandon stranded deckhands for cargo. She broke contract, saved the crew, and lost the license that once made her name respectable.

**In-game presentation.** Her wet order slip uses the dock-call **Tide**, and Storm materials trigger open excitement instead of exposition. `Thalassa Glass` appears on the revoked pilot license in her rescue event; **Stormglass** becomes the name used by her returning crew after a signature build.

| Field | Value |
|---|---|
| id | `adv_tide_glass` |
| Display | Tide |
| Job | Lagoon (`job_lagoon`) |
| Build intent | **Monostack** — Storm mid |
| Requirement tags | Storm **mid** (≥5) |
| `construction_ids` | `con_cloak`, `con_boots` |
| `target_threat_id` | `boss_bog_king` (C2; favors Frost / Occult / **Storm** / Silent) |
| Skill | `ask_sky_step` — **Sky Step.** If planned Storm ≥ mid, estimate +MOB on first-move; Shock vulnerability is shown. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 11 | 5 | 3 | 5 | 6 | 3 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Sea-elf (teal undertone; finned ear tips) |
| Visual | Mid-20s; salt-wet hair; open storm eyes; spray freckles |
| Outfit | `con_cloak` + `con_boots`. Storm cloak; sky-stitch; boots implied at cut; no dry-court gold |
| Character | Brave & open (tide-hired) |
| Hook | Tide-hired — wants the sky in the cloak, not a dry court. |

#### `adv_brine_latch` — Brine

Steam in the spray. Parade glare wants fire; the lagoon still wants frost in the boot.

| Identity | Value |
|---|---|
| True name | **BRN-L7 “Latch”** |
| Public name | **Brine** |
| Epithet | **The Tempered Latch** |

**Background.** BRN-L7 regulated pressure in a brineworks until a dock explosion fused its heat and cooling governors into one unstable loop. It chose the name Brine after holding the ruptured floodgate long enough for the workers to escape, then repurposed its industrial frame for field work.

**In-game presentation.** Heat and frost gauges flicker beside **Brine** during inspection, letting behavior establish the Temper theme. The maker designation becomes readable during a repair event; **The Tempered Latch** appears only if a successful Fire–Frost result keeps the construct operational.

| Field | Value |
|---|---|
| id | `adv_brine_latch` |
| Display | Brine |
| Job | Lagoon (`job_lagoon`) |
| Build intent | **Cross-tag** — Temper (Fire ∧ Frost) |
| Requirement tags | Fire ≥1 ∧ Frost ≥1 (`syn_fire_frost_clash`). **Avoid** Soft (Scorched Down if Fire is present) |
| `construction_ids` | `con_cloak`, `con_boots` |
| `target_threat_id` | `boss_sunspear_captain` (C3; favors Solar / Sharp / **Fire** / Royal; punishes Soft / Silk / Pure / Earth) |
| Skill | `ask_temper_brine` — **Temper Brine.** If Fire ∧ Frost both present, estimate Temper (+RES, −HP steam). Soft on the bag with Fire → Scorched Down warning. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 10 | 6 | 3 | 6 | 5 | 2 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Construct (brine-stained metal cheek plates; steam vent at temple) |
| Visual | Mid-20s frame; dual flush (ember + frost) on plating seams; alert optics |
| Outfit | `con_cloak` + `con_boots`. Cloak with fire/frost dual lining flash; Temper steam at collar |
| Character | Dual-tempered grit |
| Hook | Steam in the spray — parade wants fire; lagoon still wants frost in the boot. |

#### `adv_rime_peddler` — Rime Peddler

Walks docks and mires the same. A cloak that rings like a pot lid is a failed order.

| Identity | Value |
|---|---|
| True name | **Rurik Rimeward** |
| Public name | **Rime Peddler** |
| Epithet | **The Ringless Peddler** |

**Background.** Rurik sold winter cloth between docks and mire villages, repairing garments in exchange for road gossip. A metal-rimmed cloak once drew lightning through a customer during a squall, and his fussy refusal of ringing trim is the guilt of a craftsman who already learned the lesson too late.

**In-game presentation.** He arrives by trying to sell the player something before placing his own order, so **Rime Peddler** feels like a profession rather than a fantasy alias. His ledger reveals `Rurik Rimeward`; **The Ringless Peddler** is added after the player honors his no-Metal brief under pressure.

| Field | Value |
|---|---|
| id | `adv_rime_peddler` |
| Display | Rime Peddler |
| Job | Lagoon (`job_lagoon`) |
| Build intent | **Defensive / neg-avoid** — Frost mid; cloak must not take Metal |
| Requirement tags | Frost **mid** (≥5). **Avoid** Metal ≥1 on this cloak order (Iron Mantle Fail — `syn_neg_cloak_metal`) |
| `construction_ids` | `con_cloak`, `con_boots` |
| `target_threat_id` | `boss_salt_widow` (C1; favors **Frost** / Silent / Metal — Metal favor is a **cloak trap**) |
| Skill | `ask_rime_walk` — **Rime Walk.** If planned Frost ≥ mid, estimate ignores the **first** heat punish. Metal ≥1 on the cloak → Iron Mantle Fail warning (−MOB / PRE odd). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 12 | 3 | 4 | 6 | 5 | 3 |

Salt Widow **favors Metal** and the cloak **punishes Metal**. Rime is the person who asked you not to take the obvious dock scrap.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Dwarf (stocky bust; frost-beard stubble) |
| Visual | Mid-40s; wary dock eyes; rime on brow; practical face |
| Outfit | `con_cloak` + `con_boots`. Heavy frost-cloak (**no metal pot-lid trim**); peddler clasp of bone/wood |
| Character | Wary / practical |
| Hook | Walks docks and mires the same — a cloak that rings like a pot lid is a failed order. |

---

## M2 roster (12) — opened by this stamp

The Later table (Wizard, Hexer, Outrider, Oathbound, no named people) is **this roster**. This stamp names them. It does **not** put them in `M1_JOB_POOL`. Order ids stay the job-level `ord_*` from `28`. Constructions stay the job list. Target enemies are the existing nine `boss_*` from `17` only.

Every job: one **monostack**, one **cross-tag**, one **defensive / neg-avoid**. The monostack row is the job-default alias. Stats are **test knobs** (HP 8–16, other stats 1–8). Exactly one new `ask_*` per person. Outlooks and `syn_*` ids are from `14` / `15` only. Where the preferred pair has no row in `14`, the brief says so and does not invent a chrome.

`con_robe` is Silk, `con_mantle` and `con_coat` are Royal, `con_hood` is Silent, `con_wraps` are Sticky, `con_armor` is Metal, `con_boots` are Earth (`12`). A construction tag is one count, not a mid dump.

M2 **starter-tag trap:** Pell White (`adv_pell_white`, Pure mid) vs `boss_sunspear_captain`. Same shape as Sister Marrowveil vs Ivory Judge.

Face, race, tone, outfit, and backline for a redraw are **not** this roster table. Each of the 12 has a **Portrait uniqueness** subsection: **Race**, **Visual** (face / hair / age / body, race cue readable at 96×96), **Outfit** (silhouette + palette on that job’s constructions), **Character** (short tone), **Hook** (one sentence). Same schema on the M1 twelve. Gen rules: [M2 portrait uniqueness](#m2-portrait-uniqueness). #61 ids, jobs, and `construction_ids` stay as written; Public display text follows the identity pass above.

### Wizard — `job_wizard` · `ord_wizard` · `con_robe` + `con_mantle`

Job-default alias: `adv_wizard` → `adv_vesper_cant`. Requirement-tag family in `28`: Occult, Lunar, Royal. Not the mage order (robe + hood).

#### `adv_vesper_cant` — Vesper

Court-adjacent caster. Wants the void in the seams, not a clean-silk sermon.

| Identity | Value |
|---|---|
| True name | **Vesper Cant** |
| Public name | **Vesper** |
| Epithet | **The Void Cantor** |

**Background.** Vesper served as a court music tutor until she heard a harmonic absence hidden inside a coronation cant. The court called it an error; she followed it into forbidden study and now dresses close enough to court fashion to remind them who first taught her to listen.

**In-game presentation.** Her order begins with a single missing note in the text and uses **Vesper** without explanation. Court NPCs later supply the exile story, and **The Void Cantor** appears in the Dex after an Occult signature result makes the absent note audible.

| Field | Value |
|---|---|
| id | `adv_vesper_cant` |
| Display | Vesper |
| Job | Wizard (`job_wizard`) |
| Build intent | **Monostack** — Occult mid |
| Requirement tags | Occult **mid** (≥5) |
| `construction_ids` | `con_robe`, `con_mantle` |
| `target_threat_id` | `boss_pale_choir` (C2; favors Lunar / Occult / Silent / Frost; punishes Soft / Metal / Silk) |
| Skill | `ask_void_seam` — **Void Seam.** If planned Occult ≥ mid, the estimate applies Hex Loom (`syn_occult_5`); the first Pure spike ignored is shown. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 9 | 3 | 2 | 7 | 3 | 5 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Void elf (near-black sclera hint OR deep violet ear tips; pale) |
| Visual | Mid-20s; sharp thin face; short charcoal hair with white void streak; cool grey-pale skin; narrow eyes |
| Outfit | `con_robe` + `con_mantle`. Dark void-navy robe; mantle edged near-black with pale violet void stitch; **no hood up**; void-circle clasp |
| Character | Dark / hungry quiet |
| Hook | Court-adjacent caster who wants the void in the seams, not a clean-silk sermon. |

#### `adv_nyx_vellum` — Nyx

Two inks on the mantle. A cleanse stitch splits the order.

| Identity | Value |
|---|---|
| True name | **Nyxara Vellum** |
| Public name | **Nyx** |
| Epithet | **The Split-Ink Prodigy** |

**Background.** Nyxara was the youngest copyist in the Vellum archive and learned to reproduce spells by layering lunar notation over occult corrections. A purification attempt erased half a living manuscript—and nearly half her memory—so her refusal of Pure work is fear grounded in experience.

**In-game presentation.** Nyx speaks calmly while two differently colored annotations compete on her order card. `Nyxara Vellum` is recovered from the damaged manuscript during her story event; **The Split-Ink Prodigy** becomes a mastery title after Pale Hex succeeds without Schism Stitch.

| Field | Value |
|---|---|
| id | `adv_nyx_vellum` |
| Display | Nyx |
| Job | Wizard (`job_wizard`) |
| Build intent | **Cross-tag** — Pale Hex |
| Requirement tags | Lunar ≥1 ∧ Occult ≥1 (`syn_lunar_occult`). **Avoid** Pure (Schism Stitch `syn_neg_occult_pure`) |
| `construction_ids` | `con_robe`, `con_mantle` |
| `target_threat_id` | `boss_mire_bride` (C2; favors Silent / Occult / Lunar / Sticky; punishes Soft / Pure / Silk) |
| Skill | `ask_two_ink` — **Two Ink.** If Lunar ∧ Occult both present, estimate Pale Hex vs the brief; Pure on the bag is a Schism Stitch warning. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 8 | 5 | 2 | 6 | 4 | 4 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | High elf (long ears; platinum) |
| Visual | Late teens/early 20s; soft oval face; long platinum wavy hair; ink-smudge freckles; calm downcast eyes; ears clear of hood |
| Outfit | `con_robe` + `con_mantle`. Charcoal robe; mantle vellum trim; **hood down/absent**; gold crescent + star on mantle; square gold brooch |
| Character | Calm / two-ink focus |
| Hook | Two inks on the mantle — a cleanse stitch that splits the order. |

#### `adv_orin_goldink` — Orin

The room should bow. Hemp, mud, and tar on the mantle are an insult.

| Identity | Value |
|---|---|
| True name | **Orinel Gold-Ink** |
| Public name | **Orin** |
| Epithet | **The Gilded Hand** |

**Background.** Orinel belongs to a merchant family that purchased court access one exquisitely illuminated decree at a time. He performs aristocratic contempt because the court is waiting for any lapse that proves his family still belongs outside, making his vanity both unpleasant and strategically understandable.

**In-game presentation.** His requirements arrive gold-embossed and his inspection barks react sharply to humble materials. The formal `Orinel` appears when a rival deliberately uses it to diminish him; **The Gilded Hand** is adopted after a flawless Royal commission wins public recognition.

| Field | Value |
|---|---|
| id | `adv_orin_goldink` |
| Display | Orin |
| Job | Wizard (`job_wizard`) |
| Build intent | **Defensive / neg-avoid** — Royal mid; no peasant dump; no neg that kills a Royal / Pure court read |
| Requirement tags | Royal **mid** (≥5). **Avoid** Soft, Earth, Wild. **Avoid** Sticky ≥1 (Tar at Court `syn_neg_sticky_royal`). **Avoid** Occult ≥1 ∧ Pure ≥1 (Schism Stitch `syn_neg_occult_pure`) |
| `construction_ids` | `con_robe`, `con_mantle` |
| `target_threat_id` | `boss_gilded_warden` (C3; punishes Soft / Earth / Wild / Metal; favors Royal / Solar / Fire / Sharp) |
| Skill | `ask_court_ink` — **Court Ink.** Tar at Court or Schism Stitch is a hard estimate warning. Soft / Earth / Wild warn as peasant contempt. If those warns are clear and Royal ≥ mid, +PRE vs court threats. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 11 | 3 | 3 | 5 | 2 | 7 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Human (warm olive; no nonhuman cue — contrast the two elves) |
| Visual | Late 20s; composed longer face; sleek dark hair half-back with gold ink stick pin; high cheekbones; assessing eyes |
| Outfit | `con_robe` + `con_mantle`. Deep wine robe; gold-ink calligraphy mantle; ornate round gold clasp; upright |
| Character | Court-proud / contemptuous of peasants |
| Hook | The room should bow — hemp, mud, and tar on the mantle are an insult. |

---

### Hexer — `job_hexer` · `ord_hexer` · `con_wraps` + `con_hood`

Job-default alias: `adv_hexer` → `adv_soot_cord`. Requirement-tag family in `28`: Occult, Sticky, Silent. Hood is in the order, so Bucket Head can fire.

#### `adv_soot_cord` — Soot

Names and cords. The chapel already knows the knot.

| Identity | Value |
|---|---|
| True name | **Suthra Cord** |
| Public name | **Soot** |
| Epithet | **The Knotkeeper** |

**Background.** Suthra served a soot chapel that binds the names of the dangerous dead into knotted cords so they cannot be called back. One cord was cut from the archive without authorization, and Soot now follows its trail while hiding whether the escaped name belonged to a criminal, a saint, or family.

**In-game presentation.** Soot offers a name-cord instead of a handshake, and each repeat visit adds one knot to the portrait prop. `Suthra Cord` is spoken only by the chapel during the missing-cord event; **The Knotkeeper** is earned after the player supports the Occult signature without a cleansing spike.

| Field | Value |
|---|---|
| id | `adv_soot_cord` |
| Display | Soot |
| Job | Hexer (`job_hexer`) |
| Build intent | **Monostack** — Occult mid |
| Requirement tags | Occult **mid** (≥5). Wraps already contribute Sticky; hood already contributes Silent — those are not the ask |
| `construction_ids` | `con_wraps`, `con_hood` |
| `target_threat_id` | `boss_mire_bride` (C2; favors Silent / Occult / Lunar / Sticky; punishes Soft / Pure / Silk) |
| Skill | `ask_cord_hex` — **Cord Hex.** If planned Occult ≥ mid, the estimate applies Hex Loom (`syn_occult_5`); a Pure spike is shown (the bride punishes Pure). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 10 | 4 | 3 | 6 | 4 | 2 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Human |
| Visual | Mid-20s; angular face soot-smudged; dark cropped hair under hood; cord burns on fingers; hard stare |
| Outfit | `con_wraps` + `con_hood`. Ash-grey wraps; **hood up** face clear; knotted name-cords; chapel-rope tassel |
| Character | Dangerous (named-cord) |
| Hook | Names and cords — the chapel already knows the knot. |

#### `adv_tar_veil` — Tar

Bind and a hex in the same wrap. `14` has no chrome for that pair.

| Identity | Value |
|---|---|
| True name | **Tavra Veil** |
| Public name | **Tar** |
| Epithet | **Peatbound** |

**Background.** Tavra kept curse-markers for a bog-orc settlement where names, paths, and graves shift with the mire. She wears the tar veil to filter prophetic spores and carries binding wraps because some village curses must be restrained before they can be understood.

**In-game presentation.** Tar uses few words, but the peat map on her order changes as Sticky and Occult materials enter the plan. Her village calls her `Tavra` during a rescue event; **Peatbound** appears as a respectful communal title rather than a combat boast.

| Field | Value |
|---|---|
| id | `adv_tar_veil` |
| Display | Tar |
| Job | Hexer (`job_hexer`) |
| Build intent | **Cross-tag intent** — Sticky ∧ Occult. **No** stamped cross |
| Requirement tags | Occult ≥1 ∧ Sticky ≥1. **No** `syn_sticky_occult` and **no** `syn_sticky_silent` in `14`. Do not invent one. The only Sticky cross on file is Snaretooth (`syn_sticky_sharp`); Sharp is outside this job’s family — not this brief |
| `construction_ids` | `con_wraps`, `con_hood` |
| `target_threat_id` | `boss_bog_king` (C2; favors Frost / Occult / Storm / Silent; punishes Soft / Earth / Metal / Wild). Occult is the favor. Sticky is the bog’s own threat tag |
| Skill | `ask_peat_knot` — **Peat Knot.** If Occult ≥1 and Sticky ≥1, the estimate flags the pair and does **not** show a cross outlook. Bind / Hex Loom appear only if those counts hit their own monostack rows (≥3 / ≥5). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 9 | 5 | 3 | 5 | 3 | 2 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Bog orc (green-grey skin; small lower tusks readable at 96) |
| Visual | Early 30s; heavier brow; tar stain at lip; thick dark hair half-hidden; squinted eye |
| Outfit | `con_wraps` + `con_hood`. Peat-black wraps; hood with tar-veil strip over lower face (eyes clear); bog-green wrap edge |
| Character | Grim / peat-bound |
| Hook | Bind and a hex in the same wrap — peat knot, no chrome for the pair. |

#### `adv_ashen_cowl` — Ash

Already unheard. A metal hood is a bucket. Daylight washes the work out.

| Identity | Value |
|---|---|
| True name | **ASH-CWL/04** |
| Public name | **Ash** |
| Epithet | **The Unheard** |

**Background.** ASH-CWL/04 was built as a funerary listener, carrying final whispers from plague rooms to families who could not enter. When collectors began editing inconvenient last words, the construct fled with an archive of voices it refuses to surrender or repeat without consent.

**In-game presentation.** Ash's dialogue is sparse, but muffled waveform motifs react visibly to noisy materials. The designation is found behind the cowl during a repair event; **The Unheard** becomes a Dex title after a clean Silent result and unlocks altered, slightly more personal barks.

| Field | Value |
|---|---|
| id | `adv_ashen_cowl` |
| Display | Ash |
| Job | Hexer (`job_hexer`) |
| Build intent | **Defensive / neg-avoid** — Silent mid; no Pure / Solar wash; no Metal on the hood |
| Requirement tags | Silent **mid** (≥5). **Avoid** Metal ≥1 (Bucket Head `syn_neg_hood_metal` on `con_hood`, and Clanging Hush `syn_neg_metal_silent`). **Avoid** Pure ≥1 (judge punish; Schism Stitch if Occult is also present). **Avoid** Solar ≥1 (day wash — no `syn_neg_solar_*` in `14`; the avoid is the brief) |
| `construction_ids` | `con_wraps`, `con_hood` |
| `target_threat_id` | `boss_ivory_judge` (C3; punishes Soft / Metal / Pure / Silk; favors Royal / Lunar / Silent / Occult) |
| Skill | `ask_unbucketed` — **Unbucketed.** Estimate fail-warns if Metal ≥1 on this hood (Bucket Head + Clanging Hush). Pure or Solar on the bag marks the hush **washed**. Silent mid adds stealth only if those warns are clear. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 9 | 3 | 2 | 4 | 8 | 3 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Ash construct (matte ceramic/ash face; faint seam lines; soft optic glow) |
| Visual | Androgynous young adult frame; washed ash-blonde “hair” filaments; very pale; large quiet optics |
| Outfit | `con_wraps` + `con_hood`. Soft ashen cowl (**cloth only — no metal bucket**); pale wraps; grey-lilac hush palette |
| Character | Emotionless / unheard |
| Hook | Already unheard — a metal hood is a bucket; daylight washes the work out. |

---

### Outrider — `job_outrider` · `ord_outrider` · `con_coat` + `con_boots`

Job-default alias: `adv_outrider` → `adv_harrow_gale`. Requirement-tag family in `28`: Wild, Storm, Silent. Coat does not ban Fire or Frost mats. There is no `syn_neg_coat_metal`; Iron Mantle Fail is `con_cloak` only.

#### `adv_harrow_gale` — Harrow

Wagon-side. Wants the sky in the coat, not a second helping of bog.

| Identity | Value |
|---|---|
| True name | **Harodan Gale** |
| Public name | **Harrow** |
| Epithet | **The Wagon Wall** |

**Background.** Harodan guarded migrant wagons across open storm roads and learned that panic overturns more carts than lightning. He keeps the easy road smile and broad stance of someone who puts himself on the weather side first, but carries the names of a convoy he once failed to turn away from a flooded shortcut.

**In-game presentation.** Wagon wheels announce Harrow before his portrait enters, and his requirement text reads like practical road advice. `Harodan Gale` appears on the old convoy roll; **The Wagon Wall** is bestowed by surviving travelers after a Storm signature success.

| Field | Value |
|---|---|
| id | `adv_harrow_gale` |
| Display | Harrow |
| Job | Outrider (`job_outrider`) |
| Build intent | **Monostack** — Storm mid |
| Requirement tags | Storm **mid** (≥5). Wild is the job’s other staple and is **not** the ask — the bog punishes Wild |
| `construction_ids` | `con_coat`, `con_boots` |
| `target_threat_id` | `boss_bog_king` (C2; favors Frost / Occult / **Storm** / Silent; punishes Soft / Earth / Metal / Wild) |
| Skill | `ask_road_static` — **Road Static.** If planned Storm ≥ mid, the estimate applies Thunder Hem (`syn_storm_5`): +MOB, first Shock ignored. Wild ≥ mid warns — the bog punishes Wild even when the sky is right. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 12 | 5 | 3 | 4 | 7 | 3 |

Boots are Earth (`12`). Bog King punishes Earth. One Earth from the boots is the construction, not an Earth-mid brief. An Earth-mid or Wild-mid dump on this order is the starter trap Harrow refused.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Human |
| Visual | Mid-30s weathered; wind-chapped; storm-grey messy hair; brow scar; grit smile; broader shoulders |
| Outfit | `con_coat` + `con_boots`. Storm-slate coat collar up; sky-blue hem stitch; road dust on shoulder |
| Character | Brave & straight (wagon-side) |
| Hook | Wagon-side — wants the sky in the coat, not a second helping of bog. |

#### `adv_flint_rime` — Flint

Steam on the mile. The parade wants fire. The coat can still carry frost.

| Identity | Value |
|---|---|
| True name | **Flint Rimescale** |
| Public name | **Flint** |
| Epithet | **Steamrunner** |

**Background.** Flint was born between an ember clan and a frost clan, each treating the other half of his scales as a defect to be corrected. He became an outrider to make the contradiction useful, learning to vent dangerous heat through motion rather than choose one inheritance.

**In-game presentation.** Frost forms and evaporates around his portrait as Fire and Frost enter the plan, communicating Temper before any biography. `Rimescale` is revealed when both clans appear at a parade contract; **Steamrunner** is earned by completing that commission with the paired build intact.

| Field | Value |
|---|---|
| id | `adv_flint_rime` |
| Display | Flint |
| Job | Outrider (`job_outrider`) |
| Build intent | **Cross-tag** — Temper (Fire ∧ Frost) |
| Requirement tags | Fire ≥1 ∧ Frost ≥1 (`syn_fire_frost_clash`). **Avoid** Soft (Scorched Down `syn_neg_fire_soft` once Fire is present). `14` has **no** `syn_wild_storm` and **no** `syn_storm_silent`. Temper is the stamped fallback the coat allows. Greenmail (`syn_wild_earth`) is Wild ∧ Earth, not this pair, and Earth is the boot’s starter tag |
| `construction_ids` | `con_coat`, `con_boots` |
| `target_threat_id` | `boss_sunspear_captain` (C3; favors Solar / Sharp / **Fire** / Royal; punishes Soft / Silk / Pure / Earth) |
| Skill | `ask_mile_temper` — **Mile Temper.** If Fire ∧ Frost both present, estimate Temper (+RES, −HP steam). Soft with Fire → Scorched Down warning. Do not show a Wild ∧ Storm outlook. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 11 | 6 | 3 | 5 | 6 | 2 |

Sunspear punishes Earth. The boots contribute one Earth. Fire mid is not the ask — the pair is.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Dragonkin (small horn nubs + scale patches on cheek/jaw — frost+ember) |
| Visual | Mid-20s; sharp cheekbones; dual-tone hair (ember auburn / frost tips) OR dark hair with frost rim; steam flush |
| Outfit | `con_coat` + `con_boots`. Dual-palette coat — ember rust lining + frost-blue trim; steam at collar |
| Character | Restless / dual-temper |
| Hook | Steam on the mile — the parade wants fire; the coat can still carry frost. |

#### `adv_lark_mute` — Lark

Sleeps in the coat and leaves no ring. Plate and soft hemp both spoil the road.

| Identity | Value |
|---|---|
| True name | **Larkin Mute** |
| Public name | **Lark** |
| Epithet | **The Ringless Road** |

**Background.** Larkin comes from a halfling courier family whose routes are sung so they cannot be lost. After hostile listeners learned to follow those songs, Lark devised a silent route language and accepted `Mute` as an earned road-name rather than an insult.

**In-game presentation.** Lark is first found asleep inside the coat and communicates the opening order with route marks and short phrases. The family route-book reveals `Larkin`; **The Ringless Road** appears after a Silent result and turns later route marks into readable shortcuts.

| Field | Value |
|---|---|
| id | `adv_lark_mute` |
| Display | Lark |
| Job | Outrider (`job_outrider`) |
| Build intent | **Defensive / neg-avoid** — Silent mid; no Metal dump on the coat; no Soft trap |
| Requirement tags | Silent **mid** (≥5). **Avoid** Metal ≥1 (Clanging Hush `syn_neg_metal_silent` — Silent powers disabled). **Avoid** Soft ≥1 (starter tag; this judge punishes Soft). Iron Mantle Fail (`syn_neg_cloak_metal`) does **not** apply — that row is `con_cloak` only, and this order is `con_coat` |
| `construction_ids` | `con_coat`, `con_boots` |
| `target_threat_id` | `boss_ivory_judge` (C3; punishes Soft / Metal / Pure / Silk; favors Royal / Lunar / **Silent** / Occult). The coat’s Royal tag is favored here; it is not the ask |
| Skill | `ask_coat_hush` — **Coat Hush.** Silent mid → stealth in the estimate. Metal ≥1 marks the hush **spoiled**. Soft ≥1 marks the starter-tag trap vs this judge. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 10 | 4 | 4 | 3 | 7 | 4 |

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Halfling (smaller head/shoulder scale in bust; rounder face) |
| Visual | Early 20s; soft round face; mouse-brown tucked hair; small quiet mouth; eyes that look past you |
| Outfit | `con_coat` + `con_boots`. Muted earth-brown matte coat; no metal shine; dusty olive + clay |
| Character | Soft-spoken / careful |
| Hook | Sleeps in the coat and leaves no ring — plate and soft hemp both spoil the road. |

---

### Oathbound — `job_oathbound` · `ord_oathbound` · `con_armor` + `con_mantle`

Job-default alias: `adv_oathbound` → `adv_aurel_vow`. Requirement-tag family in `28`: Royal, Solar, Pure. Armor is Metal. Mantle is Royal.

`14` has no Solar ∧ Royal cross and no Solar ∧ Sharp cross. The stamped cross that uses this family is Dawn Vestment (`syn_solar_pure`). Masked Crown is Royal ∧ Silent — Silent is not this job’s family.

#### `adv_aurel_vow` — Aurel

Sworn to the paper’s noon. The yard can keep its glare if the cloth holds the sun.

| Identity | Value |
|---|---|
| True name | **Aurelian Vow** |
| Public name | **Aurel** |
| Epithet | **Noon’s Witness** |

**Background.** Aurelian once served a noble patron who falsified a casualty list and expected his oathbound retinue to bless it. Aurel read the true names aloud at noon, surrendered the patron's name from his own, and now swears only to vows written where everyone can see them.

**In-game presentation.** Aurel reads the order contract aloud and asks the player to confirm it, making honesty part of the interaction. `Aurelian Vow` appears on the uncensored casualty list; **Noon’s Witness** is reclaimed through a Solar signature result.

| Field | Value |
|---|---|
| id | `adv_aurel_vow` |
| Display | Aurel |
| Job | Oathbound (`job_oathbound`) |
| Build intent | **Monostack** — Solar mid |
| Requirement tags | Solar **mid** (≥5). Royal is already on `con_mantle`; Sharp is welcome, not required |
| `construction_ids` | `con_armor`, `con_mantle` |
| `target_threat_id` | `boss_sunspear_captain` (C3; favors **Solar** / Sharp / Fire / Royal; punishes Soft / Silk / Pure / Earth) |
| Skill | `ask_noon_oath` — **Noon Oath.** If planned Solar ≥ mid, the estimate applies Noon Favor (`syn_solar_5`); the first Lunar punish ignored is shown. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 15 | 3 | 6 | 4 | 2 | 6 |

Same parade as Pell White, opposite ask. Solar is favored. Pure is punished. Aurel is the person who asked for the favor.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Human |
| Visual | Mid-20s earnest; warm tan; short sun-gold crop; open bright eyes; freckles; square jaw |
| Outfit | `con_armor` + `con_mantle`. Polished armor; solar-yellow noon mantle; warm gold accents |
| Character | Brave & straight (sworn noon) |
| Hook | Sworn to the paper’s noon — the yard can keep its glare if the cloth holds the sun. |

#### `adv_clarion_mantle` — Clarion

Dawn on sworn plate. Occult in the same weave argues with the vow.

| Identity | Value |
|---|---|
| True name | **CLARION-MANTLE/07** |
| Public name | **Clarion** |
| Epithet | **The Seventh Dawn** |

**Background.** CLARION-MANTLE/07 was forged to announce coronations and has watched six rulers use the same dawn language before betraying the vows beneath it. The seventh time, the construct refused the ceremony, left the palace, and chose to make the vow rather than merely proclaim it.

**In-game presentation.** Clarion's first arrival uses a restrained ceremonial chime and the short Public name. The maker plate is exposed during a mantle repair; **The Seventh Dawn** appears after Dawn Vestment succeeds and marks the point where later dialogue shifts from recited formulae to chosen words.

| Field | Value |
|---|---|
| id | `adv_clarion_mantle` |
| Display | Clarion |
| Job | Oathbound (`job_oathbound`) |
| Build intent | **Cross-tag** — Dawn Vestment |
| Requirement tags | Solar ≥1 ∧ Pure ≥1 (`syn_solar_pure`). **Avoid** Occult ≥1 (Schism Stitch `syn_neg_occult_pure` mutes Pure and the Dawn read) |
| `construction_ids` | `con_armor`, `con_mantle` |
| `target_threat_id` | `boss_gilded_warden` (C3 court; favors Royal / **Solar** / Fire / Sharp; punishes Soft / Earth / Wild / **Metal**; does not punish Pure) |
| Skill | `ask_dawn_line` — **Dawn Line.** If Solar ∧ Pure both present, estimate Dawn Vestment (bonus vs Occult / dark). Occult on the bag → Schism Stitch warning. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 13 | 3 | 5 | 5 | 2 | 7 |

C3 punishes Metal. Solar ∧ Pure is the ask. The armor’s Metal tag vs this warden is a **legal hard draw** — same shape as a Metal-mid Halden brief on the same boss.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Construct (gilt ceremonial faceplate; dawn-ray etched optics) |
| Visual | Late 20s solemn frame; cooler fair plating; longer ash-brown hair filaments tied back; grave mouth |
| Outfit | `con_armor` + `con_mantle`. Formal plate; dawn white-gold mantle (paler than Aurel’s noon yellow); clarion/dawn-ray crest |
| Character | Solemn / ceremonial |
| Hook | Dawn on sworn plate — Occult in the same weave argues with the vow. |

#### `adv_pell_white` — Pell

Wants the stitch of daylight. The sunspear yard calls that contempt.

| Identity | Value |
|---|---|
| True name | **Pell Severin White** — `Severin` is the judgment-name of an old pale-elf house |
| Public name | **Pell** |
| Epithet | **The White Measure** |

**Background.** House White trained Pell to treat purity as measurable law, and the inherited Severin name marks the family member expected to pronounce judgment. Pell's cold certainty conceals a deeper fear: if a Pure answer can fail at the Sunspear yard, then the standard governing their entire life may be incomplete.

**In-game presentation.** Pell gives only the short name while the order bears the severe three-part seal, signaling lineage without an opening monologue. The full name is spoken at a house tribunal after the starter-tag trap is exposed; **The White Measure** can become either a proud or questioned Dex title depending on the result.

| Field | Value |
|---|---|
| id | `adv_pell_white` |
| Display | Pell |
| Job | Oathbound (`job_oathbound`) |
| Build intent | **Defensive / neg-avoid** — Pure mid; no peasant dump. **Starter-tag trap** vs the parade |
| Requirement tags | Pure **mid** (≥5). **Avoid** Soft, Earth, Wild (peasant staples). **Avoid** Occult ≥1 (Schism Stitch `syn_neg_occult_pure`). No `syn_neg_soft_metal` in `14` — do not invent one; Soft on this plate is still the peasant warn. Silk ≥3 on this armor also fires Ragged Mail (`syn_neg_metal_silk`) because `con_armor` is Metal |
| `construction_ids` | `con_armor`, `con_mantle` |
| `target_threat_id` | `boss_sunspear_captain` (C3; punishes Soft / Silk / **Pure** / Earth; favors Solar / Sharp / Fire / Royal) |
| Skill | `ask_clean_vow` — **Clean Vow.** Pure mid shows White Stitch (`syn_pure_5`) on the estimate. This brief vs Sunspear is a **starter-tag trap** — Pure is punished; the letter should show it (`30`). Occult ≥1 → Schism Stitch (Pure muted). Soft / Earth / Wild → peasant-dump warning. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 12 | 2 | 5 | 6 | 2 | 6 |

Pure is a **starter tag**. This brief vs Sunspear Captain is the M2 **trap row** — same job as Aurel Vow, same parade, wrong tag. Aurel asked for Solar, which this captain favors. Estimate (`30`) should show the punish once that axis is unlocked.

##### Portrait uniqueness

96×96 bust. Race cue must survive soft-stipple. Constructions stay the job list above.

| Field | Value |
|---|---|
| Race | Pale elf (stark white hair; ice undertone; long ears) |
| Visual | Mid-20s severe; very pale; cold grey eyes; thinner lips; less warmth than Aurel |
| Outfit | `con_armor` + `con_mantle`. Armor + stark white mantle; clean stitch embroidery; cold silver/white metal (minimal gold) |
| Character | Cold / severe purity |
| Hook | Wants the stitch of daylight — the sunspear yard calls that contempt. |

---

## Harness (Test)

Reuse `20` / `28`. **No** new person field. `20` assert 23 still describes the **M1** pool until a Client stamp edits it. The asserts below are the Design split. Each smoke checks **its own 12**. An M2 id fails an M1 smoke. An M1 id fails an M2 smoke.

| Field | Value |
|---|---|
| `boss_client_id` | Named `adv_*` from this catalog (never `appt_*`). Job-stubs still **parse** as the job-default alias |
| `boss_job_id` | Matching `job_*` |
| `order_id` | Job-level `ord_*` from `28` |
| `construction_ids` | That job’s list, in sequence |
| `threat_id` | Shop / walk-in: catalog `target_threat_id`. Boss beat: `chapter_boss_id` |
| `chapter_boss_id` / `boss_pool_id` | Unchanged (`17`) |

**M1 pool active.** On `mission_kind=boss`, assert `23` from `20` **plus**: `boss_client_id` is one of the **12** M1 named people (or a job-default alias `adv_knight` / `adv_mage` / `adv_blade_dancer` / `adv_lagoon`); `boss_job_id` ∈ `{job_knight, job_mage, job_blade_dancer, job_lagoon}`; `construction_ids` still equals the **job** list (not a per-person invention). Wizard / Hexer / Outrider / Oathbound fail this assert.

**M2 / Steam-demo pool active.** On `mission_kind=boss`, assert `23` from `20` **plus**: `boss_client_id` is one of the **12** M2 named people or a job-default alias (`adv_wizard` → `adv_vesper_cant`, `adv_hexer` → `adv_soot_cord`, `adv_outrider` → `adv_harrow_gale`, `adv_oathbound` → `adv_aurel_vow`); `boss_job_id` ∈ `{job_wizard, job_hexer, job_outrider, job_oathbound}`; `construction_ids` still equals the **job** list. Knight, Mage, Blade Dancer, and Lagoon fail this assert. `boss_client_id` is never an `appt_*`.

Profile unlock save (`unlocked_builds`) is **not** a `20` Required run field — it is meta (Dex Builds tab). Log keys live in [30](30-interactive-order.md) slice 2 and [31-dex](31-dex.md).

---

## Ugly-Client

Text-first stays legal. Names + job + stats + skill line + tag line + `boss_*` brief id are enough until a portrait file exists. Slice UI for slices 1–3 stays the ugly panel in [30](30-interactive-order.md). Posture stills and playback are that file’s slice 4 (Client #70; sockets shipped; art Later, **Nov 2**) — not a second portrait, and not this catalog’s gen list. No poster art.

Portrait sockets (one per surface that already shows a person) are [below](#portrait-sockets-2026-10-20).

---

## Portrait sockets (2026-10-20)

**Status:** First wave **landed** (#54 art / #55 Client) — the **12** named M1 `adv_*`. Do not regen them. Job stubs are not a wave. The M2 twelve are named in the roster above. Uniqueness for all 24 is stamped in [M2 portrait uniqueness](#m2-portrait-uniqueness) (ACCEPT #63; redraws #64 / #65). Do not regen. Do not revive #62.

### Socket count

**One portrait socket** on each adventurer UI surface that shows a person. Same `adv_id` file fills whichever of these is on screen. Do not add a gallery, a second bust, or a new screen.

| Surface | Where the person already shows | Socket |
|---|---|---|
| Order detail | [30](30-interactive-order.md) slice 1 order panel | One bust of the adventurer on the order |
| Boss brief | Boss-beat panel of the drawn named `adv_*` (this catalog’s draw / `30`) | One bust of **that adventurer**. The boss they fight stays [17](17-chapter-bosses.md) — no boss portrait this stamp |
| Shop walk-in | A walk-in order that shows a named adventurer | One bust of that adventurer. M1 walk-ins are the original 12. An M2 walk-in uses the same socket; a missing file stays text |

Text-first UI on these surfaces stays legal until the file exists.

### First wave — these 12 only

Not the job stubs (`adv_knight`, `adv_mage`, `adv_blade_dancer`, `adv_lagoon`, and the four M2 aliases). Not the M2 twelve — those people are named above; this wave did not gen them. Not Scrap Duelist (`appt_scrap_duelist`).

| Job | `adv_id` | Public display |
|---|---|---|
| Knight | `adv_halden_rook` | Ser Halden |
| Knight | `adv_vex_bramble` | Vex |
| Knight | `adv_solenne_ward` | Dame Solenne |
| Mage | `adv_quill_lumen` | Quill |
| Mage | `adv_neri_paleink` | Neri |
| Mage | `adv_marrowveil` | Sister Marrowveil |
| Blade Dancer | `adv_kite_thornreel` | Kite |
| Blade Dancer | `adv_mask_circlet` | Mask |
| Blade Dancer | `adv_whisper_hem` | Whisper |
| Lagoon | `adv_tide_glass` | Tide |
| Lagoon | `adv_brine_latch` | Brine |
| Lagoon | `adv_rime_peddler` | Rime Peddler |

### Art cut — Design default for stamp

Same PixelLab grain as the stamped market shelf icons and the armor packs: **Pro Flash, soft-stipple, one 96×96 canvas**. A bust uses that canvas (head and shoulders, one front view) so this wave does not open a second size. Jonathan stamps this default, or writes a different canvas on the stamp line. This PR does not gen.

| | |
|---|---|
| Tool / grain | PixelLab **Pro Flash 96×96 soft-stipple** portrait bust |
| Subject | Head and shoulders, one front view, of that named person |
| Leave out of the PNG | Card frame. Shiny overlay. Posture sheet. Direction sheet. Outfit-transfer sheet |
| Path | `assets/adv/<adv_id>.png` |
| Wire path | `res://assets/adv/<adv_id>.png` |

### Wire contract (Ulquiorra — after stamp, not this PR)

Placeholder on each socket = **display name + job** (already on the ugly panel). When `res://assets/adv/<adv_id>.png` exists, show it in a `TextureRect` on that socket. Missing file → text only. Do not require the png for the panel to function. Do not invent interactive-order beyond the existing ugly UI. Job-stub ids do not grow their own files; the alias still resolves to the named row (`adv_knight` → `adv_halden_rook`, `adv_mage` → `adv_quill_lumen`, `adv_blade_dancer` → `adv_kite_thornreel`, `adv_lagoon` → `adv_tide_glass`, `adv_wizard` → `adv_vesper_cant`, `adv_hexer` → `adv_soot_cord`, `adv_outrider` → `adv_harrow_gale`, `adv_oathbound` → `adv_aurel_vow`). M2 alias targets have no stamped png on this tip. Redraw brief: [M2 portrait uniqueness](#m2-portrait-uniqueness). `style_image` grain is `adv_quill_lumen` only — do not clone that face, including when Quill’s own uniqueness row is filled. ACCEPT redraws the M2 twelve only.

### Explicit non-goals (this stamp)

- Posture sheets
- Battle playback and posture stills — law is [30](30-interactive-order.md) slice 4. This portrait section does not gen them
- M2 portrait gens in the 2026-10-20 wave. The redraw brief is [M2 portrait uniqueness](#m2-portrait-uniqueness). A Design PR still does not gen
- Scrap Duelist portraits (or any `appt_*`)
- Portraits for job stubs (`adv_knight` and the other aliases)
- Boss / enemy portraits
- Gens, Client, or Godot in this Design PR

---

## M2 portrait uniqueness

**Status:** **Stamped** (Jonathan ACCEPT all 24 on #63). Redraws landed (#64 M1, #65 M2) and replace the held #62 outlook. Schema on every named `adv_*` (M1 12 + M2 12 = **24**): **Race | Visual | Outfit | Character | Hook**. This section does **not** change roster ids, jobs, `ask_*`, stats, requirement tags, or `construction_ids` (#61 held; M1 roster held). Public display names may use the later identity layer; that text change does not reopen portrait art. Do not regen. Do not revive #62.

After ACCEPT: Harribel soft-gate on the **12 M2 redraws only**, then Nnoitra reburn (replace the #62 assets). An M1 redraw is **not** opened by that ACCEPT. M1 regen needs a separate Jonathan stamp. The M1 rows are a docs lock on the landed files. Aizen owns the Jonathan 1:1.

Share soft-stipple grain only. Race cues must read at 96×96. The one-line above each roster table stays the catalog voice. The **Hook** cell is the art backline. **Character** is short tone.

### Held constructions (unchanged)

| Pool | Job | Order | Silhouette lock |
|---|---|---|---|
| M1 | Knight | `con_armor` + `con_gloves` | Plate and gauntlet cuff. No lace |
| M1 | Mage | `con_robe` + `con_hood` | Robe and hood. Hood stays cloth — no metal bucket |
| M1 | Blade Dancer | `con_tunic` + `con_cape` | Tunic and cape |
| M1 | Lagoon | `con_cloak` + `con_boots` | Cloak. No pot-lid metal on the cloak |
| M2 | Wizard | `con_robe` + `con_mantle` | Mantle, not the mage hood. **Hood-up is forbidden** |
| M2 | Hexer | `con_wraps` + `con_hood` | Hood and wraps. Cloth only — no metal bucket |
| M2 | Outrider | `con_coat` + `con_boots` | Coat. No robe. No plate |
| M2 | Oathbound | `con_armor` + `con_mantle` | Armor and mantle. Not a peasant coat |

No new job. No new `con_*`.

### Art brief (tech unchanged)

Same socket and path as the landed M1 wave. No second folder. No posture sheet. Missing file → text only.

| | |
|---|---|
| Tool / grain | PixelLab **Pro Flash 96×96 soft-stipple** bust |
| Subject | Head and shoulders, one front view. Race cue in frame (ears, stature, tusks, plating, fins, horns) |
| `style_image` | Stamped M1 bust `adv_quill_lumen` (`assets/adv/adv_quill_lumen.png`) — **grain only**. Not a face clone. Quill’s own uniqueness row does not make Quill the face of anyone else. Costume, race, and face come from that person’s **Portrait uniqueness** row |
| Path | `assets/adv/<adv_id>.png` (`res://assets/adv/<adv_id>.png`) |
| Leave out | Card frame. Shiny overlay. Posture sheet. Direction sheet. A second bust |

### The 24

Five fields under each person, in this order: **Race**, **Visual**, **Outfit**, **Character**, **Hook**. M1 rows sit on the M1 roster. M2 rows sit on the M2 roster.

| Pool | Job | `adv_id` | Public display |
|---|---|---|---|
| M1 | Knight | `adv_halden_rook` | Ser Halden |
| M1 | Knight | `adv_vex_bramble` | Vex |
| M1 | Knight | `adv_solenne_ward` | Dame Solenne |
| M1 | Mage | `adv_quill_lumen` | Quill |
| M1 | Mage | `adv_neri_paleink` | Neri |
| M1 | Mage | `adv_marrowveil` | Sister Marrowveil |
| M1 | Blade Dancer | `adv_kite_thornreel` | Kite |
| M1 | Blade Dancer | `adv_mask_circlet` | Mask |
| M1 | Blade Dancer | `adv_whisper_hem` | Whisper |
| M1 | Lagoon | `adv_tide_glass` | Tide |
| M1 | Lagoon | `adv_brine_latch` | Brine |
| M1 | Lagoon | `adv_rime_peddler` | Rime Peddler |
| M2 | Wizard | `adv_vesper_cant` | Vesper |
| M2 | Wizard | `adv_nyx_vellum` | Nyx |
| M2 | Wizard | `adv_orin_goldink` | Orin |
| M2 | Hexer | `adv_soot_cord` | Soot |
| M2 | Hexer | `adv_tar_veil` | Tar |
| M2 | Hexer | `adv_ashen_cowl` | Ash |
| M2 | Outrider | `adv_harrow_gale` | Harrow |
| M2 | Outrider | `adv_flint_rime` | Flint |
| M2 | Outrider | `adv_lark_mute` | Lark |
| M2 | Oathbound | `adv_aurel_vow` | Aurel |
| M2 | Oathbound | `adv_clarion_mantle` | Clarion |
| M2 | Oathbound | `adv_pell_white` | Pell |

### QC / gen rules

Nnoitra, after the stamp, and only for the busts that stamp opens:

- Field order is **Race**, **Visual**, **Outfit**, **Character**, **Hook**. Race and Character are first-class prompt inputs, with Visual and Outfit.
- A race cue has to survive soft-stipple at 96×96: ears (elf), stature or jaw (dwarf, halfling), plating or optics (construct), fins or scale (sea-elf, dragonkin), tusks (bog orc), horns (dragonkin).
- Within each job trio, races differ, characters differ, and faces do not share the same age band + hair color + expression.
- `style_image` / `quill_lumen` / `adv_quill_lumen` = grain only. Quill’s uniqueness row does not license cloning that face onto the other 23.
- Silhouette matches the held construction. Wizard = mantle, **not hood-up**. Mage = robe + hood (that hood stays). Hexer = hood / wraps, up only as that row says. Outrider = coat. Oathbound = armor + mantle. Knight = plate + gauntlet. Blade Dancer = tunic + cape. Lagoon = cloak.
- Soot: hood up, face clear. Tar: tar-veil strip, eyes clear, tusks still readable. Ashen and Marrowveil: cloth hood or cowl, **no metal bucket**.
- Constructions held. #61 roster held. M1 ids, jobs, and constructions held.
- Do not invent a job, a `con_*`, or one shared outlook to save a gen.
- ACCEPT opens **12 M2 redraws only**. Do not regen the landed M1 twelve under this stamp.

### Stamp line

**Record:** Jonathan ACCEPT all 24 on #63. M1 art #64. M2 art #65. Do not regen. Do not revive #62. The ask text was: ACCEPT all Race / Character / Visual / Outfit / Hook rows for the **24**, or rewrite named rows (list the `adv_*`). #61 and the M1 roster stay as written.


## Explicit non-goals

- Mass-renaming `boss_client_id` / `cli_*` / historical “client” prose
- Scrap Duelist (or any `appt_*`) as a boss-pool adventurer
- Inventing `con_*`, a ninth job, or a new `boss_*`
- Putting Wizard / Hexer / Outrider / Oathbound into `M1_JOB_POOL` — **LOCKED** out (Jonathan 2026-10-08)
- Putting Knight / Mage / Blade Dancer / Lagoon into `M2_JOB_POOL`, or merging the two pools into one draw — **LOCKED** out (Jonathan 2026-10-21, draw B)
- Job-stub fallback on either smoke
- Wiring this catalog in Client, reopening Elite N5 (shipped in [22](22-chapter-schedule.md)), owning slice 4 playback (law is [30](30-interactive-order.md)), or a stat / event retune
- M2 portrait gens, M1 regen, PNG edits, or posture files in this catalog (uniqueness rows are the bust brief; bust path stays `assets/adv/<adv_id>.png`; posture path is slice 4 in `30`; the landed busts stay unless a later stamp opens regen)
- One shared face or outlook across the M2 twelve (`adv_quill_lumen` is grain only)
- Wizard hood-up (wizard order stays `con_robe` + `con_mantle`)
- Scrap Duelist or job-stub portraits

---

## Pointers

- Interactive-order slices 1–3: [30-interactive-order](30-interactive-order.md)
- Dex: [31-dex](31-dex.md)
- Job pool / constructions: [28-boss-client-pool](28-boss-client-pool.md)
- Bosses / starter-tag law: [17-chapter-bosses](17-chapter-bosses.md)
- Synergy tiers / cross-tags / neg: [14-synergies](14-synergies.md)
- Outlook ids: [15-outlook-gen-list](15-outlook-gen-list.md)
- Harness: [20-harness-stamp](20-harness-stamp.md)
- Craft Finish: [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Starter tags: [19-own-basic-starter](19-own-basic-starter.md)
- PM: [pm/phase-1-plan](pm/phase-1-plan.md)
- Market (closed M1; skills icons + tab chrome live there): [32-shop-and-events](32-shop-and-events.md)
- Until-M2 stat lock (closed, Design #72 / Client #73, accept **A A A A**): [33-until-m2-tuning](33-until-m2-tuning.md)
- Art pointer: [05-art](05-art.md)
