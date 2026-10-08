# Chapter bosses — pools (3×3 → 27 run paths)

Jonathan lock (2026-09-22): each chapter has a **boss pool** of 3. At chapter start, **one** boss is drawn and announced via the **kingdom newspaper** (`26`). Full run = C1×C2×C3 → **27** combinations.

Jonathan lock (2026-10-02): bosses are **big chapter threats**. The fighter is a **shared-pool adventurer** (`28`) — **not** a fixed client per boss. C2/C3 **de-favor** `own_basic` starter tags (`19`).

## Starter-tag law

Starter-relevant tags from `own_basic` mats (`19`): **Soft, Earth, Metal, Wild, Silk, Pure** (Soft / Earth / Metal staples).

| Chapter | Starter tags |
|---|---|
| **C1** | May still clear on Soft / Earth / Metal / Wild / Silk / Pure. Approachable. |
| **C2 / C3** | Punish those tags and/or favor tags **outside** the starter set — Frost, Fire, Occult, Lunar, Solar, Royal, Sharp, Sticky, Silent, Storm, … Early deck alone is weaker. |

Favor / punish below is **vs the announced boss** (gear tags in the sim). Job **requirement tags** (`28`) are a separate axis — the order, not the threat.

## Pools

### Chapter 1 — Outer Holdings (diverse — not all Fire)

Big first-stretch threats. Soft still burns; scrap and stone still hold.

| id | Name | Threat tags | Punishes | Favors | Environment |
|---|---|---|---|---|---|
| `boss_ash_drake` | Ash Drake | Fire, Sharp | Soft, Sticky | Metal, Earth, Frost, Pure | Scorched gorge — wyrm-breath cooks the soft |
| `boss_salt_widow` | Salt Widow | Frost, Sticky, Storm | Soft, Solar | Frost, Silent, Metal | Brine docks — salt webs; spray that sloughs cloth |
| `boss_rust_knave` | Rust Knave | Metal, Earth, Sharp | Soft, Silk | Metal, Earth, Sharp | Scrap yard — a knave grown from the pile |

- **Ash Drake** — gorge-wyrm. Heat and tooth. Soft / sticky cook off; metal, earth, frost, and clean weave hold.
- **Salt Widow** — widow of the brine docks. Soft dissolves in the spray; frost, silent, and metal keep a hem.
- **Rust Knave** — scrap given a spine. Soft and silk catch every barb; metal, earth, and sharp speak its language.

### Chapter 2 — Mire Chapel

The chapel does not want hemp, scrap, or clean silk. Starter Soft / Earth / Metal / Wild / Silk / Pure are **punished**. Favors sit outside the starter set.

| id | Name | Threat tags | Punishes | Favors | Environment |
|---|---|---|---|---|---|
| `boss_mire_bride` | Mire Bride | Occult, Sticky, Lunar | Soft, Pure, Silk | Silent, Occult, Lunar, Sticky | Drowned chapel — aisle under peat, wedding still in session |
| `boss_bog_king` | Bog King | Sticky, Wild, Earth | Soft, Earth, Metal, Wild | Frost, Occult, Storm, Silent | Root throne — peat crown; swallows scrap and stone |
| `boss_pale_choir` | Pale Choir | Lunar, Occult, Storm | Soft, Metal, Silk | Lunar, Occult, Silent, Frost | Bone gallery — stacked ribs, hymn with no language |

- **Mire Bride** — drowned wedding that never ended. Clean cloth and pale silk are offerings; silent / occult / lunar / sticky walk the aisle.
- **Bog King** — root throne that claims grounded work. Soft, earth, metal, and wild become more bog. Frost, occult, storm, silent cut a path.
- **Pale Choir** — bone gallery that sings cloth to rags and finds you by clang. Lunar / occult / silent / frost; not soft, metal, or silk.

### Chapter 3 — Marble Court

Court and parade. Peasant staples (Soft / Earth / Metal / Wild / Silk / Pure) read as contempt. Favors sit outside the starter set.

