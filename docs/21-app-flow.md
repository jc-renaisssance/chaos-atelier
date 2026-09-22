# Application flow (pseudocode) — Phase-1 `own_basic`

**Status:** docs-only review draft (Jonathan 2026-09-22). **No Client src until monthly Cursor reset.**

Readable spine for Design / Test / PM review. Contract sources: `01`, `10`–`20`. Phase-1 player = clothier `own_basic` only.

```
CHAPTER LOOP (×3 in Phase-1 vertical slice)
│
├─ CHAPTER_START  → announce boss
├─ ATELIER_SHOP   → reshape material deck
├─ CRAFT_OR_TASK  → build garment(s) toward boss / side client
├─ ATELIER_SHOP   → (repeat shop ↔ craft until chapter nodes done)
└─ BOSS           → sim vs announced boss → chapter result
```

---

## 0. Run bootstrap

```
function start_run(seed):
  player.owner_id   = "own_basic"          # 16, 19 — only Phase-1 owner
  player.skills     = []                   # none on own_basic
  player.gold       = 12                   # 19
  player.deck       = starter_deck_own_basic()  # 8 mats from 19
  player.constructions_unlocked =
      [tunic, cloak, armor, robe, coat]    # Phase-1 outlook batch
  player.enchantments_unlocked = []        # shop may offer $2 runes
  chapter_index = 1
  stamp_run_start(player, seed)            # 20: owner, starter mats
```

---

## 1. Chapter start — boss announced

```
function chapter_start(chapter_index):
  boss = BOSSES[chapter_index]             # 17: Ash Drake / Mire Bride / Gilded Warden
  ui.show_boss_announce(
    name        = boss.name,
    threat_tags = boss.threat_tags,
    favors      = boss.favors,
    punishes    = boss.punishes,
    environment = boss.environment
  )
  state.chapter_boss_id = boss.id
  state.nodes_remaining = CHAPTER_NODE_BUDGET   # TBD Design number; shop↔craft cycles
  return boss
```

Player **sees the boss before spending** (StS-style). Deck shaping happens after this screen.

---

## 2. Atelier shop (your stock — not an NPC vendor)

```
function atelier_shop(player, boss_context):
  # Offers gated by owner pool + weights (19). Skills Later (reroll / income / storage).
  offers = roll_shop_offers(
    pool     = owner_material_pool("own_basic"),
    weights  = OWN_BASIC_SHOP_WEIGHTS,     # 19
    count    = 5,
    seed     = shop_seed
  )
  maybe_add_enchantment_offer(offers, p=0.40, enc_table=OWN_BASIC_ENC)  # 19

  loop until player.leaves_shop:
    action = ui.shop_action()              # buy | sell | leave
    match action:
      buy(card):
        assert card in offers and player.gold >= card.price
        player.gold -= card.price
        player.deck.add(card)
        offers.remove(card)
      sell(card):
        assert card in player.deck
        player.gold += sellback(card)      # ⌊$/2⌋ rules in 19
        player.deck.remove(card)
      leave:
        break

  stamp_phase("shop", player)              # 20 optional mid-chapter stamps
```

---

## 3. Craft (multi-stack) → resolve → adventure report

### 3a. Build garment

```
function craft_garment(player):
  construction = ui.pick_construction(player.constructions_unlocked)  # 12
  slots_n      = construction.material_slots   # e.g. Armor = 3

  materials = []
  loop until len(materials) in 1..slots_n and ui.confirm:
    mat = ui.pick_from_deck(player.deck)   # same mat id may repeat (stacks)
    materials.append(mat)

  enchantment = ui.pick_enchantment_or_none(player)  # 0..1; 13

  return Craft(
    construction = construction,
    materials    = materials,              # order = slot order
    enchantment  = enchantment
  )
```

### 3b. One resolver (data tables only)

```
function resolve_craft(craft) -> ResolvedGear:     # 10, 14, 18
  # Stats
  stats = sum(m.stats for m in craft.materials)
        + craft.construction.stat_mods
        + (craft.enchantment.stats if craft.enchantment else 0)

  # Tag bag (counts)
  tags = bag_count(
    all material tags
    ∪ construction.tags          # once, still stacks counts
    ∪ enchantment.tags
  )

  # Rarity (18)
  rarity = compute_rarity(
    max_mat_cost = max(m.cost for m in craft.materials),
    enc_cost     = craft.enchantment.cost or 0,
    stack_n      = len(craft.materials),
    unique_match = match_unique_recipe(craft)   # 14 uniq_* → legendary
  )

  # Positives always
  powers_pos = match_positive_synergies(tags, craft.construction.id)  # 14

  # Negatives gated by rarity
  powers_neg = []
  if rarity not in {rare, legendary}:
    powers_neg = match_negative_synergies(tags, craft.construction.id)  # 14
  # else: skip all syn_neg_*

  if unique_match:
    powers_pos += unique_bonus(unique_match)

  # Outlook = highest outlook_order among fired outlook-bearing rows (incl. neg)
  outlook_rows = outlook_bearing(powers_pos + powers_neg)
  if outlook_rows empty:
    outlook_id, outlook_order = "plain", 0
  else:
    winner = argmax(outlook_rows by outlook_order)
    outlook_id, outlook_order = winner.look_id, winner.outlook_order

  return ResolvedGear(stats, tags, rarity, powers_pos, powers_neg,
                      outlook_id, outlook_order, report_hints)
```

