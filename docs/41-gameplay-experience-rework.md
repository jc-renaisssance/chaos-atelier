# Gameplay experience rework — practical recommendations

**Status:** Recommendation draft, 2026-11-02. **Not stamped. Not Client-landed.** This document reviews the current Wombaste flow and proposes practical enhancements or replacements. Existing stamped documents remain implementation law until individual recommendations here are accepted and moved into their owning docs.

Primary references:

- chapter and route: [01](01-core-loop.md), [22](22-chapter-schedule.md);
- order, estimate, playback: [30](30-interactive-order.md);
- craft: [27](27-craft-mode-stamina.md), [40](40-item-trait-affinity.md);
- market and events: [32](32-shop-and-events.md);
- rewards and run pressure: [23](23-mission-report.md), [24](24-win-conditions.md), [25](25-reps-meter.md);
- boss announcement: [26](26-newspaper.md).

This review keeps Wombaste's identity. It does **not** propose turning the game into a broad shop simulator.

---

## 1. North-star experience

The player should feel:

> An adventurer trusts me with a dangerous problem. I accept a promise, choose scarce materials, make a garment with a visible identity, and then witness exactly how my choices save—or fail—them.

Every major screen should support that sentence.

The five player-facing pillars are:

1. **A memorable person** asks for help.
2. **A voluntary promise** makes the order risky.
3. **Material commitment** makes crafting tactile and irreversible for this session.
4. **Readable playback** proves what the garment did.
5. **Persistent consequences** make the item and adventurer matter after the report.

---

## 2. Executive decision list

### `[KEEP]`

- Magical clothier fantasy: the player equips adventurers rather than fighting directly.
- Announced chapter boss and authored route map.
- One shared run deck / `WagonStock`.
- Dedicated multi-item stamina craft.
- Per-item `3 / 5 / 8` tiers and scalable affinity draft in [40](40-item-trait-affinity.md).
- Market as route nodes rather than an automatic shop before every order.
- One combined fight after per-item garment reveals.
- Named adventurers, bosses, Dex, and returning profile knowledge.

### `[ENHANCE]`

- Adventurer arrival becomes a short counter scene rather than an information panel only.
- Orders gain optional contract promises.
- Route nodes preview stakes, not merely kind.
- Market stock becomes deliberately useful for the selected starter bolt and announced boss.
- Craft receives a committed-material rail, promise tracking, and a stronger Finish moment.
- Playback attributes each effect to the garment that caused it.
- Reports produce concise causal explanations and persistent world changes.

### `[REVAMP]`

- Replace the manual click-to-tier planner in [30](30-interactive-order.md) with an automatic live build forecast plus contract goals.
- Replace the pre-craft S–F estimate with causal advantages, dangers, and uncertainty.
- Remove player-editable future route drafts; show previews, but commit only at the current fork.
- Replace the hard reps-gate run failure with a low-standing boss disadvantage.
- Replace the fully random boss-adventurer reveal at the boss beat with an earlier candidate reveal or player-influenced selection.
- For the demo, progressively reveal market systems instead of exposing four equal tabs immediately.

### `[DEFER]`

- Additional owners beyond the basic owner.
- More currencies.
- A separate rent/debt simulation.
- Haggling minigame.
- Appraisal, inspection, farming, or broad shop professions.
- Large procedural route generation.
- More material families before the first five traits and contract loop are proven.

---

## 3. Current flow versus proposed flow

### Current high-level flow

```text
Newspaper
→ route node
→ order panel + abstract planner/estimate
→ craft
→ playback
→ mission report
→ route
```

The structure is sound, but the emotional decision happens too late. The adventurer is mostly an input bundle, the planner is abstract, and the outcome is primarily a report.

### Proposed high-level flow

```text
Boss announcement + chapter obligation
→ current route fork with visible stakes
→ adventurer counter scene
→ base contract + optional promise
→ preparation / market
→ tactile committed-material craft
→ Tie Off risk summary
→ garment reveal + causal fight
→ payment + trust + injury + item persistence
→ world echo on route / newspaper / returning adventurer
```

This remains the same number of major scenes. The rework changes what each scene communicates rather than adding a large parallel game.

---

## 4. Proposed order beat

### Step 1 — Arrival

Target duration: **10–20 seconds**.

Show:

