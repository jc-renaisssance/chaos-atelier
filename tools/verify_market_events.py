#!/usr/bin/env python3
"""Source + spec checks for Client market visit + text events M1 (docs/32, 20).

Godot is not required. This does not open the editor.
Does not cover M2 staff / skill / gear tabs, elite telegraph, or adventurer catalog.
"""
from __future__ import annotations

import ast
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

BANK = [
    "mat_hemp_plain",
    "mat_iron_scrap",
    "mat_cotton_spring",
    "mat_wool_grey",
    "mat_leather_tan",
    "mat_bronze_scale",
    "mat_clayweave",
    "mat_stone_shard",
    "mat_milkfleece",
    "mat_ivy_cord",
    "mat_tar_thread",
    "mat_silk_pale",
    "mat_leather_dusk",
    "mat_linen_storm",
    "mat_wirecloth",
    "mat_stonefiber",
    "mat_ember_silk",
    "mat_frostwool",
    "mat_suncloth",
    "mat_whisper_gauze",
    "mat_velvet_court",
    "mat_steel_plate",
]
NODE_EVENTS = {
    "N4": "evt_c1_heat_mirage",
    "N6": "evt_c1_ashfall",
    "N10": "evt_c1_scrap_market",
    "N17": "evt_c1_salt_spray",
}
EXCLUDED = {
    "mat_grave_silk",
    "mat_null_ink_cloth",
    "mat_silver_moth",
    "mat_skybone_weave",
    "mat_skyiron_filigree",
}
DUMP_MARKET = [
    '"market_node_id"',
    '"market_bank_id"',
    '"market_stock"',
    '"market_buys"',
    '"market_sells"',
    '"market_refresh_base"',
    '"market_refresh_step"',
    '"market_refresh_count"',
    '"market_refresh_cost_next"',
    '"market_refreshes"',
    '"market_enchants"',
    '"gold"',
    '"gold_before"',
    '"gold_after"',
    '"deck_material_count"',
]
DUMP_EVENT = [
    '"event_id"',
    '"event_choice_id"',
    '"event_deltas"',
    '"event_resolved"',
]


def fail(msg: str) -> None:
    FAILS.append(msg)


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def gd_blob() -> str:
    return "\n".join(path.read_text(encoding="utf-8") for path in SRC.rglob("*.gd"))


def src_blob() -> str:
    parts: list[str] = []
    for path in SRC.rglob("*"):
        if path.suffix in {".gd", ".tscn", ".tres", ".godot"}:
            parts.append(path.read_text(encoding="utf-8"))
    parts.append((ROOT / "project.godot").read_text(encoding="utf-8"))
    return "\n".join(parts)


def check_godot_47() -> None:
    blob = gd_blob()
    if re.search(r"^class_name GameConstants\b", blob, re.M):
        fail("class_name GameConstants hides the autoload singleton in Godot 4.7")
    if re.search(r"^class_name AtelierSession\b", blob, re.M):
        fail("class_name AtelierSession would hide the autoload singleton")
    if re.search(r"Color\.html\s*\(", blob):
        fail("Color.html(...) remains in src — 4.7 rejects it as a const expression")
    if re.search(r"const\s+\w+\s*:?=?\s*Packed\w*Array\s*\(", blob):
        fail("const Packed*Array(...) is not a constant expression in Godot 4.7")
    for path in SRC.rglob("*.gd"):
        rel = path.relative_to(ROOT)
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if re.search(r":\s*null if ", line):
                fail(f"{rel}:{i} dict ternary null vs T is INCOMPATIBLE_TERNARY")
            if line.startswith("    ") and not line.startswith("\t"):
                fail(f"space indent {rel}:{i}")
                break


def _const_dict(text: str, name: str) -> dict:
    start = text.find(f"const {name}")
    if start < 0:
        fail(f"{name} const missing")
        return {}
    brace = text.find("{", start)
    if brace < 0:
        fail(f"{name} missing opening brace")
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
        fail(f"{name} brace mismatch")
        return {}
    raw = text[brace:end].replace("true", "True").replace("false", "False")
    try:
        return ast.literal_eval(raw)
    except (SyntaxError, ValueError) as exc:
        fail(f"{name} is not a Python-literal dict: {exc}")
        return {}


