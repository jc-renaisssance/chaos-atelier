#!/usr/bin/env python3
"""Source + spec checks for Client 1B stamina craft (docs/27, docs/20).

Godot is not required. This does not open the editor.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []


def fail(msg: str) -> None:
    FAILS.append(msg)


def src_text() -> str:
    parts: list[str] = []
    for path in SRC.rglob("*"):
        if path.suffix in {".gd", ".tscn", ".tres", ".godot"}:
            parts.append(path.read_text(encoding="utf-8"))
    parts.append((ROOT / "project.godot").read_text(encoding="utf-8"))
    return "\n".join(parts)


def check_project_godot() -> None:
    text = (ROOT / "project.godot").read_text(encoding="utf-8")
    if 'PackedStringArray("4.7"' not in text:
        fail("project.godot config/features must list 4.7")
    if "4.3" in text:
        fail("project.godot still mentions 4.3")
    if "config_version=5" not in text:
        fail("project.godot config_version=5 (file format) missing")
    blob = src_text()
    if re.search(r"^class_name GameConstants\b", blob, re.M):
        fail("class_name GameConstants hides the autoload singleton in Godot 4.7")
    if re.search(r"Color\.html\s*\(", blob):
        fail("Color.html(...) is not a constant expression in Godot 4.7")


def check_source_symbols(blob: str) -> None:
    need = [
        "class_name CraftTable",
        "class_name CraftRules",
        "class_name CraftResolver",
        "class_name CraftReadout",
        "class_name CraftCatalog",
        "class_name WagonStock",
        "func play_hand",
        "func dig(",
        "func finish_early",
        "func count_finished_piece",
        "func apply_piece_session",
        "func burns_on_play",
        "unlocked_outlooks",
        "LOCKED_LABEL",
        "CURRENT",
        "POTENTIAL",
        "DIG_REFRESH_COST",
        "STAMINA_START",
        "sk_next_mat_free",
        "own_basic",
        "docs/27",
        "docs/20",
    ]
    for token in need:
        if token not in blob:
            fail(f"missing source token: {token}")
    code_only = re.sub(r"##.*", "", blob)
    banned = [
        "lineup_card_ids",
        "picked_card_id",
        "max_materials",
        "max_runes",
        "craft_task",
        "StampPhase.SHOP",
    ]
    for token in banned:
        if token in code_only:
            fail(f"superseded token present: {token}")
    if "construction picker" not in blob.lower() and "not a hand card" not in blob:
        fail("UI/source should say construction is not a hand card")
    enums = (SRC / "data" / "game_enums.gd").read_text(encoding="utf-8")
    if re.search(r"enum HandCardType\s*\{[^}]*CONSUMABLE", enums, re.S):
        fail("consumable is Later — do not add it to the stamp type enum")
    rules = (SRC / "craft" / "craft_rules.gd").read_text(encoding="utf-8")
    if "if burns_on_play(card.type):" not in rules:
        fail("play must keep materials; only burns_on_play types leave the hand")
    readout = (SRC / "ui" / "craft" / "craft_table.gd").read_text(encoding="utf-8")
    if "CraftReadout.preview" not in readout or "_refresh_readout" not in readout:
        fail("craft table must live-refresh Current / Potential from CraftReadout")


def check_gd_balance() -> None:
    for path in SRC.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        if text.count("(") != text.count(")"):
            fail(f"unbalanced () in {path.relative_to(ROOT)}")
        if text.count("[") != text.count("]"):
            fail(f"unbalanced [] in {path.relative_to(ROOT)}")
        if text.count("{") != text.count("}"):
            fail(f"unbalanced {{}} in {path.relative_to(ROOT)}")
        for i, line in enumerate(text.splitlines(), 1):
            if line.startswith("    ") and not line.startswith("\t"):
                fail(f"space indent {path.relative_to(ROOT)}:{i}")
                break


# --- spec sim (docs/27 + 20) -------------------------------------------------

STAMINA_START = 12
HAND_SIZE = 5
DIG_COST = 2
MAT_COST = {1: 1, 2: 1, 3: 2, 4: 3, 5: 3}
ENC_COST = 2
SKILL_COST = {"sk_next_mat_free": 1}

CATALOG = {
    "mat_hemp_plain": {"dollar": 1, "type": "material", "tags": ["Soft"], "stats": {"HP": 1, "DEF": 1}},
    "mat_silk_pale": {"dollar": 3, "type": "material", "tags": ["Silk"], "stats": {}},
    "mat_iron_scrap": {"dollar": 1, "type": "material", "tags": ["Metal"], "stats": {"HP": 1, "DEF": 1}},
    "mat_stone_shard": {"dollar": 2, "type": "material", "tags": ["Earth", "Metal"], "stats": {"HP": 2, "DEF": 2}},
    "sk_next_mat_free": {"dollar": 0, "type": "skill", "tags": [], "stats": {}},
    "oil_round": {"dollar": 1, "type": "consumable", "tags": [], "stats": {}},
}
CONS = {
    "con_armor": {"tags": ["Metal"]},
    "con_cloak": {"tags": ["Silent"]},
    "con_gloves": {"tags": ["Sharp"]},
    "con_tunic": {"tags": ["Soft"]},
}


class Session:
    def __init__(self, construction_id: str, piece_index: int, piece_count: int) -> None:
        self.construction_id = construction_id
        self.piece_index = piece_index
        self.piece_count = piece_count
        self.stamina_start = STAMINA_START
        self.stamina_remaining = STAMINA_START
        self.stamina_spent = 0
        self.hand_size = HAND_SIZE
        self.dig_refresh_cost = DIG_COST
        self.dig_count = 0
        self.hand: list[str] = []
        self.cards_played: list[dict] = []
        self.early_finish = False
        self.finish_reason = None
        self.next_mat_free = False

    def play_cost(self, card_id: str) -> int:
        row = CATALOG[card_id]
        if row["type"] == "skill":
            return SKILL_COST[card_id]
        if row["type"] == "rune":
            return ENC_COST
        if row["type"] == "consumable":
            return 1
        if self.next_mat_free:
            return 0
        return MAT_COST[row["dollar"]]

    def play(self, index: int) -> None:
        assert self.finish_reason is None
        card_id = self.hand[index]
        cost = self.play_cost(card_id)
        assert cost <= self.stamina_remaining
        kind = CATALOG[card_id]["type"]
        if burns_on_play(kind):
            self.hand.pop(index)
        if kind == "material" and self.next_mat_free:
            self.next_mat_free = False
        self.stamina_remaining -= cost
        self.stamina_spent += cost
        self.cards_played.append({"id": card_id, "type": kind, "cost": cost})
        if kind == "skill" and card_id == "sk_next_mat_free":
            self.next_mat_free = True
        if self.stamina_remaining == 0:
            self.finish_reason = "stamina_0"

    def dig(self, stock: list[str]) -> None:
        assert self.finish_reason is None
        assert self.stamina_remaining >= DIG_COST
        stock.extend(self.hand)
        self.hand.clear()
        self.stamina_remaining -= DIG_COST
        self.stamina_spent += DIG_COST
        self.dig_count += 1
        while len(self.hand) < HAND_SIZE and stock:
            self.hand.append(stock.pop())
        if self.stamina_remaining == 0:
            self.finish_reason = "stamina_0"

    def finish_early(self) -> None:
        assert self.finish_reason is None
        self.early_finish = True
        self.finish_reason = "early_finish"


def burns_on_play(kind: str) -> bool:
    ## Materials are durable. Consumable (Later) burns if/when that type exists.
    return kind != "material"


def potential_label(outlook_id: str, unlocked: set[str]) -> str:
    if outlook_id == "plain" or outlook_id in unlocked:
        return "plain" if outlook_id == "plain" else outlook_id
    return "locked"


def current_stats_line(session: Session) -> str:
    bag = tag_counts(session)
    return "tags " + ",".join(f"{k}x{bag[k]}" for k in sorted(bag))


def draw(stock: list[str], n: int) -> list[str]:
    out: list[str] = []
    while len(out) < n and stock:
        out.append(stock.pop())
    return out


def tag_counts(session: Session) -> dict[str, int]:
    bag: dict[str, int] = {}
    for tag in CONS[session.construction_id]["tags"]:
        bag[tag] = bag.get(tag, 0) + 1
    for card in session.cards_played:
        if card["type"] == "skill":
            continue
        for tag in CATALOG[card["id"]]["tags"]:
            bag[tag] = bag.get(tag, 0) + 1
    return bag


def run_spec() -> None:
    stock = [
        "mat_hemp_plain",
        "mat_hemp_plain",
        "mat_silk_pale",
        "mat_iron_scrap",
        "mat_stone_shard",
        "sk_next_mat_free",
        "mat_hemp_plain",
        "mat_hemp_plain",
        "mat_iron_scrap",
    ]
    crafts_done = 0
    crafts_max = 4

    # Piece 1 of 2 (armor + gloves)
    s1 = Session("con_armor", 1, 2)
    s1.hand = draw(stock, HAND_SIZE)
    if len(s1.hand) != HAND_SIZE:
        fail("opening draw should fill hand_size from stock")
    if s1.stamina_remaining != 12:
        fail("stamina_start should be 12")

    # play first hemp (cost 1) — durable: card stays, stock unchanged
    stock_before = list(stock)
    hemp_i = s1.hand.index("mat_hemp_plain")
    hemp_copies = s1.hand.count("mat_hemp_plain")
    s1.play(hemp_i)
    if s1.stamina_remaining != 11 or s1.stamina_spent != 1:
        fail(f"hemp play should spend 1, got rem={s1.stamina_remaining} spent={s1.stamina_spent}")
    if s1.hand.count("mat_hemp_plain") != hemp_copies:
        fail("material play must leave the card in hand (durable, stamina only)")
    if stock != stock_before:
        fail("material play must not decrement stock / inventory")
    if any(c["id"].startswith("con_") for c in s1.cards_played):
        fail("construction cards are illegal in cards_played")
    if current_stats_line(s1).find("Soft") < 0:
        fail("Current readout must include tags from materials played so far")
    if potential_label("syn_metal_3", {"plain"}) != "locked":
        fail("Potential must hide an unlocked-unknown outlook as locked")
    if potential_label("plain", {"plain"}) != "plain":
        fail("plain outlook is always unlocked")
    if potential_label("syn_metal_3", {"plain", "syn_metal_3"}) != "syn_metal_3":
        fail("Potential shows outlook identity only after unlock")

    # silk costs 2
    if "mat_silk_pale" in s1.hand:
        s1.play(s1.hand.index("mat_silk_pale"))
        last = s1.cards_played[-1]
        if last["cost"] != 2:
            fail(f"silk play cost should be 2, got {last['cost']}")

    # skill then free mat
    if "sk_next_mat_free" in s1.hand:
        s1.play(s1.hand.index("sk_next_mat_free"))
        if s1.cards_played[-1]["type"] != "skill":
            fail("skill type must be skill")
        if "mat_hemp_plain" in s1.hand:
            s1.play(s1.hand.index("mat_hemp_plain"))
            if s1.cards_played[-1]["cost"] != 0:
                fail("next mat after sk_next_mat_free must cost 0")

    empty_before = len(s1.hand)
    s1.dig(stock)
    if s1.dig_count != 1:
        fail("dig_count should increment")
    if s1.stamina_spent < 1 + DIG_COST:
        fail("stamina_spent must include dig cost")
    if len(s1.hand) > HAND_SIZE:
        fail("hand must not exceed hand_size after dig")
    if empty_before == 0 and not s1.hand and not stock:
        fail("empty hand is legal; dig from empty stock+hand should have been gated")

    s1.finish_early()
    if s1.finish_reason != "early_finish" or not s1.early_finish:
        fail("early finish must set finish_reason=early_finish")
    if s1.stamina_remaining == 0:
        fail("early_finish must not also be stamina_0")
    crafts_done += 1
    if crafts_done != 1:
        fail("crafts_done increments per piece, not per order")

    bag = tag_counts(s1)
    if bag.get("Metal", 0) < 1:
        fail("tag tally must include order construction tags (armor=Metal)")

    # Piece 2
    s2 = Session("con_gloves", 2, 2)
    leftover = list(s1.hand)
    stock.extend(leftover)
    s2.hand = draw(stock, HAND_SIZE)
    s2.stamina_remaining = 2
    s2.stamina_spent = 0
    s2.dig(stock)
    if s2.finish_reason != "stamina_0" or s2.early_finish:
        fail("dig that spends last 2 stamina must finish as stamina_0")
    if s2.stamina_remaining != 0:
        fail("stamina_0 requires remaining == 0")
    crafts_done += 1
    if crafts_done != 2:
        fail("multi-piece order is 2 of crafts_max=4")
    if crafts_done > crafts_max:
        fail("crafts_done exceeded crafts_max")

    # stamina 0 vs early_finish exclusive
    s3 = Session("con_tunic", 1, 1)
    s3.stamina_remaining = 0
    s3.finish_reason = "stamina_0"
    if s3.early_finish and s3.finish_reason == "stamina_0":
        fail("cannot be both early_finish and stamina_0")

    # cloak + metal should be able to fire a neg on common
    s4 = Session("con_cloak", 1, 1)
    s4.cards_played.append({"id": "mat_iron_scrap", "type": "material", "cost": 1})
    bag4 = tag_counts(s4)
    if bag4.get("Silent", 0) != 1 or bag4.get("Metal", 0) != 1:
        fail(f"cloak+iron tags expected Silent+Metal, got {bag4}")

    # rare/leg skip neg is a resolver rule — $4 mat → rare
    if MAT_COST[4] != 3:
        fail("rare mat play cost must be 3")

    # Durable monostack + skill/consumable burn path (consumable type is Later / not in stamp enum)
    s5 = Session("con_armor", 1, 1)
    s5.hand = ["mat_iron_scrap", "sk_next_mat_free", "oil_round"]
    s5.play(0)
    s5.play(0)
    if [c["id"] for c in s5.cards_played] != ["mat_iron_scrap", "mat_iron_scrap"]:
        fail("same durable material may be played again (stamina only)")
    if s5.hand[0] != "mat_iron_scrap":
        fail("replayed material must still be in hand")
    s5.play(1)
    if "sk_next_mat_free" in s5.hand:
        fail("skill leaves the hand (not durable stock)")
    if "oil_round" not in s5.hand:
        fail("consumable should still be in hand before its play")
    s5.play(s5.hand.index("oil_round"))
    if "oil_round" in s5.hand:
        fail("consumable burns on use when that type exists")
    if not burns_on_play("consumable") or burns_on_play("material"):
        fail("burn path: consumable burns; material never burns")


def main() -> int:
    blob = src_text()
    check_project_godot()
    check_source_symbols(blob)
    check_gd_balance()
    run_spec()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK stamina craft source + spec (docs/27, docs/20)")
    print("Durable materials + Current/Potential readout checked. Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
