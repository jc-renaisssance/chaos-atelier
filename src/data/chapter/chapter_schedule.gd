class_name ChapterSchedule
extends Resource
## Route-graph board (docs/22). Day count from map.day_count. No piece cap.

@export var player_owner_id: String = GameConstants.PHASE1_OWNER_ID
@export var chapter_id: int = 1
@export var chapter_boss_id: String = ""
@export var boss_pool_id: String = ""
@export var map_id: String = MapCatalog.CURRENT_MAP_ID
@export var day_count: int = 0 ## = map.day_count this chapter
@export var day_index: int = GameConstants.NULL_INT ## 1..N once a day is live
@export var days_left: int = 0
@export var days: Array[ScheduleDay] = []
@export var route_nodes: Array[RouteNode] = []
@export var route_edges: Array[RouteEdge] = []
@export var route_path: Array[String] = [] ## confirmed node ids — never drafts
@export var draft_path: Array[String] = [] ## ghost future only
@export var current_node_id: String = ""
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
	board.route_nodes = MapCatalog.make_nodes(board.map_id)
	board.route_edges = MapCatalog.make_edges(board.map_id)
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


func node_by_id(node_id: String) -> RouteNode:
	for node in route_nodes:
		if node.node_id == node_id:
			return node
	return null


func nodes_on_day(day_i: int) -> Array[RouteNode]:
	var out: Array[RouteNode] = []
	for node in route_nodes:
		if node.day_index == day_i:
			out.append(node)
	return out


func outgoing_ids(from_id: String) -> Array[String]:
	var out: Array[String] = []
	for edge in route_edges:
		if edge.from_id == from_id:
			out.append(edge.to_id)
	return out


func pin_at(day_i: int) -> AppointmentPin:
	for pin in appointment_pins:
		if pin.pinned_day == day_i:
			return pin
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


func dump_day_action() -> Variant:
	var slot := current_day()
	if slot == null or slot.day_action == GameEnums.RoundAction.NONE:
		return null
	if is_reserved_day(day_index):
		return "reserved"
	return GameEnums.day_action_wire(slot.day_action)


func current_node() -> RouteNode:
	return node_by_id(current_node_id)


func node_for_day(day_i: int) -> RouteNode:
	for nid in route_path:
		var node := node_by_id(nid)
		if node != null and node.day_index == day_i:
			return node
	if day_i == day_index:
		return current_node()
	return null


func current_pin() -> AppointmentPin:
	var node := node_for_day(day_index)
	if node == null or node.kind != "appointment":
		return null
	for pin in appointment_pins:
		if pin.node_id == node.node_id:
			return pin
	return null


func bound_block_id() -> String:
	var node := current_node()
	if node == null:
		return ""
	return node.bound_block_id


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


func last_confirmed_id() -> String:
	if route_path.is_empty():
		return ""
	return route_path[route_path.size() - 1]


func day_node_confirmed(day_i: int = 0) -> bool:
	var d := day_i if day_i > 0 else day_index
	return node_for_day(d) != null and _path_has_day(d)


func _path_has_day(day_i: int) -> bool:
	for nid in route_path:
		var node := node_by_id(nid)
		if node != null and node.day_index == day_i:
			return true
	return false


func begin_live(boss_id: String, pool_id: String) -> void:
	chapter_boss_id = boss_id
	boss_pool_id = pool_id
	appt_decline_used = false
	crafts_done = 0
	player_owner_id = GameConstants.PHASE1_OWNER_ID
	day_index = 1
	route_path.clear()
	draft_path.clear()
	current_node_id = MapCatalog.START_NODE_ID
	appointment_pins.clear()
	for slot in days:
		slot.day_action = GameEnums.RoundAction.NONE
		slot.order_id = ""
		slot.event_id = ""
		slot.node_id = ""
	_sync_pins()
	sync_days_left()
	enter_current_day()


func enter_current_day() -> void:
	if not GameConstants.is_schedule_day(day_index, day_count):
		return
	if day_index == 1:
		_confirm_internal(MapCatalog.START_NODE_ID)
		_prune_draft()
		return
	if _path_has_day(day_index):
		var pinned := node_for_day(day_index)
		if pinned != null:
			current_node_id = pinned.node_id
		_prune_draft()
		return
	var prev := last_confirmed_id()
	var today := _outgoing_on_day(prev, day_index)
	if today.size() == 1:
		_confirm_internal(today[0])
	_prune_draft()


func _outgoing_on_day(from_id: String, day_i: int) -> Array[String]:
	var out: Array[String] = []
	for nid in outgoing_ids(from_id):
		var node := node_by_id(nid)
		if node != null and node.day_index == day_i:
			out.append(nid)
	return out


