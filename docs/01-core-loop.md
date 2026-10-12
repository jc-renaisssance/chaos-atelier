> **Superseded (2026-10-12 Jonathan stamp):** Round / schedule board (`CHAPTER_ROUND_COUNT=8` as law, R1..R8, `crafts_max=4`) is replaced by the travelling atelier **Day planner** — [22-chapter-schedule](22-chapter-schedule.md). Day count = `map.day_count` (current map **8**). Craft UX is stamina hand game — [27-craft-mode-stamina](27-craft-mode-stamina.md). 1-of-3 card lineup and shop↔craft node clock are **not** live. Piece cap is **GONE**.
# Core loop

## Chapter loop (Day planner — Jonathan lock 2026-10-12)

1. **Chapter start:** the **chapter boss is announced** (name / threat tags / environment). Player sees the target before spending.
2. **Day planner:** preview **all possible options per day** (expand / popup) from the `E*` pool, then **assign** D1..(N−2). N = `map.day_count` (current map **8**). Last 2 days reserved (current map: D7 travel / final prep, D8 boss approach). Fixed-window events pin. Planner **can be updated mid-chapter** (unplayed assignable days).
3. **Play days:** the assigned option that day (shop / adventurer order / appointment / wagon event / prep). Orders enter **stamina craft** ([27](27-craft-mode-stamina.md)) — **unlimited pieces** / chapter; stamina still gates a session.
4. **Reserved last-2** then **Boss:** draw a **shared-pool** adventurer from the **M1 4-job pool** (`28` / `29` — Knight, Mage, Blade Dancer, Lagoon; **LOCKED** Jonathan 2026-10-08); craft that job’s **order constructions**; that client fights the announced boss (player is not the fighter — `17`).
5. Next chapter (harder boss announced at its start; that map’s own `day_count`).

Goal: adjust the deck knowing the boss (StS-style). Different **player owners** (Later) change your material access and skills (Balatro-style character fantasy).

## Single client beat (inside a day)

1. **Adventurer** arrives with a clear threat (or appointment / walk-in from the day’s `E*`).
2. Select **materials** from deck (multi-stack into construction slots).
3. Combine **Construction + 1..N Materials + 0..1 Enchantment** via stamina plays.
4. Resolver: stats + powers; **neg syn skipped** on rare/legendary; **outlook** = highest `outlook_order` (negs beat peers when live).
5. **Adventure simulation** — short report.
6. **Result** → gold, materials, reputation; scars Later.

## Phase-1 ship spine

One loop UI: Day planner assign → day’s option → craft (if order) → adventure report, as **`own_basic`**, with chapter boss known at chapter start.

Defer encyclopedia, special clients, multi-owner unlocks, and parallel meta until that holds.
