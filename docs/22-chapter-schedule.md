# Chapter schedule — travelling atelier (Jonathan stamp 2026-09-28)

**Status:** Design stamped. Supersedes short shop↔craft node clocks (`CHAPTER_NODE_BUDGET=3` in older `21`) and branching path maps. Supersedes PR #7 chapter “1-of-3 card lineup / 2 clients + 1 event” shell for Design lock.

## Fiction

The atelier rides a **horse-car / wagon** (or other transport). The shop moves with the road. Each chapter is one stretch: schedule of stops → destination **chapter boss**.

## Constants (Phase-1)

| Key | Value | Notes |
|---|---|---|
| Chapters per run | 3 | Unchanged |
| `CHAPTER_ROUND_COUNT` | **8** | Allowed band 6–10; 8 is the stamp |
| Crafts max per chapter | **4** garments | More rounds ≠ more forced crafts. Cap is **pieces** (garment pieces), same meaning as [`20`](20-harness-stamp.md) — not whole orders. |
| Boss telegraph | Chapter start | Boss announced before spend |
| Final rounds | Last **2** | Reserved: travel / final prep / boss — appointments cannot claim these |

## Schedule board (not a path map)

At chapter start the UI shows a **timeline of rounds 1..8**. Skill is assigning **today** and planning **tomorrow**, not picking left/right branches.

### Round action types

| Action | What it does |
|---|---|
| **Appointment** | Locked famous/important client order on a pinned future round |
| **Walk-in** | Client/order that appears this round |
| **Wagon shop** | Buy / sell / reshape material deck (stock rotates with travel) |
| **Wagon event** | Travel / road event |
| **Prep craft** | Enter craft mode without a live client — build into a ready rack for a later appointment |
| **Rest / dig** | Recover light stamina meta Later; or inventory dig outside craft (optional Phase-1) |

Each round: player picks **one** primary action (Phase-1). Later: dual actions via skills.

## Appointments (elite telegraph)

- At chapter start, reveal **2–4** named appointments pinned to future rounds (like StS elites visible ahead).
- Optional mid-chapter refresh may add 0–1 more (Later).
- On the pinned round, taking the appointment **enters craft mode once** for that order. Multi-piece = **one** parallel session ([27](27-craft-mode-stamina.md)) — **not** N sequential sessions. `crafts_done` still counts **pieces**.
- **Decline / reschedule:** Later (rep cost). Phase-1: decline allowed once per chapter at −reps.
- **Show up unready** (no matching prep / empty deck): worse payout, fail-leaning mission result, normal fail reps (not death unless sim says so).

## Boss

- Announced at chapter start (favor / punish / environment from `17`). Newspaper announces the **boss**, not the client (`26`).
- After round budget, final prep window → **draw one adventurer from the shared boss-client pool** (`28`) → **craft that job’s order constructions** → that **adventurer** fights the announced boss. Sim uses **that client's gear**. Player is not the fighter (`03`, `17`, `28`).
- Pool is **shared across all bosses / chapters**, by **job title**. Draw is **independent** of `chapter_boss_id`. Order constructions are the listed `con_*` for that job (e.g. knight → `con_armor` + `con_gloves` / gauntlet).
- Boss fail (boss-client / adventurer dead / hard loss): **`run_over`**, no retry (Phase-1 hardcore).
- **Appointments stay appointments.** Scrap Duelist and other mid-chapter named clients are `appt_*`. They are **not** the boss-client. Do not pin Scrap Duelist to reserved rounds (7–8) or the boss beat.
- Portraits / UI widgets = **Later**. Job catalog is stamped in `28` — do not invent Godot scenes or art.

## Explicit non-goals

- Branching StS path map
- Auto 3-node shop↔craft clock
- Forcing a craft every round
