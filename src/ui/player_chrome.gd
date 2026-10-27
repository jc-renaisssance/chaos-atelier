extends RefCounted
## Player words while dev_tools is false (docs/37). Stamped tables only.
## No class_name: a cold boot has not registered one yet. Callers preload this file.


const OUTLOOK_NAMES := {
	"plain": "Plain",
	"syn_metal_3": "Metal low",
	"syn_metal_5": "Metal mid",
	"syn_metal_8": "Metal apex",
	"syn_earth_3": "Earth low",
	"syn_earth_5": "Earth mid",
	"syn_earth_8": "Earth apex",
	"syn_fire_3": "Fire low",
	"syn_fire_5": "Fire mid",
	"syn_fire_8": "Fire apex",
	"syn_frost_3": "Frost low",
	"syn_frost_5": "Frost mid",
	"syn_frost_8": "Frost apex",
	"syn_silent_3": "Silent low",
	"syn_silent_5": "Silent mid",
	"syn_silent_8": "Silent apex",
	"syn_royal_3": "Royal low",
	"syn_royal_5": "Royal mid",
	"syn_royal_8": "Royal apex",
	"syn_silk_3": "Silk low",
	"syn_silk_5": "Silk mid",
	"syn_silk_8": "Silk apex",
	"syn_fire_frost_clash": "Temper",
	"syn_wild_earth": "Beastbloom",
	"syn_sticky_sharp": "Snaretooth",
	"syn_royal_silent": "Masked Crown",
	"syn_solar_pure": "Dawn Vestment",
	"syn_lunar_occult": "Pale Hex",
}

const RARITY_WORDS := {
	"common": "Common",
	"uncommon": "Uncommon",
	"rare": "Rare",
	"legendary": "Legendary",
}

const SKILL_BLURBS := {
	"sk_metal_str_double": "Double STR from Metal mats already in this piece.",
	"sk_wild_to_earth": "Consume 1 Wild mat in session → Earth mat into hand.",
	"sk_touch_up": "+1 to one chosen stat on one played material.",
	"sk_steady_hand": "Ignore first negative synergy this piece.",
	"sk_deep_dig": "Refresh hand; draw +1 extra.",
	"sk_next_mat_free": "Next material play costs 0 stamina.",
	"sk_ease_draw": "The next card played into a zone costs 1 less stamina, floor 0. Then draw 1",
	"sk_scrap_breath": "Discard 1 other card from hand. If that discard happens, stamina +1",
	"sk_heavy_draw": "The next card played into a zone contributes ×1.5 stats, each stat rounded half away from zero. Tags stay as printed. Then draw 1",
}

const _ID_PREFIXES := [
	"adv_", "appt_", "evt_", "cli_", "boss_", "mat_", "sk_", "staff_",
	"artifact_", "con_", "ord_", "syn_", "ask_", "choice_", "mat_ench_",
	"market_bank", "market_staff_bank", "market_skill_bank", "market_artifact_bank",
]


static func hud_line(chapter: int, day_text: String, day_count: int, gold: int, reps: int, boss: String) -> String:
	var line := "Chapter %d / 3   ·   Day %s / %d   ·   Gold %d   ·   Reps %d" % [
		chapter, day_text, day_count, gold, reps,
	]
	if not boss.is_empty():
		line += "   ·   %s" % boss
	return line


static func boss_name(boss_id: String) -> String:
	var title := ScheduleCatalog.boss_title(boss_id)
	if title.is_empty() or title.begins_with("boss_"):
		return ""
	return title


static func today_newspaper(boss: String) -> String:
	return "The paper names %s." % boss


static func today_unconfirmed() -> String:
	return "Choose the next stop."


static func today_adventurer() -> String:
	return "An adventurer is waiting."


static func today_appointment(appt_id: String) -> String:
	return "%s. You may decline once this chapter." % appointment_face(appt_id)


static func today_market() -> String:
	return "The market is open."


static func today_event() -> String:
	return "On the road."


static func today_travel() -> String:
	return "A day on the road."


