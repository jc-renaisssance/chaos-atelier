# M1 adventurer catalog

**Doc id: `29`.** Design only — no Client / Godot / art this stamp. Grimmjow 2026-10-05. Interactive-order slices 1–3: **[30-interactive-order](30-interactive-order.md)**. Jobs / constructions: **[28-boss-client-pool](28-boss-client-pool.md)**.

**Terminology:** UI / prose says **adventurer**. **Client** = Godot Client seat / codebase. Internal ids stay (`boss_client_id`, `con_*`, `appt_*`, `adv_*`, `ord_*`, `job_*`) so saves and Test smokes do not churn. Do not mass-rename existing ids. Scrap Duelist stays `appt_*`.

---

## M1 cut

| Lock | Value |
|---|---|
| Jobs in M1 draw | **LOCKED (Jonathan 2026-10-08) — 4 only:** Knight, Mage, Blade Dancer, Lagoon. Closes PR #28 open question 1 |
| Adventurers / job | **3** (more than one per job — PM lock) |
| M1 roster | **12** named `adv_*` |
| Later / M2 jobs | Wizard, Hexer, Outrider, Oathbound — stay in `28`, **out of the M1 draw** until named people land. Do **not** draw them; do **not** stub-fallback |
| Constructions | Job-fixed from `28` — do not invent `con_*` |
| Target enemies | Existing `boss_*` from `17` (limited enemy types = the 9 chapter bosses) |
| Appointments | Not this catalog. Scrap Duelist stays `appt_scrap_duelist` |

Numbers in this doc (stats, estimate weights in `30`) are **test knobs**, not a hard lock. Jonathan may retune. **S–F estimate letter bands** in `30` stay Test knobs — **LOCKED leave-as-knobs** (Jonathan 2026-10-08); do not lock the cutoff table.

---

## IDs

Reuse existing prefixes. **New prefix (none existed for adventurer battle skills):** `ask_*` = one combat / estimate skill on an adventurer. Distinct from `sk_*` owner **craft** skills (`27`).

| Prefix | Role | Status |
|---|---|---|
| `job_*` | Job title | Reuse `28` |
| `adv_*` | Named adventurer; live `boss_client_id` | New people below; job-stubs `adv_knight` / `adv_mage` / … from `28` stay as **job-default aliases** (not people) |
| `ord_*` | Order id | Reuse job-level `ord_knight` / `ord_mage` / `ord_blade_dancer` / `ord_lagoon` from `28` — constructions are identical per job |
| `con_*` | Order constructions | Reuse `28` / `12` |
| `boss_*` | Target enemy / brief | Reuse `17` |
| `appt_*` | Mid-chapter appointments | Unchanged; never `boss_client_id` |
| `ask_*` | Adventurer skill | **New** — say so here and in [10](10-catalog-overview.md) |
| `sk_*` | Owner craft skill | Unchanged; not this catalog |

No new harness **person** field. `boss_client_id` = the drawn named `adv_*`. `boss_job_id` = that job. `construction_ids` = that job’s list from `28`.

---

## Draw

**Boss beat stays `28`:** seeded, **independent** of `chapter_boss_id`. Player is the clothier; the drawn adventurer fights the announced boss.

**LOCKED (Jonathan 2026-10-08):** M1 pool = **those 4 jobs**, then one of that job’s 3 named people. `28`’s catalog still lists 8 jobs; the **draw** filters to `M1_JOB_POOL`. Wizard / Hexer / Outrider / Oathbound are **not** drawn in M1.

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
| When | Boss beat (after reserved rounds / final prep) — not chapter-start newspaper |
| What | One `job_*` from the **4-job M1 pool** → one named `adv_*` from that job’s **3** |
| Vs boss | Independent of `chapter_boss_id` |
| Order constructions | Still the **job** list from `28` (not per-person `con_*`) |
| Requirement tags | **Per adventurer** (this catalog) — not the job-row taste in `28` |
| `threat_id` on boss beat | Announced `chapter_boss_id` (`17`, `20`) — catalog `target_threat_id` is the **shop / brief** default, overridden here |
| Repeat | Same job or person may recur (Phase-1) |
| Unique-per-run | Later |
| Shop / walk-in | Draw from the same 12 (or from a job’s 3 when a job is offered). Same constructions + that person’s tags + that person’s `target_threat_id` |
| Wizard / Hexer / Outrider / Oathbound | **Not** in `M1_JOB_POOL` (**LOCKED**). Job stubs in `28` remain for M2. Do not draw; do not stub-fallback |

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

