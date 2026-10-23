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
import struct
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

M2_JOB_POOL = ["job_wizard", "job_hexer", "job_outrider", "job_oathbound"]
M2_JOBS = M2_JOB_POOL

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

M2_ALIASES = {
    "adv_wizard": "adv_vesper_cant",
    "adv_hexer": "adv_soot_cord",
    "adv_outrider": "adv_harrow_gale",
    "adv_oathbound": "adv_aurel_vow",
}

M2_PEOPLE_BY_JOB = {
    "job_wizard": ["adv_vesper_cant", "adv_nyx_vellum", "adv_orin_goldink"],
    "job_hexer": ["adv_soot_cord", "adv_tar_veil", "adv_ashen_cowl"],
    "job_outrider": ["adv_harrow_gale", "adv_flint_rime", "adv_lark_mute"],
    "job_oathbound": ["adv_aurel_vow", "adv_clarion_mantle", "adv_pell_white"],
}

M2_PEOPLE = {
    "adv_vesper_cant": {
        "display": "Vesper Cant",
        "job_id": "job_wizard",
        "skill_id": "ask_void_seam",
        "requirement_taste": "Occult mid",
        "requirement_tags": ["Occult"],
        "target_threat_id": "boss_pale_choir",
        "stats": {"HP": 9, "ATK": 3, "DEF": 2, "RES": 7, "MOB": 3, "PRE": 5},
        "construction_ids": ["con_robe", "con_mantle"],
    },
    "adv_nyx_vellum": {
        "display": "Nyx Vellum",
        "job_id": "job_wizard",
        "skill_id": "ask_two_ink",
        "requirement_taste": "Lunar + Occult (Pale Hex)",
        "requirement_tags": ["Lunar", "Occult"],
        "target_threat_id": "boss_mire_bride",
        "stats": {"HP": 8, "ATK": 5, "DEF": 2, "RES": 6, "MOB": 4, "PRE": 4},
        "construction_ids": ["con_robe", "con_mantle"],
    },
    "adv_orin_goldink": {
        "display": "Orin Gold-Ink",
        "job_id": "job_wizard",
        "skill_id": "ask_court_ink",
        "requirement_taste": "Royal mid",
        "requirement_tags": ["Royal"],
        "target_threat_id": "boss_gilded_warden",
        "stats": {"HP": 11, "ATK": 3, "DEF": 3, "RES": 5, "MOB": 2, "PRE": 7},
        "construction_ids": ["con_robe", "con_mantle"],
    },
    "adv_soot_cord": {
        "display": "Soot Cord",
        "job_id": "job_hexer",
        "skill_id": "ask_cord_hex",
        "requirement_taste": "Occult mid",
        "requirement_tags": ["Occult"],
        "target_threat_id": "boss_mire_bride",
        "stats": {"HP": 10, "ATK": 4, "DEF": 3, "RES": 6, "MOB": 4, "PRE": 2},
        "construction_ids": ["con_wraps", "con_hood"],
    },
    "adv_tar_veil": {
        "display": "Tar Veil",
        "job_id": "job_hexer",
        "skill_id": "ask_peat_knot",
        "requirement_taste": "Occult + Sticky",
        "requirement_tags": ["Occult", "Sticky"],
        "target_threat_id": "boss_bog_king",
        "stats": {"HP": 9, "ATK": 5, "DEF": 3, "RES": 5, "MOB": 3, "PRE": 2},
        "construction_ids": ["con_wraps", "con_hood"],
    },
    "adv_ashen_cowl": {
        "display": "Ashen Cowl",
        "job_id": "job_hexer",
        "skill_id": "ask_unbucketed",
        "requirement_taste": "Silent mid",
        "requirement_tags": ["Silent"],
        "target_threat_id": "boss_ivory_judge",
        "stats": {"HP": 9, "ATK": 3, "DEF": 2, "RES": 4, "MOB": 8, "PRE": 3},
        "construction_ids": ["con_wraps", "con_hood"],
    },
    "adv_harrow_gale": {
        "display": "Harrow Gale",
        "job_id": "job_outrider",
        "skill_id": "ask_road_static",
        "requirement_taste": "Storm mid",
        "requirement_tags": ["Storm"],
        "target_threat_id": "boss_bog_king",
        "stats": {"HP": 12, "ATK": 5, "DEF": 3, "RES": 4, "MOB": 7, "PRE": 3},
        "construction_ids": ["con_coat", "con_boots"],
    },
    "adv_flint_rime": {
        "display": "Flint Rime",
        "job_id": "job_outrider",
        "skill_id": "ask_mile_temper",
        "requirement_taste": "Fire + Frost (Temper)",
        "requirement_tags": ["Fire", "Frost"],
        "target_threat_id": "boss_sunspear_captain",
        "stats": {"HP": 11, "ATK": 6, "DEF": 3, "RES": 5, "MOB": 6, "PRE": 2},
        "construction_ids": ["con_coat", "con_boots"],
    },
    "adv_lark_mute": {
        "display": "Lark Mute",
        "job_id": "job_outrider",
        "skill_id": "ask_coat_hush",
        "requirement_taste": "Silent mid",
        "requirement_tags": ["Silent"],
        "target_threat_id": "boss_ivory_judge",
        "stats": {"HP": 10, "ATK": 4, "DEF": 4, "RES": 3, "MOB": 7, "PRE": 4},
        "construction_ids": ["con_coat", "con_boots"],
    },
    "adv_aurel_vow": {
        "display": "Aurel Vow",
        "job_id": "job_oathbound",
        "skill_id": "ask_noon_oath",
        "requirement_taste": "Solar mid",
        "requirement_tags": ["Solar"],
        "target_threat_id": "boss_sunspear_captain",
        "stats": {"HP": 15, "ATK": 3, "DEF": 6, "RES": 4, "MOB": 2, "PRE": 6},
        "construction_ids": ["con_armor", "con_mantle"],
    },
    "adv_clarion_mantle": {
        "display": "Clarion Mantle",
        "job_id": "job_oathbound",
        "skill_id": "ask_dawn_line",
        "requirement_taste": "Solar + Pure (Dawn Vestment)",
        "requirement_tags": ["Solar", "Pure"],
        "target_threat_id": "boss_gilded_warden",
        "stats": {"HP": 13, "ATK": 3, "DEF": 5, "RES": 5, "MOB": 2, "PRE": 7},
        "construction_ids": ["con_armor", "con_mantle"],
    },
    "adv_pell_white": {
        "display": "Pell White",
        "job_id": "job_oathbound",
        "skill_id": "ask_clean_vow",
        "requirement_taste": "Pure mid",
        "requirement_tags": ["Pure"],
        "target_threat_id": "boss_sunspear_captain",
        "stats": {"HP": 12, "ATK": 2, "DEF": 5, "RES": 6, "MOB": 2, "PRE": 6},
        "construction_ids": ["con_armor", "con_mantle"],
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
    if "func pick_boss_client_m2(seed: int)" not in boss:
        fail("pick_boss_client_m2(seed) missing — M2 draw is seed only")
    if "AdventurerCatalog.M2_JOB_POOL" not in boss:
        fail("pick_boss_client_m2 must draw from AdventurerCatalog.M2_JOB_POOL")
    if re.search(r"func pick_boss_client_m2\([^)]*chapter_boss", boss):
        fail("pick_boss_client_m2 must not take chapter_boss_id")
    if "client_matches_job" not in boss:
        fail("job match must accept named adv_* / aliases, not only job stubs")
    if "make_walk_in_order" not in boss:
        fail("walk-in path must resolve named people from the 12")


PORTRAIT_IDS = [
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
    "adv_vesper_cant",
    "adv_nyx_vellum",
    "adv_orin_goldink",
    "adv_soot_cord",
    "adv_tar_veil",
    "adv_ashen_cowl",
    "adv_harrow_gale",
    "adv_flint_rime",
    "adv_lark_mute",
    "adv_aurel_vow",
    "adv_clarion_mantle",
    "adv_pell_white",
]


def _fn_body(text: str, name: str) -> str:
    marker = f"func {name}"
    if marker not in text:
        fail(f"missing {marker}")
        return ""
    return text.split(marker, 1)[-1].split("\nfunc ", 1)[0]


def check_portraits() -> None:
    """Order-detail socket loads the 12 stamped busts. Missing texture keeps name + job."""
    table = (SRC / "ui" / "craft" / "craft_table.gd").read_text(encoding="utf-8")
    if "TextureRect" not in table:
        fail("order portrait socket must use TextureRect")
    if "res://assets/adv/" not in table:
        fail("order portrait must preload res://assets/adv/<adv_id>.png")
    if "TEXTURE_FILTER_NEAREST" not in table:
        fail("order portrait must use nearest-neighbor filter")
    if "PORTRAIT_PX := 96" not in table:
        fail("order portrait socket must be 96×96")
    bind = _fn_body(table, "_bind_order_portrait")
    if "AdventurerCatalog.resolve_id" not in bind:
        fail("portrait lookup must resolve job-stub aliases onto the named row")
    if "visible = tex != null" not in bind:
        fail("missing portrait must hide the socket and leave name + job text")
    refresh = _fn_body(table, "_refresh")
    if "_bind_order_portrait" not in refresh:
        fail("order refresh must bind the portrait socket")
    if "_order_title.text" not in refresh:
        fail("display name + job must stay on the order panel when the texture is missing")
    brief = _fn_body(table, "_refresh_brief_and_estimate")
    if "TextureRect" in brief or "assets/adv/" in brief:
        fail("guild-quest brief stays text — no adventurer bust on the enemy brief")
    for stub in (
        "adv_knight",
        "adv_mage",
        "adv_blade_dancer",
        "adv_lagoon",
        "adv_wizard",
        "adv_hexer",
        "adv_outrider",
        "adv_oathbound",
    ):
        if f"res://assets/adv/{stub}.png" in table:
            fail(f"job stub {stub} must not grow its own portrait file")
    if "appt_" in _fn_body(table, "_portrait_socket") or "assets/adv/appt_" in table:
        fail("Scrap Duelist / appt_* must not get a portrait")
    icon_dir = ROOT / "assets" / "adv"
    for adv_id in PORTRAIT_IDS:
        rel = f"res://assets/adv/{adv_id}.png"
        if rel not in table:
            fail(f"order panel missing preload {rel}")
        path = icon_dir / f"{adv_id}.png"
        if not path.is_file():
            fail(f"missing {path.relative_to(ROOT)}")
            continue
        data = path.read_bytes()
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            fail(f"{adv_id}.png is not a PNG")
            continue
        if len(data) < 24:
            fail(f"{adv_id}.png is truncated")
            continue
        width, height = struct.unpack(">II", data[16:24])
        if (width, height) != (96, 96):
            fail(f"{adv_id}.png is {width}x{height}, want 96x96")
    for sidecar in icon_dir.glob("*.import"):
        fail(f"do not commit Godot import sidecar {sidecar.name}")


def check_panel_and_dump() -> None:
    table = (SRC / "ui" / "craft" / "craft_table.gd").read_text(encoding="utf-8")
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
    if "pick_boss_client_m2(chapter_seed)" not in session:
        fail("Steam-demo boss beat must call pick_boss_client_m2(seed)")
    if "live_content_is_m2" not in session:
        fail("boss beat must branch on live_content_is_m2")
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


def _const_list(text: str, name: str) -> list[str]:
    match = re.search(rf"{name}\s*:=\s*(\[[^\]]*\])", text, re.S)
    if not match:
        return []
    return ast.literal_eval(re.sub(r"\s+", " ", match.group(1)))


def check_m2_catalog() -> None:
    """M2 roster + disjoint pools. Assert 23 M2 branch rejects the M1 four."""
    text = catalog_text()
    m2 = _const_list(text, "M2_JOB_POOL")
    steam = _const_list(text, "STEAM_DEMO_JOB_POOL")
    if m2 != M2_JOB_POOL:
        fail(f"M2_JOB_POOL expected {M2_JOB_POOL}, got {m2}")
    if steam != M2_JOB_POOL:
        fail(f"STEAM_DEMO_JOB_POOL must alias M2_JOB_POOL, got {steam}")
    if set(m2) & set(M1_JOB_POOL):
        fail("M1_JOB_POOL and M2_JOB_POOL must stay disjoint")
    live = text.split("func live_content_is_m2", 1)[-1].split("static func", 1)[0]
    if "return true" not in live:
        fail("live Steam-demo content must select the M2 pool")
    aliases_blob = text.split("const JOB_DEFAULT_ALIASES")[1].split("const PEOPLE_BY_JOB")[0]
    for alias, named in M2_ALIASES.items():
        if f'"{alias}": "{named}"' not in aliases_blob:
            fail(f"missing M2 alias {alias} → {named}")
    if len(M2_PEOPLE) != 12:
        fail("M2 roster must be 12 named adv_*")
    for adv_id, row in M2_PEOPLE.items():
        if adv_id in PEOPLE:
            fail(f"{adv_id} must not also be an M1 person")
        block = _block_for(text, adv_id)
        if not block:
            fail(f"could not parse M2 person {adv_id}")
            continue
        display = re.search(r'"display":\s*"([^"]+)"', block)
        if display is None or display.group(1) != row["display"]:
            fail(f"{adv_id} display expected {row['display']}")
        job = re.search(r'"job_id":\s*"([^"]+)"', block)
        if job is None or job.group(1) != row["job_id"]:
            fail(f"{adv_id} job_id expected {row['job_id']}")
        if row["job_id"] in M1_JOB_POOL:
            fail(f"{adv_id} job is in M1_JOB_POOL")
        skill = re.search(r'"skill_id":\s*"([^"]+)"', block)
        if skill is None or skill.group(1) != row["skill_id"] or not row["skill_id"].startswith("ask_"):
            fail(f"{adv_id} skill_id expected {row['skill_id']}")
        taste = re.search(r'"requirement_taste":\s*"([^"]+)"', block)
        if taste is None or taste.group(1) != row["requirement_taste"]:
            fail(f"{adv_id} requirement_taste expected {row['requirement_taste']}")
        tags = _list_literal(block, "requirement_tags")
        if tags != row["requirement_tags"]:
            fail(f"{adv_id} requirement_tags expected {row['requirement_tags']}, got {tags}")
        threat = re.search(r'"target_threat_id":\s*"([^"]+)"', block)
        if threat is None or threat.group(1) != row["target_threat_id"]:
            fail(f"{adv_id} target_threat_id expected {row['target_threat_id']}")
        stats = _stats_literal(block)
        if stats != row["stats"]:
            fail(f"{adv_id} stats expected {row['stats']}, got {stats}")
    stamp = (SRC / "data" / "stamp" / "harness_stamp.gd").read_text(encoding="utf-8")
    if "boss_roster_errors" not in stamp:
        fail("assert 23 must call boss_roster_errors for the active pool")
    schema = stamp.split("func schema_errors", 1)[-1]
    if "boss_roster_errors" not in schema:
        fail("mission_kind=boss schema must apply the M1/M2 roster split")
    to_dict = stamp.split("func to_dict", 1)[-1].split("\nfunc ", 1)[0]
    if '"adventurer_pool_id"' in to_dict:
        fail("adventurer_pool_id is schema context, not a docs/20 dump key")


def _pool_of(job_id: str) -> str:
    if job_id in M1_JOB_POOL:
        return "m1"
    if job_id in M2_JOB_POOL:
        return "m2"
    return ""


def _roster_errors(client_id: str, job_id: str, pool_id: str) -> list[str]:
    errs: list[str] = []
    if pool_id not in {"m1", "m2"}:
        return ["boss draw pool must be m1 or m2"]
    if _pool_of(job_id) != pool_id:
        errs.append(f"boss_job_id is outside the active {pool_id} job pool")
    named = client_id
    if named not in PEOPLE and named not in M2_PEOPLE:
        named = {**ALIASES, **M2_ALIASES}.get(client_id, "")
    person = PEOPLE.get(named) or M2_PEOPLE.get(named)
    if person is None or _pool_of(person["job_id"]) != pool_id:
        errs.append(f"boss_client_id is outside the active {pool_id} named roster")
    return errs


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
    ## Assert 23 M2 branch: the 12 M2 people and their aliases pass; the M1 four fail.
    for alias, named in M2_ALIASES.items():
        person = M2_PEOPLE[named]
        if _roster_errors(alias, person["job_id"], "m2"):
            fail(f"M2 alias {alias} must pass the M2 roster assert")
        if _roster_errors(named, person["job_id"], "m2"):
            fail(f"M2 person {named} must pass the M2 roster assert")
        if not _roster_errors(named, person["job_id"], "m1"):
            fail(f"M2 person {named} must fail an M1 smoke")
        if person["construction_ids"] != M2_PEOPLE[M2_PEOPLE_BY_JOB[person["job_id"]][0]]["construction_ids"] and person[
            "job_id"
        ] not in M2_PEOPLE_BY_JOB:
            fail(f"{named} constructions left the job list")
    for job_id, ids in M2_PEOPLE_BY_JOB.items():
        cons = M2_PEOPLE[ids[0]]["construction_ids"]
        for adv_id in ids:
            if M2_PEOPLE[adv_id]["construction_ids"] != cons:
                fail(f"{adv_id} construction_ids must stay the job list")
            if M2_PEOPLE[adv_id]["job_id"] != job_id:
                fail(f"{adv_id} is not in {job_id}")
    for m1_id, row in PEOPLE.items():
        if not _roster_errors(m1_id, row["job_id"], "m2"):
            fail(f"M1 person {m1_id} must fail an M2 smoke")
        if _roster_errors(m1_id, row["job_id"], "m1"):
            fail(f"M1 person {m1_id} must still pass an M1 smoke")
    if not _roster_errors("appt_scrap_duelist", "job_wizard", "m2"):
        fail("boss_client_id must never be appt_* on the M2 assert")
    m2_draw_jobs = set()
    for seed in range(1, 80):
        rng = random.Random(seed)
        job = rng.choice(M2_JOB_POOL)
        person = rng.choice(M2_PEOPLE_BY_JOB[job])
        if job in M1_JOB_POOL or person in PEOPLE:
            fail("M2 draw leaked an M1 job or person")
        m2_draw_jobs.add(job)
    if len(m2_draw_jobs) < 2:
        fail("M2 4-job pool should draw more than one job across seeds")


def main() -> int:
    check_catalog()
    check_m2_catalog()
    check_draw_and_jobs()
    check_portraits()
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