static func today_approach(boss: String) -> String:
	return "The road runs to %s." % boss


static func today_awaiting() -> String:
	return "The days are spent. Sew for the fighter."


static func today_chapter_closed() -> String:
	return "The chapter is closed."


static func today_run_over() -> String:
	return "Run over. There is no retry."


## Node A′. One line beside the kind chip. Adventurer is the kind word, not a catalog name.
static func node_line(node: RouteNode) -> String:
	if node == null:
		return ""
	var kind := node.kind
	if kind == "shop":
		kind = "market"
	match kind:
		"adventurer":
			return "Adventurer"
		"appointment":
			return appointment_face(node.ref_id)
		"market":
			return "Market"
		"event":
			return "On the road"
		"reserved":
			if _reserved_is_approach(node):
				return "Approach"
			return "Travel"
		_:
			return ""


static func appointment_face(appt_id: String) -> String:
	if appt_id.is_empty() or not appt_id.begins_with("appt_"):
		return "Appointment"
	var pin := AppointmentPin.new()
	pin.appointment_id = appt_id
	var title := ScheduleCatalog.appointment_title(pin)
	if title.is_empty() or title == appt_id or title.begins_with("appt_"):
		return "Appointment"
	return title


static func outlook_name(outlook_id: String) -> String:
	if outlook_id.is_empty():
		return ""
	return String(OUTLOOK_NAMES.get(outlook_id, ""))


static func rarity_word(wire: String) -> String:
	return String(RARITY_WORDS.get(wire, ""))


static func skill_blurb(skill_id: String) -> String:
	return String(SKILL_BLURBS.get(skill_id, ""))


## {skill name}. {clause}. ask_* stays off. A sentence that still holds a wire id is omitted.
static func skill_line(adv_id: String) -> String:
	var name := AdventurerCatalog.skill_name(adv_id).strip_edges()
	var clause := _player_clause(AdventurerCatalog.skill_clause(adv_id))
	if name.is_empty():
		return clause
	var head := name
	if not head.ends_with("."):
		head += "."
	if clause.is_empty():
		return head
	return "%s %s" % [head, clause]


static func mat_name(mat_id: String) -> String:
	var name := CraftCatalog.display_name(mat_id, GameEnums.HandCardType.MATERIAL)
	if name.is_empty() or name == mat_id or name.begins_with("mat_"):
		return ""
	return name


static func staff_face(staff_id: String) -> String:
	var label := MarketCatalog.staff_label(staff_id)
	if label.is_empty() or label.begins_with("staff_"):
		return ""
	return label


static func artifact_face(artifact_id: String) -> String:
	var label := MarketCatalog.artifact_label(artifact_id)
	if label.is_empty() or label.begins_with("artifact_"):
		return ""
	return label


static func shiny_suffix(ench_id: String) -> String:
	match ench_id:
		"mat_ench_thrift":
			return "shiny Thrift"
		"mat_ench_heavy":
			return "shiny Heavy"
		_:
			var label := MarketCatalog.enchant_label(ench_id)
			if label == "Thrift" or label == "Heavy":
				return "shiny %s" % label
			return ""


static func shelf_line(title: String, price: int, own: int, offered: int) -> String:
	var bits := PackedStringArray()
	if not title.is_empty():
		bits.append(title)
	bits.append("$%d" % price)
	bits.append("own %d" % own)
	if offered >= 0:
		bits.append("offered %d" % offered)
	return "     ".join(bits)


static func staff_delta_words(staff_id: String) -> String:
	if staff_id.is_empty():
		return ""
	var bits := PackedStringArray()
	var dm := MarketCatalog.staff_delta_materials(staff_id)
	var dr := MarketCatalog.staff_delta_runes(staff_id)
	if dm != 0:
		bits.append("Materials %+d" % dm)
	if dr != 0:
		bits.append("Runes %+d" % dr)
	return "  ·  ".join(bits)


static func staff_kit_caption(staff_id: String) -> String:
	var who := "None"
	if not staff_id.is_empty():
		var label := staff_face(staff_id)
		if not label.is_empty():
			who = label
	var line := "Your staff  ·  %s" % who
	var extra := staff_delta_words(staff_id)
	if not extra.is_empty():
		line += "  ·  %s" % extra
	return line


