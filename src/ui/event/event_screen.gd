class_name EventScreen
extends Control
## Ugly M1 text-event resolve (docs/32). One pick, one result line, no craft.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)

var _title: Label
var _event_id: Label
var _blurb: Label
var _choices: VBoxContainer
var _result: Label
var _continue_btn: Button
var _rebuild_queued: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	refresh()


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
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	_title = _label("event · —", 22, GOLD)
	root.add_child(_title)
	_event_id = _label("evt_*", 16, INK)
	root.add_child(_event_id)
	_blurb = _label("", 15, MUTED)
	_blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_blurb)

	var panel := _panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(panel)
	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 8)
	_choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(_choices)

	_result = _label("result: —", 15, GOLD)
	_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_result)

	_continue_btn = _btn("Continue", _on_continue)
	_continue_btn.visible = false
	root.add_child(_continue_btn)


func refresh() -> void:
	if not is_inside_tree():
		return
	var node_id := ""
	if AtelierSession.board != null:
		node_id = AtelierSession.board.current_node_id
	_title.text = "event · %s" % (node_id if not node_id.is_empty() else "—")
	_event_id.text = AtelierSession.event_id if not AtelierSession.event_id.is_empty() else "evt_*"
	_blurb.text = EventCatalog.blurb(AtelierSession.event_id)
	if AtelierSession.event_resolved:
		_result.text = "result: %s" % AtelierSession.event_result_line
		_continue_btn.visible = true
	else:
		_result.text = "result: —"
		_continue_btn.visible = false
	if _rebuild_queued:
		return
	_rebuild_queued = true
	call_deferred("_rebuild_choices")


func _rebuild_choices() -> void:
	_rebuild_queued = false
	if _choices == null:
		return
	for child in _choices.get_children():
		child.queue_free()
	var resolved := AtelierSession.event_resolved
	for item in EventCatalog.choices(AtelierSession.event_id):
		if not (item is Dictionary):
			continue
		var ch: Dictionary = item
		var cid := String(ch.get("id", ""))
		var label := String(ch.get("label", cid))
		var btn := _btn("%s    %s" % [cid, label], _on_choice.bind(cid))
		btn.disabled = resolved or not AtelierSession.can_pick_event_choice(cid)
		_choices.add_child(btn)
	var purse := _label(
		"gold %d   ·   reps %d   ·   mats %d"
		% [
			AtelierSession.gold,
			AtelierSession.reps,
			AtelierSession.stock.material_count() if AtelierSession.stock != null else 0,
		],
		13,
		INK
	)
	_choices.add_child(purse)


func _on_choice(choice_id: String) -> void:
	AtelierSession.pick_event_choice(choice_id)


func _on_continue() -> void:
	AtelierSession.finish_event()


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
