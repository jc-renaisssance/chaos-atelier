extends Control
## Travelling-atelier Day planner (docs/22). Craft is a dedicated screen (docs/27).

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
var _timeline: HBoxContainer
var _slots: Array[DaySlotView] = []
var _focus_day: int = 1
var _options_title: Label
var _options: VBoxContainer
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

	_title = _label("CHAOS ATELIER  ·  travelling wagon", 26, GOLD)
	root.add_child(_title)
	_meta = _label("", 15, INK)
	_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_meta)
	_note = _label("", 14, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_note)

	_planner_caption = _caption("DAY PLANNER  ·  map day_count  ·  not a path map")
	root.add_child(_planner_caption)
	var timeline_panel := _panel()
	timeline_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(timeline_panel)
	_timeline = HBoxContainer.new()
	_timeline.add_theme_constant_override("separation", 8)
	_timeline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timeline_panel.add_child(_timeline)

	## 1280×720: day strip stays put; EVENT OPTIONS / TODAY / RESOLVE scroll.
	_body_scroll = ScrollContainer.new()
	_body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(_body_scroll)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.add_child(body)

	body.add_child(_caption("EVENT OPTIONS  ·  type + id  ·  expand the focused day"))
	var options_panel := _panel()
	options_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(options_panel)
	var options_box := VBoxContainer.new()
	options_box.add_theme_constant_override("separation", 6)
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_panel.add_child(options_box)
	_options_title = _label("Click a day to preview E*.", 15, INK)
	_options_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_options_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_box.add_child(_options_title)
	_options = VBoxContainer.new()
	_options.add_theme_constant_override("separation", 4)
	_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_box.add_child(_options)

	body.add_child(_caption("TODAY  ·  one primary action from the assigned E*"))
	var today := _panel()
	today.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(today)
	var today_box := VBoxContainer.new()
	today_box.add_theme_constant_override("separation", 8)
	today_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	today.add_child(today_box)
	_today_title = _label("Assign the chapter, then take today.", 16, INK)
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
	_take_btn = _btn("Take assigned", _on_take)
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
		"Appointment / adventurer / prep craft → stamina craft (order-fixed construction). "
		+ "Wagon event / shop / rest → event path (stays on the planner).",
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
	var hint := _label("Dex · shop / menu collection list. own_basic loop: newspaper → Day planner → craft → boss-client sew → fight. Shop events / portraits Later.", 12, MUTED)
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


func _ensure_slots(n: int) -> void:
	while _slots.size() < n:
		var cell := DaySlotView.new()
		cell.focused.connect(_on_focus_day)
		_timeline.add_child(cell)
		_slots.append(cell)
	while _slots.size() > n:
		var cell: Variant = _slots.pop_back()
		if cell is Node:
			(cell as Node).queue_free()


