extends Control
## Travelling-atelier schedule board (docs/22). Order actions overlay stamina craft (docs/27).

const INK := Color.html("#e8d5b0")
const MUTED := Color.html("#b5a48a")
const GOLD := Color.html("#c9a227")
const WOOD := Color.html("#1a1410")
const PANEL := Color.html("#2a2118")

var _title: Label
var _meta: Label
var _note: Label
var _timeline: HBoxContainer
var _slots: Array[RoundSlotView] = []
var _today_title: Label
var _actions: HFlowContainer
var _resolve_title: Label
var _resolve_body: Label
var _stamp: Label
var _continue_btn: Button
var _decline_btn: Button
var _craft_table: CraftTable


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

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	_title = _label("CHAOS ATELIER  ·  travelling wagon", 26, GOLD)
	root.add_child(_title)
	_meta = _label("", 15, INK)
	_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_meta)
	_note = _label("", 14, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_note)

	root.add_child(_caption("SCHEDULE  ·  %d rounds  ·  not a path map" % GameConstants.CHAPTER_ROUND_COUNT))
	var timeline_panel := _panel()
	timeline_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(timeline_panel)
	_timeline = HBoxContainer.new()
	_timeline.add_theme_constant_override("separation", 8)
	timeline_panel.add_child(_timeline)
	_slots.clear()
	for i in range(GameConstants.CHAPTER_ROUND_COUNT):
		var cell := RoundSlotView.new()
		_timeline.add_child(cell)
		_slots.append(cell)

	root.add_child(_caption("TODAY  ·  one primary action"))
	var today := _panel()
	root.add_child(today)
	var today_box := VBoxContainer.new()
	today_box.add_theme_constant_override("separation", 8)
	today.add_child(today_box)
	_today_title = _label("Pick one action.", 16, INK)
	today_box.add_child(_today_title)
	_actions = HFlowContainer.new()
	_actions.add_theme_constant_override("h_separation", 8)
	_actions.add_theme_constant_override("v_separation", 8)
	today_box.add_child(_actions)
	var today_row := HBoxContainer.new()
	today_row.add_theme_constant_override("separation", 8)
	today_box.add_child(today_row)
	_decline_btn = _btn("Decline appointment (−reps)", _on_decline)
	today_row.add_child(_decline_btn)
	_continue_btn = _btn("Continue", _on_continue)
	today_row.add_child(_continue_btn)

	root.add_child(_caption("RESOLVE  ·  order vs event  ·  no lineup cards"))
	var resolve := _panel()
	root.add_child(resolve)
	var resolve_box := VBoxContainer.new()
	resolve_box.add_theme_constant_override("separation", 6)
	resolve.add_child(resolve_box)
	_resolve_title = _label("Waiting for a pick.", 16, GOLD)
	resolve_box.add_child(_resolve_title)
	_resolve_body = _label(
		"Appointment / walk-in / prep craft → stamina craft (order-fixed construction). "
		+ "Wagon event / shop / rest → event path (stays on the board).",
		14,
		INK
	)
	_resolve_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resolve_box.add_child(_resolve_body)

	root.add_child(_caption("STAMP  ·  docs/20 schedule + stamina  ·  crafts_done counts pieces"))
	var stamp_panel := _panel()
	stamp_panel.custom_minimum_size.y = 96
	root.add_child(stamp_panel)
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
	root.add_child(demo)
	demo.add_child(_btn("Reroll this chapter", _on_reroll))
	demo.add_child(_btn("Demo next chapter", _on_next_chapter))
	var hint := _label("Schedule + stamina craft. Shop / boss / newspaper stay later slices.", 12, MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	demo.add_child(hint)

	_craft_table = CraftTable.new()
	_craft_table.visible = false
	add_child(_craft_table)


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
	sb.border_color = Color.html("#3d342c")
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
	if _craft_table != null:
		_craft_table.visible = AtelierSession.craft_open
		if AtelierSession.craft_open:
			_craft_table.refresh()
	var board: ChapterSchedule = AtelierSession.board
	if board == null:
		return
	var boss := ScheduleCatalog.boss_title(board.chapter_boss_id)
	_title.text = "CHAOS ATELIER  ·  travelling wagon  ·  %s" % board.player_owner_id
	_meta.text = (
		"Chapter %d / %d   ·   boss %s (%s)   ·   round %s / %d   ·   %d left   ·   pieces %d / %d   ·   decline %s   ·   seed %d"
		% [
			board.chapter_id,
			GameConstants.CHAPTERS_PER_RUN,
			boss,
			board.boss_pool_id,
			"—" if board.round_index == GameConstants.NULL_INT else str(board.round_index),
			GameConstants.CHAPTER_ROUND_COUNT,
			board.rounds_left,
			board.crafts_done,
			board.crafts_max,
			"used" if board.appt_decline_used else "open (once / chapter)",
			AtelierSession.chapter_seed,
		]
	)
	_note.text = AtelierSession.last_note
	if _slots.size() != board.rounds.size():
		return
	for i in range(board.rounds.size()):
		var slot: ScheduleRound = board.rounds[i]
		var pin := board.pin_at(slot.round_index)
		_slots[i].bind(slot, pin, slot.round_index == board.round_index, ScheduleCatalog.appointment_title(pin))
	_rebuild_actions()
	_refresh_resolve()
	_stamp.text = JSON.stringify(AtelierSession.stamp_preview(), "  ")


func _rebuild_actions() -> void:
	for child in _actions.get_children():
		child.queue_free()
	var board: ChapterSchedule = AtelierSession.board
	var legal: Array[GameEnums.RoundAction] = AtelierSession.legal_actions()
	_decline_btn.visible = AtelierSession.can_decline()
	_decline_btn.disabled = not AtelierSession.can_decline()
	_continue_btn.visible = AtelierSession.resolve_open or (board != null and board.is_schedule_complete())
	_continue_btn.disabled = not AtelierSession.resolve_open
	if board != null and board.is_schedule_complete() and not AtelierSession.resolve_open:
		_today_title.text = "Chapter schedule finished. Final prep / boss is not this slice."
		_continue_btn.text = "Schedule complete"
		return
	if AtelierSession.resolve_open:
		_today_title.text = "Action locked. Continue to the next round."
		_continue_btn.text = "Continue"
		return
	var pin := board.current_pin() if board != null else null
	if pin != null and not AtelierSession.declined_this_round:
		_today_title.text = (
			"Pinned appointment: %s. Take it, or decline once this chapter (−reps) and pick another action."
			% ScheduleCatalog.appointment_title(pin)
		)
	elif GameConstants.is_reserved_final_round(board.round_index):
		_today_title.text = "Reserved final round — travel / final prep / boss approach. Appointments cannot claim 7–8."
	else:
		_today_title.text = "Pick one primary action for this round."
	for action in legal:
		var label := ScheduleCatalog.action_title(action)
		if action == GameEnums.RoundAction.APPOINTMENT and pin != null:
			label = "Appointment — %s" % ScheduleCatalog.appointment_title(pin)
		var btn := _btn(label, _on_pick.bind(action))
		_actions.add_child(btn)


func _refresh_resolve() -> void:
	if AtelierSession.last_resolve.is_empty() and not AtelierSession.resolve_open:
		if AtelierSession.board != null and AtelierSession.board.is_schedule_complete():
			_resolve_title.text = "Board complete"
			_resolve_body.text = "Eight rounds resolved. No lineup. Boss / mission report / win-con stay later."
		else:
			_resolve_title.text = "Waiting for a pick."
			_resolve_body.text = (
				"Order path: appointment, walk-in, prep craft → stamina craft (docs/27). "
				+ "Event path: wagon event, wagon shop, rest / dig → resolve here, stay phase=schedule."
			)
		return
	var payload: Dictionary = AtelierSession.last_resolve
	var klass := String(payload.get("resolve_class", ""))
	_resolve_title.text = "%s  ·  %s" % [String(payload.get("title", "")), klass]
	_resolve_body.text = String(payload.get("body", ""))


func _on_resolve(_payload: Dictionary) -> void:
	_redraw()


func _on_pick(action: GameEnums.RoundAction) -> void:
	AtelierSession.pick_action(action)


func _on_decline() -> void:
	AtelierSession.decline_appointment()


func _on_continue() -> void:
	AtelierSession.acknowledge_resolve()


func _on_reroll() -> void:
	var chapter_id := 1
	if AtelierSession.board != null:
		chapter_id = AtelierSession.board.chapter_id
	AtelierSession.start_chapter(chapter_id)


func _on_next_chapter() -> void:
	AtelierSession.cycle_demo_chapter()
