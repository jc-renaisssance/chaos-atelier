extends Control
## Travelling-atelier route graph (docs/22). Craft is a dedicated screen (docs/27).

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)

var _title: Label
var _meta: Label
var _note: Label
var _planner_caption: Label
var _graph: RouteGraphView
var _options_caption: Label
var _options_panel: PanelContainer
var _options_title: Label
var _options: VBoxContainer
var _draft_lab: Label
var _today_title: Label
var _actions: HFlowContainer
var _resolve_title: Label
var _resolve_body: Label
var _stamp: Label
var _continue_btn: Button
var _decline_btn: Button
var _take_btn: Button
var _schedule_root: Control
var _body_scroll: ScrollContainer
var _craft_table: CraftTable
var _dex_screen: DexScreen
var _market_screen: MarketScreen
var _event_screen: EventScreen
var _dex_open: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	AtelierSession.board_changed.connect(_redraw)
	AtelierSession.resolve_started.connect(_on_resolve)
	AtelierSession.chapter_finished.connect(_redraw)
	AtelierSession.craft_started.connect(_redraw)
	AtelierSession.craft_changed.connect(_redraw)
	AtelierSession.craft_order_finished.connect(_redraw)
	_redraw()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = WOOD
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)
	_schedule_root = margin

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	_title = _label("WOMBASTE  ·  travelling wagon", 26, GOLD)
	root.add_child(_title)
	_meta = _label("", 15, INK)
	_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_meta)
	_note = _label("", 14, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_note)

	_planner_caption = _caption("ROUTE GRAPH  ·  map_m1  ·  nodes + edges  ·  ugly M1")
	root.add_child(_planner_caption)
	var graph_panel := _panel()
	graph_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(graph_panel)
	_graph = RouteGraphView.new()
	_graph.node_picked.connect(_on_graph_pick)
	graph_panel.add_child(_graph)

	## 1280×720: graph stays put; FORK OPTIONS / TODAY / RESOLVE scroll.
	_body_scroll = ScrollContainer.new()
	_body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(_body_scroll)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.add_child(body)

	_options_caption = _caption("FORK OPTIONS  ·  type + id  ·  current choice only")
	body.add_child(_options_caption)
	_options_panel = _panel()
	_options_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_options_panel)
	var options_box := VBoxContainer.new()
	options_box.add_theme_constant_override("separation", 6)
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_options_panel.add_child(options_box)
	_options_title = _label("No live fork.", 15, INK)
	_options_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_options_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_box.add_child(_options_title)
	_options = VBoxContainer.new()
	_options.add_theme_constant_override("separation", 4)
	_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_box.add_child(_options)
	_draft_lab = _label("", 13, MUTED)
	_draft_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_draft_lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_draft_lab)

	body.add_child(_caption("TODAY  ·  one primary action from the current node"))
	var today := _panel()
	today.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(today)
	var today_box := VBoxContainer.new()
	today_box.add_theme_constant_override("separation", 8)
	today_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	today.add_child(today_box)
	_today_title = _label("D1 is N1. Confirm forks when current.", 16, INK)
	_today_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_today_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	today_box.add_child(_today_title)
	_actions = HFlowContainer.new()
	_actions.add_theme_constant_override("h_separation", 8)
	_actions.add_theme_constant_override("v_separation", 8)
	_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	today_box.add_child(_actions)
	var today_row := HBoxContainer.new()
	today_row.add_theme_constant_override("separation", 8)
	today_box.add_child(today_row)
	_take_btn = _btn("Take node", _on_take)
	today_row.add_child(_take_btn)
	_decline_btn = _btn("Decline appointment (−reps)", _on_decline)
	today_row.add_child(_decline_btn)
	_continue_btn = _btn("Continue", _on_continue)
	today_row.add_child(_continue_btn)

	body.add_child(_caption("RESOLVE  ·  mission (23/24)  ·  no lineup cards"))
	var resolve := _panel()
	resolve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(resolve)
	var resolve_box := VBoxContainer.new()
	resolve_box.add_theme_constant_override("separation", 6)
	resolve_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resolve.add_child(resolve_box)
	_resolve_title = _label("Waiting for a pick.", 16, GOLD)
	_resolve_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_resolve_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resolve_box.add_child(_resolve_title)
	_resolve_body = _label(
		"Current node: adventurer / appointment → stamina craft. "
		+ "Shop / event / reserved stay phase=schedule. Draft is ghost only.",
		14,
		INK
	)
	_resolve_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_resolve_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resolve_box.add_child(_resolve_body)

	body.add_child(_caption("STAMP  ·  docs/20 full dump  ·  crafts_done unbounded telemetry"))
	var stamp_panel := _panel()
	stamp_panel.custom_minimum_size.y = 96
	stamp_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(stamp_panel)
	var stamp_scroll := ScrollContainer.new()
	stamp_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stamp_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stamp_scroll.custom_minimum_size.y = 80
	stamp_panel.add_child(stamp_scroll)
	_stamp = _label("{}", 12, MUTED)
	_stamp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stamp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stamp_scroll.add_child(_stamp)

	var demo := HBoxContainer.new()
	demo.add_theme_constant_override("separation", 8)
	demo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(demo)
	demo.add_child(_btn("Dex", _on_dex))
	demo.add_child(_btn("Reroll this chapter", _on_reroll))
	demo.add_child(_btn("Demo next chapter", _on_next_chapter))
	var hint := _label("Dex · shop / menu collection list. Market on kind=shop. Text events on N4/N6/N10/N17. Staffs / skills / gear = M2.", 12, MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	demo.add_child(hint)

	_craft_table = CraftTable.new()
	_craft_table.visible = false
	_craft_table.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_craft_table)

	_dex_screen = DexScreen.new()
	_dex_screen.visible = false
	_dex_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dex_screen.closed.connect(_on_dex_closed)
	add_child(_dex_screen)

	_market_screen = MarketScreen.new()
	_market_screen.visible = false
	_market_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_market_screen)

	_event_screen = EventScreen.new()
	_event_screen.visible = false
	_event_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_event_screen)