## Roster (12)

Every job: one **monostack** brief, one **cross-tag** brief, one **defensive / neg-avoid** brief. C2 / C3 punish starter tags (**Soft, Earth, Metal, Wild, Silk, Pure** — `17` / `19`). Non-starter briefs go to C2 / C3; one Silk-mid mage vs Ivory Judge is the **starter-tag trap**.

Outlook names / tiers from `14` / `15`. Cross-tags have **no** 3/5/8 power ladder — one chrome (`cross`). Storm / Beastbloom / Snaretooth / Masked Crown / Dawn / Pale Hex are the stamped cross / storm outlook set.

### Knight — `job_knight` · `ord_knight` · `con_armor` + `con_gloves` (gauntlet)

Job-default alias: `adv_knight` → `adv_halden_rook`.

#### `adv_halden_rook` — Ser Halden Rook

Oath steel who still thinks a gorge-wyrm is a siege problem.

| Field | Value |
|---|---|
| id | `adv_halden_rook` |
| Display | Ser Halden Rook |
| Job | Knight (`job_knight`) |
| Build intent | **Monostack** — Metal mid |
| Requirement tags | Metal **mid** (≥5). Sharp welcome, not required |
| `construction_ids` | `con_armor`, `con_gloves` |
| `target_threat_id` | `boss_ash_drake` (C1; favors Metal / Earth / Frost / Pure; punishes Soft, Sticky) |
| Skill | `ask_plate_oath` — **Plate Oath.** If planned Metal ≥ mid, the estimate (and sim) ignores the **first** physical punish chip. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 14 | 4 | 6 | 3 | 2 | 4 |

#### `adv_vex_bramble` — Vex Bramble

Dock-hired plate who wants teeth in the hem, not a church bell.

| Field | Value |
|---|---|
| id | `adv_vex_bramble` |
| Display | Vex Bramble |
| Job | Knight (`job_knight`) |
| Build intent | **Cross-tag** — Snaretooth |
| Requirement tags | Sticky ≥1 ∧ Sharp ≥1 (`syn_sticky_sharp`) |
| `construction_ids` | `con_armor`, `con_gloves` |
| `target_threat_id` | `boss_salt_widow` (C1; favors Frost / Silent / Metal; punishes Soft, Solar) |
| Skill | `ask_thorn_latch` — **Thorn Latch.** If Sticky ∧ Sharp both present, estimate first-ambush **bind + chip** (Snaretooth). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 11 | 6 | 4 | 3 | 5 | 2 |

#### `adv_solenne_ward` — Dame Solenne Ward

Court plate. Soft and scrap-metal read as mud on the tiles — she will not wear a clang.

| Field | Value |
|---|---|
| id | `adv_solenne_ward` |
| Display | Dame Solenne Ward |
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

---

### Mage — `job_mage` · `ord_mage` · `con_robe` + `con_hood`

Job-default alias: `adv_mage` → `adv_quill_lumen`.

#### `adv_quill_lumen` — Quill Lumen

Road scholar. Wants the moon on the hood, not a clean-silk sermon.

| Field | Value |
|---|---|
| id | `adv_quill_lumen` |
| Display | Quill Lumen |
| Job | Mage (`job_mage`) |
| Build intent | **Monostack** — Lunar mid |
| Requirement tags | Lunar **mid** (≥5) |
| `construction_ids` | `con_robe`, `con_hood` |
| `target_threat_id` | `boss_pale_choir` (C2; favors Lunar / Occult / Silent / Frost; punishes Soft / Metal / Silk) |
| Skill | `ask_night_ledger` — **Night Ledger.** If planned Lunar ≥ mid, estimate applies the night / omen bonus; Solar punish is shown. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 9 | 3 | 2 | 6 | 4 | 5 |

#### `adv_neri_paleink` — Neri Pale-Ink

Signs in two inks. The aisle is still in session.

| Field | Value |
|---|---|
| id | `adv_neri_paleink` |
| Display | Neri Pale-Ink |
| Job | Mage (`job_mage`) |
| Build intent | **Cross-tag** — Pale Hex |
| Requirement tags | Lunar ≥1 ∧ Occult ≥1 (`syn_lunar_occult`). **Avoid** Pure (Schism Stitch / Pale Hex Pure risk) |
| `construction_ids` | `con_robe`, `con_hood` |
| `target_threat_id` | `boss_mire_bride` (C2; favors Silent / Occult / Lunar / Sticky; punishes Soft / Pure / Silk) |
| Skill | `ask_pale_signature` — **Pale Signature.** If Lunar ∧ Occult both present, estimate Pale Hex vs the brief; Pure on the bag is a risk flag. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 8 | 4 | 2 | 7 | 3 | 4 |

