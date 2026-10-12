class_name ScheduleDay
extends Resource
## One Day-planner slot. Phase-1: exactly one primary action (or NONE before pick).

@export var day_index: int = 1
@export var day_action: GameEnums.RoundAction = GameEnums.RoundAction.NONE
@export var order_id: String = "" ## appointment / walk-in / prep order when applicable
@export var event_id: String = "" ## assigned E* when resolved from the pool


func is_reserved_final(day_count: int) -> bool:
	return GameConstants.is_reserved_final_day(day_index, day_count)


func is_played() -> bool:
	return day_action != GameEnums.RoundAction.NONE


func to_dict(day_count: int) -> Dictionary:
	return {
		"day_index": day_index,
		"day_action": GameEnums.day_action_wire(day_action),
		"order_id": order_id if not order_id.is_empty() else null,
		"event_id": event_id if not event_id.is_empty() else null,
		"reserved_final": is_reserved_final(day_count),
	}


func schema_errors(day_count: int) -> PackedStringArray:
	var errs := PackedStringArray()
	if not GameConstants.is_schedule_day(day_index, day_count):
		errs.append("day_index %d not in 1..%d" % [day_index, day_count])
	if is_reserved_final(day_count) and day_action == GameEnums.RoundAction.APPOINTMENT:
		errs.append("appointment cannot claim reserved final day %d" % day_index)
	return errs
