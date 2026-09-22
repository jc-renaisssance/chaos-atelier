# Chapter bosses (Phase-1 stubs)

Jonathan / Aizen 1A: announced at **chapter start** so the player reshapes the deck toward threat tags before the boss node.

Phase-1 ships **three** stub bosses (one per chapter). Escalation flavor only — full ladder Later.

## Stub table

| id | Name | Chapter | Threat tags (cares about) | Punishes | Favors (build toward) | Environment |
|---|---|---:|---|---|---|---|
| `boss_ash_drake` | Ash Drake | 1 | Fire, Sharp | Soft, Sticky (burns / melts bonds) | Metal, Earth, Frost, Pure | Scorched gorge |
| `boss_mire_bride` | Mire Bride | 2 | Occult, Sticky, Lunar | Pure (rejects cleanse), Solar | Silent, Occult, Wild, Sticky | Fog marsh chapel |
| `boss_gilded_warden` | Gilded Warden | 3 | Royal, Metal, Solar | Silent (noise/law), Sticky (court insult) | Royal, Metal, Pure, Solar | Marble court |

## How Client uses this

1. Chapter start UI shows `boss_*` name + **threat tags** + one-line environment.
2. Adventure / boss sim weights checks: matching **Favors** tags on crafted gear help; **Punishes** tags hurt (or trigger funny fail lines).
3. Harness stamps `chapter_boss_id` + whether favor/punish tags were present on the build.

## Phase-1 rules

- Exactly one boss per chapter; chapter count = 3 for the vertical slice.
- No special-client / unique boss art in 1A–1B (placeholders OK).
- Design may add rows Later without changing the announce → shop → craft → shop → boss spine.
