# Chapter bosses — pools (3×3 → 27 run paths)

Jonathan lock (2026-09-22): each chapter has a **boss pool** of 3. At chapter start, **one** boss is drawn and announced via the **kingdom newspaper** (`26`). Full run = C1×C2×C3 → **27** combinations.

## Pools

### Chapter 1 — Outer Holdings (diverse — not all Fire)

| id | Name | Threat tags | Punishes | Favors | Environment |
|---|---|---|---|---|---|
| `boss_ash_drake` | Ash Drake | Fire, Sharp | Soft, Sticky | Metal, Earth, Frost, Pure | Scorched gorge |
| `boss_salt_widow` | Salt Widow | Frost, Sticky, Storm | Soft, Solar | Frost, Silent, Metal | Brine docks |
| `boss_rust_knave` | Rust Knave | Metal, Earth, Sharp | Soft, Silk | Metal, Earth, Sharp | Scrap yard |

### Chapter 2 — Mire Chapel

| id | Name | Threat tags | Punishes | Favors | Environment |
|---|---|---|---|---|---|
| `boss_mire_bride` | Mire Bride | Occult, Sticky, Lunar | Pure, Solar | Silent, Occult, Wild, Sticky | Fog marsh chapel |
| `boss_bog_king` | Bog King | Earth, Sticky, Wild | Royal, Solar | Earth, Sticky, Wild | Root throne |
| `boss_pale_choir` | Pale Choir | Lunar, Occult, Soft | Sharp, Metal | Lunar, Soft, Occult | Bone gallery |

### Chapter 3 — Marble Court

| id | Name | Threat tags | Punishes | Favors | Environment |
|---|---|---|---|---|---|
| `boss_gilded_warden` | Gilded Warden | Royal, Metal, Solar | Silent, Sticky | Royal, Metal, Pure, Solar | Marble court |
| `boss_ivory_judge` | Ivory Judge | Royal, Pure, Metal | Occult, Sticky | Pure, Royal, Metal | Hearing hall |
| `boss_sunspear_captain` | Sunspear Captain | Solar, Sharp, Metal | Silent, Soft | Solar, Sharp, Metal, Royal | Parade yard |

## Draw + announce

```
function pick_chapter_boss(chapter_index, seed):
  return seeded_choice(BOSS_POOLS[chapter_index], seed)

# UI: kingdom newspaper front page (26) — not a bare modal
```

- Announce **before** any shop spend that chapter.
- Harness: `chapter_boss_id`, `boss_pool_id`.
- Mid missions: StS-like **route pick** from chapter map (`22`).

## Phase-1 art

Boss portraits Later. Newspaper chrome can share atelier grain when 1C opens.