func _caption(text: String) -> Label:
	return _label(text, 12, GOLD)


func _label(text: String, size: int, color: Color) -> Label:
	var lab := Label.new()
	lab.text = text
	lab.add_theme_font_size_override("font_size", size)
	lab.add_theme_color_override("font_color", color)
	return lab


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(1)
	sb.border_color = BORDER
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", sb)
	return panel


func _btn(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.pressed.connect(cb)
	return btn


func _redraw() -> void:
	var in_craft := AtelierSession.craft_open
	var in_market := AtelierSession.market_open
	var in_event := AtelierSession.event_open
	if in_craft or in_market or in_event:
		_dex_open = false
	if _dex_screen != null:
		_dex_screen.visible = _dex_open and not in_craft and not in_market and not in_event
	if _schedule_root != null:
		_schedule_root.visible = not in_craft and not _dex_open and not in_market and not in_event
	if _craft_table != null:
		_craft_table.visible = in_craft
		if in_craft:
			_craft_table.refresh()
	if _market_screen != null:
		_market_screen.visible = in_market
		if in_market:
			_market_screen.refresh()
	if _event_screen != null:
		_event_screen.visible = in_event
		if in_event:
			_event_screen.refresh()
	if in_craft:
		return
	if in_market or in_event:
		return
	if _dex_open:
		if _dex_screen != null:
			_dex_screen.refresh()
		return
	var board: ChapterSchedule = AtelierSession.board
	if board == null:
		return
	var n := board.day_count
	var boss := ScheduleCatalog.boss_title(board.chapter_boss_id)
	_title.text = "WOMBASTE  ·  travelling wagon  ·  %s" % board.player_owner_id
	_planner_caption.text = "ROUTE GRAPH  ·  %s  ·  %d days (map.day_count)  ·  last 2 reserved  ·  nodes + edges" % [board.map_id, n]
	_meta.text = (
		"Chapter %d / %d   ·   boss %s (%s)   ·   day %s / %d   ·   %d left   ·   node %s   ·   pieces %d   ·   gold %d   ·   reps %d (gate stub %d)   ·   decline %s   ·   seed %d"
		% [
			board.chapter_id,
			GameConstants.CHAPTERS_PER_RUN,
			boss,
			board.boss_pool_id,
			"—" if AtelierSession.newspaper_open else str(board.day_index),
			n,
			board.days_left,
			board.current_node_id if not board.current_node_id.is_empty() else "—",
			board.crafts_done,
			AtelierSession.gold,
			AtelierSession.reps,
			GameConstants.REPS_GATE_STUB,
			"used" if board.appt_decline_used else "open (once / chapter)",
			AtelierSession.chapter_seed,
		]
	)
	_note.text = AtelierSession.last_note
	if _graph != null:
		_graph.bind(board)
	_rebuild_options()
	_rebuild_actions()
	_refresh_resolve()
	_stamp.text = JSON.stringify(AtelierSession.stamp_preview(), "  ")


func _rebuild_options() -> void:
	for child in _options.get_children():
		child.queue_free()
	var board: ChapterSchedule = AtelierSession.board
	if board == null:
		return
	var opts := board.fork_options()
	var show := not opts.is_empty() and not AtelierSession.newspaper_open
	if _options_caption != null:
		_options_caption.visible = show
	if _options_panel != null:
		_options_panel.visible = show
	var draft_line := ""
	if not board.draft_path.is_empty():
		draft_line = "DRAFT  ·  ghost only  ·  %s" % ", ".join(board.draft_path)
	if _draft_lab != null:
		_draft_lab.text = draft_line
		_draft_lab.visible = not draft_line.is_empty()
	if not show:
		_options_title.text = "No live fork — corridor / bind / reserved / D1 / draft-only future hide this panel."
		return
	_options_title.text = "D%d  ·  %d next  ·  M1 type + id  ·  confirm writes route_path" % [board.day_index, opts.size()]
	for node in opts:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var lab := _label(node.panel_line(), 14, INK)
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lab)
		if AtelierSession.can_confirm_node(node.node_id):
			var btn := _btn("Confirm", _on_confirm.bind(node.node_id))
			row.add_child(btn)
		_options.add_child(row)


