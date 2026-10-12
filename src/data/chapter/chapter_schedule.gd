class_name ChapterSchedule
extends Resource
## Day planner board (docs/22). Day count from map.day_count. No piece cap.

@export var player_owner_id: String = GameConstants.PHASE1_OWNER_ID
@export var chapter_id: int = 1
@export var chapter_boss_id: String = ""
@export var boss_pool_id: String = ""
@export var map_id: String = MapCatalog.CURRENT_MAP_ID
@export var day_count: int = 0 ## = map.day_count this chapter
@export var day_index: int = GameConstants.NULL_INT ## 1..N once a day is live
@export var days_left: int = 0
@export var days: Array[ScheduleDay] = []
@export var event_pool: Array[PlannerEvent] = []
@export var day_assignments: Array[DayAssignment] = []
@export var appointment_pins: Array[AppointmentPin] = []
@export var appt_decline_used: bool = false
## Unbounded piece telemetry (docs/20). Not a gate. No crafts_max.
@export var crafts_done: int = 0


static func make_empty(chapter_id_: int = 1, map_id_: String = "") -> ChapterSchedule:
	var board := ChapterSchedule.new()
	board.chapter_id = chapter_id_
	board.player_owner_id = GameConstants.PHASE1_OWNER_ID
	board.boss_pool_id = String(GameConstants.BOSS_POOL_IDS.get(chapter_id_, ""))
	board.map_id = map_id_ if not map_id_.is_empty() else MapCatalog.CURRENT_MAP_ID
	board.day_count = MapCatalog.day_count(board.map_id)
	board.days_left = board.day_count
	board.event_pool = MapCatalog.make_event_pool(board.map_id)
	for i in range(1, board.day_count + 1):
		var slot := ScheduleDay.new()
		slot.day_index = i
		board.days.append(slot)
	return board


func slot_at(day_i: int) -> ScheduleDay:
	for slot in days:
		if slot.day_index == day_i:
			return slot
	return null


func pin_at(day_i: int) -> AppointmentPin:
	for pin in appointment_pins:
		if pin.pinned_day == day_i:
			return pin
	return null


func event_by_id(event_id: String) -> PlannerEvent:
	for event in event_pool:
		if event.event_id == event_id:
			return event
	return null


func assignment_at(day_i: int) -> DayAssignment:
	for row in day_assignments:
		if row.day_index == day_i:
			return row
	return null


func assigned_event(day_i: int) -> PlannerEvent:
	var row := assignment_at(day_i)
	if row == null:
		return null
	return event_by_id(row.event_id)


func assignment_for_event(event_id: String) -> DayAssignment:
	for row in day_assignments:
		if row.event_id == event_id:
			return row
	return null


func current_day() -> ScheduleDay:
	if not GameConstants.is_schedule_day(day_index, day_count):
		return null
	return slot_at(day_index)


func current_day_action() -> GameEnums.RoundAction:
	var slot := current_day()
	if slot == null:
		return GameEnums.RoundAction.NONE
	return slot.day_action


func current_pin() -> AppointmentPin:
	if not GameConstants.is_schedule_day(day_index, day_count):
		return null
	return pin_at(day_index)


func current_assigned_event() -> PlannerEvent:
	if not GameConstants.is_schedule_day(day_index, day_count):
		return null
	return assigned_event(day_index)


func resolved_count() -> int:
	var n := 0
	for slot in days:
		if slot.is_played():
			n += 1
	return n


func sync_days_left() -> void:
	days_left = day_count - resolved_count()


func is_current_resolved() -> bool:
	var slot := current_day()
	return slot != null and slot.is_played()


func is_schedule_complete() -> bool:
	return resolved_count() >= day_count


func is_day_played(day_i: int) -> bool:
	var slot := slot_at(day_i)
	return slot != null and slot.is_played()


func is_reserved_day(day_i: int) -> bool:
	return GameConstants.is_reserved_final_day(day_i, day_count)


func options_for_day(day_i: int) -> Array[PlannerEvent]:
	var out: Array[PlannerEvent] = []
	for event in event_pool:
		if event.covers_day(day_i):
			out.append(event)
	return out


