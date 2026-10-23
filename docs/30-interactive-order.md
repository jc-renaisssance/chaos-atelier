# Interactive order — slices 1–4

**Doc id: `30`.** Design only — text-first, ugly-Client friendly. No art dependencies for M1. Grimmjow 2026-10-05. **Estimate S–F bands stay Test knobs — LOCKED leave-as-knobs (Jonathan 2026-10-08).** People / jobs / constructions: **[29-adventurer-catalog](29-adventurer-catalog.md)** · **[28-boss-client-pool](28-boss-client-pool.md)**.

**Terminology:** UI / prose says **adventurer**. **Client** = Godot Client seat / codebase. Ids unchanged (`boss_client_id`, `con_*`, `appt_*`, `adv_*`). Scrap Duelist stays `appt_*`.

Slices **1–3** are **LOCKED** (Design-then-Client, on `dev`). Slice **4** **Client shipped** (docs #69 / Client #70) — battle playback + posture sockets. Gate **A**, Surface **A**, Socket **A**. Sockets shipped. Posture art stays **Later** (**Nov 2**). The letter tables below are the law. Do not reopen playback.

**Shell (2026-10-23):** player chrome for slices 1–3, and the playback frame, is [34](34-ui-shell-v1.md) (**shipped**, Design #76 / Client #77, stamp **A A B**). Slice rules, unlock, estimate knobs, and Gate / Surface / Socket **A** do not move. Bust **A** supersedes this file’s “do not show portraits” line on the order panel only. Planner chips are text (letter **B** interim). Icon chips stay Later.

Numbers below are **test knobs** unless a row says lock. **Cross-run `unlocked_builds` is LOCKED** (Jonathan 2026-10-05). **S–F estimate letter bands stay Test knobs** — **LOCKED leave-as-knobs** (Jonathan 2026-10-08); do **not** lock the cutoff table. Closes PR #28 open question 2. Dex: [31-dex](31-dex.md).

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

Ugly UI is correct for slices 1–3: labels, buttons, monospace `?`. No poster illustration. Slice 4 is not a fourth block on this panel. It runs after Finish, then the mission report (`23`). Posture stills belong to that step only.

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

Do **not** show portraits, except the order-panel bust under shell letter **A** ([34](34-ui-shell-v1.md), shipped #77). Do **not** show Wizard / Hexer / Outrider / Oathbound people (not in M1).

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

The planner lists **unlocked** builds. Locked / unknown show as **`?`**. Builds data **is** `unlocked_builds` — the Dex Builds tab ([31-dex](31-dex.md)) **reads** the same field. Do not keep a second list.

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
| Where | **Meta / profile save** — not run state. Same layer as the Dex (`31`) |
| Across runs | **LOCKED** (Jonathan 2026-10-05). Cross-run. Confirmed — not an open question |
| Reset | **Never** on run end, `run_over`, `boss_death`, or new run |
| Fresh profile | `unlocked_builds == []` — planner shows **only `?`** |
| Write time | After each piece stamp from a Finish (N pieces → N chances) |
| Dedup | Union. Re-finishing an already-owned key is a no-op (still log “not new”) |

This is **not** a `20` Required run-identity field. Test still **logs** it (below). Do not invent a second unlock list. Dex Crafts / Adventurers / Enemies are sibling fields on this same save (`31`) — they are **not** a copy of `unlocked_builds`.

### Planner UX (ugly)

- Click a **tag chip** to set monostack intent: 1 click = low, 2 = mid, 3 = apex (cycle back or stop at apex — Client pick; log the resulting `{outlook_id, tier}`).
- Two different tags that form a `14` cross-tag → plan that `{outlook_id, tier: "cross"}`.
- **Unlocked** rows: show outlook name + tier (e.g. `Metal mid`).
- **Locked** rows: show **`?`**. If the **family** is already known (player owns Metal low but not mid), show `Metal ?` for the missing tiers of that family — do not spoiler unknown families.
- Fresh profile: **only `?`**. The planner still exists so the player can see that unlocks will fill in.
- Planner lists **only** builds that exist in `14` (pos monostack + the six cross-tags). No invented outlooks.

Planned target is **intent** for the estimate (slice 3). It does **not** change `construction_ids` or replace stamina craft. The player still Finishes a real bag; the planner is the brief they are aiming at.

### Client needs

- Persist `unlocked_builds` on the **profile / meta save** (Dex layer, `31`). Empty array on new profile.
- On each piece Finish: if threshold met, union the key(s); if apex, also union low + mid of that outlook. Also write `dex_crafts` (`31`) — do **not** duplicate Builds into another builds array.
- Do **not** write on abandon. Do **not** clear on run end / death. **LOCKED** cross-run.
- Render unlocked rows from `unlocked_builds`; render `?` for locked (see UX). Click-to-tier for tags the player can see.
- No outlook art required — text labels are the M1 surface (extends `27` Potential “locked if not unlocked”).

### Test logs

On **every Finish** (each piece stamp):

| Key | What |
|---|---|
| `unlocked_builds` | Full profile list **after** this Finish |
| `unlocks_new` | Keys newly added this piece (`[]` if none) |
| `planned_build` | `{ outlook_id, tier }` the player had selected, or null |
| `finish_reason` | Must be `player_finish` (`20`) |

**Cross-run persist assertion (LOCKED):** start a second run on the same profile → `unlocked_builds` equals the previous profile snapshot (not `[]`, not run-local). Death / `run_over` between runs must not wipe it. Fresh profile (no prior Finish) → `unlocked_builds == []` and planner is all `?`. Same persist law as the rest of the Dex (`31`).

---

## Slice 3 — Enemy brief + estimate window

The adventurer brings a **target-enemy brief** styled like a **guild quest poster** (text / box chrome — no illustration required). Beside / under it: an **estimate / outcome** window for **planned build vs that enemy**.

### Brief (poster)

| Poster line | Source |
|---|---|
| Enemy name | `17` display name for `threat_id` |
| Environment one-liner | `17` Environment column |
| Flavor | Short quest line (Client may use `17` prose) |
| Favor / punish | From `17` — **shown only if** `dex_enemies[threat_id].fought` ([31](31-dex.md)); else `?` |

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
| Letter band | `S\|A\|B\|C\|D\|F` (Test knobs — **not** a locked cutoff table) | `?` |

**Source of truth = Dex (`31`).** Do not invent a second reveal flag.

| Line | Reveals when |
|---|---|
| Planned outlook + tier | `{outlook_id, tier}` ∈ `unlocked_builds` |
| Poster name / environment | `dex_enemies[threat_id].seen` (showing the brief **writes** seen, then shows the name) |
| Favor / punish hits | `dex_enemies[threat_id].fought` — **not** gated on Builds |
| Letter band | **fought** (band uses favor / punish) |
| Skill / neg-syn (build-side) | Relevant Builds key unlocked |

Fresh profile → first brief can show the name (now `seen`); favor / punish / band stay `?` until a **boss-beat fight**.

### Deterministic estimate (ugly-Client)

Client can implement this with ints and tag-set hits. **No** animation, **no** RNG. Same inputs as the mission resolver spine, **planned** tags instead of a finished bag when the player is still aiming.

```
# Test knobs — not a hard lock (weights + S–F cutoffs)
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
  band = letter_from_score(score)   # Test-knob table below — not a lock
  return { score, band, favor_hits, punish_hits, skill_fired, neg_warnings }
```

**Letter bands — Test knobs (LOCKED leave-as-knobs, Jonathan 2026-10-08).** Do **not** lock this cutoff table for the first Client wire. Ulquiorra uses the working cutoffs; Jonathan / Test may retune. Closes PR #28 open question 2.

Working cutoffs (tunable):

| Score (Test knob) | Band |
|---:|---|
| ≥ 10 | S |
| ≥ 7 | A |
| ≥ 4 | B |
| ≥ 1 | C |
| ≥ −2 | D |
| else | F |

C2 / C3 **punish starter tags**. A Metal-mid plan vs `boss_gilded_warden` **must** subtract `PUNISH_W` (Metal ∈ punishes) in the **internal** score. A Silk-mid plan vs `boss_ivory_judge` same. The **displayed** punish line and band stay `?` until that enemy is **fought** (`31`). After `fought`, the Dex reveals the tags and the estimate can show the hits.

This estimate is a **prediction window**, not the live resolver. After Finish, `20` / `23` remain the real stamp (`rating`, `favor_tags_hit`, `punish_tags_hit`, `cleared`, …). Do not assert estimate band == post-sim `rating` this stamp (bags ≠ planned chips).

### Client needs

- Poster block: name / environment from Dex `seen`; favor / punish from Dex `fought` (`31`). Showing the brief writes `seen`.
- `threat_id` = catalog target on shop orders; `chapter_boss_id` on the boss beat.
- Run the estimate from **adventurer stats + skill + planned tags + construction tags** vs `17` favor / punish. Deterministic, no RNG, no art.
- Gate outlook lines on `unlocked_builds`. Gate enemy tags / band on `dex_enemies.fought`. Show `?` otherwise.
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
| `unlocked_builds` | Profile Builds list — gates outlook `?` |
| `dex_enemies` | `seen` / `fought` for this `threat_id` — gates tag / band `?` (`31`) |

On boss beat: `threat_id == chapter_boss_id` (`20` assert 23) even if the catalog default was a different `boss_*`.

---

## Slice 4 — Battle playback + posture (2026-10-21)

**Status:** **Closed** on the Client (docs #69 / Client #70, `f083b09`). Sockets shipped (placeholders). Posture art **Later** — **Nov 2**. Not an open Design. Slices **1–3** stay locked (unlock key, cross-run `unlocked_builds`, estimate weights, S–F cutoffs). This section does not retune stats or events.

**Law (Client #70: Gate A, Surface A, Socket A).** Posture art stays **Nov 2**. Other letters stay on the [STAMP](STAMP.md) card as the ask. Do not reopen playback.

After a player **Finish** that already runs the mission resolver, Client plays a short deterministic timeline, then shows the mission report ([23](23-mission-report.md)). The timeline displays the stamp the resolver just returned. It does not run a second fight.

### Playback gate — A, B, or C

| Letter | When it plays | Skip |
|---|---|---|
| **A (Design default)** | One playback **per piece stamp** from a `player_finish`, in listed order, on the beats that already call the mission resolver: order delivery (`day_action=adventurer`), appointment, and boss beat. Then **that piece’s** report (`23`). The next piece, if any, plays after that report closes. | Skip ends **this** playback and opens **this** piece’s report. It does not skip the report. It does not skip later pieces. |
| **B** | One playback for the whole Finish, after all N piece stamps exist, then the N reports in order. | Skip opens the first report. |
| **C** | No playback. Finish goes to the report as it does today. | — |

Write **A**, **B**, or **C**. Silence is not **A**. Design recommends **A**.

These exits do **not** play under A or B: stamina 0 without Finish, abort / back-out / any exit that is not `player_finish`, `cant_craft` (no session — the F row goes straight to the report), market visit, event text-resolve. An empty zone at Finish **does** play. The resolver already runs on that construction-only stamp (`27`).

Under Gate **A**, playback inserts after the resolver returns for that piece and before that piece’s report. Under Gate **B**, it inserts once, after the last piece stamp and before the first report. Reps, newspaper, and day advance stay in the order the Client already uses. Playback does not call the resolver again.

### Playback surface — A, B, or C

| Letter | What the player sees |
|---|---|
| **A (Design default)** | Ugly beat rows plus a placeholder actor in the posture slot for that beat. No new combat sim. |
| **B** | The same beat rows, text only. No actor slot. No posture file is read. |
| **C** | Hold the surface until posture files exist. Finish stays report-only until then. |

Write **A**, **B**, or **C**. Silence is not **A**. Design recommends **A**. **C** blocks Client on art. Decision 4 can still park the gens while Surface **A** ships placeholders.

### Beat list (Gate A or B, and Surface A or B)

Pure function of the piece stamp. No RNG. The same stamp produces the same rows. Do not roll hits, crits, or frame variants. Do not tween `hp_remaining`. Do not add a beat for `powers_negative`, `damage_aid_pct`, or `rating_score`. Those stay on the report. Beat length is a Client constant. Do not stamp a duration.

The estimate’s `?` gate (slice 3, until `fought`) does **not** apply here. Playback is the result. It shows the same `favor_tags_hit` / `punish_tags_hit` the report will show.

Actor id = the order’s named `adv_*` (`boss_client_id` / the adventurer on the order), after the job-alias resolve in slice 1. When the person is `appt_*` (C1 N5 `appt_scrap_duelist`), actor id is **null**. The rows still play. This stamp does **not** open an `appt_*` socket and does **not** gen Scrap Duelist.

Enemy is a **label** (`threat_id`; boss beat uses `chapter_boss_id`). Display name follows the poster rule in slice 3 (`seen` → name, else `?`). No enemy posture. No `boss_*` file under `assets/adv/posture/`. The landed Dex icon is not required on this surface.

| Order | Beat id | Slot | When | Label |
|---|---|---|---|---|
| 1 | `open` | `in_fight` | Always | Actor id (or the `appt_*` id). Threat label. |
| 2.. | `favor:<tag>` | `attack` | One per `favor_tags_hit`, resolver order. No sort. No dedupe. | The tag |
| .. | `punish:<tag>` | `defend` | One per `punish_tags_hit`, after the favors. Same order rules. | The tag |
| next | `skill` | `ult` | Always one | `ask_*` id from the order, plus `skill_effectiveness` (1..5). Missing star → `?`. Not a cutoff. |
| last | `result` | `in_fight` if `cleared`, else `defend` | Always | `rating`, `outcome`, `hp_remaining` as text |

`in_shop` is not a beat.

Surface **A** draws the row and an actor texture. Surface **B** draws the row only.

Gate **A** builds this list once per piece. Gate **B** concatenates those lists in `piece_index` order into the single playback, then shows the reports. Each row keeps its piece index in the log.

### Posture socket — A, B, or C

Five slots, the set the Later stub named: `in_shop`, `in_fight`, `ult`, `defend`, `attack`.

| Letter | Files | Canvas |
|---|---|---|
| **A (Design default)** | One still per slot. `assets/adv/posture/<adv_id>_<slot>.png`. Wire `res://assets/adv/posture/<adv_id>_<slot>.png`. | Pro Flash **64×64 soft-stipple**, one frame, full figure, transparent ground. |
| **B** | One sheet per adventurer. `assets/adv/posture/<adv_id>.png`. Five **64×64** cells, left to right, in the slot order above. | Same grain. A missing sheet hides all five. |
| **C** | No socket. No path. | None. Surface **A** uses code placeholders only. Surface **B** does not read files. |

Write **A**, **B**, or **C**. Silence is not **A**. Design recommends **A**. A different size (48 or 96) is a **rewrite of A**: name it on the line. Silence does not pick 64, and it does not pick 96.

**Why 64.** Portraits stay the landed **96×96** bust (`assets/adv/<adv_id>.png`, head and shoulders). Kind chips and the elite mark are **48×48** seals. A posture is a stance. At 48 the limbs sit inside soft-stipple grain, and a guard does not separate from a strike. At 96 the file is a second bust wave and the crop is a head, not a body. 64 is the next power-of-two above the chip: five stills are not a portrait redo, and the five stances can still be told apart. Nearest filter. Client may show the cell at 64 or at integer 2×. Do not scale the 96 bust into a slot. Do not crop a portrait into a posture.

**Pipeline.** PixelLab stays **stills-only**. One frame. Do not call `animate_*`. This PR does not ask for in-betweens. If a later stamp wants motion, it is Aseprite hand-keys into Godot `SpriteFrames`, using these stills as the keys. No Aseprite file in this PR.

| Slot | Where it shows | Stance |
|---|---|---|
| `in_shop` | Order panel (slice 1) and a walk-in surface that already shows that person ([29](29-adventurer-catalog.md)). Beside the 96 bust, not instead of it. Not on the route node, not on Dex, not in the newspaper. | Standing, weapon lowered |
| `in_fight` | Playback `open`, and `result` when `cleared` | Ready guard |
| `ult` | Playback `skill` | One committed pose for the `ask_*`. No VFX sheet |
| `defend` | Playback `punish`, and `result` when not `cleared` | Braced, body behind the weapon |
| `attack` | Playback `favor` | Strike at extension |

Job aliases do not get files. Resolve to the named row, same as portraits (`adv_knight` → `adv_halden_rook`, and the other aliases in [29](29-adventurer-catalog.md)).

**Missing file.** Client must not crash.

- `in_shop`: hide that slot. Bust and text stay.
- Playback, Surface **A**: the beat row still draws. A missing png uses a code-drawn flat placeholder (the slot name as text) so the stage is readable before any art. If a texture load fails, use a **1×1** stand-in and keep the row. Do not substitute `assets/adv/<adv_id>.png`.
- Socket **B**: a missing sheet hides all five on the panel. Playback uses the same placeholder / 1×1 rule.
- Socket **C**: nothing to load.

### Posture art — A or B

This PR stamps the socket and the playback law only. It does not gen.

| Letter | Gens |
|---|---|
| **A (now)** | After Jonathan stamps this card, Ulquiorra wires placeholders **first** and does not wait on files. Then Harribel soft-gate, then Nnoitra stills. Wave = the **12 M1** named `adv_*` only, five slots each (60 files). The M2 twelve stay on the placeholder rule until a later art stamp. No portrait regen. No `appt_*`. No enemy postures. No #62 revival. |
| **B (Later) (Design default)** | No gen on this queue item. The socket law still stands if Decision 3 is A or B. Client ships the placeholder / hide / 1×1 rules. |

Write **A** or **B**. Silence is not **B**. Design recommends **B**. Client may ship placeholders either way. Writing **B** does not block the Client wire. Writing **A** does not pull gens ahead of that wire. If Decision 3 is **C**, there are no files to gen — write art **B**.

Stance lines above are the socket contract. They are not a PixelLab prompt batch. A gen PR, if art is **A**, still passes Harribel before any burn. Subject of each still is that named person from the landed bust, full figure at 64, transparent ground, no text, no card frame, no second face.

### Client needs

- Gate **A**: on `player_finish` for an adventurer order, an appointment, and a boss beat, build the beat list per piece stamp, show the surface, then the existing report, in listed order. Gate **B**: one show, then the reports. Gate **C**: report only.
- A `Skip` control on the playback. Behavior is the gate table.
- Do not play on `cant_craft`, a market visit, an event, or any exit that is not `player_finish`.
- Surface **A** with Socket **A**: load `res://assets/adv/posture/<adv_id>_<slot>.png`. Honor the missing-file rules. Nearest filter.
- Do not add a scene type. This is a step between craft Finish and the report the Client already shows.
- Do not change the slice 1–3 unlock rules or the estimate cutoff table.
- No new [20](20-harness-stamp.md) Required field.
- A smoke with **zero** posture files must pass: rows show, `in_shop` stays hidden, nothing crashes.

### Test logs

Log-only. Not a `20` Required column. No new assert number under the Design default.

| Key | What |
|---|---|
| `playback_played` | bool — true when a playback was shown for this piece |
| `playback_skipped` | bool — true when Skip fired before the last beat |
| `playback_beats` | string[] — beat ids in order (`open`, `favor:<tag>`, `punish:<tag>`, `skill`, `result`) |
| `playback_actor_id` | `adv_*` or null |
| `piece_index` | which stamp this playback read |

`cant_craft`, market, and event stamps log `playback_played=false` and `playback_beats=[]`. Under Gate **B**, one Skip sets `playback_skipped=true` on every piece in that Finish.

### Explicit non-goals (this slice)

- A second combat sim, an HP tween, or RNG in the playback layer
- Locking S–F cutoffs or estimate weights (slices 1–3 stay as stamped)
- A stat / event retune
- Portrait regen, a #62 revival, Scrap Duelist postures, enemy posture sheets
- PixelLab `animate_*`, Aseprite files, or Godot `src/` in this PR
- A new Required `20` key
- `in_shop` on the route graph or the Dex row

---

## Explicit non-goals

- Poster illustration on the slice 3 brief
- Portrait regen, or posture stills inside slices 1–3 (the socket is slice 4)
- Per-item or per-`con_*` unlock keys
- Wiping `unlocked_builds` or the Dex on death / run end (**LOCKED** cross-run)
- Estimate as a `20` Required substitute for the real resolver
- Locking the S–F cutoff table (or `FAVOR_W` / `PUNISH_W`) — they stay Test knobs
- Slice 4 as a new combat sim (it displays the resolver stamp)
- Shop-event systems (market + events live in `32` — not this doc)
- Gens, Client, or Godot in this Design PR

---

## Pointers

- Dex (profile collection; `?` source of truth): [31-dex](31-dex.md)
- Catalog: [29-adventurer-catalog](29-adventurer-catalog.md)
- Jobs / constructions: [28-boss-client-pool](28-boss-client-pool.md)
- Synergy thresholds / cross-tags / neg: [14-synergies](14-synergies.md)
- Outlook ids: [15-outlook-gen-list](15-outlook-gen-list.md)
- Craft Finish / Current+Potential: [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Harness: [20-harness-stamp](20-harness-stamp.md)
- Mission report: [23-mission-report](23-mission-report.md)
- Art grain / posture pipeline: [05-art](05-art.md)
- Boss favor / punish: [17-chapter-bosses](17-chapter-bosses.md)
- PM slices: [pm/phase-1-plan](pm/phase-1-plan.md)