func _rebuild_actions() -> void:
	for child in _actions.get_children():
		child.queue_free()
	var board: ChapterSchedule = AtelierSession.board
	var legal: Array[GameEnums.RoundAction] = AtelierSession.legal_actions()
	_decline_btn.visible = AtelierSession.can_decline()
	_decline_btn.disabled = not AtelierSession.can_decline()
	_take_btn.visible = not AtelierSession.newspaper_open and not AtelierSession.resolve_open and not AtelierSession.awaiting_boss and not AtelierSession.boss_open and not AtelierSession.chapter_over and not AtelierSession.run_over
	_take_btn.disabled = legal.is_empty()
	_continue_btn.visible = AtelierSession.resolve_open or AtelierSession.chapter_over or AtelierSession.run_over
	_continue_btn.disabled = not AtelierSession.resolve_open
	if AtelierSession.newspaper_open:
		_today_title.text = "Kingdom newspaper — boss announced. Dismiss into the route graph."
		_continue_btn.text = "Open the route graph"
		_take_btn.visible = false
		return
	if AtelierSession.boss_open:
		_today_title.text = "Boss encounter resolved."
		_continue_btn.text = "Run over" if AtelierSession.run_over else "Close the chapter"
		_take_btn.visible = false
		return
	if AtelierSession.awaiting_boss:
		_today_title.text = "Day budget finished. Draw a shared-pool adventurer and sew that job vs the announced boss."
		_continue_btn.text = "Draw the fighter"
		_take_btn.visible = false
		return
	if AtelierSession.chapter_over or AtelierSession.run_over:
		_today_title.text = "Chapter closed." if not AtelierSession.run_over else "Run over — no retry."
		_continue_btn.text = "Chapter closed"
		_continue_btn.disabled = true
		_take_btn.visible = false
		return
	if AtelierSession.resolve_open:
		_today_title.text = "Action locked. Continue after the mission / event result."
		_continue_btn.text = "Continue"
		_take_btn.visible = false
		return
	if board == null:
		return
	var pin: AppointmentPin = board.current_pin()
	var node: RouteNode = board.node_for_day(board.day_index)
	if not board.day_node_confirmed():
		_today_title.text = "Live fork on D%d — confirm 1 of %d next nodes (type + id). Draft is not a pick." % [board.day_index, board.fork_options().size()]
		_take_btn.text = "Take node"
		_take_btn.disabled = true
		return
	if pin != null and node != null and node.kind == "appointment" and not AtelierSession.declined_this_day:
		_today_title.text = (
			"Current node %s appointment: %s. Take it, or decline once this chapter (−reps)."
			% [node.node_id, pin.appointment_id]
		)
		_take_btn.text = "Take appointment"
	elif board != null and board.is_reserved_day(board.day_index):
		if board.day_index == board.day_count:
			_today_title.text = "Reserved D%d — boss approach. Not player-pickable." % board.day_index
			_take_btn.text = "Resolve reserved day"
		else:
			_today_title.text = "Reserved D%d — travel / final prep. Not player-pickable." % board.day_index
			_take_btn.text = "Resolve reserved day"
	elif node != null:
		_today_title.text = "Current node %s. Take it. Market 1–3 is graph law — not a UI ban." % node.panel_line()
		_take_btn.text = "Take node"
	else:
		_today_title.text = "Confirm today's node, then take it."
		_take_btn.text = "Take node"
	for action in legal:
		if node != null and action == ScheduleRules.action_for_kind(node.kind) and not AtelierSession.declined_this_day:
			continue
		if board != null and board.is_reserved_day(board.day_index) and action == GameEnums.RoundAction.REST_DIG:
			continue
		var label := ScheduleCatalog.action_title(action)
		if action == GameEnums.RoundAction.APPOINTMENT and pin != null:
			label = "Appointment — %s" % pin.appointment_id
		var btn := _btn(label, _on_pick.bind(action))
		_actions.add_child(btn)


