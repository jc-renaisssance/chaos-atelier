# Interactive order — slices 1–3

**Doc id: `30`.** Design only — text-first, ugly-Client friendly. No art dependencies for M1. Grimmjow 2026-10-05. People / jobs / constructions: **[29-adventurer-catalog](29-adventurer-catalog.md)** · **[28-boss-client-pool](28-boss-client-pool.md)**.

**Terminology:** UI / prose says **adventurer**. **Client** = Godot Client seat / codebase. Ids unchanged (`boss_client_id`, `con_*`, `appt_*`, `adv_*`). Scrap Duelist stays `appt_*`.

Slices **1–3** are Design-then-Client (this stamp). Slice **4** is **Later** — one paragraph, no detail.

Numbers below are **test knobs** unless a row says lock.

---

## Where it lives

Extends the craft **upper-left order detail** (`27`) — not a new Godot scene type, not portraits.

```
┌─────────────────────────────────────────────┐
│ Slice 1  Order panel                        │
│   name · job · HP/ATK/DEF/RES/MOB/PRE       │
│   one ask_* line                            │
├─────────────────────────────────────────────┤
│ Slice 2  Syn-target build planner           │
│   unlocked outlook+tier rows · locked = ?   │
├─────────────────────────────────────────────┤
│ Slice 3  Enemy brief (guild-quest poster)   │
│   + estimate / outcome window               │
└─────────────────────────────────────────────┘
```

Ugly UI is correct: labels, buttons, monospace `?`. No poster illustration, no posture sheets.

---

## Slice 1 — Order panel

When an adventurer places an order (walk-in / appointment / boss-beat draw), the panel shows **that person**, not the job stub.

**Show**

| Row | Source |
|---|---|
| Display name + job | `29` |
| Six base stats | `HP` `ATK` `DEF` `RES` `MOB` `PRE` from `29` (knobs) |
| Exactly one skill | `ask_*` name + short mechanical line from `29` |
| Order constructions | `construction_ids` from the job (`28`) — already on the order |
| Requirement-tag taste | That adventurer’s row in `29` (e.g. “Metal mid”) |

Do **not** show portraits. Do **not** show Wizard / Hexer / Outrider / Oathbound people (not in M1).

On the boss beat, the panel is the drawn named `adv_*`; they still fight the **announced** boss (`28` / `17`).

### Client needs

- Bind the panel to `boss_client_id` / order adventurer id (`adv_*` from `29`).
- Render six ints + one skill string. Placeholder labels OK.
- Job-default aliases (`adv_knight` → `adv_halden_rook`, etc.) resolve to the named row so old smokes still have a panel.
- No art assets. No new harness person field.

### Test logs

- `boss_client_id` (named `adv_*` or job-default alias)
- `boss_job_id`
- `construction_ids` (job list, in sequence)
- `adventurer_skill_id` (`ask_*`) — log-only; not a new `20` Required field
- Panel-visible stats object `{HP, ATK, DEF, RES, MOB, PRE}` (the catalog knobs)

---

## Slice 2 — Syn-target build planner

Under the panel, the player plans a **synergy target** for this order. Example: click **Metal** twice = **mid** Metal build (`14` thresholds ≥3 / ≥5 / ≥8 = low / mid / apex).

The planner lists **unlocked** builds. Locked / unknown show as **`?`**. This is the **one new save system** for M1.

### Unlock key (lock)

Unlock key = **synergy outlook + tier**, **not** the finished item and **not** the construction.

Examples: Metal mid · Storm apex · Snaretooth (cross).

| Rule | Law |
|---|---|
| Key shape | `{ outlook_id, tier }` |
| Monostack `outlook_id` | Tag slug: `metal`, `storm`, `lunar`, `royal`, `silk`, `sharp`, `silent`, `frost`, `fire`, … (same vocabulary as `14`) |
| Monostack `tier` | `low` (≥3) · `mid` (≥5) · `apex` (≥8) |
| Cross-tag `outlook_id` | Chrome slug: `snaretooth`, `masked_crown`, `pale_hex`, `temper`, `beastbloom`, `dawn` (Storm monostack stays `storm` + tier; Beastbloom = `syn_wild_earth` / Greenmail) |
| Cross-tag `tier` | `cross` — `14` has **no** 3/5/8 power ladder for cross-tags. Art packs that use `_3/_5/_8` filenames are **not** separate unlock keys unless Jonathan stamps that later |
| Not the garment | Finishing armor-with-Metal-mid and robe-with-Metal-mid is the **same** key `{ outlook_id: "metal", tier: "mid" }` |
| Tiers are separate | Metal low does **not** grant Metal mid. Metal mid does **not** grant Metal low |
| Apex grants below | Reaching **apex** on that outlook also unlocks **low + mid** of the same `outlook_id` |
| What counts | A **piece** is **Finished** (`finish_reason == player_finish`, `27`) **and** that outlook is **active at that tier** (threshold met on that piece at Finish) |
| What does not count | Abandoned / backed-out / never-Finished crafts. Mid-session Current/Potential peek. Stamina 0 without Finish |
| Order outcome | **Does not matter.** Mission win, lose, D/F, or adventurer death still unlocks if Finish happened and the threshold was met |
| Which syns count | **Every** positive monostack / cross-tag whose threshold is met on that piece — not only the winning `outlook_id` for art. Metal 5 + Sharp 3 on one piece → write Metal mid **and** Sharp low |
| Neg syn | `syn_neg_*` does **not** write planner unlocks this stamp (neg outlooks are not M1 planner targets) |
| `plain` | No syn → no unlock |