func fork_options() -> Array[RouteNode]:
	var out: Array[RouteNode] = []
	if not GameConstants.is_schedule_day(day_index, day_count):
		return out
	if is_reserved_day(day_index):
		return out
	if day_index == 1:
		return out
	if is_day_played(day_index):
		return out
	if _path_has_day(day_index):
		return out
	var prev := last_confirmed_id()
	if prev.is_empty():
		return out
	var prev_node := node_by_id(prev)
	if prev_node != null and prev_node.is_bound() and outgoing_ids(prev).size() == 1:
		return out
	var ids := _outgoing_on_day(prev, day_index)
	if ids.size() < 2 or ids.size() > 4:
		return out
	for nid in ids:
		var node := node_by_id(nid)
		if node != null:
			out.append(node)
	return out


func fork_option_rows() -> Array:
	var rows: Array = []
	for node in fork_options():
		rows.append(node.option_row())
	return rows


func can_confirm_node(node_id: String) -> bool:
	return confirm_reason(node_id).is_empty()


func confirm_reason(node_id: String) -> String:
	if is_day_played(day_index):
		return "D%d is frozen (played)" % day_index
	if day_index == 1:
		return "D1 is fixed (N1) — no fork panel"
	if is_reserved_day(day_index):
		return "D%d is reserved — no fork panel" % day_index
	if _path_has_day(day_index):
		return "D%d already confirmed" % day_index
	var opts := fork_options()
	if opts.is_empty():
		return "no live fork on D%d" % day_index
	for node in opts:
		if node.node_id == node_id:
			return ""
	return "%s is not an outgoing option of %s" % [node_id, last_confirmed_id()]


func confirm_node(node_id: String) -> bool:
	if not can_confirm_node(node_id):
		return false
	_confirm_internal(node_id)
	_prune_draft()
	return true


func _confirm_internal(node_id: String) -> void:
	var node := node_by_id(node_id)
	if node == null:
		return
	if node.node_id in route_path:
		current_node_id = node.node_id
		var slot := slot_at(node.day_index)
		if slot != null:
			slot.node_id = node.node_id
			slot.event_id = node.node_id
		return
	route_path.append(node.node_id)
	current_node_id = node.node_id
	var live := slot_at(node.day_index)
	if live != null and not live.is_played():
		live.node_id = node.node_id
		live.event_id = node.node_id


func can_draft_node(node_id: String) -> bool:
	var node := node_by_id(node_id)
	if node == null or node.is_reserved():
		return false
	if node.day_index <= day_index:
		return false
	if is_day_played(node.day_index):
		return false
	if _path_has_day(node.day_index):
		return false
	var bound := bound_block_id()
	if not bound.is_empty() and node.bound_block_id == bound:
		return false
	var path := _shortest_future_path(node_id)
	return not path.is_empty()


func draft_node(node_id: String) -> bool:
	if not can_draft_node(node_id):
		return false
	if node_id in draft_path:
		var kept: Array[String] = []
		for nid in draft_path:
			kept.append(nid)
			if nid == node_id:
				break
		draft_path = kept
		return true
	var path := _shortest_future_path(node_id)
	if path.is_empty():
		return false
	draft_path = path
	return true


func _shortest_future_path(target_id: String) -> Array[String]:
	var start := last_confirmed_id()
	if start.is_empty():
		start = current_node_id
	if start.is_empty():
		return []
	var came := {}
	var queue: Array[String] = [start]
	var seen := {start: true}
	var found := false
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		if cur == target_id and cur != start:
			found = true
			break
		for nid in outgoing_ids(cur):
			if seen.has(nid):
				continue
			var node := node_by_id(nid)
			if node == null:
				continue
			if node.day_index < day_index:
				continue
			if node.day_index == day_index and _path_has_day(day_index) and nid != current_node_id:
				continue
			if node.day_index == day_index and nid in route_path:
				continue
			if is_day_played(node.day_index):
				continue
			seen[nid] = true
			came[nid] = cur
			queue.append(nid)
	if not found and not came.has(target_id):
		return []
	var walk: Array[String] = []
	var step := target_id
	while step != start and came.has(step):
		walk.push_front(step)
		step = String(came[step])
	if step != start:
		return []
	var future: Array[String] = []
	for nid in walk:
		var node := node_by_id(nid)
		if node != null and node.day_index > day_index:
			future.append(nid)
	return future


func _prune_draft() -> void:
	if draft_path.is_empty():
		return
	var kept: Array[String] = []
	var from_id := last_confirmed_id()
	if from_id.is_empty():
		from_id = current_node_id
	for nid in draft_path:
		if nid in route_path:
			continue
		var node := node_by_id(nid)
		if node == null or node.day_index <= day_index:
			continue
		if not _has_edge(from_id, nid) and kept.is_empty():
			## allow if reachable from last kept / from_id
			if not can_draft_node(nid):
				break
		if not kept.is_empty():
			if not _has_edge(kept[kept.size() - 1], nid):
				break
		elif not _has_edge(from_id, nid):
			var hop := _shortest_future_path(nid)
			if hop.is_empty():
				break
			kept = hop
			from_id = nid
			continue
		kept.append(nid)
		from_id = nid
	draft_path = kept


