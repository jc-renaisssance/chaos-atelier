# Chapter flow — round picks, clients, events

Jonathan lock (2026-09-22, corrected): **not** an StS path map. Each round the atelier lines up **3 cards** (orders and/or events). Player picks **one**; that ends the round.

## Chapter spine

```
CHAPTER
  1. Kingdom newspaper → announce boss (chapter pool)
  2. Opening atelier shop
  3. Rounds × CHAPTER_ROUND_LIMIT (Phase-1 = 3):
       lineup 3 cards → player picks 1
         · Order  → shop → craft → mission report (±reps; newspaper if fail)
         · Event  → resolve event (±reps if applicable; newspaper if fail)
       → next round
  4. If reps < reps_gate → run_over (competitors)
  5. Last atelier shop
  6. Boss — fail = adventurer dead → run_over, no retry
  7. Newspaper chapter result
```

### Phase-1 shop order (**locked**)

| Pick type | Sequence |
|---|---|
| **Order** | pick → **shop → craft** → report |
| **Event** | pick → resolve event (no craft unless event says otherwise) |
| Chapter | opening shop + **last shop before boss** |

### Phase-1 counts

| Constant | Value | Notes |
|---|---:|---|
| Chapters | **3** | |
| Bosses / pool | **3** | 27 paths; C1 diverse (`17`) |
| `CHAPTER_ROUND_LIMIT` | **3** | Rounds per chapter before boss |
| Cards offered / round | **3** | Mix of orders + events from chapter pools |
| Picks / round | **1** | Ends the round |

```
function lineup_round(chapter_index, seed):
  # 3 cards from CLIENT_POOLS ∪ EVENT_POOLS (weighted; at least one order preferred)
  return draw_three(chapter_index, seed)

function play_round(player, cards):
  choice = player.pick_one(cards)          # exactly one
  if choice.kind == order:
    atelier_shop(player)
    if cant_craft(player):
      result = cant_craft_fail_result()    # F, hp>0
    else:
      craft = craft_garment(player)
      gear  = resolve_craft(craft)
      result = run_mission(gear, choice.client)
    apply_reps_delta(result, choice.difficulty)
    if not result.cleared: newspaper.mid_fail(result)
    stamp(...); ui.show_mission_result(result)
  else:  # event
    result = resolve_event(choice.event)
    apply_reps_delta_if_any(result, choice.difficulty)
    if result.failed: newspaper.mid_fail(result)
    stamp(...); ui.show_event_result(result)
  # round ends — next lineup until CHAPTER_ROUND_LIMIT
```

Each card has `difficulty` 1–3 for reps Δ (`25`).

## Order (client) pools

### C1 — Outer Holdings

| id | Name | Threat tags | Punishes | Favors | Notes |
|---|---|---|---|---|---|
| `cli_c1_ember_scout` | Ember Scout | Fire | Soft | Metal, Earth | |
| `cli_c1_dock_hauler` | Dock Hauler | Frost, Sticky | Soft | Metal, Frost | |
| `cli_c1_scrap_duelist` | Scrap Duelist | Metal, Sharp | Soft | Metal, Sharp | |
| `cli_c1_glassblower` | Glassblower | Solar, Sharp | Sticky | Silk, Pure | |
| `cli_c1_pit_fighter` | Pit Fighter | Sharp, Wild | Soft | Sharp, Metal | |

### C2 — Mire Chapel

| id | Name | Threat tags | Punishes | Favors | Notes |
|---|---|---|---|---|---|
| `cli_c2_bog_messenger` | Bog Messenger | Sticky, Earth | Royal | Silent, Wild | |
| `cli_c2_night_nun` | Night Nun | Lunar, Pure | Occult | Lunar, Soft | |
| `cli_c2_possessed_tailor` | Possessed Tailor | Occult | Pure | Occult, Silent | possess flag |

### C3 — Marble Court

| id | Name | Threat tags | Punishes | Favors | Notes |
|---|---|---|---|---|---|
| `cli_c3_court_duelist` | Court Duelist | Royal, Sharp | Sticky | Royal, Metal | |
| `cli_c3_tax_auditor` | Tax Auditor | Royal, Pure | Silent | Pure, Metal | |
| `cli_c3_parade_mage` | Parade Mage | Solar, Silk | Occult | Solar, Silk | |

## Event pools

### C1

| id | Name | Effect | Paper |
|---|---|---|---|
| `evt_c1_ashfall` | Ashfall | Fire pressure | — |
| `evt_c1_scrap_market` | Scrap Market | Metal offer bias next shop | — |
| `evt_c1_salt_spray` | Salt Spray | Frost/Sticky | — |
| `evt_c1_heat_mirage` | Heat Mirage | MOB − | — |

### C2

| id | Name | Effect | Paper |
|---|---|---|---|
| `evt_c2_fog_bell` | Fog Bell | Lunar/Occult | — |
| `evt_c2_possession` | Thin Veil | possess flag | if fail |
| `evt_c2_root_snare` | Root Snare | Sticky/Earth | — |

### C3

| id | Name | Effect | Paper |
|---|---|---|---|
| `evt_c3_summons` | Court Summons | Royal PRE | — |
| `evt_c3_contraband` | Contraband Sweep | Sticky/Silent punished | if fail |
| `evt_c3_gala` | Gala Night | Solar/Royal | — |

## Explicit non-goals

- No branching path map / fork nodes / “skip this path forever”
- Unpicked cards of a round are discarded (may reappear in later round draws)

## Cross-links

`17` bosses · `25` reps · `26` newspaper · `23` report · `24` win-con · `20` stamps · `21` flow
