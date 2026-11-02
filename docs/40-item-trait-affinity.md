# Item trait affinity — scalable production draft

**Status:** Design draft (Jonathan direction, 2026-10-29). This is the proposed production replacement for the fixed-value `own_basic` combat-kit numbers in [39](39-starter-deck.md). The stamped `39` letters remain historical until this draft is tested and re-stamped.

The goals are:

- resolve trait tiers **per crafted item**, never from the combined tag total;
- let tiers unlock mechanics instead of fixed late-game numbers;
- scale magnitude from the stats and tag intensity of the materials that created the item;
- make acquired card copies matter by preventing one material card from being sewn repeatedly in one craft;
- keep `3 / 5 / 8` readable while allowing refined materials to carry more than one tag pip.

---

## 1. Per-item tag pips and tiers

Cards carry `tag_pips`, not only a flat tag list.

```text
tag_pips: { Fire: 1, Silk: 1 }
```

Migration rule: every existing tag in [11](11-materials.md) counts as **1 pip** unless that card receives an explicit override. Missing tags count as 0. Pips are authored data; do not derive them automatically from price or rarity.

`mat_ench_heavy` remains an explicit exception: it doubles that copy's effective tag pips and stat contribution. Both doubled values feed affinity. This is authored enchant behavior, not an inference from effective price.

For item `i` and tag `t`:

```text
I_t(i) = sum(tag_pips[t] from committed materials, construction, and rune on item i)

tier_t(i) =
  0 when I < 3
  1 when I >= 3
  2 when I >= 5
  3 when I >= 8
```

`3 / 5 / 8` are global trait thresholds, not separate numbers tuned for each trait.

- Tier 1 activates the core mechanism.
- Tier 2 improves its trigger, frequency, or conversion.
- Tier 3 adds an apex rule change.
- Pips and contributing stats above 8 continue improving magnitude; there is no Tier 4.

### Multi-item orders

Tier is never created by adding pips from different items.

```text
active_tier(t) = max(tier_t(i) for every item i)
```

Only an item that individually reaches Tier 1 contributes affinity for that trait. Multiple qualifying items support the magnitude, but cannot combine two partial stacks into Tier 2 or Tier 3.

Examples:

- Fire 4 + Fire 4 on two items: active Fire Tier 1, not Fire Tier 3.
- Fire 8 + Fire 0: active Fire Tier 3.
- Fire 8 + Fire 8: active Fire Tier 3 and two Fire-apex items.

---

## 2. Material commitment

One owned material card represents one available material allocation during a craft.

- Playing a **material** into an item moves it to `committed`, not normal discard.
- A committed material cannot be drawn or played again during that craft.
- Playing a **rune** also commits it for that craft.
- Playing a **skill** sends it to discard and it may cycle normally.
- Dig sends unplayed hand cards to discard, then redraws.
- At Finish or abort, committed cards return to `WagonStock` for the next order.
- Duplicate owned cards remain separately playable.

This replaces repeated reshuffling of one material card as the way to manufacture a monostack. Reaching higher tiers comes from owned copies, higher-pip materials, runes, constructions, and card-efficiency tools.

Session piles:

```text
draw + hand + discard + committed = cards available to this craft
```

Only `draw + hand + discard` can cycle during the craft.

---

## 3. Affinity inputs

For each item, keep the stat contribution of every card/layer. A trait reads only positive relevant stats supplied by layers carrying that trait.

```text
HP_t(i)  = sum(max(0, HP contribution)  from layers on item i with tag t)
ATK_t(i) = sum(max(0, ATK contribution) from layers on item i with tag t)
DEF_t(i) = sum(max(0, DEF contribution) from layers on item i with tag t)
RES_t(i) = sum(max(0, RES contribution) from layers on item i with tag t)
MOB_t(i) = sum(max(0, MOB contribution) from layers on item i with tag t)
PRE_t(i) = sum(max(0, PRE contribution) from layers on item i with tag t)
```

A dual-tag material may contribute its stats to both affinities. Its normal negative stats still reduce the finished item's base stats; they do not make trait potency negative.

For combat magnitude, sum the affinity inputs from items that individually reached Tier 1 in that trait:

```text
ATK_t = sum(ATK_t(i) where tier_t(i) >= 1)
I_t   = sum(I_t(i)   where tier_t(i) >= 1)
```

The highest per-item tier determines unlocked behavior. All qualifying items may support magnitude.

### Rounding