func begin_live(boss_id: String, pool_id: String) -> void:
	chapter_boss_id = boss_id
	boss_pool_id = pool_id
	appt_decline_used = false
	crafts_done = 0
	player_owner_id = GameConstants.PHASE1_OWNER_ID
	day_index = 1
	day_assignments.clear()
	appointment_pins.clear()
	for slot in days:
		slot.day_action = GameEnums.RoundAction.NONE
		slot.order_id = ""
		slot.event_id = ""
	sync_days_left()


func can_assign(day_i: int, event_id: String) -> bool:
	return assign_reason(day_i, event_id).is_empty()


func assign_reason(day_i: int, event_id: String) -> String:
	if not GameConstants.is_assignable_day(day_i, day_count):
		return "day %d is reserved / not assignable" % day_i
	if is_day_played(day_i):
		return "day %d is frozen (played)" % day_i
	var event := event_by_id(event_id)
	if event == null:
		return "unknown event %s" % event_id
	if not event.covers_day(day_i):
		return "%s window does not include D%d" % [event_id, day_i]
	var here := assignment_at(day_i)
	if here != null:
		var pinned := event_by_id(here.event_id)
		if pinned != null and pinned.fixed and pinned.event_id != event_id:
			return "fixed %s cannot leave D%d" % [pinned.event_id, day_i]
	var elsewhere := assignment_for_event(event_id)
	if elsewhere != null and elsewhere.day_index != day_i:
		if event.fixed:
			return "fixed %s cannot move off D%d" % [event_id, elsewhere.day_index]
		if is_day_played(elsewhere.day_index):
			return "%s already resolved on D%d" % [event_id, elsewhere.day_index]
	return ""


func assign_day(day_i: int, event_id: String) -> bool:
	if not can_assign(day_i, event_id):
		return false
	var event := event_by_id(event_id)
	var elsewhere := assignment_for_event(event_id)
	if elsewhere != null and elsewhere.day_index != day_i:
		_clear_assignment(elsewhere.day_index)
	var here := assignment_at(day_i)
	if here != null:
		here.event_id = event_id
	else:
		var row := DayAssignment.new()
		row.day_index = day_i
		row.event_id = event_id
		day_assignments.append(row)
	var slot := slot_at(day_i)
	if slot != null and not slot.is_played():
		slot.event_id = event_id
	_sync_pins()
	return event != null


func pin_fixed_events() -> void:
	for event in event_pool:
		if not event.fixed:
			continue
		for day_i in event.windows:
			if GameConstants.is_assignable_day(day_i, day_count):
				assign_day(day_i, event.event_id)
				break


func _clear_assignment(day_i: int) -> void:
	var kept: Array[DayAssignment] = []
	for row in day_assignments:
		if row.day_index != day_i:
			kept.append(row)
	day_assignments = kept
	var slot := slot_at(day_i)
	if slot != null and not slot.is_played():
		slot.event_id = ""


func _sync_pins() -> void:
	appointment_pins.clear()
	for row in day_assignments:
		var event := event_by_id(row.event_id)
		if event == null or event.kind != "appointment":
			continue
		var pin := AppointmentPin.new()
		pin.appointment_id = event.ref_id
		var appt: Dictionary = ScheduleCatalog.appointment_row(event.ref_id)
		pin.order_id = String(appt.get("order_id", ""))
		pin.pinned_day = row.day_index
		appointment_pins.append(pin)


## Phase-1: exactly one primary action per day (docs/22, docs/20).
func set_primary_action(action: GameEnums.RoundAction, order_id_: String = "", event_id_: String = "") -> bool:
	if action == GameEnums.RoundAction.NONE:
		return false
	var slot := current_day()
	if slot == null or slot.day_action != GameEnums.RoundAction.NONE:
		return false
	if slot.is_reserved_final(day_count) and action == GameEnums.RoundAction.APPOINTMENT:
		return false
	slot.day_action = action
	slot.order_id = order_id_
	if not event_id_.is_empty():
		slot.event_id = event_id_
	sync_days_left()
	return true


