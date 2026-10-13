# Shop visit + event resolve (M1)

**Status:** Design ready for Jonathan stamp (Grimmjow 2026-10-13). **Doc id: `32`.** Docs only — no `src/` / Godot / art this stamp. Ulquiorra holds until Jonathan stamps. Elite telegraph (N5) and adventurer catalog stay parked. Material icons stay Nnoitra 1:1.

Product display name **Wombaste** (repo `chaos-atelier`). Live chapter spine = authored route map ([22](22-chapter-schedule.md)). This doc fills the hole STAMP / PM called out on 2026-10-05: **shop systems and events were not done yet.**

**Supersedes** (for M1 route-node shop / event only):

- Auto **opening-shop** before every order / last-shop-before-boss from the old [21](21-app-flow.md) shell
- Weighted **roll-5** atelier shop from [19](19-own-basic-starter.md) as the live M1 visit (that table stays owner-pool / Later weights)
- Sell-back “$1 scraps → 0 gold” from `19` — M1 sell is **⌊$ / 2⌋, min 1**
- Free per-day `E*` / `event_pool` / `wagon_event` pick ([#36](https://github.com/jc-renaisssance/chaos-atelier/pull/36)/[#37](https://github.com/jc-renaisssance/chaos-atelier/pull/37))
- Old `22-chapter-flow` event-pool rows as live law (ids may be reused; outcomes are this table)

---

## LOCKED (Grimmjow — treat as stamped intent)

1. **Enter shop** only when the **current** route node `kind=shop` resolves. No auto opening-shop before every order.
2. **M1 actions = Buy + Sell only.** **Reshape** (free remove / transform without buy) = **Later**. Do not invent reshape UI this stamp.
3. **Stock** is an authored **offer list** of `mat_*` ids, size **4–6** on C1. Ids from [11](11-materials.md) (starter commons + a couple metal/stone). Stock **differs per shop node** on `map_m1` (N2, N7, N12, N15, N16) — rotate by travel fiction, **not** a live ban.
4. **Buy:** pay `$` from `11` from the **one** run gold purse; add **one copy** of that `mat_*` to the **run deck** (between-beats `WagonStock` / `27` — do **not** invent a second deck type). Decrement that offer’s `qty_offered`.
5. **Sell:** remove one owned copy of a `mat_*` from the run deck; gain **⌊`mat.$` / 2⌋** gold, **min 1**. Cannot sell if the run deck would drop below **≥ 3 material cards** after the sell (soft floor). Materials only — not runes / skills.
6. **Exit:** player leaves when done. **No forced buy.** Day still advances / node resolves like other primary day actions.
7. **Shop visit count 1–3** stays **graph law** from `22`. Client must **not** grey-out shop picks.
8. **Ugly M1 UI:** offer list (`mat_id` + `$` + owned count) + owned deck list for sell. No shop-owner chrome, no art. Fancy titles **Later**.
9. **Enter event** only when the **current** route node `kind=event` resolves. M1 = **text resolve**, not battle craft.
10. C1 event nodes carry **`ref_id` → `evt_*`**. Catalog below (~7 rows). Outcomes may adjust **gold**, **add/remove one mat**, and/or **reps** ([25](25-reps-meter.md)). No craft session inside event M1.
11. Outcomes stay **mild and testable**. No run-kill from a single bad pick (that fail is **Later**). Prefer ±gold / ±1 mat / small reps swings.
12. **Ugly M1 UI:** event id + choice buttons (choice id + short label) + result line. Fancy art / branching trees **Later**.
13. **One gold purse** for the run. Shop buy/sell, event gold, and (when Client pays them) mission gold all write the same `gold`. Start **12** ([19](19-own-basic-starter.md) — Test knob). Floor **0**.
14. Material icons stay **Nnoitra 1:1**. PixelLab shop / event art = **Later** (Nnoitra parallel).

Numbers marked **Test knob** may retune without a Design re-stamp of the law.

---

## When it fires

Phase-1: **one** primary action per day, from the **current** node ([22](22-chapter-schedule.md)).

| Current node `kind` | Enter | `day_action` | `phase` | Craft? |
|---|---|---|---|---|
| `shop` | Shop visit (this doc) | `shop` | `schedule` | **No** |
| `event` | Event resolve (this doc) | `event` | `schedule` | **No** |
| `adventurer` / `appointment` | Order → stamina craft (`27` / `29` / `30`) | that kind | `craft` when sewing | Yes |
| `reserved` | Travel / final prep or boss approach (`22`) | `reserved` | `schedule` / then boss beat | No (not this doc) |

Do **not** open shop on adventurer / appointment / reserved / newspaper. Do **not** open an event picker on a shop node. Do **not** revive live `event_pool` / free `E*` board.

`mission_kind` stays **null** on pure shop / event stamps (`20`). Do not emit `mission_kind=event` as a craft session.

---

## Shop visit

### Enter / exit

1. Current node is `kind=shop` and that day is being resolved (not a draft).
2. Client opens the ugly shop screen for **that node**.
3. Player may Buy, Sell, and/or **Exit** with no purchase.
4. Exit (or equivalent Done) **resolves the node**. Day advances the same way as other primary actions. `route_path` already holds this node from the confirm; exit does not re-pick the graph.

Shop is **not** a `phase`. Dump `phase=schedule` + `day_action=shop` (`20` / `22`).

### Stock (authored, per node)

Each `map_m1` shop node has a frozen offer list. **Not** a seeded roll from `19`. Size **4–6**. Every `mat_id` ∈ [11](11-materials.md). Price = that row’s `$`. M1 `qty_offered` = **1** unless a row says otherwise (Test knob).

Buy decrements `qty_offered` for that offer. `qty_offered == 0` → cannot buy that row again this visit. Stock does **not** restock mid-visit. Leaving the shop ends the visit — the node is resolved; there is no second visit to the same node.

| `shop_node_id` | Day | Fiction (not UI copy) | Offers (`mat_id` × qty) |
|---|---|---|---|
| **N2** | D2 | Early roadside stall | `mat_hemp_plain` ×1 · `mat_cotton_spring` ×1 · `mat_leather_tan` ×1 · `mat_wool_grey` ×1 · `mat_iron_scrap` ×1 |
| **N7** | D4 | Market bind (`combo_market`) | `mat_hemp_plain` ×1 · `mat_silk_pale` ×1 · `mat_iron_scrap` ×1 · `mat_bronze_scale` ×1 · `mat_stone_shard` ×1 · `mat_clayweave` ×1 |
| **N12** | D5 | Mid-road after N10 | `mat_cotton_spring` ×1 · `mat_wool_grey` ×1 · `mat_leather_tan` ×1 · `mat_bronze_scale` ×1 · `mat_stonefiber` ×1 |
| **N15** | D6 | Late scrap corridor | `mat_hemp_plain` ×1 · `mat_iron_scrap` ×1 · `mat_wirecloth` ×1 · `mat_stone_shard` ×1 · `mat_leather_dusk` ×1 |
| **N16** | D5 | After `adv_tide_glass` | `mat_cotton_spring` ×1 · `mat_linen_storm` ×1 · `mat_leather_tan` ×1 · `mat_iron_scrap` ×1 · `mat_clayweave` ×1 · `mat_silk_pale` ×1 |

Prices (from `11`, for the dump): hemp **1** · iron scrap **1** · cotton / wool / leather tan / bronze / clayweave / stone shard **2** · silk pale / leather dusk / linen storm / stonefiber / wirecloth **3**.

Shop `ref_id` on the route row stays **null** — stock is keyed by `node_id`. M1 panel is still **type + id** (`shop · N2`). Do not invent shop-owner names or display titles.

**Test knob:** Test may swap ids **inside** the `11` commons + metal/stone set (same 4–6 length) without a Design re-stamp. Do not add $5 forbidden / sci-fi stubs / voodoo skins (`19` excluded list).

### Buy

| Rule | M1 |
|---|---|
| Cost | `11` `$` for that `mat_id` |
| Purse | Run `gold` — same purse as events / mission payouts |
| If `gold < price` | Cannot buy that row (grey / ignore). No debt |
| If `qty_offered == 0` | Cannot buy |
| On success | `gold -= price`; append **one** `mat_*` copy to the between-beats run deck (`WagonStock` / `27`); `qty_offered -= 1`; append `{ mat_id, price }` to `shop_buys` |
| Deck destination | **Not** a new pile. Next craft session shuffles this stock into draw as Client already does |
| Repeat | Same id may be bought again only if `qty_offered` remains |

### Sell

| Rule | M1 |
|---|---|
| What | One owned **material** copy (`type=material`) from the run deck |
| Gain | **⌊`$` / 2⌋**, **min 1** (Test knob). `$1` hemp / iron scrap → **1** gold. **Supersedes** `19` “$1 scraps → 0” |
| Floor | After the sell, **material-card count in the run deck ≥ 3**. If the sell would leave 0, 1, or 2 materials, **refuse** (grey / ignore). This is the live floor — “cannot empty the deck of all materials” is implied |
| Count | Materials only. Runes / owner skills (if any later) do not count toward the 3 |
| On success | Remove that copy from `WagonStock`; `gold +=` gain; append `{ mat_id, gold_gained }` to `shop_sells` |
| Last copy of an id | Legal **if** the ≥3 material floor still holds |

Starter run deck is **8** materials ([19](19-own-basic-starter.md)). First sells are legal. The floor exists so a shop visit cannot strip the atelier.

### Shop 1–3 (graph law — not UI)

Count `shop` nodes on the **complete confirmed path** D1..(N−2). Authored so every full path has **1–3** shops (`22`). Client does **not** grey-out a shop option because `shops_taken == 3`. A path with 0 or 4 shops is a **map bug**.

### Ugly M1 UI

```
shop · N2
gold 12

OFFERS
  mat_hemp_plain     $1   own 2   [Buy]
  mat_cotton_spring  $2   own 1   [Buy]
  …

DECK (sell)
  mat_hemp_plain     own 2   sell +1   [Sell]
  …

[Exit]
```

Labels = ids + `$` + owned count. No shopkeeper portrait, no atelier chrome, no PixelLab icons this stamp (Nnoitra 1:1). Fancy titles **Later**.

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

Mat **add** = one copy into `WagonStock` (same deck as shop buy).

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

### Shop (when `day_action=shop` — enter and after each buy/sell/exit)

| Field | Type | Notes |
|---|---|---|
| `shop_node_id` | string | `N2` / `N7` / `N12` / `N15` / `N16` on C1. Equals `current_node_id` |
| `shop_stock` | object[] | `{ mat_id, price, qty_offered }` — live remaining offers. `mat_id` ∈ `11`. `price` = `11` `$` |
| `shop_buys` | object[] | `{ mat_id, price }[]` this visit, in order. `[]` if exit with no buy |
| `shop_sells` | object[] | `{ mat_id, gold_gained }[]` this visit, in order. `[]` if none |
| `gold` | int | Current purse after the last action. Also emit on other timetable stamps once Client has a purse |
| `gold_before` / `gold_after` | int | Visit open → after last buy/sell/exit. Floor 0 |
| `gold_delta` | int | Optional. `gold_after - gold_before` |
| `deck_material_count` | int | `type=material` cards in the between-beats run deck **after** the last action. After a legal sell: **≥ 3** |

Null the shop block when `day_action` is not `shop`.

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

`route_nodes[].ref_id` on event kinds = `evt_*` (not null). Shop kinds stay `ref_id` null; stock is `shop_stock` keyed by `shop_node_id`.

---

## Client needs (Ulquiorra)

Docs only this stamp — sketch for the **next** Client PR. No `src/` here. Hold until Jonathan stamps.

1. **Enter shop** only from current `kind=shop` node. No auto opening-shop. No shop on other kinds.
2. Load authored stock for that `node_id` (C1 table above). 4–6 `mat_*` from `11`. Show `mat_id` + `$` + owned count.
3. **Buy:** if gold ≥ price and `qty_offered` > 0 → pay, append one copy to `WagonStock`, decrement qty, log `shop_buys`.
4. **Sell:** if after-remove material count ≥ 3 → remove one owned material, add ⌊$ / 2⌋ min 1 gold, log `shop_sells`. Else refuse.
5. **Exit** with zero buys is legal. Exit resolves the day. `day_action=shop`. `phase=schedule`.
6. **Do not** grey-out shop graph picks because of visit count. Shop 1–3 is graph law (`22`).
7. **Do not** invent reshape, shop owners (`16`), forbidden unlock rooms, unique stock UI, or PixelLab icons.
8. **Enter event** only from current `kind=event` node. Read `ref_id` → `evt_*`. Show id + 1–2 choice buttons + result line.
9. Apply that choice’s deltas to the **same** gold purse / `WagonStock` / `25` reps. No craft session. Illegal pay-gold choices when gold is short. Mat-remove skip if missing or would break ≥3.
10. Dump the shop / event keys above **without SCRIPT ERROR**. Keep `#40`/`#41` route-map keys. Do **not** emit live `event_pool` / `day_assignments`.
11. Starting `gold` = **12** (knob). Floor 0. One purse.
12. M1 copy = type + id + catalog labels. Fancy titles / art **Later**.

---

## Test logs (Szayelaporro)

Log on shop enter, after each buy/sell, on shop exit, and on event choice. Required list lives in [20](20-harness-stamp.md). Sketch:

| Key | When / what |
|---|---|
| `day_action` | `shop` or `event` — matches `current_node_id` kind |
| `shop_node_id` / `shop_stock` / `shop_buys` / `shop_sells` | Shop visit |
| `gold` / `gold_before` / `gold_after` | Shop and event |
| `deck_material_count` | After shop or event mat change |
| `event_id` / `event_choice_id` / `event_deltas` / `event_resolved` | Event pick |
| `reps_before` / `reps_after` / `reps_delta` | Event with reps Δ |
| `route_path` / `current_node_id` / `route_nodes` | Unchanged law (`22` / `20`) |

**Asserts (shop + event)** — no SCRIPT ERROR path beyond existing smoke.

1. Every `shop_stock[].mat_id` ∈ `11`. C1 lists match the table (or a Test-knob swap inside commons + metal/stone, length 4–6).
2. Buy: `gold_after == gold_before - price` and `deck_material_count` +1 and `shop_buys` contains that `mat_id`.
3. Sell: `gold_after == gold_before + max(1, floor($/2))` and `deck_material_count` −1 and after-count **≥ 3**. A sell that would leave < 3 is refused (counts unchanged).
4. Exit with `shop_buys == []` is legal. `day_action == shop` still.
5. Event choice writes `event_id` + `event_choice_id` + `event_deltas` + `event_resolved == true`. Applied gold / mat / reps match the catalog (or documented skip).
6. `day_action` matches `current_node_id` kind (`shop` or `event`).
7. C1 event `route_nodes[].ref_id`: N4=`evt_c1_heat_mirage`, N6=`evt_c1_ashfall`, N10=`evt_c1_scrap_market`, N17=`evt_c1_salt_spray`.
8. No live `event_pool` / free `day_assignments`. No `phase=shop`. No reshape field.
9. Shop graph options are not banned by visit count.
10. Gold never < 0. Illegal pay-gold event choices do not apply.

---

## Explicit non-goals

- Reshape (free remove / transform without buy)
- Shop owners / shopkeeper chrome (`16`)
- Forbidden unlock rooms
- Unique / fancy stock UI
- PixelLab shop or event icons (Nnoitra 1:1 stays)
- Weighted roll-5 live shop (`19`) as the M1 visit
- Auto opening-shop / last-shop-before-boss (`21` shell)
- Live `event_pool` / free `E*` board
- Craft session / battle inside event M1
- Run-kill from a single event pick
- Branching event trees / art
- Elite telegraph on N5 (stays `22` open question)
- Adventurer catalog / Dex work
- A second deck type or a second gold purse
- Greying-out shop picks after k visits
- Inventing `$5` forbidden mats in C1 stock

---

## Later

- Shop owners (`16`) and owner-weighted stock
- Forbidden unlock rooms / $5 mats in the offer list
- Reshape
- Unique stock UI / fancy titles / PixelLab icons (Nnoitra parallel)
- Event art, branching trees, run-kill rows
- Prep-craft / rest-dig nodes (`22`)
- Enchantment / rune shop offers (`19` optional 6th slot)

---

## Open questions (Jonathan)

None this pass. Sell rate, shared gold purse, and C1 stock / event rows are **locked as M1 defaults**. Gold start **12**, sell **⌊$ / 2⌋ min 1**, event Δ, and stock ids inside `11` commons + metal/stone are **Test knobs** — retune without blocking Ulquiorra.

---

## Pointers

`22` route map · `20` harness · `11` materials · `19` starter deck + gold 12 · `27` run deck / `WagonStock` · `25` reps · `16` owners (Later) · `01` loop · `21` historical opening-shop · `10` ids · `pm/phase-1-plan` · `STAMP`