All formulas use `round_half_away_from_zero`. A positive result has a minimum of 1 unless the trait explicitly allows 0.

The coefficients below are first-playtest numbers for the current 12-HP demo scale. Keep them in one tuning table rather than hard-coding them inside trait logic.

---

## 4. Fire — Burn

Fire magnitude scales from offensive value created by Fire-bearing layers.

```text
burn_apply = max(1, round(0.25 * ATK_Fire + 0.20 * I_Fire))
```

- **Tier 1 — Kindle:** the first adventurer attack applies `burn_apply` stacks.
- **Tier 2 — Feed:** Burn ticks caused by the adventurer heal it for `floor(tick_damage * 0.50)`.
- **Tier 3 — Ash Crown:** each item whose own Fire intensity is at least 8 grants one Survive charge for that craft.

Burn remains uncapped. At the start of the holder's action, it takes damage equal to current stacks, then stacks decrease by 1. Cross-trait effects may modify application or tick behavior, not replace this formula.

Starter-scale check: three Ember Silk cards contribute Fire intensity 3 and ATK 6, producing `round(1.5 + 0.6) = 2` Burn.

---

## 5. Soft — Mend

Soft magnitude scales from vitality and resistance created by Soft-bearing layers.

```text
mend = max(1, round(0.15 * HP_Soft + 0.30 * RES_Soft + 0.20 * I_Soft))
```

- **Tier 1 — Comfort:** start with Mend reserve equal to `mend`. After the first nonlethal enemy hit, spend the reserve to heal up to that amount.
- **Tier 2 — Nest:** Mend reserve becomes `ceil(mend * 1.5)`. After every nonlethal enemy action that dealt HP damage, spend up to `ceil(mend / 2)` from the reserve.
- **Tier 3 — Cloud Embrace:** Mend reserve becomes `mend * 2`; a trigger may spend up to `mend`. Excess healing becomes Ward, capped at `mend`. The first Mend each fight also cleanses:

```text
cleanse_stacks = max(1, floor(I_Soft / 8))
```

Mend occurs after damage and therefore cannot prevent a lethal hit. A finite reserve prevents Soft from generating unlimited healing in a long encounter. Ward absorbs later damage before HP and expires after the fight.

Starter-scale check: three Grey Wool cards contribute Soft intensity 3, HP 6, and RES 3, producing `round(0.9 + 0.9 + 0.6) = 2` Mend.

---

## 6. Earth — Root

Earth magnitude scales from physical durability created by Earth-bearing layers.

```text
root_guard = max(1, round(0.10 * HP_Earth + 0.25 * DEF_Earth + 0.15 * I_Earth))
```

- **Tier 1 — Rooted:** apply Root Guard to the first incoming hit.
- **Tier 2 — Living Stone:** apply Root Guard to every incoming hit.
- **Tier 3 — Mountain Guest:** Root Guard may reduce at most 75% of a hit instead of 50%. Each Earth-apex item also grants one Root charge that cancels a stagger, displacement, armor break, or equivalent control effect.

For Tier 1 and Tier 2:

```text
damage_reduced = min(root_guard, floor(incoming_damage * 0.50))
```

For Tier 3:

```text
damage_reduced = min(root_guard, floor(incoming_damage * 0.75))
```

Earth is reliable against repeated hits but does not create a separate armor pool.

Starter-scale check: three Grey Wool cards contribute Earth intensity 3, HP 6, and DEF 3, producing `round(0.6 + 0.75 + 0.45) = 2` Root Guard, still limited by the tier's percentage cap.

---

## 7. Metal — Plate and Temper

Metal magnitude scales from armor created by Metal-bearing layers.

```text
initial_plate = max(1, round(0.15 * HP_Metal + 0.40 * DEF_Metal + 0.20 * I_Metal))
```

- **Tier 1 — Plate:** begin the fight with `initial_plate`. Plate absorbs damage before HP and is consumed point for point.
- **Tier 2 — Temper:** Plate lost since the previous adventurer attack becomes bonus damage on that attack:

```text
temper_damage = floor(plate_lost_since_last_attack * 0.50)
```

- **Tier 3 — Bell Titan:** when Plate reaches 0, spend one Reforge charge after the adventurer's next action:

```text
reforged_plate = max(1, ceil(initial_plate / 3))
reforge_charges = number of Metal-apex items
```

Metal is strongest against an early burst. Earth instead reduces every qualifying hit.