## Telemetry only — never a gate (docs/20, docs/22). Unlimited pieces.
func count_finished_piece() -> bool:
	crafts_done += 1
	return true


func advance_day() -> bool:
	if not GameConstants.is_schedule_day(day_index, day_count):
		return false
	if day_index >= day_count:
		return false
	day_index += 1
	return true


func to_dict() -> Dictionary:
	var pin_rows: Array = []
	for pin in appointment_pins:
		pin_rows.append(pin.to_dict())
	var day_rows: Array = []
	for slot in days:
		day_rows.append(slot.to_dict(day_count))
	var pool_rows: Array = []
	for event in event_pool:
		pool_rows.append(event.to_dict())
	var assign_rows: Array = []
	for row in day_assignments:
		assign_rows.append(row.to_dict())
	return {
		"player_owner_id": player_owner_id,
		"chapter_id": chapter_id,
		"chapter_boss_id": chapter_boss_id,
		"boss_pool_id": boss_pool_id,
		"map_id": map_id,
		"CHAPTER_DAY_COUNT": day_count,
		"day_index": null if day_index == GameConstants.NULL_INT else day_index,
		"days_left": days_left,
		"day_action": GameEnums.day_action_wire(current_day_action()),
		"event_pool": pool_rows,
		"day_assignments": assign_rows,
		"appointment_pins": pin_rows,
		"days": day_rows,
		"appt_decline_used": appt_decline_used,
		"crafts_done": crafts_done,
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if player_owner_id != GameConstants.PHASE1_OWNER_ID:
		errs.append("player_owner_id must be %s in Phase-1" % GameConstants.PHASE1_OWNER_ID)
	if chapter_id < 1 or chapter_id > GameConstants.CHAPTERS_PER_RUN:
		errs.append("chapter_id %d not in 1..%d" % [chapter_id, GameConstants.CHAPTERS_PER_RUN])
	if day_count != MapCatalog.day_count(map_id):
		errs.append("day_count %d != map.day_count %d" % [day_count, MapCatalog.day_count(map_id)])
	if days.size() != day_count:
		errs.append("days size %d != CHAPTER_DAY_COUNT %d" % [days.size(), day_count])
	if day_index != GameConstants.NULL_INT and not GameConstants.is_schedule_day(day_index, day_count):
		errs.append("day_index %d not in 1..%d" % [day_index, day_count])
	var seen_pin_days := {}
	var seen_pin_ids := {}
	for pin in appointment_pins:
		errs.append_array(pin.schema_errors(day_count))
		if seen_pin_days.has(pin.pinned_day):
			errs.append("duplicate appointment pin on day %d" % pin.pinned_day)
		seen_pin_days[pin.pinned_day] = true
		if seen_pin_ids.has(pin.appointment_id):
			errs.append("duplicate appointment_id %s" % pin.appointment_id)
		seen_pin_ids[pin.appointment_id] = true
	var seen_assign_days := {}
	var seen_assign_events := {}
	for row in day_assignments:
		errs.append_array(row.schema_errors(day_count))
		if seen_assign_days.has(row.day_index):
			errs.append("duplicate day_assignments on day %d" % row.day_index)
		seen_assign_days[row.day_index] = true
		if seen_assign_events.has(row.event_id):
			errs.append("duplicate day_assignments event %s" % row.event_id)
		seen_assign_events[row.event_id] = true
		var event := event_by_id(row.event_id)
		if event == null:
			errs.append("day_assignments unknown event %s" % row.event_id)
		elif not event.covers_day(row.day_index):
			errs.append("%s assigned to D%d outside window" % [row.event_id, row.day_index])
		elif event.fixed:
			var in_window := false
			for w in event.windows:
				if w == row.day_index:
					in_window = true
					break
			if not in_window:
				errs.append("fixed %s assigned outside window" % event.event_id)
	for event in event_pool:
		errs.append_array(event.schema_errors(day_count))
	for slot in days:
		errs.append_array(slot.schema_errors(day_count))
	if crafts_done < 0:
		errs.append("crafts_done %d < 0" % crafts_done)
	return errs
