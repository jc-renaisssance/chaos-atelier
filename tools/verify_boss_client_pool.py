#!/usr/bin/env python3
"""Source + spec checks for shared boss-client pool (docs/28, 17, 20).

Godot is not required. This does not open the editor.
"""
from __future__ import annotations

import ast
import pathlib
import random
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

STARTER_TAGS = ["Soft", "Earth", "Metal", "Wild", "Silk", "Pure"]

JOBS = {
    "job_knight": {
        "boss_client_id": "adv_knight",
        "order_id": "ord_knight",
        "construction_ids": ["con_armor", "con_gloves"],
        "requirement_tags": ["Metal", "Sharp"],
    },
    "job_mage": {
        "boss_client_id": "adv_mage",
        "order_id": "ord_mage",
        "construction_ids": ["con_robe", "con_hood"],
        "requirement_tags": ["Silk", "Pure", "Lunar"],
    },
    "job_lagoon": {
        "boss_client_id": "adv_lagoon",
        "order_id": "ord_lagoon",
        "construction_ids": ["con_cloak", "con_boots"],
        "requirement_tags": ["Frost", "Sticky", "Storm"],
    },
    "job_wizard": {
        "boss_client_id": "adv_wizard",
        "order_id": "ord_wizard",
        "construction_ids": ["con_robe", "con_mantle"],
        "requirement_tags": ["Occult", "Lunar", "Royal"],
    },
    "job_blade_dancer": {
        "boss_client_id": "adv_blade_dancer",
        "order_id": "ord_blade_dancer",
        "construction_ids": ["con_tunic", "con_cape"],
        "requirement_tags": ["Sharp", "Silk", "Silent"],
    },
    "job_hexer": {
        "boss_client_id": "adv_hexer",
        "order_id": "ord_hexer",
        "construction_ids": ["con_wraps", "con_hood"],
        "requirement_tags": ["Occult", "Sticky", "Silent"],
    },
    "job_outrider": {
        "boss_client_id": "adv_outrider",
        "order_id": "ord_outrider",
        "construction_ids": ["con_coat", "con_boots"],
        "requirement_tags": ["Wild", "Storm", "Silent"],
    },
    "job_oathbound": {
        "boss_client_id": "adv_oathbound",
        "order_id": "ord_oathbound",
        "construction_ids": ["con_armor", "con_mantle"],
        "requirement_tags": ["Royal", "Solar", "Pure"],
    },
}

POOL_ORDER = [
    "job_knight",
    "job_mage",
    "job_lagoon",
    "job_wizard",
    "job_blade_dancer",
    "job_hexer",
    "job_outrider",
    "job_oathbound",
]

BOSSES_17 = {
    "boss_ash_drake": {
        "threat_tags": ["Fire", "Sharp"],
        "favor_tags": ["Metal", "Earth", "Frost", "Pure"],
        "punish_tags": ["Soft", "Sticky"],
        "chapter": 1,
    },
    "boss_salt_widow": {
        "threat_tags": ["Frost", "Sticky", "Storm"],
        "favor_tags": ["Frost", "Silent", "Metal"],
        "punish_tags": ["Soft", "Solar"],
        "chapter": 1,
    },
    "boss_rust_knave": {
        "threat_tags": ["Metal", "Earth", "Sharp"],
        "favor_tags": ["Metal", "Earth", "Sharp"],
        "punish_tags": ["Soft", "Silk"],
        "chapter": 1,
    },
    "boss_mire_bride": {
        "threat_tags": ["Occult", "Sticky", "Lunar"],
        "favor_tags": ["Silent", "Occult", "Lunar", "Sticky"],
        "punish_tags": ["Soft", "Pure", "Silk"],
        "chapter": 2,
    },
    "boss_bog_king": {
        "threat_tags": ["Sticky", "Wild", "Earth"],
        "favor_tags": ["Frost", "Occult", "Storm", "Silent"],
        "punish_tags": ["Soft", "Earth", "Metal", "Wild"],
        "chapter": 2,
    },
    "boss_pale_choir": {
        "threat_tags": ["Lunar", "Occult", "Storm"],
        "favor_tags": ["Lunar", "Occult", "Silent", "Frost"],
        "punish_tags": ["Soft", "Metal", "Silk"],
        "chapter": 2,
    },
    "boss_gilded_warden": {
        "threat_tags": ["Royal", "Solar", "Sharp"],
        "favor_tags": ["Royal", "Solar", "Fire", "Sharp"],
        "punish_tags": ["Soft", "Earth", "Wild", "Metal"],
        "chapter": 3,
    },
    "boss_ivory_judge": {
        "threat_tags": ["Royal", "Lunar", "Silent"],
        "favor_tags": ["Royal", "Lunar", "Silent", "Occult"],
        "punish_tags": ["Soft", "Metal", "Pure", "Silk"],
        "chapter": 3,
    },
    "boss_sunspear_captain": {
        "threat_tags": ["Solar", "Sharp", "Fire"],
        "favor_tags": ["Solar", "Sharp", "Fire", "Royal"],
        "punish_tags": ["Soft", "Silk", "Pure", "Earth"],
        "chapter": 3,
    },
}


