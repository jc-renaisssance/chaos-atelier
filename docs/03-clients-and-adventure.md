# Clients, bosses, adventure report

**Terminology (2026-10-05):** shop / walk-in / appointment / boss-pool people are **adventurers** — not “clients.” **Client** = Godot Client seat / codebase. Filename stays; Grimmjow owns deeper bible rename Later. See [STAMP](STAMP.md) · [pm/phase-1-plan](pm/phase-1-plan.md).

## Clients & events
Mid-chapter missions from **route-map nodes** on the **timetable** — live spine **[22-chapter-schedule](22-chapter-schedule.md)** (Days D1..DN; N = `map.day_count`; current map **8**; C1 sample graph with forks + bind). Appointments / walk-ins stay `appt_*` / `adv_*` on the node row. Appointment = **StS-elite analog**. Free per-day `E*` board ([#36](https://github.com/jc-renaisssance/chaos-atelier/pull/36)/[#37](https://github.com/jc-renaisssance/chaos-atelier/pull/37)), Round / schedule board, and 1-of-3 lineup ([22-chapter-flow](22-chapter-flow.md)) are **superseded**.

## Chapter bosses
**Pools of 3 per chapter**; one announced at chapter start — **[17-chapter-bosses](17-chapter-bosses.md)**. Full run → **27** boss combinations.

**Boss-client (2026-10-02):** a **client** is responsible for the boss event. Player crafts **for that client**; the **client fights** the boss (not the player). Sim uses that client's gear.

**Shared pool (same stamp):** one pool for **all** bosses / chapters, organized by **job title** — **not** a fixed client per boss. Draw at the boss beat, independent of which boss was announced. That job’s **order constructions** (`con_*`) + requirement tags are the craft brief. Catalog: **[28-boss-client-pool](28-boss-client-pool.md)**. **M1 draw — LOCKED (Jonathan 2026-10-08):** 4 jobs only (Knight, Mage, Blade Dancer, Lagoon) — [29](29-adventurer-catalog.md). Wizard / Hexer / Outrider / Oathbound stay Later/M2. Bosses / starter-tag law: [17](17-chapter-bosses.md). Route map: [22](22-chapter-schedule.md). Harness: [20](20-harness-stamp.md).

Mid-chapter appointments (incl. Scrap Duelist) stay `appt_*` — they are **not** the boss-client and **not** Dex Adventurers ([31](31-dex.md)). Do not pin them to reserved last-2 days.

## Mission report
Rating · HP remaining · damage aid % · skill effectiveness (≤5★) + optional adventurer letter — **[23-mission-report](23-mission-report.md)**.

## Balance harness
Stamp fields — **[20-harness-stamp](20-harness-stamp.md)**.