- adventurer bust, name, and job;
- fixed garment constructions;
- target threat;
- one personal sentence explaining why this matters;
- one visible stake: injury, debt, reputation, duty, rivalry, or fear.

Do not begin with six stats and an abstract planner grid. Those remain available under Details.

Example:

> Halden Rook needs armor for the Ash Drake. His last shield is already cracked. He promises to return before the guild closes the road.

### Step 2 — Base contract

The base contract is always safe to accept:

- fixed garment order;
- base payout;
- normal reps outcome;
- no added failure penalty.

The player may decline according to existing appointment/decline law.

### Step 3 — Optional promises

Offer **one** promise on ordinary walk-ins and up to **two** on appointments or authored story orders.

The player chooses:

- no promise;
- one promise;
- both promises for an expert gamble.

Promises are fully disclosed. Do not hide the penalty.

#### Initial promise templates

| Promise | Craft or outcome constraint | Extra reward | Primary test |
|---|---|---|---|
| Rush commission | Start with reduced stamina | Gold | Efficiency |
| Budget ceiling | Committed material value stays below cap | Reps + tip | Low-cost creativity |
| Signature material | Commit a named material to a named item | Relationship + follow-up | Constraint building |
| No compromise | Finish without a negative synergy | Gold + reps | Planning |
| Make me memorable | Reach requested outlook or trait tier | Dex + relationship | Specialization |
| Bring me home | End fight above stated HP | Large trust gain | Defense |
| Against advice | Use a boss-disfavored trait and still clear | High gold + unique line | Expert play |
| Quiet work | No Metal, or finished MOB above target | Faction / appointment access | Alternative build |

### Promise reward rules

- Use existing **gold**, **reps/standing**, relationship flags, Dex, or future-node access.
- Do not add a promise currency.
- Ordinary promise failure first removes the promised bonus.
- Reps loss, injury, or relationship damage must be explicitly previewed.
- The base mission payout remains available unless the mission itself fails.
- Boss promises are authored, not randomly assembled.

### Minimal data shape

```text
contract_promise = {
  id,
  title,
  description,
  constraint_type,
  constraint_args,
  reward,
  failure_consequence,
  target_item_index?,
  target_material_id?,
  target_trait?
}
```

At most two active promise rows per order.

---

## 5. Interactive-order revamp

Owning document if accepted: [30](30-interactive-order.md).

### `[REVAMP]` Slice 1 — person first, mechanics second

Default order panel:

1. adventurer;
2. personal stake;
3. garment order;
4. threat;
5. accepted promises;
6. payout.

Move six base stats and `ask_*` details behind an expandable Details section. They remain available but should not be the emotional first read.

### `[REMOVE AS PRIMARY UX]` manual synergy-target planner

The current planner asks the player to click a desired tier before making the item. That duplicates the real craft decision and creates an abstract step between the person and the materials.

Replace it with:

- automatic live trait/tier forecast from cards currently committed;
- recipe/build discoveries in the Dex;
- optional pinning of a known build from the Dex as a reminder;
- promise tracking when the contract requests a trait.

The player expresses intent by committing cards, not by separately declaring a tag target.

### `[REVAMP]` pre-craft estimate

Do not show a precise S–F band from an imagined build. It suggests certainty that the finished bag, encounter behavior, and unknown enemy information do not support.

Before craft, show three causal groups:

```text
ADVANTAGES
- Earth may reduce the Ash Drake's repeated hits.

DANGERS
- Silk is punished by this threat.

UNKNOWN
- You have not fought this enemy; its second behavior is unknown.
```

After materials are committed, the forecast may become more specific:

- likely survives / lethal risk;
- promise met / possible / failed;
- known favorable and unfavorable trait interactions;
- uncertain enemy behavior.

Keep the actual S–F letter for the mission report.

### Knowledge rule

- Dex uncertainty may hide enemy behavior.
- It must never hide what the player's own cards, tiers, or formulas do.
- Unknown information must be labeled as unknown, not omitted.

---

## 6. Route-map enhancement

Owning document if accepted: [22](22-chapter-schedule.md).

### `[KEEP]` authored graph and current-fork commitment

The authored graph is appropriate for a demo because it lets Design control pacing and guarantee useful markets, orders, and story beats.

### `[REVAMP]` remove editable future drafts

Future drafting adds state and UI without producing a durable choice. Recommended player rule:

