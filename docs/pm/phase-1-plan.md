# Phase plan — Chaos Atelier

Updated 2026-09-21 after bible dictionary [#3](https://github.com/jc-renaisssance/chaos-atelier/pull/3) merge + Jonathan locks. **No Cursor budget add-on until monthly reset.** PixelLab may burn **this month’s remaining** quota when a gen lane is stamped.

## Review stamp (Aizen / #3)

Docs OK for now:

| Lock | Where |
|------|--------|
| Metal family + multi-stack slots | `11` / `12` |
| Pos + **neg** synergies; neg `outlook_order` **above** peers | `14` |
| Rare / legendary **skip all neg syn** | `14` |
| Outlook = max order; Phase-1 gen batch **50** (+ optional `atelier_own_basic`) | `15` |
| **Owner = player clothier** (pool + player skills), not shop NPC; Phase-1 `own_basic` only | `16` / `01` |
| Chapter: boss announced at start → shop → craft/task → shop → boss | `01` |

Open balance numbers stay first-pass until Mid/Mid smoke.

---

## Phase targets

### Phase 0 — Bible (NOW → done when stamped)

- [x] Vision / loop / craft / clients / progression / art / phases seed
- [x] Materials dictionary + constructions + enchantments + synergies + outlook list + player owners
- [ ] PM phase plan (this doc) on `dev`
- [ ] Jonathan stamp: open next lane (more docs polish vs Client vs gen)

**Exit:** dictionary is the contract; no src required.

### Phase 1A — Docs harden (default next if Jonathan wants more paper)

- Threat / chapter-boss stub table (tags the announced boss cares about)
- Rarity band rules (how rare/legendary is computed from stacks)
- Starter deck + `own_basic` shop weights (which commons stock)
- Harness stamp field list locked for Test (`powers_fired`, neg ids, stacks, `outlook_order`, `player_owner_id`, chapter boss id)
- Optional: trim / expand dictionary only if Jonathan asks

**Budget:** ~$0 Cursor on-demand (GitHub docs). No gens.

### Phase 1B — Client vertical slice (when Jonathan opens eng)

Ship **one** loop as `own_basic`:

1. Chapter start shows boss
2. Atelier shop (basic pool)
3. Craft: construction + multi-stack materials + 0–1 enchant
4. Resolver: tags → powers (skip neg on rare/legendary) → outlook = max order
5. Adventure report (tags fired / outcome)
6. Shop → repeat → boss

Also: data tables from `10`–`16`, **one** resolver, headless harness + stamp, placeholders for looks.

**Park:** multi-owner unlocks, encyclopedia, scars, named-unique art, full 408 outlook matrix, skill owners.

**Budget:** Cursor ≤ remaining on-demand until reset (prefer included when available); **0** PixelLab from Client.

### Phase 1C — Art gen (only when Jonathan stamps)

- Batch **50** garment outlooks (`armor/robe/cloak/coat/tunic` × 10 looks) per `15`
- Optional +1 `atelier_own_basic`
- Burn **this month’s remaining** PixelLab only; hard stop; no gens on locked icons
- Neg outlook assets + other owners = Later

### Phase 2+ (park)

- Unlockable player-owners (forge / voodoo / tech / moon / skill kits)
- Full outlook matrix (~408) + neg looks
- Encyclopedia, scars, special clients, IAP wiring

---

## Spend envelope (tools)

| Line | Cap |
|------|-----|
| Cursor on-demand | **No add-on** until monthly reset; burn carefully if eng opens |
| PixelLab | This-month remaining only; Phase-1C ask **≤50 (+1 atelier)** when stamped |
| Grok | Quiet |

## Sequence when Jonathan opens

1. Choose **1A** (more docs) and/or **1B** (Client) — default recommend **1A stubs then 1B**.
2. Harribel: watches if eng/gen opens.
3. Design: only if 1A gaps.
4. Client → Test smoke after catalog wired.
5. Gen lane **only** after Jonathan stamps 1C.
