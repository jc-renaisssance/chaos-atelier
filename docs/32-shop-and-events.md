# Market visit + event resolve (M1)

**Status:** Revised for Jonathan stamp (2026-10-15). **M1 materials / M2 staff-skill-gear LOCKED** (Jonathan, Game Dev Team). **Doc id: `32`.** Filename kept (`32-shop-and-events`). Docs only — no `src/` / Godot / art this stamp. Ulquiorra holds until Jonathan stamps **this revision**. Aizen merges only after stamp. Elite telegraph (N5) and adventurer catalog stay parked. Material icons stay Nnoitra 1:1.

Product display name **Wombaste** (repo `chaos-atelier`). Live chapter spine = authored route map ([22](22-chapter-schedule.md)). This doc fills the hole STAMP / PM called out on 2026-10-05: **shop systems and events were not done yet.**

**Name:** Design / UI = **market**. Wire (Client #41–#43 already ships) = node `kind=shop` and dump `day_action=shop`. Do **not** rename those wire ids this stamp. See [Wire vs display](#wire-vs-display).

**Supersedes** (for M1 route-node market / event only):

- Frozen **per-node-only 4–6 forever** stock tables as sole live law (this doc 2026-10-13) — live law is now **chapter-shared bank + shelf draw + refresh**
- Calling the visit **shop** in Design / UI — live name is **market** (wire `kind=shop` stays)
- Auto **opening-shop** before every order / last-shop-before-boss from the old [21](21-app-flow.md) shell
- Weighted **roll-5** atelier shop from [19](19-own-basic-starter.md) as the live M1 visit (that table stays owner-pool / Later weights)
- Sell-back “$1 scraps → 0 gold” from `19` — M1 sell is **⌊$ / 2⌋, min 1**
- Free per-day `E*` / `event_pool` / `wagon_event` pick ([#36](https://github.com/jc-renaisssance/chaos-atelier/pull/36)/[#37](https://github.com/jc-renaisssance/chaos-atelier/pull/37))
- Old `22-chapter-flow` event-pool rows as live law (ids may be reused; outcomes are this table)
- Market-sold **equippable owner artifacts** as an M1 catalog (none exists; see [Owner power-up](#owner-power-up-gear--staff--items))

---

## LOCKED (Grimmjow — treat as stamped intent)

1. **Enter market** only when the **current** route node `kind=shop` resolves. Display / Design name = **market**. Wire `kind` stays `shop` (Client graph already locked). No auto opening-market before every order.
2. **M1 actions = Buy + Sell + Refresh.** **Reshape** = **Later**. Do not invent reshape UI this stamp.
3. **Chapter-shared market bank.** C1 has one authored pool (`market_bank_c1`) of `mat_*` from [11](11-materials.md). **All** `map_m1` market nodes (N2, N7, N12, N15, N16 — wire `kind=shop`) draw from it. Visible **shelf** per visit / after refresh = **4–6** draws. Bank is **larger than one shelf** and includes deferred-value / mid-late mats (real `11` ids). **Not** a frozen per-node 4–6 list as sole stock law.
4. **Refresh** replaces the whole visible shelf with a new draw from the bank (same shelf size 4–6). Gold cost **increases each successful refresh** this visit: `cost(n) = market_refresh_base + (n−1) × market_refresh_step`. M1 defaults **base 2**, **step 2** → **2, 4, 6, 8…** (Test knobs). `market_refresh_count` starts **0** each visit; increments only on a successful paid refresh. Cannot refresh if `gold < cost`. No debt. Refresh does **not** restock mid-shelf rows and does **not** resolve the day.
5. **Buy:** pay `$` from `11` from the **one** run gold purse; add **one copy** of that `mat_*` to the **run deck** (between-beats `WagonStock` / `27` — do **not** invent a second deck type). Decrement that offer’s `qty_offered`.
6. **Sell:** remove one owned copy of a `mat_*` from the run deck; gain **⌊`mat.$` / 2⌋** gold, **min 1**. Cannot sell if the run deck would drop below **≥ 3 material cards** after the sell (soft floor). Materials only on the M1 tab — not runes / skills / staff / gear.
7. **Exit:** player leaves when done. **No forced buy.** Day still advances / node resolves like other primary day actions. Refresh does not exit.
8. **Market visit count 1–3** stays **graph law** from `22` (count wire `kind=shop` nodes). Client must **not** grey-out market picks.
9. **Ugly M1 UI:** one **market shell**. M1 tab = materials (shelf + sell list + Refresh + Exit). No owner chrome, no art. Fancy titles **Later**.
10. **Market contents (Jonathan 2026-10-15 — LOCKED).** The owner looks here for **materials, staffs, skill cards, or gear/artifact**. **M1 tab = materials only** (buy/sell + refresh + chapter-shared bank). **M2** = staffs / skill cards / gear·artifact tabs on the **same market shell** (shell exists M1; extra category UIs + catalogs = **M2**, not a vague Later).
11. **Enter event** only when the **current** route node `kind=event` resolves. M1 = **text resolve**, not battle craft.
12. C1 event nodes carry **`ref_id` → `evt_*`**. Catalog below (~7 rows). Outcomes may adjust **gold**, **add/remove one mat**, and/or **reps** ([25](25-reps-meter.md)). No craft session inside event M1.
13. Outcomes stay **mild and testable**. No run-kill from a single bad pick (that fail is **Later**). Prefer ±gold / ±1 mat / small reps swings.
14. **Ugly M1 UI:** event id + choice buttons (choice id + short label) + result line. Fancy art / branching trees **Later**.
15. **One gold purse** for the run. Market buy/sell/refresh, event gold, and (when Client pays them) mission gold all write the same `gold`. Start **12** ([19](19-own-basic-starter.md) — Test knob). Floor **0**.
16. **Owner power-up.** M1 = skills (`16`) + craft enc / staff-slot mentions (`10` / `12b`). No stamped equippable artifact catalog for sale in M1. **M2** = staff / skill-card / gear·artifact market tabs on this shell.
17. Material icons stay **Nnoitra 1:1**. PixelLab market / event art = **Later** (Nnoitra parallel).

Numbers marked **Test knob** may retune without a Design re-stamp of the law.

---

## When it fires

Phase-1: **one** primary action per day, from the **current** node ([22](22-chapter-schedule.md)).

| Current node `kind` (wire) | Enter | `day_action` (wire) | Display | `phase` | Craft? |
|---|---|---|---|---|---|
| `shop` | Market visit (this doc) | `shop` | **Market** | `schedule` | **No** |
| `event` | Event resolve (this doc) | `event` | Event | `schedule` | **No** |
| `adventurer` / `appointment` | Order → stamina craft (`27` / `29` / `30`) | that kind | that kind | `craft` when sewing | Yes |
| `reserved` | Travel / final prep or boss approach (`22`) | `reserved` | Reserved | `schedule` / then boss beat | No (not this doc) |

Do **not** open market on adventurer / appointment / reserved / newspaper. Do **not** open an event picker on a market node. Do **not** revive live `event_pool` / free `E*` board.

`mission_kind` stays **null** on pure market / event stamps (`20`). Do not emit `mission_kind=event` as a craft session.

---

## Wire vs display

Client #41–#43 already ships the route graph with `kind=shop` and dump `day_action=shop` (`src/data/game_enums.gd` `DAY_ACTION_WIRE`, `map_catalog.gd`). Ulquiorra has **not** started the visit Client. **Do not** break those wire ids this stamp.

| Layer | Value |
|---|---|
| Design / UI / panel type label | **market** (e.g. `market · N2`) |
| Node `kind` (map + `route_nodes`) | `shop` |
| Dump `day_action` | `shop` |
| Visit dump keys (new this PR — not in Client yet) | `market_*` (`market_bank_id`, `market_stock`, `market_refresh_*`, …) |
| Graph law “1–3 visits” | Count nodes with `kind=shop` |

Client maps: current `kind=shop` → open **market** shell. Dump still writes `day_action=shop`.

---

## Market visit

### Enter / exit

1. Current node is `kind=shop` and that day is being resolved (not a draft).
2. Client opens the ugly **market** shell (Materials tab). Draw the first **shelf** (4–6) from `market_bank_c1`. `market_refresh_count = 0`.
3. Player may **Buy**, **Sell**, **Refresh**, and/or **Exit** with no purchase.
4. Exit (or equivalent Done) **resolves the node**. Day advances the same way as other primary actions. `route_path` already holds this node from the confirm; exit does not re-pick the graph.
5. Refresh does **not** resolve the day.

Market is **not** a `phase`. Dump `phase=schedule` + `day_action=shop` (wire — display Market).

Market `ref_id` on the route row stays **null**. M1 panel = **type + id** with display type **market** (`market · N2`). Wire kind remains `shop`. Do not invent market-owner names or fancy titles.

### Chapter-shared bank (`market_bank_c1`)

**Live stock law:** one authored bank for the chapter. Every `map_m1` market node (`kind=shop`) draws its visible shelf from this bank. Refresh redraws from the **same** bank.

| Rule | M1 |
|---|---|
| Bank id | `market_bank_c1` |
| Who draws | N2, N7, N12, N15, N16 — all of them |
| Bank size | **22** `mat_*` (below) — **larger than one shelf** |
| Shelf size | **4–6** distinct ids (Test knob; M1 default **5** on first draw if Client needs a single number) |
| `qty_offered` | **1** per shelf row (Test knob) |
| Price | That row’s `$` from `11` |
| Draw | Distinct ids **without replacement within one shelf**. Independent draw from the **full** bank on each visit and each refresh — the bank does **not** deplete on buy or refresh |
| Same id later | Legal on a later refresh or a later market node |
| Excluded | `$5` forbidden, sci-fi stubs, voodoo skins, `mat_grave_silk`, `mat_null_ink_cloth`, `mat_silver_moth`, `mat_skybone_weave`, `mat_skyiron_filigree` ([19](19-own-basic-starter.md) excluded list) |

**Supersedes** the 2026-10-13 frozen “only these 4–6 per node forever” tables as sole stock law. Short **first-draw seeds** per node below are **non-binding fiction hints** for a seeded first shelf — not a second stock system. Live law = bank + draw + refresh.

**Test knob:** Test may swap bank ids **inside** `11` commons + metal/stone + the deferred mid-late set already listed (same “larger than one shelf”, same excluded list) without a Design re-stamp. Do not add `$5` forbidden / sci-fi stubs / voodoo skins (`19` excluded list).

#### Bank table

All ids exist in [11](11-materials.md). `$` copied from `11` for the dump.

| `mat_id` | `$` | Tags | Band | Why in the bank |
|---|---:|---|---|---|
| `mat_hemp_plain` | 1 | Soft | now | Starter staple |
| `mat_iron_scrap` | 1 | Metal | now | Starter staple |
| `mat_cotton_spring` | 2 | Soft, Pure | now | Starter staple |
| `mat_wool_grey` | 2 | Soft, Earth | now | Starter staple |
| `mat_leather_tan` | 2 | Wild | now | Starter staple |
| `mat_bronze_scale` | 2 | Metal | now | Cheap metal stack |
| `mat_clayweave` | 2 | Earth | now | Cheap earth stack |
| `mat_stone_shard` | 2 | Earth, Metal | now | Stack staple (`11`) |
| `mat_milkfleece` | 2 | Soft, Pure | now | Soft / Pure filler |
| `mat_ivy_cord` | 2 | Wild, Earth | now | Cheap cross |
| `mat_tar_thread` | 2 | Sticky, Earth | **deferred** | Sticky is weak on C1 staples; later punish / favor lines want it |
| `mat_silk_pale` | 3 | Silk | now | Luxury flow already in starter |
| `mat_leather_dusk` | 3 | Silent, Wild | **deferred** | Silent later; stealth hide |
| `mat_linen_storm` | 3 | Storm | **deferred** | Storm later; early `$` sting |
| `mat_wirecloth` | 3 | Metal | mid | Mid metal — useful once armor stacks |
| `mat_stonefiber` | 3 | Earth, Metal | mid | Heavy earth — later armor |
| `mat_ember_silk` | 3 | Fire, Silk | **deferred** | Fire later; hot to touch |
| `mat_frostwool` | 3 | Frost, Soft | **deferred** | Frost later |
| `mat_suncloth` | 3 | Solar | **deferred** | Solar later |
| `mat_whisper_gauze` | 3 | Silent, Soft | **deferred** | Silent later; fragile now |
| `mat_velvet_court` | 4 | Royal, Silk | **deferred** | Royal ceremony — expensive now, later court / gala |
| `mat_steel_plate` | 4 | Metal | **deferred** | Heavy plate — `$4` early, armor later |

**22 rows.** Shelf 4–6. Bank ≫ shelf so Refresh can show deferred mats the first shelf hid.

#### First-draw seeds (non-binding fiction)

Optional seeded first shelf so N2 feels like a roadside stall and N7 like a market. **Not** live-only stock. Refresh and later visits ignore these and draw from the bank.

| `market_node_id` | Day | Fiction (not UI copy) | Hint first shelf (5) |
|---|---|---|---|
| **N2** | D2 | Early roadside | hemp · cotton · leather tan · wool · iron scrap |
| **N7** | D4 | Market bind | hemp · silk pale · bronze · stone shard · clayweave |
| **N12** | D5 | Mid-road | cotton · wool · leather tan · bronze · stonefiber |
| **N15** | D6 | Late scrap | hemp · iron scrap · wirecloth · stone shard · leather dusk |
| **N16** | D5 | After `adv_tide_glass` | cotton · linen storm · leather tan · iron scrap · silk pale |

### Refresh

| Rule | M1 |
|---|---|
| What | Replace the **entire** visible shelf with a new 4–6 draw from `market_bank_c1` |
| Mid-shelf | Does **not** restock bought rows. The old shelf is discarded |
| `market_refresh_count` | **0** at visit enter. +1 only after a **successful paid** refresh |
| Next cost | `market_refresh_base + market_refresh_count × market_refresh_step` |
| nth refresh cost | `base + (n−1) × step` |
| M1 defaults (Test knobs) | `market_refresh_base = 2`, `market_refresh_step = 2` → costs **2, 4, 6, 8…** |
| If `gold < cost` | Cannot refresh (grey / ignore). No debt |
| On success | `gold -= cost`; `market_refresh_count += 1`; replace `market_stock`; append `{ n, cost }` to `market_refreshes` |
| Day | Does **not** resolve the node. Player may Buy / Sell / Refresh / Exit after |
| vs `own_broker` | That owner’s free reroll (`16`) is **Later**. M1 refresh is the paid curve for `own_basic` |

### Buy

| Rule | M1 |
|---|---|
| Cost | `11` `$` for that `mat_id` |
| Purse | Run `gold` — same purse as refresh / events / mission payouts |
| If `gold < price` | Cannot buy that row (grey / ignore). No debt |
| If `qty_offered == 0` | Cannot buy |
| On success | `gold -= price`; append **one** `mat_*` copy to the between-beats run deck (`WagonStock` / `27`); `qty_offered -= 1`; append `{ mat_id, price }` to `market_buys` |
| Deck destination | **Not** a new pile. Next craft session shuffles this stock into draw as Client already does |
| Repeat | Same id may be bought again only if `qty_offered` remains on **this** shelf. Refresh may offer it again |
| Bank | Buy does **not** remove the id from `market_bank_c1` |

### Sell

| Rule | M1 |
|---|---|
| What | One owned **material** copy (`type=material`) from the run deck |
| Gain | **⌊`$` / 2⌋**, **min 1** (Test knob). `$1` hemp / iron scrap → **1** gold. **Supersedes** `19` “$1 scraps → 0” |
| Floor | After the sell, **material-card count in the run deck ≥ 3**. If the sell would leave 0, 1, or 2 materials, **refuse** (grey / ignore). This is the live floor — “cannot empty the deck of all materials” is implied |
| Count | Materials only. Runes / owner skills (if any later) do not count toward the 3 |
| On success | Remove that copy from `WagonStock`; `gold +=` gain; append `{ mat_id, gold_gained }` to `market_sells` |
| Last copy of an id | Legal **if** the ≥3 material floor still holds |

Starter run deck is **8** materials ([19](19-own-basic-starter.md)). First sells are legal. The floor exists so a market visit cannot strip the atelier.

### Market visits 1–3 (graph law — not UI)

Count wire `kind=shop` nodes on the **complete confirmed path** D1..(N−2). Authored so every full path has **1–3** markets (`22`). Client does **not** grey-out a market option because `shops_taken == 3`. A path with 0 or 4 market nodes is a **map bug**.

### Ugly M1 UI

```
market · N2
gold 12
refresh next $2  (count 0)

SHELF
  mat_hemp_plain     $1   own 2   [Buy]
  mat_cotton_spring  $2   own 1   [Buy]
  …

DECK (sell)
  mat_hemp_plain     own 2   sell +1   [Sell]
  …

[Refresh $2]   [Exit]
```

Labels = ids + `$` + owned count + next refresh cost. No market-owner portrait, no atelier chrome, no PixelLab icons this stamp (Nnoitra 1:1). Fancy titles **Later**.

### Market tabs (contents)

The market is where the owner looks for **materials, staffs, skill cards, or gear/artifact**.

| Tab | Milestone | Notes |
|---|---|---|
| **Materials** | **M1** — the live tab | Buy / sell / refresh + `market_bank_c1`. Jonathan locked 2026-10-15 |
| **Staffs** | **M2** | Same shell. Catalog + UI in M2. Staff-slot law already in `12b` |
| **Skill cards** | **M2** | Same shell. Owner skills already in `16` (`sk_*`) — this tab sells / picks extras, not a second skill system |
| **Gear / artifact** | **M2** | Same shell. **No** stamped equippable catalog for sale in M1 |

**LOCKED (Jonathan 2026-10-15):** M1 = materials only. M2 = the other three tabs on this shell. Do not hide the shell behind a different scene type in M2 — extra tabs plug into this visit. Do not invent M2 catalogs in the M1 Client.

---

## Owner power-up (gear / staff / items)

**LOCKED — M1 vs M2 (Jonathan 2026-10-15).**

| Already covered (do not invent a parallel) | Where |
|---|---|
| Owner **skills** (reroll, income floor, hand / storage) | [16](16-shop-owners.md) — player clothier kit. Phase-1 = `own_basic` (none). Other owners Later |
| Craft **enchantments / runes** (`enc_*`) | [10](10-catalog-overview.md) · [13](13-enchantments.md) · stamina hand (`27`) |
| **Staff-slot** raises to `max_materials` / `max_runes` | [12b](12b-craft-slots.md) (historical 2m1r; live craft is stamina — staff still Later unlock) |

**No** stamped equippable artifact / owner-gear market catalog exists. There is no `gear_*` / `artifact_*` offer list to wire.

**M1 (LOCKED):** market tab stays **materials only** (buy / sell / refresh `mat_*`). Do **not** add market-sold staffs, skill cards, or equippable owner artifacts this stamp. Do **not** sell runes on the C1 shelf (`19` optional 6th enc slot stays Later / M2).

**M2 (LOCKED as the milestone):** Staffs / skill cards / gear·artifact tabs on the **same market shell**, with catalogs stamped then. Forbidden rooms / `$5` mats stay out of M1 (may ride M2 or a later stamp).

---

## Event resolve

### Enter

1. Current node is `kind=event` and that day is being resolved (not a draft).
2. Read `ref_id` → `evt_*` from the node row. **Prefer `ref_id`** over a per-node unique event. Nodes may share a catalog row on later maps; C1 uses one row each.
3. Client shows event id + one-liner + **1–2** choice buttons.
4. Player picks **exactly one** choice. Apply that row’s deltas. Show the **result line**.
5. That pick **resolves the node**. Day advances. No craft session. No second choice tree.

`phase=schedule` + `day_action=event`. `mission_kind` null. Do **not** emit windowed `event_pool`.

### C1 node → catalog

| Node | Day | `ref_id` | Notes |
|---|---|---|---|
| **N4** | D2 | `evt_c1_heat_mirage` | Fork 1 option |
| **N6** | D3 | `evt_c1_ashfall` | From N3 or N4 |
| **N10** | D4 | `evt_c1_scrap_market` | Unbound option from elite N5 |
| **N17** | D6 | `evt_c1_salt_spray` | Corridor from N16 |

Update `22` / Client `map_m1` `ref_id` on these four rows when Client lands. Until then Design law is this table.

### M1 event catalog

About **7** `evt_*` rows. Four are bound on `map_m1`. Three extras exist for Test / later maps — **do not** draw them onto C1 nodes this stamp. Reused ids from superseded `22-chapter-flow` pools; **outcomes are this table**, not the old “Fire pressure / Metal offer bias” lines.

Choice ids are stable dump keys. UI label = the short quoted string (ugly). Fiction one-liner is Design / debug, not a fancy title lock.

Gold floor **0**. A pay-gold choice is **illegal** when `gold < cost` (grey / ignore) — every such event also has a free walk / argue pick so the node can always resolve.

Mat **remove** uses the same **≥ 3 material** soft floor as sell. If the named mat is not owned, or remove would break the floor: **skip the mat delta**, still apply gold / reps, result line says the skip. Do not SCRIPT ERROR.

Mat **add** = one copy into `WagonStock` (same deck as market buy).

Reps use the existing meter ([25](25-reps-meter.md)): `reps = max(0, reps + Δ)`. Event Δ is **small** (this table), not the order rating formula. Write `reps_before` / `reps_after` / `reps_delta` when Δ ≠ 0; Δ = 0 may omit or emit 0.

**No** `cleared` / `mission_failed` / `run_over` from these M1 rows. `event_resolved` = player picked a choice and deltas applied (or skipped as above).

#### Bound on `map_m1`

**`evt_c1_heat_mirage`** — N4

The road shimmers. The horse-car’s water skins feel light.

| `event_choice_id` | Label | Deltas | Result line |
|---|---|---|---|
| `choice_share_skin` | Share the last skin | gold **−1** · reps **+1** | A walker nods and steps aside. |
| `choice_press_on` | Press on | none | The haze holds. You keep the skins. |

**`evt_c1_ashfall`** — N6

Fine ash coats the bolts. Someone will pay to brush it — or you keep a scrap.

| `event_choice_id` | Label | Deltas | Result line |
|---|---|---|---|
| `choice_brush` | Brush the bolts | gold **+2** | A ditch clerk pays for the clean-up. |
| `choice_keep_ash` | Pocket a charred scrap | add **`mat_iron_scrap`** | One noisy scrap joins the deck. |

**`evt_c1_scrap_market`** — N10

A ditch stall after the elite road. Junk, and a polite price.

| `event_choice_id` | Label | Deltas | Result line |
|---|---|---|---|
| `choice_buy_scrap` | Pay for iron scrap | gold **−1** · add **`mat_iron_scrap`** | You buy one scrap. (Illegal if gold < 1.) |
| `choice_walk` | Walk on | none | The stall stays behind. |

**`evt_c1_salt_spray`** — N17

Salt wind on the last stretch. Leather takes the wet.

| `event_choice_id` | Label | Deltas | Result line |
|---|---|---|---|
| `choice_oil` | Oil the hides | gold **−2** · reps **+1** | The deck stays supple. (Illegal if gold < 2.) |
| `choice_sell_damp` | Sell a damp hide | gold **+2** · remove **`mat_leather_tan`** | One tan leather leaves if owned and the ≥3 floor holds; else gold +2 only and the line notes the skip. |

#### Extras (catalog only — not on C1 nodes)

**`evt_c1_kind_stranger`**

A walker flags the wagon and leaves a thank-you coin.

| `event_choice_id` | Label | Deltas | Result line |
|---|---|---|---|
| `choice_take` | Take the coin | gold **+2** | The coin hits the purse. |

**`evt_c1_wagon_rattle`**

A crate lid pops. Lash it, or let a bolt walk.

| `event_choice_id` | Label | Deltas | Result line |
|---|---|---|---|
| `choice_lash` | Lash the crate | gold **−1** | The lid holds. (Illegal if gold < 1.) |
| `choice_let_go` | Let one bolt walk | remove **`mat_hemp_plain`** | One hemp leaves if owned and the ≥3 floor holds; else nothing lost. |

**`evt_c1_toll_post`**

A ditch clerk wants a road tax. Not a run-kill.

| `event_choice_id` | Label | Deltas | Result line |
|---|---|---|---|
| `choice_pay` | Pay the tax | gold **−2** | The ledger closes. (Illegal if gold < 2.) |
| `choice_argue` | Argue the ledger | reps **−1** | The clerk scowls. You roll on. |

**Test knob:** gold / reps ints and which `mat_*` is added/removed may retune inside “mild” (±1..3 gold, ±1 reps, ±1 mat from `11` commons/metal/stone). Do not add a run-kill row without a Design stamp.

### Ugly M1 UI

```
event · N4
evt_c1_heat_mirage
The road shimmers. The horse-car’s water skins feel light.

[choice_share_skin  Share the last skin]
[choice_press_on    Press on]

result: A walker nods and steps aside.
```

No art. No branching tree after the first pick. One result line, then the day is done.

---

## Dump / harness

Extend [20](20-harness-stamp.md). Keep route-map keys from #40/#41 intact (`route_path`, `day_action` = `shop` \| `event`, `current_node_id`, `route_nodes`, …). **Do not** revive live `event_pool` / free `E*` board.

### Market (when `day_action=shop` — enter and after each buy/sell/refresh/exit)

| Field | Type | Notes |
|---|---|---|
| `market_node_id` | string | `N2` / `N7` / `N12` / `N15` / `N16` on C1. Equals `current_node_id` |
| `market_bank_id` | string | C1 = **`market_bank_c1`** |
| `market_stock` | object[] | Live remaining shelf `{ mat_id, price, qty_offered }`. Length **4–6**. Every `mat_id` ∈ bank ⊆ `11`. `price` = `11` `$` |
| `market_buys` | object[] | `{ mat_id, price }[]` this visit, in order. `[]` if exit with no buy |
| `market_sells` | object[] | `{ mat_id, gold_gained }[]` this visit, in order. `[]` if none |
| `market_refresh_base` | int | Test knob. M1 default **2** |
| `market_refresh_step` | int | Test knob. M1 default **2** |
| `market_refresh_count` | int | Successful paid refreshes **this visit**. **0** at enter |
| `market_refresh_cost_next` | int | `base + count × step`. Cost of the next Refresh button |
| `market_refreshes` | object[] | `{ n, cost }[]` this visit, in order. `[]` if none |
| `gold` | int | Current purse after the last action. Also emit on other timetable stamps once Client has a purse |
| `gold_before` / `gold_after` | int | Visit open → after last buy/sell/refresh/exit. Floor 0 |
| `gold_delta` | int | Optional. `gold_after - gold_before` |
| `deck_material_count` | int | `type=material` cards in the between-beats run deck **after** the last action. After a legal sell: **≥ 3** |

Null the market block when `day_action` is not `shop`. **Reshape is Later** — do not emit a reshape field. Do not emit owner-gear / staff / skill-card offer fields on M1.

### Event (when `day_action=event` — after the choice)

| Field | Type | Notes |
|---|---|---|
| `event_id` | string | `evt_*` from the node `ref_id` |
| `event_choice_id` | string | `choice_*` from the catalog row |
| `event_deltas` | object | `{ gold: int, mat_add: string\|null, mat_remove: string\|null, reps: int }` — **applied** values (skipped mat → null / 0 as implemented, but log the skip) |
| `event_resolved` | bool | Choice applied (including skipped mat). M1 rows are not mission-clear |
| `event_result_line` | string | Optional debug copy. Not Required |
| `gold` / `gold_before` / `gold_after` | int | Same purse |
| `reps_before` / `reps_after` / `reps_delta` | int | When event Δ ≠ 0; else 0 / omit |
| `deck_material_count` | int | After applied mat add/remove |

Null the event block when `day_action` is not `event`. Do **not** emit `cleared` as a mission gate for these rows.

`route_nodes[].ref_id` on event kinds = `evt_*` (not null). Market nodes (`kind=shop`) stay `ref_id` null; shelf is `market_stock` from `market_bank_c1`.

---

## Client needs (Ulquiorra)

Docs only this stamp — sketch for the **next** Client PR. No `src/` here. Hold until Jonathan stamps **this revision**.

1. **Enter market** only from current `kind=shop` node. Display label **market**. Dump `day_action=shop`. No auto opening-market. No market on other kinds.
2. Load **`market_bank_c1`**. Draw a 4–6 shelf (hint seeds optional). Show `mat_id` + `$` + owned count. Do **not** treat the old per-node 4–6 tables as the only legal stock.
3. **Buy:** if gold ≥ price and `qty_offered` > 0 → pay, append one copy to `WagonStock`, decrement qty, log `market_buys`.
4. **Sell:** if after-remove material count ≥ 3 → remove one owned material, add ⌊$ / 2⌋ min 1 gold, log `market_sells`. Else refuse.
5. **Refresh:** if gold ≥ `market_refresh_cost_next` → pay, increment `market_refresh_count`, replace the whole shelf from the bank, log `market_refreshes`. Else refuse. Does not exit.
6. **Exit** with zero buys is legal. Exit resolves the day. `day_action=shop`. `phase=schedule`.
7. **Do not** grey-out market graph picks because of visit count. Visits 1–3 is graph law (`22`).
8. **Shell:** one market screen. M1 live tab = materials. Do **not** invent staff / skill-card / gear tabs in the M1 Client (those are **M2**). No reshape, owner chrome (`16`), forbidden rooms, PixelLab icons, or a second scene type.
9. **Enter event** only from current `kind=event` node. Read `ref_id` → `evt_*`. Show id + 1–2 choice buttons + result line.
10. Apply that choice’s deltas to the **same** gold purse / `WagonStock` / `25` reps. No craft session. Illegal pay-gold choices when gold is short. Mat-remove skip if missing or would break ≥3.
11. Dump the `market_*` / event keys above **without SCRIPT ERROR**. Keep `#40`/`#41` route-map keys and wire `day_action=shop`. Do **not** emit live `event_pool` / `day_assignments`.
12. Starting `gold` = **12** (knob). Floor 0. One purse. Refresh knobs base **2** / step **2**.
13. M1 copy = display type **market** + id + catalog labels. Fancy titles / art **Later**.

---

## Test logs (Szayelaporro)

Log on market enter, after each buy/sell/refresh, on market exit, and on event choice. Required list lives in [20](20-harness-stamp.md). Sketch:

| Key | When / what |
|---|---|
| `day_action` | `shop` or `event` — wire; matches `current_node_id` kind. Display Market when `shop` |
| `market_node_id` / `market_bank_id` / `market_stock` / `market_buys` / `market_sells` | Market visit |
| `market_refresh_count` / `market_refresh_cost_next` / `market_refreshes` | After enter and each refresh |
| `gold` / `gold_before` / `gold_after` | Market and event |
| `deck_material_count` | After market or event mat change |
| `event_id` / `event_choice_id` / `event_deltas` / `event_resolved` | Event pick |
| `reps_before` / `reps_after` / `reps_delta` | Event with reps Δ |
| `route_path` / `current_node_id` / `route_nodes` | Unchanged law (`22` / `20`) |

**Asserts (market + event)** — no SCRIPT ERROR path beyond existing smoke.

1. Every `market_stock[].mat_id` ∈ `market_bank_c1` ⊆ `11`. `len(market_stock)` ∈ 4..6. Price matches `11` `$`.
2. Buy: `gold_after == gold_before - price` and `deck_material_count` +1 and `market_buys` contains that `mat_id`.
3. Sell: `gold_after == gold_before + max(1, floor($/2))` and `deck_material_count` −1 and after-count **≥ 3**. A sell that would leave < 3 is refused (counts unchanged).
4. Refresh: `gold_after == gold_before - (base + (n−1)×step)`; `market_refresh_count` += 1; `market_stock` replaced (still 4–6, still ⊆ bank). Refused if `gold < cost` (count unchanged). Refresh does **not** append `route_path` or exit.
5. Exit with `market_buys == []` is legal. `day_action == shop` still. `market_refresh_count` may be 0.
6. Event choice writes `event_id` + `event_choice_id` + `event_deltas` + `event_resolved == true`. Applied gold / mat / reps match the catalog (or documented skip).
7. `day_action` matches `current_node_id` kind (`shop` or `event`).
8. C1 event `route_nodes[].ref_id`: N4=`evt_c1_heat_mirage`, N6=`evt_c1_ashfall`, N10=`evt_c1_scrap_market`, N17=`evt_c1_salt_spray`.
9. No live `event_pool` / free `day_assignments`. No `phase=shop`. No reshape field. No owner-gear offer field.
10. Market graph options (`kind=shop`) are not banned by visit count.
11. Gold never < 0. Illegal pay-gold event / refresh / buy choices do not apply.

---

## Explicit non-goals

- Reshape (free remove / transform without buy)
- Frozen per-node-only 4–6 lists as sole stock law
- Market-sold staff / skill-card / `gear_*` catalogs in **M1** (those are **M2**)
- Staff / skill-card / gear tabs as live **M1** catalogs
- Shop-owner / market-keeper chrome (`16`)
- `own_broker` free reroll as the M1 refresh (Later owner skill)
- Forbidden unlock rooms
- Unique / fancy stock UI
- PixelLab market or event icons (Nnoitra 1:1 stays)
- Weighted roll-5 live atelier shop (`19`) as the M1 visit
- Auto opening-market / last-market-before-boss (`21` shell)
- Renaming wire `kind=shop` / `day_action=shop` this stamp
- Live `event_pool` / free `E*` board
- Craft session / battle inside event M1
- Run-kill from a single event pick
- Branching event trees / art
- Elite telegraph on N5 (stays `22` open question)
- Adventurer catalog / Dex work
- A second deck type or a second gold purse
- Greying-out market picks after k visits
- Inventing `$5` forbidden mats in the C1 bank

---

## Later / M2

**M2 (named milestone — Jonathan 2026-10-15):**

- **Staffs / skill cards / gear·artifact** tabs on the same market shell + catalogs

**Later (not the M2 market-tab lock):**

- Owner roster (`16`) and owner-weighted stock
- `own_broker` free reroll (do not replace the paid refresh curve unless stamped)
- Forbidden unlock rooms / $5 mats in the bank
- Reshape
- Unique stock UI / fancy titles / PixelLab icons (Nnoitra parallel)
- Event art, branching trees, run-kill rows
- Prep-craft / rest-dig nodes (`22`)
- Enchantment / rune market offers (`19` optional 6th slot)

---

## Open questions (Jonathan)

None this pass. Jonathan locked **M1 = materials tab only** and **M2 = staffs / skill cards / gear·artifact tabs** on this shell. Market name (wire `shop` kept), refresh curve, chapter bank, shared gold purse, sell rate, and C1 `evt_*` rows are **locked as M1 defaults**. Gold start **12**, refresh **base 2 / step 2**, sell **⌊$ / 2⌋ min 1**, shelf size 4–6, and bank ids inside `11` (excluded list held) are **Test knobs** — retune without blocking Ulquiorra.

---

## Pointers

`22` route map · `20` harness · `11` materials · `19` starter deck + gold 12 + excluded list · `27` run deck / `WagonStock` · `25` reps · `16` owner skills · `10` / `12b` enc + staff-slot · `01` loop · `21` historical opening-shop · `pm/phase-1-plan` · `STAMP`
