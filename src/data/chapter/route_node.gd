class_name RouteNode
extends Resource
## One authored route-map node (docs/22, docs/20). M1 dump = type + id — no title field.

## Autoload has no class_name (Godot 4.7). Call statics on the script type.
const _GameConstants := preload("res://src/autoload/game_constants.gd")

@export var node_id: String = ""
@export var day_index: int = 1
@export var kind: String = "" ## shop | adventurer | appointment | event | reserved
@export var ref_id: String = "" ## adv_* / appt_* / empty
@export var bound_block_id: String = "" ## combo_market or empty


static func from_row(row: Dictionary) -> RouteNode:
	var node := RouteNode.new()
	node.node_id = String(row.get("node_id", ""))
	node.day_index = int(row.get("day_index", 0))
	node.kind = String(row.get("kind", ""))
	node.ref_id = String(row.get("ref_id", ""))
	node.bound_block_id = String(row.get("bound_block_id", ""))
	return node


func is_reserved() -> bool:
	return kind == "reserved"


func is_bound() -> bool:
	return not bound_block_id.is_empty()


func panel_line() -> String:
	## M1: type + id only. Keep adv_* / appt_* on the row when present.
	var line := "%s · %s" % [kind, node_id]
	if not ref_id.is_empty():
		line += "  %s" % ref_id
	return line


func option_row() -> Dictionary:
	var ref: Variant = null if ref_id.is_empty() else ref_id
	return {
		"node_id": node_id,
		"kind": kind,
		"ref_id": ref,
	}


func to_dict() -> Dictionary:
	var ref: Variant = null if ref_id.is_empty() else ref_id
	var bound: Variant = null if bound_block_id.is_empty() else bound_block_id
	return {
		"node_id": node_id,
		"day_index": day_index,
		"kind": kind,
		"ref_id": ref,
		"bound_block_id": bound,
	}


func schema_errors(day_count: int) -> PackedStringArray:
	var errs := PackedStringArray()
	if node_id.is_empty():
		errs.append("node_id empty")
	if kind not in ["shop", "adventurer", "appointment", "event", "reserved"]:
		errs.append("%s kind %s not in shop/adventurer/appointment/event/reserved" % [node_id, kind])
	if kind == "reserved":
		if not _GameConstants.is_reserved_final_day(day_index, day_count):
			errs.append("%s reserved day_index %d not last-2 for N=%d" % [node_id, day_index, day_count])
	else:
		if not _GameConstants.is_assignable_day(day_index, day_count):
			errs.append("%s day_index %d not in 1..(N-2) for N=%d" % [node_id, day_index, day_count])
	if kind == "appointment" and not ref_id.begins_with("appt_"):
		errs.append("%s appointment ref_id must be appt_*" % node_id)
	if kind == "adventurer" and not ref_id.begins_with("adv_"):
		errs.append("%s adventurer ref_id must be adv_*" % node_id)
	if kind == "appointment" and ref_id.begins_with("adv_"):
		errs.append("%s appointment must not use adv_* (Scrap Duelist stays appt_*)" % node_id)
	return errs
