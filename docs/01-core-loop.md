> **Superseded (2026-10-13 Jonathan stamp):** the free per-day `E*` options board ([#36](https://github.com/jc-renaisssance/chaos-atelier/pull/36)/[#37](https://github.com/jc-renaisssance/chaos-atelier/pull/37)) is replaced by a **hand-authored route map with forks** — [22-chapter-schedule](22-chapter-schedule.md). Day count = `map.day_count` (current map **8**). Combos = bound multi-day blocks. Craft UX is stamina hand game — [27-craft-mode-stamina](27-craft-mode-stamina.md). Round board, 1-of-3 lineup, and shop↔craft node clock are **not** live. Piece cap is **GONE**. Display name **Wombaste**.
# Core loop

## Chapter loop (route map — Jonathan lock 2026-10-13)

1. **Chapter start:** the **chapter boss is announced** (name / threat tags / environment). Player sees the target before spending.
2. **Route map / timetable:** walk the authored graph for this map. N = `map.day_count` (current map **8**). Last 2 days reserved (current map: D7 travel / final prep, D8 boss approach). At **forks** pick 1 of **2–4** visible next nodes (type + id). **Bound** days have no options panel. **No choice → no panel.** Past is frozen. Shop visits 1–3 come from how many shop nodes the path hits — not a UI ban.
3. **Play days:** the current node (shop / adventurer / appointment-elite / event / reserved). Orders enter **stamina craft** ([27](27-craft-mode-stamina.md)) — **unlimited pieces** / chapter; stamina still gates a session.
4. **Reserved last-2** then **Boss:** draw a **shared-pool** adventurer from the **M1 4-job pool** (`28` / `29` — Knight, Mage, Blade Dancer, Lagoon; **LOCKED** Jonathan 2026-10-08); craft that job’s **order constructions**; that client fights the announced boss (player is not the fighter — `17`).
5. Next chapter (harder boss announced at its start; that map’s own `day_count` + graph).

Goal: adjust the deck knowing the boss (StS-style). Different **player owners** (Later) change your material access and skills (Balatro-style character fantasy).

## Single client beat (inside a day)

1. **Adventurer** arrives with a clear threat (or appointment / walk-in from the current route node).
2. Select **materials** from deck (multi-stack into construction slots).
3. Combine **Construction + 1..N Materials + 0..1 Enchantment** via stamina plays.
4. Resolver: stats + powers; **neg syn skipped** on rare/legendary; **outlook** = highest `outlook_order` (negs beat peers when live).
5. **Adventure simulation** — short report.
6. **Result** → gold, materials, reputation; scars Later.

## Phase-1 ship spine

One loop UI: timetable (fork pick or pinned corridor/bind) → day’s node → craft (if order) → adventure report, as **`own_basic`**, with chapter boss known at chapter start.

Defer encyclopedia, special clients, multi-owner unlocks, and parallel meta until that holds.
