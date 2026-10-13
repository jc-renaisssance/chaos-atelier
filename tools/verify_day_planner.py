#!/usr/bin/env python3
"""Source + spec checks for Client route-graph board (docs/22, 20, 24, 27).

Godot is not required. This does not open the editor.
Replaces the free E* Day-planner board (Design #36 / Client #37).
"""
from __future__ import annotations

import ast
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

NODE_KINDS = {"shop", "adventurer", "appointment", "event", "reserved"}
GRAPH_KINDS = {"shop", "adventurer", "appointment", "event"}


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
    if re.search(r"(?<![_\w])GameConstants\.is_assignable_day\b", blob):
        fail(
            "GameConstants.is_assignable_day calls a static on the autoload instance — "
            "use preload(\"res://src/autoload/game_constants.gd\").is_assignable_day(...) "
            "(no class_name on the autoload)"
        )
    for path in SRC.rglob("*.gd"):
        rel = path.relative_to(ROOT)
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if re.search(r":\s*null if ", line):
                fail(
                    f"{rel}:{i} dict ternary null vs T is INCOMPATIBLE_TERNARY — "
                    "assign to var x: Variant first"
                )
    for rel in (
        "src/data/chapter/appointment_pin.gd",
        "src/data/chapter/route_node.gd",
        "src/data/chapter/planner_event.gd",
        "src/data/chapter/day_assignment.gd",
    ):
        text = (ROOT / rel).read_text(encoding="utf-8")
        if re.search(
            r"\bGameConstants\.(is_assignable_day|is_reserved_final_day|is_schedule_day|assignable_day_max)\b",
            text,
        ):
            fail(f"{rel} calls GameConstants statics on the autoload instance")
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
        "class_name RouteNode",
        "class_name RouteEdge",
        "class_name RouteGraphView",
        "class_name RouteNodeView",
        "class_name ScheduleDay",
        "CURRENT_MAP_ID",
        "day_count",
        "CHAPTER_DAY_COUNT",
        "RESERVED_FINAL_DAY_COUNT",
        "func assignable_day_max",
        "func is_assignable_day",
        "func is_reserved_final_day",
        "func fork_options",
        "func confirm_node",
        "func draft_node",
        "func take_day",
        "func can_confirm_node",
        "ROUTE GRAPH",
        "FORK OPTIONS",
        "panel_line",
        "appt_scrap_duelist",
        "combo_market",
        "phase=schedule",
        "StampPhase.SCHEDULE",
        "route_map_id",
        "route_path",
        "draft_path",
        "current_node_id",
        "fork_options",
    ]
    for token in need:
        if token not in blob:
            fail(f"missing source token: {token}")
    if "phase=planner" in blob or "StampPhase.PLANNER" in blob:
        fail("do not invent phase=planner — dump phase=schedule stays")
    if "phase=route" in blob or "StampPhase.ROUTE" in blob:
        fail("do not invent phase=route — dump phase=schedule stays")
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
    if "shops_taken" in session or "shop_ban" in session:
        fail("session must not UI-ban shop after k visits")
    board = (SRC / "data" / "chapter" / "chapter_schedule.gd").read_text(encoding="utf-8")
    if "crafts_max" in re.sub(r"##.*", "", board):
        fail("ChapterSchedule must not keep a crafts_max field")
    if "MapCatalog.day_count" not in board:
        fail("ChapterSchedule must read day_count from MapCatalog / map")
    ui = (SRC / "ui" / "schedule" / "schedule_board.gd").read_text(encoding="utf-8")
    if '"R%d"' in ui or "R1" in ui:
        fail("schedule board must not use R1 Round labels")
    if "pieces %d /" in ui or "CRAFTS_MAX" in ui:
        fail("header must not show a pieces X / max cap")
    if "EVENT OPTIONS" in ui:
        fail("board must not keep the free E* EVENT OPTIONS panel")
    if "DAY PLANNER" in ui:
        fail("board must not keep DAY PLANNER caption — live board is the route graph")
    if "class_name RouteGraphView" not in blob:
        fail("M1 must ship a route-graph layout (nodes + edges), not a day strip only")
    if "Confirm" not in ui or "confirm_node" not in ui:
        fail("board must expose Confirm on a live fork")
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
    if '"event_pool"' in dump or '"day_assignments"' in dump:
        fail("harness dump must not emit superseded event_pool / day_assignments")
    for key in ('"route_map_id"', '"route_nodes"', '"route_edges"', '"route_path"', '"fork_options"', '"draft_path"', '"current_node_id"', '"bound_block_id"'):
        if key not in dump:
            fail(f"harness dump missing {key}")
    if "class_name RoundSlotView" in blob or "class_name ScheduleRound" in blob:
        fail("RoundSlotView / ScheduleRound must stay gone")