### Save field (lock)

```
unlocked_builds: { outlook_id: string, tier: "low" | "mid" | "apex" | "cross" }[]
```

| Rule | Law |
|---|---|
| Where | **Meta / profile save** — not run state |
| Across runs | **Persists.** Stamped default = **cross-run** |
| Reset | **Never** on run end, `run_over`, `boss_death`, or new run |
| Fresh profile | `unlocked_builds == []` — planner shows **only `?`** |
| Write time | After each piece stamp from a Finish (N pieces → N chances) |
| Dedup | Union. Re-finishing an already-owned key is a no-op (still log “not new”) |

This is **not** a `20` Required run-identity field. Test still **logs** it (below). Do not invent a second unlock list.

### Planner UX (ugly)

- Click a **tag chip** to set monostack intent: 1 click = low, 2 = mid, 3 = apex (cycle back or stop at apex — Client pick; log the resulting `{outlook_id, tier}`).
- Two different tags that form a `14` cross-tag → plan that `{outlook_id, tier: "cross"}`.
- **Unlocked** rows: show outlook name + tier (e.g. `Metal mid`).
- **Locked** rows: show **`?`**. If the **family** is already known (player owns Metal low but not mid), show `Metal ?` for the missing tiers of that family — do not spoiler unknown families.
- Fresh profile: **only `?`**. The planner still exists so the player can see that unlocks will fill in.
- Planner lists **only** builds that exist in `14` (pos monostack + the six cross-tags). No invented outlooks.

Planned target is **intent** for the estimate (slice 3). It does **not** change `construction_ids` or replace stamina craft. The player still Finishes a real bag; the planner is the brief they are aiming at.

### Client needs

- Persist `unlocked_builds` on the **profile / meta save** (the one new save system). Empty array on new profile.
- On each piece Finish: if threshold met, union the key(s); if apex, also union low + mid of that outlook.
- Do **not** write on abandon. Do **not** clear on run end / death.
- Render unlocked rows; render `?` for locked (see UX). Click-to-tier for tags the player can see.
- No outlook art required — text labels are the M1 surface (extends `27` Potential “locked if not unlocked”).

### Test logs

On **every Finish** (each piece stamp):

| Key | What |
|---|---|
| `unlocked_builds` | Full profile list **after** this Finish |
| `unlocks_new` | Keys newly added this piece (`[]` if none) |
| `planned_build` | `{ outlook_id, tier }` the player had selected, or null |
| `finish_reason` | Must be `player_finish` (`20`) |

**Cross-run persist assertion:** start a second run on the same profile → `unlocked_builds` equals the previous profile snapshot (not `[]`, not run-local). Death / `run_over` between runs must not wipe it. Fresh profile (no prior Finish) → `unlocked_builds == []` and planner is all `?`.

---

## Slice 3 — Enemy brief + estimate window

The adventurer brings a **target-enemy brief** styled like a **guild quest poster** (text / box chrome — no illustration required). Beside / under it: an **estimate / outcome** window for **planned build vs that enemy**.

### Brief (poster)

| Poster line | Source |
|---|---|
| Enemy name | `17` display name for `threat_id` |
| Environment one-liner | `17` Environment column |
| Flavor | Short quest line (Client may use `17` prose) |
| Favor / punish | From `17` — **shown** if that tag-axis is unlocked knowledge (see below); else `?` |

`threat_id`:

- Shop / walk-in / appointment: catalog `target_threat_id` (`29`)
- Boss beat: announced `chapter_boss_id` (`28` / `20`) — the poster is whoever the newspaper named, **not** the catalog default

### What the estimate shows

Extends Current / Potential (`27`): unlocked info shown; locked / unknown = **`?`**.

| Line | Unlocked | Locked |
|---|---|---|
| Planned outlook + tier | Name | `?` |
| Favor tags hit | Tag list | `?` |
| Punish tags hit | Tag list | `?` |
| Skill proc (`ask_*`) | Fires / does not, + one clause | `?` |
| Neg-syn warning | Named `syn_neg_*` if the planned bag would fire it | `?` |
| Letter band | `S\|A\|B\|C\|D\|F` (knob bands) | `?` |

