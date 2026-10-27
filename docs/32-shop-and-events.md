# Market visit + event resolve (M1 + M2 tabs)

**Status:** **M2 visual leftovers landed** (#51–#55; tab chrome stamped **A**, no gens). **Doc id: `32`.** Filename kept (`32-shop-and-events`) — one market bible. **M1 market is closed.** M2 catalogs and the Staffs / Gear shelf-icon wire already landed (#46 Design, #47 Client, #48 art, #49 icon wire). Skills shelf icons landed (#51 Design, #52 art, #53 Client). Adventurer portrait sockets are [29](29-adventurer-catalog.md) and landed (#54 art / #55 Client), not a market catalog. Elite telegraph (N5) is the route-board badge in [22](22-chapter-schedule.md) — not a market socket.

**M1 is closed.** Materials tab + refresh + `market_bank_c1` + mat Enchant (`mat_ench_*`) + code-only shiny + text `evt_*` stay as stamped in #44 / shipped Client #45. Do **not** reopen M1. Screen labels that print those ids are the ugly record. Player words are [37](37-player-facing-chrome.md). Tab chrome **A**, banks, prices, and shiny-as-code stay.

**M2 (this revision):** three new tabs on the **same** market shell — **Staffs / Skills / Gear**. Catalogs below.

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
- Market-sold **equippable owner artifacts** as an **M1** catalog (M1 had none; **M2** `artifact_*` catalog is this stamp — [Market M2](#market-m2--staffs--skills--gear))

---

## LOCKED (Grimmjow — treat as stamped intent)

1. **Enter market** only when the **current** route node `kind=shop` resolves. Display / Design name = **market**. Wire `kind` stays `shop` (Client graph already locked). No auto opening-market before every order.
2. **M1 actions = Buy + Sell + Refresh + Enchant.** **Reshape** = **Later**. Enchant is a **materials-tab action**, not a new tab, not a craft session, not a separate day beat. Do not invent reshape UI this stamp.
3. **Chapter-shared market bank.** C1 has one authored pool (`market_bank_c1`) of `mat_*` from [11](11-materials.md). **All** `map_m1` market nodes (N2, N7, N12, N15, N16 — wire `kind=shop`) draw from it. Visible **shelf** per visit / after refresh = **4–6** draws. Bank is **larger than one shelf** and includes deferred-value / mid-late mats (real `11` ids). **Not** a frozen per-node 4–6 list as sole stock law.
4. **Refresh** replaces the whole visible shelf with a new draw from the bank (same shelf size 4–6). Gold cost **increases each successful refresh** this visit: `cost(n) = market_refresh_base + (n−1) × market_refresh_step`. M1 defaults **base 2**, **step 2** → **2, 4, 6, 8…** (Test knobs). `market_refresh_count` starts **0** each visit; increments only on a successful paid refresh. Cannot refresh if `gold < cost`. No debt. Refresh does **not** restock mid-shelf rows and does **not** resolve the day.
5. **Buy:** pay `$` from `11` from the **one** run gold purse; add **one copy** of that `mat_*` to the **run deck** (between-beats `WagonStock` / `27` — do **not** invent a second deck type). Decrement that offer’s `qty_offered`.
6. **Sell:** remove one owned copy of a `mat_*` from the run deck; gain **⌊`mat.$` / 2⌋** gold, **min 1**, from the **base** `$` (ignore `mat_ench_thrift` / `mat_ench_heavy` for sell rate M1 — Test knob). Cannot sell if the run deck would drop below **≥ 3 material cards** after the sell (soft floor). Materials only on the M1 tab — not runes / skills / staff / gear.
7. **Exit:** player leaves when done. **No forced buy.** Day still advances / node resolves like other primary day actions. Refresh and Enchant do **not** exit.
8. **Market visit count 1–3** stays **graph law** from `22` (count wire `kind=shop` nodes). Client must **not** grey-out market picks.
9. **Ugly M1 UI:** one **market shell**. M1 tab = materials (shelf + sell list + Refresh + Enchant + Exit). Enchanted copies show a **shiny color overlay** (ugly tint / modulate / `shiny` flag — **OK**). No owner chrome, no art. Fancy titles / Nnoitra polish **Later**.
10. **Market contents (Jonathan 2026-10-15 — LOCKED).** The owner looks here for **materials, staffs, skill cards, or gear/artifact**. **M1 tab = materials only** (buy/sell + refresh + **enchant** + chapter-shared bank). **M2** = staffs / skill cards / gear·artifact tabs on the **same market shell** (shell exists M1; extra category UIs + catalogs = **M2**, not a vague Later). Do **not** reopen this tab split.
11. **Enter event** only when the **current** route node `kind=event` resolves. M1 = **text resolve**, not battle craft.
12. C1 event nodes carry **`ref_id` → `evt_*`**. Catalog below (~7 rows). Outcomes may adjust **gold**, **add/remove one mat**, and/or **reps** ([25](25-reps-meter.md)). No craft session inside event M1.
13. Outcomes stay **mild and testable**. No run-kill from a single bad pick (that fail is **Later**). Prefer ±gold / ±1 mat / small reps swings.
14. **Ugly M1 UI:** event id + choice buttons (choice id + short label) + result line. Fancy art / branching trees **Later**.
15. **One gold purse** for the run. Market buy/sell/refresh/**enchant**, event gold, and (when Client pays them) mission gold all write the same `gold`. Start **12** ([19](19-own-basic-starter.md) — Test knob). Floor **0**.
16. **Owner power-up.** M1 = skills (`16`) + craft enc / staff-slot mentions (`10` / `12b`) + **material enchant** on this tab (`mat_ench_*`, this doc). **M2 catalogs (this stamp):** `staff_*` · `sk_*` · `artifact_*` — [Market M2](#market-m2--staffs--skills--gear).
17. Material icons stay **Nnoitra 1:1** for a new gen. PixelLab market / event art = **Later** (Nnoitra parallel). **Faces (stamped, Design #83, path A):** the 38 live `mat_*` pictures export to `assets/mat/<id>.png` ([36](36-craft-hand-cards.md)), one file for the hand and for this shelf. Tab chrome stays the text strip. That export is not a gen. Shiny stays code-only. Shiny overlay on enchanted mats = **Design lock**; M1 Client ugly tint is enough — do **not** block Client on art. **M2 restates:** shiny is **code-only** Client tint / shader on card art. **No** shiny PixelLab assets / overlay gens. Staff / skill / gear cards are **not** enchanted — they do **not** get shiny.
18. **Material enchant (M1 — LOCKED, M2 restated).** Enchant (Thrift / Heavy) = **materials only.** Staff / skill / gear tabs do **not** take `mat_ench_*`. No overwrite / stack. Distinct from craft `enc_*`. See [Enchant](#enchant-material--m1). **Not an open question — cut this way.** (Separate upgrade systems for gear Later if needed.)
19. **M2 Staffs tab.** Buy / sell `staff_*` that plug into [12b](12b-craft-slots.md) staff-slot law (raises `max_materials` / `max_runes` while assigned). **One staff equipped** (M2 default). Buy adds to the **run kit** (not the craft deck). Equip / unequip from this tab.
20. **M2 Skills tab.** Buy / sell existing owner `sk_*` from [27](27-craft-mode-stamina.md) into the `own_basic` **run kit** (run-long deck membership). Not a second skill system. Not one-shot burn. Other-owner passives in [16](16-shop-owners.md) stay Later.
21. **M2 Gear tab.** Buy / sell / equip `artifact_*` that power the **owner** (income, storage, soft utility). **2 gear slots.** No craft-session use. Prefix is `artifact_*` (crafted garment “gear” in `10` stays the resolver output).
22. **M2 refresh.** Refresh stays **materials shelf only**. Staff / skill / gear banks do **not** redraw mid-visit.
23. **Ugly M1/M2 UI:** one shell. Tab strip **Materials | Staffs | Skills | Gear**. Exit still resolves the node.

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
| Visit dump keys (new this PR — not in Client yet) | `market_*` (`market_bank_id`, `market_stock`, `market_refresh_*`, `market_enchants`, …) |
| Graph law “1–3 visits” | Count nodes with `kind=shop` |

Client maps: current `kind=shop` → open **market** shell. Dump still writes `day_action=shop`.

---

## Market visit

### Enter / exit

1. Current node is `kind=shop` and that day is being resolved (not a draft).
2. Client opens the ugly **market** shell (Materials tab). Draw the first **shelf** (4–6) from `market_bank_c1`. `market_refresh_count = 0`.
3. Player may **Buy**, **Sell**, **Refresh**, **Enchant**, and/or **Exit** with no purchase.
4. Exit (or equivalent Done) **resolves the node**. Day advances the same way as other primary actions. `route_path` already holds this node from the confirm; exit does not re-pick the graph.
5. Refresh and Enchant do **not** resolve the day.

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
| Day | Does **not** resolve the node. Player may Buy / Sell / Refresh / Enchant / Exit after |
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
| Enchanted copy | Still ⌊**base** `$` / 2⌋ min 1. Ignore `mat_ench_thrift` / `mat_ench_heavy` for sell rate M1 (Test knob — keep simple) |
| Floor | After the sell, **material-card count in the run deck ≥ 3**. If the sell would leave 0, 1, or 2 materials, **refuse** (grey / ignore). This is the live floor — “cannot empty the deck of all materials” is implied |
| Count | Materials only. Runes / owner skills (if any later) do not count toward the 3 |
| On success | Remove that copy from `WagonStock`; `gold +=` gain; append `{ mat_id, gold_gained }` to `market_sells` |
| Last copy of an id | Legal **if** the ≥3 material floor still holds |

Starter run deck is **8** materials ([19](19-own-basic-starter.md)). First sells are legal. The floor exists so a market visit cannot strip the atelier.

### Enchant (material — M1)

**LOCKED (Grimmjow).** Owner can **enchant** owned material cards so they get enhanced stats / special utility. **Not** a new tab. **Not** a craft session. **Not** a separate day beat. Market action on the **materials** tab — **Enchant** alongside Buy / Sell / Refresh / Exit.

**Name:** this is **material enchant** (`mat_ench_*`). Craft enchantments / runes stay `enc_*` ([13](13-enchantments.md) · [10](10-catalog-overview.md)). Do **not** merge the two systems.

#### When / how

1. Player picks **one owned** `mat_*` copy from the run deck (`WagonStock` / [27](27-craft-mode-stamina.md)).
2. Picks **one** enhance option from the M1 catalog below.
3. Pays the enchant fee from the **one** gold purse.
4. That card **copy** becomes enchanted: store `mat_enchant_id` on the card instance + `shiny=true`.
5. Does **not** resolve the day (same as Refresh). Player may Buy / Sell / Refresh / Enchant / Exit after.

#### M1 enhance catalog

Jonathan’s two examples — small catalog. Fees are **Test knobs**.

| `mat_enchant_id` | Label | Effect (Design) | Fee (Test knob default) |
|---|---|---|---:|
| `mat_ench_thrift` | Thrift | **Reduced cost** — this card’s effective `$` for craft spend / any cost that reads mat `$` becomes **⌊$/2⌋, min 1**. Tag contribution unchanged. | **2** |
| `mat_ench_heavy` | Heavy | **Increased cost, double stat** — effective `$` = **2 ×** base `$`; tag / synergy contribution in craft counts **double** (as if two copies of that mat’s tags for synergy thresholds). | **3** |

**Cost** = the material’s `$` when Client / craft reads it for spend or value (play cost, other `$` reads). **Stat** / tag contribution = how that mat counts toward synergy / tag stacks in craft — existing bag-count law in [10](10-catalog-overview.md) / [11](11-materials.md) / [14](14-synergies.md) / [27](27-craft-mode-stamina.md). Do **not** invent a new combat system for this stamp.

#### Rules

| Rule | M1 |
|---|---|
| Who | **Materials only** (`type=material` / `mat_*`). Cannot enchant runes / skills / staff / gear |
| Copies | One owned **copy**. Enchant stamps that instance |
| Stack | **One enchant per card copy.** Already enchanted (`mat_enchant_id != null`) → **refuse**. No overwrite / multi-stack this stamp |
| Gold | Cannot enchant if `gold < fee`. No debt |
| On success | `gold -= fee`; stamp `mat_enchant_id` + `shiny=true` on that copy; append `{ mat_id, mat_enchant_id, fee }` to `market_enchants` |
| Sell | Still ⌊**base** `$` / 2⌋ min 1. Ignore thrift / heavy for sell rate M1 (Test knob — keep simple). Soft floor ≥3 unchanged |
| Refresh / bank / buy | Unchanged. Enchant is **not** a bank offer |
| Exit | Still resolves the node. Enchant does **not** exit |
| Day | Does **not** resolve the node (same as Refresh) |

#### Shiny overlay (Design lock)

Enchanted material cards **must** show a **shiny color overlay** so they’re readable as enchanted. M1 Client = ugly tint / modulate / simple `shiny` flag — **OK**. Dump / UI flag `shiny` or derive from `mat_enchant_id != null`. Nnoitra polish / PixelLab = **Later**. Do **not** block Client on art.

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

DECK (sell / enchant)
  mat_hemp_plain     own 2   sell +1   [Sell]  [Enchant]
  mat_wool_grey      own 1   shiny     [Sell]          ← already enchanted; Enchant refused
  …

[Refresh $2]   [Enchant]   [Exit]
```

Labels = ids + `$` + owned count + next refresh cost + shiny / `mat_enchant_id` when set. Enchant picker = owned `mat_*` copy + enhance id (`mat_ench_thrift` / `mat_ench_heavy`) + fee. No market-owner portrait, no atelier chrome, no PixelLab icons this stamp (Nnoitra 1:1). Fancy titles / Nnoitra shine **Later**. Ugly tint on `shiny` is enough.

### Market tabs (contents)

The market is where the owner looks for **materials, staffs, skill cards, or gear/artifact**.

| Tab | Milestone | Notes |
|---|---|---|
| **Materials** | **M1 — shipped** (#45) | Buy / sell / refresh / **enchant** + `market_bank_c1`. Do not reopen |
| **Staffs** | **M2 — this stamp** | Same shell. Catalog `staff_*` below. Staff-slot law in `12b` |
| **Skills** | **M2 — this stamp** | Same shell. Sells existing `sk_*` from `27` into the `own_basic` kit. Not a second skill system |
| **Gear** | **M2 — this stamp** | Same shell. Catalog `artifact_*` below. Owner utility — not craft mats |

**LOCKED (Jonathan 2026-10-15):** M1 = materials only. M2 = the other three tabs on this shell. Do not hide the shell behind a different scene type in M2 — extra tabs plug into this visit. **M1 Client #45 must not grow these tabs** — M2 Client after this stamp.

---

## Owner power-up (gear / staff / items)

**LOCKED — M1 vs M2 (Jonathan 2026-10-15 / Grimmjow M2 catalogs 2026-10-16).**

| Already covered (do not invent a parallel) | Where |
|---|---|
| Owner **skills** (reroll, income floor, hand / storage) | [16](16-shop-owners.md) — player clothier kit. Phase-1 = `own_basic` (none). Other owners Later. **M2 skill tab** sells the existing `sk_*` craft cards from [27](27-craft-mode-stamina.md) into that kit — not a second system |
| Craft **enchantments / runes** (`enc_*`) | [10](10-catalog-overview.md) · [13](13-enchantments.md) · stamina hand (`27`) — **not** `mat_ench_*` |
| **Material enchant** (`mat_ench_*`) | This doc — market action on the M1 materials tab **only**. Distinct from craft `enc_*`. Staff / skill / gear do **not** take `mat_ench_*` |
| **Staff-slot** raises to `max_materials` / `max_runes` | [12b](12b-craft-slots.md) — **M2 live unlock** via `staff_*` below. Does **not** revive 2m1r slot-fill UI |
| **Owner artifacts** (`artifact_*`) | **M2 catalog** below. Prefix locked `artifact_*` (not `gear_*` — `10` “Final gear” is the crafted garment) |

**M1 (LOCKED / shipped #45):** materials tab only. Do **not** reopen.

**M2 (this stamp):** catalogs + tab law below. Forbidden rooms / `$5` mats stay out (Later). Do **not** invent staff / skill / gear enchant. Do **not** sell `enc_*` runes on these tabs (`19` optional 6th enc slot stays Later).

---

## Market M2 — Staffs / Skills / Gear

**Status:** Grimmjow Design 2026-10-16. Catalog landed with #46 (Client #47, staff / artifact icons #48 / #49). Same visit, same shell, same `kind=shop` / `day_action=shop` / one gold purse / Exit-resolves-node as M1. Do **not** reopen this catalog. Visual leftovers for the 2026-10-20 stamp are [below](#m2-visual-leftovers-2026-10-20).

### Shared M2 market laws (inherit M1)

| Rule | M2 |
|---|---|
| Enter | Current node `kind=shop` only. Display **market**. Wire `day_action=shop` |
| Shell | One screen. Tab strip **Materials \| Staffs \| Skills \| Gear** |
| Gold | The **one** run purse. Floor 0. No debt |
| Buy | Pay catalog `$` if `gold ≥ price` and `qty_offered > 0` (plus unique-owned checks below). No debt |
| Sell | Remove one owned copy; gain **⌊`$` / 2⌋**, **min 1**, from that row’s catalog `$`. **No** ≥3 material floor on these tabs (that floor is materials only) |
| Refresh | **Materials shelf only.** Staff / skill / gear banks do **not** redraw mid-visit. Refresh cost / count unchanged |
| Enchant | **Materials tab only.** Staff / skill / gear do **not** take `mat_ench_*`. No shiny on these cards |
| Shiny | Code-only Client tint / shader on **enchanted material** card art. **No** PixelLab shiny overlay gens. M2 cards are not enchanted → not shiny |
| Exit | Still the only action that resolves the node. Buy / sell / equip / refresh / enchant do **not** exit |
| Banks | Chapter-shared. **Do not deplete** on buy (same as `market_bank_c1`). Each visit shows the **full** M2 bank for that tab (`qty_offered` **1** per row — Test knob). No first-draw seeds (catalogs are small) |
| M1 tab | Unchanged. Do not reopen materials / refresh / enchant / `evt_*` |

### Run kit vs run deck

| What | Where it lives | Craft session? |
|---|---|---|
| `mat_*` / bought `sk_*` | Between-beats **run deck** (`WagonStock` / `27`) | Yes — shuffle into hand. `type=material` / `type=skill` |
| `staff_*` / `artifact_*` | **Run kit** (owned list + equip slots). **Not** the craft deck. Do **not** invent a second deck type | **No** — never `cards_played`. Staff raises caps; artifacts apply owner utility |

`own_basic` starts with **empty** staff / artifact kit and **0** `sk_*` ([16](16-shop-owners.md) / [19](19-own-basic-starter.md)).

### Enchant cut (M2 restated)

**LOCKED.** Enchant (Thrift / Heavy) = materials only. Staff / skill / gear tabs have **no** Enchant button, accept **no** `mat_ench_*`, and do **not** stamp `shiny`. Separate gear-upgrade systems = Later if needed. Not an open question.

### Shiny (M2 restated)

Already M1 law; restated so M2 card art does not grow a second shine pipeline. Enchanted **materials** may show code-only tint. No shiny PixelLab assets / overlay gens for staff, skill, or gear — and those cards are not enchanted anyway.

---

### Staffs tab

**Job:** sell / buy **staff** items that plug into craft **staff-slot** law in [12b](12b-craft-slots.md) — raises `max_materials` / `max_runes` while assigned.

Investigated: `12b` names staff skills **Apprentice Hands** (+1 `max_materials`) and **Rune Desk** (+1 `max_runes`). No `staff_*` ids existed. `10` / `16` mention staff only as that Later unlock. Live craft is stamina (`27`); 2m1r slot-fill UI stays superseded. M2 staff is the unlock that makes the 12b numbers **move**.

#### Equip rule (M2 — pick locked)

**One staff equipped.** Buy adds the `staff_id` to the **run kit** (owned). Equip / unequip / swap from the **Staffs tab** (same visit — no separate inventory scene). Buy does **not** auto-equip. Unequip → default caps. Selling an equipped staff **unequips first**, then sells.

#### Cap law (12b plug-in)

| Field | Default (`own_basic`, no staff) | With staff |
|---|---:|---|
| `player.max_materials` | **2** | 2 + equipped staff’s `Δ_materials` |
| `player.max_runes` | **1** | 1 + equipped staff’s `Δ_runes` |

- Live craft stays stamina (`27`). Do **not** revive 2m1r slot-fill UI.
- **M2 Client craft:** per-zone bag respects the caps (`len(materials) ≤ max_materials`, `len(runes) ≤ max_runes`). Stamina still gates. 27’s “no hard material-slot cap” was the **M1-until-staff** gap — not a forever law once a staff can raise the number.
- M1 Client #45 may keep ignoring these fields until the M2 Client lands.
- Cairnplate / any unique that needs `max_materials ≥ 3` ([12b](12b-craft-slots.md)) becomes legal with a staff that raises materials to ≥ 3.
- Owner-skill Extra Seam / Second Rune stay **Later** (other owners / later stamp). Do **not** also sell them on the Skills tab this pass — slot raises come from staff.

#### Staff catalog (`market_staff_bank_c1`) — **5** ids

Prices are **Test knobs**. All ids are new this stamp. Nnoitra arts these after lock.

| `staff_id` | Label | 12b skill | `Δ_materials` | `Δ_runes` | `$` |
|---|---|---|---:|---:|---:|
| `staff_apprentice` | Apprentice | Apprentice Hands | +1 | 0 | **4** |
| `staff_rune_desk` | Rune Desk | Rune Desk | 0 | +1 | **5** |
| `staff_loom_pair` | Loom Pair | both | +1 | +1 | **8** |
| `staff_third_seam` | Third Seam | Apprentice Hands ×2 | +2 | 0 | **7** |
| `staff_rune_pair` | Rune Pair | Rune Desk ×2 | 0 | +2 | **8** |

**5 rows.** Full bank = the shelf every visit. `qty_offered` **1**. Bank does not deplete.

| Rule | M2 |
|---|---|
| Unique | **One owned copy per `staff_id`.** Already owned → Buy refused (grey / ignore). Sell, then you may buy it again later |
| Stack | Equipped staff’s Δ only. Do **not** stack two staffs (one slot) |
| Sell | ⌊`$` / 2⌋ min 1. Unequip if equipped |
| Enchant / shiny | **No** |
| Craft deck | **No** — never `type=staff` in `cards_played` |

Worked caps (default 2 / 1 + Δ):

| Equipped | `max_materials` | `max_runes` |
|---|---:|---:|
| *(none)* | 2 | 1 |
| `staff_apprentice` | 3 | 1 |
| `staff_rune_desk` | 2 | 2 |
| `staff_loom_pair` | 3 | 2 |
| `staff_third_seam` | 4 | 1 |
| `staff_rune_pair` | 2 | 3 |

#### Ugly Staffs UI

```
market · N2
gold 12
[Materials] [Staffs] [Skills] [Gear]

SHELF
  staff_apprentice    $4   Δm+1        [Buy]
  staff_rune_desk     $5   Δr+1        [Buy]
  staff_loom_pair     $8   Δm+1 Δr+1   [Buy]
  staff_third_seam    $7   Δm+2        [Buy]
  staff_rune_pair     $8   Δr+2        [Buy]

KIT  equipped: staff_apprentice    max_m 3  max_r 1
  staff_apprentice    equipped   [Unequip]  sell +2   [Sell]

[Exit]
```

Labels = ids + `$` + Δ + equipped mark. No Refresh / Enchant on this tab. No owner chrome.

---

### Skill cards tab

**Job:** market offers for owner **skill cards** tied to `16` / `27` (`sk_*`). Phase-1 player is `own_basic` (starts with **none**). Other owners Later.

Investigated: [16](16-shop-owners.md) is the owner-skill **law** (kit on the clothier) but has **no** `sk_*` ids. [27](27-craft-mode-stamina.md) already stamped six draft `sk_*` (session cards, stamina cost). [29](29-adventurer-catalog.md) / [10](10-catalog-overview.md): `sk_*` = owner craft skills; `ask_*` = adventurer battle skills. Do **not** invent a second skill system.

#### Kit rule (M2 — pick locked)

**Buy into the run kit** (run-long). Matches `16` “permanent or run-long kit.” **Not** one-shot burn (day-generated consumables stay Later in `20` / `27`).

On success: pay `$`; append **one** `type=skill` copy (`sk_*`) to the **run deck** (`WagonStock` / `27`). Next craft session shuffles it into draw like any other deck card. Play → discard → reshuffle (`27`). Selling removes one owned copy from the deck.

`own_basic` may buy these extras without unlocking other owners. [16](16-shop-owners.md) owner-locked passives (broker free-reroll, tithe income, packrat hand) stay **Later** as other-owner kit — M2 income / storage / soft utility is the **Gear** tab, not a parallel `sk_*` set.

#### Skill catalog (`market_skill_bank_c1`) — **6** ids

**Existing** `27` ids. Do not rename. Gold `$` is a **Test knob**, scaled from that card’s stamina cost (1 → **3**, 2 → **5**, 3 → **7**). Effects stay the `27` draft lines.

| `skill_id` | Stamina (27) | `$` | Effect (from `27`) |
|---|---:|---:|---|
| `sk_next_mat_free` | 1 | **3** | Next material play costs 0 stamina |
| `sk_touch_up` | 1 | **3** | +1 to one chosen stat on one already-played material in the **target zone** |
| `sk_steady_hand` | 1 | **3** | Ignore first negative synergy roll hint this **target** piece (does **not** skip rarity rules) |
| `sk_metal_str_double` | 2 | **5** | Double STR contribution from Metal-tagged materials already in the **target** piece |
| `sk_wild_to_earth` | 2 | **5** | Consume 1 Wild material in session → add 1 random Earth material into hand |
| `sk_deep_dig` | 3 | **7** | Refresh hand; draw +1 extra |

**6 rows.** Full bank = the shelf every visit. `qty_offered` **1**. Bank does not deplete.

| Rule | M2 |
|---|---|
| Duplicates | **Allowed** — these are deck cards. Second buy of the same `sk_*` adds a second copy |
| Sell | ⌊`$` / 2⌋ min 1. No ≥3 floor (skills do not count toward the material floor) |
| Enchant / shiny | **No** |
| Equip | **None** — ownership = deck membership |
| Other `sk_*` | Do not invent Extra Seam / Second Rune / broker-reroll cards this stamp |

#### Ugly Skills UI

```
market · N2
gold 12
[Materials] [Staffs] [Skills] [Gear]

SHELF
  sk_next_mat_free      $3   [Buy]
  sk_touch_up           $3   [Buy]
  sk_steady_hand        $3   [Buy]
  sk_metal_str_double   $5   [Buy]
  sk_wild_to_earth      $5   [Buy]
  sk_deep_dig           $7   [Buy]
  (shelf face: assets/m2-market/<skill_id>.png when present; else this id label)

DECK (skills)
  sk_next_mat_free      own 1   sell +1   [Sell]

[Exit]
```

---

### Gear / artifact tab

**Job:** new stamped catalog. Power the **owner** (not craft mats): income, storage, soft utility. No craft-session use. Nnoitra arts these ids after stamp.

**Prefix lock:** `artifact_*`. Tab display name = **Gear**. Do **not** use `gear_*` — [10](10-catalog-overview.md) “Final gear” is the crafted garment.

#### Equip rule (M2 — pick locked)

**2 gear slots.** Buy adds the `artifact_id` to the **run kit**. Equip / unequip / swap from the **Gear tab**. Buy does **not** auto-equip. Up to **two** different artifacts equipped. Selling an equipped artifact **unequips that slot**, then sells. Empty slots are legal.

#### Artifact catalog (`market_artifact_bank_c1`) — **8** ids

Prices are **Test knobs**. All ids are new this stamp. Effects apply **while equipped** (unequip → lose the bonus).

| `artifact_id` | Label | Effect (Design) | `$` |
|---|---|---|---:|
| `artifact_coin_purse` | Tithe Purse | +1 gold on every order / mission payout this run | **5** |
| `artifact_ledger_clip` | Ledger Clip | +1 gold when **entering** a market visit | **4** |
| `artifact_pack_strap` | Pack Strap | +1 `hand_size` (5 → 6) | **6** |
| `artifact_needle_tin` | Needle Tin | `dig_refresh_cost` −1 (min **1**) | **6** |
| `artifact_wagon_hook` | Wagon Hook | Material **sell** gain +1 (still min 1; still from **base** `$`; ignore thrift/heavy) | **5** |
| `artifact_stamp_case` | Stamp Case | +1 reps when an order rates **S** or **A** | **6** |
| `artifact_road_charm` | Road Charm | Event gold **losses** reduced by 1 (min 0 applied loss) | **4** |
| `artifact_oil_rag` | Oil Rag | +2 `stamina_start` per craft session (not × N) | **5** |

**8 rows.** Full bank = the shelf every visit. `qty_offered` **1**. Bank does not deplete.

These are the M2 stand-ins for `16` tithe / packrat-style utility so `own_basic` can buy them without unlocking other owners. They are **not** `sk_*` and **not** staff-slot raises.

| Rule | M2 |
|---|---|
| Unique | **One owned copy per `artifact_id`.** Already owned → Buy refused |
| Slots | **2.** Cannot equip the same id twice (only one copy exists) |
| Craft | **No** — never `cards_played`. Do not sew artifacts into a garment |
| Enchant / shiny | **No** |
| Sell | ⌊`$` / 2⌋ min 1. Unequip if equipped |
| Stack | Two **different** artifacts stack. Staff Δ + artifact utility stack (different systems) |

#### Ugly Gear UI

```
market · N2
gold 12
[Materials] [Staffs] [Skills] [Gear]

SHELF
  artifact_coin_purse    $5   [Buy]
  artifact_ledger_clip   $4   [Buy]
  artifact_pack_strap    $6   [Buy]
  artifact_needle_tin    $6   [Buy]
  artifact_wagon_hook    $5   [Buy]
  artifact_stamp_case    $6   [Buy]
  artifact_road_charm    $4   [Buy]
  artifact_oil_rag       $5   [Buy]

KIT  slots 1/2
  artifact_pack_strap    slot 1   [Unequip]  sell +3   [Sell]

[Exit]
```

---

### Nnoitra art ids (stable — lock before gens)

Ping **Harribel** before PixelLab / chrome gens. Material icons stay 1:1. No shiny overlay gens.

**Staffs (5):** `staff_apprentice` · `staff_rune_desk` · `staff_loom_pair` · `staff_third_seam` · `staff_rune_pair`

**Gear (8):** `artifact_coin_purse` · `artifact_ledger_clip` · `artifact_pack_strap` · `artifact_needle_tin` · `artifact_wagon_hook` · `artifact_stamp_case` · `artifact_road_charm` · `artifact_oil_rag`

**Skills (6, existing):** `sk_next_mat_free` · `sk_touch_up` · `sk_steady_hand` · `sk_metal_str_double` · `sk_wild_to_earth` · `sk_deep_dig` — shelf-face cut is locked in [M2 visual leftovers](#m2-visual-leftovers-2026-10-20). Do not invent a second id. No shiny gens.

**Tab chrome:** stamped **A** (no gens). Keep the text strip.

Owner chrome / shopkeeper portraits stay **out** (non-goal).

---

## M2 visual leftovers (2026-10-20)

**Status:** Landed (#51–#55). Tab chrome stamped **A** (no gens). Does **not** reopen M1 (materials tab, refresh, `market_bank_c1`, mat Enchant, code-only shiny, text `evt_*`). Does **not** invent a new `sk_*`, staff, artifact, or tab. Staff / artifact 96×96 faces already on disk (`assets/m2-market/`, #48 / #49) stay the art language for the skills faces below.

Shiny stays **code-only** on enchanted **materials**. Skills, staffs, and gear never take `mat_ench_*` and never get a shiny PixelLab overlay.

### Skills shelf icons — lock

Exactly these six, already the Skills tab / [27](27-craft-mode-stamina.md) catalog. Do not rename. Do not add a seventh.

| `skill_id` | Stamina (27) | `$` (Test knob) |
|---|---:|---:|
| `sk_next_mat_free` | 1 | **3** |
| `sk_touch_up` | 1 | **3** |
| `sk_steady_hand` | 1 | **3** |
| `sk_metal_str_double` | 2 | **5** |
| `sk_wild_to_earth` | 2 | **5** |
| `sk_deep_dig` | 3 | **7** |

Effects stay the `27` lines in the Skills catalog above. Gold `$` stays a Test knob.

**Art cut** (match stamped staff / artifact shelf faces and the armor Pro Flash grain):

| | |
|---|---|
| Tool / grain | PixelLab **Pro Flash 96×96 soft-stipple** |
| Subject | Item / skill-card **face only** |
| Leave out of the PNG | Card chrome frame. Shiny overlay. A second, smaller tag-chip |
| Path | `assets/m2-market/<skill_id>.png` (same folder as `staff_*` / `artifact_*`) |
| Wire path | `res://assets/m2-market/<skill_id>.png` |

**Wire contract (Ulquiorra — after stamp, not this PR).** Skills shelf rows that today show the text `sk_*` use a `TextureRect` (or the same control Staffs / Gear already use for `assets/m2-market`) loading that path **when the file is present**. Missing file → keep the id label. Price, owned count, Buy, and Sell stay. Skills stay **deck cards** (buy into the run deck). **No** equip UI. **No** Enchant on the Skills tab. Do **not** invent a second icon size, and do **not** gen a 16×16 tag-chip for these six.

Kit / deck rows may stay text. This stamp is the **shelf face** only.

### Tab chrome — Jonathan stamps A or B

Today the Client tab strip is text: **Materials | Staffs | Skills | Gear**. Fancy chrome was Later. This stamp picks whether it stays Later for this wave.

**A — Skip chrome this wave (Design default).** Keep the Client text strip. No tab-chip gens. Nnoitra stays idle on chrome. Skills faces and the [29](29-adventurer-catalog.md) portrait brief still proceed.

**B — Ship chrome.** Nnoitra gens after stamp (Harribel soft-gate first). Brief only — do not gen in this PR:

| | |
|---|---|
| Chips | **4.** Materials · Staffs · Skills · Gear. No fifth tab. No portraits, no owner chrome, no event art |
| Ids / paths | `tab_materials` · `tab_staffs` · `tab_skills` · `tab_gear` → `assets/m2-market/tab_<name>.png` |
| Size / grain | **Flat 16×16 Pro Flash.** Same small-chip language as the stamped monostack **tag chips**, not the 96×96 shelf icons. A 96×96 tab would be a second shelf icon sitting in the strip |
| Selected vs idle | **One frame each. Selected = Client modulate** (same family as the text tab’s selected tint). Not a second painted frame. Four files, not eight |
| Wire | Existing tab control shows the 16×16 chip. Word labels may stay beside the chip. Missing file → text label, as today |

Jonathan writes **A** or **B** on the stamp. **A** does not authorize chrome gens. Silence is not **B**.

### Not in this section

Adventurer portraits: [29](29-adventurer-catalog.md) **Portrait sockets**. Owner / shopkeeper chrome stays out. Event art stays Later. Material icons stay Nnoitra 1:1.

---

## Event resolve

> **Until-M2 pool — locked, [33](33-until-m2-tuning.md).** Which `evt_*` resolves is that pool (weights + day-band), not a script that names the day. Outcome ints in the catalog below are the until-M2 lock (no integer edits here). The free `E*` board stays dead. Decision **A** draws (Client #73). Decision **B** was not taken.

### Enter

1. Current node is `kind=event` and that day is being resolved (not a draft).
2. Read `ref_id` → `evt_*` from the node row. **Prefer `ref_id`** over a per-node unique event. Nodes may share a catalog row on later maps; C1 uses one row each. Under [33](33-until-m2-tuning.md) decision **A** (Client #73) this step is the pool draw; the `ref_id` stays a sample legal row.
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

**Test knob:** gold / reps ints and which `mat_*` is added/removed may retune inside “mild” (±1..3 gold, ±1 reps, ±1 mat from `11` commons/metal/stone). Do not add a run-kill row without a Design stamp. [33](33-until-m2-tuning.md) decision 1, if accepted, stops that retune for these seven rows. The ints below do not change in that proposal.

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

### Market (when `day_action=shop` — enter and after each buy/sell/refresh/enchant/exit)

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
| `market_enchants` | object[] | `{ mat_id, mat_enchant_id, fee }[]` this visit, in order. `[]` if none |
| `gold` | int | Current purse after the last action. Also emit on other timetable stamps once Client has a purse |
| `gold_before` / `gold_after` | int | Visit open → after last buy/sell/refresh/enchant/exit. Floor 0. After enchant, same pair as other market spends |
| `gold_delta` | int | Optional. `gold_after - gold_before` |
| `deck_material_count` | int | `type=material` cards in the between-beats run deck **after** the last action. After a legal sell: **≥ 3** |

**Card / deck representation:** enchanted copies in `WagonStock` / dump carry `mat_enchant_id` (+ optional `shiny: true`). Client may dump `shiny` or derive it from `mat_enchant_id != null`.

Null the market block when `day_action` is not `shop`. **Reshape is Later** — do not emit a reshape field. Do not emit staff/skill/gear enchant fields.

### Market M2 tabs (when `day_action=shop` — M2 Client; M1 #45 may omit)

Emit on enter and after each buy/sell/equip/exit on these tabs. Materials keys above stay Required.

| Field | Type | Notes |
|---|---|---|
| `market_tab` | enum | `materials` \| `staffs` \| `skills` \| `gear` — current tab. Optional on M1 dumps |
| `market_staff_bank_id` | string | C1 = **`market_staff_bank_c1`** |
| `market_staff_stock` | object[] | `{ staff_id, price, qty_offered }[]`. Length **5**. Every `staff_id` ∈ staff catalog. `price` = catalog `$` |
| `market_staff_buys` | object[] | `{ staff_id, price }[]` this visit. `[]` if none |
| `market_staff_sells` | object[] | `{ staff_id, gold_gained }[]` this visit. `[]` if none |
| `staff_owned` | string[] | Owned `staff_id`s this run (unique) |
| `staff_equipped_id` | string\|null | The one equipped staff, or null |
| `max_materials` | int | **2** + equipped staff `Δ_materials` |
| `max_runes` | int | **1** + equipped staff `Δ_runes` |
| `market_skill_bank_id` | string | C1 = **`market_skill_bank_c1`** |
| `market_skill_stock` | object[] | `{ skill_id, price, qty_offered }[]`. Length **6**. Every `skill_id` ∈ `27` table above |
| `market_skill_buys` | object[] | `{ skill_id, price }[]` this visit. `[]` if none |
| `market_skill_sells` | object[] | `{ skill_id, gold_gained }[]` this visit. `[]` if none |
| `deck_skill_count` | int | `type=skill` cards in the run deck after the last action |
| `market_artifact_bank_id` | string | C1 = **`market_artifact_bank_c1`** |
| `market_artifact_stock` | object[] | `{ artifact_id, price, qty_offered }[]`. Length **8**. Every `artifact_id` ∈ artifact catalog |
| `market_artifact_buys` | object[] | `{ artifact_id, price }[]` this visit. `[]` if none |
| `market_artifact_sells` | object[] | `{ artifact_id, gold_gained }[]` this visit. `[]` if none |
| `artifact_owned` | string[] | Owned `artifact_id`s this run (unique) |
| `artifact_equipped_ids` | string[] | Length **0..2**. Distinct ids ⊆ `artifact_owned` |

`gold` / `gold_before` / `gold_after` / `gold_delta` already cover M2 spends. `deck_material_count` unchanged (skills / staff / artifacts do not count).

M1 Client #45 that omits the M2 block is still legal. M2 Client **must** emit it on `day_action=shop`.

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
4. **Sell:** if after-remove material count ≥ 3 → remove one owned material, add ⌊**base** $ / 2⌋ min 1 gold (ignore thrift/heavy), log `market_sells`. Else refuse.
5. **Refresh:** if gold ≥ `market_refresh_cost_next` → pay, increment `market_refresh_count`, replace the whole shelf from the bank, log `market_refreshes`. Else refuse. Does not exit.
6. **Enchant:** pick one owned `mat_*` copy + one enhance id (`mat_ench_thrift` / `mat_ench_heavy`). If gold ≥ fee and the copy is not already enchanted → pay, stamp `mat_enchant_id` + `shiny=true` on that deck copy, log `market_enchants`. Else refuse (already enchanted / short gold / not a material). Does not exit. Materials only — do **not** invent staff / skill / gear enchant this stamp.
7. **Exit** with zero buys is legal. Exit resolves the day. `day_action=shop`. `phase=schedule`.
8. **Do not** grey-out market graph picks because of visit count. Visits 1–3 is graph law (`22`).
9. **Shell:** one market screen. M1 live tab = materials (Buy / Sell / Refresh / Enchant / Exit). Enchanted cards show a **shiny color overlay** (ugly tint / modulate / `shiny` flag — OK). Do **not** invent staff / skill-card / gear tabs in the M1 Client (those are **M2**). No reshape, owner chrome (`16`), forbidden rooms, PixelLab icons, or a second scene type. Do not block Client on Nnoitra shine.
10. **Enter event** only from current `kind=event` node. Read `ref_id` → `evt_*`. Show id + 1–2 choice buttons + result line.
11. Apply that choice’s deltas to the **same** gold purse / `WagonStock` / `25` reps. No craft session. Illegal pay-gold choices when gold is short. Mat-remove skip if missing or would break ≥3.
12. Dump the `market_*` / event keys above **without SCRIPT ERROR**. Keep `#40`/`#41` route-map keys and wire `day_action=shop`. Do **not** emit live `event_pool` / `day_assignments`. Enchanted deck copies carry `mat_enchant_id` (+ optional `shiny`).
13. Starting `gold` = **12** (knob). Floor 0. One purse. Refresh knobs base **2** / step **2**. Enchant fees **2** (Thrift) / **3** (Heavy).
14. M1 copy = display type **market** + id + catalog labels. Fancy titles / art **Later**. Shiny overlay = ugly tint M1.

### Client needs (Ulquiorra) — M2 tabs

Catalog + tab shell shipped (#47). Staff / artifact shelf icons shipped (#49). Skills shelf faces shipped (#51 / #52 / #53). Tab chrome stamped **A** (no gens, no tab chips). Do not grow #45. Do not reopen M1.

15. **Same shell.** Tab strip Materials | Staffs | Skills | Gear. Enter still only from `kind=shop`. `day_action=shop`. Exit still resolves the node.
16. **Do not** put Enchant or Refresh on Staffs / Skills / Gear. Refresh still redraws **materials** only. Enchant still materials only (`mat_ench_*`). No `mat_ench_*` / `shiny` on staff, skill, or artifact instances.
17. **Staffs:** load `market_staff_bank_c1` (5 rows). Buy → run kit (not `WagonStock`). Refuse if already owned or `gold < price`. Sell ⌊$/2⌋ min 1; unequip if equipped. **One** `staff_equipped_id`. Equip / unequip from this tab; buy does not auto-equip. Dump `max_materials` / `max_runes` = 2/1 + Δ.
18. **M2 craft:** per-zone bag `len(materials) ≤ max_materials`, `len(runes) ≤ max_runes`. Do not revive 2m1r slot UI. Stamina still gates.
19. **Skills:** load `market_skill_bank_c1` (6 existing `sk_*`). Buy → one `type=skill` copy on `WagonStock`. Duplicates legal. Sell removes one copy. No equip. Next craft shuffles them (`27`).
20. **Gear:** load `market_artifact_bank_c1` (8 `artifact_*`). Buy → run kit. Refuse if already owned. **2** slots (`artifact_equipped_ids`). Equip from this tab. Apply listed owner utility **while equipped** only. Never `cards_played`.
21. Dump the M2 keys above **without SCRIPT ERROR**. Keep M1 `market_*` / event keys. Gold is the one purse.
22. Ugly ids + `$` + owned / equipped marks. No owner chrome. Staff / artifact shelf icons are the #49 wire. Skills shelf faces are the #53 wire. Tab chrome stamped **A** — no tab-chip gens. Harribel before further gens.

---

## Test logs (Szayelaporro)

Log on market enter, after each buy/sell/refresh/enchant, on market exit, and on event choice. Required list lives in [20](20-harness-stamp.md). Sketch:

| Key | When / what |
|---|---|
| `day_action` | `shop` or `event` — wire; matches `current_node_id` kind. Display Market when `shop` |
| `market_node_id` / `market_bank_id` / `market_stock` / `market_buys` / `market_sells` | Market visit |
| `market_refresh_count` / `market_refresh_cost_next` / `market_refreshes` | After enter and each refresh |
| `market_enchants` | After each enchant — `{ mat_id, mat_enchant_id, fee }[]` |
| `gold` / `gold_before` / `gold_after` | Market and event (enchant writes the same pair) |
| `deck_material_count` | After market or event mat change |
| `mat_enchant_id` / `shiny` | On enchanted deck copies |
| `event_id` / `event_choice_id` / `event_deltas` / `event_resolved` | Event pick |
| `reps_before` / `reps_after` / `reps_delta` | Event with reps Δ |
| `route_path` / `current_node_id` / `route_nodes` | Unchanged law (`22` / `20`) |
| `market_tab` / `market_staff_*` / `staff_owned` / `staff_equipped_id` / `max_materials` / `max_runes` | M2 Staffs tab |
| `market_skill_*` / `deck_skill_count` | M2 Skills tab |
| `market_artifact_*` / `artifact_owned` / `artifact_equipped_ids` | M2 Gear tab |

**Asserts (market + event)** — no SCRIPT ERROR path beyond existing smoke.

1. Every `market_stock[].mat_id` ∈ `market_bank_c1` ⊆ `11`. `len(market_stock)` ∈ 4..6. Price matches `11` `$`.
2. Buy: `gold_after == gold_before - price` and `deck_material_count` +1 and `market_buys` contains that `mat_id`.
3. Sell: `gold_after == gold_before + max(1, floor($/2))` from **base** `$` (ignore thrift/heavy) and `deck_material_count` −1 and after-count **≥ 3**. A sell that would leave < 3 is refused (counts unchanged).
4. Refresh: `gold_after == gold_before - (base + (n−1)×step)`; `market_refresh_count` += 1; `market_stock` replaced (still 4–6, still ⊆ bank). Refused if `gold < cost` (count unchanged). Refresh does **not** append `route_path` or exit.
5. Exit with `market_buys == []` is legal. `day_action == shop` still. `market_refresh_count` may be 0. Enchant-only visits (no buy) are also legal.
6. Event choice writes `event_id` + `event_choice_id` + `event_deltas` + `event_resolved == true`. Applied gold / mat / reps match the catalog (or documented skip).
7. `day_action` matches `current_node_id` kind (`shop` or `event`).
8. C1 event `route_nodes[].ref_id`: N4=`evt_c1_heat_mirage`, N6=`evt_c1_ashfall`, N10=`evt_c1_scrap_market`, N17=`evt_c1_salt_spray`.
9. No live `event_pool` / free `day_assignments`. No `phase=shop`. No reshape field. No owner-gear offer field.
10. Market graph options (`kind=shop`) are not banned by visit count.
11. Gold never < 0. Illegal pay-gold event / refresh / buy / enchant choices do not apply.
12. Enchant: `gold_after == gold_before - fee`; that deck copy has `mat_enchant_id` set (+ `shiny` true or derived); `market_enchants` contains `{ mat_id, mat_enchant_id, fee }`. `mat_enchant_id` ∈ {`mat_ench_thrift`, `mat_ench_heavy`}. Refused if already enchanted / `gold < fee` / not a material (gold and stamp unchanged). Enchant does **not** resolve the day / append `route_path`. No staff / skill / gear enchant field.

**Asserts (M2 tabs)** — M2 Client only. #45 may omit the M2 block.

13. `market_staff_stock` length **5**; every `staff_id` ∈ the staff catalog; price matches `$`. Unique: a second buy of an owned `staff_id` is refused. `staff_equipped_id` is null or ∈ `staff_owned`. `max_materials` / `max_runes` match default 2/1 + equipped Δ. Refresh does **not** change staff stock.
14. `market_skill_stock` length **6**; every `skill_id` ∈ the `27` six. Buy appends `type=skill` and `deck_skill_count` +1. Duplicates legal. Sell −1. Skills do not change `deck_material_count` / ≥3 floor.
15. `market_artifact_stock` length **8**; every `artifact_id` ∈ the artifact catalog. Unique owned. `len(artifact_equipped_ids) ∈ 0..2` and all distinct ⊆ `artifact_owned`. Refresh does **not** change artifact stock.
16. Sell gold on these tabs = `max(1, floor($/2))` from catalog `$`. Gold never < 0. Equip / buy / sell do **not** append `route_path` or resolve the day.
17. No `mat_enchant_id` / `shiny` on staff, skill, or artifact instances. No `enc_*` sold on these tabs.

---

## Explicit non-goals

- Reshape (free remove / transform without buy)
- Frozen per-node-only 4–6 lists as sole stock law
- Reopening M1 materials / refresh / enchant / `evt_*` (shipped #45)
- Staff / skill / gear tabs in the **M1** Client (#45 must stay materials-only)
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
- Elite telegraph on N5 (route badge in [22](22-chapter-schedule.md); not a market socket)
- Adventurer catalog / Dex work
- A second deck type or a second gold purse
- Greying-out market picks after k visits
- Inventing `$5` forbidden mats in the C1 bank
- Reopening M1 tab scope (still materials only; M2 staff / skill / artifact unchanged)
- Craft-session enchant of mats (craft `enc_*` runes stay their own system — do **not** merge into `mat_ench_*`)
- Overwrite / multi-stack mat enchants M1
- Nnoitra / PixelLab shine blocking M1 Client (ugly tint is enough)
- Staff / skill / gear enchant this stamp
- A second skill system parallel to `16` / `27` `sk_*`
- `gear_*` ids (prefix is `artifact_*`)
- PixelLab shiny overlays / shiny gens for M2 cards
- Refreshing staff / skill / gear banks mid-visit
- Owner chrome / shopkeeper portraits
- Client `src/` / Godot this PR
- Elite N5 telegraph ([22](22-chapter-schedule.md)), adventurer catalog, battle playback
- Merging craft `enc_*` runes into market mat enchant
- Selling Extra Seam / Second Rune as `sk_*` this pass (slot raises = staff)
- Auto-equip on buy
- More than one staff equipped (M2 default = 1)
- More than two gear slots (M2 default = 2)
- Craft-session use of staff / artifacts

---

## Later (not this M2 tab lock)

- Owner roster (`16`) and owner-weighted stock
- `own_broker` free reroll (do not replace the paid refresh curve unless stamped)
- Owner-skill Extra Seam / Second Rune as buyable `sk_*`
- Forbidden unlock rooms / $5 mats in the bank
- Reshape
- Unique stock UI / fancy titles / PixelLab icons (Nnoitra parallel — after stamp + Harribel)
- Nnoitra shiny overlay polish (ugly tint stays legal)
- Overwrite / multi-stack mat enchants
- Separate gear-upgrade / enchant systems
- Event art, branching trees, run-kill rows
- Prep-craft / rest-dig nodes (`22`)
- Enchantment / rune market offers (`19` optional 6th slot) — still **not** `mat_ench_*`

---

## Open questions (Jonathan)

None on the M2 catalogs (2026-10-16). Those locks shipped with #46–#49. M1 stays closed. Enchant cut (materials only) stays locked. Gold prices and Δ ints stay **Test knobs**.

**2026-10-20 visual leftovers:** landed (#51–#55). Tab chrome stamped **A** (no gens). Not an open question.

---

## Pointers

`22` route map · `20` harness · `11` materials · `19` starter deck + gold 12 + excluded list · `27` run deck / `sk_*` · `14` synergy bag-count · `13` craft `enc_*` (distinct) · `25` reps · `16` owner skills · `10` / `12b` enc + staff-slot · `01` loop · `21` historical opening-shop · `pm/phase-1-plan` · `STAMP`