func _redraw() -> void:
	var in_craft := AtelierSession.craft_open
	if in_craft:
		_dex_open = false
	if _dex_screen != null:
		_dex_screen.visible = _dex_open and not in_craft
	if _schedule_root != null:
		_schedule_root.visible = not in_craft and not _dex_open
	if _craft_table != null:
		_craft_table.visible = in_craft
		if in_craft:
			_craft_table.refresh()
	if in_craft:
		return
	if _dex_open:
		if _dex_screen != null:
			_dex_screen.refresh()
		return
	var board: ChapterSchedule = AtelierSession.board
	if board == null:
		return
	var n := board.day_count
	_ensure_slots(n)
	if _focus_day < 1 or _focus_day > n:
		_focus_day = board.day_index if GameConstants.is_schedule_day(board.day_index, n) else 1
	var boss := ScheduleCatalog.boss_title(board.chapter_boss_id)
	_title.text = "CHAOS ATELIER  ·  travelling wagon  ·  %s" % board.player_owner_id
	_planner_caption.text = "DAY PLANNER  ·  %d days (map.day_count)  ·  last 2 reserved  ·  not a path map" % n
	_meta.text = (
		"Chapter %d / %d   ·   boss %s (%s)   ·   day %s / %d   ·   %d left   ·   pieces %d   ·   reps %d (gate stub %d)   ·   decline %s   ·   seed %d"
		% [
			board.chapter_id,
			GameConstants.CHAPTERS_PER_RUN,
			boss,
			board.boss_pool_id,
			"—" if AtelierSession.newspaper_open else str(board.day_index),
			n,
			board.days_left,
			board.crafts_done,
			AtelierSession.reps,
			GameConstants.REPS_GATE_STUB,
			"used" if board.appt_decline_used else "open (once / chapter)",
			AtelierSession.chapter_seed,
		]
	)
	_note.text = AtelierSession.last_note
	if _slots.size() != board.days.size():
		return
	for i in range(board.days.size()):
		var slot: ScheduleDay = board.days[i]
		var pin := board.pin_at(slot.day_index)
		var assigned := board.assigned_event(slot.day_index)
		_slots[i].bind(
			slot,
			pin,
			assigned,
			slot.day_index == board.day_index and not AtelierSession.newspaper_open,
			slot.day_index == _focus_day,
			n
		)
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
	var day_i := _focus_day
	var reserved := board.is_reserved_day(day_i)
	var played := board.is_day_played(day_i)
	var assigned := board.assigned_event(day_i)
	var opts := board.options_for_day(day_i)
	if reserved:
		_options_title.text = (
			"D%d reserved — travel / final prep or boss approach. Not player-assignable."
			% day_i
		)
		return
	var count_note := "%d option(s)" % opts.size()
	if day_i == 1:
		count_note += " · D1 first-customer"
	_options_title.text = "D%d  ·  %s  ·  M1 shows type + id" % [day_i, count_note]
	if opts.is_empty():
		_options.add_child(_label("No E* on this day.", 13, MUTED))
		return
	for event in opts:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var line := event.panel_line()
		if event.fixed:
			line += "  [fixed]"
		var lab := _label(line, 14, INK)
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lab)
		var state := ""
		var elsewhere := board.assignment_for_event(event.event_id)
		if assigned != null and assigned.event_id == event.event_id:
			state = "assigned here"
		elif elsewhere != null:
			state = "assigned D%d" % elsewhere.day_index
		if played:
			var frozen := _label("frozen", 12, MUTED)
			row.add_child(frozen)
		elif AtelierSession.can_assign_event(day_i, event.event_id):
			var btn := _btn("Assign", _on_assign.bind(day_i, event.event_id))
			row.add_child(btn)
		elif not state.is_empty():
			row.add_child(_label(state, 12, MUTED))
		else:
			row.add_child(_label("locked", 12, MUTED))
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
		_today_title.text = "Kingdom newspaper — boss announced. Dismiss into the Day planner."
		_continue_btn.text = "Open the Day planner"
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
	var pin: AppointmentPin = board.current_pin() if board != null else null
	var assigned: PlannerEvent = board.current_assigned_event() if board != null else null
	if pin != null and not AtelierSession.declined_this_day:
		_today_title.text = (
			"Pinned appointment: %s. Take it, or decline once this chapter (−reps) and pick another action."
			% pin.appointment_id
		)
		_take_btn.text = "Take appointment"
	elif board != null and board.is_reserved_day(board.day_index):
		if board.day_index == board.day_count:
			_today_title.text = "Reserved D%d — boss approach. Not player-assignable." % board.day_index
			_take_btn.text = "Resolve reserved day"
		else:
			_today_title.text = "Reserved D%d — travel / final prep. Not player-assignable." % board.day_index
			_take_btn.text = "Resolve reserved day"
	elif assigned != null:
		_today_title.text = "Assigned today: %s. Take it, or update unplayed assignable days." % assigned.panel_line()
		_take_btn.text = "Take assigned"
	else:
		_today_title.text = "Assign an E* to D%d (options panel), then take the day." % (board.day_index if board != null else 0)
		_take_btn.text = "Take assigned"
	for action in legal:
		if assigned != null and action == ScheduleRules.action_for_kind(assigned.kind) and not AtelierSession.declined_this_day:
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
				"Assign E* at chapter start (and update unplayed assignable days). "
				+ "Order path: appointment, adventurer, prep craft → stamina craft → mission result (docs/23, 24). "
				+ "Event path: wagon event, wagon shop, rest / dig → stay phase=schedule. "
				+ "After the day budget: shared-pool boss-client sew, then that adventurer fights. Mid-fail continues; boss fail = run_over."
			)
		return
	var payload: Dictionary = AtelierSession.last_resolve
	var klass := String(payload.get("resolve_class", ""))
	_resolve_title.text = "%s  ·  %s" % [String(payload.get("title", "")), klass]
	_resolve_body.text = String(payload.get("body", ""))


func _on_resolve(_payload: Dictionary) -> void:
	_redraw()


func _on_focus_day(day_index: int) -> void:
	_focus_day = day_index
	_redraw()


func _on_assign(day_index: int, event_id: String) -> void:
	AtelierSession.assign_event(day_index, event_id)


func _on_pick(action: GameEnums.RoundAction) -> void:
	AtelierSession.pick_action(action)


func _on_take() -> void:
	AtelierSession.take_day()


func _on_decline() -> void:
	AtelierSession.decline_appointment()


func _on_continue() -> void:
	AtelierSession.acknowledge_resolve()


func _on_dex() -> void:
	if AtelierSession.craft_open:
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
