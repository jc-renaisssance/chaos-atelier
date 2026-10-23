> **Superseded:** **1-of-3 card lineup** / `CHAPTER_ROUND_LIMIT=3` / Round board / free per-day `E*` board below is **not** the live chapter spine. Live = travelling atelier **route map with forks**, `CHAPTER_DAY_COUNT` = `map.day_count` (current map **8**) — [22-chapter-schedule](22-chapter-schedule.md). Craft = stamina mode — [27-craft-mode-stamina](27-craft-mode-stamina.md). **No `crafts_max`.** The `atelier_shop(player)` **opening-shop** / last-shop-before-boss calls below are **historical** — live **market** is a **route node** visit only ([32](32-shop-and-events.md); display Market, wire `kind=shop`; M1 materials / M2 Staffs·Skills·Gear). Keep this file as historical PR #7 shell notes.

## Boot (2026-10-23)

The process opens a **title screen**, then the route graph. It does not open `schedule_board` as `run/main_scene`. Law: [35](35-steam-demo-cut.md).

Client adds `res://src/ui/title/title_screen.tscn` and sets `project.godot` `run/main_scene` to that scene. The board scene stays the board.

| Control | Does |
|---|---|
| **New run** | Starts a chapter the way a run starts today. Newspaper, then the graph. |
| **Continue** | Resumes the profile save. Disabled when there is no save. |
| **Quit** | Leaves the process. |

Word on the screen: **Wombaste**. No seed field. No stamp dump.

`dev_tools` defaults **false**. Dex, **Reroll this chapter**, **Demo next chapter**, and the STAMP JSON dump are off that flag, on the board, never on the title. A demo boot does not show them.
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

**Was:** not an StS route map — **1 of 3 cards** per round (old `22-chapter-flow`). **Now:** hand-authored route map with forks — [22-chapter-schedule](22-chapter-schedule.md). Shop / event resolve — [32](32-shop-and-events.md). Do **not** auto-open shop before every order.

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

**Historical review:** Card lineup (not map) · reps · newspaper · C1 diversity · cant_craft F/hp>0. **Live spine:** route map ([22](22-chapter-schedule.md)) · stamina craft ([27](27-craft-mode-stamina.md)) · market visit + event resolve ([32](32-shop-and-events.md)). `cant_craft` at piece-cap is **GONE**. The 2026-10-12 free `E*` Day planner is **superseded**. Opening-shop in the pseudocode above is **not** live. Slice 4 playback (docs #69 / Client #70) sits on a Finish that already runs `run_mission`, then `ui.show_mission_result`. `cant_craft` still skips the timeline. This file’s pseudocode stays the historical shell. Until-M2 numbers are [33](33-until-m2-tuning.md).