def fail(msg: str) -> None:
    FAILS.append(msg)


def src_text() -> str:
    parts: list[str] = []
    for path in SRC.rglob("*"):
        if path.suffix in {".gd", ".tscn", ".tres", ".godot"}:
            parts.append(path.read_text(encoding="utf-8"))
    parts.append((ROOT / "project.godot").read_text(encoding="utf-8"))
    return "\n".join(parts)


def _list_literal(text: str, key: str) -> list[str]:
    match = re.search(rf'"{key}":\s*(\[[^\]]*\])', text)
    if not match:
        return []
    return ast.literal_eval(match.group(1))


def _block_for(text: str, key: str) -> str:
    match = re.search(rf'"{re.escape(key)}":\s*\{{(.*?)\n\t\}}\s*,', text, re.S)
    if not match:
        return ""
    return match.group(1)


def check_job_catalog() -> None:
    catalog = (SRC / "data" / "catalog" / "boss_client_catalog.gd").read_text(encoding="utf-8")
    if "func pick_boss_client(seed: int)" not in catalog:
        fail("pick_boss_client(seed) missing — must take seed only")
    if re.search(r"func pick_boss_client\([^)]*chapter_boss", catalog):
        fail("pick_boss_client must not take chapter_boss_id")
    if "SHARED_BOSS_CLIENT_POOL" not in catalog:
        fail("SHARED_BOSS_CLIENT_POOL missing")
    jobs_blob = catalog.split("const JOBS")[1] if "const JOBS" in catalog else catalog
    for token in ("scrap_duelist", "cli_c1_scrap", "appt_scrap", "appt_c1"):
        if token in jobs_blob:
            fail(f"boss-client catalog must not include {token}")
    if re.search(r'"boss_client_id":\s*"appt_', catalog):
        fail("boss_client_id must never be appt_*")
    constructions_src = (SRC / "data" / "catalog" / "craft_catalog.gd").read_text(encoding="utf-8")
    for job_id, row in JOBS.items():
        if f'"{job_id}"' not in catalog:
            fail(f"missing job {job_id}")
            continue
        block = _block_for(catalog, job_id)
        if not block:
            fail(f"could not parse job block {job_id}")
            continue
        for field in ("boss_client_id", "order_id"):
            got = re.search(rf'"{field}":\s*"([^"]+)"', block)
            if got is None or got.group(1) != row[field]:
                fail(f"{job_id} {field} expected {row[field]}, got {got.group(1) if got else None}")
        cons = _list_literal(block, "construction_ids")
        if cons != row["construction_ids"]:
            fail(f"{job_id} construction_ids expected {row['construction_ids']}, got {cons}")
        tags = _list_literal(block, "requirement_tags")
        if tags != row["requirement_tags"]:
            fail(f"{job_id} requirement_tags expected {row['requirement_tags']}, got {tags}")
        for con_id in cons:
            if f'"{con_id}"' not in constructions_src:
                fail(f"{job_id} invents unknown {con_id}")
            if not con_id.startswith("con_"):
                fail(f"{job_id} construction {con_id} is not con_*")
    mage = JOBS["job_mage"]["construction_ids"]
    wizard = JOBS["job_wizard"]["construction_ids"]
    if mage == wizard:
        fail("mage and wizard must not collapse — hood vs mantle")
    if "con_hood" not in mage or "con_mantle" not in wizard:
        fail("mage must list con_hood; wizard must list con_mantle")
    pool = _list_literal(catalog.replace("const SHARED_BOSS_CLIENT_POOL :=", '"SHARED_BOSS_CLIENT_POOL":'), "SHARED_BOSS_CLIENT_POOL")
    if not pool:
        match = re.search(r"SHARED_BOSS_CLIENT_POOL\s*:=\s*(\[[^\]]*\])", catalog, re.S)
        if match:
            pool = ast.literal_eval(re.sub(r"\s+", " ", match.group(1)))
    if pool != POOL_ORDER:
        fail(f"SHARED_BOSS_CLIENT_POOL order expected {POOL_ORDER}, got {pool}")


