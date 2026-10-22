# Dex (M1 collection record)

**Doc id: `31`.** Design only — no Client / Godot / art this stamp. Grimmjow 2026-10-05. Jonathan: *“something like the craft dex for recording all crafts and enemy and adventurers unlocked etc.”*

**Terminology:** UI / prose says **adventurer**. **Client** = Godot Client seat / codebase. Ids unchanged (`adv_*`, `con_*`, `boss_*`, `appt_*`, `boss_client_id`). Scrap Duelist stays `appt_*`. Do not mass-rename.

The Dex is the **profile-level, cross-run** collection record. It is the same save layer as `unlocked_builds` ([30](30-interactive-order.md) slice 2). Slice 2 / 3 `?` rules **read the Dex** — one source of truth.

**2026-10-13:** Scrap Duelist / `appt_*` stay **appointments** on the route map (`22`, C1 elite = N5). They are **not** this Adventurers tab.

Lore blurbs and Fashion Encyclopedia pages stay **Later**. **[Dex art sockets (2026-10-20)](#dex-art-sockets-2026-10-20)** open tab chips and row icons on the ugly list Client #35 already ships. This stamp does not add a screen.

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

Ugly-Client: one **plain list / grid** screen, reachable from the **shop / menu**. Four tabs. No lore pages. Tab / row art sockets are [Dex art sockets (2026-10-20)](#dex-art-sockets-2026-10-20) — not a second screen.

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
- Reachable from shop / menu (one button). `?` for locked rows. **Shipped** Client #35. Art sockets plug into this strip and this list — [Dex art sockets (2026-10-20)](#dex-art-sockets-2026-10-20).
- Builds rows = outlook name + tier (text). Row icons for Builds stay **off** this stamp.
- Crafts rows = construction display name + outlook/tier + `first_day` / run id (debug-ok). Row icons for Crafts stay **off** this stamp.
- Adventurers rows = name + job + received / completed (once met). Met rows may show the existing bust (art section). Unmet stays `?`.
- Enemies rows = name (if seen) + seen/fought + tags only if fought. Enemy icons are the stamp line in the art section.
- **Later:** lore entries, full Fashion Encyclopedia chrome (`04`). Not this stamp.

---

## Dex art sockets (2026-10-20)

**Status:** Grimmjow Design-ready for Jonathan stamp. Docs only. No `src/` / Godot / art gens in this PR. The screen is the ugly list Client #35 already ships: tab strip **Builds | Crafts | Adventurers | Enemies**, then one `ItemList`. Shop / menu entry stays. This section does not add a page.

Market leftovers stay **closed**. Chrome **A**, six `sk_*`, and `assets/adv/<adv_id>.png` (#54 / #55) have landed. Do not regen portraits. Do not reopen the market.

`20` is unchanged. No new dump keys. A missing png keeps the text row. Reveal rules above stay the reveal rules — art does not show a name, a bust, or an enemy face the list is still hiding as `?`.

House grain for anything this stamp gens: PixelLab **Pro Flash 96×96 soft-stipple**. Dex tabs are not a second size. A 16×16 Dex chip is not offered (that was market chrome **B**, and it was not stamped).

### Tab chips — lock

Four faces. One frame each. Selected = **Client modulate** on that frame (same pattern as market chrome **A**). Word labels may stay on the button. Missing file → text button as #35.

| Tab | File | Subject |
|---|---|---|
| Builds | `assets/dex/tab_builds.png` | Folded-pattern / outlook mark. Not a garment poster |
| Crafts | `assets/dex/tab_crafts.png` | Finished-hem / piece mark. Not a `con_*` matrix |
| Adventurers | `assets/dex/tab_adventurers.png` | Generic person mark. Not one of the 12 named busts |
| Enemies | `assets/dex/tab_enemies.png` | Generic threat mark. Not one of the nine `boss_*` |

Wire path: `res://assets/dex/tab_<slug>.png` (`builds` / `crafts` / `adventurers` / `enemies`).

Leave out of the PNG: tab word, card frame, selected-state frame, shiny, lore caption.

### Adventurer rows — accept the default

Met row may show the bust **already at** `assets/adv/<adv_id>.png` (`res://assets/adv/<adv_id>.png`). The twelve named M1 people in [29](29-adventurer-catalog.md) are that set. Unmet row stays `?` with **no** texture and no name. Missing png on a met row → text line as today (name + job + received / completed).

No second portrait set. No job-stub file. No `appt_*` row. No Scrap Duelist.

### Enemy row icons — Jonathan writes A or B

The list already has one row per `boss_*` in [17](17-chapter-bosses.md) (nine). Favor / punish text stays **fought-only**. This line is only the row icon.

- **A (Design default) — lock the nine.** Clear first wave. Pro Flash **96×96 soft-stipple**. One threat face / sigil each. Not a full-scene portrait, not a posture sheet, not newspaper chrome. Show the icon only when that row already shows a name (`seen` or `fought`). Unseen row stays `?` with no icon.
- **B — placeholder rows.** Tab chips still stamp. Enemy rows stay the #35 text (`?` / name / env / counts / tags). No `boss_*` png this wave.

**Silence is not A.** Nine icons are the expensive fork. Write **A** or **B**. Design recommends **A**.

| `boss_*` | File (only if **A**) |
|---|---|
| `boss_ash_drake` | `assets/dex/boss_ash_drake.png` |
| `boss_salt_widow` | `assets/dex/boss_salt_widow.png` |
| `boss_rust_knave` | `assets/dex/boss_rust_knave.png` |
| `boss_mire_bride` | `assets/dex/boss_mire_bride.png` |
| `boss_bog_king` | `assets/dex/boss_bog_king.png` |
| `boss_pale_choir` | `assets/dex/boss_pale_choir.png` |
| `boss_gilded_warden` | `assets/dex/boss_gilded_warden.png` |
| `boss_ivory_judge` | `assets/dex/boss_ivory_judge.png` |
| `boss_sunspear_captain` | `assets/dex/boss_sunspear_captain.png` |

Wire path: `res://assets/dex/<boss_id>.png`.

### Builds and Crafts rows — lock (no new art)

Text rows stay. Do not gen an outlook-tier icon or a `con_*` × outlook icon for this list. Outlook combination art stays [15](15-outlook-gen-list.md). That is not a Dex socket.

### Wire contract (Ulquiorra — after stamp, not this PR)

Keep the #35 screen. On each tab button, if `res://assets/dex/tab_<slug>.png` exists, show it on that button. Selected tab modulates the one texture; the active-tab treatment the list already uses may stay. Missing file → text button.

Adventurers: on a **met** row, if `res://assets/adv/<adv_id>.png` exists, set that `ItemList` icon. Unmet → `?` and no icon.

Enemies: only if the stamp is **A**, and the row is `seen` or `fought`, and `res://assets/dex/<boss_id>.png` exists, set that icon. Otherwise the text row as #35. Stamp **B** → do not look for enemy pngs.

Do not add a lore page, a second portrait, or a write path.

### Explicit non-goals (this section)

- Lore pages, Fashion Encyclopedia, poster pages
- A second `adv_*` portrait set, or busts on unmet rows
- Builds / Crafts row icons
- Owner chrome. Posture sockets and slice 4 playback are [30](30-interactive-order.md) — not a Dex socket
- Elite N5 telegraph (law is [22](22-chapter-schedule.md) Elite telegraph — not a Dex socket)
- Market chrome, `sk_*` regen, portrait regen
- M2 four-job people (Wizard / Hexer / Outrider / Oathbound)
- Shiny gens
- Gens, Client, or Godot in this Design PR

---

## Client needs

- Persist `unlocked_builds`, `dex_crafts`, `dex_adventurers`, `dex_enemies` on the **same profile / meta save**. Fresh profile = all empty → UI all `?`.
- **Never** clear on run end / death / `run_over`.
- **One write path** for Builds: Finish + threshold → `unlocked_builds`. Dex Builds tab only reads it.
- On each piece Finish: also union `dex_crafts` for each `con_*` × met outlook-tier (and `plain`/`base` if none).
- On order panel open: upsert `dex_adventurers` (`met`, `orders_received++`). On that order’s Finish: `orders_completed++`. Resolve job-stubs to named `adv_*`.
- On slice 3 brief show or newspaper announce: upsert `dex_enemies.seen`. On boss-beat resolve: set `fought`, `fights++`.
- Slice 2 / 3 `?` gates **read these fields** (table above). Do not invent a second reveal flag.
- Ugly list/grid from shop/menu stays the screen (#35). Tab / row textures are [Dex art sockets (2026-10-20)](#dex-art-sockets-2026-10-20) — wire only after Jonathan stamps. Missing png → the text row already shipped.

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
- Illustrated encyclopedia / lore pages (Later)
- Fashion Encyclopedia chrome (`04`)
- `appt_*` in the Adventurers tab (M1)
- Invented enemy ids (use `17` `boss_*`)
- A second adventurer portrait set (reuse `assets/adv/` or show text)
- Builds / Crafts row-icon matrix (outlook × tier × `con_*`)
- Wiping the Dex on death
- Making Dex a `20` Required run stamp
- Owner chrome, posture sockets ([30](30-interactive-order.md) slice 4), the shipped elite N5 telegraph ([22](22-chapter-schedule.md)), market reopen (those are outside this file)

---

## Pointers

- Unlock / planner / estimate: [30-interactive-order](30-interactive-order.md)
- Named people: [29-adventurer-catalog](29-adventurer-catalog.md)
- Boss favor / punish: [17-chapter-bosses](17-chapter-bosses.md)
- Newspaper announce: [26-newspaper](26-newspaper.md)
- Finish: [27-craft-mode-stamina](27-craft-mode-stamina.md)
- Harness `run_id`: [20-harness-stamp](20-harness-stamp.md)
- Encyclopedia park: [04-progression](04-progression.md)
- Art sockets: this file (2026-10-20) · route board: [22](22-chapter-schedule.md) · grain: [05-art](05-art.md)
- PM: [pm/phase-1-plan](pm/phase-1-plan.md)
