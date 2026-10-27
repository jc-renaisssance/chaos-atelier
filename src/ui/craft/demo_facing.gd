class_name DemoFacing
extends RefCounted
## Brief and Estimate labels (docs/35 Copy A). Weights stay off the label.
## A locked field is "?" on that line only.

const NEG_NAMES := {
	"syn_neg_metal_silk": "Ragged Mail",
	"syn_neg_hood_metal": "Bucket Head",
	"syn_neg_cloak_metal": "Iron Mantle Fail",
	"syn_neg_metal_silent": "Clanging Hush",
	"syn_neg_soft_sharp": "Frayed Comfort",
	"syn_neg_sticky_royal": "Tar at Court",
	"syn_neg_occult_pure": "Schism Stitch",
	"syn_neg_fire_soft": "Scorched Down",
}


static func brief_text(seen: bool, display_name: String, environment: String, flavor: String) -> String:
	## Brief A: a cli_* row with no environment and no flavor is the name only.
	## Boss Copy A still has both lines. Blank lines are never legal.
	if not seen:
		return "?"
	if environment.is_empty() and flavor.is_empty():
		return display_name if not display_name.is_empty() else "?"
	var lines := PackedStringArray()
	if not display_name.is_empty():
		lines.append(display_name)
	if not environment.is_empty():
		lines.append(environment)
	if not flavor.is_empty():
		lines.append(flavor)
	if lines.is_empty():
		return "?"
	return "\n".join(lines)


static func locked_estimate() -> String:
	return estimate_text({
		"planned_outlook": "?",
		"estimate_favor_hits": "?",
		"estimate_punish_hits": "?",
		"estimate_skill_fired": "?",
		"estimate_neg_warnings": "?",
		"estimate_band": "?",
	}, "", "")


static func estimate_text(gated: Dictionary, skill_name: String, skill_line: String) -> String:
	return "\n".join([
		"Plan: %s" % _plan_field(gated.get("planned_outlook", "?")),
		"Favors: %s" % _tag_field(gated.get("estimate_favor_hits", "?")),
		"Punishes: %s" % _tag_field(gated.get("estimate_punish_hits", "?")),
		"Skill: %s" % _skill_field(gated.get("estimate_skill_fired", "?"), skill_name, skill_line),
		"Watch: %s" % _watch_field(gated.get("estimate_neg_warnings", "?")),
		"Read: %s" % _read_field(gated.get("estimate_band", "?")),
	])


static func _plan_field(value: Variant) -> String:
	if value is String:
		var text := String(value)
		if text.is_empty() or text == "?" or text == "—":
			return "?"
		return text
	return "?"


static func _tag_field(value: Variant) -> String:
	if value is String:
		return "?"
	var names := _strings(value)
	if names.is_empty():
		return "None"
	return ", ".join(names)


static func _watch_field(value: Variant) -> String:
	if value is String:
		return "?"
	var names := PackedStringArray()
	for syn_id in _strings(value):
		var name := String(NEG_NAMES.get(syn_id, ""))
		if not name.is_empty():
			names.append(name)
	if names.is_empty():
		return "None"
	return ", ".join(names)


static func _read_field(value: Variant) -> String:
	if not (value is String):
		return "?"
	var letter := String(value)
	if letter == "S" or letter == "A" or letter == "B" or letter == "C" or letter == "D" or letter == "F":
		return letter
	return "?"


static func _skill_field(value: Variant, skill_name: String, skill_line: String) -> String:
	if not (value is bool):
		return "?"
	if not bool(value):
		return "Does not fire."
	var clause := _one_clause(skill_line)
	if skill_name.is_empty():
		if clause.is_empty():
			return "Fires."
		return "Fires. %s." % clause
	if clause.is_empty():
		return "Fires. %s." % skill_name
	return "Fires. %s. %s." % [skill_name, clause]


static func _one_clause(skill_line: String) -> String:
	var cleaned := ""
	var tick := false
	for i in skill_line.length():
		var ch := skill_line.substr(i, 1)
		if ch == "`":
			tick = not tick
			continue
		if not tick:
			cleaned += ch
	cleaned = cleaned.strip_edges()
	var dot := cleaned.find(".")
	if dot >= 0:
		cleaned = cleaned.substr(0, dot)
	return cleaned.strip_edges()


static func _strings(value: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if value is PackedStringArray:
		return value
	if value is Array:
		for item in value:
			var text := String(item)
			if not text.is_empty():
				out.append(text)
	return out
