# Application flow (pseudocode) — Phase-1 `own_basic`

**Status:** docs review (Jonathan 2026-09-22+). **No Client src until monthly Cursor reset.**

Contract: `10`–`23`. Player = `own_basic` only.

```
RUN
└─ CHAPTER ×3
   ├─ pick boss from chapter pool (17) → announce
   ├─ shop
   ├─ missions ×3 = client → event → client  (22)
   │    each: shop → craft(2m1r) → mission report(+letter?) →
   ├─ last shop
   └─ boss fight → next chapter
```

**Constants:**

```
MISSIONS_BEFORE_BOSS = 3
CHAPTER_MISSION_ORDER = [client, event, client]
max_materials = 2 + skill_bonuses   # default 2
max_runes     = 1 + skill_bonuses   # default 1
```

---

## 0. Run bootstrap

```
function start_run(seed):
  player.owner_id = "own_basic"
  player.skills   = []
  player.staff    = []
  player.gold     = 12
  player.deck     = starter_deck_own_basic()
  player.constructions_unlocked = [tunic, cloak, armor, robe, coat]
  player.max_materials = 2
  player.max_runes     = 1
  chapter_index = 1
  stamp_run_start(player, seed)
```

---

## 1. Chapter start — boss from pool

```
function chapter_start(chapter_index, seed):
  boss = pick_chapter_boss(chapter_index, seed)  # 17 — 1 of 3
  ui.show_boss_announce(boss)
  state.chapter_boss_id = boss.id
  state.boss_pool_id    = f"c{chapter_index}"
  return boss
```

---

## 2. Atelier shop

(unchanged spine — `19` weights; player atelier not NPC.)

---

## 3. Craft — construction compulsory, default 2m1r

```
function craft_garment(player):
  construction = ui.pick_construction(...)   # REQUIRED

  materials = []
  loop until len(materials) in 1..player.max_materials and ui.confirm:
    mat = ui.pick_from_deck(player.deck)
    player.deck.remove(mat)                  # CONSUME
    materials.append(mat)

  runes = []
  loop until len(runes) in 0..player.max_runes and ui.confirm:
    enc = ui.pick_rune_or_done(...)
    if enc: player.consume_rune(enc); runes.append(enc)

  return Craft(construction, materials, runes)  # Phase-1: treat runes[0] as single enc in resolver
```

Resolver / rarity / neg / outlook: same as before (`14`, `18`) — if multiple runes Later, bag-count all rune tags.

---

## 4. Mission report

```
function run_mission(gear, threat) -> MissionResult:   # 23
  sim = deterministic_sim(gear, threat)
  result = build_mission_result(gear, threat, sim)
  # rating, hp_remaining, damage_aid_pct, skill_effectiveness ★≤5
  result.letter = maybe_letter(gear, result, threat.event_flags)
  apply_rewards(player, payout(result))
  return result
```

---

## 5. Chapter body + boss

```
function chapter_body(player, chapter_index, boss):
  for kind in CHAPTER_MISSION_ORDER:       # client, event, client
    atelier_shop(player, boss)
    threat = pick_client_or_event(chapter_index, kind)  # 22
    craft  = craft_garment(player)
    gear   = resolve_craft(craft)
    result = run_mission(gear, threat)
    stamp_craft_run(..., phase="craft_task", mission=result)
    ui.show_mission_result(result)         # card + optional letter
  atelier_shop(player, boss)               # last shop

function chapter_boss(player, boss):
  craft  = craft_garment(player)
  gear   = resolve_craft(craft)
  result = run_mission(gear, threat=boss)
  stamp_craft_run(..., phase="boss", mission=result)
  ui.show_boss_result(result)
  advance_or_end_run()
```

---

## 6. Main

```
function main():
  start_run(seed)
  while chapter_index <= 3:
    boss = chapter_start(chapter_index, seed)
    chapter_body(player, chapter_index, boss)
    chapter_boss(player, boss)
    chapter_index += 1
  show_run_summary()  # path = 1 of 27 boss combos
```

---

## UI screens

| Screen | Shows |
|---|---|
| Chapter announce | Boss from pool (name, tags, env) |
| Atelier shop | Gold, deck, offers |
| Craft | Construction required; up to 2 mats + 1 rune; deck consume |
| Mission result | Rating · HP left · damage aid % · ★ skill · powers; letter if any |
| Boss result | Same + chapter advance |

Art: after this doc stamp → **1C armor outlook gens** first (Jonathan).

---

## Review checklist

| Role | Check |
|---|---|
| Design | Boss pools 3×3; 2m1r; mission card+letter; client/event order |
| Test | Stamp mission fields + letter_id; rarity→neg; 27-path smoke later |
| Client post-reset | Implement this + `22`/`23` |