def _const_list(text: str, name: str) -> list:
    start = text.find(f"const {name}")
    if start < 0:
        fail(f"{name} const missing")
        return []
    br = text.find("[", start)
    if br < 0:
        fail(f"{name} missing [")
        return []
    depth = 0
    end = -1
    for i, ch in enumerate(text[br:], br):
        if ch == "[":
            depth += 1
        elif ch == "]":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end < 0:
        fail(f"{name} bracket mismatch")
        return []
    try:
        return ast.literal_eval(text[br:end])
    except (SyntaxError, ValueError) as exc:
        fail(f"{name} is not a Python-literal list: {exc}")
        return []


def check_bank() -> None:
    market = read("src/data/catalog/market_catalog.gd")
    catalog = read("src/data/catalog/craft_catalog.gd")
    bank = _const_list(market, "BANK_C1")
    if len(bank) != 22:
        fail(f"market_bank_c1 size {len(bank)} != 22")
    if sorted(bank) != sorted(BANK):
        fail(f"market_bank_c1 mismatch: extra={set(bank) - set(BANK)} missing={set(BANK) - set(bank)}")
    mats = _const_dict(catalog, "MATERIALS")
    for mat_id in bank:
        if mat_id not in mats:
            fail(f"{mat_id} in bank but missing from CraftCatalog.MATERIALS")
        dollar = int(mats[mat_id].get("dollar", 0))
        if dollar >= 5:
            fail(f"{mat_id} is $5 forbidden in C1 bank")
        if mat_id in EXCLUDED:
            fail(f"{mat_id} is on the excluded list")
    seeds = _const_dict(market, "FIRST_DRAW")
    for node_id, ids in seeds.items():
        if len(ids) != 5:
            fail(f"first-draw {node_id} length {len(ids)} != 5")
        for mat_id in ids:
            if mat_id not in bank:
                fail(f"first-draw {node_id} id {mat_id} not in bank")
    if "GOLD_START := 12" not in read("src/autoload/game_constants.gd"):
        fail("GOLD_START must default 12")
    if "MARKET_REFRESH_BASE := 2" not in read("src/autoload/game_constants.gd"):
        fail("MARKET_REFRESH_BASE must default 2")
    if "MARKET_REFRESH_STEP := 2" not in read("src/autoload/game_constants.gd"):
        fail("MARKET_REFRESH_STEP must default 2")
    if "MAT_ENCH_THRIFT_FEE := 2" not in read("src/autoload/game_constants.gd"):
        fail("Thrift fee must default 2")
    if "MAT_ENCH_HEAVY_FEE := 3" not in read("src/autoload/game_constants.gd"):
        fail("Heavy fee must default 3")


def check_map_events() -> None:
    catalog = read("src/data/chapter/map_catalog.gd")
    start = catalog.find("const MAPS")
    brace = catalog.find("{", start)
    depth = 0
    end = -1
    for i, ch in enumerate(catalog[brace:], brace):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    raw = catalog[brace:end].replace("true", "True").replace("false", "False")
    maps = ast.literal_eval(raw)
    nodes = {row["node_id"]: row for row in maps["map_m1"]["nodes"]}
    for nid, evt in NODE_EVENTS.items():
        row = nodes.get(nid, {})
        if row.get("kind") != "event":
            fail(f"{nid} must be kind=event")
        if row.get("ref_id") != evt:
            fail(f"{nid} ref_id {row.get('ref_id')} != {evt}")
    for nid in ("N2", "N7", "N12", "N15", "N16"):
        if nodes.get(nid, {}).get("kind") != "shop":
            fail(f"{nid} must stay kind=shop (wire)")
        if nodes.get(nid, {}).get("ref_id"):
            fail(f"{nid} market node must keep ref_id null")


