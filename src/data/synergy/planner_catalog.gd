class_name PlannerCatalog
extends RefCounted
## Slice 2 planner vocabulary (docs/14, 30). Pos monostack + the six cross-tags only.
## Intent for the estimate — does not change constructions or replace stamina craft.

## docs/14 positive monostack tags. Planner lists low / mid / apex for each.
const MONOSTACK_TAGS := [
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

const MONO_TIERS := ["low", "mid", "apex"]

## Cross-tag chrome slugs (docs/30). Storm monostack stays storm + tier.
const CROSS_ROWS := [
	{"outlook_id": "temper", "a": "Fire", "b": "Frost", "display": "Temper"},
	{"outlook_id": "beastbloom", "a": "Wild", "b": "Earth", "display": "Beastbloom"},
	{"outlook_id": "snaretooth", "a": "Sticky", "b": "Sharp", "display": "Snaretooth"},
	{"outlook_id": "masked_crown", "a": "Royal", "b": "Silent", "display": "Masked Crown"},
	{"outlook_id": "dawn", "a": "Solar", "b": "Pure", "display": "Dawn"},
	{"outlook_id": "pale_hex", "a": "Lunar", "b": "Occult", "display": "Pale Hex"},
]


static func is_monostack_tag(tag: String) -> bool:
	return MONOSTACK_TAGS.has(tag)


static func outlook_for_tag(tag: String) -> String:
	return tag.to_lower()


static func display_outlook(outlook_id: String) -> String:
	for row in CROSS_ROWS:
		if String(row["outlook_id"]) == outlook_id:
			return String(row["display"])
	if outlook_id.is_empty():
		return ""
	return outlook_id.capitalize()


static func tier_min(tier: String) -> int:
	match tier:
		"mid":
			return GameConstants.SYN_THRESHOLD_TIER_2
		"apex":
			return GameConstants.SYN_THRESHOLD_APEX
		_:
			return GameConstants.SYN_THRESHOLD_TIER_1


static func cross_for(tag_a: String, tag_b: String) -> String:
	if tag_a.is_empty() or tag_b.is_empty() or tag_a == tag_b:
		return ""
	for row in CROSS_ROWS:
		var a := String(row["a"])
		var b := String(row["b"])
		if (tag_a == a and tag_b == b) or (tag_a == b and tag_b == a):
			return String(row["outlook_id"])
	return ""


static func tags_for_cross(outlook_id: String) -> PackedStringArray:
	for row in CROSS_ROWS:
		if String(row["outlook_id"]) == outlook_id:
			return PackedStringArray([String(row["a"]), String(row["b"])])
	return PackedStringArray()


static func _title(outlook_id: String) -> String:
	for tag in MONOSTACK_TAGS:
		if String(tag).to_lower() == outlook_id:
			return String(tag)
	return outlook_id.capitalize()


static func build_row(outlook_id: String, tier: String) -> Dictionary:
	return {"outlook_id": outlook_id, "tier": tier}


static func dup_plan(planned: Variant) -> Variant:
	if planned is Dictionary:
		var row: Dictionary = planned
		var outlook_id := String(row.get("outlook_id", ""))
		var tier := String(row.get("tier", ""))
		if outlook_id.is_empty() or tier.is_empty():
			return null
		return build_row(outlook_id, tier)
	return null


static func plan_label(planned: Variant) -> String:
	var row := dup_plan(planned)
	if not row is Dictionary:
		return "—"
	var item: Dictionary = row
	return "%s %s" % [display_outlook(String(item.get("outlook_id", ""))), String(item.get("tier", ""))]


## Client pick: same chip cycles low → mid → apex → off. A pairing tag plans that cross.
static func after_click(planned: Variant, clicked_tag: String) -> Variant:
	if not is_monostack_tag(clicked_tag):
		return dup_plan(planned)
	var slug := outlook_for_tag(clicked_tag)
	var current := dup_plan(planned)
	if not current is Dictionary:
		return build_row(slug, "low")
	var row: Dictionary = current
	var outlook_id := String(row.get("outlook_id", ""))
	var tier := String(row.get("tier", ""))
	if tier == "cross":
		return build_row(slug, "low")
	if outlook_id == slug:
		match tier:
			"low":
				return build_row(slug, "mid")
			"mid":
				return build_row(slug, "apex")
			_:
				return null
	var prior_tag := _title(outlook_id)
	var cross_id := cross_for(prior_tag, clicked_tag)
	if not cross_id.is_empty():
		return build_row(cross_id, "cross")
	return build_row(slug, "low")


static func chip_caption(tag: String, planned: Variant) -> String:
	var row := dup_plan(planned)
	if not row is Dictionary:
		return tag
	var item: Dictionary = row
	var outlook_id := String(item.get("outlook_id", ""))
	var tier := String(item.get("tier", ""))
	if tier == "cross":
		var pair := tags_for_cross(outlook_id)
		if tag in pair:
			return "%s · cross" % tag
		return tag
	if outlook_id == outlook_for_tag(tag):
		return "%s · %s" % [tag, tier]
	return tag


static func planned_tags(planned: Variant) -> Dictionary:
	var bag := {}
	var row := dup_plan(planned)
	if not row is Dictionary:
		return bag
	var item: Dictionary = row
	var outlook_id := String(item.get("outlook_id", ""))
	var tier := String(item.get("tier", ""))
	if tier == "cross":
		for tag in tags_for_cross(outlook_id):
			_add(bag, String(tag), GameConstants.SYN_CROSS_TAG_MIN)
		return bag
	if MONO_TIERS.has(tier):
		_add(bag, _title(outlook_id), tier_min(tier))
	return bag


static func add_construction_tags(bag: Dictionary, construction_ids: PackedStringArray) -> Dictionary:
	var out := bag.duplicate()
	for con_id in construction_ids:
		for tag in CraftCatalog.construction_tags(String(con_id)):
			_add(out, String(tag), 1)
	return out


static func _add(bag: Dictionary, tag: String, n: int) -> void:
	if tag.is_empty() or n <= 0:
		return
	bag[tag] = int(bag.get(tag, 0)) + n


static func family_known(unlocked_builds: Array, outlook_id: String) -> bool:
	for row in unlocked_builds:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		if String(item.get("outlook_id", "")) == outlook_id:
			return true
	return false


## Unlocked named rows. Known family missing a tier → `Metal ?`. Unknown families → `?`.
## Fresh profile (nothing unlocked) → a single `?`.
static func list_lines(unlocked_builds: Array) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	var unknown_n := 0
	for tag in MONOSTACK_TAGS:
		var slug := outlook_for_tag(String(tag))
		if not family_known(unlocked_builds, slug):
			unknown_n += 1
			continue
		var missing := false
		for tier in MONO_TIERS:
			if _has_key(unlocked_builds, slug, String(tier)):
				lines.append("%s %s" % [tag, tier])
			else:
				missing = true
		if missing:
			lines.append("%s ?" % tag)
	for row in CROSS_ROWS:
		var slug := String(row["outlook_id"])
		if _has_key(unlocked_builds, slug, "cross"):
			lines.append(String(row["display"]))
		else:
			unknown_n += 1
	if lines.is_empty():
		return PackedStringArray(["?"])
	while unknown_n > 0:
		lines.append("?")
		unknown_n -= 1
	return lines


static func _has_key(unlocked_builds: Array, outlook_id: String, tier: String) -> bool:
	for row in unlocked_builds:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		if String(item.get("outlook_id", "")) == outlook_id and String(item.get("tier", "")) == tier:
			return true
	return false
