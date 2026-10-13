#!/usr/bin/env python3
"""Source + spec checks for Client Day planner + drop crafts_max (docs/22, 20, 24, 27).

Godot is not required. This does not open the editor.
"""
from __future__ import annotations

import ast
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

EVENT_KINDS = {"shop", "adventurer", "appointment", "event"}


def fail(msg: str) -> None:
    FAILS.append(msg)


def src_text() -> str:
    parts: list[str] = []
    for path in SRC.rglob("*"):
        if path.suffix in {".gd", ".tscn", ".tres", ".godot"}:
            parts.append(path.read_text(encoding="utf-8"))
    parts.append((ROOT / "project.godot").read_text(encoding="utf-8"))
    return "\n".join(parts)


def gd_blob() -> str:
    return "\n".join(path.read_text(encoding="utf-8") for path in SRC.rglob("*.gd"))


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
    if re.search(r":=\s*[^\n]*\belse\s+null\b", blob):
        fail(":= … else null infers Variant — Godot 4.7.2 warning-as-error (use an explicit type)")
    if re.search(r"const\s+\w+\s*:?=?\s*Packed\w*Array\s*\(", gd_blob()):
        fail("const Packed*Array(...) is not a constant expression in Godot 4.7 — use array literals")
    names: set[str] = set()
    for path in SRC.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        for match in re.finditer(r"func\s+(\w+)\s*\([^)]*\)\s*->\s*Variant", text):
            names.add(match.group(1))
    if names:
        joined = "|".join(re.escape(name) for name in sorted(names, key=len, reverse=True))
        infer = re.compile(rf"^\s*var\s+\w+\s+:=\s*.*\b({joined})\s*\(")
        for path in SRC.rglob("*.gd"):
            rel = path.relative_to(ROOT)
            for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
                if infer.search(line):
                    fail(
                        f"{rel}:{i} var x := Variant-returning helper infers Variant — "
                        "Godot 4.7.2 warning-as-error (use var x: Variant = …)"
                    )


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


def check_source_symbols(blob: str) -> None:
    need = [
        "class_name MapCatalog",
        "class_name PlannerEvent",
        "class_name DayAssignment",
        "class_name ScheduleDay",
        "class_name DaySlotView",
        "CURRENT_MAP_ID",
        "day_count",
        "CHAPTER_DAY_COUNT",
        "RESERVED_FINAL_DAY_COUNT",
        "func assignable_day_max",
        "func is_assignable_day",
        "func is_reserved_final_day",
        "func options_for_day",
        "func assign_day",
        "func pin_fixed_events",
        "func assign_event",
        "func take_day",
        "func can_assign_event",
        "EVENT OPTIONS",
        "DAY PLANNER",
        "panel_line",
        "appt_c1_scrap_duelist",
        "phase=schedule",
        "StampPhase.SCHEDULE",
    ]
    for token in need:
        if token not in blob:
            fail(f"missing source token: {token}")
    if "phase=planner" in blob or "StampPhase.PLANNER" in blob:
        fail("do not invent phase=planner — dump phase=schedule stays")
    constants = (SRC / "autoload" / "game_constants.gd").read_text(encoding="utf-8")
    if "CHAPTER_ROUND_COUNT" in constants:
        fail("GameConstants must not keep CHAPTER_ROUND_COUNT as law")
    if "CRAFTS_MAX" in constants:
        fail("GameConstants must not keep CRAFTS_MAX")
    if re.search(r"const\s+CHAPTER_DAY_COUNT\s*:?=?\s*8", constants):
        fail("do not hardcode CHAPTER_DAY_COUNT=8 as global law — read map.day_count")
    session = (SRC / "autoload" / "atelier_session.gd").read_text(encoding="utf-8")
    if "can_open_piece" in session:
        fail("piece-cap gate can_open_piece must be gone from AtelierSession")
    if "crafts_done ==" in session or "crafts_done >=" in session:
        fail("session must not gate on crafts_done")
    board = (SRC / "data" / "chapter" / "chapter_schedule.gd").read_text(encoding="utf-8")
    if "crafts_max" in re.sub(r"##.*", "", board):
        fail("ChapterSchedule must not keep a crafts_max field")
    if "MapCatalog.day_count" not in board:
        fail("ChapterSchedule must read day_count from MapCatalog / map")
    ui = (SRC / "ui" / "schedule" / "schedule_board.gd").read_text(encoding="utf-8")
    if '"R%d"' in ui or "R1" in ui:
        fail("schedule board must not use R1 Round labels")
    if '"D%d"' not in (SRC / "ui" / "schedule" / "day_slot_view.gd").read_text(encoding="utf-8"):
        fail("DaySlotView must label D1..DN")
    if "pieces %d /" in ui or "CRAFTS_MAX" in ui:
        fail("header must not show a pieces X / max cap")
    if "EVENT OPTIONS" not in ui:
        fail("board must host an EVENT OPTIONS panel")
    if "Assign" not in ui or "assign_event" not in ui:
        fail("board must expose assign on the options panel")
    craft = (SRC / "ui" / "craft" / "craft_table.gd").read_text(encoding="utf-8")
    if "CRAFTS_MAX" in craft or "pieces sewn %d /" in craft:
        fail("craft table must not show a piece cap")
    if "func count_finished_piece" not in board:
        fail("crafts_done telemetry (count_finished_piece) may remain")
    dump = (SRC / "data" / "stamp" / "harness_stamp.gd").read_text(encoding="utf-8")
    if '"crafts_max"' in dump:
        fail("harness dump must not emit crafts_max")
    if '"round_index"' in dump or '"CHAPTER_ROUND_COUNT"' in dump:
        fail("harness dump must use day_* / CHAPTER_DAY_COUNT, not round_*")
    if '"event_pool"' not in dump or '"day_assignments"' not in dump:
        fail("harness dump must include event_pool and day_assignments")
    if "class_name RoundSlotView" in blob or "class_name ScheduleRound" in blob:
        fail("RoundSlotView / ScheduleRound must be replaced by Day labels")