**Unlocked knowledge** for a line = the player owns the `unlocked_builds` key that justifies it (the planned outlook+tier, or a family already known for that tag). Fresh profile → poster name / environment may still show (the adventurer handed you the paper); mechanical favor / punish / band / skill = `?`.

### Deterministic estimate (ugly-Client)

Client can implement this with ints and tag-set hits. **No** animation, **no** RNG. Same inputs as the mission resolver spine, **planned** tags instead of a finished bag when the player is still aiming.

```
# knobs — not a hard lock
FAVOR_W  = 2
PUNISH_W = 3
SKILL_W  = 2
NEG_W    = 3
STAT_W   = 1   # applied to (ATK + DEF + RES) / 3, floored

function planned_tags(planned_build):
  # monostack mid Metal → { Metal: 5 }  (use tier minimum: low 3, mid 5, apex 8)
  # cross Snaretooth    → { Sticky: 1, Sharp: 1 }
  # plus construction tags from construction_ids (12) so hood+Metal can warn Bucket Head

function estimate(adventurer, planned_build, enemy):
  tags = planned_tags(planned_build)
  score  = floor( (adventurer.ATK + adventurer.DEF + adventurer.RES) / 3 ) * STAT_W
  score += count_hits(tags, enemy.favors)  * FAVOR_W
  score -= count_hits(tags, enemy.punishes) * PUNISH_W
  if adventurer.skill_condition_met(tags, enemy):
    score += SKILL_W
  if would_fire_syn_neg(tags, construction_ids) and rarity_would_not_skip:
    score -= NEG_W
  band = letter_from_score(score)   # knob table below
  return { score, band, favor_hits, punish_hits, skill_fired, neg_warnings }
```

| Score (knob) | Band |
|---:|---|
| ≥ 10 | S |
| ≥ 7 | A |
| ≥ 4 | B |
| ≥ 1 | C |
| ≥ −2 | D |
| else | F |

C2 / C3 **punish starter tags**. A Metal-mid plan vs `boss_gilded_warden` **must** subtract `PUNISH_W` (Metal ∈ punishes). A Silk-mid plan vs `boss_ivory_judge` same. The estimate is how M1 teaches that — once those keys are unlocked. Until then the punish line is `?`.

This estimate is a **prediction window**, not the live resolver. After Finish, `20` / `23` remain the real stamp (`rating`, `favor_tags_hit`, `punish_tags_hit`, `cleared`, …). Do not assert estimate band == post-sim `rating` this stamp (bags ≠ planned chips).

### Client needs

- Poster block: enemy display name + environment string + `?` for locked favor / punish.
- `threat_id` = catalog target on shop orders; `chapter_boss_id` on the boss beat.
- Run the estimate from **adventurer stats + skill + planned tags + construction tags** vs `17` favor / punish. Deterministic, no RNG, no art.
- Gate mechanical lines on `unlocked_builds`. Show `?` otherwise.
- Ugly labels OK. Do not wait on poster illustration.

### Test logs

| Key | What |
|---|---|
| `threat_id` | Brief enemy (`boss_*`) |
| `planned_build` | `{ outlook_id, tier }` or null |
| `estimate_band` | `S\|A\|B\|C\|D\|F` or `?` if locked |
| `estimate_favor_hits` | string[] or `?` |
| `estimate_punish_hits` | string[] or `?` |
| `estimate_skill_fired` | bool or `?` |
| `estimate_neg_warnings` | `syn_neg_*`[] or `?` |
| `unlocked_builds` | Profile list used to gate `?` |

On boss beat: `threat_id == chapter_boss_id` (`20` assert 23) even if the catalog default was a different `boss_*`.

---

## Slice 4 — Later (no detail)

After Finish: a simple **animated battle playback** driven by the mission resolver, then the **mission report** (`23`). Adventurer **posture** slots (in-shop / in-fight / ult / defend / attack) wait for Jonathan to open the art lane for M1 or defer them to M2. Not a Client pickup this stamp.

---

## Explicit non-goals

- Portraits, poster illustration, posture sheets
- Per-item or per-`con_*` unlock keys
- Wiping `unlocked_builds` on death / run end (unless Jonathan overrides the confirmation Q)
- Estimate as a `20` Required substitute for the real resolver
- Slice 4 implementation
- Shop-event systems (still required for M1 “full experience” per PM — not this doc)

---

## Pointers

- Catalog: [29-adventurer-catalog](29-adventurer-catalog.md)
- Jobs / constructions: [28-boss-client-pool](28-boss-client-pool.md)
- Synergy thresholds / cross-tags / neg: [14-synergies](14-synergies.md)
- Outlook ids: [15-outlook-gen-list](15-outlook-gen-list.md)
- Craft Finish / Current+Potential: [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Harness: [20-harness-stamp](20-harness-stamp.md)
- Mission report: [23-mission-report](23-mission-report.md)
- Boss favor / punish: [17-chapter-bosses](17-chapter-bosses.md)
- PM slices: [pm/phase-1-plan](pm/phase-1-plan.md)
