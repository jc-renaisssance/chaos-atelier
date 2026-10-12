class_name DaySlotView
extends PanelContainer
## One Day-planner cell. Label D1..DN from map day_count. Not a path-map node.

signal focused(day_index: int)

var _index: Label
var _badge: Label
var _body: Label
var _style: StyleBoxFlat
var _day_index: int = 0


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(112, 168)
	_style = StyleBoxFlat.new()
	_style.set_corner_radius_all(8)
	_style.set_border_width_all(2)
	_style.content_margin_left = 8
	_style.content_margin_right = 8
	_style.content_margin_top = 8
	_style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", _style)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	_index = Label.new()
	_index.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_index.add_theme_font_size_override("font_size", 22)
	box.add_child(_index)
	_badge = Label.new()
	_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge.add_theme_font_size_override("font_size", 12)
	box.add_child(_badge)
	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("font_size", 13)
	box.add_child(_body)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT and _day_index > 0:
			focused.emit(_day_index)


func bind(
	slot: ScheduleDay,
	pin: AppointmentPin,
	assigned: PlannerEvent,
	is_current: bool,
	is_focused: bool,
	day_count: int
) -> void:
	if slot == null:
		return
	_day_index = slot.day_index
	var reserved := slot.is_reserved_final(day_count)
	var done := slot.is_played()
	_index.text = "D%d" % slot.day_index
	var ink := Color(0.91, 0.835, 0.69)
	var muted := Color(0.71, 0.643, 0.541)
	if is_focused:
		_style.border_width_bottom = 4
	else:
		_style.border_width_bottom = 2
	if is_current:
		_style.bg_color = Color(0.227, 0.173, 0.094)
		_style.border_color = Color(0.788, 0.635, 0.153)
		_badge.text = "TODAY"
		_badge.add_theme_color_override("font_color", Color(0.788, 0.635, 0.153))
	elif done:
		_style.bg_color = Color(0.141, 0.11, 0.086)
		_style.border_color = Color(0.416, 0.345, 0.251)
		_badge.text = "DONE"
		_badge.add_theme_color_override("font_color", muted)
	elif reserved:
		_style.bg_color = Color(0.11, 0.094, 0.086)
		_style.border_color = Color(0.29, 0.247, 0.22)
		_badge.text = "RESERVED"
		_badge.add_theme_color_override("font_color", muted)
	elif assigned != null and assigned.fixed:
		_style.bg_color = Color(0.165, 0.102, 0.094)
		_style.border_color = Color(0.545, 0.227, 0.227)
		_badge.text = "FIXED"
		_badge.add_theme_color_override("font_color", Color(0.831, 0.478, 0.416))
	elif assigned != null:
		_style.bg_color = Color(0.165, 0.129, 0.094)
		_style.border_color = Color(0.416, 0.345, 0.251)
		_badge.text = "ASSIGNED"
		_badge.add_theme_color_override("font_color", Color(0.788, 0.635, 0.153))
	else:
		_style.bg_color = Color(0.133, 0.11, 0.094)
		_style.border_color = Color(0.239, 0.204, 0.173)
		_badge.text = "OPEN"
		_badge.add_theme_color_override("font_color", muted)
	_index.add_theme_color_override("font_color", ink)
	_body.add_theme_color_override("font_color", ink)
	var lines: PackedStringArray = PackedStringArray()
	if reserved:
		if slot.day_index == day_count:
			lines.append("boss approach")
		else:
			lines.append("travel / final prep")
	if assigned != null:
		lines.append(assigned.panel_line())
	elif pin != null:
		lines.append(pin.appointment_id)
		lines.append("D%d" % pin.pinned_day)
	if done:
		var action_label: Variant = GameEnums.day_action_wire(slot.day_action)
		lines.append(str(action_label) if action_label != null else "")
		if not slot.order_id.is_empty():
			lines.append(slot.order_id)
	elif assigned == null and not reserved:
		lines.append("no assignment")
	_body.text = "\n".join(lines)