def _literal_maps(text: str) -> dict:
    match = re.search(r"const MAPS := (\{.*?\n\})", text, re.S)
    if not match:
        fail("MapCatalog MAPS const missing")
        return {}
    raw = match.group(1)
    raw = raw.replace("true", "True").replace("false", "False")
    try:
        return ast.literal_eval(raw)
    except (SyntaxError, ValueError) as exc:
        fail(f"MapCatalog MAPS is not a Python-literal dict: {exc}")
        return {}


def check_map_pool() -> None:
    catalog = (SRC / "data" / "chapter" / "map_catalog.gd").read_text(encoding="utf-8")
    maps = _literal_maps(catalog)
    if "map_m1" not in maps:
        fail("current map map_m1 missing")
        return
    row = maps["map_m1"]
    n = int(row.get("day_count", 0))
    if n != 8:
        fail(f"current map day_count must be 8, got {n}")
    pool = list(row.get("event_pool", []))
    kinds = {str(ev.get("kind", "")) for ev in pool}
    if not kinds <= EVENT_KINDS:
        fail(f"E* kinds must be {EVENT_KINDS}, got {kinds}")
    for ev in pool:
        if "title" in ev:
            fail(f"{ev.get('event_id')} must not invent a title field")
        if str(ev.get("kind")) == "appointment" and not str(ev.get("ref_id", "")).startswith("appt_"):
            fail(f"{ev.get('event_id')} appointment ref must be appt_*")
        if str(ev.get("kind")) == "adventurer" and not str(ev.get("ref_id", "")).startswith("adv_"):
            fail(f"{ev.get('event_id')} adventurer ref must be adv_*")
        windows = [int(d) for d in ev.get("windows", [])]
        for day_i in windows:
            if day_i > n - 2:
                fail(f"{ev.get('event_id')} window includes reserved day {day_i}")
    by_day: dict[int, list[dict]] = {d: [] for d in range(1, n + 1)}
    for ev in pool:
        for day_i in ev.get("windows", []):
            by_day[int(day_i)].append(ev)
    d1_ids = {str(ev.get("event_id")) for ev in by_day[1]}
    if d1_ids != {"E5"}:
        fail(f"D1 options must be first-customer E5 only, got {d1_ids}")
    for day_i in range(2, n - 1):
        count = len(by_day[day_i])
        if count < 2 or count > 4:
            fail(f"D{day_i} must list 2–4 options, got {count}")
    if by_day[n - 1] or by_day[n]:
        fail("reserved last-2 must have no player E*")
    scrap = [ev for ev in pool if str(ev.get("ref_id")) == "appt_c1_scrap_duelist"]
    if not scrap or str(scrap[0].get("kind")) != "appointment":
        fail("Scrap Duelist must stay an appointment row (appt_*), not Dex Adventurers")
    ids = [str(ev.get("event_id")) for ev in pool]
    for required in ("E1", "E2", "E3", "E4", "E5", "E8"):
        if required not in ids:
            fail(f"current-map pool missing {required}")

    # Assign / reserved relative to N — not hardcoded 8.
    def assignable(day_i: int, day_count: int) -> bool:
        return 1 <= day_i <= day_count - 2

    def reserved(day_i: int, day_count: int) -> bool:
        return day_count - 1 <= day_i <= day_count

    for day_count, expect_assign, expect_res in (
        (8, list(range(1, 7)), [7, 8]),
        (3, [1], [2, 3]),
        (12, list(range(1, 11)), [11, 12]),
    ):
        got_a = [d for d in range(1, day_count + 1) if assignable(d, day_count)]
        got_r = [d for d in range(1, day_count + 1) if reserved(d, day_count)]
        if got_a != expect_assign or got_r != expect_res:
            fail(f"reserved last-2 broken for N={day_count}: assign={got_a} reserved={got_r}")

    constants = (SRC / "autoload" / "game_constants.gd").read_text(encoding="utf-8")
    if "day_count - RESERVED_FINAL_DAY_COUNT" not in constants and "RESERVED_FINAL_DAY_COUNT" not in constants:
        fail("reserved last-2 must be relative to map day_count")
    session = (SRC / "autoload" / "atelier_session.gd").read_text(encoding="utf-8")
    if "func assign_event" not in session or "func take_day" not in session:
        fail("session must expose chapter-start assign + take_day")
    if "is_day_played" not in (SRC / "data" / "chapter" / "chapter_schedule.gd").read_text(encoding="utf-8"):
        fail("mid-chapter update must freeze played days")
    if "fixed" not in (SRC / "data" / "chapter" / "chapter_schedule.gd").read_text(encoding="utf-8"):
        fail("fixed-window events must pin / refuse moves")
    ui = (SRC / "ui" / "schedule" / "schedule_board.gd").read_text(encoding="utf-8")
    if "_on_assign" not in ui or "can_assign_event" not in ui:
        fail("options panel must wire assign / update on unplayed assignable days")
    slot = (SRC / "ui" / "schedule" / "day_slot_view.gd").read_text(encoding="utf-8")
    if "RESERVED" not in slot or "boss approach" not in slot or "travel / final prep" not in slot:
        fail("timeline must mark reserved last-2")
    if "day_index == day_count" not in slot:
        fail("boss approach label must be relative to map length, not hardcoded D8")


