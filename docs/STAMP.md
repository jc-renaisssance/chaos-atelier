# Jonathan stamp — 2026-09-28 (Chaos Atelier)

## Locked

1. **Travelling atelier** (wagon/horse-car) + **schedule board** (not path map).
2. **3 chapter bosses** kept; **`CHAPTER_ROUND_COUNT = 8`** (band 6–10).
3. **Appointments** on future rounds (elite telegraph).
4. **Craft mode** = stamina hand game; construction **from order** (multi-piece OK).
5. Hand = **materials + enchantments + owner skills** only (no construction cards).
6. Hand **does not auto-refill**; stamina refresh digs inventory.
7. Craft ends on **stamina empty** or **early finish**.
8. **Infinite monostack** allowed; gated by stamina/skills/refresh.
9. Synergies + outlook art kept; thresholds **retuned** (3 / 5 / apex 8 for Fire·Metal·Earth).

## Files in this drop

| File | Action |
|---|---|
| `docs/22-chapter-schedule.md` | **Add** (canonical `22` — schedule only) |
| `docs/27-craft-mode-stamina.md` | **Add** (renamed from provisional `23-craft-mode-stamina.md`; `23` stays mission-report) |
| `docs/14-synergies-RETUNE.md` | Stamp source; **merged** into `docs/14-synergies.md` (replace thresholds) |
| Update README / `00-doc-categories` / `01` / `02` / `21` / `12` / `20` | Point at new spine; mark 2m1r / node clock / construction picker / 1-of-3 **superseded** |
| `docs/22-chapter-flow.md` | Kept as history; **superseded** by schedule |

## Blocked

Cursor cloud agent launch refused: **Cursor usage exhausted** (on-demand required). Docs written locally for manual apply or relaunch after on-demand / monthly reset.

## Supersedes

- `CHAPTER_NODE_BUDGET=3` shop↔craft clock
- Construction picker in craft UI
- Default 2m1r as hard craft shape
- PR #7 chapter shell assumptions (appointments/schedule replace card lineup)
- Doc-id collision: provisional craft `23` → `27` so `23-mission-report` stays stable

---

# Jonathan stamp — 2026-09-29 (synergy tier extension)

## Locked (docs only)

1. **Most positive monostack tags** use **≥3 / ≥5 / ≥8** (extend beyond Fire·Metal·Earth).
2. **Frost:** `syn_frost_5` mid + `syn_frost_8` apex; mid art `look_armor_frost_3` → `frost_5`; apex art Later.
3. **Royal stamped armor = APEX** (`look_armor_royal` → `royal_8` / `syn_royal_8`), not low.
4. **Silent / silk:** mid + apex syn rows added; art Later (stamped unnumbered assets map to low `_3` for now).
5. **Cross-tags:** ≥1∧≥1 power + single outlook; no monostack tiers — reviewed in `14`.
6. Docs only — no PixelLab, no game code this pass.

## Files in this drop

| File | Action |
|---|---|
| `docs/14-synergies.md` | Tier table + frost mid/apex + royal apex lock + cross-tag review |
| `docs/14-synergies-RETUNE.md` | Append 2026-09-29 extension note |
| `docs/15-outlook-gen-list.md` | Replace stale 10-id list; remap legacy filenames; art gaps |
| `docs/STAMP.md` | This note |

## Art gaps (armor) — superseded evening

Morning gaps for frost/silent/silk/royal mid+apex are **closed** by the stamped pack (see evening stamp below). Remaining: cross-tag + neg outlooks; other-owner-pool tags.

---

# Jonathan stamp — 2026-09-29 evening (armor pack complete + owner pool)

## Locked

1. **Armor image lineup DONE** for traveler / atelier default: stamped pack covers plain + metal/earth/fire/frost ladders + silent/silk/royal ladders + freestanding frost apex. **Do not** plan more monostack armor gens for storm / lunar / solar / sticky / sharp / soft / wild / occult / pure.
2. **Tomorrow focus:** cross-tag positive syn + negative syn (art/docs as needed).
3. **Other syn lines** (lunar, solar, storm, sticky, sharp, soft, wild, occult, pure, …) → **other shop owner pool** — not traveler/atelier default armor outlooks. Power rows stay in `14`; armor outlook gen parks under other owners ([15](15-outlook-gen-list.md)).
4. **Stamped filenames:** silent/silk/royal use `_3` / `_5` / `_8`; metal/earth/fire/frost low+mid still legacy `*_2` / mid `*_3`; all apex `*_8` including frost. `04-syn/` may only have `look_armor_royal` alias (or empty).

## Files in this drop

| File | Action |
|---|---|
| `docs/14-synergies.md` | Locks + open: armor DONE, other-owner pool, next = cross-tag/neg |
| `docs/14-synergies-RETUNE.md` | Note frost apex stamped; evening sync appendix |
| `docs/15-outlook-gen-list.md` | Reflect stamped `_3`/`_5`/`_8`; complete default armor table; other-owner pool; next = cross/neg |
| `docs/STAMP.md` | This note |
| `armor-stamped-2026-09-29/` | Local stamped pack (untracked or local-only unless added) |

## Next

- Cross-tag positive + negative syn art/docs
- Other shop owner armor outlooks when that shop work starts

---

# Jonathan stamp — 2026-10-02 (cross-tag positive armor)

`armor-cross-tag-locked-2026-10-02/` — locked Storm / Beastbloom / Snaretooth / Masked Crown / Dawn Vestment / Pale Hex (`_3` / `_5` / `_8`).
