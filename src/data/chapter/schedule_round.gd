class_name ScheduleRound
extends Resource
## One of 8 timeline slots. Phase-1: exactly one primary action (or NONE before pick).

@export var round_index: int = 1
@export var round_action: GameEnums.RoundAction = GameEnums.RoundAction.NONE
@export var order_id: String = "" ## appointment / walk-in / prep order when applicable


func is_reserved_final() -> bool:
	return GameConstants.is_reserved_final_round(round_index)


func to_dict() -> Dictionary:
	return {
		"round_index": round_index,
		"round_action": GameEnums.round_action_wire(round_action),
		"order_id": order_id if not order_id.is_empty() else null,
		"reserved_final": is_reserved_final(),
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if not GameConstants.is_schedule_round(round_index):
		errs.append("round_index %d not in 1..%d" % [round_index, GameConstants.CHAPTER_ROUND_COUNT])
	if is_reserved_final() and round_action == GameEnums.RoundAction.APPOINTMENT:
		errs.append("appointment cannot claim reserved final round %d" % round_index)
	return errs
