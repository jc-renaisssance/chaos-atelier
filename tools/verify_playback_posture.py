#!/usr/bin/env python3
"""Source lock for interactive-order slice 4 (docs/30 Gate A · Surface A · Socket A).

Godot is not required. Zero posture files must stay legal: rows are data,
in_shop hides, playback uses a flat placeholder / 1×1 stand-in, never a 96 bust.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
PLAYBACK = SRC / "ui" / "playback"
FAILS: list[str] = []

LOG_KEYS = (
    "playback_played",
    "playback_skipped",
    "playback_beats",
    "playback_actor_id",
)


def fail(msg: str) -> None:
    FAILS.append(msg)


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def beat_ids(
    favor: list[str],
    punish: list[str],
    cleared: bool,
    stars: object,
    skill_id: str,
) -> list[tuple[str, str]]:
    """Spec mirror of PlaybackBeats.build. Same stamp → same rows. No sort, no dedupe."""
    rows: list[tuple[str, str]] = [("open", "in_fight")]
    for tag in favor:
        rows.append((f"favor:{tag}", "attack"))
    for tag in punish:
        rows.append((f"punish:{tag}", "defend"))
    rows.append(("skill", "ult"))
    result_slot = "in_fight" if cleared else "defend"
    rows.append(("result", result_slot))
    if stars not in (1, 2, 3, 4, 5):
        if skill_id != "?" and not str(skill_id).startswith("ask_"):
            pass
    return rows


def check_spec() -> None:
    plain = beat_ids([], [], True, 3, "ask_plate_oath")
    if [row[0] for row in plain] != ["open", "skill", "result"]:
        fail(f"empty hits must be open/skill/result, got {plain}")
    if plain[0][1] != "in_fight" or plain[1][1] != "ult" or plain[2][1] != "in_fight":
        fail(f"cleared result must use in_fight, got {plain}")
    lost = beat_ids(["Metal", "Sharp"], ["Soft"], False, 1, "ask_plate_oath")
    ids = [row[0] for row in lost]
    if ids != ["open", "favor:Metal", "favor:Sharp", "punish:Soft", "skill", "result"]:
        fail(f"favor then punish, resolver order, no dedupe sort, got {ids}")
    slots = [row[1] for row in lost]
    if slots != ["in_fight", "attack", "attack", "defend", "ult", "defend"]:
        fail(f"uncleared result must use defend, got {slots}")
    dup = beat_ids(["Metal", "Metal"], [], True, 5, "ask_x")
    if [row[0] for row in dup].count("favor:Metal") != 2:
        fail("duplicate favor tags must not be deduped")
    if any(row[0] == "in_shop" or row[1] == "in_shop" for row in lost):
        fail("in_shop is not a beat")


def check_source() -> None:
    beats = read(PLAYBACK / "playback_beats.gd")
    socket = read(PLAYBACK / "posture_socket.gd")
    step = read(PLAYBACK / "playback_step.gd")
    session = read(SRC / "autoload" / "atelier_session.gd")
    stamp = read(SRC / "data" / "stamp" / "harness_stamp.gd")
    table = read(SRC / "ui" / "craft" / "craft_table.gd")
    board = read(SRC / "ui" / "schedule" / "schedule_board.gd")
    rules = read(SRC / "chapter" / "schedule_rules.gd")
    dex = read(SRC / "ui" / "dex" / "dex_screen.gd")
    route = read(SRC / "ui" / "schedule" / "route_node_view.gd")
    build = beats.split("static func build(", 1)[-1].split("static func beat_ids", 1)[0]

    if 'res://assets/adv/posture/%s_%s.png' not in socket:
        fail("socket must wire res://assets/adv/posture/<adv_id>_<slot>.png")
    if "CELL_PX := 64" not in socket or "DISPLAY_PX := 128" not in socket:
        fail("socket is 64×64 shown at integer 2×")
    for slot in ("in_shop", "in_fight", "ult", "defend", "attack"):
        if slot not in socket:
            fail(f"socket missing slot {slot}")
    if "begins_with(\"appt_\")" not in socket:
        fail("appt_* must not open a posture path")
    if "Image.create(1, 1" not in socket:
        fail("failed texture load must keep a 1×1 stand-in")
    if "_placeholder" not in socket:
        fail("missing playback png must use a flat placeholder")
    if "assets/adv/adv_" in socket or "PORTRAITS" in socket:
        fail("do not substitute the 96 bust into a posture slot")
    shop = socket.split("static func shop_still", 1)[-1].split("static func playback_still", 1)[0]
    if "hidden" not in shop:
        fail("missing in_shop must hide that slot")
    if "assets/adv/" in beats:
        fail("beat list must not read posture files")
    if "MissionResolver" in beats or "MissionResolver" in step or "MissionResolver" in socket:
        fail("playback must not run a second sim")
    for blob, name in ((beats, "beats"), (socket, "socket"), (step, "step")):
        if re.search(r"\brand[a-z_]*\s*\(", blob) or "RandomNumberGenerator" in blob:
            fail(f"{name} must not roll RNG")
        if "Tween" in blob:
            fail(f"{name} must not tween hp")
    if '"open"' not in build or '"skill"' not in build or '"result"' not in build:
        fail("build must emit open, skill, and result")
    if build.find("favor:") > build.find("punish:") or build.find("punish:") > build.find('"skill"'):
        fail("beat order must be open, favor, punish, skill, result")
    if '"in_shop"' in build:
        fail("in_shop is not a beat id")
    if "star_text" not in beats or 'return "?"' not in beats:
        fail("missing skill star must display ? and still emit the beat")
    if 'btn.text = "Skip"' not in step and '_btn("Skip"' not in step:
        fail("playback needs a Skip control")
    if "BEAT_SEC" not in step:
        fail("beat length must be a client constant, not a stamp field")
    if "TEXTURE_FILTER_NEAREST" not in step or "TEXTURE_FILTER_NEAREST" not in table:
        fail("posture stills use nearest filter")
    if "InShopPosture" not in table or "shop_still" not in table:
        fail("order panel must host in_shop beside the bust")
    if "assets/adv/posture" in dex or "PostureSocket" in dex:
        fail("in_shop must not land on Dex")
    if "assets/adv/posture" in route or "PostureSocket" in route:
        fail("in_shop must not land on the route graph")
    if "finish_playback" not in session or "continue_piece_report" not in session:
        fail("session must end playback into the piece report, then continue")
    finish = session.split("func finish_playback", 1)[-1].split("\nfunc ", 1)[0]
    if "piece_report_open = true" not in finish:
        fail("Skip and the natural end must open this piece's report")
    if "_return_to_schedule" in finish:
        fail("ending playback must not skip the report or later pieces")
    cont = session.split("func continue_piece_report", 1)[-1].split("\nfunc ", 1)[0]
    if "_show_playback_cursor" not in cont or "_return_to_schedule" not in cont:
        fail("closing a piece report starts the next playback, then the existing report")
    gate = session.split("func _gate_a_plays", 1)[-1].split("\nfunc ", 1)[0]
    if "MissionKind.BOSS" not in gate or "RoundAction.WALK_IN" not in gate or "RoundAction.APPOINTMENT" not in gate:
        fail("Gate A plays on adventurer order, appointment, and boss beat")
    if "PLAYER_FINISH" not in gate:
        fail("only player_finish plays")
    if "MissionKind.PREP" in gate and "return true" in gate.split("MissionKind.PREP", 1)[-1][:80]:
        fail("prep must not play")
    cant = session.split("func _emit_cant_craft", 1)[-1].split("\nfunc ", 1)[0]
    if "_begin_playback_gate" in cant or "playback_open = true" in cant:
        fail("cant_craft goes straight to the report")
    if "_begin_playback_gate" not in session.split("func _resolve_session", 1)[-1].split("func _gate_a_plays", 1)[0]:
        fail("playback inserts after the resolver loop")
    if "build_piece_report" not in rules:
        fail("piece report must be the docs/23 card")
    if "PlaybackStep" not in board:
        fail("schedule board must host the playback step")
    for key in LOG_KEYS:
        if f'"{key}"' not in stamp:
            fail(f"stamp dump missing log key {key}")
    schema = stamp.split("func schema_errors", 1)[-1]
    for key in LOG_KEYS:
        if f'errs.append("{key}' in schema or f"{key} must" in schema:
            fail(f"{key} must stay log-only — not a 20 Required schema field")
    if "BEAT_SEC" in stamp:
        fail("do not stamp the beat duration")
    posture_dir = ROOT / "assets" / "adv" / "posture"
    if posture_dir.exists() and any(posture_dir.glob("*.png")):
        fail("this wire ships placeholders — do not add posture pngs")


def check_gd_hygiene() -> None:
    blob_parts: list[str] = []
    for path in SRC.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        blob_parts.append(text)
        if text.count("{") != text.count("}"):
            fail(f"unbalanced {{}} in {path.relative_to(ROOT)}")
        if text.count("(") != text.count(")"):
            fail(f"unbalanced () in {path.relative_to(ROOT)}")
        for i, line in enumerate(text.splitlines(), 1):
            if line.startswith("    ") and not line.startswith("\t"):
                fail(f"space indent {path.relative_to(ROOT)}:{i}")
                break
    blob = "\n".join(blob_parts)
    if re.search(r"Color\.html\s*\(", blob):
        fail("Color.html(...) is not a constant expression in Godot 4.7")
    if re.search(r":=\s*[^\n]*\belse\s+null\b", blob):
        fail(":= … else null infers Variant — Godot 4.7.2 warning-as-error")
    if re.search(r"const\s+\w+\s*:?=?\s*Packed\w*Array\s*\(", blob):
        fail("const Packed*Array(...) is not a constant expression in Godot 4.7")


def main() -> int:
    check_spec()
    check_source()
    check_gd_hygiene()
    if FAILS:
        print(f"playback posture: {len(FAILS)} failure(s)")
        for msg in FAILS:
            print(f"  - {msg}")
        return 1
    print("Playback Gate A / Surface A / Socket A locked. Zero posture files stay legal.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