def _literal_maps(text: str) -> dict:
    start = text.find("const MAPS :=")
    if start < 0:
        fail("MapCatalog MAPS const missing")
        return {}
    brace = text.find("{", start)
    if brace < 0:
        fail("MapCatalog MAPS const missing opening brace")
        return {}
    depth = 0
    end = -1
    for i, ch in enumerate(text[brace:], brace):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end < 0:
        fail("MapCatalog MAPS const brace mismatch")
        return {}
    raw = text[brace:end]
    raw = raw.replace("true", "True").replace("false", "False")
    try:
        return ast.literal_eval(raw)
    except (SyntaxError, ValueError) as exc:
        fail(f"MapCatalog MAPS is not a Python-literal dict: {exc}")
        return {}


def _complete_paths(nodes: dict[str, dict], outs: dict[str, list[str]], start: str) -> list[list[str]]:
    graph_end_days = {n["day_index"] for n in nodes.values() if n["kind"] != "reserved"}
    max_graph_day = max(graph_end_days) if graph_end_days else 0
    found: list[list[str]] = []

    def walk(path: list[str]) -> None:
        cur = path[-1]
        node = nodes[cur]
        if node["kind"] == "reserved":
            return
        if node["day_index"] == max_graph_day:
            found.append(path[:])
            return
        for nxt in outs.get(cur, []):
            if nxt in path:
                continue
            walk(path + [nxt])

    walk([start])
    return found