- show the entire reachable graph;
- allow hover/click preview of future nodes;
- commit only the next node at the current fork;
- past nodes freeze;
- bound corridors remain visible;
- do not save a mutable ghost itinerary.

This is easier to understand and retains strategic planning.

### Node preview

Every reachable current option should communicate:

- node kind;
- known person or event title when fiction allows;
- expected reward category;
- risk level;
- whether it supports the selected bolt;
- whether it advances chapter standing;
- bound follow-up nodes.

Do not reveal random event outcomes. Reveal the kind of opportunity or risk.

Example:

```text
MARKET
Bolt support: likely
Boss counters: possible
Standing: none

APPOINTMENT — Scrap Duelist
High risk
High standing
Promise available
```

### Route pacing for an 8-day chapter

Recommended emotional rhythm:

1. **D1:** authored first returning-capable adventurer; teaches contract and craft.
2. **D2:** first meaningful fork: market / second order / event.
3. **D3:** appointment or recovery opportunity.
4. **D4–D5:** specialization and relationship consequence.
5. **D6:** boss-fighter candidate confirmation and final meaningful preparation.
6. **D7:** visible final prep, no filler.
7. **D8:** boss approach and climax.

---

## 7. Boss preparation revamp

### Problem

The boss is announced early, but the adventurer/job used for the boss order is drawn at the boss beat. Because constructions and person skills depend on that draw, late randomness can invalidate otherwise intelligent deck preparation.

### `[REVAMP]` candidate reveal

At chapter start:

- reveal the boss;
- reveal **two possible fighter jobs** or named candidates;
- explain how chapter actions influence which candidate becomes available.

By D5 or D6:

- lock the fighter;
- show their fixed constructions and personal skill;
- keep D6/D7 as meaningful final preparation.

Possible selection rules:

- highest relationship among candidates;
- route appointment chosen;
- explicit player selection after meeting a standing requirement;
- authored chapter outcome.

Do not reveal the final fighter only after all market and route decisions are exhausted.

### Boss promise

The boss contract gets one authored promise tied to the chapter story. It should not be required to win, but completing it should produce a memorable unlock, relationship beat, or unique garment record.

---

## 8. Reps / standing revamp

Owning documents if accepted: [24](24-win-conditions.md), [25](25-reps-meter.md).

### Problem

A hard run-over because a numeric reps gate was missed can feel administrative. It also bypasses the game's strongest climax: crafting for and watching the boss fight.

### `[REVAMP]` standing changes boss conditions

Rename player-facing reps to **Guild Standing** or another fiction-specific term.

Always allow the boss contract, but standing changes its conditions:

- **Above target:** choose the fighter or gain a preparation advantage.
- **At target:** normal boss contract.
- **Below target:** weaker candidate, lower starting trust, reduced contract options, or an added boss complication.

The run should normally end because the boss fight was lost, not because the player was stopped before making the final garment.

### Forecast

Route screen always shows:

```text
Standing now
Boss target
Standing available on visible paths
Projected boss condition
```

This uses the existing resource. Do not add rent.

---

## 9. Market enhancement

Owning document if accepted: [32](32-shop-and-events.md).

### `[KEEP]`

- route-node access;
- buy, sell, refresh, material enchant;
- chapter bank;
- one gold purse.

### `[ENHANCE]` curated shelf composition

Pure random draws can produce shelves that are technically valid but irrelevant. For the first shelf of each visit, use soft slots:

- 2 offers biased toward the selected starter bolt;
- 1 offer relevant to the announced boss;
- 1 broadly useful or neutral offer;
- 1 wildcard/deferred material.

Refresh may be less curated but should still exclude a shelf with no usable basic-owner tags.

This improves decision quality without guaranteeing the desired build.

### `[ENHANCE]` explain why an offer matters

On hover:

- current owned copies;
- tag pips;
- which item tier this copy could help reach;
- known boss favor/punish interaction;
- whether it supports an accepted promise.

Do not label a card simply “recommended.” Explain the reason.

### `[REVAMP FOR DEMO]` progressive system reveal

Avoid presenting Materials, Staffs, Skills, and Gear as four equally important tabs during the first market.

Recommended:

- first market: Materials + Enchant only;
- after first successful order: Skills;
- after first appointment or chapter: Tools, containing Staff/Gear for the demo;
- full game may restore separate Staffs and Gear tabs when content depth supports them.

The systems may remain implemented; the recommendation is progressive player exposure.

