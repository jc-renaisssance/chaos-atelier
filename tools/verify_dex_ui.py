#!/usr/bin/env python3
"""Source + spec checks for Client PR 4 — ugly Dex list UI (docs/31).

Godot is not required. This does not open the editor.
UI-only: reads unlocked_builds / dex_crafts / dex_adventurers / dex_enemies.
Does not cover unlock write law, planner/estimate ? gates, art, or slice 4.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

TABS = ["Builds", "Crafts", "Adventurers", "Enemies"]
BOSSES = [
    "boss_ash_drake",
    "boss_salt_widow",
    "boss_rust_knave",
    "boss_mire_bride",
    "boss_bog_king",
    "boss_pale_choir",
    "boss_gilded_warden",
    "boss_ivory_judge",
    "boss_sunspear_captain",
]
PEOPLE = [
    "adv_halden_rook",
    "adv_vex_bramble",
    "adv_solenne_ward",
    "adv_quill_lumen",
    "adv_neri_paleink",
    "adv_marrowveil",
    "adv_kite_thornreel",
    "adv_mask_circlet",
    "adv_whisper_hem",
    "adv_tide_glass",
    "adv_brine_latch",
    "adv_rime_peddler",
]
MONOSTACK = [
    "Fire",
    "Frost",
    "Storm",
    "Earth",
    "Lunar",
    "Solar",
    "Royal",
    "Silent",
    "Sticky",
    "Sharp",
    "Soft",
    "Wild",
    "Occult",
    "Pure",
    "Metal",
    "Silk",
]
MONO_TIERS = ["low", "mid", "apex"]
CROSS = [
    ("temper", "Fire", "Frost", "Temper"),
    ("beastbloom", "Wild", "Earth", "Beastbloom"),
    ("snaretooth", "Sticky", "Sharp", "Snaretooth"),
    ("masked_crown", "Royal", "Silent", "Masked Crown"),
    ("dawn", "Solar", "Pure", "Dawn"),
    ("pale_hex", "Lunar", "Occult", "Pale Hex"),
]
WRITE_TOKENS = [
    "apply_finish",
    "note_adventurer_order",
    "complete_adventurer_order",
    "note_enemy_seen",
    "note_enemy_brief",
    "note_enemy_fought",
    "note_shop_brief",
    "note_new_run",
    "save_to_disk",
    "unlocked_builds.append",
    "dex_crafts.append",
    "dex_adventurers.append",
    "dex_enemies.append",
]


def fail(msg: str) -> None:
    FAILS.append(msg)


def read(rel: str) -> str:
    return (SRC / rel).read_text(encoding="utf-8")


def src_blob() -> str:
    parts: list[str] = []
    for path in SRC.rglob("*"):
        if path.suffix in {".gd", ".tscn", ".tres", ".godot"}:
            parts.append(path.read_text(encoding="utf-8"))
    parts.append((ROOT / "project.godot").read_text(encoding="utf-8"))
    return "\n".join(parts)


def title_of(outlook_id: str) -> str:
    for tag in MONOSTACK:
        if tag.lower() == outlook_id:
            return tag
    return outlook_id.capitalize()


def list_build_lines(unlocked: list[dict]) -> list[str]:
    lines: list[str] = []
    unknown_n = 0
    owned = {(row["outlook_id"], row["tier"]) for row in unlocked}
    families = {row["outlook_id"] for row in unlocked}
    for tag in MONOSTACK:
        slug = tag.lower()
        if slug not in families:
            unknown_n += 1
            continue
        missing = False
        for tier in MONO_TIERS:
            if (slug, tier) in owned:
                lines.append(f"{tag} {tier}")
            else:
                missing = True
        if missing:
            lines.append(f"{tag} ?")
    for slug, _a, _b, display in CROSS:
        if (slug, "cross") in owned:
            lines.append(display)
        else:
            unknown_n += 1
    if not lines:
        return ["?"]
    lines.extend(["?"] * unknown_n)
    return lines


def craft_line(row: dict) -> str:
    name = {"con_armor": "Armor", "con_tunic": "Tunic"}.get(row["construction_id"], row["construction_id"])
    outlook = title_of(row["outlook_id"])
    return f"{name}  ·  {outlook} {row['tier']}  ·  day {row['first_day']}  ·  {row['first_run_id']}"


def adventurer_lines(rows: list[dict]) -> list[str]:
    by_id = {row["adventurer_id"]: row for row in rows}
    out: list[str] = []
    for adv_id in PEOPLE:
        row = by_id.get(adv_id, {})
        if not row or not row.get("met"):
            out.append("?")
            continue
        out.append(
            f"{adv_id}  ·  received {row.get('orders_received', 0)}  ·  completed {row.get('orders_completed', 0)}"
        )
    return out


def enemy_line(threat_id: str, row: dict | None, names: dict[str, str]) -> str:
    row = row or {}
    seen = bool(row.get("seen", False))
    fought = bool(row.get("fought", False))
    if not seen and not fought:
        return "?"
    name = names[threat_id]
    favor = "?"
    punish = "?"
    if fought:
        favor = "Metal"
        punish = "Soft"
    return (
        f"{name}  ·  briefs {int(row.get('briefs_seen', 0))}  ·  fights {int(row.get('fights', 0))}"
        f"  ·  favor {favor}  ·  punish {punish}"
    )


def check_source() -> None:
    dex = read("ui/dex/dex_screen.gd")
    board = read("ui/schedule/schedule_board.gd")
    profile = read("data/profile/profile_meta.gd")
    session = read("autoload/atelier_session.gd")
    planner = read("data/synergy/planner_catalog.gd")
    adventurers = read("data/catalog/adventurer_catalog.gd")
    threats = read("data/catalog/threat_catalog.gd")
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    blob = src_blob()
    tscn = (SRC / "ui/dex/dex_screen.tscn").read_text(encoding="utf-8")

    if "class_name DexScreen" not in dex:
        fail("DexScreen class missing")
    if "DexScreen.new()" not in board:
        fail("schedule board (shop / menu) must host DexScreen")
    if '_btn("Dex"' not in board and 'btn("Dex"' not in board:
        fail("shop / menu must have one Dex button")
    if "open_screen" not in dex or "open_screen" not in board:
        fail("Dex must refresh on open")
    if "load_from_disk" not in dex.split("func open_screen", 1)[-1] and "load_from_disk" not in dex.split(
        "func refresh", 1
    )[-1][:400]:
        fail("Dex refresh on open must reload the persisted profile")
    if "Builds | Crafts | Adventurers | Enemies" not in dex:
        fail("tab strip must be Builds | Crafts | Adventurers | Enemies")
    for tab in TABS:
        if f'"{tab}"' not in dex:
            fail(f"Dex missing tab {tab}")
    if "const TABS := [" not in dex:
        fail("TABS must be an array-literal const (Godot 4.7)")
    if "ItemList" not in dex:
        fail("Dex must use a scroll list (ItemList) — keep it ugly")
    if "TextureRect" in dex or "TextureRect" in tscn:
        fail("Dex must not use TextureRect / portraits")
    if "Fashion Encyclopedia" in dex or "Fashion Encyclopedia" in board:
        fail("Fashion Encyclopedia chrome is M2 — not this PR")
    if "profile.unlocked_builds" not in dex or "PlannerCatalog.list_lines" not in dex:
        fail("Builds tab must list unlocked_builds via PlannerCatalog.list_lines")
    if "profile.dex_crafts" not in dex:
        fail("Crafts tab must read dex_crafts")
    if "profile.dex_adventurers" not in dex:
        fail("Adventurers tab must read dex_adventurers")
    if "profile.dex_enemies" not in dex:
        fail("Enemies tab must read dex_enemies")
    if "all_named_ids" not in dex:
        fail("Adventurers tab must walk the 12 named slots (all_named_ids)")
    if "ThreatCatalog.BOSSES" not in dex:
        fail("Enemies tab must list M1 boss_* from ThreatCatalog")
    if "display_name" not in dex or "environment" not in dex:
        fail("Enemies tab must show name + environment when seen")
    if "favor_tags" not in dex or "punish_tags" not in dex:
        fail("Enemies tab must show favor / punish when fought")
    if "begins_with(\"appt_\")" not in dex and "appt_" not in dex:
        fail("Adventurers tab must refuse appt_* / Scrap Duelist")
    if re.search(r"\bdex_builds\b", dex) or re.search(r"\bdex_builds\b", board):
        fail("parallel dex_builds field must not exist — Builds reads unlocked_builds")
    for token in WRITE_TOKENS:
        if token in dex:
            fail(f"Dex UI must not write ({token})")
    if "apply_finish" not in session or "unlocked_builds" not in profile:
        fail("write paths stay on the profile / session — Dex is UI-only")
    if "list_lines" not in planner:
        fail("PlannerCatalog.list_lines missing — Builds has nothing to reuse")
    if "all_named_ids" not in adventurers:
        fail("AdventurerCatalog.all_named_ids missing")
    named = adventurers.split("const PEOPLE :=", 1)[-1].split("static func resolve_id", 1)[0]
    for adv_id in PEOPLE:
        if f'"{adv_id}"' not in named:
            fail(f"catalog missing named adventurer {adv_id}")
    if named.count("adv_") < 12:
        fail("M1 Adventurers tab expects 12 named people")
    for boss_id in BOSSES:
        if f'"{boss_id}"' not in threats:
            fail(f"ThreatCatalog missing M1 boss {boss_id}")
    adv_fn = dex.split("func _adventurer_lines", 1)[-1].split("func _enemy_lines", 1)[0]
    if "UNKNOWN" not in adv_fn and '"?"' not in adv_fn:
        fail("unmet adventurers must render as ?")
    if "display_name" in adv_fn.split("not bool(row.get(\"met\"", 1)[0] and "AdventurerCatalog.display_name" in adv_fn.split(
        "not bool(row.get(\"met\"", 1
    )[0]:
        fail("do not spoiler unmet adventurer names")
    enemy_fn = dex.split("func _enemy_line", 1)[-1].split("func _adventurer_row", 1)[0]
    if "not seen and not fought" not in enemy_fn and "seen" not in enemy_fn:
        fail("unseen enemies must render as ?")
    if "if fought:" not in enemy_fn and "fought" not in enemy_fn:
        fail("favor / punish must wait on fought")
    if "res://src/ui/dex/dex_screen.gd" not in tscn:
        fail("dex_screen.tscn must attach DexScreen")
    if 'PackedStringArray("4.7"' not in project:
        fail("project.godot config/features must list 4.7")
    if "4.3" in project:
        fail("project.godot still mentions 4.3")
    if re.search(r"^class_name AtelierSession\b", blob, re.M):
        fail("class_name AtelierSession would hide the autoload")
    if re.search(r"^class_name GameConstants\b", blob, re.M):
        fail("class_name GameConstants hides the autoload")
    if re.search(r"Color\.html\s*\(", blob):
        fail("Color.html(...) is not a constant expression in Godot 4.7")
    if re.search(r":=\s*[^\n]*\belse\s+null\b", blob):
        fail(":= … else null infers Variant — Godot 4.7.2 warning-as-error")
    check_variant_infer()
    gd_only = "\n".join(path.read_text(encoding="utf-8") for path in SRC.rglob("*.gd"))
    if re.search(r"const\s+\w+\s*:?=?\s*Packed\w*Array\s*\(", gd_only):
        fail("const Packed*Array(...) is not a constant expression in Godot 4.7 — use array literals")
    for path in SRC.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        if text.count("{") != text.count("}"):
            fail(f"unbalanced {{}} in {path.relative_to(ROOT)}")
        if text.count("(") != text.count(")"):
            fail(f"unbalanced () in {path.relative_to(ROOT)}")
        for i, line in enumerate(text.splitlines(), 1):
            if line.startswith("    ") and not line.startswith("\t"):
                fail(f"space indent {path.relative_to(ROOT)}:{i}")
                break


def variant_returning_funcs() -> set[str]:
    names: set[str] = set()
    for path in SRC.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        for match in re.finditer(r"func\s+(\w+)\s*\([^)]*\)\s*->\s*Variant", text):
            names.add(match.group(1))
    return names


def check_variant_infer() -> None:
    names = variant_returning_funcs()
    if not names:
        return
    joined = "|".join(re.escape(name) for name in sorted(names, key=len, reverse=True))
    pattern = re.compile(rf"^\s*var\s+\w+\s+:=\s*.*\b({joined})\s*\(")
    for path in SRC.rglob("*.gd"):
        rel = path.relative_to(ROOT)
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if pattern.search(line):
                fail(
                    f"{rel}:{i} var x := …() infers Variant — Godot 4.7.2 warning-as-error "
                    "(use var x: Variant = …)"
                )


def check_spec() -> None:
    fresh_builds = list_build_lines([])
    if fresh_builds != ["?"]:
        fail(f"fresh Builds tab must be only ?, got {fresh_builds}")
    metal_low = list_build_lines([{"outlook_id": "metal", "tier": "low"}])
    if "Metal low" not in metal_low or "Metal ?" not in metal_low:
        fail(f"known family missing tiers should show Metal ?, got {metal_low}")
    if any(line.startswith("Storm ") and not line.startswith("Storm ?") for line in metal_low):
        fail("unknown Build families must not spoiler names")

    if craft_line(
        {
            "construction_id": "con_armor",
            "outlook_id": "metal",
            "tier": "mid",
            "first_day": 1,
            "first_run_id": "run_a",
        }
    ) != "Armor  ·  Metal mid  ·  day 1  ·  run_a":
        fail("Crafts row must be construction + outlook/tier + first_day / run id")
    if not list_build_lines([]) == ["?"]:
        fail("fresh Crafts / Builds empty → ?")

    fresh_adv = adventurer_lines([])
    if fresh_adv != ["?"] * 12:
        fail(f"fresh Adventurers must be 12 unknown slots, got {fresh_adv}")
    if any(name.lstrip("?") and "Halden" in name for name in fresh_adv):
        fail("fresh Adventurers must not spoiler names")
    met = adventurer_lines(
        [{"adventurer_id": "adv_halden_rook", "met": True, "orders_received": 1, "orders_completed": 0}]
    )
    if not any("received 1" in line and "completed 0" in line for line in met):
        fail("met adventurer must show received / completed")
    if met.count("?") != 11:
        fail(f"unmet adventurer slots stay ?, got {met}")
    appt = adventurer_lines(
        [{"adventurer_id": "appt_c1_scrap_duelist", "met": True, "orders_received": 1, "orders_completed": 0}]
    )
    if any("scrap" in line.lower() or "duelist" in line.lower() for line in appt):
        fail("Scrap Duelist / appt_* must not appear on the Adventurers tab")

    names = {
        "boss_ash_drake": "Ash Drake",
        "boss_gilded_warden": "Gilded Warden",
    }
    unseen = enemy_line("boss_ash_drake", {}, names)
    if unseen != "?":
        fail(f"never-seen enemy must be ?, got {unseen}")
    if "Ash Drake" in unseen:
        fail("do not spoiler never-seen enemy names")
    seen = enemy_line(
        "boss_ash_drake",
        {"seen": True, "fought": False, "briefs_seen": 1, "fights": 0},
        names,
    )
    if "Ash Drake" not in seen or "briefs 1" not in seen:
        fail(f"seen enemy must show name + counts, got {seen}")
    if "favor Metal" in seen or "punish Soft" in seen:
        fail(f"favor / punish stay ? until fought, got {seen}")
    if "favor ?" not in seen or "punish ?" not in seen:
        fail(f"seen-not-fought tags must be ?, got {seen}")
    fought = enemy_line(
        "boss_gilded_warden",
        {"seen": True, "fought": True, "briefs_seen": 1, "fights": 1},
        names,
    )
    if "Gilded Warden" not in fought or "favor Metal" not in fought or "punish Soft" not in fought:
        fail(f"fought enemy may reveal tags, got {fought}")

    boss_names = {boss_id: boss_id for boss_id in BOSSES}
    boss_names["boss_ash_drake"] = "Ash Drake"
    empty_enemies = [enemy_line(boss_id, {}, boss_names) for boss_id in BOSSES]
    if empty_enemies != ["?"] * 9:
        fail(f"fresh Enemies must be 9 × ?, got {empty_enemies}")
    if any(
        boss_id.replace("boss_", "").replace("_", " ") in line.lower() and line != "?"
        for boss_id, line in zip(BOSSES, empty_enemies)
    ):
        fail("fresh Enemies must not spoiler names")


def main() -> int:
    check_source()
    check_spec()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK ugly Dex list UI (docs/31)")
    print("Four tabs from shop/menu. Reads unlocked_builds + three Dex lists. No write paths.")
    print("Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
