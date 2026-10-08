#!/usr/bin/env python3
"""Source + spec checks for interactive-order slices 2–3 UI (docs/14, 17, 30, 31).

Godot is not required. This does not open the editor.
Does not cover Dex shop/menu (Client PR 4) or slice 4 battle playback.
"""
from __future__ import annotations

import math
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

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
TIER_MIN = {"low": 3, "mid": 5, "apex": 8}
CROSS = [
    ("temper", "Fire", "Frost", "Temper"),
    ("beastbloom", "Wild", "Earth", "Beastbloom"),
    ("snaretooth", "Sticky", "Sharp", "Snaretooth"),
    ("masked_crown", "Royal", "Silent", "Masked Crown"),
    ("dawn", "Solar", "Pure", "Dawn"),
    ("pale_hex", "Lunar", "Occult", "Pale Hex"),
]
CON_TAGS = {
    "con_armor": ["Metal"],
    "con_gloves": ["Sharp"],
    "con_robe": ["Silk"],
    "con_hood": ["Silent"],
    "con_cloak": ["Silent"],
    "con_boots": ["Earth"],
    "con_tunic": ["Soft"],
    "con_cape": ["Silk"],
}
BOSSES = {
    "boss_ash_drake": {
        "favor": ["Metal", "Earth", "Frost", "Pure"],
        "punish": ["Soft", "Sticky"],
    },
    "boss_gilded_warden": {
        "favor": ["Royal", "Solar", "Fire", "Sharp"],
        "punish": ["Soft", "Earth", "Wild", "Metal"],
    },
    "boss_ivory_judge": {
        "favor": ["Royal", "Lunar", "Silent", "Occult"],
        "punish": ["Soft", "Metal", "Pure", "Silk"],
    },
}
HALDEN = {"HP": 14, "ATK": 4, "DEF": 6, "RES": 3, "MOB": 2, "PRE": 4}
MARROWVEIL = {"HP": 10, "ATK": 2, "DEF": 3, "RES": 5, "MOB": 5, "PRE": 5}
FAVOR_W, PUNISH_W, SKILL_W, NEG_W, STAT_W = 2, 3, 2, 3, 1
BANDS = [(10, "S"), (7, "A"), (4, "B"), (1, "C"), (-2, "D")]
LOG_KEYS = [
    "planned_build",
    "threat_id",
    "estimate_band",
    "estimate_favor_hits",
    "estimate_punish_hits",
    "estimate_skill_fired",
    "estimate_neg_warnings",
    "unlocked_builds",
    "dex_enemies",
]
NEG_ROWS = [
    {"id": "syn_neg_metal_silk", "a": "Metal", "amin": 3, "b": "Silk", "bmin": 3},
    {"id": "syn_neg_hood_metal", "construction": "con_hood", "tag": "Metal", "min": 1},
    {"id": "syn_neg_cloak_metal", "construction": "con_cloak", "tag": "Metal", "min": 1},
    {"id": "syn_neg_metal_silent", "a": "Metal", "amin": 1, "b": "Silent", "bmin": 1},
    {"id": "syn_neg_soft_sharp", "a": "Soft", "amin": 1, "b": "Sharp", "bmin": 1},
    {"id": "syn_neg_sticky_royal", "a": "Sticky", "amin": 1, "b": "Royal", "bmin": 1},
    {"id": "syn_neg_occult_pure", "a": "Occult", "amin": 1, "b": "Pure", "bmin": 1},
    {"id": "syn_neg_fire_soft", "a": "Fire", "amin": 1, "b": "Soft", "bmin": 1},
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


def cross_for(tag_a: str, tag_b: str) -> str:
    for outlook_id, a, b, _display in CROSS:
        if (tag_a == a and tag_b == b) or (tag_a == b and tag_b == a):
            return outlook_id
    return ""


def tags_for_cross(outlook_id: str) -> list[str]:
    for slug, a, b, _display in CROSS:
        if slug == outlook_id:
            return [a, b]
    return []


def after_click(planned: dict | None, clicked: str) -> dict | None:
    if clicked not in MONOSTACK:
        return planned
    slug = clicked.lower()
    if planned is None:
        return {"outlook_id": slug, "tier": "low"}
    outlook_id = planned["outlook_id"]
    tier = planned["tier"]
    if tier == "cross":
        return {"outlook_id": slug, "tier": "low"}
    if outlook_id == slug:
        if tier == "low":
            return {"outlook_id": slug, "tier": "mid"}
        if tier == "mid":
            return {"outlook_id": slug, "tier": "apex"}
        return None
    cross_id = cross_for(title_of(outlook_id), clicked)
    if cross_id:
        return {"outlook_id": cross_id, "tier": "cross"}
    return {"outlook_id": slug, "tier": "low"}


def planned_tags(planned: dict | None) -> dict[str, int]:
    bag: dict[str, int] = {}
    if not planned:
        return bag
    outlook_id = planned["outlook_id"]
    tier = planned["tier"]
    if tier == "cross":
        for tag in tags_for_cross(outlook_id):
            bag[tag] = bag.get(tag, 0) + 1
        return bag
    if tier in TIER_MIN:
        tag = title_of(outlook_id)
        bag[tag] = bag.get(tag, 0) + TIER_MIN[tier]
    return bag


def add_constructions(bag: dict[str, int], construction_ids: list[str]) -> dict[str, int]:
    out = dict(bag)
    for con_id in construction_ids:
        for tag in CON_TAGS.get(con_id, []):
            out[tag] = out.get(tag, 0) + 1
    return out


def count_hits(bag: dict[str, int], listed: list[str]) -> list[str]:
    hits: list[str] = []
    for tag in listed:
        if bag.get(tag, 0) > 0 and tag not in hits:
            hits.append(tag)
    return hits


def would_fire_neg(bag: dict[str, int], construction_ids: list[str]) -> list[str]:
    fired: list[str] = []
    for row in NEG_ROWS:
        if "construction" in row:
            ok = row["construction"] in construction_ids and bag.get(row["tag"], 0) >= row["min"]
        else:
            ok = bag.get(row["a"], 0) >= row["amin"] and bag.get(row["b"], 0) >= row["bmin"]
        if ok and row["id"] not in fired:
            fired.append(row["id"])
    return fired


def skill_fired(skill_id: str, bag: dict[str, int], construction_ids: list[str], negs: list[str]) -> bool:
    if skill_id == "ask_plate_oath":
        return bag.get("Metal", 0) >= 5
    if skill_id == "ask_clean_hood":
        hood_metal = "con_hood" in construction_ids and bag.get("Metal", 0) >= 1
        schism = bag.get("Occult", 0) >= 1 and bag.get("Pure", 0) >= 1
        return bag.get("Silk", 0) >= 5 and not hood_metal and not schism
    if skill_id == "ask_temper_brine":
        return bag.get("Fire", 0) >= 1 and bag.get("Frost", 0) >= 1
    return False


def letter_from_score(score: int) -> str:
    for cutoff, band in BANDS:
        if score >= cutoff:
            return band
    return "F"


def estimate(stats: dict, skill_id: str, planned: dict | None, cons: list[str], threat_id: str) -> dict:
    tags = add_constructions(planned_tags(planned), cons)
    score = math.floor((stats["ATK"] + stats["DEF"] + stats["RES"]) / 3) * STAT_W
    favor = count_hits(tags, BOSSES[threat_id]["favor"])
    punish = count_hits(tags, BOSSES[threat_id]["punish"])
    score += len(favor) * FAVOR_W
    score -= len(punish) * PUNISH_W
    negs = would_fire_neg(tags, cons)
    fired = skill_fired(skill_id, tags, cons, negs)
    if fired:
        score += SKILL_W
    if negs:
        score -= NEG_W
    return {
        "score": score,
        "band": letter_from_score(score),
        "favor_hits": favor,
        "punish_hits": punish,
        "skill_fired": fired,
        "neg_warnings": negs,
        "tags": tags,
    }


def list_lines(unlocked: list[dict]) -> list[str]:
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


def check_source() -> None:
    planner = read("data/synergy/planner_catalog.gd")
    estimate_src = read("data/mission/estimate_law.gd")
    table = read("ui/craft/craft_table.gd")
    session = read("autoload/atelier_session.gd")
    stamp = read("data/stamp/harness_stamp.gd")
    profile = read("data/profile/profile_meta.gd")
    threat = read("data/catalog/threat_catalog.gd")
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    blob = src_blob()

    if "class_name PlannerCatalog" not in planner:
        fail("PlannerCatalog class missing")
    if "class_name EstimateLaw" not in estimate_src:
        fail("EstimateLaw class missing")
    for tag in MONOSTACK:
        if f'"{tag}"' not in planner:
            fail(f"planner missing monostack tag {tag}")
    for slug, _a, _b, _display in CROSS:
        if f'"{slug}"' not in planner:
            fail(f"planner missing cross {slug}")
    if "syn_neg_" in planner and "CROSS_ROWS" in planner:
        if re.search(r'outlook_id": "syn_neg_', planner):
            fail("planner must not list neg syn as targets")
    for knob, value in (
        ("FAVOR_W", 2),
        ("PUNISH_W", 3),
        ("SKILL_W", 2),
        ("NEG_W", 3),
        ("STAT_W", 1),
    ):
        if f"const {knob} := {value}" not in estimate_src:
            fail(f"estimate knob {knob} must be {value} (Test knobs, leave-as-knobs)")
    if "letter_from_score" not in estimate_src:
        fail("estimate must map score → S–F via Test-knob cutoffs")
    if "rand" in estimate_src.lower() and "RandomNumber" in estimate_src:
        fail("estimate must be deterministic — no RNG")
    if "syn-target" not in table:
        fail("craft table must host the syn-target planner under the order panel")
    if "guild-quest brief" not in table:
        fail("craft table must host the guild-quest brief")
    if "TextureRect" in table:
        fail("planner / brief must not use TextureRect / portraits")
    if "click_planner_tag" not in session or "click_planner_tag" not in table:
        fail("tag chips must set planned_build via click_planner_tag")
    if "construction_ids" in session.split("func click_planner_tag", 1)[-1].split("func _note_order_brief", 1)[0]:
        if "construction_ids =" in session.split("func click_planner_tag", 1)[-1].split("func _note_order_brief", 1)[0]:
            fail("planner intent must not rewrite construction_ids")
    if "_note_order_brief" not in session or "note_shop_brief" not in session:
        fail("showing the brief must write seen via note_shop_brief")
    begin = session.split("func _begin_craft", 1)[-1].split("func _open_session", 1)[0]
    if "_note_order_brief" not in begin:
        fail("_begin_craft must show/write the brief once (not on every refresh)")
    if "TODO(PR 3)" in session or "TODO(PR 3)" in profile:
        fail("PR 3 brief hook must be live — remove the TODO(PR 3) stub")
    if "brief_threat_id" not in session:
        fail("boss beat must override threat_id to chapter_boss_id")
    if "MissionKind.BOSS" not in session.split("func brief_threat_id", 1)[-1].split("func click_planner_tag", 1)[0]:
        fail("brief_threat_id must special-case boss beat")
    if "environment" not in threat or "flavor" not in threat:
        fail("ThreatCatalog must carry docs/17 environment / flavor for the poster")
    for key in LOG_KEYS:
        if f'"{key}"' not in stamp:
            fail(f"stamp dump missing log key {key}")
    schema = stamp.split("func schema_errors")[-1]
    for key in (
        "planned_build",
        "estimate_band",
        "estimate_favor_hits",
        "estimate_punish_hits",
        "estimate_skill_fired",
        "estimate_neg_warnings",
    ):
        if f'errs.append("{key}' in schema or f"{key} must" in schema:
            fail(f"{key} must stay log-only — not a 20 Required schema field")
    if re.search(r'errs\.append\([^\n]*estimate_band', schema):
        fail("do not schema-assert estimate band against post-sim rating")
    if "planned_build: Variant = null" not in stamp:
        fail("planned_build must be explicit Variant (Godot 4.7)")
    ui_blob = ""
    for path in (SRC / "ui").rglob("*"):
        if path.suffix in {".gd", ".tscn"}:
            ui_blob += path.read_text(encoding="utf-8")
    for token in ("Dex tab", "Builds | Crafts", "Fashion Encyclopedia"):
        if token in ui_blob:
            fail(f"Dex shop/menu screen must not land in this PR ({token})")
    if 'PackedStringArray("4.7"' not in project:
        fail("project.godot config/features must list 4.7")
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
    ## Godot 4.7.2 warning-as-error: `var x := variant_fn()` infers Variant.
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
    plan = None
    plan = after_click(plan, "Metal")
    if plan != {"outlook_id": "metal", "tier": "low"}:
        fail(f"first Metal click should be low, got {plan}")
    plan = after_click(plan, "Metal")
    if plan != {"outlook_id": "metal", "tier": "mid"}:
        fail(f"second Metal click should be mid, got {plan}")
    plan = after_click(plan, "Metal")
    if plan != {"outlook_id": "metal", "tier": "apex"}:
        fail(f"third Metal click should be apex, got {plan}")
    plan = after_click(plan, "Metal")
    if plan is not None:
        fail("fourth Metal click should cycle off")
    two = after_click(after_click(None, "Sticky"), "Sharp")
    if two != {"outlook_id": "snaretooth", "tier": "cross"}:
        fail(f"Sticky+Sharp should plan Snaretooth cross, got {two}")
    replaced = after_click(after_click(None, "Metal"), "Sharp")
    if replaced != {"outlook_id": "sharp", "tier": "low"}:
        fail(f"Metal then Sharp (not a cross) should replace, got {replaced}")

    if planned_tags({"outlook_id": "metal", "tier": "mid"}) != {"Metal": 5}:
        fail("monostack mid must use the tier minimum (5)")
    if planned_tags({"outlook_id": "snaretooth", "tier": "cross"}) != {"Sticky": 1, "Sharp": 1}:
        fail("Snaretooth must be {Sticky:1, Sharp:1}")
    bag = add_constructions(planned_tags({"outlook_id": "metal", "tier": "low"}), ["con_hood", "con_robe"])
    if bag.get("Metal", 0) < 1 or "Silent" not in bag:
        fail("construction tags must stack onto planned chips (hood+Metal → Bucket Head)")

    fresh = list_lines([])
    if fresh != ["?"]:
        fail(f"fresh profile planner must be only ?, got {fresh}")
    metal_low = list_lines([{"outlook_id": "metal", "tier": "low"}])
    if "Metal low" not in metal_low or "Metal ?" not in metal_low:
        fail(f"known family missing tiers should show Metal ?, got {metal_low}")
    if any(line.startswith("Storm ") and not line.startswith("Storm ?") for line in metal_low if line != "?"):
        fail("unknown families must not spoiler names")
    if "Storm mid" in metal_low:
        fail("do not list locked unknown-family named rows")

    ash = estimate(
        HALDEN,
        "ask_plate_oath",
        {"outlook_id": "metal", "tier": "mid"},
        ["con_armor", "con_gloves"],
        "boss_ash_drake",
    )
    if "Metal" not in ash["favor_hits"]:
        fail("Metal-mid vs Ash Drake must hit Metal favor")
    if ash["skill_fired"] is not True:
        fail("Plate Oath should fire on Metal ≥ mid")
    if ash["band"] not in {"S", "A", "B", "C", "D", "F"}:
        fail("estimate band must be a letter")

    gilded = estimate(
        HALDEN,
        "ask_plate_oath",
        {"outlook_id": "metal", "tier": "mid"},
        ["con_armor", "con_gloves"],
        "boss_gilded_warden",
    )
    if "Metal" not in gilded["punish_hits"]:
        fail("Metal-mid vs Gilded Warden must subtract PUNISH_W (Metal ∈ punishes)")
    expect = 4 + len(gilded["favor_hits"]) * 2 - len(gilded["punish_hits"]) * 3 + 2
    if gilded["neg_warnings"]:
        expect -= NEG_W
    if gilded["score"] != expect:
        fail(f"Gilded Metal-mid internal score expected {expect}, got {gilded['score']}")

    ivory = estimate(
        MARROWVEIL,
        "ask_clean_hood",
        {"outlook_id": "silk", "tier": "mid"},
        ["con_robe", "con_hood"],
        "boss_ivory_judge",
    )
    if "Silk" not in ivory["punish_hits"]:
        fail("Silk-mid vs Ivory Judge must subtract PUNISH_W (Silk ∈ punishes)")

    gated_locked = {
        "estimate_band": "?",
        "estimate_favor_hits": "?",
        "estimate_punish_hits": "?",
        "estimate_skill_fired": "?",
        "estimate_neg_warnings": "?",
    }
    fought = False
    unlocked = False
    if not fought:
        if gated_locked["estimate_band"] != "?":
            fail("band stays ? until fought")
    if not unlocked:
        if gated_locked["estimate_skill_fired"] != "?":
            fail("skill/neg stay ? until the planned Builds key is unlocked")

    dump = {key: "?" for key in LOG_KEYS}
    dump["planned_build"] = {"outlook_id": "metal", "tier": "mid"}
    dump["threat_id"] = "boss_gilded_warden"
    dump["unlocked_builds"] = [{"outlook_id": "metal", "tier": "mid"}]
    dump["dex_enemies"] = [{"threat_id": "boss_gilded_warden", "seen": True, "fought": False}]
    if dump["estimate_band"] != "?":
        fail("displayed band stays ? until fought even when internal score has PUNISH_W")
    if "dex_builds" in dump:
        fail("dump must not grow a dex_builds key")
    required_20 = {"run_id", "player_owner_id", "CHAPTER_ROUND_COUNT"}
    for key in (
        "planned_build",
        "estimate_band",
        "estimate_favor_hits",
        "estimate_punish_hits",
        "estimate_skill_fired",
        "estimate_neg_warnings",
    ):
        if key in required_20:
            fail(f"{key} must not become a 20 Required field")

    hood_metal = estimate(
        MARROWVEIL,
        "ask_clean_hood",
        {"outlook_id": "metal", "tier": "low"},
        ["con_robe", "con_hood"],
        "boss_ivory_judge",
    )
    if "syn_neg_hood_metal" not in hood_metal["neg_warnings"]:
        fail("hood+Metal must warn Bucket Head (syn_neg_hood_metal)")
    if hood_metal["skill_fired"]:
        fail("Clean Hood must not fire when the hood-metal warn is live")


def main() -> int:
    check_source()
    check_spec()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK interactive-order slices 2–3 planner + estimate (docs/14, 17, 30, 31)")
    print("Planner chips set intent only. Brief writes seen. Estimate knobs stay Test knobs.")
    print("Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