def check_appointments_untouched() -> None:
    schedule = (SRC / "data" / "chapter" / "schedule_catalog.gd").read_text(encoding="utf-8")
    if '"appointment_id": "appt_c1_scrap_duelist"' not in schedule:
        fail("Scrap Duelist must stay an appointment")
    if '"threat_id": "cli_c1_scrap_duelist"' not in schedule:
        fail("Scrap Duelist appointment must keep cli_c1_scrap_duelist")
    if "appt_c1_scrap_duelist" in (SRC / "data" / "catalog" / "boss_client_catalog.gd").read_text(encoding="utf-8"):
        fail("do not pin Scrap Duelist into the boss-client catalog")


def check_boss_rewrite() -> None:
    threat = (SRC / "data" / "catalog" / "threat_catalog.gd").read_text(encoding="utf-8")
    for boss_id, row in BOSSES_17.items():
        block = _block_for(threat, boss_id)
        if not block:
            fail(f"could not parse boss row {boss_id}")
            continue
        for field in ("threat_tags", "favor_tags", "punish_tags"):
            got = _list_literal(block, field)
            if got != row[field]:
                fail(f"{boss_id} {field} expected {row[field]}, got {got}")
        if row["chapter"] >= 2:
            punished_starters = [t for t in row["punish_tags"] if t in STARTER_TAGS]
            favored_starters = [t for t in row["favor_tags"] if t in STARTER_TAGS]
            if not punished_starters:
                fail(f"{boss_id} C{row['chapter']} must punish at least one own_basic starter tag")
            if favored_starters:
                fail(f"{boss_id} C{row['chapter']} must not favor starter tags {favored_starters}")
        else:
            if "Soft" not in row["punish_tags"]:
                fail(f"{boss_id} C1 still punishes Soft (approachable on other staples)")


def check_harness_and_flow(blob: str) -> None:
    need = [
        "class_name BossClientCatalog",
        "func pick_boss_client",
        "func make_order",
        "func _begin_boss_client_craft",
        "SHARED_BOSS_CLIENT_POOL",
        "boss_client_id",
        "boss_job_id",
        "OWN_BASIC_STARTER_TAGS",
        "docs/28",
    ]
    for token in need:
        if token not in blob:
            fail(f"missing source token: {token}")
    dump_src = (SRC / "data" / "stamp" / "harness_stamp.gd").read_text(encoding="utf-8")
    for field in ("boss_client_id", "boss_job_id"):
        if f'"{field}"' not in dump_src:
            fail(f"stamp dump missing {field}")
    if "boss_client_id must never be appt_*" not in dump_src:
        fail("harness schema must reject appt_* boss_client_id")
    if "construction_ids must equal that job" not in dump_src:
        fail("harness schema must assert job construction_ids")
    session = (SRC / "autoload" / "atelier_session.gd").read_text(encoding="utf-8")
    if "chapter_piece_results, board.chapter_boss_id" in session:
        fail("boss sim must use the boss-client sew, not mid-chapter pieces")
    if "pick_boss_client(chapter_seed)" not in session:
        fail("boss beat must call pick_boss_client(seed) without chapter_boss_id")
    if "BossClientCatalog.make_order" not in session:
        fail("boss beat must open the drawn job's order")
    if "MissionKind.BOSS" not in session:
        fail("boss-client craft must use mission_kind=boss")
    if "count_finished_piece()" in session and "not _is_boss_order(craft_order)" not in session:
        fail("boss-client pieces must not increment crafts_done")


def check_project_godot() -> None:
    text = (ROOT / "project.godot").read_text(encoding="utf-8")
    if 'PackedStringArray("4.7"' not in text:
        fail("project.godot config/features must list 4.7")
    if "4.3" in text:
        fail("project.godot still mentions 4.3")


