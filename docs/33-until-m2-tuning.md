# Until-M2 tuning — stats and event pool (2026-10-22)

**Status:** **Closed.** Jonathan accept **A A A A** (tables / elite pressure **A** / mission gold **A** / reps gate **A** / event attach **A**) on Design #72. Client landed (#73, `9f03c16`). **Doc id: `33`.** The decision table below is historical law. Do not reopen. No further Client on this file. No art. Does not revive #62. Does not reopen the M2 four-job Client wire (#75, landed). UI shell v1 **shipped** ([34](34-ui-shell-v1.md), Design #76 / Client #77, stamp **A A B**). Do not reopen. Posture art stays **Nov 2**. PR #71: Solenne ×4 art **HOLD** until **2026-11-02**; Halden + Vex **KEEP**; shop **ACCEPT**.

**Test chapter:** C1 on `map_m1` (`CHAPTER_DAY_COUNT` = **8**), `M1_JOB_POOL` only. Every number in this file is an **until-M2** lock for that test. It is not a forever-final for C2, C3, or a later map length.

**Does not reopen:** route-map spine ([22](22-chapter-schedule.md)), Elite telegraph N5 (#66 / #67 / #68), interactive-order slice 4 (docs #69 / Client #70), portrait redraws (#64 / #65), market catalogs ([32](32-shop-and-events.md) mechanism), estimate S–F cutoffs ([30](30-interactive-order.md), Jonathan 2026-10-08 leave-as-knobs). Does not revive #62. Does not revive the free per-day `E*` board (#36 / #37).

The stamp card is [STAMP](STAMP.md) (2026-10-22). The letters are written. Code cites in the tables below are the pre-Client #73 deltas. Client #73 followed accept **A A A A**. Do not read a stub row as live.

---

## Standing schedule locks

These already stand. This file restates them. They are not decisions.

| Lock | Until-M2 reading |
|---|---|
| **Round → Day** | Live labels are **D1..DN**. Dump key is `day_index`. Do not emit `CHAPTER_ROUND_COUNT` / `round_index` / R1..R8 as live law. |
| **`crafts_max` gone** | Unlimited pieces per chapter. Stamina still gates one session ([27](27-craft-mode-stamina.md)). Do not emit `crafts_max`. `cant_craft` is not a piece cap. |
| **Last 2 vs `CHAPTER_DAY_COUNT`** | `CHAPTER_DAY_COUNT` = `map.day_count`. Not global law. Graph days = **D1..(N−2)**. **D(N−1)** = travel / final prep. **DN** = boss approach. Current test map **N = 8** → D7 travel / final prep, D8 boss approach. Reserved days are not picks and not event nodes. |
| **Event-pool model** | Which `evt_*` resolves is a **pool row**, not a script that says “D3 is always Ashfall” because the day number says so. The route graph still authors **where** a `kind=event` node sits. The pool fills **which catalog row** that node resolves. This is not the windowed `E*` board. Do not emit `event_pool` / free `day_assignments`. |
| **2–4 options** | Fork width on the current test map. A live fork lists **2–4** next nodes (type + id). Corridor, entered bind, and reserved days show **no** options panel. `map_m1` forks are 2 or 3 wide. The cap is 2–4. Do not add an edge to force 4. An event screen shows that row’s **1–2 choices** ([32](32-shop-and-events.md)). It does not show 2–4 events. |

**Telegraph timing is not soft.** No windup seconds.

- Elite: the appointment badge is on the card from chapter start (shipped, Marker A, Scope A). Predicate `kind=appointment`. C1 shows it on **N5** only.
- Boss: newspaper announce at chapter start ([26](26-newspaper.md)), before spend. The badge does not sit on D7 / D8 or a `boss_*`.
- Playback beats ([30](30-interactive-order.md) slice 4) display the resolver stamp. They are not a combat clock and not a second sim.

---

## Where the numbers live today

Bible rows below are the source. Code cites are what Client does now. This PR does not edit `src/`.

| Topic | Bible | Code today |
|---|---|---|
| Person stats | [29](29-adventurer-catalog.md) six-stat tables | `src/data/catalog/adventurer_catalog.gd` `PEOPLE` — **M1 12 only**, matches `29`. M2 12 are docs-only |
| Garment / mat stats | [11](11-materials.md), [12](12-constructions.md) | `src/data/catalog/craft_catalog.gd` (mats / constructions) |
| Threat tags, no HP bar | [17](17-chapter-bosses.md) | `src/data/catalog/threat_catalog.gd` — tags only |
| Pressure, `hp_remaining`, aid, mission letters | not tabulated; harness shape in [20](20-harness-stamp.md) | `src/mission/mission_resolver.gd` `attach` / `_pressure` / `_letter` |
| Order difficulty | not tabulated | `src/data/chapter/schedule_catalog.gd` — named `adv_*` route orders **2**; `appt_scrap_duelist` **3**. Boss **3** in `resolve_boss` |
| Stamina | [27](27-craft-mode-stamina.md) draft `12 * N` | `src/autoload/game_constants.gd` |
| Purse knobs | [19](19-own-basic-starter.md) start **12**; [32](32-shop-and-events.md) | `game_constants.gd` `GOLD_START` **12** and the market consts |
| Mission gold | [32](32-shop-and-events.md) “when Client pays them” — **no int** | `src/autoload/atelier_session.gd` `_apply_mission_payout` — **+1 only if** `artifact_coin_purse` is equipped, on clear and on fail |
| Reps formula | [25](25-reps-meter.md) | `src/chapter/reps_rules.gd` |
| Reps gate | [25](25-reps-meter.md) C1 **8** / C2 **14** / C3 **20** | `REPS_GATE_STUB` **0** (`game_constants.gd`). The gate does not fire |
| Decline | [22](22-chapter-schedule.md) “−reps”, once / chapter — **no int** | `DECLINE_REPS_STUB` **−1** (`atelier_session.gd`) |
| Event rows | [32](32-shop-and-events.md) seven `evt_c1_*` | `src/data/catalog/event_catalog.gd` |
| Welded C1 refs | [32](32-shop-and-events.md) N4 / N6 / N10 / N17 | `src/data/chapter/map_catalog.gd` and `EventCatalog.NODE_EVENTS` |

---

## Decision 1 — Accept these tables

**Accept, or name the row.** One list. A named row is a rewrite of that row only. Silence is not accept. Design recommends **accept**.

No cell in `29` / `11` / `12` / `32` changes in this PR. Accepting means those cells become the until-M2 lock and lose “retune without a stamp”.

### People (`29`)

Scale already written there: **HP 8–16**, other stats **1–8**. All 24 rows sit inside it. Test-chapter draw uses the M1 twelve. The M2 twelve are the same lock and stay docs-only until a later Client. Do not wire them here.

Delta vs `29`: the line “stats are test knobs, not a hard lock” **stops applying to the six-stat cells** if this decision is accept. It still applies to estimate weights and the S–F cutoff table in `30`.

### Garments

`11` material stat columns and `$`, and `12` construction stat columns, as written. They feed the same soak the resolver already uses. This stamp does not retune a hemp or an armor row.

### Difficulty (code → lock)

| Beat on the test chapter | `card_difficulty` |
|---|---:|
| Named `adv_*` route order | **2** |
| `appt_scrap_duelist` (N5) | **3** |
| Boss beat | **3** |

Other appointment rows in `schedule_catalog.gd` are not on `map_m1`. They are not this test.

### Stamina (`27`, `game_constants.gd`)

| Knob | Until-M2 |
|---|---|
| Session start | **`12 * N`** (N = piece count, 1..4) |
| Hand | **5** |
| Dig | **2**, session-wide, not × N |
| Material play | common **1** / uncommon **2** / rare or legendary **3** |
| Rune play | **2** |
| Zones | **1..4** |

Delta: “Jonathan may retune” on the `12 * N` draft becomes this lock. The integers do not move. `artifact_oil_rag` **+2** stamina (not × N) stays the `32` effect.

### Purse knobs already numbered

| Knob | Until-M2 |
|---|---|
| `gold` start | **12** |
| Floor | **0** |
| Shelf | **4–6**, first-draw default **5** |
| `qty_offered` | **1** |
| Refresh | base **2**, step **2** → 2, 4, 6… |
| `mat_ench_thrift` / `mat_ench_heavy` | fee **2** / **3** |
| Sell | **⌊base $ / 2⌋**, min **1** |
| Material floor | **≥ 3** or the sell / event-remove skips |
| Staff `$` | 4 / 5 / 8 / 7 / 8 as in `32` |
| Skill `$` | 3 / 3 / 3 / 5 / 5 / 7 as in `32` |
| Artifact `$` | 5 / 4 / 6 / 6 / 5 / 6 / 4 / 5 as in `32` |

### Event outcome ints (`32`)

The seven `evt_c1_*` gold / reps / mat deltas, as written. Mild stays mild: no run-kill. Delta: the sentence that Test may retune those ints inside ±1..3 **without** a stamp **stops** if this decision is accept.

### Decline

**−1** reps, once per chapter, floor 0. Delta vs `22`: the int was only in code.

### Mission letters (not the estimate bands)

`mission_resolver.gd` `_letter`, until-M2:

| Score | Letter |
|---:|---|
| `hp_remaining` ≤ 0, or empty bag | **F** / **D** as the function already returns |
| ≥ 82 | S |
| ≥ 68 | A |
| ≥ 54 | B |
| ≥ 40 | C |
| ≥ 24 | D |
| else | F |

These are the post-sim letters. They are **not** the estimate cutoffs in `30` (≥10 / ≥7 / ≥4 / ≥1 / ≥−2). Those stay Test knobs. Do not assert estimate band == mission `rating`.

---

## Decision 2 — Elite pressure

There is **no enemy HP** and **no enemy damage int**. `hp_remaining` is adventurer / gear soak in **0..1**. Threats in `17` are tag rows. Do not add a boss HP pool in this stamp.

Current formula (`mission_resolver.gd` `attach`). Accept the coefficients. The only fork is the elite pressure row.

```
soak    = max(0, HP + DEF + RES)
punch   = max(0, ATK) + 0.35 * max(0, MOB) + 0.35 * max(0, PRE)
soak_r  = clamp(soak / (8 + 2 * difficulty), 0, 0.55)
hp      = clamp(1 - pressure + soak_r + 0.08 * favor_n - 0.12 * punish_n - 0.07 * neg_n - empty_pen, 0, 1)
empty_pen = 0.22 if the bag is empty and the beat is not prep, else 0
aid     = clamp(round(punch * 8 + 6 * positives + 12 * favor_n), 0, 100)   # 0 if empty
```

| Band | `pressure` today |
|---|---:|
| Order difficulty 1 | 0.28 |
| Order difficulty 2 | 0.40 |
| Order difficulty 3 | 0.52 |
| Boss (`is_boss`) | 0.84 |

N5 uses the difficulty-3 row (**0.52**). The resolver has no elite branch. Difficulty still sets the soak divisor and the reps / gold multiplier. A pressure bump does not also change difficulty.

**A (Design default):** an appointment beat uses pressure **0.64**. Scrap Duelist stays difficulty **3** (soak divisor 14, reps / gold as a 3). Boss stays **0.84**. Other orders stay on the 0.28 / 0.40 / 0.52 row. Delta vs `_pressure`: one new branch, `kind` appointment (the same predicate as the shipped badge).

**B:** no branch. Appointment pressure stays the order’s difficulty row. N5 stays **0.52**.

Write **A** or **B**. Silence is not **A**. Design recommends **A**. The badge already calls N5 the hard node. 0.64 sits under the boss and above a hard walk-in. It does not invent an HP bar.

---

## Decision 3 — Mission gold

Start **12** cannot fund the M2 shelf by itself (apprentice staff **4**, a 1-stamina skill **3**, loom pair **8**). Events pay about **±1..2**. Sells pay **⌊$ / 2⌋** min 1. [32](32-shop-and-events.md) already says mission gold writes the same purse, and never set the int.

`_apply_mission_payout` adds gold only for the coin purse, including on a failed order.

**A (Design default):** base payout on a **cleared** order or boss beat:

| Rating | Multiplier |
|---|---:|
| S | 3 |
| A | 2 |
| B | 2 |
| C | 1 |
| D | 0 |
| F | 0 |

`gold += card_difficulty * multiplier`. Not cleared → **0**. Boss uses difficulty **3**.

`artifact_coin_purse` adds **+1** only when that base payout is **> 0**. A fail, and a clear that pays 0, are not payouts. Delta vs code: the function today adds +1 on every return, clear or not, when the purse is equipped.

Events stay on the `32` deltas. Market buy / sell / refresh / enchant stay on the purse knobs. No second purse.

Worked test chapter, three difficulty-2 **B** clears before the boss: 3 × (2 × 2) = **12** gold, the same size as the start purse. With start 12 that is one staff, one cheap skill, one `$2` mat, and one refresh — not the whole M2 bank. A difficulty-3 **B** boss adds 2 × 3 = **6**.

**B:** no base mission gold. Purse stays start 12 + events + sells + the coin-purse +1 as code does it today.

Write **A** or **B**. Silence is not **A**. Design recommends **A**.

---

## Decision 4 — Reps gate

The [25](25-reps-meter.md) **formula** stays. This decision does not edit `rating_mult`, the death **−3 × difficulty** row, the fail **−difficulty** row, or the floor at 0.

| Chapter | Gate in `25` |
|---|---:|
| C1 | **8** |
| C2 | **14** |
| C3 | **20** |

Code uses `REPS_GATE_STUB` **0**, so a chapter never fails the gate. The comment in `reps_rules.gd` still calls 8 / 14 / 20 the old 3-round shell.

A difficulty-2 **B** clear is `round(1.5 × 2)` = **3** reps. Three of those = **9**.

**A (Design default):** wire the `25` table. Test chapter gate = **8**. C2 **14** and C3 **20** are the same until-M2 table, not a retune. Do not multiply the gate by `CHAPTER_DAY_COUNT`. The “old 3-round shell” sentence becomes history. Delta vs code: stub **0** → this table. Delta vs `25`: none on the ints.

Why 8 still fits an 8-day map: a short path of three difficulty-2 B clears makes 9 and passes. One fail (**−2**) on that path misses. A five-order path is looser. That is acceptable for this test. The gate’s job is “you can miss”, not “the long path is hard”.

**B:** C1 gate **10**. Three difficulty-2 B clears (9) miss unless one of them is better. C2 / C3 stay 14 / 20. Delta vs `25`: C1 8 → 10.

Write **A** or **B**. Silence is not **A**. Design recommends **A**.

Decline **−1** is Decision 1, not this letter.

---

## Decision 5 — Event pool attach

### Pool (both letters)

All seven existing `evt_c1_*` rows. No new id. Outcomes stay Decision 1. Weights are relative inside the legal day-band. Rarity is the label for that weight, not a second roll.

| `evt_*` | Rarity | Weight | Bands | On `map_m1` today |
|---|---|---:|---|---|
| `evt_c1_heat_mirage` | common | 3 | early, mid | N4 |
| `evt_c1_ashfall` | common | 3 | early, mid | N6 |
| `evt_c1_kind_stranger` | common | 2 | early, mid | off the map |
| `evt_c1_wagon_rattle` | common | 2 | early, mid, late | off the map |
| `evt_c1_scrap_market` | uncommon | 2 | mid, late | N10 |
| `evt_c1_salt_spray` | uncommon | 2 | late | N17 |
| `evt_c1_toll_post` | rare | 1 | mid, late | off the map |

### Day bands (both letters)

Relative to **N = `CHAPTER_DAY_COUNT`**, not a hardcoded 8. Current test uses N = 8, so the bands land on D1–D2 / D3–D4 / D5–D6.

| Band | `day_index` |
|---|---|
| early | 1..2, and only if that day is still a graph day (≤ N−2) |
| mid | 3..4, and ≤ N−2 |
| late | 5..(N−2) |
| reserved | **N−1** and **N** — no draw, no event choices |

`map_m1` event nodes and the band each welded id already satisfies:

| Node | Day | Band | Welded `ref_id` |
|---|---|---|---|
| N4 | D2 | early | `evt_c1_heat_mirage` |
| N6 | D3 | mid | `evt_c1_ashfall` |
| N10 | D4 | mid | `evt_c1_scrap_market` |
| N17 | D6 | late | `evt_c1_salt_spray` |

Last 2 stay travel / boss. They are not pool days. A 3-day or 12-day map is not this test. Late-only rows do not draw when the late band is empty.

### A (Design default) — draw

On enter of `kind=event` (not a draft):

1. Candidates = pool rows whose bands include that `day_index`, not yet resolved this chapter.
2. If none, unused pool rows, ignoring band.
3. If none, the node’s `ref_id` if it is in the pool (only then may a row repeat).
4. Weighted pick. Scan the table above, top to bottom. Stable on the run seed.
5. Show that row’s **1–2** choices. One pick resolves the node.

The four `ref_id`s on `map_m1` stay on the graph as a **sample legal draw** (each is in band). They are not the resolver. `event_id` on the stamp is the drawn id. It may differ from `route_nodes[].ref_id`.

Delta vs the pre-Client weld and vs `map_catalog.gd`: the four equalities (N4 heat, N6 ash, N10 scrap, N17 salt) became “`event_id` ∈ pool, band contains `day_index`, no repeat”. Client #73 moved [20](20-harness-stamp.md) assert 26. The four ids stay the sample legal draw. No new Required key. Do not emit windowed `event_pool`.

### B — weld

Resolver keeps the node `ref_id`. N4 / N6 / N10 / N17 stay those four ids. The three extras stay off `map_m1`. Weights and bands are filed here for a later map. Assert 26 would have stayed the weld. Letter **B** was not taken. Client #73 followed **A**.

Write **A** or **B**. Silence is not **A**. Design recommends **A**. The standing rule is a pool. Three catalog rows already have no node. The sample ids remain legal outcomes, so the test chapter’s text does not have to change — the rule does.

---

## Client (landed — #73)

Not open work. Ulquiorra followed this file on #73 (`9f03c16`). Szayelaporro smoked. No art seat. The M2 twelve stayed docs-only on that Client. Do not re-queue this table.

| Letter | What #73 followed |
|---|---|
| 1 accept | Cited cells locked. Decline **−1** already matched. No M2 people wire |
| 2 A | `mission_resolver.gd` `_pressure` — appointment **0.64** |
| 3 A | `_apply_mission_payout` — base table; coin purse only if base > 0 |
| 4 A | chapter table (C1 **8** / C2 **14** / C3 **20**). `REPS_GATE_STUB` **0** retired |
| 5 A | day-band draw in place of the welded `ref_id`. Assert 26’s four equalities retired with that Client |

Letters **B** were not taken. No new [20](20-harness-stamp.md) Required key. `gold` on a mission stamp uses the `gold` / `gold_before` / `gold_after` fields `20` already has for the purse.

---

## Decisions (stamp)

**Record:** accept / **A** / **A** / **A** / **A** (Jonathan, Design #72). Client #73. The five lines below are the law as stamped. They are not an open ask.

1. **Tables — accept, or name the row.** People, garments, difficulty, stamina, purse knobs, event outcome ints, decline **−1**, mission letter cutoffs. Estimate S–F bands are not in this list. Design recommends **accept**. Silence is not accept.

2. **Elite pressure — A or B.** **A:** appointment **0.64**. **B:** difficulty row (N5 stays 0.52). Design recommends **A**. Silence is not **A**.

3. **Mission gold — A or B.** **A:** `difficulty ×` S3 / A2 / B2 / C1 / D0 / F0 on a clear; else 0; coin purse +1 only if that base is > 0. **B:** no base payout. Design recommends **A**. Silence is not **A**.

4. **Reps gate — A or B.** **A:** C1 **8** / C2 **14** / C3 **20**. **B:** C1 **10**. Design recommends **A**. Silence is not **A**.

5. **Event attach — A or B.** **A:** weighted day-band draw, no repeat. **B:** keep the four welded ids. Design recommends **A**. Silence is not **A**.

## Questions

None.

## Blocks stamp

**Stamped.** The lines below are the ask as written. They are not open.

An unanswered tables line. Silence is not accept.

An unanswered elite line (**A** or **B**). Silence is not **A**.

An unanswered gold line (**A** or **B**). Silence is not **A**.

An unanswered reps line (**A** or **B**). Silence is not **A**.

An unanswered event line (**A** or **B**). Silence is not **A**.

Estimate S–F cutoffs do not block. They stay knobs. Telegraph timing does not block. It is not soft. Harness assert 26 does not block this docs stamp. It moves with the Client if the event letter is **A**.

Nothing else blocks. #62 is not in this PR. Elite N5 is not in this PR. Slice 4 is not in this PR. No PixelLab in this PR. No `src/` in this PR.
