class_name RouteGraphView
extends Control
## Ugly M1 route graph: nodes + edges, columns by day (docs/22).
## Kind chips sit on RouteNodeView. Edges stay draw_line.

signal node_picked(node_id: String)

const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const BIND := Color(0.831, 0.478, 0.635)
const EDGE := Color(0.416, 0.345, 0.251)

var _row: HBoxContainer
var _columns: Array[VBoxContainer] = []
var _cards: Dictionary = {}
var _edges: Array[RouteEdge] = []
var _cut: Dictionary = {}
var _draft: Dictionary = {}
var _path: Dictionary = {}
var _pending_board: ChapterSchedule
var _bind_queued: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(0, 292)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 8)
	_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_row)


func bind(board: ChapterSchedule) -> void:
	if board == null:
		return
	# Click-draft: picked is still emitting when board_changed → bind.
	# Object.free() mid-signal is free-locked-object in Godot 4.7 — defer rebuild.
	_pending_board = board
	if _bind_queued:
		return
	_bind_queued = true
	call_deferred("_apply_bind")


func _apply_bind() -> void:
	_bind_queued = false
	var board: ChapterSchedule = _pending_board
	_pending_board = null
	if board == null or not is_inside_tree():
		return
	_ensure_columns(board.day_count)
	_cards.clear()
	_edges = board.route_edges
	_cut.clear()
	_draft.clear()
	_path.clear()
	for nid in board.route_path:
		_path[nid] = true
	for nid in board.draft_path:
		_draft[nid] = true
	var fork_ids := {}
	for node in board.fork_options():
		fork_ids[node.node_id] = true
	for i in range(_columns.size()):
		var col: VBoxContainer = _columns[i]
		var day_i := i + 1
		var head := col_head(col)
		if head != null:
			if board.is_reserved_day(day_i):
				if day_i == board.day_count:
					head.text = "D%d  boss approach" % day_i
				else:
					head.text = "D%d  travel / final prep" % day_i
			else:
				head.text = "D%d" % day_i
		_drop_stale_cards(col)
	for node in board.route_nodes:
		var col_i := node.day_index - 1
		if col_i < 0 or col_i >= _columns.size():
			continue
		var card := RouteNodeView.new()
		var is_cut := board.is_cut(node.node_id)
		if is_cut:
			_cut[node.node_id] = true
		card.picked.connect(_on_picked)
		_columns[col_i].add_child(card)
		_cards[node.node_id] = card
		card.bind(
			node,
			node.node_id == board.current_node_id and not AtelierSession.newspaper_open,
			_path.has(node.node_id) and node.node_id != board.current_node_id,
			_draft.has(node.node_id),
			is_cut,
			fork_ids.has(node.node_id),
			node.is_bound()
		)
	_fit_width()
	queue_redraw()
	call_deferred("queue_redraw")


func _drop_stale_cards(col: VBoxContainer) -> void:
	var stale: Array[Node] = []
	for child in col.get_children():
		if child is RouteNodeView:
			stale.append(child)
	for child in stale:
		var card := child as RouteNodeView
		if card == null:
			continue
		if card.picked.is_connected(_on_picked):
			card.picked.disconnect(_on_picked)
		col.remove_child(card)
		card.queue_free()


func col_head(col: VBoxContainer) -> Label:
	for child in col.get_children():
		if child is Label:
			return child as Label
	return null


func _ensure_columns(n: int) -> void:
	while _columns.size() < n:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 6)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var head := Label.new()
		head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.add_theme_font_size_override("font_size", 14)
		head.add_theme_color_override("font_color", GOLD)
		head.text = "D%d" % (_columns.size() + 1)
		col.add_child(head)
		_row.add_child(col)
		_columns.append(col)
	while _columns.size() > n:
		var col: Variant = _columns.pop_back()
		if col is Node:
			(col as Node).queue_free()


func _fit_width() -> void:
	var width := 0.0
	if _row != null:
		width = _row.get_combined_minimum_size().x
	custom_minimum_size = Vector2(width, 292)


func _on_picked(node_id: String) -> void:
	node_picked.emit(node_id)


func _draw() -> void:
	for edge in _edges:
		var a: Variant = _cards.get(edge.from_id, null)
		var b: Variant = _cards.get(edge.to_id, null)
		if a == null or b == null:
			continue
		if not (a is Control) or not (b is Control):
			continue
		var from_c: Control = a
		var to_c: Control = b
		var p1 := _center(from_c)
		var p2 := _center(to_c)
		var cut_edge := _cut.has(edge.from_id) or _cut.has(edge.to_id)
		var bind_edge := _is_bind_pair(edge.from_id, edge.to_id)
		var on_path := _path.has(edge.from_id) and _path.has(edge.to_id)
		var on_draft := _draft.has(edge.to_id) and (_draft.has(edge.from_id) or _path.has(edge.from_id))
		var color := EDGE
		var width := 2.0
		if cut_edge:
			color = Color(0.239, 0.204, 0.173, 0.35)
			width = 1.0
		elif bind_edge:
			color = BIND
			width = 4.0
		elif on_path:
			color = GOLD
			width = 3.0
		elif on_draft:
			color = Color(0.788, 0.635, 0.153, 0.45)
			width = 2.0
		draw_line(p1, p2, color, width, true)


func _center(card: Control) -> Vector2:
	var r := card.get_global_rect()
	var origin := get_global_rect().position
	return r.position - origin + r.size * 0.5


func _is_bind_pair(from_id: String, to_id: String) -> bool:
	return (
		(from_id == "N7" and to_id == "N8")
		or (from_id == "N8" and to_id == "N9")
	)
