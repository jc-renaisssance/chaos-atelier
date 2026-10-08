class_name ProfileMeta
extends RefCounted
## Cross-run Dex + unlocked_builds (docs/30 slice 2, docs/31).
## Same profile / meta save layer. Not run state. Fresh profile = all empty.
## Never clear on run end, run_over, boss_death, or new run.

const SAVE_PATH := "user://atelier_profile.json"
const TIERS_BUILD := PackedStringArray(["low", "mid", "apex", "cross"])
const TIERS_CRAFT := PackedStringArray(["low", "mid", "apex", "cross", "base"])

var unlocked_builds: Array = [] ## {outlook_id, tier}
var dex_crafts: Array = [] ## {construction_id, outlook_id, tier, first_run_id, first_day}
var dex_adventurers: Array = [] ## {adventurer_id, met, orders_received, orders_completed}
var dex_enemies: Array = [] ## {threat_id, seen, fought, briefs_seen, fights}
var profile_day: int = 0 ## knob: 1 on first run start, +1 per new run


func is_fresh() -> bool:
	return (
		unlocked_builds.is_empty()
		and dex_crafts.is_empty()
		and dex_adventurers.is_empty()
		and dex_enemies.is_empty()
	)


func note_new_run() -> void:
	## Day clock is a knob (docs/31). Each start_chapter mints a new run_id today.
	if profile_day < 1:
		profile_day = 1
	else:
		profile_day += 1
	save_to_disk()


func apply_finish(
	construction_id: String,
	powers_positive: PackedStringArray,
	run_id: String,
	finish_reason: GameEnums.FinishReason
) -> Dictionary:
	var empty := {
		"unlocks_new": [],
		"dex_crafts_new": [],
	}
	if finish_reason != GameEnums.FinishReason.PLAYER_FINISH:
		return empty
	if construction_id.is_empty() or not construction_id.begins_with("con_"):
		return empty
	var keys: Array = UnlockLaw.keys_from_powers(powers_positive)
	var unlocks_new: Array = []
	var crafts_new: Array = []
	for key in keys:
		var row: Dictionary = key
		if _union_build(String(row.get("outlook_id", "")), String(row.get("tier", ""))):
			unlocks_new.append(_build_row(String(row.get("outlook_id", "")), String(row.get("tier", ""))))
	if keys.is_empty():
		if _union_craft(construction_id, "plain", "base", run_id, profile_day):
			crafts_new.append(_craft_row(construction_id, "plain", "base", run_id, profile_day))
	else:
		for key in keys:
			var row: Dictionary = key
			var outlook_id := String(row.get("outlook_id", ""))
			var tier := String(row.get("tier", ""))
			if _union_craft(construction_id, outlook_id, tier, run_id, profile_day):
				crafts_new.append(_craft_row(construction_id, outlook_id, tier, run_id, profile_day))
	save_to_disk()
	return {
		"unlocks_new": unlocks_new,
		"dex_crafts_new": crafts_new,
	}


func note_adventurer_order(raw_id: String) -> Dictionary:
	var adventurer_id := _named_adventurer_id(raw_id)
	var empty := {"dex_adventurer_new_met": []}
	if adventurer_id.is_empty():
		return empty
	var row := _adventurer_row(adventurer_id)
	var new_met: Array = []
	if row.is_empty():
		row = {
			"adventurer_id": adventurer_id,
			"met": true,
			"orders_received": 1,
			"orders_completed": 0,
		}
		dex_adventurers.append(row)
		new_met.append(adventurer_id)
	else:
		if not bool(row.get("met", false)):
			new_met.append(adventurer_id)
		row["met"] = true
		row["orders_received"] = int(row.get("orders_received", 0)) + 1
	save_to_disk()
	return {"dex_adventurer_new_met": new_met}


func complete_adventurer_order(raw_id: String) -> void:
	var adventurer_id := _named_adventurer_id(raw_id)
	if adventurer_id.is_empty():
		return
	var row := _adventurer_row(adventurer_id)
	if row.is_empty() or not bool(row.get("met", false)):
		return
	row["orders_completed"] = int(row.get("orders_completed", 0)) + 1
	save_to_disk()


func note_enemy_seen(threat_id: String) -> Dictionary:
	## Newspaper announce of chapter_boss_id. Sets seen once; count bump optional.
	return _upsert_enemy(threat_id, true, false, false)