func _has_edge(from_id: String, to_id: String) -> bool:
	for edge in route_edges:
		if edge.from_id == from_id and edge.to_id == to_id:
			return true
	return false


func is_cut(node_id: String) -> bool:
	if node_id in route_path or node_id == current_node_id:
		return false
	var node := node_by_id(node_id)
	if node == null:
		return true
	if node.day_index < day_index:
		return true
	if node.day_index == day_index and _path_has_day(day_index) and node_id != current_node_id:
		return true
	var start := last_confirmed_id()
	if start.is_empty():
		start = current_node_id
	if start.is_empty():
		return false
	if node_id == start:
		return false
	var seen := {start: true}
	var queue: Array[String] = [start]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		if cur == node_id:
			return false
		for nid in outgoing_ids(cur):
			if seen.has(nid):
				continue
			var nxt := node_by_id(nid)
			if nxt == null:
				continue
			if nxt.day_index < day_index:
				continue
			if nxt.day_index == day_index and _path_has_day(day_index) and nid != current_node_id:
				continue
			seen[nid] = true
			queue.append(nid)
	return true


func shops_on_path() -> int:
	var n := 0
	for nid in route_path:
		var node := node_by_id(nid)
		if node != null and node.kind == "shop" and not node.is_reserved():
			n += 1
	return n


func _sync_pins() -> void:
	appointment_pins.clear()
	for node in route_nodes:
		if node.kind != "appointment":
			continue
		var pin := AppointmentPin.new()
		pin.appointment_id = node.ref_id
		pin.node_id = node.node_id
		pin.pinned_day = node.day_index
		var appt: Dictionary = ScheduleCatalog.appointment_row(node.ref_id)
		pin.order_id = String(appt.get("order_id", ""))
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
	if not day_node_confirmed():
		return false
	slot.day_action = action
	slot.order_id = order_id_
	var node := current_node()
	if node != null:
		slot.node_id = node.node_id
		slot.event_id = node.node_id if event_id_.is_empty() else event_id_
	elif not event_id_.is_empty():
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
	enter_current_day()
	return true


func to_dict() -> Dictionary:
	var pin_rows: Array = []
	for pin in appointment_pins:
		pin_rows.append(pin.to_dict())
	var day_rows: Array = []
	for slot in days:
		day_rows.append(slot.to_dict(day_count))
	var node_rows: Array = []
	for node in route_nodes:
		node_rows.append(node.to_dict())
	var edge_rows: Array = []
	for edge in route_edges:
		edge_rows.append(edge.to_dict())
	var path_rows: Array = []
	for nid in route_path:
		path_rows.append(nid)
	var draft_rows: Array = []
	for nid in draft_path:
		draft_rows.append(nid)
	var bound := bound_block_id()
	return {
		"player_owner_id": player_owner_id,
		"chapter_id": chapter_id,
		"chapter_boss_id": chapter_boss_id,
		"boss_pool_id": boss_pool_id,
		"map_id": map_id,
		"route_map_id": map_id,
		"CHAPTER_DAY_COUNT": day_count,
		"day_index": null if day_index == GameConstants.NULL_INT else day_index,
		"days_left": days_left,
		"day_action": dump_day_action(),
		"route_nodes": node_rows,
		"route_edges": edge_rows,
		"route_path": path_rows,
		"draft_path": draft_rows,
		"current_node_id": null if current_node_id.is_empty() else current_node_id,
		"bound_block_id": null if bound.is_empty() else bound,
		"fork_options": fork_option_rows(),
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
	var seen_nodes := {}
	for node in route_nodes:
		errs.append_array(node.schema_errors(day_count))
		if seen_nodes.has(node.node_id):
			errs.append("duplicate route node %s" % node.node_id)
		seen_nodes[node.node_id] = true
	for edge in route_edges:
		errs.append_array(edge.schema_errors())
		if not seen_nodes.has(edge.from_id) or not seen_nodes.has(edge.to_id):
			errs.append("edge %s→%s missing node" % [edge.from_id, edge.to_id])
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
	for nid in route_path:
		if not seen_nodes.has(nid):
			errs.append("route_path unknown node %s" % nid)
		if nid in draft_path:
			errs.append("draft_path must not overlap confirmed %s" % nid)
	for nid in draft_path:
		if not seen_nodes.has(nid):
			errs.append("draft_path unknown node %s" % nid)
	var d1 := node_by_id(MapCatalog.START_NODE_ID)
	if d1 == null or d1.day_index != 1 or d1.kind != "adventurer":
		errs.append("D1 must be N1 adventurer")
	var opts := fork_options()
	if opts.size() == 1 or opts.size() > 4:
		errs.append("live fork_options length %d not in 2..4" % opts.size())
	if crafts_done < 0:
		errs.append("crafts_done %d < 0" % crafts_done)
	for slot in days:
		errs.append_array(slot.schema_errors(day_count))
	return errs
