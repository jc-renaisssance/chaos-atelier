# Phase plan — Chaos Atelier

Updated **2026-09-28** after Jonathan stamp (travelling atelier schedule + stamina craft) + Aizen category / hygiene pass. **No Cursor budget add-on until monthly reset.** PixelLab may burn **this month’s remaining** quota when a gen lane is stamped.

## Live Design spine (2026-09-28)

| Lock | Where |
|------|--------|
| Travelling atelier + **schedule board** (`CHAPTER_ROUND_COUNT=8`, appointments) | `22-chapter-schedule` |
| Craft = **stamina hand game**; construction from order; infinite monostack gated by stamina | `27` |
| Synergy thresholds retuned (3 / 5 / apex 8 Fire·Metal·Earth); RETUNE applied | `14` |
| Pos + **neg** synergies; neg `outlook_order` **above** peers; rare/leg **skip all neg** | `14` / `18` |
| Owner = **player clothier**; Phase-1 = `own_basic` only | `16` / `19` |
| Boss pools C1–C3 → 27 paths; C1 diverse | `17` |
| Win-con / reps / newspaper / mission report | `24` / `25` / `26` / `23` |

**Superseded (history only):** 1-of-3 card lineup (`22-chapter-flow`, old `21`), `CHAPTER_NODE_BUDGET=3` shop↔craft clock, default **2m1r** slot UI (`12b`), construction picker in craft.

See also: [STAMP](../STAMP.md), [00-doc-categories](../00-doc-categories.md), [README](../README.md).

---

## Phase targets

### Phase 0 — Bible

- [x] Vision / loop / craft / clients / progression / art / phases seed
- [x] Materials dictionary + constructions + enchantments + synergies + outlook list + owners
- [x] Chapter schedule + stamina craft stamp (2026-09-28)
- [x] Category map + README / STAMP indexes
- [ ] Soft nits closed (this plan + categories explicit `23`–`26`)

**Exit:** stamped docs are the contract; no src required until Cursor reset.

### Phase 1A — Docs harden

- [x] Boss pools, rarity, `own_basic` starter, harness stamp fields
- [x] Schedule + stamina craft stamped
- [x] Optional: harness asserts retargeted off 2m1r / 1-of-3 → schedule + stamina (`20`)
- [ ] Optional: trim dictionary only if Jonathan asks

**Budget:** ~$0 Cursor on-demand (human / connector docs). No gens.

### Phase 1B — Client vertical slice (after monthly Cursor reset)

Ship **one** loop as `own_basic`:

1. Chapter start → schedule board + boss announce
2. Rounds (appointments / walk-in / wagon shop / event / prep craft)
3. Craft: stamina hand game (`27`) — order-fixed construction(s)
4. Resolver: tags → powers (skip neg on rare/legendary) → outlook = max order
5. Mission report + reps + newspaper
6. Boss → next chapter

Also: data tables from catalogs, one resolver, headless harness + stamp, placeholders for looks.

**Park:** multi-owner unlocks, encyclopedia, scars, named-unique art, full outlook matrix, skill owners catalog.

**Budget:** Cursor after reset (prefer included); **0** PixelLab from Client.

### Phase 1C — Art gen (only when Jonathan stamps)

- Batch **1 = armor × 10 outlooks** first (not full 50 until stamped)
- Optional later: robe/cloak/coat/tunic rows + atelier
- Burn **this month’s remaining** PixelLab only; hard stop; no gens on locked icons
- Neg outlook assets + other owners = Later

### Phase 2+ (park)

- Unlockable player-owners
- Full outlook matrix + neg looks
- Encyclopedia, scars, special clients, IAP wiring

---

## Spend envelope (tools)

| Line | Cap |
|------|-----|
| Cursor on-demand | **No add-on** until monthly reset; docs land via human commit |
| PixelLab | This-month remaining only; Phase-1C when Jonathan stamps |
| Grok | Quiet |

## Sequence

1. Close remaining 1A paper nits (this doc).
2. Hold Client (**1B**) until Cursor monthly reset.
3. Hold armor gens (**1C**) until Jonathan stamps the gen lane after docs confirmed.
4. Harribel watches if eng/gen opens.
5. Design / Test: harness retarget when Jonathan opens that lane.
