# Application flow (pseudocode) — Phase-1 `own_basic`

```
RUN
└─ CHAPTER ×3
   ├─ newspaper: announce boss
   ├─ opening shop
   ├─ rounds ×3:
   │     lineup 3 cards → pick 1
   │       order  → shop → craft → mission → ±reps
   │       event  → resolve event → ±reps if any
   │     newspaper if fail
   ├─ if reps < gate → run_over
   ├─ last shop → boss (fail = death, no retry)
   └─ newspaper: chapter result
```

**Not** an StS route map — **1 of 3 cards** per round (`22`).

## Chapter body

```
function chapter_body(...):
  atelier_shop(player)                     # opening
  rounds_left = CHAPTER_ROUND_LIMIT        # 3
  while rounds_left > 0:
    cards = lineup_round(chapter_index)    # exactly 3
    choice = ui.pick_one(cards)
    if choice.kind == order:
      atelier_shop(player)
      if cant_craft(player):
        result = MissionResult(rating="F", hp_remaining=1,
          damage_aid_pct=0, cleared=false, cant_craft=true)
      else:
        craft = craft_garment(player)
        gear = resolve_craft(craft)
        result = run_mission(gear, choice.client)
      apply_reps_delta(result, choice.difficulty)
      if not result.cleared: newspaper.show(mid_fail, result)
      stamp(...); ui.show_mission_result(result)
    else:
      result = resolve_event(choice.event)
      apply_reps_delta_if_any(result, choice.difficulty)
      if result.failed: newspaper.show(mid_fail, result)
      stamp(...); ui.show_event_result(result)
    rounds_left -= 1                       # pick ends the round
  if player.reps < state.reps_gate:
    run_over("reps_gate_miss")
    return
  atelier_shop(player)                     # last before boss
```

## Review

Card lineup (not map) · reps · newspaper · C1 diversity · cant_craft F/hp>0. Armor 1C waits Jonathan stamp.
