# Chapter bosses — pools (3×3 → 27 run paths)

Jonathan lock (2026-09-22): each chapter has a **boss pool** of 3. At chapter start, **one** boss is drawn from that chapter’s pool and announced. Full run = C1×C2×C3 picks → **3³ = 27** encounter combinations.

## Pools

### Chapter 1 — Scorch Corridor

| id | Name | Threat tags | Punishes | Favors | Environment |
|---|---|---|---|---|---|
| `boss_ash_drake` | Ash Drake | Fire, Sharp | Soft, Sticky | Metal, Earth, Frost, Pure | Scorched gorge |
| `boss_cinder_hound` | Cinder Hound | Fire, Wild | Soft, Silent | Metal, Earth, Sharp | Ash flats |
| `boss_glass_phoenix` | Glass Phoenix | Fire, Solar | Frost, Occult | Solar, Pure, Silk | Mirage spire |

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

## Draw rule

```
function pick_chapter_boss(chapter_index, seed):
  pool = BOSS_POOLS[chapter_index]   # length 3
  return seeded_choice(pool, seed)  # uniform; no repeats required across runs
```

- Announce **before** any shop spend that chapter.
- Harness stamps `chapter_boss_id` + `boss_pool_id` (`c1` / `c2` / `c3`).
- Mid-chapter clients may echo pool themes but are not bosses (see `22-chapter-flow.md`).

## Phase-1 art

Boss portraits Later. Placeholders OK until stamped.