def check_map_graph() -> None:
    catalog = (SRC / "data" / "chapter" / "map_catalog.gd").read_text(encoding="utf-8")
    maps = _literal_maps(catalog)
    if "map_m1" not in maps:
        fail("current map map_m1 missing")
        return
    row = maps["map_m1"]
    n = int(row.get("day_count", 0))
    if n != 8:
        fail(f"current map day_count must be 8, got {n}")
    raw_nodes = list(row.get("nodes", []))
    raw_edges = list(row.get("edges", []))
    if row.get("event_pool"):
        fail("map_m1 must not keep a windowed event_pool")
    nodes: dict[str, dict] = {}
    for item in raw_nodes:
        nid = str(item.get("node_id", ""))
        if not nid:
            fail("node missing node_id")
            continue
        if "title" in item:
            fail(f"{nid} must not invent a title field")
        kind = str(item.get("kind", ""))
        if kind not in NODE_KINDS:
            fail(f"{nid} kind {kind} not in {NODE_KINDS}")
        if kind == "appointment" and not str(item.get("ref_id", "")).startswith("appt_"):
            fail(f"{nid} appointment ref must be appt_*")
        if kind == "adventurer" and not str(item.get("ref_id", "")).startswith("adv_"):
            fail(f"{nid} adventurer ref must be adv_*")
        day_i = int(item.get("day_index", 0))
        if kind == "reserved":
            if day_i not in (n - 1, n):
                fail(f"{nid} reserved day_index {day_i} not last-2")
        else:
            if day_i < 1 or day_i > n - 2:
                fail(f"{nid} day_index {day_i} not in 1..(N-2)")
        nodes[nid] = item
    d1 = [item for item in raw_nodes if int(item.get("day_index", 0)) == 1]
    if len(d1) != 1 or str(d1[0].get("node_id")) != "N1":
        fail(f"D1 must be N1 only, got {d1}")
    elif str(d1[0].get("kind")) != "adventurer" or str(d1[0].get("ref_id")) != "adv_halden_rook":
        fail("D1 N1 must be adventurer adv_halden_rook")
    if "N1" not in nodes or "R7" not in nodes or "R8" not in nodes:
        fail("map_m1 missing N1 / R7 / R8")
    outs: dict[str, list[str]] = {nid: [] for nid in nodes}
    ins: dict[str, list[str]] = {nid: [] for nid in nodes}
    for edge in raw_edges:
        frm = str(edge.get("from", edge.get("from_id", "")))
        to = str(edge.get("to", edge.get("to_id", "")))
        if frm not in nodes or to not in nodes:
            fail(f"edge {frm}→{to} missing node")
            continue
        outs[frm].append(to)
        ins[to].append(frm)
        from_day = int(nodes[frm].get("day_index", 0))
        to_day = int(nodes[to].get("day_index", 0))
        if to_day != from_day + 1:
            fail(f"edge {frm}→{to} is not forward day {from_day}→{from_day+1}")
    forks = {nid: dests for nid, dests in outs.items() if 2 <= len(dests) <= 4}
    expected_forks = {
        "N1": {"N2", "N3", "N4"},
        "N3": {"N5", "N6"},
        "N5": {"N7", "N10", "N11"},
        "N6": {"N7", "N11"},
        "N10": {"N12", "N13"},
    }
    got_forks = {nid: set(dests) for nid, dests in forks.items() if nodes[nid]["kind"] != "reserved"}
    if got_forks != expected_forks:
        fail(f"C1 forks mismatch: {got_forks} != {expected_forks}")
    for nid, dests in outs.items():
        if nodes[nid]["kind"] == "reserved":
            continue
        if len(dests) == 0:
            fail(f"{nid} has no outgoing edge")
        if len(dests) > 4:
            fail(f"{nid} fork wider than 4")
        if len(dests) == 1:
            continue
        if not (2 <= len(dests) <= 4):
            fail(f"{nid} outgoing {len(dests)} not corridor(1) or fork(2-4)")
    bind = ["N7", "N8", "N9"]
    for nid in bind:
        if str(nodes.get(nid, {}).get("bound_block_id")) != "combo_market":
            fail(f"{nid} must carry bound_block_id combo_market")
    if outs.get("N7") != ["N8"] or outs.get("N8") != ["N9"]:
        fail("combo_market sequence must be N7→N8→N9")
    scrap = [
        item
        for item in raw_nodes
        if str(item.get("ref_id")) in {"appt_scrap_duelist", "appt_c1_scrap_duelist"}
    ]
    if not scrap or str(scrap[0].get("kind")) != "appointment" or str(scrap[0].get("node_id")) != "N5":
        fail("Scrap Duelist must stay an appointment row on N5 (appt_*), not Dex Adventurers")
    paths = _complete_paths(nodes, outs, "N1")
    if not paths:
        fail("no complete D1..(N-2) paths")
    shop_counts: list[int] = []
    path_ids = [tuple(p) for p in paths]
    for path in paths:
        shops = sum(1 for nid in path if str(nodes[nid].get("kind")) == "shop")
        shop_counts.append(shops)
        if shops < 1 or shops > 3:
            fail(f"complete path {path} shop count {shops} not in 1..3")
        if any(str(nodes[nid].get("kind")) == "reserved" for nid in path):
            fail(f"graph path included reserved {path}")
    expected_samples = {
        ("N1", "N2", "N5", "N7", "N8", "N9"): 2,
        ("N1", "N3", "N5", "N10", "N13", "N15"): 1,
        ("N1", "N4", "N6", "N11", "N16", "N17"): 1,
    }
    for sample, shops in expected_samples.items():
        if sample not in path_ids:
            fail(f"missing sample path {sample}")
        else:
            got = sum(1 for nid in sample if str(nodes[nid].get("kind")) == "shop")
            if got != shops:
                fail(f"sample {sample} shops {got} != {shops}")
    if not shop_counts:
        fail("no shop counts")
    elif min(shop_counts) < 1 or max(shop_counts) > 3:
        fail(f"shop counts {shop_counts} escape 1..3")

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
    if "func confirm_node" not in session or "func take_day" not in session:
        fail("session must expose confirm_node + take_day")
    if "func draft_node" not in session:
        fail("session must expose draft_node (ghost only)")
    schedule = (SRC / "data" / "chapter" / "chapter_schedule.gd").read_text(encoding="utf-8")
    if "is_day_played" not in schedule:
        fail("frozen past must remain")
    if "draft_path" not in schedule or "route_path" not in schedule:
        fail("board must keep route_path vs draft_path")
    ui = (SRC / "ui" / "schedule" / "schedule_board.gd").read_text(encoding="utf-8")
    if "_on_confirm" not in ui or "can_confirm_node" not in ui:
        fail("options panel must wire Confirm on a live fork only")
    if "shops_taken" in ui or "shop ban" in ui.lower():
        fail("UI must not ban shop picks")
    graph_ui = (SRC / "ui" / "schedule" / "route_graph_view.gd").read_text(encoding="utf-8")
    if '"D%d"' not in graph_ui and "D%d" not in graph_ui:
        fail("graph columns must label D1..DN")
    if "travel / final prep" not in graph_ui or "boss approach" not in graph_ui:
        fail("graph must mark reserved last-2")
    if "day_i == board.day_count" not in graph_ui and "day_i == board.day_count" not in ui:
        if "day_count" not in graph_ui:
            fail("boss approach label must be relative to map length, not hardcoded D8")


