# Dex (M1 collection record)

**Doc id: `31`.** Design only — no Client / Godot / art this stamp. Grimmjow 2026-10-05. Jonathan: *“something like the craft dex for recording all crafts and enemy and adventurers unlocked etc.”*

**Terminology:** UI / prose says **adventurer**. **Client** = Godot Client seat / codebase. Ids unchanged (`adv_*`, `con_*`, `boss_*`, `appt_*`, `boss_client_id`). Scrap Duelist stays `appt_*`. Do not mass-rename.

The Dex is the **profile-level, cross-run** collection record. It is the same save layer as `unlocked_builds` ([30](30-interactive-order.md) slice 2). Slice 2 / 3 `?` rules **read the Dex** — one source of truth.

Art + lore blurbs = **Later / M2**. M1 is an ugly list / grid.

---

## Law (lock)

| Rule | Value |
|---|---|
| Where | **Meta / profile save** — not run state |
| Across runs | **LOCKED** (Jonathan 2026-10-05). Same lock as `unlocked_builds` |
| Reset | **Never** on run end, `run_over`, `boss_death`, or new run |
| Fresh profile | Every tab is **all `?`**. Lists below are empty |
| Day clock (knob) | `profile_day` — int, starts **1** on first run start, **+1 per new run**. M1 stand-in for “day.” Do not invent a calendar |

Not a `20` Required run-identity field. Test **logs** the Dex (below).

---

## Tabs (M1)

Ugly-Client: one **plain list / grid** screen, reachable from the **shop / menu**. Four tabs. No portraits, no poster art, no lore pages.

| Tab | What it shows | Save field | Do not |
|---|---|---|---|
| **Builds** | Outlook + tier unlocked | **`unlocked_builds`** — **this is the data.** Dex **reads** it | Do not copy into a second list |
| **Crafts** | Finished pieces: `con_*` × outlook-tier + first-finish run / day | `dex_crafts` | Do not treat this as the Builds unlock |
| **Adventurers** | Named `adv_*` met (order received) + optional completed count | `dex_adventurers` | Do not use `appt_*` / Scrap Duelist here (Later) |
| **Enemies** | `boss_*` / threat ids: seen vs fought | `dex_enemies` | Do not show favor / punish until **fought** |

Unknown / unmet rows render as **`?`**. Do not spoiler names of never-met adventurers or never-seen enemies. Known families with a missing tier (Builds) may show `Metal ?` per [30](30-interactive-order.md).

---

## Builds tab = `unlocked_builds`

Law lives in [30](30-interactive-order.md) slice 2. **Do not duplicate.**

```
unlocked_builds: { outlook_id: string, tier: "low" | "mid" | "apex" | "cross" }[]
```

| Trigger | Write |
|---|---|
| Piece **Finished** (`player_finish`) and that outlook **tier is active** (threshold met) | Union `{outlook_id, tier}` |
| Apex met | Also union **low + mid** of that outlook |
| Abandon / stamina 0 without Finish | No write |
| Order win / lose / death | Does **not** matter — Finish + threshold is enough |

Dex Builds tab **lists** `unlocked_builds`. Slice 2 planner **lists** the same field. One write path (Finish).

---

## Crafts — `dex_crafts`

Record the **first** time each **`con_*` × outlook-tier** combo is Finished. This is **not** `unlocked_builds` (that key ignores construction). Armor-Metal-mid and robe-Metal-mid are **two** craft rows and **one** Builds key.

```
dex_crafts: {
  construction_id: string,   # con_*
  outlook_id: string,        # metal | storm | snaretooth | plain | …
  tier: "low" | "mid" | "apex" | "cross" | "base",
  first_run_id: string,      # run_id from the Finish stamp (20)
  first_day: int             # profile_day at first Finish
}[]
```

| Trigger | Write |
|---|---|
| Piece Finished and outlook-tier **threshold met** on that piece | If the pair `(construction_id, outlook_id, tier)` is new → append with `first_run_id` / `first_day`. Else no-op (keep first) |
| Every met tier on that piece | Metal 8 on `con_armor` writes armor×metal **low, mid, and apex** (thresholds all met) |
| Every met outlook on that piece | Metal mid + Sharp low on one hood → two (or more) rows |
| No positive syn (`plain`) | Write `{ construction_id, outlook_id: "plain", tier: "base", … }` once per `con_*` |
| Abandon | No write |
| Order outcome | Does not matter |

`tier: "base"` is **only** for `plain`. Cross-tags use `tier: "cross"` as in `30`.

---

## Adventurers — `dex_adventurers`

```
dex_adventurers: {
  adventurer_id: string,     # named adv_* from 29
  met: bool,
  orders_received: int,
  orders_completed: int      # stamped so Test has a field; increment is optional-feeling but defined
}[]
```

| Trigger | Write |
|---|---|
| **Met / order received** | First time this `adv_*` **places an order** (walk-in, appointment-as-adventurer, or boss-beat draw) — slice 1 panel opens. Set `met = true`, `orders_received += 1` (first time: insert row, received = 1) |
| Job-stub alias | `adv_knight` etc. **resolve** to the named default (`29`) before the key — do not store the stub as a person |
| **Completed** | After that order’s craft session **Finish** (mission may then win or lose). `orders_completed += 1` |
| Decline / abandon / never opened the panel | No `met`. No completed bump |
| Scrap Duelist / `appt_*` | **Not** this tab in M1 |

Fresh profile: list empty → Adventurers tab is all `?` (12 unknown slots, no names). Once met, show display name + job + received / completed counts.

---

## Enemies — `dex_enemies`

M1 enemy types = the **9** `boss_*` in [17](17-chapter-bosses.md).

```
dex_enemies: {
  threat_id: string,         # boss_*
  seen: bool,
  fought: bool,
  briefs_seen: int,
  fights: int
}[]
```