static func actor_caption(actor_id: Variant) -> String:
	if actor_id is String and not String(actor_id).is_empty():
		var named := person_name(String(actor_id))
		if not named.is_empty():
			return named
	if AtelierSession.board != null:
		var pin: AppointmentPin = AtelierSession.board.current_pin()
		if pin != null and not pin.appointment_id.is_empty():
			return appointment_face(pin.appointment_id)
	return ""


static func person_name(token: String) -> String:
	if token.begins_with("adv_"):
		var name := AdventurerCatalog.display_name(token)
		if name.is_empty() or name == token or name.begins_with("adv_"):
			return ""
		return name
	if token.begins_with("appt_"):
		return appointment_face(token)
	return ""


static func beat_label(row: Dictionary) -> String:
	var id := String(row.get("id", ""))
	var label := String(row.get("label", ""))
	if id == "skill":
		return _skill_beat(label)
	if id.begins_with("favor:") or id.begins_with("punish:"):
		var tag := id.substr(id.find(":") + 1)
		if tag.is_empty() or _has_hidden_id(tag):
			return ""
		return tag
	var parts := label.split("  ·  ")
	var kept := PackedStringArray()
	for part in parts:
		var faced := _face_token(String(part).strip_edges())
		if not faced.is_empty():
			kept.append(faced)
	return "  ·  ".join(kept)


static func board_report(payload: Dictionary) -> Dictionary:
	if payload.is_empty():
		return {"show": false, "title": "", "body": ""}
	var title := String(payload.get("title", ""))
	var body := String(payload.get("body", ""))
	if title.begins_with("Mission — ") or title.begins_with("cant_craft"):
		var letter := String(payload.get("rating", ""))
		if letter.is_empty():
			letter = "F" if title.begins_with("cant_craft") else title.trim_prefix("Mission — ").strip_edges()
		var won := bool(payload.get("cleared", false))
		return {"show": true, "title": "Read %s" % letter, "body": "%s\n%s" % [letter, "Won" if won else "Lost"]}
	if title.begins_with("Boss clear — ") or (title.begins_with("Run over — ") and not title.contains("reps")):
		return _boss_report(title, body, payload)
	return report_from_title_body(title, body)


static func playback_report(snap: Dictionary) -> Dictionary:
	if not bool(snap.get("report", false)):
		return {"show": false, "title": "", "body": ""}
	if String(snap.get("kind", "")) != "fight":
		var piece_index := int(snap.get("piece_index", -1))
		var result := _find_piece(piece_index)
		if not result.is_empty():
			return piece_face(result, piece_index)
	var title := String(snap.get("title", ""))
	var body := String(snap.get("body", ""))
	if title.begins_with("Piece "):
		return _piece_from_debug(title, body)
	return report_from_title_body(title, body)


static func report_from_title_body(title: String, body: String) -> Dictionary:
	if title.begins_with("Mission — "):
		var letter := title.trim_prefix("Mission — ").strip_edges()
		var won := body.contains("cleared true")
		return {"show": true, "title": "Read %s" % letter, "body": "%s\n%s" % [letter, "Won" if won else "Lost"]}
	if title.begins_with("cant_craft"):
		return {"show": true, "title": "Read F", "body": "F\nLost"}
	if title.begins_with("Boss clear — ") or (title.begins_with("Run over — ") and not title.contains("reps")):
		return _boss_report(title, body, {})
	if title.begins_with("market ·"):
		return {"show": true, "title": "Market", "body": "Back on the road."}
	if title.begins_with("event ·"):
		return {"show": true, "title": "On the road", "body": body}
	if title.contains("reps gate") or body.contains("run_over_reason") or body.contains("reps_gate"):
		return {"show": true, "title": "Run over", "body": "There is no retry."}
	if title.begins_with("Piece "):
		return _piece_from_debug(title, body)
	return {"show": false, "title": "", "body": ""}