#### `adv_marrowveil` — Sister Marrowveil

Wants flow and a clean hood. Will not wear a bucket. Ivory still calls silk contempt.

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

---

### Blade Dancer — `job_blade_dancer` · `ord_blade_dancer` · `con_tunic` + `con_cape`

Job-default alias: `adv_blade_dancer` → `adv_kite_thornreel`.

#### `adv_kite_thornreel` — Kite Thornreel

Edge and hem. Wants a choir of cuts, not a quiet bow.

| Field | Value |
|---|---|
| id | `adv_kite_thornreel` |
| Display | Kite Thornreel |
| Job | Blade Dancer (`job_blade_dancer`) |
| Build intent | **Monostack** — Sharp mid |
| Requirement tags | Sharp **mid** (≥5) |
| `construction_ids` | `con_tunic`, `con_cape` |
| `target_threat_id` | `boss_rust_knave` (C1; favors Metal / Earth / Sharp; punishes Soft, Silk) |
| Skill | `ask_edge_count` — **Edge Count.** If planned Sharp ≥ mid, estimate reflect-chip vs physical threats (Razor Choir band). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 10 | 7 | 3 | 2 | 7 | 3 |

#### `adv_mask_circlet` — Mask Circlet

A bow that is also a lie. Court hush, not a dancing bell.

| Field | Value |
|---|---|
| id | `adv_mask_circlet` |
| Display | Mask Circlet |
| Job | Blade Dancer (`job_blade_dancer`) |
| Build intent | **Cross-tag** — Masked Crown |
| Requirement tags | Royal ≥1 ∧ Silent ≥1 (`syn_royal_silent`). **Avoid** Metal (Clanging Hush kills Silent) |
| `construction_ids` | `con_tunic`, `con_cape` |
| `target_threat_id` | `boss_ivory_judge` (C3; favors Royal / Lunar / Silent / Occult) |
| Skill | `ask_incognito_bow` — **Incognito Bow.** If Royal ∧ Silent both present, estimate Masked Crown +PRE on intrigue. Metal on the bag → fail-open (spotted / clang). |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 9 | 5 | 3 | 3 | 6 | 6 |

#### `adv_whisper_hem` — Whisper Hem

Already gone. Soft knives and ringing plate both ruin the act.

| Field | Value |
|---|---|
| id | `adv_whisper_hem` |
| Display | Whisper Hem |
| Job | Blade Dancer (`job_blade_dancer`) |
| Build intent | **Defensive / neg-avoid** — Silent mid; hush must survive |
| Requirement tags | Silent **mid** (≥5). **Avoid** Metal ≥1 (Clanging Hush). **Avoid** Soft ∧ Sharp (Frayed Comfort — tunic is Soft-tagged in `12`, so Sharp dump is the trap) |
| `construction_ids` | `con_tunic`, `con_cape` |
| `target_threat_id` | `boss_bog_king` (C2; favors Frost / Occult / Storm / Silent; punishes Soft / Earth / Metal / Wild) |
| Skill | `ask_hush_check` — **Hush Check.** Silent mid → stealth bonus in the estimate. Any Metal, or Soft ∧ Sharp, marks the hush **spoiled**. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 8 | 4 | 2 | 3 | 8 | 2 |

---

### Lagoon — `job_lagoon` · `ord_lagoon` · `con_cloak` + `con_boots`

Job-default alias: `adv_lagoon` → `adv_tide_glass`. Jonathan-named title. Not Salt Widow. Not an appointment.

#### `adv_tide_glass` — Tide Glass

Tide-hired. Wants the sky in the cloak, not a dry court.

| Field | Value |
|---|---|
| id | `adv_tide_glass` |
| Display | Tide Glass |
| Job | Lagoon (`job_lagoon`) |
| Build intent | **Monostack** — Storm mid |
| Requirement tags | Storm **mid** (≥5) |
| `construction_ids` | `con_cloak`, `con_boots` |
| `target_threat_id` | `boss_bog_king` (C2; favors Frost / Occult / **Storm** / Silent) |
| Skill | `ask_sky_step` — **Sky Step.** If planned Storm ≥ mid, estimate +MOB on first-move; Shock vulnerability is shown. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 11 | 5 | 3 | 5 | 6 | 3 |