func note_enemy_brief(threat_id: String) -> Dictionary:
	## TODO(PR 3): call from the guild-quest poster / estimate brief when that UI lands.
	## Shop brief writes seen + briefs_seen++, not fought.
	return _upsert_enemy(threat_id, true, false, true)


func note_enemy_fought(threat_id: String) -> Dictionary:
	## Boss-beat mission resolve (win / lose / death / cant_craft). fought + fights++.
	## seen=true if the newspaper path was missed.
	return _upsert_enemy(threat_id, true, true, false)


func has_build(outlook_id: String, tier: String) -> bool:
	return not _find_build(outlook_id, tier).is_empty()


func to_dict() -> Dictionary:
	return {
		"unlocked_builds": _dup_rows(unlocked_builds),
		"dex_crafts": _dup_rows(dex_crafts),
		"dex_adventurers": _dup_rows(dex_adventurers),
		"dex_enemies": _dup_rows(dex_enemies),
		"profile_day": profile_day,
	}


func from_dict(data: Dictionary) -> void:
	unlocked_builds = _parse_builds(data.get("unlocked_builds", []))
	dex_crafts = _parse_crafts(data.get("dex_crafts", []))
	dex_adventurers = _parse_adventurers(data.get("dex_adventurers", []))
	dex_enemies = _parse_enemies(data.get("dex_enemies", []))
	profile_day = int(data.get("profile_day", 0))


func load_from_disk() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		from_dict(parsed as Dictionary)


func save_to_disk() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(to_dict()))


func _named_adventurer_id(raw_id: String) -> String:
	if raw_id.is_empty() or raw_id.begins_with("appt_"):
		return ""
	var named := AdventurerCatalog.resolve_id(raw_id)
	if named.is_empty() or not AdventurerCatalog.is_named(named):
		return ""
	if named.begins_with("appt_"):
		return ""
	return named


func _union_build(outlook_id: String, tier: String) -> bool:
	if outlook_id.is_empty() or outlook_id == "plain":
		return false
	if not TIERS_BUILD.has(tier):
		return false
	if not _find_build(outlook_id, tier).is_empty():
		return false
	unlocked_builds.append(_build_row(outlook_id, tier))
	return true


func _union_craft(
	construction_id: String,
	outlook_id: String,
	tier: String,
	run_id: String,
	day: int
) -> bool:
	if construction_id.is_empty() or outlook_id.is_empty():
		return false
	if not TIERS_CRAFT.has(tier):
		return false
	if tier == "base" and outlook_id != "plain":
		return false
	if outlook_id == "plain" and tier != "base":
		return false
	if not _find_craft(construction_id, outlook_id, tier).is_empty():
		return false
	dex_crafts.append(_craft_row(construction_id, outlook_id, tier, run_id, day))
	return true


func _upsert_enemy(threat_id: String, mark_seen: bool, mark_fought: bool, bump_brief: bool) -> Dictionary:
	var seen_new: Array = []
	var fought_new: Array = []
	if threat_id.is_empty() or not ThreatCatalog.is_boss(threat_id):
		return {"dex_enemy_seen_new": seen_new, "dex_enemy_fought_new": fought_new}
	var row := _enemy_row(threat_id)
	if row.is_empty():
		row = {
			"threat_id": threat_id,
			"seen": false,
			"fought": false,
			"briefs_seen": 0,
			"fights": 0,
		}
		dex_enemies.append(row)
	if mark_seen and not bool(row.get("seen", false)):
		row["seen"] = true
		seen_new.append(threat_id)
	elif mark_seen:
		row["seen"] = true
	if bump_brief:
		row["briefs_seen"] = int(row.get("briefs_seen", 0)) + 1
		if not bool(row.get("seen", false)):
			row["seen"] = true
			seen_new.append(threat_id)
	if mark_fought:
		if not bool(row.get("fought", false)):
			fought_new.append(threat_id)
		row["fought"] = true
		row["fights"] = int(row.get("fights", 0)) + 1
		if not bool(row.get("seen", false)):
			row["seen"] = true
			seen_new.append(threat_id)
	save_to_disk()
	return {"dex_enemy_seen_new": seen_new, "dex_enemy_fought_new": fought_new}


