class_name PlannerEvent
extends Resource
## One E* row (docs/20, docs/22). M1 dump = type + id — no title field.

@export var event_id: String = ""
@export var kind: String = "" ## shop | adventurer | appointment | event
@export var windows: Array[int] = []
@export var fixed: bool = false
@export var ref_id: String = "" ## adv_* / appt_* / empty


static func from_row(row: Dictionary) -> PlannerEvent:
	var event := PlannerEvent.new()
	event.event_id = String(row.get("event_id", ""))
	event.kind = String(row.get("kind", ""))
	event.fixed = bool(row.get("fixed", false))
	event.ref_id = String(row.get("ref_id", ""))
	var raw: Variant = row.get("windows", [])
	event.windows.clear()
	if raw is Array:
		for item in raw:
			event.windows.append(int(item))
	return event


func covers_day(day_index: int) -> bool:
	return day_index in windows


func panel_line() -> String:
	## M1: type + id only. Keep adv_* / appt_* on the row when present.
	var line := "%s · %s" % [kind, event_id]
	if not ref_id.is_empty():
		line += "  %s" % ref_id
	return line


func to_dict() -> Dictionary:
	var refs: Variant = null if ref_id.is_empty() else ref_id
	var days: Array = []
	for day_i in windows:
		days.append(day_i)
	return {
		"event_id": event_id,
		"kind": kind,
		"windows": days,
		"fixed": fixed,
		"ref_id": refs,
	}


func schema_errors(day_count: int) -> PackedStringArray:
	var errs := PackedStringArray()
	if event_id.is_empty():
		errs.append("event_id empty")
	if kind not in ["shop", "adventurer", "appointment", "event"]:
		errs.append("kind %s not in shop/adventurer/appointment/event" % kind)
	if windows.is_empty():
		errs.append("%s windows empty" % event_id)
	for day_i in windows:
		if not GameConstants.is_assignable_day(day_i, day_count):
			errs.append("%s window day %d not assignable for N=%d" % [event_id, day_i, day_count])
	if kind == "appointment" and not ref_id.begins_with("appt_"):
		errs.append("%s appointment ref_id must be appt_*" % event_id)
	if kind == "adventurer" and not ref_id.begins_with("adv_"):
		errs.append("%s adventurer ref_id must be adv_*" % event_id)
	if kind == "appointment" and ref_id.begins_with("adv_"):
		errs.append("%s appointment must not use adv_* (Scrap Duelist stays appt_*)" % event_id)
	return errs
