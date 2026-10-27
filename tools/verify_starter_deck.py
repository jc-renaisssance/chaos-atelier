#!/usr/bin/env python3
"""Client wire for docs/39 starter deck, C′ burn, D′ survive, and the five kits.

Godot is not required. The fight mirror is the stamped counts in docs/39.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

HP_START = 12
INCOMING = 3
RARE = 3
LEGENDARY = 4


def fail(msg: str) -> None:
    FAILS.append(msg)


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def scale_half_away(n: int) -> int:
    mag = abs(n * 3)
    rounded = (mag + 1) // 2
    return -rounded if n < 0 else rounded


def met(n: int) -> int:
    if n >= 8:
        return 8
    if n >= 5:
        return 5
    if n >= 3:
        return 3
    return 0


def count(bag: dict, tag: str) -> int:
    return int(bag.get(tag, 0))


def combined(pieces: list[dict]) -> dict:
    bag: dict[str, int] = {}
    for piece in pieces:
        for key, value in piece.get("tag_counts", {}).items():
            bag[key] = bag.get(key, 0) + int(value)
    return bag


def charges_of(pieces: list[dict]) -> int:
    n = 0
    for piece in pieces:
        if count(piece.get("tag_counts", {}), "Fire") >= 8:
            n += 1
    return n


def skip_neg(pieces: list[dict]) -> bool:
    for piece in pieces:
        rarity = int(piece.get("craft_rarity", 1))
        if rarity in (RARE, LEGENDARY):
            return True
    return False


def any_cloak(pieces: list[dict]) -> bool:
    return any(piece.get("construction_id") == "con_cloak" for piece in pieces)


def numbers(pieces: list[dict]) -> dict:
    bag = combined(pieces)
    fire, soft, earth, metal, silk = (count(bag, t) for t in ("Fire", "Soft", "Earth", "Metal", "Silk"))
    skip = skip_neg(pieces)
    cloak = any_cloak(pieces)
    apply = 4 if fire >= 8 else 3 if fire >= 5 else 2 if fire >= 3 else 0
    if apply > 0 and metal >= 8:
        apply += 1
    if fire >= 1 and metal >= 1:
        apply += 1
    metal_dmg = 4 if metal >= 5 else 2 if metal >= 3 else 0
    if soft >= 1 and metal >= 1:
        metal_dmg += 1
    if not skip and cloak and metal >= 1:
        metal_dmg = 0
    silk_bonus = 2 if silk >= 8 else 1 if silk >= 5 else 0
    if soft >= 1 and silk >= 1:
        silk_bonus += 1
    earth_cut = 4 if earth >= 5 else 2 if earth >= 3 else 0
    if earth >= 1 and metal >= 1:
        earth_cut += 1
    if earth >= 1 and silk >= 1:
        earth_cut += 1
    heal = 3 if soft >= 5 else 2 if soft >= 3 else 0
    if not skip and fire >= 1 and soft >= 1:
        heal //= 2
    adv_first = silk >= 3
    if not skip and metal >= 3 and silk >= 3:
        adv_first = False
    open_burn = 1 if (not skip and fire >= 1 and soft >= 1) else 0
    open_chip = 0
    if not skip and metal >= 3 and silk >= 3:
        open_chip += 1
    if not skip and cloak and metal >= 1:
        open_chip += 1
    return {
        "apply": apply,
        "metal_dmg": metal_dmg,
        "silk_bonus": silk_bonus,
        "earth_cut": earth_cut,
        "earth_apex": earth >= 8,
        "heal": heal,
        "adv_first": adv_first,
        "open_burn": open_burn,
        "open_chip": open_chip,
        "tick_plus": fire >= 1 and earth >= 1,
        "charges": charges_of(pieces),
        "tier_Fire": met(fire),
        "tier_Soft": met(soft),
        "tier_Earth": met(earth),
        "tier_Metal": met(metal),
        "tier_Silk": met(silk),
    }


def kits_live(pieces: list[dict]) -> bool:
    if not pieces:
        return False
    num = numbers(pieces)
    return any(
        (
            num["apply"] > 0,
            num["metal_dmg"] > 0,
            num["silk_bonus"] > 0,
            num["earth_cut"] > 0,
            num["earth_apex"],
            num["heal"] > 0,
            num["adv_first"],
            num["open_burn"] > 0,
            num["open_chip"] > 0,
            num["charges"] > 0,
            num["tick_plus"],
        )
    )


def fight(pieces: list[dict], foe_1_incoming: int = INCOMING) -> list[str]:
    num = numbers(pieces)
    rows: list[str] = []
    for tag in ("Fire", "Soft", "Earth", "Metal", "Silk"):
        tier = num[f"tier_{tag}"]
        if tier >= 3:
            rows.append(f"{tag} {tier}")
    state = {
        "adv_hp": HP_START,
        "foe_hp": HP_START,
        "adv_burn": 0,
        "foe_burn": 0,
        "charges": num["charges"],
        "fire_applied": False,
        "earth_used": False,
        "tick_plus_used": False,
    }
    rows.append(f"Charges {state['charges']}")
    rows.append(f"Adventurer HP {HP_START}")
    rows.append(f"Foe HP {HP_START}")
    rows.append("Burn counters 0")
    if num["open_burn"] > 0:
        state["adv_burn"] += num["open_burn"]
        rows.append(f"Counter {state['adv_burn']}")
    for _ in range(num["open_chip"]):
        before = state["adv_hp"]
        state["adv_hp"] = before - 1
        rows.append("1")
        rows.append(f"Adventurer HP {before} → {state['adv_hp']}")
    if num["heal"] >= 1:
        before = state["adv_hp"]
        state["adv_hp"] = before + num["heal"]
        rows.append(f"Heal pop {num['heal']}")
        rows.append(f"Adventurer HP {before} → {state['adv_hp']}")
        if state["adv_burn"] > 0:
            stacks = state["adv_burn"]
            state["adv_burn"] = stacks - 1
            rows.append(f"Counter {stacks} → {stacks - 1}")

    def tick(unit: str) -> None:
        stacks = state[f"{unit}_burn"]
        if stacks <= 0:
            return
        dmg = stacks
        if num["tick_plus"] and not state["tick_plus_used"]:
            dmg += 1
            state["tick_plus_used"] = True
        before = state[f"{unit}_hp"]
        state[f"{unit}_hp"] = before - dmg
        state[f"{unit}_burn"] = stacks - 1
        who = "Foe" if unit == "foe" else "Adventurer"
        rows.append(f"Tick {dmg}")
        rows.append(f"{who} HP {before} → {state[f'{unit}_hp']}")
        rows.append(f"Counter {stacks} → {stacks - 1}")
        if unit != "foe" or not state["fire_applied"]:
            return
        leech = dmg // 2
        if leech < 1:
            return
        adv_before = state["adv_hp"]
        state["adv_hp"] = adv_before + leech
        rows.append(f"Heal pop {leech}")
        rows.append(f"Adventurer HP {adv_before} → {state['adv_hp']}")

    def incoming(amount: int) -> None:
        shown = amount
        if not state["earth_used"]:
            state["earth_used"] = True
            shown = max(0, amount - num["earth_cut"])
            if num["earth_apex"] and shown >= 1:
                shown = 0
        rows.append(f"Incoming {shown}")
        if shown == 0:
            return
        before = state["adv_hp"]
        would = before - shown
        if before >= 1 and would <= 0:
            if state["charges"] > 0:
                had = state["charges"]
                state["adv_hp"] = 1
                state["charges"] = had - 1
                rows.append("Survive")
                rows.append(f"Adventurer HP {before} → 1")
                rows.append(f"Charges {had} → {had - 1}")
            else:
                state["adv_hp"] = 0
                rows.append(f"Adventurer HP {before} → 0")
            return
        state["adv_hp"] = would
        rows.append(f"Adventurer HP {before} → {would}")

    def adventurer(which: int) -> None:
        tick("adv")
        if which != 1:
            return
        if num["apply"] > 0:
            old = state["foe_burn"]
            state["foe_burn"] = old + num["apply"]
            state["fire_applied"] = True
            rows.append(f"Apply {num['apply']}")
            if old == 0:
                rows.append(f"Counter {state['foe_burn']}")
            else:
                rows.append(f"Counter {old} → {state['foe_burn']}")
        if num["metal_dmg"] > 0:
            before = state["foe_hp"]
            state["foe_hp"] = before - num["metal_dmg"]
            rows.append(f"Metal damage {num['metal_dmg']}")
            rows.append(f"Foe HP {before} → {state['foe_hp']}")
        if num["silk_bonus"] > 0:
            before = state["foe_hp"]
            state["foe_hp"] = before - num["silk_bonus"]
            rows.append(f"First attack +{num['silk_bonus']}")
            rows.append(f"Foe HP {before} → {state['foe_hp']}")

    def foe(amount: int) -> None:
        tick("foe")
        incoming(amount)

    if num["adv_first"]:
        adventurer(1)
        foe(foe_1_incoming)
        adventurer(2)
        foe(INCOMING)
    else:
        foe(foe_1_incoming)
        adventurer(1)
        foe(INCOMING)
        adventurer(2)
    return rows


def piece(tags: dict, rarity: int = 1, construction: str = "con_tunic") -> dict:
    return {"tag_counts": tags, "craft_rarity": rarity, "construction_id": construction}


def expect_order(rows: list[str], needles: list[str], title: str) -> None:
    at = 0
    for needle in needles:
        while at < len(rows) and rows[at] != needle:
            at += 1
        if at >= len(rows):
            fail(f"{title} missing {needle!r} after the prior line; rows={rows}")
            return
        at += 1


def check_counts() -> None:
    if scale_half_away(1) != 2 or scale_half_away(2) != 3:
        fail("heavy draw 1 → 2 and 2 → 3")
    if scale_half_away(-1) != -2 or scale_half_away(-2) != -3 or scale_half_away(0) != 0:
        fail("heavy draw half away from zero on negatives")

    count1 = fight([piece({"Fire": 8, "Metal": 8}, construction="con_armor")])
    expect_order(
        count1,
        [
            "Fire 8",
            "Metal 8",
            "Charges 1",
            "Burn counters 0",
            "Incoming 3",
            "Adventurer HP 12 → 9",
            "Apply 6",
            "Counter 6",
            "Metal damage 4",
            "Foe HP 12 → 8",
            "Tick 6",
            "Foe HP 8 → 2",
            "Counter 6 → 5",
            "Heal pop 3",
            "Adventurer HP 9 → 12",
            "Incoming 3",
            "Adventurer HP 12 → 9",
        ],
        "count 1",
    )
    if "Survive" in count1 or "Charges 1 → 0" in count1:
        fail("count 1 hits of 3 are not lethal; the charge stays 1")
    if count1.count("Apply 6") != 1:
        fail("adv_2 has no second Fire apply")
    if "Soft 8" in count1 or any(row.startswith("Silk ") for row in count1):
        fail("count 1 does not ascend Soft or Silk")

    count2 = fight([piece({"Fire": 8})], foe_1_incoming=12)
    expect_order(
        count2,
        [
            "Fire 8",
            "Charges 1",
            "Incoming 12",
            "Survive",
            "Adventurer HP 12 → 1",
            "Charges 1 → 0",
            "Apply 4",
            "Counter 4",
            "Tick 4",
            "Foe HP 12 → 8",
            "Counter 4 → 3",
            "Heal pop 2",
            "Adventurer HP 1 → 3",
            "Incoming 3",
            "Adventurer HP 3 → 0",
        ],
        "count 2",
    )
    if "Metal 8" in count2:
        fail("count 2 is Fire only")

    split = fight(
        [piece({"Fire": 4}), piece({"Fire": 4}, construction="con_armor")],
        foe_1_incoming=12,
    )
    if "Fire 8" not in split or "Charges 0" not in split or "Apply 4" not in split:
        fail(f"two Fire 4 pieces ascend and apply, charges stay 0: {split}")
    if "Survive" in split or "Adventurer HP 12 → 0" not in split:
        fail("combined Fire apex with N=0 sets HP to 0 on a lethal hit")

    both = fight(
        [piece({"Fire": 8}), piece({"Fire": 8}, construction="con_armor")],
        foe_1_incoming=12,
    )
    if "Charges 2" not in both or "Charges 2 → 1" not in both:
        fail(f"two Fire-apex pieces mint 2 charges and spend 1: {both}")

    soft = fight([piece({"Soft": 8})])
    expect_order(soft, ["Soft 8", "Charges 0", "Heal pop 3", "Adventurer HP 12 → 15"], "soft apex")
    if "Survive" in soft or any(row.startswith("Apply ") for row in soft):
        fail("Soft ≥ 8 heals and does not mint a survive charge")

    cleansed = fight([piece({"Fire": 8, "Soft": 8})])
    expect_order(
        cleansed,
        ["Counter 1", "Heal pop 1", "Counter 1 → 0"],
        "fire+soft halves the pop then cleanses 1",
    )

    earth = fight([piece({"Earth": 5}, construction="con_armor")])
    if "Incoming 0" not in earth or "Adventurer HP 12 → 9" not in earth:
        fail(f"Earth ≥ 5 shows a 0 chip; the later hit still lands: {earth}")
    if "Adventurer HP 12 → 11" in earth or "Adventurer HP 12 → 10" in earth:
        fail("a 0 chip does not change HP")

    low_earth = fight([piece({"Earth": 3})])
    if "Incoming 1" not in low_earth or "Adventurer HP 12 → 11" not in low_earth:
        fail("Earth ≥ 3 reduces the first 3 to 1")

    apex_earth = fight([piece({"Earth": 8})], foe_1_incoming=12)
    if "Incoming 0" not in apex_earth:
        fail("Earth apex turns a remainder into 0 once")

    silk = fight([piece({"Silk": 5})])
    if silk.index("First attack +1") > silk.index("Incoming 3"):
        fail("Silk ≥ 3 acts first; the +1 is on that first attack")
    silk8 = fight([piece({"Silk": 8, "Soft": 1})])
    if "First attack +3" not in silk8:
        fail("Silk apex +2 replaces +1, then Soft∧Silk adds +1")

    metal_silk = fight([piece({"Metal": 3, "Silk": 3}, construction="con_armor")])
    if metal_silk.index("Incoming 3") > metal_silk.index("Metal damage 2"):
        fail("syn_neg_metal_silk keeps the foe first")
    if "Adventurer HP 12 → 11" not in metal_silk:
        fail("syn_neg_metal_silk opens with 1 HP")

    cloak = fight([piece({"Metal": 5}, construction="con_cloak")])
    if any(row.startswith("Metal damage") for row in cloak):
        fail("syn_neg_cloak_metal suppresses Metal's adv_1 damage")
    if "1" not in cloak:
        fail("syn_neg_cloak_metal opens with a 1 HP chip")

    tick = fight([piece({"Fire": 3})])
    expect_order(tick, ["Apply 2", "Tick 2", "Counter 2 → 1", "Heal pop 1"], "worked tick")

    if kits_live([piece({})]):
        fail("an empty bag does not replace the Surface A fight")
    if not kits_live([piece({"Fire": 8})]):
        fail("a live Fire kit must take the kit fight")


def check_source() -> None:
    catalog = read(SRC / "data" / "catalog" / "craft_catalog.gd")
    block = catalog.split("const OWN_BASIC_STARTER", 1)[1].split("static func own_basic_starter", 1)[0]
    ids = re.findall(r'\["([^"]+)"', block)
    roles = re.findall(r'"(tagged|no_tag|skill)"', block)
    expect_ids = [
        "mat_ember_silk",
        "mat_wool_grey",
        "mat_iron_scrap",
        "mat_hemp_plain",
        "mat_hemp_plain",
        "mat_hemp_plain",
        "mat_hemp_plain",
        "sk_ease_draw",
        "sk_scrap_breath",
        "sk_heavy_draw",
    ]
    if ids != expect_ids:
        fail(f"starter deck ids {ids}")
    if roles != ["tagged", "tagged", "tagged", "no_tag", "no_tag", "no_tag", "no_tag", "skill", "skill", "skill"]:
        fail(f"starter roles {roles}")
    if '"mat_hemp_plain"' not in catalog or '"tags": ["Soft"]' not in catalog.split('"mat_hemp_plain"', 1)[1][:240]:
        fail("shop hemp keeps Soft")
    for blurb in (
        "The next card played into a zone costs 1 less stamina, floor 0. Then draw 1",
        "Discard 1 other card from hand. If that discard happens, stamina +1",
        "The next card played into a zone contributes ×1.5 stats, each stat rounded half away from zero. Tags stay as printed. Then draw 1",
    ):
        if blurb not in catalog:
            fail(f"catalog missing Soft skill sentence: {blurb}")
    if "(mag + 1) // 2" not in catalog:
        fail("heavy draw must round half away from zero")
    chrome = read(SRC / "ui" / "player_chrome.gd")
    for blurb in (
        "The next card played into a zone costs 1 less stamina, floor 0. Then draw 1",
        "Discard 1 other card from hand. If that discard happens, stamina +1",
    ):
        if blurb not in chrome:
            fail("player chrome missing a docs/39 skill sentence")
    if '"sk_next_mat_free": "Next material play costs 0 stamina."' not in chrome:
        fail("bought next-mat-free blurb must stay")
    constants = read(SRC / "autoload" / "game_constants.gd")
    if "const HAND_SIZE := 5" not in constants or "const DIG_REFRESH_COST := 2" not in constants:
        fail("hand 5 and dig 2 stay")
    if '"sk_ease_draw": 1' not in constants or '"sk_scrap_breath": 0' not in constants or '"sk_heavy_draw": 1' not in constants:
        fail("starter skill costs are 1 / 0 / 1")
    if "var ap_" in constants or "AP_START" in constants:
        fail("AP is the stamina meter; do not add a second meter")
    rules = read(SRC / "craft" / "craft_rules.gd")
    if "session.hand.size() != 1" not in rules:
        fail("scrap breath must not pick a card when more than one other card remains")
    if "draw_one(session, rng)" not in rules or 'card.id == "sk_ease_draw"' not in rules:
        fail("ease draw sets the next-card discount and draws 1")
    if 'card.id == "sk_heavy_draw"' not in rules or "stat_one_and_half = true" not in rules:
        fail("heavy draw marks the next zone play")
    if "session.dig_refresh_cost" not in rules:
        fail("dig stays on its own cost")
    session = read(SRC / "autoload" / "atelier_session.gd")
    if "PlaybackBeats.vignette" not in session or "_one_fight" not in session:
        fail("vignettes and the one fight stay")
    if "OwnBasicFight.kits_live" not in session or "OwnBasicFight.build" not in session:
        fail("the one fight wires the kits when they are live")
    if "var dev_tools: bool = false" not in session:
        fail("dev_tools stays false on the player path")
    if "next_cost_less" not in session or "next_stat_heavy" not in session:
        fail("next-card modifiers live on the session and clear with it")
    fight_gd = read(SRC / "ui" / "playback" / "own_basic_fight.gd")
    if "const HP_START := 12" not in fight_gd or "const INCOMING := 3" not in fight_gd:
        fail("playback HP starts at 12 and the skeleton incoming stays 3")
    if "mini(" in fight_gd or "clamp" in fight_gd:
        fail("burn stacks have no cap")
    if 'state["foe_burn"] = old + apply' not in fight_gd:
        fail("apply adds stacks; it does not replace them")
    if "MissionResolver" in fight_gd:
        fail("the kit fight does not recompute the report hp float")
    slot = read(SRC / "ui" / "craft" / "craft_hand_slot.gd")
    if '"cost %d"' not in slot and '"cost %d" %' not in slot:
        fail("cost caption stays")
    if "tags_for_card" not in slot or "PlannerChipArt" not in slot:
        fail("Soft A tag chips stay, and no-tag copies withhold tags")
    beats = read(SRC / "ui" / "playback" / "playback_beats.gd")
    if '"open"' not in beats or '"skill"' not in beats or "static func vignette" not in beats:
        fail("Surface A vignette beats stay")


def main() -> int:
    check_counts()
    check_source()
    if FAILS:
        print(f"starter deck wire: {len(FAILS)} failed")
        for msg in FAILS:
            print(f"  - {msg}")
        return 1
    print("starter deck wire: docs/39 counts, deck, and kit playback hold.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
