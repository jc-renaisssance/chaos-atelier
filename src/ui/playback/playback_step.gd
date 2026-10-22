class_name PlaybackStep
extends Control
## Gate A step between craft Finish and the report the client already shows.
## Ugly beat rows + placeholder actor. Skip ends this playback only.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const PLATE := Color(0.24, 0.2, 0.16)
const BORDER := Color(0.239, 0.204, 0.173)
## Beat length is a client constant. Not a stamp field.
const BEAT_SEC := 0.7

var _title: Label
var _note: Label
var _rows_box: VBoxContainer
var _report_title: Label
var _report_body: Label
var _actor_plate: ColorRect
var _actor_tex: TextureRect
var _actor_name: Label
var _actor_caption: Label
var _skip_btn: Button
var _continue_btn: Button
var _stamp: Label
var _built := false
var _report_mode := false
var _serial := -1
var _piece := -1
var _beat := 0
var _elapsed := 0.0
var _rows: Array = []
var _actor_id: Variant = null
var _row_labels: Array[Label] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	set_process(true)
	visible = false


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = WOOD
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	_title = _label("PLAYBACK", 22, GOLD)
	root.add_child(_title)
	_note = _label("", 13, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_note)

	var stage := HBoxContainer.new()
	stage.add_theme_constant_override("separation", 12)
	stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(stage)

	var actor := _panel()
	actor.custom_minimum_size = Vector2(PostureSocket.DISPLAY_PX + 24, 0)
	stage.add_child(actor)
	var actor_box := VBoxContainer.new()
	actor_box.add_theme_constant_override("separation", 6)
	actor.add_child(actor_box)
	actor_box.add_child(_label("ACTOR", 11, GOLD))
	var socket := Control.new()
	socket.custom_minimum_size = Vector2(PostureSocket.DISPLAY_PX, PostureSocket.DISPLAY_PX)
	actor_box.add_child(socket)
	_actor_plate = ColorRect.new()
	_actor_plate.color = PLATE
	_actor_plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_actor_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	socket.add_child(_actor_plate)
	_actor_tex = TextureRect.new()
	_actor_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_actor_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_actor_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_actor_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_actor_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_actor_tex.visible = false
	socket.add_child(_actor_tex)
	_actor_name = _label("—", 16, INK)
	_actor_name.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_actor_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_actor_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_actor_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	socket.add_child(_actor_name)
	_actor_caption = _label("", 12, MUTED)
	_actor_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	actor_box.add_child(_actor_caption)

	var rows_panel := _panel()
	rows_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.add_child(rows_panel)
	var rows_scroll := ScrollContainer.new()
	rows_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rows_panel.add_child(rows_scroll)
	var rows_wrap := VBoxContainer.new()
	rows_wrap.add_theme_constant_override("separation", 6)
	rows_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_scroll.add_child(rows_wrap)
	rows_wrap.add_child(_label("BEATS  ·  open / favor / punish / skill / result", 11, GOLD))
	_rows_box = VBoxContainer.new()
	_rows_box.add_theme_constant_override("separation", 4)
	_rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_wrap.add_child(_rows_box)
	_report_title = _label("", 16, GOLD)
	_report_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_report_title.visible = false
	rows_wrap.add_child(_report_title)
	_report_body = _label("", 14, INK)
	_report_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_report_body.visible = false
	rows_wrap.add_child(_report_body)

	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	root.add_child(btns)
	_skip_btn = _btn("Skip", _on_skip)
	btns.add_child(_skip_btn)
	_continue_btn = _btn("Continue", _on_continue)
	btns.add_child(_continue_btn)

	var stamp_panel := _panel()
	stamp_panel.custom_minimum_size.y = 72
	root.add_child(stamp_panel)
	var stamp_scroll := ScrollContainer.new()
	stamp_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stamp_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stamp_scroll.custom_minimum_size.y = 64
	stamp_panel.add_child(stamp_scroll)
	_stamp = _label("{}", 11, MUTED)
	_stamp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stamp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stamp_scroll.add_child(_stamp)


func dismiss() -> void:
	_built = false
	_serial = -1
	_piece = -1
	_beat = 0
	_elapsed = 0.0
	_rows = []


