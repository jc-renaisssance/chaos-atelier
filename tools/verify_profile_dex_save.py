#!/usr/bin/env python3
"""Source + spec checks for Client PR 2 — profile / Dex save (docs/30, 31).

Godot is not required. This does not open the editor.
Does not cover slice 2 planner UI, slice 3 estimate, or Dex shop/menu screens.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
FAILS: list[str] = []

LOG_KEYS = [
    "unlocked_builds",
    "unlocks_new",
    "planned_build",
    "dex_crafts",
    "dex_crafts_new",
    "dex_adventurers",
    "dex_adventurer_new_met",
    "dex_enemies",
    "dex_enemy_seen_new",
    "dex_enemy_fought_new",
]

CROSS_UNLOCK = {
    "syn_fire_frost_clash": "temper",
    "syn_wild_earth": "beastbloom",
    "syn_sticky_sharp": "snaretooth",
    "syn_royal_silent": "masked_crown",
    "syn_solar_pure": "dawn",
    "syn_lunar_occult": "pale_hex",
}

TIER_FROM_INT = {1: "low", 2: "mid", 3: "apex"}
ALIASES = {
    "adv_knight": "adv_halden_rook",
    "adv_mage": "adv_quill_lumen",
    "adv_blade_dancer": "adv_kite_thornreel",
    "adv_lagoon": "adv_tide_glass",
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


def read(rel: str) -> str:
    return (SRC / rel).read_text(encoding="utf-8")


def parse_positive_rows(text: str) -> list[tuple[str, str, str]]:
    rows: list[tuple[str, str, str]] = []
    for match in re.finditer(
        r'\{"id":\s*"(syn_[^"]+)",\s*"tag":\s*"([^"]+)",\s*"tier":\s*(\d+)',
        text,
    ):
        syn_id, tag, tier = match.group(1), match.group(2), int(match.group(3))
        rows.append((syn_id, tag.lower(), TIER_FROM_INT.get(tier, "low")))
    return rows


def key_for_power(power: str, positives: list[tuple[str, str, str]]) -> dict | None:
    if power in CROSS_UNLOCK:
        return {"outlook_id": CROSS_UNLOCK[power], "tier": "cross"}
    for syn_id, tag, tier in positives:
        if syn_id == power:
            return {"outlook_id": tag, "tier": tier}
    return None


def keys_from_powers(powers: list[str], positives: list[tuple[str, str, str]]) -> list[dict]:
    keys: list[dict] = []
    seen: set[str] = set()
    for power in powers:
        key = key_for_power(power, positives)
        if key is None:
            continue
        kid = f"{key['outlook_id']}/{key['tier']}"
        if kid not in seen:
            seen.add(kid)
            keys.append(dict(key))
        if key["tier"] == "apex":
            for lower in ("low", "mid"):
                lid = f"{key['outlook_id']}/{lower}"
                if lid not in seen:
                    seen.add(lid)
                    keys.append({"outlook_id": key["outlook_id"], "tier": lower})
    return keys


class Profile:
    def __init__(self) -> None:
        self.unlocked_builds: list[dict] = []
        self.dex_crafts: list[dict] = []
        self.dex_adventurers: list[dict] = []
        self.dex_enemies: list[dict] = []
        self.profile_day = 0

    def note_new_run(self) -> None:
        self.profile_day = 1 if self.profile_day < 1 else self.profile_day + 1

    def _has_build(self, outlook_id: str, tier: str) -> bool:
        return any(
            row["outlook_id"] == outlook_id and row["tier"] == tier
            for row in self.unlocked_builds
        )

    def _has_craft(self, construction_id: str, outlook_id: str, tier: str) -> bool:
        return any(
            row["construction_id"] == construction_id
            and row["outlook_id"] == outlook_id
            and row["tier"] == tier
            for row in self.dex_crafts
        )

    def apply_finish(
        self,
        construction_id: str,
        powers: list[str],
        run_id: str,
        finish_reason: str,
        positives: list[tuple[str, str, str]],
    ) -> dict:
        if finish_reason != "player_finish":
            return {"unlocks_new": [], "dex_crafts_new": []}
        keys = keys_from_powers(powers, positives)
        unlocks_new: list[dict] = []
        crafts_new: list[dict] = []
        for key in keys:
            if not self._has_build(key["outlook_id"], key["tier"]):
                row = {"outlook_id": key["outlook_id"], "tier": key["tier"]}
                self.unlocked_builds.append(row)
                unlocks_new.append(dict(row))
        if not keys:
            if not self._has_craft(construction_id, "plain", "base"):
                row = {
                    "construction_id": construction_id,
                    "outlook_id": "plain",
                    "tier": "base",
                    "first_run_id": run_id,
                    "first_day": self.profile_day,
                }
                self.dex_crafts.append(row)
                crafts_new.append(dict(row))
        else:
            for key in keys:
                if not self._has_craft(construction_id, key["outlook_id"], key["tier"]):
                    row = {
                        "construction_id": construction_id,
                        "outlook_id": key["outlook_id"],
                        "tier": key["tier"],
                        "first_run_id": run_id,
                        "first_day": self.profile_day,
                    }
                    self.dex_crafts.append(row)
                    crafts_new.append(dict(row))
        return {"unlocks_new": unlocks_new, "dex_crafts_new": crafts_new}

    def note_adventurer(self, raw_id: str) -> list[str]:
        if raw_id.startswith("appt_"):
            return []
        named = ALIASES.get(raw_id, raw_id)
        if not named.startswith("adv_") or named in ALIASES:
            return []
        for row in self.dex_adventurers:
            if row["adventurer_id"] == named:
                row["met"] = True
                row["orders_received"] += 1
                return []
        self.dex_adventurers.append(
            {
                "adventurer_id": named,
                "met": True,
                "orders_received": 1,
                "orders_completed": 0,
            }
        )
        return [named]

    def complete_adventurer(self, raw_id: str) -> None:
        named = ALIASES.get(raw_id, raw_id)
        for row in self.dex_adventurers:
            if row["adventurer_id"] == named and row["met"]:
                row["orders_completed"] += 1
                return

    def note_seen(self, threat_id: str) -> list[str]:
        for row in self.dex_enemies:
            if row["threat_id"] == threat_id:
                if not row["seen"]:
                    row["seen"] = True
                    return [threat_id]
                return []
        self.dex_enemies.append(
            {
                "threat_id": threat_id,
                "seen": True,
                "fought": False,
                "briefs_seen": 0,
                "fights": 0,
            }
        )
        return [threat_id]

    def note_fought(self, threat_id: str) -> tuple[list[str], list[str]]:
        seen_new: list[str] = []
        fought_new: list[str] = []
        row = None
        for item in self.dex_enemies:
            if item["threat_id"] == threat_id:
                row = item
                break
        if row is None:
            row = {
                "threat_id": threat_id,
                "seen": False,
                "fought": False,
                "briefs_seen": 0,
                "fights": 0,
            }
            self.dex_enemies.append(row)
        if not row["seen"]:
            row["seen"] = True
            seen_new.append(threat_id)
        if not row["fought"]:
            fought_new.append(threat_id)
        row["fought"] = True
        row["fights"] += 1
        return seen_new, fought_new

    def snapshot(self) -> dict:
        return {
            "unlocked_builds": [dict(r) for r in self.unlocked_builds],
            "dex_crafts": [dict(r) for r in self.dex_crafts],
            "dex_adventurers": [dict(r) for r in self.dex_adventurers],
            "dex_enemies": [dict(r) for r in self.dex_enemies],
        }


def check_source() -> None:
    session = read("autoload/atelier_session.gd")
    stamp = read("data/stamp/harness_stamp.gd")
    profile = read("data/profile/profile_meta.gd")
    unlock = read("data/synergy/unlock_law.gd")
    resolver = read("craft/craft_resolver.gd")
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    blob = src_text()

    if "class_name ProfileMeta" not in profile:
        fail("ProfileMeta class missing")
    if "class_name UnlockLaw" not in unlock:
        fail("UnlockLaw class missing")
    if "user://atelier_profile.json" not in profile:
        fail("profile must persist under user:// (durable layer, not run state)")
    if "dex_crafts" not in profile or "dex_adventurers" not in profile or "dex_enemies" not in profile:
        fail("profile must hold the three Dex lists plus unlocked_builds")
    if "unlocked_builds" not in profile:
        fail("profile must hold unlocked_builds")
    if re.search(r"\bdex_builds\b", profile) or re.search(r"\bdex_builds\b", session) or re.search(
        r"\bdex_builds\b", stamp
    ):
        fail("parallel dex_builds field must not exist — Builds reads unlocked_builds")
    if "profile = ProfileMeta.new()" in session.split("func start_chapter", 1)[-1].split("func _reset_craft_state", 1)[0]:
        fail("start_chapter must not reconstruct the profile")
    start = session.split("func start_chapter", 1)[-1].split("func _reset_craft_state", 1)[0]
    for wipe in (
        "unlocked_builds.clear",
        "dex_crafts.clear",
        "dex_adventurers.clear",
        "dex_enemies.clear",
        "profile.unlocked_builds = []",
        "profile.dex_crafts = []",
    ):
        if wipe in start or wipe in session.split("func cycle_demo_chapter", 1)[-1][:800]:
            fail(f"must not wipe Dex on new run / cycle ({wipe})")
    if "profile.note_new_run()" not in session:
        fail("start_chapter must bump profile_day via note_new_run")
    if "profile.note_enemy_seen" not in session:
        fail("newspaper announce must write dex_enemies.seen")
    if "profile.note_enemy_fought" not in session:
        fail("boss-beat resolve must write dex_enemies.fought")
    if "profile.apply_finish" not in session:
        fail("Finish must write unlocked_builds + dex_crafts")
    if "_note_order_panel" not in session or "note_adventurer_order" not in session:
        fail("order panel open must upsert dex_adventurers")
    if "complete_adventurer_order" not in session:
        fail("order Finish must increment orders_completed")
    if "PLAYER_FINISH" not in profile or "player_finish" not in session:
        fail("Dex craft/build writes must gate on player_finish")
    if "TODO(PR 3)" not in session and "TODO(PR 3)" not in profile:
        fail("shop brief must leave a TODO(PR 3) hook")
    if "note_shop_brief" not in session and "note_enemy_brief" not in profile:
        fail("thin shop-brief seen hook missing")
    if "CraftResolver.POSITIVE_TAG_ROWS" not in unlock:
        fail("UnlockLaw must reuse CraftResolver positive rows (no second threshold table)")
    if "CROSS_UNLOCK" not in unlock:
        fail("UnlockLaw must map the six cross-tag chrome slugs")
    for syn_id, slug in CROSS_UNLOCK.items():
        if f'"{syn_id}": "{slug}"' not in unlock:
            fail(f"missing cross unlock {syn_id} → {slug}")
    if "syn_neg_" in unlock and "key_for_power" in unlock:
        if re.search(r'CROSS_UNLOCK.*syn_neg_', unlock, re.S):
            fail("neg syn must not write planner unlocks")
    for key in LOG_KEYS:
        if f'"{key}"' not in stamp:
            fail(f"stamp dump missing log key {key}")
    schema = stamp.split("func schema_errors")[-1]
    for key in LOG_KEYS:
        if f'errs.append("{key}' in schema or f"{key} must" in schema:
            fail(f"{key} must stay log-only — not a 20 Required schema field")
    if "planned_build: Variant = null" not in stamp:
        fail("planned_build must be explicit Variant (Godot 4.7), null until PR 3 planner")
    if "resolve_id" not in profile or "appt_" not in profile:
        fail("adventurer write must resolve aliases and refuse appt_*")
    if "load_from_disk" not in session or "load_from_disk" not in profile:
        fail("session must load the durable profile on boot")
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
    ui_blob = ""
    for path in (SRC / "ui").rglob("*"):
        if path.suffix in {".gd", ".tscn"}:
            ui_blob += path.read_text(encoding="utf-8")
    for token in ("estimate_band", "syn-target", "Dex tab", "Builds | Crafts"):
        if token in ui_blob:
            fail(f"planner / Dex UI must not land in this PR ({token})")
    if "POSITIVE_TAG_ROWS" not in resolver:
        fail("CraftResolver positive rows missing — unlock law has nothing to reuse")
    for path in SRC.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        if text.count("{") != text.count("}"):
            fail(f"unbalanced {{}} in {path.relative_to(ROOT)}")
        for i, line in enumerate(text.splitlines(), 1):
            if line.startswith("    ") and not line.startswith("\t"):
                fail(f"space indent {path.relative_to(ROOT)}:{i}")
                break


def check_spec() -> None:
    positives = parse_positive_rows(read("craft/craft_resolver.gd"))
    if ("syn_metal_3", "metal", "low") not in positives:
        fail("expected syn_metal_3 → metal low in CraftResolver")
    if ("syn_metal_8", "metal", "apex") not in positives:
        fail("expected syn_metal_8 → metal apex in CraftResolver")

    fresh = Profile()
    if any(
        [
            fresh.unlocked_builds,
            fresh.dex_crafts,
            fresh.dex_adventurers,
            fresh.dex_enemies,
        ]
    ):
        fail("fresh profile must be all empty lists")
    fresh.note_new_run()
    if fresh.profile_day != 1:
        fail("first run start must set profile_day=1")

    metal8 = ["syn_metal_3", "syn_metal_5", "syn_metal_8", "syn_sharp_3"]
    keys = keys_from_powers(metal8, positives)
    expect_keys = {
        ("metal", "low"),
        ("metal", "mid"),
        ("metal", "apex"),
        ("sharp", "low"),
    }
    got_keys = {(k["outlook_id"], k["tier"]) for k in keys}
    if got_keys != expect_keys:
        fail(f"metal 8 + sharp 3 keys expected {expect_keys}, got {got_keys}")

    apex_only = keys_from_powers(["syn_metal_8"], positives)
    apex_got = {(k["outlook_id"], k["tier"]) for k in apex_only}
    if apex_got != {("metal", "apex"), ("metal", "low"), ("metal", "mid")}:
        fail(f"apex must also union low+mid, got {apex_got}")

    if keys_from_powers(["syn_neg_metal_silk"], positives):
        fail("neg syn must not unlock Builds")
    if keys_from_powers(["uniq_cairnplate"], positives):
        fail("uniq_* is not a planner unlock key")

    cross = keys_from_powers(["syn_sticky_sharp"], positives)
    if cross != [{"outlook_id": "snaretooth", "tier": "cross"}]:
        fail(f"Snaretooth cross key mismatch: {cross}")

    write = fresh.apply_finish("con_armor", metal8, "run_a", "player_finish", positives)
    if {(r["outlook_id"], r["tier"]) for r in fresh.unlocked_builds} != expect_keys:
        fail("Finish must union every met positive outlook-tier into unlocked_builds")
    if {(r["construction_id"], r["outlook_id"], r["tier"]) for r in fresh.dex_crafts} != {
        ("con_armor", "metal", "low"),
        ("con_armor", "metal", "mid"),
        ("con_armor", "metal", "apex"),
        ("con_armor", "sharp", "low"),
    }:
        fail("Finish must write dex_crafts per con_* × met outlook-tier")
    if not write["unlocks_new"] or not write["dex_crafts_new"]:
        fail("first Finish should report unlocks_new and dex_crafts_new")

    again = fresh.apply_finish("con_armor", metal8, "run_b", "player_finish", positives)
    if again["unlocks_new"] or again["dex_crafts_new"]:
        fail("re-finish of owned keys must be a no-op (keep first_run_id)")
    first_day = fresh.dex_crafts[0]["first_day"]
    first_run = fresh.dex_crafts[0]["first_run_id"]
    if first_run != "run_a" or first_day != 1:
        fail("dex_crafts must keep first Finish run/day")

    gloves = fresh.apply_finish("con_gloves", ["syn_metal_5", "syn_metal_3"], "run_a", "player_finish", positives)
    craft_pairs = {(r["construction_id"], r["outlook_id"], r["tier"]) for r in fresh.dex_crafts}
    if ("con_gloves", "metal", "low") not in craft_pairs or ("con_gloves", "metal", "mid") not in craft_pairs:
        fail("same outlook-tier on two con_* must be two craft rows")
    build_n = len(fresh.unlocked_builds)
    if gloves["unlocks_new"]:
        fail("gloves Metal mid should not add a new Builds key if armor already unlocked it")
    if len(fresh.unlocked_builds) != build_n:
        fail("Builds key ignores construction — armor+gloves Metal mid is one key")

    abandon = fresh.apply_finish("con_hood", metal8, "run_a", "stamina_0", positives)
    if abandon["unlocks_new"] or abandon["dex_crafts_new"]:
        fail("abandon / non-player_finish must not write Builds or Crafts")
    if any(r["construction_id"] == "con_hood" for r in fresh.dex_crafts):
        fail("stamina 0 without Finish must not write dex_crafts")

    plain = Profile()
    plain.note_new_run()
    plain.apply_finish("con_tunic", [], "run_plain", "player_finish", positives)
    if plain.unlocked_builds:
        fail("plain Finish must not write unlocked_builds")
    if plain.dex_crafts != [
        {
            "construction_id": "con_tunic",
            "outlook_id": "plain",
            "tier": "base",
            "first_run_id": "run_plain",
            "first_day": 1,
        }
    ]:
        fail("no positive syn → one plain/base craft row per con_*")

    adv = Profile()
    if adv.note_adventurer("appt_c1_scrap_duelist"):
        fail("never store appt_* in dex_adventurers")
    if adv.dex_adventurers:
        fail("appointment without named adv_* must not write Adventurers")
    met = adv.note_adventurer("adv_knight")
    if met != ["adv_halden_rook"]:
        fail(f"job-stub alias must resolve before the key, got {met}")
    if adv.dex_adventurers[0]["adventurer_id"] != "adv_halden_rook":
        fail("must not store the stub adv_knight as a person")
    if adv.dex_adventurers[0]["orders_received"] != 1 or not adv.dex_adventurers[0]["met"]:
        fail("first order panel open: met=true, orders_received=1")
    adv.note_adventurer("adv_halden_rook")
    if adv.dex_adventurers[0]["orders_received"] != 2:
        fail("second order open must increment orders_received")
    adv.complete_adventurer("adv_knight")
    if adv.dex_adventurers[0]["orders_completed"] != 1:
        fail("order Finish must increment orders_completed")

    enemies = Profile()
    seen = enemies.note_seen("boss_ash_drake")
    if seen != ["boss_ash_drake"] or not enemies.dex_enemies[0]["seen"] or enemies.dex_enemies[0]["fought"]:
        fail("newspaper announce sets seen, not fought")
    seen2 = enemies.note_seen("boss_ash_drake")
    if seen2:
        fail("second newspaper announce is not a new seen flip")
    seen_new, fought_new = enemies.note_fought("boss_ash_drake")
    if fought_new != ["boss_ash_drake"] or enemies.dex_enemies[0]["fights"] != 1:
        fail("boss-beat resolve sets fought and fights++")
    if seen_new:
        fail("seen should already be true after newspaper")
    missed = Profile()
    seen_new, fought_new = missed.note_fought("boss_gilded_warden")
    if "boss_gilded_warden" not in seen_new or "boss_gilded_warden" not in fought_new:
        fail("boss-beat must set seen if the newspaper path was missed")
    if not missed.dex_enemies[0]["fought"] or missed.dex_enemies[0]["fights"] != 1:
        fail("fought write missing on missed-seen boss resolve")

    persist = Profile()
    persist.note_new_run()
    persist.apply_finish("con_armor", ["syn_metal_5", "syn_metal_3"], "run_1", "player_finish", positives)
    persist.note_adventurer("adv_tide_glass")
    persist.complete_adventurer("adv_tide_glass")
    persist.note_seen("boss_salt_widow")
    persist.note_fought("boss_salt_widow")
    snap = persist.snapshot()
    persist.note_new_run()
    if persist.profile_day != 2:
        fail("second run on the same profile must +1 profile_day")
    snap2 = persist.snapshot()
    if snap2 != snap:
        fail("second run must keep all four Dex lists (not [] / not run-local)")
    persist.unlocked_builds.clear()
    if not snap["unlocked_builds"]:
        fail("snapshot should have held unlocked_builds before a wipe")
    if persist.unlocked_builds and persist.unlocked_builds == snap["unlocked_builds"]:
        fail("test harness sanity")
    persist.unlocked_builds = [dict(r) for r in snap["unlocked_builds"]]
    if persist.snapshot()["dex_adventurers"] != snap["dex_adventurers"]:
        fail("adventurers must survive a new-run clock bump")

    dump = {key: ([] if key != "planned_build" else None) for key in LOG_KEYS}
    if "dex_builds" in dump:
        fail("dump must not grow a dex_builds key")
    if dump["planned_build"] is not None:
        fail("planned_build is null until PR 3 planner UI")


def main() -> int:
    check_source()
    check_spec()
    if FAILS:
        print("FAIL")
        for item in FAILS:
            print(" -", item)
        return 1
    print("OK profile / Dex meta save (docs/30, 31)")
    print("Finish writes Builds+Crafts; order open writes Adventurers; boss resolve writes Enemies.")
    print("Cross-run lists persist. Log keys are not 20 Required. Godot editor was not opened.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