### `[DO NOT ADD]` haggling

Contract promises already create negotiation and risk. A second price-bargaining minigame would dilute crafting.

---

## 10. Craft-screen enhancement

Owning documents if accepted: [27](27-craft-mode-stamina.md), [40](40-item-trait-affinity.md).

### Committed-material rail

Each item zone displays:

- construction silhouette;
- committed materials in play order;
- per-card cost and pips;
- current item stats;
- current trait tiers;
- next reachable breakpoints;
- relevant promise status.

Once committed, a material visibly moves from the hand into that rail. It cannot silently disappear into a counter.

### Preview before placement

Hovering or dragging a card over a zone shows the delta:

```text
Earth 2 → 3: Root Tier 1 activates
Root Guard 0 → 1
DEF +2
MOB −1
Promise “Bring me home”: still possible
Stamina 6 → 4
```

This preview uses known player data only.

### Tactile response

Use a small reusable response set:

- cloth / silk placement sound;
- metal impact / fastening sound;
- stone-heavy placement sound;
- rune activation sound;
- trait-tier ascend sting;
- garment silhouette, trim, or color update.

Do not require a separate sewing minigame. Card commitment is the hands-on verb.

### `[ENHANCE]` Finish as Tie Off

Player-facing label may be **Tie Off** while the wire remains `player_finish`.

Before confirmation, show:

1. **Certain:** active item tiers and computed affinity effects.
2. **Conditional:** known enemy interactions and promise checks.
3. **Unknown:** unrevealed enemy behavior.

If stamina remains, show it as forgone opportunity—not as an error.

### Undo policy

Recommended first test:

- undo the most recent material commitment before another card is played;
- refund its stamina;
- no undo after Dig, skill resolution, or Tie Off.

This protects against input mistakes without making commitment meaningless.

---

## 11. Playback enhancement

Owning document if accepted: [30](30-interactive-order.md).

### Garment reveal

Before combat:

- reveal each finished item for 1–2 seconds;
- show its strongest trait and fulfilled promise contribution;
- place the item visually on or beside the adventurer;
- then enter one combined fight.

### Causal combat beats

Every trait beat must identify:

- source item;
- trait;
- amount;
- target;
- remaining counter/charge where applicable.

Example:

```text
Cairn Coat · Earth Tier 2
Root reduced 3 damage to 2
```

Do not show only floating numbers without a source.

### Playback controls

- normal speed;
- fast speed after first viewing;
- pause/inspect current beat;
- no manual combat decisions during playback.

The player made decisions during crafting. Playback is proof and drama, not a second combat game.

### Enemy behaviors

For production, each enemy needs:

- one visible signature behavior;
- one escalation or conditional behavior;
- one interaction that changes trait value.

More enemy behaviors produce greater replay value than more passive stat rows.

---

## 12. Mission report and persistent consequence

Owning documents if accepted: [23](23-mission-report.md), [29](29-adventurer-catalog.md), [31](31-dex.md).

### Report hierarchy

Show:

1. adventurer outcome;
2. contract and promise result;
3. payment and standing;
4. three decisive causes;
5. relationship/world change;
6. detailed numeric breakdown behind More.

Example:

```text
HALDEN RETURNED WOUNDED
Contract: clear
Promise “Bring me home”: failed

Why:
- Cairn Coat reduced 6 total damage.
- Ember Cloak applied 5 Burn.
- Low Silk let the Ash Drake act first.

+6 gold
+2 Guild Standing
Halden remembers the failed promise.
```

### Item persistence

The finished item record remains attached to the adventurer:

- item name / outlook;
- construction;
- committed materials;
- trait tiers;
- mission result;
- promise result;
- chapter/run made.

When the adventurer returns, show or reference the item. The item is not only a Dex count.

### World echoes

Use inexpensive channels:

- one newspaper line;
- adventurer portrait garment overlay or item icon;
- altered future dialogue;
- route node unlocked or removed;
- market bias or discount;
- appointment follow-up.

Every important promise should have at least one echo.

---

## 13. Starter-scenario enhancement

Owning document if accepted: [40](40-item-trait-affinity.md).

Do not launch the demo with five equally shallow bolt choices. First prove three:

### Ember — offense / tempo

- primary: Fire;
- secondary market bias: Silk;
- opening customer: aggressive, time-sensitive order;
- teaching point: Burn and initiative;
- risk: weak sustain.

