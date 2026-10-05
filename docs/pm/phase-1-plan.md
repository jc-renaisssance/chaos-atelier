# Roadmap — Chaos Atelier

Updated **2026-10-05** after Jonathan stamp (M1 ugly full-experience Client + M2 Steam demo + **adventurers** terminology). **Supersedes** the 2026-09-28 Cursor-reset / Phase-0–1C framing in this file.

See also: [STAMP](../STAMP.md), [00-doc-categories](../00-doc-categories.md), [README](../README.md).

---

## Terminology

Call shop / walk-in / appointment / boss-pool people **adventurers**. Do **not** call them “clients.”

**Client** = the Godot **Client** seat / codebase only.

This PR locks the term in PM + STAMP. It does **not** mass-rename historical bible docs. Grimmjow owns deeper bible renames Later. One-line pointers: [03](../03-clients-and-adventure.md), [28](../28-boss-client-pool.md).

---

## Already on `dev`

As of tip `1082ef5` (Client + Design stamps through 2026-10-02):

| Landed | Where |
|--------|--------|
| Travelling atelier + schedule board (`CHAPTER_ROUND_COUNT=8`) | `22-chapter-schedule` |
| Craft = stamina hand game; construction from order | `27` |
| **Finish-only** (stamina 0 ≠ finish) | `27` / Client |
| **StS** cycle (play→discard, dig dump, reshuffle) + Current/Potential | `27` / Client |
| **Multi-piece** parallel session (dedicated UI, `12 × N` stamina, ≤4 zones) | `27` / Client |
| Shared boss-adventurer pool by job + C1–C3 rewrite | `28` / `17` / Client |
| Synergy thresholds, pos+neg, rarity skip-neg | `14` / `18` |
| Owner = player clothier; Phase-1 = `own_basic` | `16` / `19` |
| Win-con / reps / newspaper / mission report (docs) | `24` / `25` / `26` / `23` |

**Jonathan confirmed 2026-10-05:** C1 **craft path works**. Shop systems and events are **not done yet**.

**Superseded (history only):** 1-of-3 card lineup, `CHAPTER_NODE_BUDGET=3` shop↔craft clock, default 2m1r slot UI, construction picker in craft, sequential per-piece stamina, auto-finish on `stamina_0`, fixed-client-per-boss, “hold Client until Cursor monthly reset.”

---

## Milestone 1 — Ugly full-experience Client (limited options)

Fully developed **ugly** Client that ships the **full experience** with **limited content options**.

| Lock | Note |
|------|------|
| Limited **adventurer jobs** | Count / which jobs = Grimmjow Design catalog. Do not invent a set here. |
| Limited **enemy types** | Same — Design stamps the cut. |
| Shop adventurers | **More than one adventurer per job/class.** |
| Catalog before wire | Define **stats / skills / requirement tags** first. Design catalog lands before Client wires people. |
| Shop + events | **Not done yet.** Still required for “full experience” under M1. |
| Art | Panels / partial armor fallbacks OK for M1. |
| Demo seed | Pinned demo seed = **optional**. |

### Interactive order pack (2026-10-05, text-first)

| Slice | What |
|------:|------|
| 1 | Adventurer **stats/skills panel** on the order |
| 2 | **Unlocked syn-target draft** under that panel — persist unlocks **across runs** |
| 3 | **Enemy quest brief** + estimate/outcome window (extends Current/Potential; unlocked items shown, `?` if locked) |
| 4 | After-craft **battle playback** (deterministic from mission resolver) then **posture art slots** — can follow 1–3 |

Slices 1–3 are Design-then-Client. Slice 4 art (postures/posters) waits for Jonathan to open that lane for M1 **or** defer it to M2.

---

## Milestone 2 — Steam demo

| Lock | Note |
|------|------|
| Ugly UI | Replaced / handled |
| Art | Adventurer (and related Client) arts **mostly done** |
| Remaining | Stat / event **tuning** + art gen **fill** |
| Ship scope | **Not** shipping the full game this month |
| Budget | PixelLab / Cursor treated as **fine** for this plan. Harribel watches burn. |

---

## Sequence after this stamp merges

1. **Grimmjow** — Design docs: limited M1 job set + multi-adventurer-per-job catalog (stats / skills / requirement tags) + interactive-order docs for slices **1–3**. **Landed:** [29-adventurer-catalog](../29-adventurer-catalog.md) · [30-interactive-order](../30-interactive-order.md).
2. **Ulquiorra** — Client PRs **after** those Design stamps land. Do not invent catalog in Client.
3. **Szayelaporro** — Godot re-smoke **each** Client land.
4. **Slice 4 art** (postures/posters) — when Jonathan opens that lane for M1, or defers to M2.

This stamp is **docs only**. No game Client code in this drop.

---

## Park / Later (not M1 exit)

- Unlockable player-owners, encyclopedia, scars, named-unique art, full outlook matrix
- Full game ship (beyond Steam demo)
- Grimmjow deeper bible “client” → adventurer renames
- 0-cost cards / further owner abilities at 0 stamina
- N > 4 zones / split orders

---

## Spend envelope (tools)

| Line | Cap |
|------|-----|
| Cursor / PixelLab | **Fine** for this plan (2026-10-05). Harribel watches burn. |
| Grok | Quiet |

**Supersedes** 2026-09-28: “no Cursor add-on until monthly reset” / “0 PixelLab from Client” / hold 1B until reset.