func refresh() -> void:
	var snap: Dictionary = AtelierSession.playback_snapshot()
	var report := bool(snap.get("report", false))
	var piece := int(snap.get("piece_index", -1))
	var serial := int(snap.get("serial", -1))
	if _built and _serial == serial and _report_mode == report and _piece == piece:
		_stamp.text = JSON.stringify(AtelierSession.stamp_preview(), "  ")
		return
	_built = true
	_report_mode = report
	_serial = serial
	_piece = piece
	_beat = 0
	_elapsed = 0.0
	_actor_id = snap.get("actor_id", null)
	_rows = []
	var raw_rows: Variant = snap.get("beats", [])
	if raw_rows is Array:
		_rows.assign(raw_rows)
	_title.text = "PLAYBACK  ·  piece %d / %d  ·  docs/30" % [piece, int(snap.get("piece_count", 0))]
	if report:
		_note.text = String(snap.get("note", ""))
		_report_title.text = String(snap.get("title", ""))
		_report_body.text = String(snap.get("body", ""))
	else:
		_note.text = "Skip ends this playback only. The report still opens. Later pieces still play."
	_report_title.visible = report
	_report_body.visible = report
	_rows_box.visible = not report
	_skip_btn.visible = not report
	_continue_btn.visible = report
	_rebuild_rows()
	_apply_beat()
	_stamp.text = JSON.stringify(AtelierSession.stamp_preview(), "  ")


func _process(delta: float) -> void:
	if not visible or _report_mode or not AtelierSession.playback_open:
		return
	if _rows.is_empty():
		AtelierSession.finish_playback(false)
		return
	_elapsed += delta
	if _elapsed < BEAT_SEC:
		return
	_elapsed = 0.0
	if _beat >= _rows.size() - 1:
		AtelierSession.finish_playback(false)
		return
	_beat += 1
	_apply_beat()


func _rebuild_rows() -> void:
	for child in _rows_box.get_children():
		child.queue_free()
	_row_labels.clear()
	for row in _rows:
		if not (row is Dictionary):
			continue
		var lab := _label("", 14, INK)
		lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_rows_box.add_child(lab)
		_row_labels.append(lab)


func _apply_beat() -> void:
	var slot := ""
	for i in range(_row_labels.size()):
		var lab: Label = _row_labels[i]
		var row: Dictionary = {}
		if i < _rows.size() and _rows[i] is Dictionary:
			row = _rows[i]
		var mark := "  "
		var color := MUTED
		if not _report_mode and i == _beat:
			mark = "▸ "
			color = INK
		if _report_mode:
			mark = "  "
			color = MUTED
		lab.text = "p%s  %s%s  ·  %s  ·  %s" % [
			str(row.get("piece_index", _piece)),
			mark,
			String(row.get("id", "")),
			String(row.get("slot", "")),
			String(row.get("label", "")),
		]
		lab.add_theme_color_override("font_color", color)
		if i == _beat:
			slot = String(row.get("slot", ""))
	if _report_mode and not _rows.is_empty():
		var last: Variant = _rows[_rows.size() - 1]
		if last is Dictionary:
			slot = String(last.get("slot", slot))
	_bind_actor(slot)


func _bind_actor(slot: String) -> void:
	var still: Dictionary = PostureSocket.playback_still(_actor_id, slot)
	var placeholder := bool(still.get("placeholder", true))
	var fallback := bool(still.get("fallback_1x1", false))
	var tex: Texture2D = still.get("texture") as Texture2D
	var slot_name := String(still.get("slot", slot))
	_actor_tex.texture = tex
	_actor_tex.visible = tex != null
	_actor_name.visible = placeholder or fallback or tex == null
	_actor_name.text = slot_name
	var who := "—"
	if _actor_id is String and not String(_actor_id).is_empty():
		who = String(_actor_id)
	_actor_caption.text = "%s  ·  %s  ·  64×64 ×2" % [slot_name, who]


func _on_skip() -> void:
	if not AtelierSession.playback_open:
		return
	var before_last := true
	if not _rows.is_empty() and _beat >= _rows.size() - 1:
		before_last = false
	AtelierSession.finish_playback(before_last)


func _on_continue() -> void:
	AtelierSession.continue_piece_report()


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
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)
	return panel


func _btn(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.pressed.connect(cb)
	return btn