#### `adv_brine_latch` — Brine Latch

Steam in the spray. Parade glare wants fire; the lagoon still wants frost in the boot.

| Field | Value |
|---|---|
| id | `adv_brine_latch` |
| Display | Brine Latch |
| Job | Lagoon (`job_lagoon`) |
| Build intent | **Cross-tag** — Temper (Fire ∧ Frost) |
| Requirement tags | Fire ≥1 ∧ Frost ≥1 (`syn_fire_frost_clash`). **Avoid** Soft (Scorched Down if Fire is present) |
| `construction_ids` | `con_cloak`, `con_boots` |
| `target_threat_id` | `boss_sunspear_captain` (C3; favors Solar / Sharp / **Fire** / Royal; punishes Soft / Silk / Pure / Earth) |
| Skill | `ask_temper_brine` — **Temper Brine.** If Fire ∧ Frost both present, estimate Temper (+RES, −HP steam). Soft on the bag with Fire → Scorched Down warning. |

| HP | ATK | DEF | RES | MOB | PRE |
|---:|---:|---:|---:|---:|---:|
| 10 | 6 | 3 | 6 | 5 | 2 |

#### `adv_rime_peddler` — Rime Peddler

Walks docks and mires the same. A cloak that rings like a pot lid is a failed order.

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

---

## Later / M2 jobs (not M1 people)

Rows stay in `28`. No named `adv_*` this stamp. **Not in `M1_JOB_POOL` — LOCKED (Jonathan 2026-10-08).** Do not draw these jobs in M1. Do not fall back to `adv_wizard` / `adv_hexer` / `adv_outrider` / `adv_oathbound` stubs.

| job id | Display | Order constructions | Requirement tags (`28`) |
|---|---|---|---|
| `job_wizard` | Wizard | `con_robe` + `con_mantle` | Occult, Lunar, Royal |
| `job_hexer` | Hexer | `con_wraps` + `con_hood` | Occult, Sticky, Silent |
| `job_outrider` | Outrider | `con_coat` + `con_boots` | Wild, Storm, Silent |
| `job_oathbound` | Oathbound | `con_armor` + `con_mantle` | Royal, Solar, Pure |

When M2 opens them: **3 named adventurers each**, same table shape (mono / cross / neg-avoid). Do not invent people in Client before that Design stamp.

---

## Harness (Test)

Reuse `20` / `28`. **No** new person field.

| Field | M1 value |
|---|---|
| `boss_client_id` | Named `adv_*` from this catalog (never `appt_*`). Job-stub `adv_knight` etc. still **parse** as the job-default alias |
| `boss_job_id` | Matching `job_*` |
| `order_id` | Job-level `ord_*` from `28` |
| `construction_ids` | That job’s list, in sequence |
| `threat_id` | Shop / walk-in: catalog `target_threat_id`. Boss beat: `chapter_boss_id` |
| `chapter_boss_id` / `boss_pool_id` | Unchanged (`17`) |

On `mission_kind=boss`, assert `23` from `20` **plus**: `boss_client_id` is one of the 12 (or a job-default alias); `boss_job_id` matches that person’s job; `construction_ids` still equals the **job** list (not a per-person invention).

Profile unlock save (`unlocked_builds`) is **not** a `20` Required run field — it is meta (Dex Builds tab). Log keys live in [30](30-interactive-order.md) slice 2 and [31-dex](31-dex.md).

---

## Ugly-Client

No portraits, no poster art, no posture sheets this stamp. Names + job + stats + skill line + tag line + `boss_*` brief id are enough. Slice UI: [30](30-interactive-order.md).

---

## Explicit non-goals

- Mass-renaming `boss_client_id` / `cli_*` / historical “client” prose
- Scrap Duelist (or any `appt_*`) as a boss-pool adventurer
- Inventing `con_*` or a fifth M1 job
- Wiring catalog in Client this PR
- Slice 4 battle playback / posture art (`30` Later)
- Named people for Wizard / Hexer / Outrider / Oathbound
- Drawing Wizard / Hexer / Outrider / Oathbound in M1 (or 8-job draw + job-stub fallback) — **LOCKED** out (Jonathan 2026-10-08)

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
