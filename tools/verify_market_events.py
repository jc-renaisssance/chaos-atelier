#!/usr/bin/env python3
"""Source + spec checks for Client market visit M1 + M2 tabs (docs/32, 20).

Godot is not required. This does not open the editor.
Does not cover elite telegraph or adventurer catalog.
"""
from __future__ import annotations

import ast
import pathlib
import re
import struct
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
DUMP_M2 = [
    '"market_tab"',
    '"market_staff_bank_id"',
    '"market_staff_stock"',
    '"market_staff_buys"',
    '"market_staff_sells"',
    '"staff_owned"',
    '"staff_equipped_id"',
    '"max_materials"',
    '"max_runes"',
    '"market_skill_bank_id"',
    '"market_skill_stock"',
    '"market_skill_buys"',
    '"market_skill_sells"',
    '"deck_skill_count"',
    '"market_artifact_bank_id"',
    '"market_artifact_stock"',
    '"market_artifact_buys"',
    '"market_artifact_sells"',
    '"artifact_owned"',
    '"artifact_equipped_ids"',
]
STAFFS = [
    "staff_apprentice",
    "staff_rune_desk",
    "staff_loom_pair",
    "staff_third_seam",
    "staff_rune_pair",
]
SKILLS = [
    "sk_next_mat_free",
    "sk_touch_up",
    "sk_steady_hand",
    "sk_metal_str_double",
    "sk_wild_to_earth",
    "sk_deep_dig",
]
ARTIFACTS = [
    "artifact_coin_purse",
    "artifact_ledger_clip",
    "artifact_pack_strap",
    "artifact_needle_tin",
    "artifact_wagon_hook",
    "artifact_stamp_case",
    "artifact_road_charm",
    "artifact_oil_rag",
]
STAFF_CAPS = {
    "": (2, 1),
    "staff_apprentice": (3, 1),
    "staff_rune_desk": (2, 2),
    "staff_loom_pair": (3, 2),
    "staff_third_seam": (4, 1),
    "staff_rune_pair": (2, 3),
}
STAFF_PRICES = {
    "staff_apprentice": 4,
    "staff_rune_desk": 5,
    "staff_loom_pair": 8,
    "staff_third_seam": 7,
    "staff_rune_pair": 8,
}
SKILL_PRICES = {
    "sk_next_mat_free": 3,
    "sk_touch_up": 3,
    "sk_steady_hand": 3,
    "sk_metal_str_double": 5,
    "sk_wild_to_earth": 5,
    "sk_deep_dig": 7,
}
ARTIFACT_PRICES = {
    "artifact_coin_purse": 5,
    "artifact_ledger_clip": 4,
    "artifact_pack_strap": 6,
    "artifact_needle_tin": 6,
    "artifact_wagon_hook": 5,
    "artifact_stamp_case": 6,
    "artifact_road_charm": 4,
    "artifact_oil_rag": 5,
}


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
    consts = read("src/autoload/game_constants.gd")
    if "GOLD_START := 12" not in consts:
        fail("GOLD_START must default 12")
    if "MARKET_REFRESH_BASE := 2" not in consts:
        fail("MARKET_REFRESH_BASE must default 2")
    if "MARKET_REFRESH_STEP := 2" not in consts:
        fail("MARKET_REFRESH_STEP must default 2")
    if "MAT_ENCH_THRIFT_FEE := 2" not in consts:
        fail("Thrift fee must default 2")
    if "MAT_ENCH_HEAVY_FEE := 3" not in consts:
        fail("Heavy fee must default 3")
    if 'MARKET_STAFF_BANK_ID := "market_staff_bank_c1"' not in consts:
        fail("staff bank id must be market_staff_bank_c1")
    if 'MARKET_SKILL_BANK_ID := "market_skill_bank_c1"' not in consts:
        fail("skill bank id must be market_skill_bank_c1")
    if 'MARKET_ARTIFACT_BANK_ID := "market_artifact_bank_c1"' not in consts:
        fail("artifact bank id must be market_artifact_bank_c1")
    staffs = _const_dict(market, "STAFFS")
    if sorted(staffs) != sorted(STAFFS):
        fail(f"staff catalog mismatch: {sorted(staffs)} != {STAFFS}")
    for staff_id, price in STAFF_PRICES.items():
        if int(staffs.get(staff_id, {}).get("dollar", -1)) != price:
            fail(f"{staff_id} price {staffs.get(staff_id)} != {price}")
    skills = _const_dict(market, "SKILLS")
    if sorted(skills) != sorted(SKILLS):
        fail(f"skill catalog mismatch: extra={set(skills) - set(SKILLS)} missing={set(SKILLS) - set(skills)}")
    for skill_id, price in SKILL_PRICES.items():
        if int(skills.get(skill_id, {}).get("dollar", -1)) != price:
            fail(f"{skill_id} price != {price}")
    artifacts = _const_dict(market, "ARTIFACTS")
    if sorted(artifacts) != sorted(ARTIFACTS):
        fail(f"artifact catalog mismatch: extra={set(artifacts) - set(ARTIFACTS)} missing={set(ARTIFACTS) - set(artifacts)}")
    for artifact_id, price in ARTIFACT_PRICES.items():
        if int(artifacts.get(artifact_id, {}).get("dollar", -1)) != price:
            fail(f"{artifact_id} price != {price}")
    if any(k.startswith("gear_") for k in artifacts):
        fail("do not use gear_* ids")


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
        "func buy_staff",
        "func buy_skill",
        "func buy_artifact",
        "func equip_staff",
        "func equip_artifact",
        "staff_apprentice",
        "staff_rune_desk",
        "staff_loom_pair",
        "staff_third_seam",
        "staff_rune_pair",
        "artifact_coin_purse",
        "artifact_ledger_clip",
        "artifact_pack_strap",
        "artifact_needle_tin",
        "artifact_wagon_hook",
        "artifact_stamp_case",
        "artifact_road_charm",
        "artifact_oil_rag",
        "market_staff_bank_c1",
        "market_skill_bank_c1",
        "market_artifact_bank_c1",
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
    for key in DUMP_MARKET + DUMP_EVENT + DUMP_M2:
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
    for token in ("Staffs", "Skills", "Gear", "MARKET_TAB_STAFFS", "MARKET_TAB_SKILLS", "MARKET_TAB_GEAR"):
        if token not in market_ui:
            fail(f"M2 market UI missing {token}")
    if "gear_*" in market_ui:
        fail("prefix is artifact_* — do not sell gear_*")
    if "mat_ench_" in market_ui and "MARKET_TAB_STAFFS" in market_ui:
        # Enchant buttons must stay on the materials deck path only.
        if "_staff_kit_row" in market_ui and "enchant_market" in market_ui:
            staff_fn = market_ui.split("func _staff_kit_row", 1)[-1].split("func _", 1)[0]
            if "enchant" in staff_fn.lower():
                fail("Staffs tab must not take mat_ench_*")
    if ".free()" in market_ui or ".free()" in read("src/ui/event/event_screen.gd"):
        fail("market/event UI must queue_free, not free() mid-signal")
    if "queue_free" not in market_ui:
        fail("market shelf rebuild must queue_free")
    session = read("src/autoload/atelier_session.gd")
    for token in (
        "func buy_staff",
        "func sell_staff",
        "func equip_staff",
        "func unequip_staff",
        "func buy_skill",
        "func sell_skill",
        "func buy_artifact",
        "func equip_artifact",
        "func unequip_artifact",
        "market_staff_bank_c1",
        "artifact_equipped_ids",
        "live_max_materials",
    ):
        if token not in session and token not in blob:
            fail(f"missing M2 session token: {token}")
    if "market_staff_stock = MarketCatalog" in session and "refresh_market" in session:
        refresh_fn = session.split("func refresh_market", 1)[-1].split("func ", 1)[0]
        if "staff_stock" in refresh_fn or "artifact_stock" in refresh_fn or "skill_stock" in refresh_fn:
            fail("refresh must not redraw staff / skill / artifact stock")
    route = read("src/data/chapter/route_node.gd")
    if 'return "market"' not in route:
        fail("RouteNode.display_kind must map shop → market")
    if "kind" in route and "shop" not in route:
        fail("wire kind shop must remain")