| id | Name | Threat tags | Punishes | Favors | Environment |
|---|---|---|---|---|---|
| `boss_gilded_warden` | Gilded Warden | Royal, Solar, Sharp | Soft, Earth, Wild, Metal | Royal, Solar, Fire, Sharp | Marble court — gold-leaf plate, no mud on the tiles |
| `boss_ivory_judge` | Ivory Judge | Royal, Lunar, Silent | Soft, Metal, Pure, Silk | Royal, Lunar, Silent, Occult | Hearing hall — ivory gavel; hemp is contempt |
| `boss_sunspear_captain` | Sunspear Captain | Solar, Sharp, Fire | Soft, Silk, Pure, Earth | Solar, Sharp, Fire, Royal | Parade yard — mirrored spears; shade is desertion |

- **Gilded Warden** — marble-court enforcer. Soft, earth, wild, and scrap-metal look like mud on the tiles. Royal, solar, fire, sharp.
- **Ivory Judge** — hearing hall. Soft, metal, pure, and silk are entered as contempt. Royal, lunar, silent, occult keep standing.
- **Sunspear Captain** — parade glare. Soft, silk, pure, and earth wilt. Solar, sharp, fire, royal hold the line.

## Boss-client (shared pool) — Jonathan 2026-10-02

There is a **client responsible for the boss event**. The player crafts **for that client**. The **client fights** the announced boss — the player is the clothier, not the fighter.

**Pool law:** one **shared adventurer / boss-client pool for all bosses and chapters** — **not** a fixed client per boss. Organized by **job title**. Catalog + draw: **[28-boss-client-pool](28-boss-client-pool.md)**.

- At the **boss beat**, draw one adventurer from the shared pool (seeded). Independent of which boss was drawn.
- **M1 draw — LOCKED (Jonathan 2026-10-08):** filter to **4 jobs** — Knight, Mage, Blade Dancer, Lagoon (`28` / `29`). Do **not** draw Wizard / Hexer / Outrider / Oathbound.
- That adventurer’s **order constructions** (`con_*` listed per job in `28`) **+ requirement tags** are what the player crafts for. Constructions come from that order (`27`) — not a picker.
- That adventurer **fights** the announced chapter boss. Sim (`20` `mission_kind=boss`) uses **that client's gear**.
- Example: C1 may draw Ash Drake as boss; C1 (or any chapter) may still draw a knight or a mage — different jobs → different constructions and different requirement tags.
- **Appointments stay appointments.** Scrap Duelist and other mid-chapter named clients are `appt_*`. They are **not** the boss-client. Do not pin Scrap Duelist to reserved rounds or the boss beat.

Portraits / UI widgets = **Later**. Do not invent Godot scenes or art this stamp.

Harness: `chapter_boss_id` + `boss_pool_id` + `boss_client_id` / `boss_job_id` + `order_id` / `construction_ids` from the pool (`20`, `28`).

## Draw + announce

```
function pick_chapter_boss(chapter_index, seed):
  return seeded_choice(BOSS_POOLS[chapter_index], seed)

function pick_boss_client(seed):
  job = seeded_choice(M1_JOB_POOL, seed)
  # M1_JOB_POOL = job_knight, job_mage, job_blade_dancer, job_lagoon
  # LOCKED Jonathan 2026-10-08 — not the 8-job catalog
  # independent of chapter_boss_id / chapter_index
  return seeded_choice(ADVENTURERS_BY_JOB[job], seed)  # named people: 29

# UI: kingdom newspaper front page (26) — boss only, not the client
```

- Announce the **boss** **before** any shop spend that chapter.
- Draw the **boss-client** at the **boss beat** (after reserved rounds / final prep). Independent of the announced boss.
- Same job may recur across chapters (Phase-1). Unique-per-run = Later.
- Telegraph the job before the boss beat = Later.
- Harness: `chapter_boss_id`, `boss_pool_id`, `boss_client_id`, `boss_job_id`.
- Mid missions: schedule appointments / walk-ins (`22`) — not this pool.

## Phase-1 art

Boss portraits Later. Newspaper chrome can share atelier grain when 1C opens. Client / job portraits Later (`28`).

## Pointers

- Shared pool / jobs: [28-boss-client-pool](28-boss-client-pool.md) · M1 named people / 4-job draw: [29-adventurer-catalog](29-adventurer-catalog.md)
- Starter tags: [19-own-basic-starter](19-own-basic-starter.md)
- Schedule / boss beat: [22-chapter-schedule](22-chapter-schedule.md)
- Harness: [20-harness-stamp](20-harness-stamp.md)
- Newspaper: [26-newspaper](26-newspaper.md)
- Craft: [27-craft-mode-stamina](27-craft-mode-stamina.md)