| Flag | Trigger |
|---|---|
| **`seen`** | Encountered via **brief** (slice 3 guild-quest poster shown for that `threat_id`) **or** kingdom newspaper announces that `chapter_boss_id` (`26`). `briefs_seen += 1` on each brief show; newspaper announce sets `seen` once (count bump optional — Test: `seen == true`) |
| **`fought`** | **Boss beat** mission resolved against that id (`mission_kind=boss`, `threat_id` / `chapter_boss_id` match) — win, lose, death, or `cant_craft`. `fights += 1`. Shop / walk-in briefs do **not** set `fought` |

| UI | When |
|---|---|
| Name + environment | `seen` — else `?` |
| Favor / punish tags (`17`) | **`fought` only** — else `?` |
| Fight / brief counts | When `seen` or `fought` |

Shop brief for `target_threat_id` (`29`) sets **seen**, not fought. Boss beat sets **fought** (and seen if somehow missed).

---

## Slice 2 / 3 `?` — one source of truth

| Surface | Shows real text when | Else |
|---|---|---|
| Slice 2 planner row (outlook + tier) | `{outlook_id, tier}` ∈ `unlocked_builds` | `?` |
| Slice 3 planned-outlook name | same Builds key | `?` |
| Slice 3 poster name / environment | `dex_enemies[threat_id].seen` (showing the brief **writes** seen, then shows the name) | `?` |
| Slice 3 favor / punish (poster + estimate hits) | `dex_enemies[threat_id].fought` | `?` |
| Slice 3 estimate band | **fought** (band uses favor / punish) | `?` |
| Slice 3 skill / neg-syn (build-side) | Relevant Builds key unlocked | `?` |

Do **not** gate enemy favor / punish on `unlocked_builds`. **Fought** is the tag reveal. Builds unlock is the outlook reveal.

Fresh profile: first brief writes `seen` and can show the name; tags and band stay `?` until a boss-beat fight.

---

## Ugly-Client (M1)

- One screen: tab strip **Builds | Crafts | Adventurers | Enemies** + a scroll list or small grid.
- Reachable from shop / menu (one button). No art assets. `?` for locked rows.
- Builds rows = outlook name + tier (text).
- Crafts rows = construction display name + outlook/tier + `first_day` / run id (debug-ok).
- Adventurers rows = name + job + received / completed (once met).
- Enemies rows = name (if seen) + seen/fought + tags only if fought.
- **Later / M2:** art, lore entries, full Fashion Encyclopedia chrome (`04`).

---

## Client needs

- Persist `unlocked_builds`, `dex_crafts`, `dex_adventurers`, `dex_enemies` on the **same profile / meta save**. Fresh profile = all empty → UI all `?`.
- **Never** clear on run end / death / `run_over`.
- **One write path** for Builds: Finish + threshold → `unlocked_builds`. Dex Builds tab only reads it.
- On each piece Finish: also union `dex_crafts` for each `con_*` × met outlook-tier (and `plain`/`base` if none).
- On order panel open: upsert `dex_adventurers` (`met`, `orders_received++`). On that order’s Finish: `orders_completed++`. Resolve job-stubs to named `adv_*`.
- On slice 3 brief show or newspaper announce: upsert `dex_enemies.seen`. On boss-beat resolve: set `fought`, `fights++`.
- Slice 2 / 3 `?` gates **read these fields** (table above). Do not invent a second reveal flag.
- Ugly list/grid from shop/menu. No art.

---

## Test logs

Log after the matching trigger (and on a cross-run load):

| Key | When / what |
|---|---|
| `unlocked_builds` | Every Finish — full list after write (`30`) |
| `unlocks_new` | Keys newly added to Builds this piece |
| `dex_crafts` | Every Finish — full list after write |
| `dex_crafts_new` | New `(construction_id, outlook_id, tier)` rows this piece (`[]` if none) |
| `dex_adventurers` | On order received and on order Finish |
| `dex_adventurer_new_met` | `adv_*` that flipped `met` false→true this event (`[]` if none) |
| `dex_enemies` | On brief / newspaper and on boss-beat resolve |
| `dex_enemy_seen_new` / `dex_enemy_fought_new` | ids newly flipped this event |

**Asserts**

1. Right trigger only — no craft row on abandon; no `met` without an order panel; no `fought` from a shop brief alone.
2. Builds Finish **does** write `unlocked_builds` and **does not** require a parallel `dex_builds` field (must not exist).
3. Crafts key includes `construction_id` — same outlook-tier on two `con_*` → two rows.
4. **Cross-run persist:** second run on the same profile keeps all four lists (not `[]`). Death / `run_over` must not wipe them.
5. Fresh profile → all four empty and Dex UI is all `?`.
6. Slice 3 favor / punish / band are `?` until `dex_enemies[threat_id].fought`; after a boss-beat resolve they may reveal.

---

## Explicit non-goals

- Second copy of `unlocked_builds`
- Illustrated encyclopedia / lore pages (Later / M2)
- `appt_*` in the Adventurers tab (M1)
- Invented enemy ids (use `17` `boss_*`)
- Wiping the Dex on death
- Making Dex a `20` Required run stamp

---

## Pointers

- Unlock / planner / estimate: [30-interactive-order](30-interactive-order.md)
- Named people: [29-adventurer-catalog](29-adventurer-catalog.md)
- Boss favor / punish: [17-chapter-bosses](17-chapter-bosses.md)
- Newspaper announce: [26-newspaper](26-newspaper.md)
- Finish: [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Harness `run_id`: [20-harness-stamp](20-harness-stamp.md)
- Encyclopedia park: [04-progression](04-progression.md)
- PM: [pm/phase-1-plan](pm/phase-1-plan.md)