### 3c. Adventure / task sim + report

```
function run_adventure(gear, threat) -> AdventureResult:   # 01, 03, 17
  # Deterministic short sim — stamp which tags/stats/powers mattered.
  favor_hits  = gear.tags ∩ threat.favors
  punish_hits = gear.tags ∩ threat.punishes

  outcome = score_checks(gear.stats, gear.powers_pos, gear.powers_neg,
                         favor_hits, punish_hits, threat)
  # outcome ∈ {win, lose, mixed} — pass look = overall trend (20), not every cell

  report = build_report_lines(gear.report_hints, favor_hits, punish_hits, outcome)
  rewards = payout(outcome)                # gold / mats / rep; scars Later

  apply_rewards(player, rewards)
  return AdventureResult(outcome, report, favor_hits, punish_hits, rewards)
```

### 3d. Harness stamp (every craft→sim)

```
function stamp_craft_run(run_id, player, craft, gear, threat, result, phase):
  emit({                                    # 20 — required fields
    run_id, player_owner_id: player.owner_id,
    player_skills: player.skills,
    chapter_id, chapter_boss_id: state.chapter_boss_id,
    phase,                                  # shop | craft_task | boss
    construction: craft.construction.id,
    material_ids: [m.id for m in craft.materials],
    stack_counts: counts(craft.materials),
    enchantment_id: craft.enchantment?.id,
    tag_counts: gear.tags,
    craft_rarity: gear.rarity,
    powers_positive: ids(gear.powers_pos),
    powers_negative: ids(gear.powers_neg),  # MUST be [] if rare/legendary
    outlook_id: gear.outlook_id,
    outlook_order: gear.outlook_order,
    stats: gear.stats,
    threat_id: threat.id,
    outcome: result.outcome,
    report_lines: result.report,
    favor_tags_hit: result.favor_hits,
    punish_tags_hit: result.punish_hits
  })
```

---

## 4. Shop ↔ craft cycle

```
function chapter_body(player, boss):
  while state.nodes_remaining > 0:
    atelier_shop(player, boss)
    threat = pick_side_client_or_task()    # optional mid-chapter clients
    craft  = craft_garment(player)
    gear   = resolve_craft(craft)
    result = run_adventure(gear, threat)
    stamp_craft_run(..., phase="craft_task")
    ui.show_report(result)
    state.nodes_remaining -= 1
    # Design may force a final shop before boss — same atelier_shop()
```

---

## 5. Boss node

```
function chapter_boss(player, boss):
  # May allow one last shop before fight (01 spine: shop → … → boss).
  atelier_shop(player, boss)               # if Design stamps "last shop"

  craft  = craft_garment(player)           # or pick from prepared loadout
  gear   = resolve_craft(craft)
  result = run_adventure(gear, threat=boss)
  stamp_craft_run(..., phase="boss")
  ui.show_boss_result(result)

  if result.outcome == lose and HARDCORE:  # Phase-1 draft: soft continue OK
    end_run()
  else:
    chapter_index += 1
    if chapter_index > 3: win_run()
    else: chapter_start(chapter_index)
```

---

## 6. Top-level main

```
function main():
  start_run(seed)
  while chapter_index <= 3:
    boss = chapter_start(chapter_index)
    chapter_body(player, boss)
    chapter_boss(player, boss)
  show_run_summary()
```

---

## Phase-1 UI screens (placeholders OK)

| Screen | Shows |
|---|---|
| Chapter announce | Boss name, threat / favor / punish tags, environment |
| Atelier shop | Gold, deck, 5 weighted offers, buy/sell/leave |
| Craft | Construction picker, material slot fills (repeats OK), optional enc |
| Report | Outcome, which powers/tags fired, favor/punish hits, outlook id (text) |
| Boss result | Same stamp + chapter advance |

Art: placeholders until **1C** (≤50 outlook gens when Jonathan stamps). Outlook id still computed so harness / report can name `plain` vs syn look.

---

## Explicit non-goals until reset / Later

- Godot `src/` / Cloud Agent (paused until monthly Cursor reset)
- Multi-owner select (`own_forge` / voodoo / tech / skill owners)
- Encyclopedia, scars, full 312/408 outlook matrix art
- Inventing synergy keys not in `14`

---

## Review checklist

| Role | Check |
|---|---|
| **Design** | Boss announce before spend; stacks; rarity→neg skip; neg outlook can win; `own_basic` pool |
| **Test** | Stamp fields match `20`; asserts 1–5 hold in this flow |
| **PM** | One loop only; shop = player atelier not NPC |
| **Client (post-reset)** | Implement this file as the vertical slice + headless harness |