Starter-scale check: three Iron Scrap cards contribute Metal intensity 3, HP 3, and DEF 3, producing `round(0.45 + 1.2 + 0.6) = 2` Plate.

---

## 8. Silk — Flow

Silk magnitude scales from mobility and presence created by Silk-bearing layers.

```text
flow = max(1, round(0.30 * MOB_Silk + 0.20 * PRE_Silk + 0.20 * I_Silk))
```

- **Tier 1 — First Thread:** add `flow` to the adventurer's initiative score.
- **Tier 2 — Flow:** when the adventurer acts before the foe, its first attack gains:

```text
flow_damage = max(1, ceil(flow / 2))
```

- **Tier 3 — Loom Sovereign:** after the normal second adventurer action, spend one Flourish charge to deal `flow` damage. Flourish is a damage beat, not another full action, and does not reapply Fire or repeat Temper.

```text
flourish_charges = number of Silk-apex items
```

Initiative becomes an opposed score rather than an unconditional Silk switch:

```text
adventurer_initiative = base_MOB + flow
foe_initiative        = foe MOB / encounter initiative value
```

Ties favor the foe unless an adventurer skill says otherwise.

Starter-scale check: three Ember Silk cards contribute Silk intensity 3 and MOB 3, producing `round(0.9 + 0.6) = 2` Flow.

---

## 9. Starting deck and basic-owner access

`own_basic` may use **Fire, Soft, Earth, Metal, and Silk**. It should not begin with all five active.

Keep the readable starter shape:

```text
3 tagged materials + 4 neutral materials + 3 skills = 10 cards
hand size = 5
```

At run start, choose one **starter bolt**. The bolt determines the three tagged material cards. The four no-tag Hemp printings and three starter skills stay common to every bolt.

First test bolts:

- **Ember:** `mat_ember_silk` ×3 starter printings — Fire only; Silk is withheld on these three copies so the bolt opens one trait. Normal market Ember Silk keeps Fire and Silk.
- **Hearth:** tagged `mat_hemp_plain` ×3 — Soft.
- **Cairn:** `mat_clayweave` ×3 — Earth.
- **Forge:** `mat_iron_scrap` ×3 — Metal.
- **Fineweave:** `mat_silk_pale` ×3 — Silk.

The selected bolt guarantees at least one Tier-1 direction without cycling a single material. Market stock may contain all five basic-owner traits, with a moderate weight toward the selected bolt. The choice is a starting direction, not a permanent class lock.

The three starter skills remain:

- `sk_ease_draw`
- `sk_scrap_breath`
- `sk_heavy_draw`

`sk_heavy_draw` multiplies the next material's **stats**, not its tag pips. A separate future effect may amplify tag pips.

---

## 10. Stamina draft

Set stamina from desired decisions per item, not directly from synergy thresholds.

First production test:

```text
stamina_start = 8 * item_count + 2
dig_cost = 2 session-wide
```

Results:

- 1 item: 10 stamina
- 2 items: 18 stamina
- 3 items: 26 stamina
- 4 items: 34 stamina

Target:

- early item: approximately 4–5 meaningful plays including skills and dig;
- developed item: approximately 6–8 plays through efficient cards and tools;
- apex: reached through owned copies, explicit tag pips, runes, and deck development—not by repeatedly cycling one material.

Late-game progression should grant bounded advantages such as stamina, draw, discounts, pip amplification, or better affinity conversion. Avoid automatic chapter scaling that makes every late craft play the whole deck.

For the first test, stamina and committed copies replace a hard material-slot cap. Existing `staff_*` entries that only raise `max_materials` should be re-authored later as stamina, draw, discount, or affinity tools rather than reviving slot-fill UI.

---

## 11. Required test telemetry

Record per item:

- committed card ids;
- intensity and tier for each trait;
- affinity inputs and final formula result;
- stamina spent by card type;
- digs;
- active tier per combined fight;
- apex charge creation and spending;
- damage, healing, mitigation, Plate, Flow, and Ward contributed by each trait.

Initial balance targets:

- Tier 1 is reliably reachable from the selected starter bolt.
- Tier 2 requires acquisition or a deliberate rune/construction line.
- Tier 3 is unusual in Chapter 1 and becomes a planned late-run result.
- No trait formula contributes more than roughly half of a successful build's total value without substantial specialization.

The formula coefficients and stamina values are Test knobs. The per-item tier rule, commitment model, and tier-as-mechanism structure are the proposed production spine.
