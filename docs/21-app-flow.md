# Application flow (pseudocode) — Phase-1 `own_basic`

Docs review. **No Client src until monthly Cursor reset.**

```
RUN
└─ CHAPTER ×3
   ├─ newspaper: announce boss from pool (17, 26)
   ├─ shop
   ├─ route ×3: player picks node (diff 1–3) → shop → craft(2m1r) → mission
   │     → ±reps (25) → newspaper if mid-fail
   ├─ if reps < gate → run_over (competitors)
   ├─ last shop → boss (fail = death, no retry)
   └─ newspaper: chapter result
```

Constants: `max_materials=2`, `max_runes=1`, route nodes=3, clear floor C, reps gates in `25`.

## Bootstrap

```
function start_run(seed):
  player.owner_id = "own_basic"
  player.reps = 0
  player.max_materials = 2
  player.max_runes = 1
  player.deck = starter_deck_own_basic()
  ...
```

## Chapter

```
function chapter_start(chapter_index, seed):
  boss = pick_chapter_boss(chapter_index, seed)
  newspaper.show(boss_announce, boss)      # 26
  state.reps_gate = REPS_GATE[chapter_index]
  state.rounds_left = 3
  return boss

function chapter_body(...):
  while state.rounds_left > 0:
    node = ui.pick_route_node(offers)      # StS — avoid hard if weak
    atelier_shop(player)
    if cant_craft(player):
      result = auto_fail_mission()
    else:
      craft = craft_garment(player)        # consume deck
      gear = resolve_craft(craft)
      result = run_mission(gear, node.threat)
    apply_reps(result, node.difficulty)
    if not result.cleared:
      newspaper.show(mid_fail, result)
    stamp(...); ui.show_mission_result(result)
    state.rounds_left -= 1
  if player.reps < state.reps_gate:
    newspaper.show(run_over_shop)
    run_over("reps_gate_miss")
    return
  atelier_shop(player)

function chapter_boss(player, boss):
  craft/gear/result = ...
  if not result.cleared:
    newspaper.show(run_over_death)
    run_over("boss_death")                 # no retry
  else:
    newspaper.show(chapter_result_clear)
```

## Review

Design: diverse C1 · reps · route pick · newspaper. Test: stamps `20` asserts 9–14. Client post-reset: implement this + `22`–`26`.