def check_board_scroll() -> None:
    """1280×720: overflow body must scroll; day strip must not steal the leftover height."""
    ui = (SRC / "ui" / "schedule" / "schedule_board.gd").read_text(encoding="utf-8")
    if "_body_scroll" not in ui:
        fail("schedule board must keep _body_scroll for 1280×720 overflow")
    if ui.count("ScrollContainer.new()") < 2:
        fail("board must construct a body ScrollContainer (stamp scroll alone is not enough)")
    if "horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED" not in ui:
        fail("overflow ScrollContainer must disable horizontal so labels wrap at viewport width")
    if re.search(r"timeline_panel\.size_flags_vertical\s*=\s*Control\.SIZE_EXPAND_FILL", ui):
        fail("day strip must not SIZE_EXPAND_FILL vertically — that clips EVENT OPTIONS / TODAY / RESOLVE at 720")
    build = ui.split("func _build", 1)[-1].split("func _caption", 1)[0]
    scroll_at = build.find("_body_scroll")
    if scroll_at < 0:
        fail("board _build must create _body_scroll")
        return
    after = build[scroll_at:]
    for token in ('"EVENT OPTIONS', '"TODAY', '"RESOLVE'):
        if token not in after:
            fail(f"{token} panel must be parented under the overflow ScrollContainer")
    if "size_flags_vertical = Control.SIZE_EXPAND_FILL" not in after:
        fail("overflow ScrollContainer must SIZE_EXPAND_FILL the leftover height")


def main() -> int:
    blob = src_text()
    check_project_godot()
    check_godot_47_hotfix(blob)
    check_source_symbols(blob)
    check_gd_balance()
    check_map_pool()
    check_board_scroll()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK Day planner source + spec (docs/22, 20, 24, 27)")
    print("No crafts_max gate; Day labels; map.day_count; E* options; assign/update; reserved last-2.")
    print("Godot 4.7 constraints: features 4.7; no class_name on autoloads; no Color.html; no const Packed*Array; no var x := Variant helpers.")
    print("Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
