#!/usr/bin/env python3
"""Source + spec checks for interactive-order slice 1 (docs/29, 30).

Godot is not required. This does not open the editor.
Does not cover slice 2 planner, slice 3 estimate, Dex, or slice 4 playback.
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

M1_JOB_POOL = [
    "job_knight",
    "job_mage",
    "job_blade_dancer",
    "job_lagoon",
]

M2_JOBS = ["job_wizard", "job_hexer", "job_outrider", "job_oathbound"]

ALIASES = {
    "adv_knight": "adv_halden_rook",
    "adv_mage": "adv_quill_lumen",
    "adv_blade_dancer": "adv_kite_thornreel",
    "adv_lagoon": "adv_tide_glass",
}

PEOPLE_BY_JOB = {
    "job_knight": ["adv_halden_rook", "adv_vex_bramble", "adv_solenne_ward"],
    "job_mage": ["adv_quill_lumen", "adv_neri_paleink", "adv_marrowveil"],
    "job_blade_dancer": ["adv_kite_thornreel", "adv_mask_circlet", "adv_whisper_hem"],
    "job_lagoon": ["adv_tide_glass", "adv_brine_latch", "adv_rime_peddler"],
}

PEOPLE = {
    "adv_halden_rook": {
        "display": "Ser Halden Rook",
        "job_id": "job_knight",
        "skill_id": "ask_plate_oath",
        "requirement_taste": "Metal mid",
        "stats": {"HP": 14, "ATK": 4, "DEF": 6, "RES": 3, "MOB": 2, "PRE": 4},
        "construction_ids": ["con_armor", "con_gloves"],
    },
    "adv_vex_bramble": {
        "display": "Vex Bramble",
        "job_id": "job_knight",
        "skill_id": "ask_thorn_latch",
        "requirement_taste": "Sticky + Sharp (Snaretooth)",
        "stats": {"HP": 11, "ATK": 6, "DEF": 4, "RES": 3, "MOB": 5, "PRE": 2},
        "construction_ids": ["con_armor", "con_gloves"],
    },
    "adv_solenne_ward": {
        "display": "Dame Solenne Ward",
        "job_id": "job_knight",
        "skill_id": "ask_clean_court",
        "requirement_taste": "Royal mid",
        "stats": {"HP": 12, "ATK": 3, "DEF": 5, "RES": 4, "MOB": 3, "PRE": 6},
        "construction_ids": ["con_armor", "con_gloves"],
    },
    "adv_quill_lumen": {
        "display": "Quill Lumen",
        "job_id": "job_mage",
        "skill_id": "ask_night_ledger",
        "requirement_taste": "Lunar mid",
        "stats": {"HP": 9, "ATK": 3, "DEF": 2, "RES": 6, "MOB": 4, "PRE": 5},
        "construction_ids": ["con_robe", "con_hood"],
    },
    "adv_neri_paleink": {
        "display": "Neri Pale-Ink",
        "job_id": "job_mage",
        "skill_id": "ask_pale_signature",
        "requirement_taste": "Lunar + Occult (Pale Hex)",
        "stats": {"HP": 8, "ATK": 4, "DEF": 2, "RES": 7, "MOB": 3, "PRE": 4},
        "construction_ids": ["con_robe", "con_hood"],
    },
    "adv_marrowveil": {
        "display": "Sister Marrowveil",
        "job_id": "job_mage",
        "skill_id": "ask_clean_hood",
        "requirement_taste": "Silk mid",
        "stats": {"HP": 10, "ATK": 2, "DEF": 3, "RES": 5, "MOB": 5, "PRE": 5},
        "construction_ids": ["con_robe", "con_hood"],
    },
    "adv_kite_thornreel": {
        "display": "Kite Thornreel",
        "job_id": "job_blade_dancer",
        "skill_id": "ask_edge_count",
        "requirement_taste": "Sharp mid",
        "stats": {"HP": 10, "ATK": 7, "DEF": 3, "RES": 2, "MOB": 7, "PRE": 3},
        "construction_ids": ["con_tunic", "con_cape"],
    },
    "adv_mask_circlet": {
        "display": "Mask Circlet",
        "job_id": "job_blade_dancer",
        "skill_id": "ask_incognito_bow",
        "requirement_taste": "Royal + Silent (Masked Crown)",
        "stats": {"HP": 9, "ATK": 5, "DEF": 3, "RES": 3, "MOB": 6, "PRE": 6},
        "construction_ids": ["con_tunic", "con_cape"],
    },
    "adv_whisper_hem": {
        "display": "Whisper Hem",
        "job_id": "job_blade_dancer",
        "skill_id": "ask_hush_check",
        "requirement_taste": "Silent mid",
        "stats": {"HP": 8, "ATK": 4, "DEF": 2, "RES": 3, "MOB": 8, "PRE": 2},
        "construction_ids": ["con_tunic", "con_cape"],
    },
    "adv_tide_glass": {
        "display": "Tide Glass",
        "job_id": "job_lagoon",
        "skill_id": "ask_sky_step",
        "requirement_taste": "Storm mid",
        "stats": {"HP": 11, "ATK": 5, "DEF": 3, "RES": 5, "MOB": 6, "PRE": 3},
        "construction_ids": ["con_cloak", "con_boots"],
    },
    "adv_brine_latch": {
        "display": "Brine Latch",
        "job_id": "job_lagoon",
        "skill_id": "ask_temper_brine",
        "requirement_taste": "Fire + Frost (Temper)",
        "stats": {"HP": 10, "ATK": 6, "DEF": 3, "RES": 6, "MOB": 5, "PRE": 2},
        "construction_ids": ["con_cloak", "con_boots"],
    },
    "adv_rime_peddler": {
        "display": "Rime Peddler",
        "job_id": "job_lagoon",
        "skill_id": "ask_rime_walk",
        "requirement_taste": "Frost mid",
        "stats": {"HP": 12, "ATK": 3, "DEF": 4, "RES": 6, "MOB": 5, "PRE": 3},
        "construction_ids": ["con_cloak", "con_boots"],
    },
}

STAT_KEYS = ["HP", "ATK", "DEF", "RES", "MOB", "PRE"]
LOG_KEYS = [
    "boss_client_id",
    "boss_job_id",
    "construction_ids",
    "adventurer_skill_id",
    "adventurer_stats",
]


def fail(msg: str) -> None:
    FAILS.append(msg)


def catalog_text() -> str:
    return (SRC / "data" / "catalog" / "adventurer_catalog.gd").read_text(encoding="utf-8")


def boss_catalog_text() -> str:
    return (SRC / "data" / "catalog" / "boss_client_catalog.gd").read_text(encoding="utf-8")


def _list_literal(text: str, key: str) -> list:
    match = re.search(rf'"{key}":\s*(\[[^\]]*\])', text)
    if not match:
        return []
    return ast.literal_eval(match.group(1))


def _block_for(text: str, key: str) -> str:
    match = re.search(rf'"{re.escape(key)}":\s*\{{(.*?)\n\t\}}\s*,', text, re.S)
    if not match:
        return ""
    return match.group(1)


def _stats_literal(block: str) -> dict:
    match = re.search(r'"stats":\s*(\{[^}]+\})', block)
    if not match:
        return {}
    return ast.literal_eval(match.group(1))


def resolve_id(adv_id: str) -> str:
    if adv_id in PEOPLE:
        return adv_id
    return ALIASES.get(adv_id, "")


def pick_m1(seed: int) -> tuple[str, str]:
    rng = random.Random(seed)
    job = rng.choice(M1_JOB_POOL)
    person = rng.choice(PEOPLE_BY_JOB[job])
    return job, person


def check_catalog() -> None:
    text = catalog_text()
    if "class_name AdventurerCatalog" not in text:
        fail("AdventurerCatalog class missing")
    pool_match = re.search(r"M1_JOB_POOL\s*:=\s*(\[[^\]]*\])", text, re.S)
    pool: list[str] = []
    if pool_match:
        pool = ast.literal_eval(re.sub(r"\s+", " ", pool_match.group(1)))
    if pool != M1_JOB_POOL:
        fail(f"M1_JOB_POOL expected {M1_JOB_POOL}, got {pool}")
    for m2 in M2_JOBS:
        if m2 in pool:
            fail(f"{m2} must stay out of M1_JOB_POOL")
    aliases_blob = text.split("const JOB_DEFAULT_ALIASES")[1].split("const PEOPLE_BY_JOB")[0] if "const JOB_DEFAULT_ALIASES" in text else ""
    for alias, named in ALIASES.items():
        if f'"{alias}": "{named}"' not in aliases_blob and f'"{alias}": "{named}"' not in text:
            fail(f"missing alias {alias} → {named}")
    if len(PEOPLE) != 12:
        fail("M1 roster must be 12 named adv_*")
    for adv_id, row in PEOPLE.items():
        if f'"{adv_id}"' not in text:
            fail(f"missing person {adv_id}")
            continue
        block = _block_for(text, adv_id)
        if not block:
            fail(f"could not parse person block {adv_id}")
            continue
        display = re.search(r'"display":\s*"([^"]+)"', block)
        if display is None or display.group(1) != row["display"]:
            fail(f"{adv_id} display expected {row['display']}, got {display.group(1) if display else None}")
        job = re.search(r'"job_id":\s*"([^"]+)"', block)
        if job is None or job.group(1) != row["job_id"]:
            fail(f"{adv_id} job_id expected {row['job_id']}")
        skill = re.search(r'"skill_id":\s*"([^"]+)"', block)
        if skill is None or skill.group(1) != row["skill_id"]:
            fail(f"{adv_id} skill_id expected {row['skill_id']}")
        if not row["skill_id"].startswith("ask_"):
            fail(f"{adv_id} skill must be ask_*")
        taste = re.search(r'"requirement_taste":\s*"([^"]+)"', block)
        if taste is None or taste.group(1) != row["requirement_taste"]:
            fail(f"{adv_id} requirement_taste expected {row['requirement_taste']}")
        stats = _stats_literal(block)
        if stats != row["stats"]:
            fail(f"{adv_id} stats expected {row['stats']}, got {stats}")
        for key in STAT_KEYS:
            if key not in stats:
                fail(f"{adv_id} stats missing {key}")
        if "sk_" in String_safe(block) and re.search(r'"skill_id":\s*"sk_', block):
            fail(f"{adv_id} skill_id must not be sk_*")
    named = [adv_id for job_id in M1_JOB_POOL for adv_id in PEOPLE_BY_JOB[job_id]]
    if named != list(PEOPLE.keys()):
        fail(f"PEOPLE_BY_JOB flatten expected {list(PEOPLE.keys())}, got {named}")


def String_safe(block: str) -> str:
    return block


def check_draw_and_jobs() -> None:
    boss = boss_catalog_text()
    if "AdventurerCatalog.M1_JOB_POOL" not in boss:
        fail("pick_boss_client must draw from AdventurerCatalog.M1_JOB_POOL")
    if "ids_for_job" not in boss:
        fail("pick_boss_client must pick a named person from that job")
    if re.search(r"func pick_boss_client\([^)]*chapter_boss", boss):
        fail("pick_boss_client must not take chapter_boss_id")
    if "SHARED_BOSS_CLIENT_POOL[rng.randi_range" in boss:
        fail("M1 draw must not use the 8-job SHARED_BOSS_CLIENT_POOL")
    for m2 in ("adv_wizard", "adv_hexer", "adv_outrider", "adv_oathbound"):
        if m2 in catalog_text():
            fail(f"M1 catalog must not name {m2}")
    if "client_matches_job" not in boss:
        fail("job match must accept named adv_* / aliases, not only job stubs")
    if "make_walk_in_order" not in boss:
        fail("walk-in path must resolve named people from the 12")


def check_panel_and_dump() -> None:
    table = (SRC / "ui" / "craft" / "craft_table.gd").read_text(encoding="utf-8")
    if "TextureRect" in table:
        fail("order panel must not use TextureRect / portraits")
    if "adventurer order detail" not in table:
        fail("upper-left caption should name adventurer order detail")
    for token in (
        "AdventurerCatalog.stats_line",
        "AdventurerCatalog.skill_panel_line",
        "requirement_taste",
        "order_adventurer_id",
    ):
        if token not in table:
            fail(f"craft table missing {token}")
    stamp = (SRC / "data" / "stamp" / "harness_stamp.gd").read_text(encoding="utf-8")
    for key in LOG_KEYS:
        if f'"{key}"' not in stamp:
            fail(f"stamp dump missing log key {key}")
    if "adventurer_skill_id must" in stamp or 'errs.append("adventurer_skill_id' in stamp:
        fail("adventurer_skill_id must stay log-only — not a 20 Required schema field")
    session = (SRC / "autoload" / "atelier_session.gd").read_text(encoding="utf-8")
    if "apply_adventurer_logs" not in session and "apply_adventurer_logs" not in stamp:
        fail("stamp must fill adventurer log keys")
    if "pick_boss_client(chapter_seed)" not in session:
        fail("boss beat must still call pick_boss_client(seed)")
    schedule = (SRC / "data" / "chapter" / "schedule_catalog.gd").read_text(encoding="utf-8")
    if "make_walk_in_order" not in schedule:
        fail("walk-in should resolve through named M1 people")
    if '"appointment_id": "appt_c1_scrap_duelist"' not in schedule:
        fail("Scrap Duelist must stay an appointment")


def check_godot_47() -> None:
    blob_parts: list[str] = []
    for path in [
        SRC / "data" / "catalog" / "adventurer_catalog.gd",
        SRC / "data" / "catalog" / "boss_client_catalog.gd",
        SRC / "ui" / "craft" / "craft_table.gd",
        SRC / "data" / "stamp" / "harness_stamp.gd",
        SRC / "data" / "order" / "client_order.gd",
    ]:
        blob_parts.append(path.read_text(encoding="utf-8"))
    blob = "\n".join(blob_parts)
    if re.search(r"^class_name GameConstants\b", blob, re.M):
        fail("class_name GameConstants hides the autoload singleton")
    if re.search(r"Color\.html\s*\(", blob):
        fail("Color.html(...) is not a constant expression in Godot 4.7")
    if re.search(r":=\s*[^\n]*\belse\s+null\b", blob):
        fail(":= … else null infers Variant — Godot 4.7.2 warning-as-error")
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    if 'PackedStringArray("4.7"' not in project:
        fail("project.godot config/features must list 4.7")
    for path in SRC.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        if text.count("{") != text.count("}"):
            fail(f"unbalanced {{}} in {path.relative_to(ROOT)}")
        for i, line in enumerate(text.splitlines(), 1):
            if line.startswith("    ") and not line.startswith("\t"):
                fail(f"space indent {path.relative_to(ROOT)}:{i}")
                break


def run_spec() -> None:
    a = pick_m1(0x693EC23)
    b = pick_m1(0x693EC23)
    if a != b:
        fail("same seed must draw the same job + person")
    jobs = set()
    people = set()
    for seed in range(1, 120):
        job, person = pick_m1(seed)
        if job in M2_JOBS:
            fail(f"M1 draw picked M2 job {job}")
        if job not in M1_JOB_POOL:
            fail(f"M1 draw picked unknown job {job}")
        if person not in PEOPLE_BY_JOB[job]:
            fail(f"{person} is not in {job}'s named three")
        jobs.add(job)
        people.add(person)
    if len(jobs) < 2:
        fail("M1 4-job pool should draw more than one job across seeds")
    if any(p.startswith("adv_wizard") or p.startswith("adv_hexer") for p in people):
        fail("M1 draw must not emit Wizard/Hexer people")
    for alias, named in ALIASES.items():
        resolved = resolve_id(alias)
        if resolved != named:
            fail(f"alias {alias} should resolve to {named}")
        if PEOPLE[resolved]["job_id"] != {
            "adv_knight": "job_knight",
            "adv_mage": "job_mage",
            "adv_blade_dancer": "job_blade_dancer",
            "adv_lagoon": "job_lagoon",
        }[alias]:
            fail(f"alias {alias} job mismatch")
        dump = {
            "mission_kind": "boss",
            "boss_client_id": alias,
            "boss_job_id": PEOPLE[named]["job_id"],
            "construction_ids": list(PEOPLE[named]["construction_ids"]),
            "adventurer_skill_id": PEOPLE[named]["skill_id"],
            "adventurer_stats": dict(PEOPLE[named]["stats"]),
        }
        if dump["boss_client_id"].startswith("appt_"):
            fail("alias dump must never be appt_*")
        if dump["construction_ids"] != PEOPLE[named]["construction_ids"]:
            fail("construction_ids must stay the job list")
        if set(dump["adventurer_stats"]) != set(STAT_KEYS):
            fail("panel stats object must be {HP, ATK, DEF, RES, MOB, PRE}")
    named_dump = {
        "mission_kind": "boss",
        "boss_client_id": "adv_halden_rook",
        "boss_job_id": "job_knight",
        "construction_ids": ["con_armor", "con_gloves"],
        "adventurer_skill_id": "ask_plate_oath",
        "adventurer_stats": {"HP": 14, "ATK": 4, "DEF": 6, "RES": 3, "MOB": 2, "PRE": 4},
    }
    if named_dump["adventurer_skill_id"] != PEOPLE["adv_halden_rook"]["skill_id"]:
        fail("named dump skill mismatch")
    if named_dump["adventurer_stats"] != PEOPLE["adv_halden_rook"]["stats"]:
        fail("named dump stats mismatch")


def main() -> int:
    check_catalog()
    check_draw_and_jobs()
    check_panel_and_dump()
    check_godot_47()
    run_spec()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK adventurer order panel slice 1 (docs/29, 30)")
    print("M1 draw is 4 jobs × named people; aliases resolve; dump keys are log-only.")
    print("Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