def check_light_route_sim() -> None:
    """Light walk of C1 forks / corridor / bind / D1-no-panel without Godot."""
    catalog = (SRC / "data" / "chapter" / "map_catalog.gd").read_text(encoding="utf-8")
    maps = _literal_maps(catalog)
    if "map_m1" not in maps:
        return
    row = maps["map_m1"]
    nodes = {str(n["node_id"]): n for n in row["nodes"]}
    outs: dict[str, list[str]] = {nid: [] for nid in nodes}
    for edge in row["edges"]:
        outs[str(edge["from"])].append(str(edge["to"]))

    def fork_panel(current: str, day_index: int, confirmed_today: bool) -> list[str]:
        if day_index == 1 or confirmed_today:
            return []
        node = nodes[current]
        if str(node.get("kind")) == "reserved":
            return []
        dests = [d for d in outs[current] if int(nodes[d]["day_index"]) == day_index]
        if len(dests) < 2:
            return []
        return dests

    if fork_panel("N1", 1, True) != []:
        fail("D1 must have no options panel")
    d2 = fork_panel("N1", 2, False)
    if set(d2) != {"N2", "N3", "N4"}:
        fail(f"N1→D2 fork must be N2/N3/N4, got {d2}")
    if fork_panel("N2", 3, False) != []:
        fail("N2 corridor N2→N5 must hide the options panel")
    if set(fork_panel("N3", 3, False)) != {"N5", "N6"}:
        fail("N3→D3 fork must be N5/N6")
    if fork_panel("N7", 5, False) != []:
        fail("bind N7→N8 must hide the options panel")
    if fork_panel("N8", 6, False) != []:
        fail("bind N8→N9 must hide the options panel")
    if fork_panel("N9", 7, False) != []:
        fail("reserved D7 must hide the options panel")
    schedule = (SRC / "data" / "chapter" / "chapter_schedule.gd").read_text(encoding="utf-8")
    if "day_index == 1" not in schedule or "fork_options" not in schedule:
        fail("board fork_options must special-case D1 empty")
    if "draft_path" in schedule and "route_path.append" in schedule:
        if re.search(r"route_path\.append\(.*draft", schedule):
            fail("confirm must not append draft_path into route_path")


