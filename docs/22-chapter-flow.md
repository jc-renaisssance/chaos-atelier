# Chapter flow — route, clients, events

Jonathan lock (2026-09-22+): StS-like **route** — player **picks** mid missions; reps meter (`25`); announce via newspaper (`26`).

## Chapter spine

```
CHAPTER
  1. Kingdom newspaper → announce boss (from chapter pool)
  2. Atelier shop
  3. Route map — pick MISSIONS_BEFORE_BOSS nodes (each: shop → craft → mission → newspaper if fail)
  4. Check reps >= reps_gate (25); else run_over (competitors)
  5. Last atelier shop
  6. Boss fight — fail = adventurer dead → run_over, no retry
  7. Newspaper chapter result edition
```

### Phase-1 counts

| Constant | Value | Notes |
|---|---:|---|
| Chapters | **3** | |
| Bosses / chapter pool | **3** | 27 paths; C1 diversified (`17`) |
| Route nodes before boss | **3** | Player **chooses** which node each time |
| Offered choices per pick | **2–3** | From chapter client/event pools + difficulty | 
| Shops | Before route, before each craft (or after pick), last before boss | Phase-1 keep shop before craft |

Fixed `client→event→client` order is **replaced** by **player route picks**. Pools still supply what can appear on the map.

```
function pick_route_node(chapter_index, reps, rounds_left):
  offers = roll_map_nodes(CLIENT_POOLS, EVENT_POOLS, difficulties={1,2,3})
  # UI: StS-style — skip hard if reps/HP weak
  return player.choose(offers)
```

Each node has `difficulty` 1–3 for reps Δ (`25`).

## Client pools (per chapter)

### C1 — Outer Holdings

| id | Name | Threat tags | Punishes | Favors | Notes |
|---|---|---|---|---|---|
| `cli_c1_ember_scout` | Ember Scout | Fire | Soft | Metal, Earth | |
| `cli_c1_dock_hauler` | Dock Hauler | Frost, Sticky | Soft | Metal, Frost | Pairs Salt Widow |
| `cli_c1_scrap_duelist` | Scrap Duelist | Metal, Sharp | Soft | Metal, Sharp | Pairs Rust Knave |
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

| id | Name | Effect | Letter / paper |
|---|---|---|---|
| `evt_c1_ashfall` | Ashfall | Fire pressure | — |
| `evt_c1_scrap_market` | Scrap Market | Metal offer bias | — |
| `evt_c1_salt_spray` | Salt Spray | Frost/Sticky | — |
| `evt_c1_heat_mirage` | Heat Mirage | MOB − | — |

### C2

| id | Name | Effect | Letter / paper |
|---|---|---|---|
| `evt_c2_fog_bell` | Fog Bell | Lunar/Occult | — |
| `evt_c2_possession` | Thin Veil | possess flag | letter + paper if fail |
| `evt_c2_root_snare` | Root Snare | Sticky/Earth | — |

### C3

| id | Name | Effect | Letter / paper |
|---|---|---|---|
| `evt_c3_summons` | Court Summons | Royal PRE | — |
| `evt_c3_contraband` | Contraband Sweep | Sticky/Silent punished | paper on fail |
| `evt_c3_gala` | Gala Night | Solar/Royal | — |

## Mission loop (pseudocode)

```
function run_chapter_route(player, chapter_index, boss):
  rounds_left = 3
  while rounds_left > 0:
    node = pick_route_node(...)          # player choice
    atelier_shop(player)
    craft = craft_garment(player)
    gear  = resolve_craft(craft)
    result = run_mission(gear, node.threat)
    apply_reps_delta(result, node.difficulty)  # 25
    if not result.cleared:
      newspaper.mid_fail(result)         # 26
    stamp(...)
    ui.show_mission_result(result)
    rounds_left -= 1
  if player.reps < reps_gate[chapter_index]:
    newspaper.shop_ruined()
    run_over(reason="reps_gate_miss")
    return
  atelier_shop(player)
  # boss…
```

## Cross-links

`17` bosses · `25` reps · `26` newspaper · `23` report · `24` win-con · `20` stamps · `21` flow
