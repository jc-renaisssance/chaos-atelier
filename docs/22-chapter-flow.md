# Chapter flow — clients, events, counts

Jonathan lock (2026-09-22): define **how many** clients/events before the boss, and the **pools** per chapter.

## Chapter spine (actual game flow)

```
CHAPTER
  1. Announce boss (draw from chapter boss pool — 17)
  2. Atelier shop
  3. Mission nodes × MISSIONS_BEFORE_BOSS
       each node = CLIENT or EVENT from chapter pools
       pattern: shop → craft → mission report → (shop)
  4. Last atelier shop
  5. Boss fight (announced boss)
```

### Phase-1 counts (locked draft)

| Constant | Value | Notes |
|---|---:|---|
| Chapters per run | **3** | C1 → C2 → C3 |
| Bosses per chapter pool | **3** | 27 run combinations |
| `MISSIONS_BEFORE_BOSS` | **3** | Replaces loose “node budget” |
| Of those 3 | **2 clients + 1 event** | Order: client, event, client (fixed for Phase-1 smoke) |
| Shops | before first mission, between missions optional, **last shop before boss** | `21` |

```
CHAPTER_MISSION_ORDER = [client, event, client]  # then last shop → boss
```

## Client pools (per chapter)

Clients are mid-chapter missions (not bosses). Each has threat tags + favors/punishes + reward bias.

### C1 clients

| id | Name | Threat tags | Punishes | Favors | Notes |
|---|---|---|---|---|---|
| `cli_c1_ember_scout` | Ember Scout | Fire | Soft | Metal, Earth | Escort through ash |
| `cli_c1_glassblower` | Glassblower | Solar, Sharp | Sticky | Silk, Pure | Fragile cargo |
| `cli_c1_pit_fighter` | Pit Fighter | Sharp, Wild | Soft | Sharp, Metal | Arena bout |

### C2 clients

| id | Name | Threat tags | Punishes | Favors | Notes |
|---|---|---|---|---|---|
| `cli_c2_bog_messenger` | Bog Messenger | Sticky, Earth | Royal | Silent, Wild | Deliver through mire |
| `cli_c2_night_nun` | Night Nun | Lunar, Pure | Occult | Lunar, Soft | Vigil |
| `cli_c2_possessed_tailor` | Possessed Tailor | Occult | Pure | Occult, Silent | **possess event flag** possible |

### C3 clients

| id | Name | Threat tags | Punishes | Favors | Notes |
|---|---|---|---|---|---|
| `cli_c3_court_duelist` | Court Duelist | Royal, Sharp | Sticky | Royal, Metal | Formal duel |
| `cli_c3_tax_auditor` | Tax Auditor | Royal, Pure | Silent | Pure, Metal | Inspection |
| `cli_c3_parade_mage` | Parade Mage | Solar, Silk | Occult | Solar, Silk | Ceremony |

Draw: seeded pick from chapter client pool (avoid immediate repeat if pool >1).

## Event pools (per chapter)

Events are non-client mission beats (road, omen, market twist). May set letter flags.

### C1 events

| id | Name | Effect (draft) | Letter flag |
|---|---|---|---|
| `evt_c1_ashfall` | Ashfall | +Fire pressure; Soft gear chips | — |
| `evt_c1_scrap_market` | Scrap Market | Bonus Metal scrap offer next shop | — |
| `evt_c1_heat_mirage` | Heat Mirage | MOB checks harder | — |

### C2 events

| id | Name | Effect (draft) | Letter flag |
|---|---|---|---|
| `evt_c2_fog_bell` | Fog Bell | Lunar/Occult lean | — |
| `evt_c2_possession` | Thin Veil | Next client may gain **possess** flag | `client_possess` |
| `evt_c2_root_snare` | Root Snare | Sticky/Earth; MOB − | — |

### C3 events

| id | Name | Effect (draft) | Letter flag |
|---|---|---|---|
| `evt_c3_summons` | Court Summons | Royal PRE checks | — |
| `evt_c3_contraband` | Contraband Sweep | Sticky/Silent punished | — |
| `evt_c3_gala` | Gala Night | Solar/Royal favor | — |

## Mission node resolver

```
function run_chapter_missions(player, chapter_index, boss):
  order = CHAPTER_MISSION_ORDER  # [client, event, client]
  for kind in order:
    atelier_shop(player)               # or skip mid-shops if Design trims — Phase-1: shop before each
    if kind == client:
      threat = pick(CLIENT_POOLS[chapter_index])
    else:
      threat = pick(EVENT_POOLS[chapter_index])
      apply_event_flags(threat)
    craft = craft_garment(player)      # 2m1r default; consume deck
    gear  = resolve_craft(craft)
    result = run_mission(gear, threat) # 23 mission report + maybe letter
    stamp(..., phase="craft_task")
    ui.show_mission_result(result)
  atelier_shop(player)                 # last shop
  # then boss
```

## Cross-links

- Bosses: `17` · Mission report: `23` · Craft caps: `12b` · Flow pseudo: `21` · Stamps: `20`
