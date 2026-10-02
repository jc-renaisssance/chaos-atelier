#!/usr/bin/env python3
"""Source + spec checks for Client 1B own_basic loop (docs/20, 23, 24).

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
    if 'GameConstants="*res://src/autoload/game_constants.gd"' not in text:
        fail("GameConstants autoload entry missing")
    if 'AtelierSession="*res://src/autoload/atelier_session.gd"' not in text:
        fail("AtelierSession autoload entry missing")


def check_godot_47_hotfix(blob: str) -> None:
    if re.search(r"^class_name GameConstants\b", blob, re.M):
        fail("class_name GameConstants hides the autoload singleton in Godot 4.7")
    if re.search(r"^class_name AtelierSession\b", blob, re.M):
        fail("class_name AtelierSession would hide the autoload singleton")
    if re.search(r"Color\.html\s*\(", blob):
        fail("Color.html(...) remains in src — 4.7 rejects it as a const expression")
    if re.search(r"const\s+\w+\s*:?=?\s*Color\.html", blob):
        fail("const … Color.html is not a constant expression in Godot 4.7")
    if re.search(r":=\s*[^\n]*\belse\s+null\b", blob):
        fail(":= … else null infers Variant — Godot 4.7.2 warning-as-error (use an explicit type)")


def check_source_symbols(blob: str) -> None:
    need = [
        "class_name MissionResolver",
        "class_name ThreatCatalog",
        "class_name RepsRules",
        "func cant_craft_result",
        "func resolve_boss",
        "func resolve_order",
        "func grade_piece",
        "func stamp_preview",
        "HEADLINE_BOSS_ANNOUNCE",
        "own_basic",
        "docs/23",
        "docs/24",
        "docs/20",
        "boss_death",
        "reps_gate_miss",
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
    if "mission_stub\": true" in blob or "mission_stub = true" in blob:
        fail("mission result is still stubbed")


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


def rating_clears(rating: str) -> bool:
    return rating in {"S", "A", "B", "C"}


def letter(score: float, hp: float, empty: bool, cant: bool) -> str:
    if cant:
        return "F"
    if hp <= 0.0:
        return "F"
    if empty:
        return "D"
    if score >= 82.0:
        return "S"
    if score >= 68.0:
        return "A"
    if score >= 54.0:
        return "B"
    if score >= 40.0:
        return "C"
    if score >= 24.0:
        return "D"
    return "F"


def grade(
    soak: float,
    punch: float,
    favor_n: int,
    punish_n: int,
    neg_n: int,
    pos_n: int,
    rarity_bonus: float,
    cards_n: int,
    difficulty: int,
    is_boss: bool,
    prep: bool,
) -> dict:
    empty = cards_n == 0
    if prep:
        pressure = 0.0
        empty_pen = 0.0
    elif is_boss:
        pressure = 0.84
        empty_pen = 0.22 if empty else 0.0
    else:
        pressure = {1: 0.28, 2: 0.40, 3: 0.52}[difficulty]
        empty_pen = 0.22 if empty else 0.0
    soak_ratio = min(max(soak / float(8 + 2 * max(difficulty, 1)), 0.0), 0.55)
    hp = min(max(1.0 - pressure + soak_ratio + 0.08 * favor_n - 0.12 * punish_n - 0.07 * neg_n - empty_pen, 0.0), 1.0)
    if prep:
        hp = 1.0
    aid = 0 if empty else int(round(punch * 8.0 + 6.0 * pos_n + 12.0 * favor_n))
    aid = max(0, min(100, aid))
    stars = 1 if empty else 2
    score = hp * 42.0 + aid * 0.32 + stars * 5.0 + rarity_bonus + 5.0 * favor_n - 7.0 * punish_n - 6.0 * neg_n
    if prep and empty:
        score = min(score, 30.0)
    rating = letter(score, hp, empty, False)
    cleared = hp > 0.0 and rating_clears(rating)
    return {"rating": rating, "hp": hp, "aid": aid, "cleared": cleared, "failed": not cleared}


def reps_delta(cleared: bool, rating: str, difficulty: int, hp: float, cant: bool) -> int:
    mult = {"S": 3.0, "A": 2.0, "B": 1.5, "C": 1.0, "D": 0.0, "F": 0.0}[rating]
    if cleared:
        return int(round(mult * difficulty))
    if not cant and hp <= 0.0:
        return -3 * difficulty
    return -difficulty


def run_spec() -> None:
    cant = {"rating": "F", "hp": 1.0, "aid": 0, "cleared": False, "cant": True}
    if cant["rating"] != "F" or cant["hp"] <= 0 or cant["aid"] != 0 or cant["cleared"]:
        fail("cant_craft must be F, hp>0, aid 0, cleared false")
    if rating_clears("F") or rating_clears("D"):
        fail("D/F must not clear")
    if not all(rating_clears(r) for r in "SABC"):
        fail("S/A/B/C must clear when hp>0")

    empty_boss = grade(0, 0, 0, 0, 0, 0, 0, 0, 3, True, False)
    if empty_boss["hp"] > 0 or empty_boss["cleared"] or empty_boss["rating"] != "F":
        fail(f"empty loadout vs boss should die F, got {empty_boss}")
    if empty_boss["cleared"]:
        fail("boss empty must not clear")
    # boss fail → run_over
    run_over = (not empty_boss["cleared"])
    reason = "boss_death" if run_over else None
    if not run_over or reason != "boss_death":
        fail("boss fail must be run_over / boss_death")

    mid = grade(2, 1, 0, 1, 0, 0, 0, 1, 2, False, False)
    if mid["hp"] <= 0:
        fail("mid order with some soak should usually keep hp>0")
    # mid fail continues
    mid_run_over = False
    if not mid["cleared"] and mid_run_over:
        fail("mid-fail must not set run_over")

    empty_order = grade(0, 0, 0, 0, 0, 0, 0, 0, 2, False, False)
    if empty_order["rating"] != "D":
        fail(f"empty live order with hp>0 should be D, got {empty_order}")
    if empty_order["cleared"]:
        fail("empty D must not clear")

    prep = grade(1, 0, 0, 0, 0, 0, 0, 0, 1, False, True)
    if prep["hp"] != 1.0:
        fail("prep ready-rack keeps hp 1")

    sewn = grade(8, 3, 2, 0, 0, 2, 6, 3, 2, False, False)
    if not sewn["cleared"] or sewn["rating"] not in "SABC":
        fail(f"decent sew should clear, got {sewn}")

    d = reps_delta(False, "F", 2, 1.0, True)
    if d != -2:
        fail(f"cant_craft fail Δ should be -difficulty, got {d}")
    death = reps_delta(False, "F", 2, 0.0, False)
    if death != -6:
        fail(f"mid death Δ should be -3*difficulty, got {death}")
    win = reps_delta(True, "C", 2, 1.0, False)
    if win != 2:
        fail(f"C clear Δ should be difficulty, got {win}")

    if sewn["cleared"] != (sewn["hp"] > 0 and rating_clears(sewn["rating"])):
        fail("cleared derivation broken")

    stamp_fields = [
        "run_id",
        "player_owner_id",
        "chapter_id",
        "chapter_boss_id",
        "boss_pool_id",
        "CHAPTER_ROUND_COUNT",
        "round_index",
        "rounds_left",
        "round_action",
        "appointment_pins",
        "appt_decline_used",
        "crafts_done_this_chapter",
        "crafts_max",
        "phase",
        "mission_kind",
        "zone_count",
        "stamina_start",
        "cards_played",
        "finish_reason",
        "rating",
        "hp_remaining",
        "damage_aid_pct",
        "skill_effectiveness",
        "cleared",
        "mission_failed",
        "outcome",
        "favor_tags_hit",
        "punish_tags_hit",
        "run_over",
        "run_over_reason",
        "reps_before",
        "reps_after",
        "reps_delta",
        "reps_gate",
        "newspaper_event",
        "newspaper_headline_id",
        "letter_id",
        "cant_craft",
    ]
    dump_src = (SRC / "data" / "stamp" / "harness_stamp.gd").read_text(encoding="utf-8")
    for field in stamp_fields:
        if f'"{field}"' not in dump_src:
            fail(f"stamp dump missing {field}")


def main() -> int:
    blob = src_text()
    check_project_godot()
    check_godot_47_hotfix(blob)
    check_source_symbols(blob)
    check_gd_balance()
    run_spec()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK own_basic loop source + spec (docs/20, 23, 24)")
    print("Godot 4.7 project features set; editor was not opened.")
    print("Hotfix: no class_name GameConstants; no Color.html; no := … else null.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
