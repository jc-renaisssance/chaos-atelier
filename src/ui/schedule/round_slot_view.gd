class_name RoundSlotView
extends PanelContainer
## One of 8 timeline cells. Not a path-map node.

var _index: Label
var _badge: Label
var _body: Label
var _style: StyleBoxFlat


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
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
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


func bind(
	slot: ScheduleRound,
	pin: AppointmentPin,
	is_current: bool,
	pin_title: String
) -> void:
	if slot == null:
		return
	var reserved := slot.is_reserved_final()
	var done := slot.round_action != GameEnums.RoundAction.NONE
	_index.text = "R%d" % slot.round_index
	var ink := Color.html("#e8d5b0")
	var muted := Color.html("#b5a48a")
	if is_current:
		_style.bg_color = Color.html("#3a2c18")
		_style.border_color = Color.html("#c9a227")
		_badge.text = "TODAY"
		_badge.add_theme_color_override("font_color", Color.html("#c9a227"))
	elif done:
		_style.bg_color = Color.html("#241c16")
		_style.border_color = Color.html("#6a5840")
		_badge.text = "DONE"
		_badge.add_theme_color_override("font_color", muted)
	elif reserved:
		_style.bg_color = Color.html("#1c1816")
		_style.border_color = Color.html("#4a3f38")
		_badge.text = "RESERVED"
		_badge.add_theme_color_override("font_color", muted)
	elif pin != null:
		_style.bg_color = Color.html("#2a1a18")
		_style.border_color = Color.html("#8b3a3a")
		_badge.text = "PINNED"
		_badge.add_theme_color_override("font_color", Color.html("#d47a6a"))
	else:
		_style.bg_color = Color.html("#221c18")
		_style.border_color = Color.html("#3d342c")
		_badge.text = "OPEN"
		_badge.add_theme_color_override("font_color", muted)
	_index.add_theme_color_override("font_color", ink)
	_body.add_theme_color_override("font_color", ink)
	var lines: PackedStringArray = PackedStringArray()
	if reserved:
		if slot.round_index == GameConstants.CHAPTER_ROUND_COUNT:
			lines.append("boss approach")
		else:
			lines.append("travel / final prep")
	if pin != null:
		lines.append(pin_title if not pin_title.is_empty() else pin.appointment_id)
		lines.append("round %d" % pin.pinned_round)
	if done:
		lines.append(ScheduleCatalog.action_title(slot.round_action))
		if not slot.order_id.is_empty():
			lines.append(slot.order_id)
	elif pin == null and not reserved:
		lines.append("no pin")
	_body.text = "\n".join(lines)
