# Craft mode — stamina hand game (Jonathan stamp 2026-09-28)

**Status:** Design stamped. **Doc id: `27`** (renamed from provisional `23` to avoid collision with `23-mission-report.md`). Supersedes form-fill craft (pick construction + fill `material_slots` / default 2m1r) as the live craft UX.

**Jonathan 2026-10-02 (correction):** **supersedes durable-in-hand (#17).** Craft is **Slay the Spire–like** — play leaves the hand; discard / draw / reshuffle. Stamp 2 live readout (Current + Potential) **unchanged**. Stamina still costs on play.

**Jonathan 2026-10-02 (stamina 0 ≠ finish):** **supersedes** `27` / `20` auto-finish on `stamina_0` / `finish_reason: stamina_0`. When stamina hits 0 the session **stays open**. Cards do **not** disappear or auto-resolve. Only the player clicking **Finish** crafts and runs the resolver. StS cycle + Current/Potential **unchanged**.

**Jonathan 2026-10-02 (multi-piece craft UI):** **supersedes** Phase-1 sequential per-piece stamina pools (piece N then N+1 sessions) for multi-construction orders. Multi-item order → craft **all pieces in one session** with **higher initial stamina**. **Dedicated craft UI** — not the schedule board.

## Entering craft mode

Player takes an **order** (appointment / walk-in / **boss-client**) or **prep craft** on the schedule → leave the schedule board → enter **dedicated craft UI**. Boss beat: draw from the **shared job pool** (`28`); craft that job’s **order constructions**; the adventurer fights the announced boss (`17`, `22`) — player is not the fighter.

One order = **one** craft session. Multi-piece does **not** re-enter craft per piece.

## Dedicated craft UI (not schedule)

Craft is its **own** screen. Do not overlay the schedule board as the live table.

| Region | Contents |
|---|---|
| **Lower** | Hand + action buttons (**Dig**, **Finish**). Cards **display here** only |
| **Upper left** | Client **order detail** (who / threat / listed constructions) |
| **Upper right** | Up to **4** craft **drop zones** — one per ordered item. Unused zones stay empty / hidden if the order has fewer pieces |

```
┌──────────────────────┬──────────────────────────┐
│ Upper left           │ Upper right              │
│ Client order detail  │ Zones (≤4)  [1][2][3][4] │
├──────────────────────┴──────────────────────────┤
│ Lower: hand slots 1–5  ·  Dig (D)  ·  Finish    │
└─────────────────────────────────────────────────┘
```

Phase-1: Design UX lock. Not a Client widget spec this stamp.

## Construction (order-fixed)

- **Construction comes from the client order**, not from a hand card.
- **No construction cards** in the deck/hand.
- An order may list **multiple constructions** (e.g. armor + gloves), like a multi-enemy encounter.
- **Law (supersedes sequential multi-piece):** craft **all listed pieces in one session**. One shared stamina pool (`12 * N`, draft). **Not** resolve piece N, then open a new session for N+1.
- **Max zones = 4.** Order with **>4** constructions = **Later / split**. Do not invent a fifth zone or auto-split this stamp.
- Each zone is one piece = `construction_ids[zone_index-1]`. Zone 1 = first listed construction.

## Input

- **N > 1:** play by **dragging** a hand card into a zone, **or** select a zone then hit **1–5**.
- **N = 1:** one zone; drag not required — **1–5** / click plays into it.
- **1–5** = hand card slots (left→right). Plays the card into the **selected / target** zone.
- **D** = **dig / redraw** hand. StS dig still applies (dump remaining hand → discard, then draw; mid-draw shortfall reshuffles). Session-wide — not per zone.
- Click a zone to **select** it. Enter session: default select **zone 1**. Drag onto a zone plays there and selects it.
- A play **must target a zone**. No zoneless play.

Materials / runes / skills apply to **that piece’s bag only**. Skills that say they hit every zone / the session bag = **Later**. Do not invent.

## Hand card types only

| Type | Role |
|---|---|
| **Material** | Stats + tags; same id may stack across plays (copies, or after discard→reshuffle). Play costs **stamina**; card **leaves the hand** → discard |
| **Enchantment / rune** | Extra tags / powers. Play → discard (same cycle) |
| **Owner skill** | Player/owner skill — **not** an equipment power. Play → discard (same cycle). Target zone’s bag only (Phase-1) |
| **Consumable** | **Later.** Round-generated that round; **burns** on use (exception to discard). Distinct from `material` — not in Phase-1 `cards_played` type enum; no fake field |

**Law (supersedes durable-in-hand, #17):** Play **any** craft hand card (material included) → it **leaves the hand**. Played cards go to the **discard pile**, unless a special card says otherwise. Cards remain in the **run deck** via discard→reshuffle — they are **not** deleted from the atelier. That is **not** “stay in hand after play.” Round-generated **consumable** cards (Later, distinct type) **burn** on use. Do not treat `material` as a burn type.

Skills manipulate the craft session (costs, converts, doubles, digs), then leave to discard. They are not sewn into the garment unless a skill explicitly says so (none in Phase-1 draft). Phase-1: if a skill edits a bag, it edits the **target zone** only.

## Stamina (one pool, whole session)

- **One** stamina pool for the session. Start = **`12 * N`** (Phase-1 **draft** — same per-piece base as mono, summed for parallel play). Jonathan may retune.
- Dig cost stays **2** (session-wide, not × N).
- Each play costs **stamina** (card-defined cost ≥ 0 after modifiers). Stamina craft UX is unchanged for costs; this lock is **when the session ends**.
- A play (material included) spends stamina **and** the card **leaves the hand** → discard (unless a special card says otherwise). A **consumable** play (Later, distinct type) burns the card.
- **Stamina 0 ≠ finish.** When stamina hits 0 the session **stays open**. Hand / draw / discard stay. Cards do **not** vanish. The resolver does **not** run.
- **Only Finish** (player click) ends the **whole** session and proceeds to resolve. Phase-1 legal end = **Finish only** — `finish_reason: player_finish` (`20`).
- **One Finish** → resolve **each zone’s piece** in **order-listed sequence**. Still **one harness stamp per piece** for Test. No auto-finish on stamina 0.
- **0-cost cards** and further **owner abilities** that could still fire at 0 stamina = **Later**. Do not invent a catalog this stamp.
- **Supersedes** any `27` / `20` rule that auto-finishes on `stamina_0` / `finish_reason: stamina_0` as the craft-end trigger. If a dump still carries `stamina_0`, it is a **session state flag** (`stamina_remaining == 0`) — **not** auto-craft.
- **Supersedes** sequential multi-piece: N stamina pools, N enter-craft, resolve N before starting N+1.

### Empty zone at Finish

Zone with **zero plays** at Finish = existing empty-piece path (mono Finish with `cards_played` empty for that piece — construction-only bag, resolver still runs). **`cant_craft` is session-open fail** (could not enter craft) — **not** an empty zone. If a harsher empty/fail piece rule is later stamped, use that. **Hold** if undefined — **do not invent** a harsh fail this stamp.

### Hand cycle (Slay the Spire–like)

Piles this **session** (shared across zones): **hand** · **draw** · **discard**. Together they **are** the run deck. Shop sell / explicit loss still change stock between beats.

1. **Play** any hand card → it leaves the hand → **discard** (unless a special card says otherwise). Play is tagged to the **target zone**.
2. **Refresh / dig** → remaining hand cards drop to **discard**, then draw a new hand (up to hand size from the **draw** pile).
3. If the draw pile has **not enough cards mid-draw** → **shuffle discard into draw**, then continue drawing.
4. Cards stay in the atelier by cycling discard→reshuffle — **not** by sitting in hand after play.

### Refresh (no auto-refill)

- Hand does **not** refill automatically when empty.
- Player spends stamina to **refresh / dig** (fiction: rummage the wagon stock) even if every hand card was already played. **D** or the Dig button.
- Refresh cost: Phase-1 draft **2 stamina** (tunable). Dump remaining hand to discard, then draw up to hand size from the draw pile (reshuffle if short). One shared hand — not per zone.

## Live item readout (required UI)

Craft session shows two readouts for the **active / selected zone** (Design lock — Ulquiorra implements after merge; not a Client widget spec):

1. **Current** — live stats for that zone’s piece (sum / bag from materials + runes played into **that zone** so far).
2. **Potential** — predicted outlook / item identity when that outlook is **unlocked**; if not unlocked, show locked / hidden (no spoiler of the outlook art or name beyond “locked”).

Phase-1: Current / Potential for the **selected zone** only. Per-zone simultaneous readouts = **Later** if too heavy.

Not a harness dump assert unless Test later stamps fields in [20](20-harness-stamp.md).

## Infinite monostack (intentional)

- No hard material-slot cap in craft mode.
- Depth is gated by **stamina + refresh tax + skill economy + deck contents**.
- Same id may stack across plays (multiple copies, or the same card after it cycles discard→reshuffle). You **cannot** replay one in-hand card without it leaving first. Stacks are **per zone bag** — playing the same id into two zones does not merge bags.
- Synergy breakpoints still gate readable power and **outlook art** (see [14-synergies](14-synergies.md); RETUNE thresholds merged).

## Phase-1 draft owner skills (examples — not full catalog)

| id | Cost | Effect (draft) |
|---|---:|---|
| `sk_next_mat_free` | 1 | Next material play costs 0 stamina |
| `sk_metal_str_double` | 2 | Double STR contribution from Metal-tagged materials already in the **target** piece |
| `sk_wild_to_earth` | 2 | Consume 1 Wild material in session → add 1 random Earth material into hand |
| `sk_touch_up` | 1 | +1 to one chosen stat on one already-played material **in the target zone** |
| `sk_deep_dig` | 3 | Refresh hand; draw +1 extra |
| `sk_steady_hand` | 1 | Ignore first negative synergy roll hint this **target** piece (does **not** skip rarity rules — still full neg skip only on rare/leg) |

`own_basic` starts with a tiny skill stub set Later; Phase-1 may ship 0–2 skills unlocked.

## Resolver (unchanged spine)

After **one Finish:** for each zone in **listed order**, bag tags from that zone’s played materials + that construction + that zone’s played runes → rarity (`18`) → positives / negatives (`14`) → outlook = max `outlook_order` → stamp (`20`). One stamp / piece. `crafts_done_this_chapter` still increments **per piece**, not per order.

## Superseded

- Player-picked construction from unlocked list during craft
- `construction.material_slots` as the hard fill gate
- Default **2 materials + 1 rune** as the only legal shape (`12b` if present — mark superseded)
- **Durable-in-hand (#17):** “play spends stamina only; card stays in hand / stock”
- **Stamina 0 auto-finish:** `stamina_0` / `finish_reason: stamina_0` as the craft-end trigger (`20` old assert 14)
- **Sequential multi-piece:** each piece its own stamina pool; resolve piece N before starting N+1; N enter-craft sessions for N constructions

## Phase-1 draft numbers (Design 2026-09-28 / 2026-10-02, for Ulquiorra)

**Draft** — Jonathan may retune. Do not treat as final economy.

| Knob | Value |
|---|---|
| Stamina start (session) | **`12 * N`** (N = `piece_count`; mono = 12) |
| Max zones | **4** (>4 constructions = Later / split — do not invent) |
| Hand size | 5 |
| Dig refresh cost | 2 stamina (not × N) |
| Dig draw | dump remaining hand → discard; draw up to hand size from draw (reshuffle if short) |
| Play target | must name a zone (drag, or selected zone + 1–5) |
| Finish | **one** click ends the **session** — **only** legal Phase-1 end (`player_finish`) |
| Stamina 0 | session **stays open**; **not** auto-finish. Cards stay. Resolver waits for Finish |
| Empty zone at Finish | construction-only / existing empty-piece path; **not** `cant_craft`; no invented harsh fail |
| Common mat play cost | 1 |
| Uncommon mat play cost | 2 |
| Rare mat play cost | 3 |
| Enchantment play cost | 2 |

**Law:** stamina craft replaces 2m1r slot UI. Multi-piece = **one session**, stamina **`12 * N`**, up to **4** zones. **One Finish** resolves listed pieces in order — **N harness stamps**, not N sessions. Play any card → leave hand → discard (unless special); play is tagged to a zone. Refresh dumps remaining hand to discard, then draws; mid-draw shortfall shuffles discard into draw. Cards stay in the run deck via reshuffle — **not** in hand after play. Consumables (Later) burn. Live readout = Current + Potential for the **selected zone** (locked if outlook not unlocked). **Stamina 0 ≠ finish** — session stays open; only **Finish** crafts (`player_finish`). `stamina_0` is state, not auto-craft.
