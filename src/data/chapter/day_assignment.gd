class_name DayAssignment
extends Resource
## Player-assigned (and fixed-pin) E* on one assignable day (docs/20, docs/22).

## Autoload has no class_name (Godot 4.7). Call statics on the script type.
const _GameConstants := preload("res://src/autoload/game_constants.gd")

@export var day_index: int = 1
@export var event_id: String = ""


func to_dict() -> Dictionary:
	return {
		"day_index": day_index,
		"event_id": event_id,
	}


func schema_errors(day_count: int) -> PackedStringArray:
	var errs := PackedStringArray()
	if event_id.is_empty():
		errs.append("event_id empty on day_assignments")
	if not _GameConstants.is_assignable_day(day_index, day_count):
		errs.append("day_assignments day_index %d not in 1..(N-2) for N=%d" % [day_index, day_count])
	return errs