### Cairn — mitigation / commitment

- primary: Earth;
- secondary market bias: Metal;
- opening customer: survival promise;
- teaching point: per-hit Root versus finite Plate;
- risk: low tempo.

### Hearth — recovery / efficiency

- primary: Soft;
- secondary market bias: neutral low-cost materials;
- opening customer: budget ceiling;
- teaching point: Mend reserve and efficient crafting;
- risk: lethal burst.

Each scenario changes:

- three tagged starter cards;
- first customer;
- first market bias;
- tutorial promise;
- wagon color/banner detail;
- recommended first build.

It should not change the route map, boss pool, or core rules.

Fineweave and Forge can join after the first three have clearly different completion and replay behavior.

---

## 14. Content-depth rule

For the first proof, prioritize:

- 3 starter scenarios;
- 4 deeply recurring adventurers;
- 6 reusable promise templates;
- 2 authored boss promises;
- 3 distinct enemy behavior patterns;
- 5 basic-owner traits;
- 1 polished chapter.

Do not treat all 24 catalog adventurers as equally deep for the demo. The broader catalog can remain data-complete, but four people should carry the emotional experience.

### Repetition protection

- Do not repeat the same promise template within three orders.
- Do not schedule the same dominant threat behavior on consecutive orders.
- Track the player's dominant trait and occasionally offer a counter, support, or temptation.
- A returning adventurer must reference at least one prior item or promise.
- Events should modify a later decision, not only grant `±gold`.

---

## 15. Practical implementation sequence

### P0 — prove the emotional loop

No large content expansion.

1. Pick one existing adventurer as the first recurring customer.
2. Add one personal stake line.
3. Add three promise templates.
4. Add promise status to craft and report.
5. Persist the finished item on that adventurer.
6. Add one later dialogue/world echo.

**Exit test:** the player remembers the person and item, not only the rating.

### P0 — make outcomes accountable

1. Per-item trait/tier forecast.
2. Card-hover placement delta.
3. Source item on playback trait beats.
4. Three-cause mission summary.
5. Unknown enemy behavior labeled explicitly.

**Exit test:** at least 80% of observed players can explain why they won or lost.

### P1 — improve route and boss fairness

1. Remove editable future drafts from player UX.
2. Add current-node stake previews.
3. Reveal boss-fighter candidates early.
4. Lock fighter by D5/D6.
5. Convert reps hard gate into boss-condition modifier.

**Exit test:** players can explain what they are preparing for and why they chose a path.

### P1 — tactile craft pass

1. Committed-material rail.
2. Material-family audio.
3. Garment visual update on commitment/tier.
4. Tie Off summary.
5. Limited undo policy.

**Exit test:** placing a material feels like the primary game action.

### P1 — three-scenario demo

1. Ember.
2. Cairn.
3. Hearth.
4. Scenario-biased first market and customer.
5. Capture-ready opening order → craft → fight sequence.

**Exit test:** players express immediate interest in trying another scenario.

### P2 — production depth

1. Returning-adventurer arcs.
2. Additional enemy behaviors.
3. Promise and event variety.
4. Fineweave / Forge starts.
5. Wider catalog depth.

---

## 16. Demo acceptance targets

- First meaningful contract choice within **90 seconds**.
- First Tier-1 trait and visible combat trigger during the first craft.
- First craft reaches Tie Off within **8 minutes** for a new player.
- At least one returning-adventurer or world echo in a **30–45 minute** demo.
- At least **80%** of observed players can identify the decisive win/loss cause.
- At least **50%** voluntarily take one promise.
- Fewer than **20%** accept a promise without reading it.
- Most players can distinguish Earth mitigation, Metal Plate, Soft Mend, Fire Burn, and Silk Flow after seeing each once.
- At least one route fork creates a stated safe-versus-greedy discussion during playtest.

These are research targets, not balance laws.

---

## 17. What this rework deliberately avoids

- It does not copy Probably Stolen's professions or feature count.
- It does not turn Wombaste into real-time store labor.
- It does not add negotiation, appraisal, contraband, rent, or inventory-grid minigames.
- It does not add player-controlled combat.
- It does not replace the route map with a life simulator.
- It does not require dozens of new art assets before proving the loop.

The transferable lesson is:

> Make the fantasy immediately legible, make the core work tactile, make risk voluntary, and make consequences persist.