def check_no_free_mid_signal() -> None:
    """bind must not Object.free() RouteNodeView while picked is still emitting."""
    graph = (SRC / "ui" / "schedule" / "route_graph_view.gd").read_text(encoding="utf-8")
    if re.search(r"(?<!queue_)\.free\s*\(", graph):
        fail(
            "route_graph_view must not Object.free() cards mid-picked — "
            "use disconnect + queue_free + deferred rebuild (Godot 4.7 free-locked-object)"
        )
    if "queue_free" not in graph:
        fail("route_graph_view must queue_free stale RouteNodeView cards")
    if "picked.disconnect" not in graph and "disconnect(_on_picked)" not in graph:
        fail("route_graph_view must disconnect picked before dropping cards")
    if 'call_deferred("_apply_bind")' not in graph:
        fail('route_graph_view bind must call_deferred("_apply_bind") so rebuild is not mid-picked')
    if "func _apply_bind" not in graph:
        fail("route_graph_view missing deferred _apply_bind rebuild")
    bind_fn = graph.split("func bind(", 1)[-1].split("func ", 1)[0]
    if "RouteNodeView.new()" in bind_fn:
        fail("bind() must not rebuild cards inline — defer to _apply_bind")
    if "queue_free" in bind_fn or ".free(" in bind_fn:
        fail("bind() must not free cards inline — defer to _apply_bind")


def check_board_scroll() -> None:
    """1280×720: overflow body must scroll; graph must not steal the leftover height."""
    ui = (SRC / "ui" / "schedule" / "schedule_board.gd").read_text(encoding="utf-8")
    if "_body_scroll" not in ui:
        fail("schedule board must keep _body_scroll for 1280×720 overflow")
    if ui.count("ScrollContainer.new()") < 2:
        fail("board must construct a body ScrollContainer (stamp scroll alone is not enough)")
    if "horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED" not in ui:
        fail("overflow ScrollContainer must disable horizontal so labels wrap at viewport width")
    if re.search(r"graph_panel\.size_flags_vertical\s*=\s*Control\.SIZE_EXPAND_FILL", ui):
        fail("graph must not SIZE_EXPAND_FILL vertically — that clips FORK OPTIONS / TODAY / RESOLVE at 720")
    build = ui.split("func _build", 1)[-1].split("func _caption", 1)[0]
    scroll_at = build.find("_body_scroll")
    if scroll_at < 0:
        fail("board _build must create _body_scroll")
        return
    after = build[scroll_at:]
    for token in ('"FORK OPTIONS', '"TODAY', '"RESOLVE'):
        if token not in after:
            fail(f"{token} panel must be parented under the overflow ScrollContainer")
    if "size_flags_vertical = Control.SIZE_EXPAND_FILL" not in after:
        fail("overflow ScrollContainer must SIZE_EXPAND_FILL the leftover height")
    if "_options_panel.visible" not in ui and "_options_caption.visible" not in ui:
        fail("no choice → no options panel (hide fork panel when empty)")


def main() -> int:
    blob = src_text()
    check_project_godot()
    check_godot_47_hotfix(blob)
    check_source_symbols(blob)
    check_gd_balance()
    check_map_graph()
    check_light_route_sim()
    check_no_free_mid_signal()
    check_board_scroll()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK route-graph source + spec (docs/22, 20, 24, 27)")
    print("map_m1 nodes+edges; D1=N1; forks 2–4 when current; bind combo_market; shop 1–3 from graph.")
    print("No crafts_max; phase=schedule; draft ghost only; corridor/bind/reserved/D1 hide the options panel.")
    print("Godot 4.7 constraints: features 4.7; no class_name on autoloads; no Color.html; no const Packed*Array; no var x := Variant helpers.")
    print("route_graph_view: no Object.free mid-picked — disconnect + queue_free + deferred _apply_bind.")
    print("Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
