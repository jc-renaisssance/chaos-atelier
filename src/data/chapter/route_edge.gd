class_name RouteEdge
extends Resource
## Authored directed edge on the route map (docs/22, docs/20). Not seeded.

@export var from_id: String = ""
@export var to_id: String = ""


static func from_row(row: Dictionary) -> RouteEdge:
	var edge := RouteEdge.new()
	edge.from_id = String(row.get("from", row.get("from_id", "")))
	edge.to_id = String(row.get("to", row.get("to_id", "")))
	return edge


func to_dict() -> Dictionary:
	return {
		"from": from_id,
		"to": to_id,
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if from_id.is_empty() or to_id.is_empty():
		errs.append("route_edges row missing from/to")
	return errs
