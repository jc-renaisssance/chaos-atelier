class_name CraftReadout
extends RefCounted
## Live Current / Potential craft panel (docs/27). Design UX — not a harness dump.

const LOCKED_LABEL := "locked"


static func preview(session: CraftStaminaSession) -> Dictionary:
	if session == null:
		return {
			"tag_counts": {},
			"craft_rarity": GameEnums.CraftRarity.NONE,
			"powers_positive": PackedStringArray(),
			"powers_negative": PackedStringArray(),
			"outlook_id": "plain",
			"outlook_order": 0,
			"stats": GearStats.new(),
		}
	return CraftResolver.resolve(session, session.construction_id)


static func current_stats(preview: Dictionary) -> GearStats:
	var stats: GearStats = preview.get("stats", null)
	if stats == null:
		return GearStats.new()
	return stats


static func current_line(preview: Dictionary) -> String:
	var stats := current_stats(preview)
	var bag: Dictionary = Dictionary(preview.get("tag_counts", {}))
	return (
		"HP %+d  ATK %+d  DEF %+d  RES %+d  MOB %+d  PRE %+d   ·   tags %s"
		% [
			stats.HP,
			stats.ATK,
			stats.DEF,
			stats.RES,
			stats.MOB,
			stats.PRE,
			_tag_line(bag),
		]
	)


static func outlook_id_of(preview: Dictionary) -> String:
	var outlook := String(preview.get("outlook_id", "plain"))
	if outlook.is_empty():
		return "plain"
	return outlook


static func is_outlook_unlocked(outlook_id: String, unlocked: PackedStringArray) -> bool:
	if outlook_id.is_empty() or outlook_id == "plain":
		return true
	return outlook_id in unlocked


static func potential_unlocked(preview: Dictionary, unlocked: PackedStringArray) -> bool:
	return is_outlook_unlocked(outlook_id_of(preview), unlocked)


static func potential_label(preview: Dictionary, unlocked: PackedStringArray) -> String:
	if not potential_unlocked(preview, unlocked):
		return LOCKED_LABEL
	var outlook := outlook_id_of(preview)
	var order := int(preview.get("outlook_order", 0))
	if outlook == "plain":
		return "plain"
	return "%s · order %d" % [outlook, order]


static func _tag_line(bag: Dictionary) -> String:
	if bag.is_empty():
		return "—"
	var keys: Array = bag.keys()
	keys.sort()
	var bits: PackedStringArray = PackedStringArray()
	for key in keys:
		bits.append("%s×%d" % [String(key), int(bag[key])])
	return ", ".join(bits)
