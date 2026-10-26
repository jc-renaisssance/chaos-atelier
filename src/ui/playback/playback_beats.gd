class_name PlaybackBeats
extends RefCounted
## Surface A beat list (docs/30 slice 4). Pure function of the resolver stamp.
## No RNG. No second sim. Does not read posture files. in_shop is not a beat.


## Named adv_* after the job-alias resolve. appt_* and unknown ids are null — no socket.
static func actor_id_for(raw_id: String) -> Variant:
	if raw_id.is_empty() or raw_id.begins_with("appt_"):
		return null
	var named := AdventurerCatalog.resolve_id(raw_id)
	if named.is_empty() or named.begins_with("appt_"):
		return null
	if not named.begins_with("adv_"):
		return null
	if not AdventurerCatalog.is_named(named):
		return null
	return named


## Open-row person token: actor id, else the appt_* id, else a dash.
static func open_person_label(actor: Variant, appt_id: String) -> String:
	if actor is String and not String(actor).is_empty():
		return String(actor)
	if appt_id.begins_with("appt_"):
		return appt_id
	return "—"


## Poster rule (slice 3): seen → name, else ?. Caller forces seen for non-boss threats.
static func threat_label(threat_id: String, seen: bool) -> String:
	if threat_id.is_empty():
		return "—"
	if not seen:
		return "?"
	var name := ThreatCatalog.display_name(threat_id)
	if name.is_empty():
		return "?"
	return name


## Same stamp → same rows. Favor then punish, resolver order. No sort. No dedupe.
static func build(
	result: Dictionary,
	person_label: String,
	threat_label_text: String,
	skill_id: String,
	piece_index: int
) -> Array:
	var rows: Array = []
	rows.append(_row(
		"open",
		"in_fight",
		"%s  ·  %s" % [person_label, threat_label_text],
		piece_index
	))
	for tag in _as_strings(result.get("favor_tags_hit", [])):
		rows.append(_row("favor:%s" % tag, "attack", tag, piece_index))
	for tag in _as_strings(result.get("punish_tags_hit", [])):
		rows.append(_row("punish:%s" % tag, "defend", tag, piece_index))
	var ask := skill_id
	if ask.is_empty() or not ask.begins_with("ask_"):
		ask = "?"
	rows.append(_row(
		"skill",
		"ult",
		"%s  ·  ★%s" % [ask, star_text(result.get("skill_effectiveness", null))],
		piece_index
	))
	var result_slot := "defend"
	if bool(result.get("cleared", false)):
		result_slot = "in_fight"
	rows.append(_row(
		"result",
		result_slot,
		"%s  ·  %s  ·  hp %s" % [
			_enum_text(GameEnums.rating_wire(result.get("rating", GameEnums.Rating.NONE))),
			_enum_text(GameEnums.outcome_wire(result.get("outcome", GameEnums.Outcome.NONE))),
			_hp_text(result.get("hp_remaining", null)),
		],
		piece_index
	))
	return rows


static func beat_ids(rows: Array) -> Array:
	var ids: Array = []
	for row in rows:
		if row is Dictionary:
			ids.append(String(row.get("id", "")))
	return ids


## Missing or out of 1..5 → ?. Not a cutoff — the skill beat still exists.
static func star_text(value: Variant) -> String:
	if value is int or value is float:
		var n := int(value)
		if n >= 1 and n <= 5:
			return str(n)
	return "?"


## Piece vignette (docs/35 lock 5). Not the fight. No hp, no cleared, no in_fight opener.
## The one fight is PlaybackBeats.build on the combined gear, once, after the last report.
static func vignette(result: Dictionary, piece_index: int, construction_name: String) -> Array:
	var outlook := String(result.get("outlook_id", "plain"))
	var rarity_wire: Variant = GameEnums.craft_rarity_wire(result.get("craft_rarity", GameEnums.CraftRarity.NONE))
	var rarity := _wire_text(rarity_wire)
	var who := construction_name if not construction_name.is_empty() else "Piece"
	var rows: Array = []
	rows.append(_row("open", "defend", "%s  ·  %s" % [who, outlook], piece_index))
	var tags := _tag_counts_line(result.get("tag_counts", {}))
	if not tags.is_empty():
		rows.append(_row("tags", "defend", tags, piece_index))
	rows.append(_row("result", "defend", "%s  ·  %s" % [rarity, outlook], piece_index))
	return rows


static func _row(beat_id: String, slot: String, label: String, piece_index: int) -> Dictionary:
	return {
		"id": beat_id,
		"slot": slot,
		"label": label,
		"piece_index": piece_index,
	}


static func _tag_counts_line(value: Variant) -> String:
	if not (value is Dictionary):
		return ""
	var bag: Dictionary = value
	var bits := PackedStringArray()
	for key in bag.keys():
		bits.append("%s ×%s" % [String(key), str(bag[key])])
	if bits.is_empty():
		return ""
	return ", ".join(bits)


static func _wire_text(value: Variant) -> String:
	if value == null:
		return "?"
	var text := String(value)
	if text.is_empty():
		return "?"
	return text


static func _as_strings(value: Variant) -> Array:
	var out: Array = []
	if value is PackedStringArray:
		var packed: PackedStringArray = value
		for item in packed:
			out.append(String(item))
		return out
	if value is Array:
		for item in value:
			out.append(String(item))
	return out


static func _enum_text(value: Variant) -> String:
	if value is String and not String(value).is_empty():
		return String(value)
	return "?"


static func _hp_text(value: Variant) -> String:
	if value is float or value is int:
		return "%.2f" % float(value)
	return "?"