func _find_build(outlook_id: String, tier: String) -> Dictionary:
	for row in unlocked_builds:
		var item: Dictionary = row
		if String(item.get("outlook_id", "")) == outlook_id and String(item.get("tier", "")) == tier:
			return item
	return {}


func _find_craft(construction_id: String, outlook_id: String, tier: String) -> Dictionary:
	for row in dex_crafts:
		var item: Dictionary = row
		if (
			String(item.get("construction_id", "")) == construction_id
			and String(item.get("outlook_id", "")) == outlook_id
			and String(item.get("tier", "")) == tier
		):
			return item
	return {}


func _adventurer_row(adventurer_id: String) -> Dictionary:
	for row in dex_adventurers:
		var item: Dictionary = row
		if String(item.get("adventurer_id", "")) == adventurer_id:
			return item
	return {}


func _enemy_row(threat_id: String) -> Dictionary:
	for row in dex_enemies:
		var item: Dictionary = row
		if String(item.get("threat_id", "")) == threat_id:
			return item
	return {}


func _build_row(outlook_id: String, tier: String) -> Dictionary:
	return {"outlook_id": outlook_id, "tier": tier}


func _craft_row(
	construction_id: String,
	outlook_id: String,
	tier: String,
	run_id: String,
	day: int
) -> Dictionary:
	return {
		"construction_id": construction_id,
		"outlook_id": outlook_id,
		"tier": tier,
		"first_run_id": run_id,
		"first_day": day,
	}


func _parse_builds(raw: Variant) -> Array:
	var out: Array = []
	if not raw is Array:
		return out
	for row in raw:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		var outlook_id := String(item.get("outlook_id", ""))
		var tier := String(item.get("tier", ""))
		if outlook_id.is_empty() or not TIERS_BUILD.has(tier):
			continue
		if _find_in(out, ["outlook_id", "tier"], [outlook_id, tier]):
			continue
		out.append(_build_row(outlook_id, tier))
	return out


func _parse_crafts(raw: Variant) -> Array:
	var out: Array = []
	if not raw is Array:
		return out
	for row in raw:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		var construction_id := String(item.get("construction_id", ""))
		var outlook_id := String(item.get("outlook_id", ""))
		var tier := String(item.get("tier", ""))
		if construction_id.is_empty() or outlook_id.is_empty() or not TIERS_CRAFT.has(tier):
			continue
		if _find_in(out, ["construction_id", "outlook_id", "tier"], [construction_id, outlook_id, tier]):
			continue
		out.append(
			_craft_row(
				construction_id,
				outlook_id,
				tier,
				String(item.get("first_run_id", "")),
				int(item.get("first_day", 0))
			)
		)
	return out


func _parse_adventurers(raw: Variant) -> Array:
	var out: Array = []
	if not raw is Array:
		return out
	for row in raw:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		var adventurer_id := _named_adventurer_id(String(item.get("adventurer_id", "")))
		if adventurer_id.is_empty():
			continue
		if _find_in(out, ["adventurer_id"], [adventurer_id]):
			continue
		out.append({
			"adventurer_id": adventurer_id,
			"met": bool(item.get("met", false)),
			"orders_received": int(item.get("orders_received", 0)),
			"orders_completed": int(item.get("orders_completed", 0)),
		})
	return out


func _parse_enemies(raw: Variant) -> Array:
	var out: Array = []
	if not raw is Array:
		return out
	for row in raw:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		var threat_id := String(item.get("threat_id", ""))
		if threat_id.is_empty() or not ThreatCatalog.is_boss(threat_id):
			continue
		if _find_in(out, ["threat_id"], [threat_id]):
			continue
		out.append({
			"threat_id": threat_id,
			"seen": bool(item.get("seen", false)),
			"fought": bool(item.get("fought", false)),
			"briefs_seen": int(item.get("briefs_seen", 0)),
			"fights": int(item.get("fights", 0)),
		})
	return out


func _find_in(rows: Array, fields: Array, values: Array) -> bool:
	for row in rows:
		var item: Dictionary = row
		var ok := true
		for i in range(fields.size()):
			if String(item.get(fields[i], "")) != String(values[i]):
				ok = false
				break
		if ok:
			return true
	return false


func _dup_rows(rows: Array) -> Array:
	var out: Array = []
	for row in rows:
		if row is Dictionary:
			out.append((row as Dictionary).duplicate())
	return out
