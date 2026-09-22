# Application flow (pseudocode) — Phase-1 `own_basic`

```
RUN
└─ CHAPTER ×3
   ├─ newspaper: announce boss
   ├─ opening shop
   ├─ route ×3: pick node → shop → craft(2m1r) → mission → ±reps
   │     → newspaper if mid-fail
   ├─ if reps < gate → run_over
   ├─ last shop → boss (fail = death, no retry)
   └─ newspaper: chapter result
```

**Shop order (locked):** `pick → shop → craft` (+ last shop before boss).

## Chapter body

```
function chapter_body(...):
  atelier_shop(player)                     # opening
  while state.rounds_left > 0:
    node = ui.pick_route_node(offers)      # FIRST
    atelier_shop(player)                   # THEN shop → craft
    if cant_craft(player):
      result = MissionResult(
        rating="F", hp_remaining=1,        # >0 — no death Δ
        damage_aid_pct=0, cleared=false, cant_craft=true)
    else:
      craft = craft_garment(player)
      gear = resolve_craft(craft)
      result = run_mission(gear, node.threat)
    apply_reps_delta(result, node.difficulty)
    if not result.cleared:
      newspaper.show(mid_fail, result)
    stamp(...); ui.show_mission_result(result)
    state.rounds_left -= 1
  if player.reps < state.reps_gate:
    run_over("reps_gate_miss")
    return
  atelier_shop(player)                     # last before boss
```

## Review

Design/Client/Test: shop order + cant_craft path pinned. Armor 1C waits Jonathan stamp.