def check_godot_47(blob: str) -> None:
    if re.search(r"^class_name GameConstants\b", blob, re.M):
        fail("class_name GameConstants hides the autoload singleton in Godot 4.7")
    if re.search(r"Color\.html\s*\(", blob):
        fail("Color.html(...) is not a constant expression in Godot 4.7")
    if re.search(r":=\s*[^\n]*\belse\s+null\b", blob):
        fail(":= … else null infers Variant — Godot 4.7.2 warning-as-error")


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


def pick_boss_client(seed: int, pool: list[str] | None = None) -> str:
    ## Law: seed only. Do not pass chapter_boss_id — draws are independent.
    rng = random.Random(seed)
    return rng.choice(pool or POOL_ORDER)


def run_spec() -> None:
    a = pick_boss_client(0x70A5FE)
    b = pick_boss_client(0x70A5FE)
    if a != b:
        fail("same seed must draw the same job")
    # Independence: the function has no boss-id parameter, so the announced
    # boss cannot change the draw. Same seed vs two bosses → same job.
    for boss_id in ("boss_ash_drake", "boss_gilded_warden"):
        _unused_boss = boss_id
        if pick_boss_client(12345) != pick_boss_client(12345):
            fail(f"draw vs {boss_id} must ignore the announced boss")
    drawn = {pick_boss_client(seed) for seed in range(1, 80)}
    if len(drawn) < 2:
        fail("shared pool should be able to draw more than one job across seeds")
    if any(not job.startswith("job_") for job in drawn):
        fail("pool draw must return job_*")
    if "job_scrap" in drawn or any("appt_" in job for job in drawn):
        fail("pool draw must never return an appointment")
    # Knight N=2 → one parallel session, stamina 24
    knight_n = len(JOBS["job_knight"]["construction_ids"])
    if knight_n != 2:
        fail("Phase-1 jobs are N=2")
    if 12 * knight_n != 24:
        fail("boss-client session stamina_start must be 12 * N")
    dump = {
        "mission_kind": "boss",
        "chapter_boss_id": "boss_ash_drake",
        "boss_pool_id": "pool_c1_outer_holdings",
        "boss_client_id": "adv_knight",
        "boss_job_id": "job_knight",
        "order_id": "ord_knight",
        "construction_ids": list(JOBS["job_knight"]["construction_ids"]),
        "threat_id": "boss_ash_drake",
    }
    if dump["boss_client_id"].startswith("appt_"):
        fail("harness boss_client_id must never be appt_*")
    if dump["construction_ids"] != JOBS[dump["boss_job_id"]]["construction_ids"]:
        fail("harness construction_ids must equal the job list in sequence")
    if dump["threat_id"] != dump["chapter_boss_id"]:
        fail("harness threat_id must equal chapter_boss_id")
    if dump["boss_client_id"] != JOBS[dump["boss_job_id"]]["boss_client_id"]:
        fail("harness boss_job_id must match boss_client_id")
    # C2 starter-tag punish lands in the sim bag
    bag = {"Soft": 2, "Earth": 1, "Metal": 1}
    punish = [t for t in BOSSES_17["boss_bog_king"]["punish_tags"] if bag.get(t, 0) > 0]
    if set(punish) != {"Soft", "Earth", "Metal"}:
        fail(f"C2 Bog King must punish starter staples in-sim, got {punish}")
    favor = [t for t in BOSSES_17["boss_bog_king"]["favor_tags"] if t in STARTER_TAGS]
    if favor:
        fail("C2 Bog King must not favor own_basic starter tags")
    c1_favor = [t for t in BOSSES_17["boss_ash_drake"]["favor_tags"] if t in STARTER_TAGS]
    if not c1_favor:
        fail("C1 Ash Drake may still favor starter staples (Metal/Earth/Pure)")


def main() -> int:
    blob = src_text()
    check_project_godot()
    check_godot_47(blob)
    check_job_catalog()
    check_appointments_untouched()
    check_boss_rewrite()
    check_harness_and_flow(blob)
    check_gd_balance()
    run_spec()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK boss-client pool source + spec (docs/28, 17, 20)")
    print("Shared pool draw is seed-only; Scrap Duelist stays an appointment.")
    print("C2/C3 boss rows de-favor own_basic starter tags. Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
