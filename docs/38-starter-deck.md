# Starter deck — basic owner combat (Soft Design)

**Doc id: `38`.** **Status: Soft Design, stamp open.** Written off tip **`d51d47e`** (Soft chrome #91). Docs only. No `src/`. No assets. No PixelLab. No gens. Doc id `38` was free on that tip.

This file is the starter **deck** and the basic-owner combat kits. The hand is a draw from that deck. Jonathan (2026-10-27): the **3 / 4 / 3** is the starter deck composition.

Separate from Soft chrome [37](37-player-facing-chrome.md) (#91), craft hand [36](36-craft-hand-cards.md) (A′AAAA), tag chrome **A**, and Drop A. Those stay closed. The Solenne height note is a different file. This file does not edit posture art, PR #71, or a height doc.

Ulquiorra and Szayelaporro **hold** the Client until Soft PASS, Jonathan stamps, and Aizen merges. Nnoitra has no seat.

---

## Locks this file does not reopen

| Lock | Where |
|---|---|
| Hand size **5** (`max_hand`) | [27](27-craft-mode-stamina.md), [36](36-craft-hand-cards.md). Fan step stays `32 / (max_hand - 1)` |
| Dig cost **2**, session stamina **`12 * N`**, Finish-only, StS cycle | [27](27-craft-mode-stamina.md). Letter G below recommends keeping dig at 2 |
| Soft A′AAAA, tag chrome **A**, Drop A, cost caption, N=2 one fight | [36](36-craft-hand-cards.md) #83–#89. Client #88 (`e9f503f`) |
| Player-facing chrome **Node A′ · Brief A · Event A** | [37](37-player-facing-chrome.md) #91 |
| Gate **A** / Surface **A** / Socket **A**, vignettes **A**, one fight | [30](30-interactive-order.md), [35](35-steam-demo-cut.md). The PASS bar below is the fight. It does not reopen those letters |
| Shop weights, market shell, the six sold `sk_*` | [19](19-own-basic-starter.md) weights, [32](32-shop-and-events.md). This file does not retune gold ints |
| Solar / Lunar / Occult on other owners | They stay in [14](14-synergies.md) as history. They do not enter this starter deck |

---

## Jonathan locks (2026-10-27)

Written as locks. Letters A–G under them are the open lines. Silence is not a letter.

### 1. Hand 5. Starter deck is 3 / 4 / 3

`max_hand` stays **5**. The open hand is five cards drawn from the starter deck.

The starter deck composition is **tagged mats / no-tag mats / skills ≈ 3 / 4 / 3**. That composition is the whole starting deck. [19](19-own-basic-starter.md) calls its eight mats a fixed hand. This lock replaces that list with the starter deck in letter B. Bought and found cards join **that same deck**.

Each run shuffles that deck and draws **5**. Inside the run, dig, discard, and reshuffle stay [27](27-craft-mode-stamina.md).

### 2. The composition is fixed. The draw is random

Every run starts with the same cards. The draw order changes. The composition does not re-roll.

### 3. AP and stamina are one meter

Skills spend stamina. Dig spends stamina. Material plays spend stamina. Session start stays **`12 * N`**. There is no second action meter. Dig stays **2** unless letter G is rewritten.

### 4. “Next card” is a craft play

“Next card” means the next hand card **played into a zone** after the skill resolves. It is a craft play. It is not a fight beat, not Dig, and not the skill that just resolved. If Finish happens first, the modifier ends with the session. It does not carry into the next session.

### 5. Replace [14](14-synergies.md)

For `own_basic`, the combat kits in this file **replace** the live monostack ladders, the report-hint quotes, and the passive effect cells. They are the same rows, rewritten. A report-hint string beside a kit is not a second layer. History stays printed in `14` until this card is stamped. After the stamp, `own_basic` reads the kits here. Tags with no kit in this file do not keep the old passive.

### 6. Playback Soft PASS bar

On the **one fight** ([35](35-steam-demo-cut.md) lock 5: combined gear, after the vignettes), these have to be **seen**:

| Jonathan’s word | Seen means |
|---|---|
| Burn chip | A damage number leaves the unit that is burning, on the tick beat |
| HP tick | That unit’s HP integer changes on the same beat, by the kit’s amount |
| Sun counter | A stack integer on the unit, changing when stacks are applied or spent. In these kits the integer is **burn stacks** |
| Ascend | Its own beat when a ladder’s highest met tier is 3, 5, or 8 |
| Heal pop | A number rising off the healed unit, equal to the HP gained, on the heal beat |

A report-hint sentence fails this bar. Gate A vignettes stay the shipped beat list. They are not this fight. The resolver’s `hp_remaining` float stays the report field until a Client stamp adds these beats into it. Soft PASS watches the fight integers below.

### 7. Basic owner first

M2 writes **`own_basic`** first. Occult, Solar, and Lunar stay out of this owner’s syns and out of the cards that may enter the deck. So do tags the basic shop and events will not carry.

Pipeline, in order:

1. Select the syns that belong to `own_basic`.
2. Add the cross-tag syns and the neg syns for that set.
3. Build the mats and skills that enter the deck and feed those syns.

Solar’s combat example stays out. Fire stays in when the tagged mats include Fire.

---

## Starter skills (Soft draft)

Costs are the lock (1 / 0 / 1). Ids are Soft’s draft. Same `sk_*` cards as [27](27-craft-mode-stamina.md): they enter the starter deck, shuffle, play into a zone, then discard. Letter F recommends that cycle. They are not on `market_skill_bank_c1`. The six sold skills stay the buy list.

A play still has to name a zone ([27](27-craft-mode-stamina.md)). The “next card” modifier is for the next zone play in the session, whichever zone that play uses.

| id | Cost | Effect |
|---|---:|---|
| `sk_ease_draw` | **1** | The next card played into a zone costs **1** less stamina, floor **0**. Then draw **1** |
| `sk_scrap_breath` | **0** | Discard **1** other card from hand. If that discard happens, stamina **+1** |
| `sk_heavy_draw` | **1** | The next card played into a zone contributes **×1.5** stats, each stat rounded half away from zero. Tags stay as printed. Then draw **1** |

Draw **1** uses the draw pile. A short pile shuffles discard into draw, then continues. An empty deck after that shuffle draws **0**.

`sk_scrap_breath` leaves the hand before its discard. The discarded card is a different card. An empty remaining hand discards nothing and does not gain stamina. This is the one cost-**0** card in the draft. The Later line in `27` (no 0-cost catalog) stays for every other card.

`sk_heavy_draw` examples: hemp HP **1** → **2**, DEF **1** → **2**. Ember ATK **2** → **3**, RES **−1** → **−2**. Wool MOB **−1** → **−2**. Heavy (`mat_ench_heavy`) still doubles tags. This skill does not.

`sk_ease_draw` on a card that already costs **0** stays **0**. Dig is not a card, so the modifier does not change dig.

---

## Letters (open — Soft recommends)

Jonathan writes each line. The recommend is filled so the stamp can copy it.

### A. What “tagged” means

**Recommend A.** A mat is **tagged** when its tag list contains any of the **16** monostack tags in [14](14-synergies.md). A mat is **no-tag** when that list is empty.

**B** (only Soft / Earth / Metal / Wild / Silk / Pure count as tagged) would put a Fire-only mat in the no-tag seats. Fire is the combat example that belongs in the tagged seats. **A** counts Fire.

[11](11-materials.md) has no empty Tags cell. The four no-tag cards are a **starter printing** of `mat_hemp_plain`: same stats, same `$`, **tags withheld** on those four copies. A shop copy of `mat_hemp_plain` keeps **Soft**. Harness: those four rows carry `starter_role: no_tag` and `tags: []`. The face stays `assets/mat/mat_hemp_plain.png`. No new id. No gen.

### B. How big the starter deck is

**Recommend: 10 cards. The whole starter deck.** 3 tagged + 4 no-tag + 3 skills. It **replaces** the 8-mat list in [19](19-own-basic-starter.md) for run start. It is not an 11-card deck of those 8 mats plus 3 skills (that mix is not 3 / 4 / 3). Shop weights stay the offer table. A buy appends a card to this deck.

| # | id | `starter_role` | Tags on this copy | Feeds |
|---:|---|---|---|---|
| 1 | `mat_ember_silk` | tagged | Fire, Silk | Fire kit. Silk comes with this mat, so Silk is in the set |
| 2 | `mat_wool_grey` | tagged | Soft, Earth | Soft, Earth |
| 3 | `mat_iron_scrap` | tagged | Metal | Metal |
| 4–7 | `mat_hemp_plain` ×4 | no-tag | *(withheld)* | Stats only. HP 1, DEF 1, play cost 1 |
| 8 | `sk_ease_draw` | skill | — | Next-card −1, draw 1 |
| 9 | `sk_scrap_breath` | skill | — | Discard 1, +1 stamina |
| 10 | `sk_heavy_draw` | skill | — | Next-card ×1.5 stats, draw 1 |

One copy of a tagged mat reaches a **≥ 3** ladder by cycling discard → reshuffle inside the session ([27](27-craft-mode-stamina.md)), and by later buys of the same id. The starter deck does not re-roll to print three Embers.

Starting gold **12** and the unlocked constructions (`con_tunic`, `con_cloak`, `con_armor`, `con_robe`, `con_coat`) stay.

### C. Burn

**Recommend these numbers.** Soft QC can count them on the fight.

The unit that **holds** the stacks is the one that ticks. At the **start** of each of that unit’s actions, while stacks **> 0**:

1. Deal **1 HP × stacks**.
2. Then stacks **− 1**.

**Cap 5.** An apply that would pass 5 sets the counter to 5. Extra stacks are lost.

**Lifesteal.** When the stacks were applied by the adventurer’s Fire kit and the tick hits the foe: heal the adventurer for **floor(tick damage / 2)**. A heal of **0** does not pop. A heal **≥ 1** pops.

**Cleanse.** On a Soft heal pop, the healed unit (the adventurer) loses **1** burn stack after the pop. A muted heal does not cleanse. Full cleanse of every stack is a Pure effect. Pure is outside this deck’s buy list, so this pass cleanses **1** stack per pop.

Worked tick: **2** stacks → **2** damage, counter **2 → 1**, lifesteal **1**, heal pop **1**.

### D. Survive once

**Recommend: once per fight**, and only on `syn_soft_8`.

When a hit would move the adventurer from **≥ 1** HP to **≤ 0**, HP becomes **1** and the charge is spent. The beat shows HP **1** and an ascend beat `survive`. A later lethal in that same fight goes to **0**. The next fight has the charge again. Piece vignettes are not fights, so they do not spend it.

Order on an incoming hit: Earth reduces the number, then this check, then the HP integer changes.

### E. First combat kits

**Recommend: Fire, Soft, Earth, Metal, and Silk.**

The three tagged cards feed those five tags. Fire is the combat example. Silk is on `mat_ember_silk`, so a Silk ladder with no kit would leave that tag on the old passive row. **Wild** and **Pure** stay on the historical weight table and off the buy list for this pass, so their old rows do not fire and this pass does not draft their kits. **Solar, Lunar, Occult** stay out.

Highest met tier is the one that applies. Tiers do not stack their numbers. The apex **adds** its rider (survive, the extra burn stack, the full block) on top of the mid number.

Construction tags still enter the bag ([12](12-constructions.md)). The one fight reads the **combined** bag ([35](35-steam-demo-cut.md)): tag counts sum across pieces. A pair neg sees both tags when the two mats were played on different pieces.

### F. Where skills are drawn

**Recommend: the same draw, hand, and discard as [27](27-craft-mode-stamina.md).** The three skills are cards in the starter deck. Dig dumps the hand, including skills, then draws up to 5. Soft’s pick is that shared cycle.

### G. Dig cost

**Recommend: keep 2.** No alternate number. Session-wide, not × N.

---

## Cards that may enter the deck

After the syn set in letter E, `own_basic` may add a mat or a rune whose tags are a subset of **{Fire, Soft, Earth, Metal, Silk}**, or a no-tag printing. A card with any other tag stays off this owner’s buy list. The weight rows stay printed in [19](19-own-basic-starter.md) as history. An event that already grants a held-out mat still grants it; those tags do not fire a kit. Stats on that copy still apply.

**May enter**

| id | Tags |
|---|---|
| `mat_hemp_plain` | Soft (shop copy) |
| `mat_wool_grey` | Soft, Earth |
| `mat_iron_scrap`, `mat_bronze_scale`, `mat_wirecloth`, `mat_steel_plate` | Metal |
| `mat_clayweave` | Earth |
| `mat_stone_shard`, `mat_stonefiber` | Earth, Metal |
| `mat_silk_pale` | Silk |
| `mat_ember_silk` | Fire, Silk |
| `enc_rune_ember` | Fire |
| `enc_rune_stone` | Earth |
| `enc_rune_iron` | Metal |

**Stay off the buy list** (weights remain in `19` until a later stamp writes their kits): `mat_cotton_spring`, `mat_leather_tan`, `mat_leather_dusk`, `mat_linen_storm`, `mat_velvet_court`, `mat_milkfleece`, `mat_tar_thread`, `mat_frostwool`, `mat_ivy_cord`, `mat_whisper_gauze`, and every Occult / Solar / Lunar id. Runes and sigils that carry Frost, Storm, Lunar, Solar, Silent, Sticky, Sharp, Pure, Wild, Royal, or Occult stay off the list. `enc_rune_moon`, `enc_rune_sun`, and `enc_rune_hex` are in that group.

The six market skills (`sk_next_mat_free`, `sk_touch_up`, `sk_steady_hand`, `sk_metal_str_double`, `sk_wild_to_earth`, `sk_deep_dig`) stay buyable. They are the existing craft cards. They are not a second skill system. `sk_wild_to_earth` can put an Earth mat in hand; it does not put Wild, Solar, Lunar, or Occult into the deck.

C2 / C3 still de-favor Soft, Earth, Metal, Wild, Silk, and Pure on the boss rows ([17](17-chapter-bosses.md), [19](19-own-basic-starter.md)). That sentence stays. Wild and Pure are named there and are not in this buy list.

---

## Fight playback (when any kit below is live)

Both units show an HP integer, starting at **12**. Other screens do not grow an HP bar. No RNG. Four actions:

| Silk on the combined bag | Order |
|---|---|
| Silk **< 3** | `foe_1`, `adv_1`, `foe_2`, `adv_2` |
| Silk **≥ 3** | `adv_1`, `foe_1`, `adv_2`, `foe_2` |

Beat order:

1. **Ascend**, one per ladder that meets **≥ 3**, in order Fire, Soft, Earth, Metal, Silk. The beat shows the highest met tier.
2. **Open.** Neg chips and the self-burn stack.
3. **Soft heal**, if Soft **≥ 3**. Pop, then cleanse 1 stack on the adventurer if any remain.
4. Each action. **Tick first** if that unit’s stacks are **> 0**, then the action body.
5. `adv_1` body: Fire **applies** stacks to the foe (counter changes; apply is not HP). Metal’s bonus is HP damage on this same action. Silk’s bonus damage is on the adventurer’s **first** attack, which is `adv_1` when Silk **≥ 3** and `adv_1` still when Silk **< 3** (the first adventurer action either way).
6. Each foe action body: one incoming hit of **3** HP, then Earth, then survive, then the HP integer.

`adv_2` has no second Fire apply and no second Metal bonus. It still ticks if the adventurer is burning.

---

## Kits (replace the [14](14-synergies.md) rows for these ids)

Outlook art does not move. No gen. A new cross id has no png; the look falls through to the ladder row when that row fires, because these `outlook_order` values sit under the low tier. Existing neg orders stay, so a live neg still beats the low and mid looks it already beats.

### Fire — `syn_fire_3` / `syn_fire_5` / `syn_fire_8`

| When | Apply on `adv_1` | Rider |
|---|---:|---|
| Fire **≥ 3** | **2** stacks | — |
| Fire **≥ 5** | **3** | — |
| Fire **≥ 8** | **4** | — |

Then the burn rules. The old lines (“Cloth drank the heat.”, “Seams smoking.”, “They wore a kiln.”) do not satisfy the PASS bar.

### Soft — `syn_soft_3` / `syn_soft_5` / `syn_soft_8`

| When | Heal pop, once, on the heal beat | Rider |
|---|---:|---|
| Soft **≥ 3** | **2** | Cleanse **1** self stack |
| Soft **≥ 5** | **3** | Cleanse **1** |
| Soft **≥ 8** | **3** | Cleanse **1**, and **survive once per fight** (letter D) |

### Earth — `syn_earth_3` / `syn_earth_5` / `syn_earth_8`

The first incoming hit is reduced. A reduction to **0** still shows a **0** chip so the mitigation is visible. HP does not change on a 0.

| When | First hit (base 3) | Rider |
|---|---|---|
| Earth **≥ 3** | **−2** (min 0) → **1** | — |
| Earth **≥ 5** | **−4** → **0** | — |
| Earth **≥ 8** | **−4** → **0** | The first hit that would remain **≥ 1** after reduction becomes **0** once. At **≥ 5** the base reduction already hits 0, so this rider shows when a cross or a later number would have left a remainder |

### Metal — `syn_metal_3` / `syn_metal_5` / `syn_metal_8`

| When | Damage on `adv_1` | Rider |
|---|---:|---|
| Metal **≥ 3** | **2** | — |
| Metal **≥ 5** | **4** | — |
| Metal **≥ 8** | **4** | Also **+1** burn stack on that apply (cap 5 after) |

### Silk — `syn_silk_3` / `syn_silk_5` / `syn_silk_8`

| When | Seen |
|---|---|
| Silk **≥ 3** | Adventurer acts first (the order table) |
| Silk **≥ 5** | That first attack also deals **+1** |
| Silk **≥ 8** | That first attack deals **+2** (replaces the +1) |

### Cross-tag (one power each, no 3 / 5 / 8)

| id | When | Effect | `outlook_order` |
|---|---|---|---:|
| `syn_fire_metal` | Fire **≥ 1** ∧ Metal **≥ 1** | Fire apply **+1** stack, then cap 5 | 89 |
| `syn_fire_earth` | Fire **≥ 1** ∧ Earth **≥ 1** | The first burn tick this fight deals **+1** HP | 88 |
| `syn_soft_metal` | Soft **≥ 1** ∧ Metal **≥ 1** | Metal’s `adv_1` damage **+1** | 9 |
| `syn_soft_silk` | Soft **≥ 1** ∧ Silk **≥ 1** | Silk’s first-attack bonus **+1** | 8 |
| `syn_earth_metal` | Earth **≥ 1** ∧ Metal **≥ 1** | Earth reduction **+1** | 19 |
| `syn_earth_silk` | Earth **≥ 1** ∧ Silk **≥ 1** | Earth reduction **+1** | 18 |

Two reduction crosses stack. `syn_earth_metal` and `syn_earth_silk` together are **−2** on top of the Earth tier.

**No separate cross** for Fire ∧ Silk. `mat_ember_silk` would turn that cross on every time the Fire mat is in the bag. Silk count still feeds the Silk ladder. **No separate cross** for Soft ∧ Earth. `mat_wool_grey` is both tags; the ladders already read them.

### Neg syns (same ids, new effects)

Rare and legendary still skip `syn_neg_*` ([18](18-rarity.md)).

| id | When | Effect, seen on the fight |
|---|---|---|
| `syn_neg_fire_soft` | Fire **≥ 1** ∧ Soft **≥ 1** | Open: adventurer gains **1** burn stack. The Soft heal amount is **halved**, round down (2 → 1, 3 → 1). The pop shows the halved number, then cleanse **1**. A halved heal of **0** does not pop and does not cleanse |
| `syn_neg_metal_silk` | Metal **≥ 3** ∧ Silk **≥ 3** | Silk’s first-strike reorder does not happen. Open: adventurer takes **1** HP (chip and tick) |
| `syn_neg_cloak_metal` | Any piece is `con_cloak`, and combined Metal **≥ 1** | Metal’s `adv_1` damage does not apply. Open: **1** HP chip on the adventurer |

Other `14` negs name a tag outside this set (`Silent`, `Sharp`, `Royal`, `Sticky`, `Occult`, `Pure`) or a hood. They do not fire for `own_basic` on this pass. `con_hood` is not a starting construction. Their rows stay in `14` as history.

`syn_fire_frost_clash`, `syn_wild_earth`, `syn_sticky_sharp`, `syn_royal_silent`, `syn_solar_pure`, and `syn_lunar_occult` name a tag outside the set. They do not fire for `own_basic` on this pass.

---

## One fight Soft can count

Combined bag **Fire ≥ 3**, **Soft ≥ 3**, Earth and Metal and Silk under 3. `syn_neg_fire_soft` is live. Silk **< 3**, so the foe acts first. Playback HP starts at 12.

| Beat | What is on screen |
|---|---|
| Ascend | Fire **3**, then Soft **3** |
| Open | Adventurer burn counter **1** |
| Heal | Pop **1** (2 halved). Counter **1 → 0** |
| `foe_1` | Incoming **3**. Adventurer HP **12 → 9**. No tick (counter is 0) |
| `adv_1` | Apply **2** on the foe. Counter **2**. No Metal damage |
| `foe_2` | Tick **2** first. Foe HP **12 → 10**. Counter **2 → 1**. Heal pop **1** on the adventurer (floor(2 / 2)). Then incoming **3**. Adventurer HP **10 → 7** |
| `adv_2` | No tick. No second apply |

A report line that only says the cloth drank the heat fails this count.

---

## Harness (later Client, not this PR)

No new Required key in [20](20-harness-stamp.md). When a Client follows the stamp, the run-start dump lists the ten cards with `starter_role`. The four hemp rows have empty tags. Shop hemp does not.

---

## Holds

Ulquiorra holds the Client. Szayelaporro holds smoke. Both wait for Soft PASS, Jonathan’s stamp, and Aizen’s merge. Nnoitra has no seat. No gens. #71 Solenne ×4 stays **HOLD** until **2026-11-02**. Halden + Vex **KEEP**. Shop **ACCEPT**. Posture art stays **Nov 2**.
