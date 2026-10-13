class_name AppointmentPin
extends Resource
## appt_* row on the route map. pinned_day ∈ 1..(N-2) (docs/22, docs/20).
## Scrap Duelist stays here — not Dex Adventurers.

## Autoload has no class_name (Godot 4.7). Call statics on the script type.
const _GameConstants := preload("res://src/autoload/game_constants.gd")

@export var appointment_id: String = ""
@export var order_id: String = ""
@export var node_id: String = ""
@export var pinned_day: int = 1


func to_dict() -> Dictionary:
	var pinned_node: Variant = null if node_id.is_empty() else node_id
	return {
		"appointment_id": appointment_id,
		"order_id": order_id,
		"node_id": pinned_node,
		"pinned_day": pinned_day,
	}


func schema_errors(day_count: int) -> PackedStringArray:
	var errs := PackedStringArray()
	if appointment_id.is_empty():
		errs.append("appointment_id empty")
	if order_id.is_empty():
		errs.append("order_id empty")
	if appointment_id.begins_with("adv_"):
		errs.append("appointment_id must not be adv_*")
	if not _GameConstants.is_assignable_day(pinned_day, day_count):
		errs.append("pinned_day %d not in 1..(N-2) for N=%d" % [pinned_day, day_count])
	return errs