static func hides_id(text: String) -> bool:
	return _has_hidden_id(text)


static func piece_face(result: Dictionary, piece_index: int) -> Dictionary:
	var con_id := String(result.get("construction_id", ""))
	var con_name := ""
	if not con_id.is_empty():
		con_name = CraftCatalog.construction_name(con_id)
	if con_name.is_empty() or con_name.begins_with("con_"):
		con_name = "Piece"
	var rarity := ""
	var wire_v: Variant = GameEnums.craft_rarity_wire(int(result.get("craft_rarity", GameEnums.CraftRarity.NONE)))
	if wire_v is String:
		rarity = rarity_word(String(wire_v))
	var outlook := outlook_name(String(result.get("outlook_id", "")))
	var lines := PackedStringArray()
	lines.append(con_name)
	if not rarity.is_empty():
		lines.append(rarity)
	if not outlook.is_empty():
		lines.append(outlook)
	var tags := tag_words(result.get("tag_counts", {}))
	if not tags.is_empty():
		lines.append(tags)
	return {
		"show": true,
		"title": "Piece %d · %s" % [piece_index, con_name],
		"body": "\n".join(lines),
	}


static func tag_words(bag_v: Variant) -> String:
	if not (bag_v is Dictionary):
		return ""
	var bag: Dictionary = bag_v
	if bag.is_empty():
		return ""
	var keys: Array = bag.keys()
	keys.sort()
	var bits := PackedStringArray()
	for key in keys:
		var word := String(key)
		if _has_hidden_id(word):
			continue
		bits.append("%s×%d" % [word, int(bag[key])])
	return ", ".join(bits)


static func _reserved_is_approach(node: RouteNode) -> bool:
	var count := node.day_index
	if AtelierSession.board != null and AtelierSession.board.day_count > 0:
		count = AtelierSession.board.day_count
	return node.day_index == count


static func _player_clause(raw: String) -> String:
	var cleaned := _collapse(_strip_ticks(raw))
	if cleaned.is_empty():
		return ""
	var parts := cleaned.split(". ")
	var kept := PackedStringArray()
	for i in parts.size():
		var sentence := String(parts[i]).strip_edges()
		if sentence.is_empty() or _has_hidden_id(sentence):
			continue
		if i < parts.size() - 1 and not sentence.ends_with("."):
			sentence += "."
		kept.append(sentence)
	return " ".join(kept)


static func _strip_ticks(text: String) -> String:
	var out := ""
	var tick := false
	for i in text.length():
		var ch := text.substr(i, 1)
		if ch == "`":
			tick = not tick
			continue
		if not tick:
			out += ch
	return out


static func _collapse(text: String) -> String:
	var out := text.replace("()", "").replace("( )", "")
	while "  " in out:
		out = out.replace("  ", " ")
	out = out.replace(" ;", ";").replace(" .", ".").replace(" :", ":").strip_edges()
	return out


static func _has_hidden_id(text: String) -> bool:
	var lower := text.to_lower()
	for prefix in _ID_PREFIXES:
		if prefix in lower:
			return true
	if "own_basic" in lower or "map_m1" in lower or "docs/" in lower:
		return true
	if "route_path" in lower or "phase=schedule" in lower or "run_over_reason" in lower:
		return true
	if "hd_run_over" in lower or "hd_chapter_result" in lower or "cant_craft" in lower:
		return true
	if "crafts_done" in lower or "(stub)." in lower or "δm" in lower or "δr" in lower or "δ0" in lower:
		return true
	return false


static func _skill_name_for_ask(ask_id: String) -> String:
	for pool in ["m1", "m2"]:
		for adv_id in AdventurerCatalog.all_named_ids(pool):
			if AdventurerCatalog.skill_id(String(adv_id)) == ask_id:
				return AdventurerCatalog.skill_name(String(adv_id))
	return ""