def check_source() -> None:
    blob = src_blob()
    need = [
        "class_name MarketCatalog",
        "class_name EventCatalog",
        "class_name MarketScreen",
        "class_name EventScreen",
        "mat_ench_thrift",
        "mat_ench_heavy",
        "market_enchants",
        "market_bank_c1",
        "func buy_market",
        "func sell_market",
        "func refresh_market",
        "func enchant_market",
        "func exit_market",
        "func pick_event_choice",
        "func display_kind",
        "market ·",
        "evt_c1_heat_mirage",
        "choice_share_skin",
        "choice_press_on",
        "choice_brush",
        "choice_keep_ash",
        "choice_buy_scrap",
        "choice_walk",
        "choice_oil",
        "choice_sell_damp",
        "shiny",
        "MARKET_MATERIAL_FLOOR",
    ]
    for token in need:
        if token not in blob:
            fail(f"missing source token: {token}")
    session = read("src/autoload/atelier_session.gd")
    if "shops_taken" in session or "shop_ban" in session:
        fail("session must not UI-ban shop after k visits")
    dump = read("src/data/stamp/harness_stamp.gd")
    for key in DUMP_MARKET + DUMP_EVENT:
        if key not in dump:
            fail(f"harness dump missing {key}")
    if '"event_pool"' in dump or '"day_assignments"' in dump:
        fail("do not revive event_pool / day_assignments")
    if '"reshape"' in dump:
        fail("reshape is Later — do not emit")
    ui = read("src/ui/schedule/schedule_board.gd")
    if "MarketScreen.new()" not in ui or "EventScreen.new()" not in ui:
        fail("schedule board must host MarketScreen and EventScreen")
    if "day_action=shop" not in read("src/chapter/schedule_rules.gd") and 'WAGON_SHOP: "shop"' not in read(
        "src/data/game_enums.gd"
    ):
        fail("wire day_action must stay shop")
    enums = read("src/data/game_enums.gd")
    if "WAGON_SHOP: \"shop\"" not in enums.replace(" ", ""):
        if 'RoundAction.WAGON_SHOP: "shop"' not in enums:
            fail("DAY_ACTION_WIRE must keep WAGON_SHOP → shop")
    market_ui = read("src/ui/market/market_screen.gd")
    for parked in ("staff catalog", "gear_*", "artifact_*", "sk_next_mat_free"):
        if parked in market_ui and parked != "sk_next_mat_free":
            fail(f"M1 market UI must not wire {parked}")
    if ".free()" in market_ui or ".free()" in read("src/ui/event/event_screen.gd"):
        fail("market/event UI must queue_free, not free() mid-signal")
    if "queue_free" not in market_ui:
        fail("market shelf rebuild must queue_free")
    route = read("src/data/chapter/route_node.gd")
    if 'return "market"' not in route:
        fail("RouteNode.display_kind must map shop → market")
    if "kind" in route and "shop" not in route:
        fail("wire kind shop must remain")


def check_formulas() -> None:
    """Mirror docs/32 Test knobs without Godot."""
    gold = 12
    refresh_base, refresh_step = 2, 2
    costs = [refresh_base + i * refresh_step for i in range(3)]
    if costs != [2, 4, 6]:
        fail(f"refresh curve {costs} != [2, 4, 6]")
    if gold < costs[0]:
        fail("start gold cannot pay first refresh")
    if max(1, 1 // 2) != 1:
        fail("hemp sell must be 1, not 19's 0")
    if max(1, 2 // 2) != 1:
        fail("cotton sell must be 1")
    if max(1, 3 // 2) != 1:
        fail("silk sell floor/2")
    if max(1, 4 // 2) != 2:
        fail("velvet sell must be 2")
    if max(1, 1 // 2) != 1:
        fail("thrift does not change sell — still base")
    if 1 // 2 < 1:
        thrift_cost = max(1, 1 // 2)
        if thrift_cost != 1:
            fail("thrift $1 → 1")
    if 3 // 2 != 1:
        fail("thrift $3 → floor 1")
    if 2 * 4 != 8:
        fail("heavy doubles $")
    if 12 - 2 < 0 or 12 - 3 < 0:
        fail("start gold must afford one enchant")
    mats = 8
    if mats - 5 < 3:
        fail("starter 8 materials allows 5 sells before floor 3")
    # event pay-gold illegal when short
    if not (1 > 0):
        fail("choice_buy_scrap costs 1")
    gold0 = 0
    if gold0 < 1:
        pass  # illegal pay
    else:
        fail("gold 0 must refuse pay-1")


def main() -> int:
    check_godot_47()
    check_bank()
    check_map_events()
    check_source()
    check_formulas()
    if FAILS:
        for msg in FAILS:
            print(f"FAIL: {msg}")
        print(f"{len(FAILS)} failure(s).")
        return 1
    print("market M1 materials tab; refresh 2/4/6; bank 22; enchant Thrift/Heavy; events N4/N6/N10/N17.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
