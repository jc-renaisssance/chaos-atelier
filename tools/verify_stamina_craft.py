#!/usr/bin/env python3
"""Source + spec checks for Client 1B stamina craft (docs/27, docs/20).

Godot is not required. This does not open the editor.
Parallel multi-piece: one session, stamina_start = 12 * N, ≤4 zones.
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
        "class_name CraftZone",
        "class_name CraftHandSlot",
        "class_name CraftRules",
        "class_name CraftResolver",
        "class_name CraftReadout",
        "class_name CraftCatalog",
        "class_name WagonStock",
        "func play_hand",
        "func select_zone",
        "func open_session",
        "func dig(",
        "func finish_early",
        "func count_finished_piece",
        "func apply_piece_session",
        "func burns_on_play",
        "func reshuffle_discard_into_draw",
        "func draw_up_to_hand",
        "func return_run_deck",
        "func session_stamina_start",
        "draw_pile",
        "discard_pile",
        "unlocked_outlooks",
        "LOCKED_LABEL",
        "CURRENT",
        "POTENTIAL",
        "DIG_REFRESH_COST",
        "STAMINA_START",
        "ZONE_COUNT_MAX",
        "zone_count",
        "zone_index",
        "selected_zone_index",
        "sk_next_mat_free",
        "own_basic",
        "PLAYER_FINISH",
        "player_finish",
        "docs/27",
        "docs/20",
        "_get_drag_data",
        "_drop_data",
        "KEY_D",
        "KEY_1",
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
        "awaiting_next_piece",
        "open_piece_session",
        "Sew next piece",
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
    if "session.hand.remove_at(hand_index)" not in rules:
        fail("play must remove the card from hand (StS: play leaves the hand)")
    if re.search(
        r"if burns_on_play\(card\.type\):\s*\n\s*session\.hand\.remove_at",
        rules,
    ):
        fail("materials must also leave the hand — do not gate remove_at on burns_on_play")
    if "session.discard_pile.append(card)" not in rules:
        fail("played cards must go to discard unless they burn")
    if "reshuffle_discard_into_draw" not in rules:
        fail("mid-draw shortfall must shuffle discard into draw")
    if "return_hand_copies" in rules:
        fail("durable-in-hand return_hand_copies must be reversed")
    if "played.zone_index" not in rules and "zone_index = target" not in rules:
        fail("play must stamp zone_index on cards_played")
    readout = (SRC / "ui" / "craft" / "craft_table.gd").read_text(encoding="utf-8")
    if "CraftReadout.preview" not in readout or "_refresh_readout" not in readout:
        fail("craft table must live-refresh Current / Potential from CraftReadout")
    if "CURRENT" not in readout or "POTENTIAL" not in readout:
        fail("Stamp 2 Current / Potential panel must remain")
    if "selected zone" not in readout.lower() and "selected_zone" not in readout:
        fail("Current / Potential must track the selected zone")
    if "UPPER LEFT" not in readout or "UPPER RIGHT" not in readout:
        fail("dedicated craft UI must keep upper-left order + upper-right zones")
    if "LOWER" not in readout:
        fail("dedicated craft UI must keep the lower hand + actions region")
    if "durable · stays" in readout or "Materials are durable" in readout:
        fail("UI must not claim materials stay in hand after play")
    if "_maybe_stamina_zero" in rules:
        fail("play/dig must not auto-finish on stamina 0 — remove _maybe_stamina_zero")
    if re.search(r"finish_reason\s*=\s*GameEnums\.FinishReason\.STAMINA_0", rules):
        fail("craft_rules must not set finish_reason stamina_0 (superseded auto-craft)")
    if "FinishReason.PLAYER_FINISH" not in rules:
        fail("Finish click must set finish_reason player_finish")
    if '"Finish"' not in readout and "Finish" not in readout:
        fail("craft table must expose a Finish button")
    if "Early finish" in readout:
        fail("Finish is the only button — do not label it Early finish")
    session_src = (SRC / "data" / "craft" / "craft_stamina_session.gd").read_text(encoding="utf-8")
    if "session_stamina_start" not in session_src:
        fail("session stamina_start must be 12 * piece_count")
    if "stamina_start != GameConstants.STAMINA_START" in session_src:
        fail("do not assert stamina_start == 12; session pool is 12 * N")
    played = (SRC / "data" / "craft" / "played_card.gd").read_text(encoding="utf-8")
    if "zone_index" not in played or "construction_id" not in played:
        fail("cards_played rows must include zone_index and construction_id")
    board = (SRC / "ui" / "schedule" / "schedule_board.gd").read_text(encoding="utf-8")
    if "_schedule_root.visible = not in_craft" not in board and "not in_craft" not in board:
        fail("schedule board must hide when the dedicated craft screen is open")
    if "overlay stamina craft" in board:
        fail("craft must not overlay the schedule board as the live table")


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


# --- spec sim (docs/27 + 20 asserts 13–17) -----------------------------------

STAMINA_PER_PIECE = 12
HAND_SIZE = 5
DIG_COST = 2
ZONE_COUNT_MAX = 4
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
    def __init__(self, construction_ids: list[str]) -> None:
        self.construction_ids = list(construction_ids)
        self.piece_count = len(self.construction_ids)
        self.zone_count = self.piece_count
        self.selected_zone_index = 1
        self.piece_index = 1
        self.construction_id = self.construction_ids[0]
        self.stamina_start = STAMINA_PER_PIECE * self.piece_count
        self.stamina_remaining = self.stamina_start
        self.stamina_spent = 0
        self.hand_size = HAND_SIZE
        self.dig_refresh_cost = DIG_COST
        self.dig_count = 0
        self.hand: list[str] = []
        self.draw_pile: list[str] = []
        self.discard_pile: list[str] = []
        self.cards_played: list[dict] = []
        self.early_finish = False
        self.finish_reason = None
        self.next_mat_free = False

    def focus_zone(self, zone_index: int) -> None:
        assert 1 <= zone_index <= self.zone_count
        self.selected_zone_index = zone_index
        self.piece_index = zone_index
        self.construction_id = self.construction_ids[zone_index - 1]

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

    def play(self, index: int, zone_index: int | None = None) -> None:
        assert self.finish_reason is None
        target = self.selected_zone_index if zone_index is None else zone_index
        assert 1 <= target <= self.zone_count
        self.focus_zone(target)
        card_id = self.hand.pop(index)
        cost = self.play_cost(card_id)
        assert cost <= self.stamina_remaining
        kind = CATALOG[card_id]["type"]
        if not burns_on_play(kind):
            self.discard_pile.append(card_id)
        if kind == "material" and self.next_mat_free:
            self.next_mat_free = False
        self.stamina_remaining -= cost
        self.stamina_spent += cost
        self.cards_played.append(
            {
                "id": card_id,
                "type": kind,
                "cost": cost,
                "zone_index": target,
                "construction_id": self.construction_ids[target - 1],
            }
        )
        if kind == "skill" and card_id == "sk_next_mat_free":
            self.next_mat_free = True
        ## Stamina 0 ≠ finish. Session stays open until Finish.

    def cards_for_zone(self, zone_index: int) -> list[dict]:
        return [c for c in self.cards_played if c["zone_index"] == zone_index]

    def reshuffle_discard_into_draw(self) -> bool:
        if not self.discard_pile:
            return False
        self.draw_pile.extend(self.discard_pile)
        self.discard_pile.clear()
        return True

    def draw_up_to_hand(self) -> None:
        while len(self.hand) < HAND_SIZE:
            if not self.draw_pile:
                if not self.reshuffle_discard_into_draw():
                    break
            if not self.draw_pile:
                break
            self.hand.append(self.draw_pile.pop())

    def dig(self) -> None:
        assert self.finish_reason is None
        assert self.stamina_remaining >= DIG_COST
        self.discard_pile.extend(self.hand)
        self.hand.clear()
        self.stamina_remaining -= DIG_COST
        self.stamina_spent += DIG_COST
        self.dig_count += 1
        self.draw_up_to_hand()
        ## Stamina 0 ≠ finish. Dig that spends the last stamina leaves the session open.

    def run_deck(self) -> list[str]:
        return list(self.hand) + list(self.draw_pile) + list(self.discard_pile)

    def finish_early(self) -> list[dict]:
        assert self.finish_reason is None
        self.early_finish = True
        self.finish_reason = "player_finish"
        stamps = []
        for i in range(1, self.piece_count + 1):
            self.focus_zone(i)
            stamps.append(
                {
                    "piece_index": i,
                    "piece_count": self.piece_count,
                    "zone_count": self.zone_count,
                    "construction_id": self.construction_id,
                    "stamina_start": self.stamina_start,
                    "stamina_remaining": self.stamina_remaining,
                    "finish_reason": "player_finish",
                    "cards_played": list(self.cards_played),
                    "bag": tag_counts(self, i),
                }
            )
        return stamps


def burns_on_play(kind: str) -> bool:
    ## Consumable (Later) burns. Materials / runes / skills go to discard.
    return kind == "consumable"


def potential_label(outlook_id: str, unlocked: set[str]) -> str:
    if outlook_id == "plain" or outlook_id in unlocked:
        return "plain" if outlook_id == "plain" else outlook_id
    return "locked"


def current_stats_line(session: Session, zone_index: int | None = None) -> str:
    bag = tag_counts(session, zone_index or session.selected_zone_index)
    return "tags " + ",".join(f"{k}x{bag[k]}" for k in sorted(bag))


def tag_counts(session: Session, zone_index: int) -> dict[str, int]:
    bag: dict[str, int] = {}
    con_id = session.construction_ids[zone_index - 1]
    for tag in CONS[con_id]["tags"]:
        bag[tag] = bag.get(tag, 0) + 1
    for card in session.cards_for_zone(zone_index):
        if card["type"] == "skill":
            continue
        for tag in CATALOG[card["id"]]["tags"]:
            bag[tag] = bag.get(tag, 0) + 1
    return bag


def run_spec() -> None:
    deck = [
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

    # One session for armor + gloves — stamina 24, two zones
    s = Session(["con_armor", "con_gloves"])
    if s.stamina_start != 24 or s.zone_count != 2 or s.piece_count != 2:
        fail(
            f"multi-piece session should be stamina 24 / 2 zones, got start={s.stamina_start} zones={s.zone_count}"
        )
    if s.zone_count > ZONE_COUNT_MAX:
        fail("zone_count must be ≤ 4")
    s.draw_pile = list(deck)
    s.draw_up_to_hand()
    if len(s.hand) != HAND_SIZE:
        fail("opening draw should fill hand_size from draw pile")
    leftover_draw = list(s.draw_pile)
    if len(leftover_draw) != len(deck) - HAND_SIZE:
        fail("opening draw must leave remainder on the draw pile")

    # play first hemp into zone 1 — leaves hand → discard; stays in run deck
    hemp_i = s.hand.index("mat_hemp_plain")
    hemp_in_hand = s.hand.count("mat_hemp_plain")
    deck_before = s.run_deck()
    s.play(hemp_i, 1)
    if s.stamina_remaining != 23 or s.stamina_spent != 1:
        fail(f"hemp play should spend 1 from 24, got rem={s.stamina_remaining} spent={s.stamina_spent}")
    last = s.cards_played[-1]
    if last.get("zone_index") != 1 or last.get("construction_id") != "con_armor":
        fail("play must stamp zone_index + construction_id")
    if s.hand.count("mat_hemp_plain") != hemp_in_hand - 1:
        fail("material play must leave the hand (StS cycle, not durable-in-hand)")
    if "mat_hemp_plain" not in s.discard_pile:
        fail("played material must go to discard")
    if sorted(s.run_deck()) != sorted(deck_before):
        fail("play must keep the card in the run deck (discard), not delete it")
    if leftover_draw != s.draw_pile:
        fail("material play must not pull from the draw pile")
    if any(c["id"].startswith("con_") for c in s.cards_played):
        fail("construction cards are illegal in cards_played")
    if current_stats_line(s, 1).find("Soft") < 0:
        fail("Current readout must include tags from materials played into the selected zone")
    if "Soft" in tag_counts(s, 2):
        fail("zone bags must not merge — hemp in zone 1 must not enter zone 2")
    if potential_label("syn_metal_3", {"plain"}) != "locked":
        fail("Potential must hide an unlocked-unknown outlook as locked")
    if potential_label("plain", {"plain"}) != "plain":
        fail("plain outlook is always unlocked")
    if potential_label("syn_metal_3", {"plain", "syn_metal_3"}) != "syn_metal_3":
        fail("Potential shows outlook identity only after unlock")

    # silk costs 2 into selected zone (still 1)
    if "mat_silk_pale" in s.hand:
        s.play(s.hand.index("mat_silk_pale"))
        last = s.cards_played[-1]
        if last["cost"] != 2:
            fail(f"silk play cost should be 2, got {last['cost']}")
        if last.get("zone_index") != 1:
            fail("1–5 / click without a drop uses the selected zone")
        if "mat_silk_pale" in s.hand:
            fail("silk must leave the hand after play")

    # skill then free mat — still zone 1
    if "sk_next_mat_free" in s.hand:
        s.play(s.hand.index("sk_next_mat_free"), 1)
        if s.cards_played[-1]["type"] != "skill":
            fail("skill type must be skill")
        if s.cards_played[-1].get("zone_index") != 1:
            fail("skill plays still carry zone_index")
        if "sk_next_mat_free" in s.hand:
            fail("skill must leave the hand → discard")
        if "sk_next_mat_free" not in s.discard_pile:
            fail("played skill must go to discard")
        if "mat_hemp_plain" in s.hand:
            s.play(s.hand.index("mat_hemp_plain"), 1)
            if s.cards_played[-1]["cost"] != 0:
                fail("next mat after sk_next_mat_free must cost 0")

    remaining_before_dig = list(s.hand)
    discarded_before_dig = list(s.discard_pile)
    spent_before_dig = s.stamina_spent
    s.dig()
    if s.dig_count != 1:
        fail("dig_count should increment")
    if s.stamina_spent != spent_before_dig + DIG_COST:
        fail("dig cost stays 2 — not × N")
    if len(s.hand) > HAND_SIZE:
        fail("hand must not exceed hand_size after dig")
    for card_id in remaining_before_dig:
        if card_id in s.hand and s.hand.count(card_id) > (
            leftover_draw + discarded_before_dig + remaining_before_dig
        ).count(card_id):
            fail("dig must dump remaining hand to discard before drawing")
    if remaining_before_dig and all(c in s.hand for c in remaining_before_dig) and not leftover_draw:
        fail("dig must dump remaining hand to discard, then draw a new hand")

    # Play into zone 2 from the same session / same stamina pool
    if "mat_iron_scrap" in s.hand:
        rem_before = s.stamina_remaining
        s.play(s.hand.index("mat_iron_scrap"), 2)
        if s.cards_played[-1]["construction_id"] != "con_gloves":
            fail("zone 2 play must tag construction_id=con_gloves")
        if s.stamina_remaining != rem_before - 1:
            fail("zone 2 play spends the shared session pool — not a fresh 12")
        if s.stamina_start != 24:
            fail("playing into zone 2 must not reset stamina_start")

    stamps = s.finish_early()
    if s.finish_reason != "player_finish" or not s.early_finish:
        fail("Finish must set finish_reason=player_finish (early_finish agrees)")
    if s.finish_reason == "stamina_0":
        fail("Finish must not emit finish_reason stamina_0")
    if len(stamps) != 2:
        fail("one Finish must emit one stamp per piece (N stamps, one session)")
    if [row["piece_index"] for row in stamps] != [1, 2]:
        fail("Finish stamps must be listed sequence 1..N")
    if any(row["stamina_start"] != 24 for row in stamps):
        fail("each piece stamp repeats the session stamina_start = 12 * N")
    if any(row["finish_reason"] != "player_finish" for row in stamps):
        fail("every piece stamp from that Finish uses player_finish")
    if stamps[0]["bag"].get("Metal", 0) < 1:
        fail("tag tally must include order construction tags (armor=Metal)")
    if stamps[1]["bag"].get("Sharp", 0) < 1:
        fail("empty-or-played gloves zone must still carry construction Sharp")
    if "Soft" in stamps[1]["bag"]:
        fail("zone 2 stamp bag must not include zone 1 hemp Soft")
    crafts_done += len(stamps)
    if crafts_done != 2:
        fail("crafts_done increments per piece after the one Finish, not per order")
    if crafts_done > crafts_max:
        fail("crafts_done exceeded crafts_max")

    # Empty zone at Finish = construction-only bag, not cant_craft
    empty = Session(["con_tunic", "con_cloak"])
    empty.hand = ["mat_hemp_plain"]
    empty.play(0, 1)
    empty_stamps = empty.finish_early()
    if empty_stamps[1]["bag"] != {"Silent": 1}:
        fail(f"empty zone at Finish is construction-only, got {empty_stamps[1]['bag']}")
    if empty_stamps[1].get("cant_craft"):
        fail("empty zone at Finish is not cant_craft")

    # stamina 0 is state — session stays open until Finish
    s0 = Session(["con_tunic"])
    if s0.stamina_start != 12:
        fail("mono session stamina_start should be 12 * 1")
    s0.hand = ["mat_hemp_plain"]
    s0.stamina_remaining = 2
    s0.stamina_spent = 10
    deck_at_zero = s0.run_deck()
    s0.dig()
    if s0.finish_reason is not None:
        fail("dig that spends last 2 stamina must not auto-finish")
    if s0.stamina_remaining != 0:
        fail("last-2 dig should leave stamina_remaining == 0")
    if s0.early_finish:
        fail("stamina 0 must not set early_finish")
    if not s0.run_deck():
        fail("cards must stay in the StS piles when stamina hits 0")
    if sorted(s0.run_deck()) != sorted(deck_at_zero):
        fail("stamina 0 must not drop cards from the run deck")
    s0.finish_early()
    if s0.finish_reason != "player_finish":
        fail("Finish at stamina 0 must set player_finish")
    if "mat_hemp_plain" not in s0.hand and "mat_hemp_plain" not in s0.discard_pile and "mat_hemp_plain" not in s0.draw_pile:
        fail("Finish is what ends the session — cards stay until then")

    s3 = Session(["con_tunic"])
    s3.hand = ["mat_hemp_plain"]
    s3.stamina_remaining = 0
    if s3.finish_reason is not None:
        fail("stamina_remaining == 0 with no Finish must stay open")
    s3.finish_early()
    if s3.finish_reason != "player_finish":
        fail("explicit Finish at 0 stamina must be player_finish")
    if "mat_hemp_plain" not in s3.hand:
        fail("Finish is what ends the piece — cards stay until then")

    # cloak + metal should be able to fire a neg on common
    s4 = Session(["con_cloak"])
    s4.cards_played.append(
        {"id": "mat_iron_scrap", "type": "material", "cost": 1, "zone_index": 1, "construction_id": "con_cloak"}
    )
    bag4 = tag_counts(s4, 1)
    if bag4.get("Silent", 0) != 1 or bag4.get("Metal", 0) != 1:
        fail(f"cloak+iron tags expected Silent+Metal, got {bag4}")

    if MAT_COST[4] != 3:
        fail("rare mat play cost must be 3")

    # Same id via copies or after reshuffle — not by replaying one in-hand card
    s5 = Session(["con_armor"])
    s5.hand = ["mat_iron_scrap", "mat_iron_scrap", "sk_next_mat_free", "oil_round"]
    s5.play(0, 1)
    if "mat_iron_scrap" not in s5.discard_pile:
        fail("played material must sit in discard")
    s5.play(0, 1)
    if [c["id"] for c in s5.cards_played] != ["mat_iron_scrap", "mat_iron_scrap"]:
        fail("same material id may stack via copies (each play leaves the hand)")
    if "mat_iron_scrap" in s5.hand:
        fail("cannot replay one in-hand card — it already left")
    if s5.discard_pile.count("mat_iron_scrap") != 2:
        fail("both iron copies must be in discard")
    s5.play(0, 1)
    if "sk_next_mat_free" in s5.hand:
        fail("skill leaves the hand")
    if "sk_next_mat_free" not in s5.discard_pile:
        fail("skill goes to discard")
    if "oil_round" not in s5.hand:
        fail("consumable should still be in hand before its play")
    s5.play(s5.hand.index("oil_round"), 1)
    if "oil_round" in s5.hand:
        fail("consumable burns on use when that type exists")
    if "oil_round" in s5.discard_pile:
        fail("consumable burns — it does not go to discard")
    if not burns_on_play("consumable") or burns_on_play("material"):
        fail("burn path: consumable burns; material never burns")

    # Mid-draw reshuffle: empty draw, dump + reshuffle discard, continue
    s6 = Session(["con_tunic"])
    s6.hand = ["mat_hemp_plain", "mat_silk_pale"]
    s6.draw_pile = []
    s6.discard_pile = ["mat_iron_scrap", "mat_stone_shard", "mat_hemp_plain"]
    s6.play(0, 1)
    s6.dig()
    if s6.dig_count != 1:
        fail("reshuffle dig should increment dig_count")
    if s6.draw_pile and len(s6.hand) < HAND_SIZE:
        fail("draw should continue after reshuffle until hand_size or empty")
    if len(s6.hand) != 5:
        fail(f"reshuffle mid-draw should refill to 5, got {len(s6.hand)}")
    if s6.discard_pile:
        fail("after full redraw from reshuffled discard, discard should be empty")
    if "mat_silk_pale" not in s6.hand:
        fail("dumped leftover hand must cycle back via reshuffle")
    if "mat_hemp_plain" not in s6.hand:
        fail("played hemp must cycle discard → draw → hand")

    # N > 4 is Later — do not invent a fifth zone
    if ZONE_COUNT_MAX != 4:
        fail("max zones must be 4")


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
    print("Parallel multi-piece: one session, stamina_start=12*N, ≤4 zones, one Finish.")
    print("Finish-only craft (player_finish). Stamina 0 stays open. StS + selected-zone Current/Potential.")
    print("Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