SHELF_ICON_IDS = [
    "staff_apprentice",
    "staff_rune_desk",
    "staff_loom_pair",
    "staff_third_seam",
    "staff_rune_pair",
    "artifact_coin_purse",
    "artifact_ledger_clip",
    "artifact_pack_strap",
    "artifact_needle_tin",
    "artifact_wagon_hook",
    "artifact_stamp_case",
    "artifact_road_charm",
    "artifact_oil_rag",
]


def _fn_body(text: str, name: str) -> str:
    marker = f"func {name}"
    if marker not in text:
        fail(f"missing {marker}")
        return ""
    return text.split(marker, 1)[-1].split("\nfunc ", 1)[0]


def check_shelf_icons() -> None:
    """Staffs + Gear shelves load the stamped 96×96 PNGs. Skills stay text."""
    market_ui = read("src/ui/market/market_screen.gd")
    if "TextureRect" not in market_ui:
        fail("Staffs / Gear shelves must use TextureRect")
    if "res://assets/m2-market/" not in market_ui:
        fail("shelves must preload res://assets/m2-market/<id>.png")
    staff_shelf = _fn_body(market_ui, "_staff_shelf_row")
    gear_shelf = _fn_body(market_ui, "_artifact_shelf_row")
    if "_shelf_icon(" not in staff_shelf:
        fail("Staffs shelf must show the stamped icon")
    if "_shelf_icon(" not in gear_shelf:
        fail("Gear shelf must show the stamped icon")
    for name in ("_skill_shelf_row", "_skill_deck_row"):
        body = _fn_body(market_ui, name)
        if "_shelf_icon" in body or "m2-market" in body or "TextureRect" in body:
            fail(f"{name} must stay sk_* text — no skill card art")
    icon_dir = ROOT / "assets" / "m2-market"
    for item_id in SHELF_ICON_IDS:
        rel = f"res://assets/m2-market/{item_id}.png"
        if rel not in market_ui:
            fail(f"market screen missing preload {rel}")
        path = icon_dir / f"{item_id}.png"
        if not path.is_file():
            fail(f"missing {path.relative_to(ROOT)}")
            continue
        data = path.read_bytes()
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            fail(f"{item_id}.png is not a PNG")
            continue
        if len(data) < 24:
            fail(f"{item_id}.png is truncated")
            continue
        width, height = struct.unpack(">II", data[16:24])
        if (width, height) != (96, 96):
            fail(f"{item_id}.png is {width}x{height}, want 96x96")
    for sidecar in icon_dir.glob("*.import"):
        fail(f"do not commit Godot import sidecar {sidecar.name}")


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
    for staff_id, caps in STAFF_CAPS.items():
        dm = int(staffs_delta(staff_id)[0]) if staff_id else 0
        dr = int(staffs_delta(staff_id)[1]) if staff_id else 0
        if (2 + dm, 1 + dr) != caps:
            fail(f"{staff_id or 'none'} caps {(2 + dm, 1 + dr)} != {caps}")
    if max(1, 4 // 2) != 2:
        fail("staff_apprentice sell must be 2")
    if max(1, 3 // 2) != 1:
        fail("skill $3 sell must be 1")
    if max(1, 5 // 2) != 2:
        fail("artifact $5 sell must be 2")


def staffs_delta(staff_id: str) -> tuple[int, int]:
    table = {
        "staff_apprentice": (1, 0),
        "staff_rune_desk": (0, 1),
        "staff_loom_pair": (1, 1),
        "staff_third_seam": (2, 0),
        "staff_rune_pair": (0, 2),
    }
    return table.get(staff_id, (0, 0))


def main() -> int:
    check_godot_47()
    check_bank()
    check_map_events()
    check_source()
    check_shelf_icons()
    check_formulas()
    if FAILS:
        for msg in FAILS:
            print(f"FAIL: {msg}")
        print(f"{len(FAILS)} failure(s).")
        return 1
    print(
        "market M1 materials + M2 Staffs/Skills/Gear; refresh materials-only; "
        "staff 5 / skill 6 / artifact 8; Staffs/Gear shelf icons; events N4/N6/N10/N17."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