static func _skill_beat(label: String) -> String:
	var parts := label.split("  ·  ")
	var ask := ""
	if parts.size() > 0:
		ask = String(parts[0]).strip_edges()
	var star := ""
	if parts.size() > 1:
		star = String(parts[1]).strip_edges()
	if ask.is_empty() or ask == "?" or not ask.begins_with("ask_"):
		return "Does not fire."
	var name := _skill_name_for_ask(ask)
	if name.is_empty():
		return star
	if star.is_empty():
		return name
	return "%s  ·  %s" % [name, star]


static func _face_token(token: String) -> String:
	if token.is_empty() or token == "—":
		return ""
	if token.begins_with("hp ") or token == "hp":
		return ""
	if token.begins_with("adv_") or token.begins_with("appt_"):
		return person_name(token)
	if token.begins_with("ask_"):
		return _skill_name_for_ask(token)
	if token == "plain" or token.begins_with("syn_"):
		return outlook_name(token)
	if RARITY_WORDS.has(token):
		return rarity_word(token)
	if _has_hidden_id(token):
		return ""
	return token


static func _boss_report(title: String, body: String, payload: Dictionary) -> Dictionary:
	var boss := ""
	var dash := title.find("— ")
	if dash >= 0:
		boss = title.substr(dash + 2).strip_edges()
	var fighter := ""
	if not payload.is_empty():
		fighter = AdventurerCatalog.display_name(String(payload.get("boss_client_id", "")))
		if fighter.is_empty() or fighter.begins_with("adv_") or fighter.begins_with("appt_"):
			fighter = BossClientCatalog.display_name(String(payload.get("boss_job_id", "")))
	if fighter.is_empty() or fighter.begins_with("adv_") or fighter.begins_with("appt_"):
		var paren := body.find(" (%s)" % "")
		if paren > 0:
			fighter = body.substr(0, paren).strip_edges()
	if fighter.begins_with("adv_") or fighter.begins_with("appt_"):
		fighter = ""
	var letter := String(payload.get("rating", ""))
	if letter.is_empty():
		var rating_at := body.find("rating ")
		if rating_at >= 0 and rating_at + 7 <= body.length():
			letter = body.substr(rating_at + 7, 1)
	var line := ""
	if not fighter.is_empty() and not boss.is_empty():
		line = "%s against %s." % [fighter, boss]
	if not letter.is_empty():
		line = letter if line.is_empty() else "%s\n%s" % [line, letter]
	return {"show": true, "title": title, "body": line}


static func _piece_from_debug(title: String, body: String) -> Dictionary:
	var name := ""
	var sep := title.find(" · ")
	if sep >= 0:
		name = title.substr(sep + 3).strip_edges()
	if name.begins_with("con_"):
		name = "Piece"
	var rarity := ""
	var outlook := ""
	var tags := ""
	for raw_line in body.split("\n"):
		var line := String(raw_line)
		if not line.begins_with("Rarity "):
			continue
		var look_at := line.find(" · look ")
		var tags_at := line.find(" · tags ")
		var rarity_wire := ""
		if look_at > 7:
			rarity_wire = line.substr(7, look_at - 7).strip_edges()
		rarity = rarity_word(rarity_wire)
		if look_at >= 0:
			var look_end := tags_at if tags_at > look_at else line.length()
			var look_id := line.substr(look_at + 8, look_end - (look_at + 8)).strip_edges().trim_suffix(".")
			outlook = outlook_name(look_id)
		if tags_at >= 0:
			var tag_text := line.substr(tags_at + 8).trim_suffix(".").strip_edges()
			if tag_text != "(none)" and not tag_text.is_empty() and not _has_hidden_id(tag_text):
				tags = tag_text
	var lines := PackedStringArray()
	if not name.is_empty():
		lines.append(name)
	if not rarity.is_empty():
		lines.append(rarity)
	if not outlook.is_empty():
		lines.append(outlook)
	if not tags.is_empty():
		lines.append(tags)
	return {"show": true, "title": title, "body": "\n".join(lines)}


static func _find_piece(piece_index: int) -> Dictionary:
	if piece_index < 0:
		return {}
	for item in AtelierSession.piece_results:
		if item is Dictionary and int(item.get("piece_index", -1)) == piece_index:
			return item
	return {}
