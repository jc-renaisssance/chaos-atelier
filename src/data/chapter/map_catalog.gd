class_name MapCatalog
extends RefCounted
## Map settings for the Day planner (docs/22, docs/20).
## Day count is per-map — not global law. Current map = 8.
## M1 E* panel = type + id only. No display titles this stamp.

const CURRENT_MAP_ID := "map_m1"
const EVENT_KINDS := ["shop", "adventurer", "appointment", "event"]

## Current-map sketch LOCKED (docs/22). Later maps stamp their own pool + day_count.
const MAPS := {
	"map_m1": {
		"map_id": "map_m1",
		"day_count": 8,
		"event_pool": [
			{"event_id": "E5", "kind": "adventurer", "windows": [1], "fixed": true, "ref_id": "adv_halden_rook"},
			{"event_id": "E1", "kind": "shop", "windows": [2], "fixed": true, "ref_id": ""},
			{"event_id": "E2", "kind": "adventurer", "windows": [2], "fixed": false, "ref_id": "adv_vex_bramble"},
			{"event_id": "E3", "kind": "event", "windows": [2, 3], "fixed": false, "ref_id": ""},
			{"event_id": "E4", "kind": "adventurer", "windows": [2, 6], "fixed": false, "ref_id": "adv_kite_thornreel"},
			{"event_id": "E6", "kind": "shop", "windows": [3, 4], "fixed": false, "ref_id": ""},
			{"event_id": "E8", "kind": "appointment", "windows": [3], "fixed": true, "ref_id": "appt_c1_scrap_duelist"},
			{"event_id": "E13", "kind": "event", "windows": [3], "fixed": false, "ref_id": ""},
			{"event_id": "E7", "kind": "event", "windows": [4], "fixed": false, "ref_id": ""},
			{"event_id": "E9", "kind": "adventurer", "windows": [4, 5], "fixed": false, "ref_id": "adv_quill_lumen"},
			{"event_id": "E10", "kind": "shop", "windows": [5, 6], "fixed": false, "ref_id": ""},
			{"event_id": "E11", "kind": "event", "windows": [5], "fixed": false, "ref_id": ""},
			{"event_id": "E12", "kind": "adventurer", "windows": [6], "fixed": false, "ref_id": "adv_tide_glass"},
		],
	},
}


static func map_row(map_id: String = "") -> Dictionary:
	var id := map_id if not map_id.is_empty() else CURRENT_MAP_ID
	var row: Variant = MAPS.get(id, {})
	if row is Dictionary:
		return row as Dictionary
	return {}


static func day_count(map_id: String = "") -> int:
	var row := map_row(map_id)
	return int(row.get("day_count", 0))


static func event_pool_rows(map_id: String = "") -> Array:
	var row := map_row(map_id)
	var pool: Variant = row.get("event_pool", [])
	if pool is Array:
		return pool as Array
	return []


static func make_event_pool(map_id: String = "") -> Array[PlannerEvent]:
	var out: Array[PlannerEvent] = []
	for item in event_pool_rows(map_id):
		var row: Variant = item
		if row is Dictionary:
			out.append(PlannerEvent.from_row(row as Dictionary))
	return out


static func is_event_kind(kind: String) -> bool:
	return kind in EVENT_KINDS