func _refresh_resolve() -> void:
	if AtelierSession.last_resolve.is_empty() and not AtelierSession.resolve_open:
		if AtelierSession.chapter_over or AtelierSession.run_over:
			_resolve_title.text = "Run over" if AtelierSession.run_over else "Chapter closed"
			_resolve_body.text = AtelierSession.last_note
		else:
			_resolve_title.text = "Waiting for a pick."
			_resolve_body.text = (
				"Walk the authored graph. Confirm a live fork when that day is current. "
				+ "Draft future is ghost only — not route_path. "
				+ "Order path: appointment / adventurer → stamina craft. "
				+ "Event path: market (wire shop) / event / reserved stay phase=schedule. "
				+ "After the day budget: shared-pool boss-client sew, then that adventurer fights."
			)
		return
	var payload: Dictionary = AtelierSession.last_resolve
	var klass := String(payload.get("resolve_class", ""))
	_resolve_title.text = "%s  ·  %s" % [String(payload.get("title", "")), klass]
	_resolve_body.text = String(payload.get("body", ""))


func _on_resolve(_payload: Dictionary) -> void:
	_redraw()


func _on_graph_pick(node_id: String) -> void:
	if AtelierSession.can_confirm_node(node_id):
		AtelierSession.confirm_node(node_id)
		return
	AtelierSession.draft_node(node_id)


func _on_confirm(node_id: String) -> void:
	AtelierSession.confirm_node(node_id)


func _on_pick(action: GameEnums.RoundAction) -> void:
	AtelierSession.pick_action(action)


func _on_take() -> void:
	AtelierSession.take_day()


func _on_decline() -> void:
	AtelierSession.decline_appointment()


func _on_continue() -> void:
	AtelierSession.acknowledge_resolve()


func _on_dex() -> void:
	if AtelierSession.craft_open or AtelierSession.market_open or AtelierSession.event_open:
		return
	_dex_open = true
	if _dex_screen != null:
		_dex_screen.open_screen()
	_redraw()


func _on_dex_closed() -> void:
	_dex_open = false
	_redraw()


func _on_reroll() -> void:
	var chapter_id := 1
	if AtelierSession.board != null:
		chapter_id = AtelierSession.board.chapter_id
	AtelierSession.start_chapter(chapter_id)


func _on_next_chapter() -> void:
	AtelierSession.cycle_demo_chapter()
