# Craft mode — stamina hand game (Jonathan stamp 2026-09-28)

**Status:** Design stamped. **Doc id: `27`** (renamed from provisional `23` to avoid collision with `23-mission-report.md`). Supersedes form-fill craft (pick construction + fill `material_slots` / default 2m1r) as the live craft UX.

**Jonathan 2026-10-02 (correction):** **supersedes durable-in-hand (#17).** Craft is **Slay the Spire–like** — play leaves the hand; discard / draw / reshuffle. Stamp 2 live readout (Current + Potential) **unchanged**. Stamina still costs on play.

## Entering craft mode

Player takes an **order** (appointment / walk-in) or **prep craft** on the schedule → enter craft mode.

## Construction (order-fixed)

- **Construction comes from the client order**, not from a hand card.
- **No construction cards** in the deck/hand.
- An order may list **multiple constructions** (e.g. armor + gloves), like a multi-enemy encounter.
- Phase-1 rule: craft pieces **in listed order**; each piece has its **own stamina pool**; resolve piece N before starting N+1 (unless early-abort order).

## Hand card types only

| Type | Role |
|---|---|
| **Material** | Stats + tags; same id may stack across plays (copies, or after discard→reshuffle). Play costs **stamina**; card **leaves the hand** → discard |
| **Enchantment / rune** | Extra tags / powers. Play → discard (same cycle) |
| **Owner skill** | Player/owner skill — **not** an equipment power. Play → discard (same cycle) |
| **Consumable** | **Later.** Round-generated that round; **burns** on use (exception to discard). Distinct from `material` — not in Phase-1 `cards_played` type enum; no fake field |

**Law (supersedes durable-in-hand, #17):** Play **any** craft hand card (material included) → it **leaves the hand**. Played cards go to the **discard pile**, unless a special card says otherwise. Cards remain in the **run deck** via discard→reshuffle — they are **not** deleted from the atelier. That is **not** “stay in hand after play.” Round-generated **consumable** cards (Later, distinct type) **burn** on use. Do not treat `material` as a burn type.

Skills manipulate the craft session (costs, converts, doubles, digs), then leave to discard. They are not sewn into the garment unless a skill explicitly says so (none in Phase-1 draft).

## Stamina

- Each play costs **stamina** (card-defined cost ≥ 0 after modifiers). Stamina craft UX is unchanged; this correction is **where the card goes**, not a stamina removal.
- A play (material included) spends stamina **and** the card **leaves the hand** → discard (unless a special card says otherwise). A **consumable** play (Later, distinct type) burns the card.
- Craft for the current piece ends when:
  1. **Stamina hits 0**, or
  2. Player chooses **early finish**
- On end: run the existing resolver (tags → synergies → rarity → outlook → mission/boss sim as appropriate).

### Hand cycle (Slay the Spire–like)

Piles this piece: **hand** · **draw** · **discard**. Together they **are** the run deck. Shop sell / explicit loss still change stock between beats.

1. **Play** any hand card → it leaves the hand → **discard** (unless a special card says otherwise).
2. **Refresh / dig** → remaining hand cards drop to **discard**, then draw a new hand (up to hand size from the **draw** pile).
3. If the draw pile has **not enough cards mid-draw** → **shuffle discard into draw**, then continue drawing.
4. Cards stay in the atelier by cycling discard→reshuffle — **not** by sitting in hand after play.

### Refresh (no auto-refill)

- Hand does **not** refill automatically when empty.
- Player spends stamina to **refresh / dig** (fiction: rummage the wagon stock) even if every hand card was already played.
- Refresh cost: Phase-1 draft **2 stamina** (tunable). Dump remaining hand to discard, then draw up to hand size from the draw pile (reshuffle if short).

## Live item readout (required UI)

Craft session shows two readouts for the **current piece** (Design lock — Ulquiorra implements after merge; not a Client widget spec):

1. **Current** — live stats for the piece in progress (sum / bag from materials + runes played so far this piece).
2. **Potential** — predicted outlook / item identity when that outlook is **unlocked**; if not unlocked, show locked / hidden (no spoiler of the outlook art or name beyond “locked”).

Phase-1: Design UX only. Not a harness dump assert unless Test later stamps fields in [20](20-harness-stamp.md).

## Infinite monostack (intentional)

- No hard material-slot cap in craft mode.
- Depth is gated by **stamina + refresh tax + skill economy + deck contents**.
- Same id may stack across plays (multiple copies, or the same card after it cycles discard→reshuffle). You **cannot** replay one in-hand card without it leaving first.
- Synergy breakpoints still gate readable power and **outlook art** (see [14-synergies](14-synergies.md); RETUNE thresholds merged).

## Phase-1 draft owner skills (examples — not full catalog)

| id | Cost | Effect (draft) |
|---|---:|---|
| `sk_next_mat_free` | 1 | Next material play costs 0 stamina |
| `sk_metal_str_double` | 2 | Double STR contribution from Metal-tagged materials already in this piece |
| `sk_wild_to_earth` | 2 | Consume 1 Wild material in session → add 1 random Earth material into hand |
| `sk_touch_up` | 1 | +1 to one chosen stat on one already-played material |
| `sk_deep_dig` | 3 | Refresh hand; draw +1 extra |
| `sk_steady_hand` | 1 | Ignore first negative synergy roll hint this piece (does **not** skip rarity rules — still full neg skip only on rare/leg) |

`own_basic` starts with a tiny skill stub set Later; Phase-1 may ship 0–2 skills unlocked.

## Resolver (unchanged spine)

After finish: bag tags from played materials + order construction + played runes → rarity (`18`) → positives / negatives (`14`) → outlook = max `outlook_order` → stamp (`20`).

## Superseded

- Player-picked construction from unlocked list during craft
- `construction.material_slots` as the hard fill gate
- Default **2 materials + 1 rune** as the only legal shape (`12b` if present — mark superseded)
- **Durable-in-hand (#17):** “play spends stamina only; card stays in hand / stock”

## Phase-1 draft numbers (Design 2026-09-28, for Ulquiorra)

| Knob | Value |
|---|---|
| Stamina start (per piece) | 12 |
| Hand size | 5 |
| Dig refresh cost | 2 stamina |
| Dig draw | dump remaining hand → discard; draw up to hand size from draw (reshuffle if short) |
| Early finish | allowed anytime |
| Stamina 0 | auto-finish piece → resolver |
| Common mat play cost | 1 |
| Uncommon mat play cost | 2 |
| Rare mat play cost | 3 |
| Enchantment play cost | 2 |

**Law:** stamina craft replaces 2m1r slot UI. Multi-piece = N sessions, one harness stamp each. Play any card → leave hand → discard (unless special). Refresh dumps remaining hand to discard, then draws; mid-draw shortfall shuffles discard into draw. Cards stay in the run deck via reshuffle — **not** in hand after play. Consumables (Later) burn. Live readout = Current + Potential (locked if outlook not unlocked).
