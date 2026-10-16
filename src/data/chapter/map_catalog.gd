class_name MapCatalog
extends RefCounted
## Map settings for the route graph (docs/22, docs/20).
## Day count is per-map — not global law. Current map = 8.
## M1 panel = type + id only. No display titles this stamp.

const CURRENT_MAP_ID := "map_m1"
const NODE_KINDS := ["shop", "adventurer", "appointment", "event", "reserved"]
const START_NODE_ID := "N1"
const BIND_COMBO_MARKET := "combo_market"

## Current-map graph LOCKED (docs/22). Later maps stamp their own nodes + edges + day_count.
const MAPS := {
	"map_m1": {
		"map_id": "map_m1",
		"day_count": 8,
		"nodes": [
			{"node_id": "N1", "day_index": 1, "kind": "adventurer", "ref_id": "adv_halden_rook"},
			{"node_id": "N2", "day_index": 2, "kind": "shop"},
			{"node_id": "N3", "day_index": 2, "kind": "adventurer", "ref_id": "adv_vex_bramble"},
			{"node_id": "N4", "day_index": 2, "kind": "event", "ref_id": "evt_c1_heat_mirage"},
			{"node_id": "N5", "day_index": 3, "kind": "appointment", "ref_id": "appt_scrap_duelist"},
			{"node_id": "N6", "day_index": 3, "kind": "event", "ref_id": "evt_c1_ashfall"},
			{"node_id": "N7", "day_index": 4, "kind": "shop", "bound_block_id": "combo_market"},
			{"node_id": "N8", "day_index": 5, "kind": "adventurer", "ref_id": "adv_quill_lumen", "bound_block_id": "combo_market"},
			{"node_id": "N9", "day_index": 6, "kind": "adventurer", "ref_id": "adv_kite_thornreel", "bound_block_id": "combo_market"},
			{"node_id": "N10", "day_index": 4, "kind": "event", "ref_id": "evt_c1_scrap_market"},
			{"node_id": "N11", "day_index": 4, "kind": "adventurer", "ref_id": "adv_tide_glass"},
			{"node_id": "N12", "day_index": 5, "kind": "shop"},
			{"node_id": "N13", "day_index": 5, "kind": "adventurer", "ref_id": "adv_quill_lumen"},
			{"node_id": "N14", "day_index": 6, "kind": "adventurer", "ref_id": "adv_kite_thornreel"},
			{"node_id": "N15", "day_index": 6, "kind": "shop"},
			{"node_id": "N16", "day_index": 5, "kind": "shop"},
			{"node_id": "N17", "day_index": 6, "kind": "event", "ref_id": "evt_c1_salt_spray"},
			{"node_id": "R7", "day_index": 7, "kind": "reserved"},
			{"node_id": "R8", "day_index": 8, "kind": "reserved"},
		],
		"edges": [
			{"from": "N1", "to": "N2"},
			{"from": "N1", "to": "N3"},
			{"from": "N1", "to": "N4"},
			{"from": "N2", "to": "N5"},
			{"from": "N3", "to": "N5"},
			{"from": "N3", "to": "N6"},
			{"from": "N4", "to": "N6"},
			{"from": "N5", "to": "N7"},
			{"from": "N5", "to": "N10"},
			{"from": "N5", "to": "N11"},
			{"from": "N6", "to": "N7"},
			{"from": "N6", "to": "N11"},
			{"from": "N7", "to": "N8"},
			{"from": "N8", "to": "N9"},
			{"from": "N10", "to": "N12"},
			{"from": "N10", "to": "N13"},
			{"from": "N12", "to": "N14"},
			{"from": "N13", "to": "N15"},
			{"from": "N11", "to": "N16"},
			{"from": "N16", "to": "N17"},
			{"from": "N9", "to": "R7"},
			{"from": "N14", "to": "R7"},
			{"from": "N15", "to": "R7"},
			{"from": "N17", "to": "R7"},
			{"from": "R7", "to": "R8"},
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


static func node_rows(map_id: String = "") -> Array:
	var row := map_row(map_id)
	var nodes: Variant = row.get("nodes", [])
	if nodes is Array:
		return nodes as Array
	return []


static func edge_rows(map_id: String = "") -> Array:
	var row := map_row(map_id)
	var edges: Variant = row.get("edges", [])
	if edges is Array:
		return edges as Array
	return []


static func make_nodes(map_id: String = "") -> Array[RouteNode]:
	var out: Array[RouteNode] = []
	for item in node_rows(map_id):
		var row: Variant = item
		if row is Dictionary:
			out.append(RouteNode.from_row(row as Dictionary))
	return out


static func make_edges(map_id: String = "") -> Array[RouteEdge]:
	var out: Array[RouteEdge] = []
	for item in edge_rows(map_id):
		var row: Variant = item
		if row is Dictionary:
			out.append(RouteEdge.from_row(row as Dictionary))
	return out


static func is_node_kind(kind: String) -> bool:
	return kind in NODE_KINDS
