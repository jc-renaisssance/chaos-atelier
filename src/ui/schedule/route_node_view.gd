class_name RouteNodeView
extends PanelContainer
## Ugly M1 graph node: type + id only (docs/22). Art Later.

signal picked(node_id: String)

var _style: StyleBoxFlat
var _id_lab: Label
var _kind_lab: Label
var _ref_lab: Label
var _node_id: String = ""


func _ready() -> void:
	custom_minimum_size = Vector2(108, 72)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style = StyleBoxFlat.new()
	_style.set_corner_radius_all(6)
	_style.set_border_width_all(2)
	_style.content_margin_left = 6
	_style.content_margin_right = 6
	_style.content_margin_top = 6
	_style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", _style)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	_id_lab = Label.new()
	_id_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_id_lab.add_theme_font_size_override("font_size", 16)
	box.add_child(_id_lab)
	_kind_lab = Label.new()
	_kind_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_kind_lab.add_theme_font_size_override("font_size", 12)
	box.add_child(_kind_lab)
	_ref_lab = Label.new()
	_ref_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ref_lab.add_theme_font_size_override("font_size", 10)
	_ref_lab.autowrap_mode = TextServer.AUTOWRAP_OFF
	box.add_child(_ref_lab)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT and not _node_id.is_empty():
			picked.emit(_node_id)


func bind(
	node: RouteNode,
	is_current: bool,
	is_past: bool,
	is_draft: bool,
	is_cut: bool,
	is_fork: bool,
	is_bound: bool
) -> void:
	if node == null:
		return
	_node_id = node.node_id
	var ink := Color(0.91, 0.835, 0.69)
	var muted := Color(0.71, 0.643, 0.541)
	_id_lab.text = node.node_id
	_kind_lab.text = node.display_kind()
	_ref_lab.text = node.ref_id
	_ref_lab.visible = not node.ref_id.is_empty()
	if is_current:
		_style.bg_color = Color(0.227, 0.173, 0.094)
		_style.border_color = Color(0.788, 0.635, 0.153)
		_style.set_border_width_all(3)
	elif is_past:
		_style.bg_color = Color(0.141, 0.11, 0.086)
		_style.border_color = Color(0.416, 0.345, 0.251)
		_style.set_border_width_all(2)
		ink = muted
	elif is_cut:
		_style.bg_color = Color(0.09, 0.078, 0.07)
		_style.border_color = Color(0.2, 0.173, 0.153)
		_style.set_border_width_all(1)
		ink = Color(0.42, 0.38, 0.33)
	elif is_fork:
		_style.bg_color = Color(0.184, 0.149, 0.086)
		_style.border_color = Color(0.831, 0.694, 0.227)
		_style.set_border_width_all(3)
	elif is_draft:
		_style.bg_color = Color(0.149, 0.133, 0.094)
		_style.border_color = Color(0.545, 0.478, 0.29)
		_style.set_border_width_all(2)
		_style.border_color.a = 0.7
	elif is_bound:
		_style.bg_color = Color(0.165, 0.11, 0.125)
		_style.border_color = Color(0.545, 0.29, 0.416)
		_style.set_border_width_all(2)
	elif node.is_reserved():
		_style.bg_color = Color(0.11, 0.094, 0.086)
		_style.border_color = Color(0.29, 0.247, 0.22)
		_style.set_border_width_all(2)
		ink = muted
	else:
		_style.bg_color = Color(0.133, 0.11, 0.094)
		_style.border_color = Color(0.239, 0.204, 0.173)
		_style.set_border_width_all(2)
	_id_lab.add_theme_color_override("font_color", ink)
	_kind_lab.add_theme_color_override("font_color", ink)
	_ref_lab.add_theme_color_override("font_color", muted)
