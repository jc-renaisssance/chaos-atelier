# Player-facing chrome — Soft strip

**Doc id: `37`.** **Status: Stamped Node A′ · Brief A · Event A** (Jonathan, Soft #91). Written off `dev` tip **`78d1837`** (docs #90). Client wire on that parent is **`274a8d6`** (#89). The letters are not open. Silence is not **A**. Plain node **A** (a catalog name on an adventurer stop) is not the stamp. No `src/` in this amend. No assets. No PixelLab. No burn. Soft QC is next. Ulquiorra holds the Client until that PASS and Aizen merges.

Jonathan (2026-10-26): the M2 Steam demo is almost-production UI and gameplay. Placeholder art is legal. A gap that leaves a broken drop or missing card chrome does not clear. M2 and the full product differ by locked owners and by which map is authored. They do not differ by a debug skin.

This file is the strip. A Steam player, with `dev_tools` false, never sees a raw id, an empty Brief panel, or a scaffolding label. The inventory below is what tip actually paints. It is not a wish list.

---

## Locks this file does not reopen

| Lock | Where |
|---|---|
| Soft A′AAAA hand, drag, drop, mat path, placeholder | [36](36-craft-hand-cards.md) #83–#85. Card **108×148**. Face **88×88**. Fan step `32 / (max_hand - 1)` |
| Tag chrome **A** | [36](36-craft-hand-cards.md) §6. #87 / #89. Native 16×16 chips. Tag names stay off the caption. Type and `cost N` stay (#88) |
| Drop clear, cost caption, N=2 as one fight | Client #88 (`e9f503f`). [35](35-steam-demo-cut.md) lock 5 |
| Copy **A** Brief / Estimate for a seen boss, and every `?` gate | [35](35-steam-demo-cut.md). Weights stay off the label |
| Outlook sockets, planner icon chips | [35](35-steam-demo-cut.md) #79–#82. Do not regen |
| Shell palette **A**, bust **A**, playback frame in the shell | [34](34-ui-shell-v1.md) #76 / #77 |
| Market tab chrome **A** (text strip). Shiny stays code-only | [32](32-shop-and-events.md) |
| Kind chips 48×48, elite badge, graph click commits | [22](22-chapter-schedule.md) #57–#59, #66–#68, [35](35-steam-demo-cut.md) |
| `dev_tools` default **false**. Dex, Reroll, Demo next chapter, STAMP JSON stay off the player tree | [21](21-app-flow.md), [35](35-steam-demo-cut.md) |
| Posture art **Nov 2**. PR #71 Solenne ×4 **HOLD**. Halden + Vex **KEEP**. Shop **ACCEPT** | Do not gen. Do not edit pngs |
| Stamina, unlock keys, estimate cutoffs, `M2_JOB_POOL`, route graph law | `27`, `33`, `29`, `22` |

A letter below changes words on a control. It does not move a row in that table. `22`’s “type + id” and “three text lines” sentences are the #41 / #57 record. They are not the demo face.

---

## What tip paints

`dev_tools` is false unless the title **Dev** check is pressed. Everything in this section is on that default path, except the one Dev control and the block it unlocks.

### Title — `src/ui/title/title_screen.gd`

| Control | Text |
|---|---|
| Word | `Wombaste` |
| Buttons | `New run` · `Continue` · `Quit` |
| Check | `Dev` |

`Dev` sets `AtelierSession.dev_tools`. Default is off. The control is on the boot screen.

### Map — `schedule_board.gd`, `route_node_view.gd`, `route_graph_view.gd`

`DaySlotView` is not in this tree. FORK OPTIONS is not in this tree.

**Header.** Title becomes `WOMBASTE  ·  travelling wagon  ·  own_basic` (`player_owner_id`). Caption starts as `ROUTE GRAPH  ·  map_m1  ·  nodes + edges  ·  ugly M1` and redraws as `ROUTE GRAPH  ·  {map_id}  ·  {n} days (map.day_count)  ·  last 2 reserved  ·  nodes + edges`.

**Meta line** (one label):

```
Chapter {n} / {n}   ·   boss {title} ({boss_pool_id})   ·   day {n} / {n}   ·   {left} left   ·   node {current_node_id}   ·   pieces {crafts_done}   ·   gold {n}   ·   reps {n} (gate {n})   ·   decline {used|open (once / chapter)}   ·   seed {chapter_seed}
```

**Note line** prints `last_note`. Strings a player hits include `Confirmed N1 on D1.`, `Draft ghost N8 (not confirmed).`, `Kingdom newspaper — boss announced before spend. Route graph next: D1 is N1…`, `Market N2 — …`, `Bought mat_iron_scrap for 1 gold.`, `Event evt_c1_heat_mirage — pick one choice.`, `Appointment declined (Phase-1: once / chapter, −reps stub {n}).`, `Order lists more than 4 constructions — Later / split. No fifth zone.`, `cant_craft — F, hp>0, aid 0…`, and `schema: …`.

**Draft label**, when a draft exists: `DRAFT  ·  ghost only  ·  N3, N8`.

**Today caption:** `TODAY  ·  one primary action from the current node`.

**Today body** (the live one depends on state):

| State | Text on tip |
|---|---|
| Boot copy, before redraw | `D1 is N1. Click the graph to commit the next node.` |
| Newspaper | `Kingdom newspaper — boss announced. Dismiss into the route graph.` Button `Open the route graph` |
| Day not confirmed | `Click the next node on the graph. That commits the path. A later node only drafts.` Button `Take node` (disabled) |
| Appointment | `Current node {node_id} appointment: {appointment_id}. Take it, or decline once this chapter (−reps).` Button `Take appointment` |
| Reserved last day | `Reserved D{n} — boss approach. Not player-pickable.` Button `Resolve reserved day` |
| Reserved other | `Reserved D{n} — travel / final prep. Not player-pickable.` Button `Resolve reserved day` |
| Other confirmed node | `Current node {panel_line()}. Take it. Market 1–3 is graph law — not a UI ban.` Button `Take node` |
| Awaiting boss | `Day budget finished. Draw a shared-pool adventurer and sew that job vs the announced boss.` Button `Draw the fighter` |
| Resolve open | `Action locked. Continue after the mission / event result.` |

`panel_line()` is `{kind} · {node_id}` plus `ref_id` when set. A live card reads `adventurer · N1  adv_halden_rook` or `market · N2`. Extra action buttons use `Appointment — {appointment_id}` (`appt_scrap_duelist` on the current map). `appointment_title` already returns `Scrap Duelist` and is not what the button prints.

Decline button: `Decline appointment (−reps)`.

**Resolve caption:** `RESOLVE  ·  mission (23/24)  ·  no lineup cards`.

Idle body:

```
Waiting for a pick.
Walk the authored graph. … Draft future is ghost only — not route_path. …
Order path: appointment / adventurer → stamina craft.
Event path: market (wire shop) / event / reserved stay phase=schedule. …
```

When a result exists, the title is `{title}  ·  {resolve_class}` and the body is the payload. Player-visible bodies:

| Source | What the player reads |
|---|---|
| Mission return | `Mission result (docs/23, 24): rating S · cleared true · hp …` then the gate formula, `crafts_done is unbounded telemetry`, `cant_craft — F…`, `Newspaper mid_fail chrome (copy Later).`, and `Piece 1 · rarity common · rating S · look syn_metal_5.` |
| Boss | `{Fighter} ({adv_*}) vs {Boss}: rating S · cleared true · hp …` then `Newspaper chrome hd_chapter_result (copy Later).` or `run_over · boss_death — no retry (docs/24). Newspaper chrome hd_run_over.` |
| Piece report | `Rarity common · look syn_metal_5 · tags …` and `This vignette is not the fight. …` |
| Market exit | Title `market · N2`. Body is buy/sell/staff/skill/gear/refresh/enchant counters |
| Event exit | Title `event · {evt_* or node id}` |
| Reps gate | Body `reps_after < reps_gate (8). run_over_reason=reps_gate_miss.` |

**Node card** (`RouteNodeView.bind`): line 1 `node.node_id` (`N1`), line 2 `display_kind()` (`market`, `adventurer`, `appointment`, `event`, `reserved`), line 3 `ref_id` (`adv_*`, `appt_*`, `evt_*`). Kind chip and elite badge sit beside those lines. Column heads are `D1` … `D6`, `D7  travel / final prep`, `D8  boss approach`.

### Craft, planner, outlook, brief — `craft_table.gd`, `craft_zone.gd`, `craft_hand_slot.gd`, `demo_facing.gd`, `craft_readout.gd`

**Stays production on a live session.** `Craft`. `Stamina  {n} / {n}`. `Dig · 2`. `Finish`. `Return` or `Resolve the fight`. `Draw {n}  ·  Discard {n}`. Section words Plan, Zones, Current, Potential, Hand. Order title `{display}  ·  {job}`. Stats `HP n   ATK n   DEF n   RES n   MOB n   PRE n`. `Fighting {boss display name}`. `Listed  {n} {construction name}`. `Taste  {requirement_taste}` (prose already, e.g. `Metal mid`). Planner chips are icons; tooltip is the tag word (`Fire`). Plan line is `?` or `Metal mid` (`plan_label`). Estimate is Copy A. Hand shows the display name, slot index `1`–`5`, type, `cost N`, and the landed chips. Outlook art hides when locked. Zone title is the construction name.

**Does not stay.**

| Surface | Tip string |
|---|---|
| Skill line on the order | `{ask_*}  ·  {skill name}. {clause}.` from `skill_panel_line` |
| Potential, unlocked | `{syn_*} · order {n}` or the word `plain`. Locked word `locked` stays |
| Current tags | `tags Metal×2, Silk×1` — tag words, not ids. Stays |
| Zone, no cards yet | `Empty — Finish uses the construction-only bag.` |
| No session | `No session.` / `Leave the route graph to sew an order here.` Brief body `""`. Estimate body `""`. Both headers still show |
| Skill caption / shelf | Four blurbs end in ` (stub).` One ends in `(clamped to hand_size this slice).` |

**Brief.** Copy A is three lines when the row has them. On this tip every `boss_*` row has `environment` and `flavor` (9 rows). Every `cli_*` row has a name and tags and neither field (23 rows). Non-boss threats force `seen = true`, so a walk-in or appointment paints:

```
Ember Scout
<blank>
<blank>
```

under the header `Brief`. That is the empty Brief panel. Unseen boss and empty threat stay `?`. No-session Brief is a header over an empty string.

### Market — `market_screen.gd`

| Control | Tip text |
|---|---|
| Title | `market · {node_id}` |
| Meta | `gold n   ·   refresh next $n   ·   count n   ·   mats n   ·   skills n   ·   max_m n  max_r n   ·   gear n/2` |
| Note | `last_note` (`Bought mat_iron_scrap…`, `Enchanted mat_iron_scrap with mat_ench_thrift…`, `Cannot buy staff_apprentice.`) |
| Hint | `Refresh / Enchant = materials only. Exit resolves the day.` |
| Shelf captions | `SHELF  ·  market_staff_bank_c1  ·  unique owned` · `SHELF  ·  market_skill_bank_c1  ·  buy into own_basic kit` · `SHELF  ·  market_artifact_bank_c1  ·  unique owned` · `SHELF  ·  buy from market_bank_c1` |
| Kit captions | `KIT  equipped: {staff_id\|none}    max_m n  max_r n` · `DECK (skills)  ·  sell copies  ·  no equip` · `KIT  slots n/2` · `DECK  ·  sell / enchant owned mat_*` |
| Material row | `{mat_id}     $n   own n   qty n` and, if shiny, `shiny {mat_ench_*}` |
| Staff row | `{staff_id}     $n   Δm+1 Δr+0   owned`. `staff_label` exists (`Apprentice`) and is not the row title. `Δ0` when both deltas are 0 |
| Skill row | `{sk_*}     $n   own n   {blurb}` |
| Artifact row | `{artifact_id}` plus `artifact_label` in the same line |
| Tabs | `Materials` · `Staffs` · `Skills` · `Gear` |
| Buttons | `Buy` · `Sell +n` · `Equip` · `Unequip` · `Exit` · `Refresh $n` · enchant `Thrift $2` / `Heavy $3` |

### Event — `event_screen.gd`

| Control | Tip text |
|---|---|
| Title | `event · {node_id}` |
| Id line | `{evt_*}` or the placeholder `evt_*` |
| Choice | `{choice_*}    {label}` e.g. `choice_share_skin    Share the last skin` |
| Before the pick | `result: —` |
| After | `result: {sentence}` |

The seven live events have a blurb and choice labels. They have no title field. Blurbs are already player sentences.

### Battle — `playback_step.gd`, `playback_beats.gd`

| Control | Tip text |
|---|---|
| Title | `Fight` or `Vignette` |
| Notes | `Skip ends this fight. The report still opens.` · `Piece vignette. Skip opens this piece's report. The fight plays once after the last piece.` · `One fight for the combined gear. Skip opens the report.` · `Piece report. Continue opens the one fight.` |
| Beat row | `{pN }{mark}{beat id}  ·  {slot}  ·  {label}` |
| Fight open label | `{adv_* or appt_*}  ·  {threat name or ?}` (`open_person_label` returns the id) |
| Skill beat | `{ask_*}  ·  ★{n}` |
| Vignette label | `{construction}  ·  {syn_*}` and `{rarity wire}  ·  {syn_*}` |
| Actor | Name label is the slot (`in_fight`, `ult`, `defend`, `attack`) when the still is missing. Caption `{slot}  ·  {adv_*}`. Missing png stays a hidden texture. That hide stays |

Buttons `Skip` and `Continue` stay. Report title `Piece {n} · {construction name}` is a display name. The body under it is the piece-report dump above.

### Dev block (only after the title check)

Not on a default boot. Once `Dev` is on, the board adds `STAMP  ·  docs/20 full dump  ·  crafts_done unbounded telemetry`, the JSON panel, `Dex`, `Reroll this chapter`, `Demo next chapter`. Dex title is `DEX  ·  ugly list  ·  profile / meta`. This stamp does not restyle that block. It removes the way a Steam player opens it.

### Not on the player tree

No control’s text is the literal `TODO`. The player-visible scaffold word is `Later` (`Later / split`, `copy Later`). `(stub).` is on four skill blurbs.

---

## What stays visible

- Title word **Wombaste**. **New run**, **Continue**, **Quit**.
- Column heads `D1` … `D8`, including `travel / final prep` and `boss approach`.
- Kind chip, elite badge, graph click (commit or draft). Draft stays a border. It does not need a word.
- Craft frame: stamina, Dig, Finish, Return / Resolve the fight, draw and discard counts, zone construction name, hand name, slot index, type, `cost N`, tag chips, Current stat line with tag words (`Metal×2`).
- Order name and job, stat line, `Fighting {boss name}`, listed constructions, taste prose.
- Plan chips and `Metal mid` / `?`. Estimate Copy A, including `?`.
- Boss Brief: the three Copy A lines, or `?` when unseen.
- Outlook art when unlocked. The word `locked` when it is not. Missing png hides the rect.
- Market tabs, Buy / Sell / Equip / Unequip / Exit / Refresh `$n`, enchant labels Thrift and Heavy, mat faces, shelf icons.
- Event blurb and choice **label**. Result sentence after the pick.
- Battle titles Fight / Vignette, Skip, Continue, rating letter, tag words on favor and punish beats.
- Gold and reps as numbers. Boss display name. Day numbers.

Placeholder art stays a gap, not a label. A missing posture still does not print `in_fight`.

---

## What must hide

Wire ids stay in the stamp, the catalog, and the test log. They leave every `Label` and `Button` a player can read while `dev_tools` is false.

Never on that path: `own_basic`, `map_m1`, `map.day_count`, a route node id (`N` plus digits), `adv_`, `appt_`, `evt_`, `cli_`, `boss_`, `mat_`, `sk_`, `staff_`, `artifact_`, `con_`, `ord_`, `syn_`, `ask_`, `choice_`, `mat_ench_`, `market_bank`, `market_staff_bank`, `market_skill_bank`, `market_artifact_bank`, `Δm`, `Δr`, `Δ0`, `(stub).`, the word `Later`, `TODO`, `ugly`, a `docs/` citation, `route_path`, `phase=schedule`, `ghost only`, `wire shop`, `seed` as a labeled integer, `run_over_reason`, `hd_run_over`, `hd_chapter_result`, `cant_craft`, `crafts_done`. The title has no control named `Dev`.

`last_note` is the session log. The board note, the market note, and any resolve body do not print it. The log may stay on the dev stamp.

### Title

Do not construct the Dev check. Nothing on the title writes `dev_tools`. The flag stays default false. The dev panel on the board may remain for a smoke that sets the flag in test. A demo boot does not show it.

### Board words

Header is `Wombaste`. No owner id. No map caption.

HUD, one line:

```
Chapter {n} / 3   ·   Day {n|—} / {day_count}   ·   Gold {n}   ·   Reps {n}   ·   {boss display name}
```

Day is `—` while the newspaper is up. No pool id, node id, piece count, gate integer, decline flag, or seed.

Hide the route caption, the draft id line, the Today caption, and the Resolve caption. Hide the resolve panel until a player result exists. Idle copy (`Waiting for a pick.` and the authored-graph essay) does not show.

| State | Today line | Button |
|---|---|---|
| Newspaper | `The paper names {boss display name}.` | `Continue` |
| Day not confirmed | `Choose the next stop.` | hidden |
| Adventurer confirmed | `An adventurer is waiting.` | `Sew` |
| Appointment confirmed | `{appointment title}. You may decline once this chapter.` | `Sew` |
| Market confirmed | `The market is open.` | `Shop` |
| Event confirmed | `On the road.` | `Look` |
| Reserved, not the last day | `A day on the road.` | `Continue` |
| Reserved, last day | `The road runs to {boss display name}.` | `Continue` |
| Awaiting boss | `The days are spent. Sew for the fighter.` | `Sew for the fight` |
| Chapter closed | `The chapter is closed.` | `Chapter closed` (disabled) |
| Run over | `Run over. There is no retry.` | `Run over` |

Decline stays `Decline appointment (−reps)`. It does not print an `appt_*` id. No today line prints `Not player-pickable`, `graph law`, `shared-pool`, or `route graph`.

Click still commits or drafts. Take still enters the day. Only the words change.

### Reports a player reads

Piece report title stays `Piece {n} · {construction name}`. Body is the construction name, the rarity word (`Common`, `Uncommon`, `Rare`, `Legendary`), and the outlook name from the table below. Omit tags when the bag is empty. Do not print `look {syn_*}`, `(none)`, or `This vignette is not the fight`.

Mission return title: `Read {S|A|B|C|D|F}`. Body is the letter and `Won` or `Lost` from `cleared`. No aid percent, no gate formula, no `docs/23`, no `copy Later`.

Boss title stays `Boss clear — {display name}` or `Run over — {display name}`. Body is `{fighter display name} against {boss display name}.` plus the letter. No `adv_*` in parentheses. No newspaper-chrome id.

Market exit title: `Market`. Body: `Back on the road.` Gold is the HUD. Event exit title is `On the road`. Body is the result sentence. Reps-gate title: `Run over`. Body: `There is no retry.`

### Craft words

Skill line is `{skill name}. {clause}` with no `ask_*`.

Potential, when unlocked, is the outlook name in the table. Not `syn_*`. Not `order {n}`. `plain` prints `Plain`. Locked stays `locked`.

| `outlook_id` | Player name |
|---|---|
| `plain` | Plain |
| `syn_metal_3` / `_5` / `_8` | Metal low / mid / apex |
| `syn_earth_3` / `_5` / `_8` | Earth low / mid / apex |
| `syn_fire_3` / `_5` / `_8` | Fire low / mid / apex |
| `syn_frost_3` / `_5` / `_8` | Frost low / mid / apex |
| `syn_silent_3` / `_5` / `_8` | Silent low / mid / apex |
| `syn_royal_3` / `_5` / `_8` | Royal low / mid / apex |
| `syn_silk_3` / `_5` / `_8` | Silk low / mid / apex |
| `syn_fire_frost_clash` | Temper |
| `syn_wild_earth` | Beastbloom |
| `syn_sticky_sharp` | Snaretooth |
| `syn_royal_silent` | Masked Crown |
| `syn_solar_pure` | Dawn Vestment |
| `syn_lunar_occult` | Pale Hex |

Any other id (neg syn, `uniq_*`) prints nothing in that slot. Do not invent a name. Art hide for those ids stays [35](35-steam-demo-cut.md).

Zone body is empty until a card is played. The construction name is the title. No construction-only-bag sentence.

No-session craft is not a player screen. If that refresh paints, hide the Brief header and the Estimate header. Do not show `No session.` or `route graph`.

Skill blurbs, on the card and on the shelf, drop the scaffold tail. The rest of the sentence stays:

| Id | Player blurb |
|---|---|
| `sk_metal_str_double` | `Double STR from Metal mats already in this piece.` |
| `sk_wild_to_earth` | `Consume 1 Wild mat in session → Earth mat into hand.` |
| `sk_touch_up` | `+1 to one chosen stat on one played material.` |
| `sk_steady_hand` | `Ignore first negative synergy this piece.` |
| `sk_deep_dig` | `Refresh hand; draw +1 extra.` |

`sk_next_mat_free` is already `Next material play costs 0 stamina.` and stays.

### Market words

Title `Market`. Header `Gold {n}`. Hint `Enchant is for materials.` Shelf caption `For sale`. Materials kit `Your cloth`. Skills kit `Your skills`. Staff kit `Your staff`, then the staff label or `None`, and `Materials +{n}` / `Runes +{n}` from the deltas (omit a zero delta; never `Δm`). Gear kit `Gear {n} / 2`.

Row title is the existing display string: material `name`, `staff_label`, `artifact_label`. A skill row’s words are the blurb above, not `sk_*`. Shiny suffix is `shiny Thrift` or `shiny Heavy`. Own count stays `own {n}`. Offer count is `offered {n}`. Price stays `$n`.

### Battle words

A beat row is the player label only. No beat id, no slot key, no `pN` prefix.

Open line: `{display name}  ·  {threat name or ?}`. Appointment with no named adventurer uses the appointment title, not `appt_*`.

Skill beat: `{skill name}  ·  ★{n}`, or `Does not fire.` when there is no `ask_*`.

Vignette label uses the construction name, the rarity word, and the outlook table. Not `syn_*`.

Actor caption is the display name. The slot key never shows. A missing still hides the texture and does not substitute the slot word. Do not gen a still.

Hide the explainer notes (`Skip ends this fight…`, `Piece vignette…`, `One fight for the combined gear…`, `Piece report. Continue…`). Skip and Continue stay.

---

## Letters

**Stamped Node A′ · Brief A · Event A.** Jonathan, Soft #91. These lines are the stamp. They are not an open A|B. Silence is not **A**.

### 1. Node face — stamped A′

The kind chip and the elite badge stay. `node_id` and `ref_id` still hide.

**A′ (taken).** One production line on the card, beside the chip. This is Jonathan’s amend of the Design **A** table. A normal adventurer stop does not print `AdventurerCatalog.display_name`. It labels the stop type, the way a shop labels the kind of stop and not the person inside.

| Kind | Line |
|---|---|
| Adventurer | `Adventurer`. Kind word only. Not the catalog display name |
| Appointment | `ScheduleCatalog.appointment_title`. Unknown id → `Appointment`. The title still shows |
| Market | `Market` |
| Event | `On the road` (Event **A**) |
| Reserved, not last | `Travel` |
| Reserved, last | `Approach` |

The Today line for a confirmed adventurer is `An adventurer is waiting.` It does not print the catalog name. The appointment Today line still uses the appointment title. The order panel, after the player enters craft, still shows the person. That panel is not this card.

**B** (chip and badge only, no text line) is not taken. Plain **A** (display name on the adventurer card) is not taken.

### 2. Client Brief — stamped A

Boss rows keep Copy A (three lines, or `?`). Empty threat stays `?`. Blank lines are never legal.

**A (taken).** A `cli_*` row with no environment and no flavor prints the display name only. One line. The header `Brief` stays. No flavor was written.

**B** (pasted environment and flavor) is not taken.

### 3. Event header — stamped A

Node id, `evt_*`, and `choice_*` hide. The blurb stays. The button is the choice label only. `result: —` hides until the pick; then the result sentence shows, with no `result:` prefix.

**A (taken).** Every event’s header is `On the road`. The node line uses those same words. No new title field.

**B** (seven titles) is not taken.

---

## Client (after Soft QC — not this amend)

The letters are stamped. Ulquiorra still holds until Soft QC passes and Aizen merges. Szayelaporro holds until that Client. Nnoitra has no seat. Harribel does not gate. No gen. This amend is the stamp record. It is not the QC and it is not the Client.

The Client replaces strings and hides controls. It does not retune rules, banks, chips, mat faces, or the fan. It does not delete the dev panel; it deletes the title setter. The adventurer route line is the word `Adventurer`.

---

## Stamp card

### 1. Files to review

| File | What |
|---|---|
| `docs/37-player-facing-chrome.md` | This law. Inventory, hide list, stamped **Node A′ · Brief A · Event A** |
| `docs/22-chapter-schedule.md` | Pointer. Type + id is the #41 record. Player words are here |
| `docs/21-app-flow.md` | Title has no Dev check |
| `docs/32-shop-and-events.md` | Pointer. Id labels are the ugly record. Tabs stay **A** |
| `docs/35-steam-demo-cut.md` | Boss Brief stays Copy A. The hollow `cli_*` poster is letter 2 |
| `docs/34-ui-shell-v1.md` | Shell letters stay. This strip is not a shell reopen |
| `docs/30-interactive-order.md` | Playback words. Gate / Surface / Socket stay **A** |
| `docs/27-craft-mode-stamina.md` | Pointer. Rules stay |
| `docs/36-craft-hand-cards.md` | Pointer. `(stub).` leaves the blurb. Caption layout stays |
| `docs/05-art.md` | No gens |
| `docs/pm/phase-1-plan.md` | Stamped letters. Parent tip `78d1837`. Soft QC next |
| `docs/README.md` · `docs/00-doc-categories.md` · `docs/STAMP.md` | Index and this card |

### 2. Decisions

The hide list and the stay list are accepts. The three letters are written. Silence is not **A**.

1. **Node face — stamped A′.** One production line beside the kind chip. Adventurer line is the word `Adventurer`, not `AdventurerCatalog.display_name`. Appointment line is `ScheduleCatalog.appointment_title` (unknown → `Appointment`). Market is `Market`. Event is `On the road`. Reserved is `Travel` or `Approach`. Chip and elite badge stay. `node_id` and `ref_id` hide. Plain **A** and **B** are not taken.

2. **Client Brief — stamped A.** Display name only when the `cli_*` row has no environment and no flavor. Boss Copy A stays. Blank lines do not ship. **B** is not taken.

3. **Event header — stamped A.** `On the road` for every event. **B** is not taken.

### 3. Questions

None.

### 4. Blockers

The letters are answered. **Node A′ · Brief A · Event A.**

Soft QC has not passed. That is the next gate. Ulquiorra holds the Client until Soft PASS and Aizen merge. This amend does not start the Client.

**Holds.** PR **#71**: Solenne ×4 art **HOLD** until **2026-11-02**. Halden + Vex **KEEP**. Shop **ACCEPT**. Do not revive **#62**. Posture art stays **Nov 2**. No gens in this amend. No `src/` in this amend. Soft A′AAAA, tag chrome **A**, Drop A, Path A, and #88 stay landed. Do not read them as open.

### Stamp

**Node A′ · Brief A · Event A.** The adventurer stop reads `Adventurer`. The appointment stop still reads the appointment title.
