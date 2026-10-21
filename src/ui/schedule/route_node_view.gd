class_name RouteNodeView
extends PanelContainer
## Ugly M1 graph node (docs/22). Three text lines stay.
## Kind chip: res://assets/route/kind_<display_kind()>.png at 48×48 when preloaded.
## Missing texture keeps the #41 text card. One texture, modulated by bind() flags.
## Elite telegraph (docs/22, Marker A / Scope A): a second overlay, not a kind chip.
## assets/route/elite_mark.png at 20×20, top-right inset 2. Missing png → no badge.

signal picked(node_id: String)

const KIND_PX := 48
const ELITE_CARD_PX := 20
const ELITE_ROW_PX := 16
const ELITE_INSET := 2
## Not a KIND_ICONS entry. Fail-soft: a missing file must not take down the card.
const ELITE_MARK_PATH := "res://assets/route/elite_mark.png"
## Stamped route chips (art #58, size B). Wire shop → display_kind() market. No kind_shop.png.
const KIND_ICONS := {
	"market": preload("res://assets/route/kind_market.png"),
	"adventurer": preload("res://assets/route/kind_adventurer.png"),
	"appointment": preload("res://assets/route/kind_appointment.png"),
	"event": preload("res://assets/route/kind_event.png"),
	"reserved": preload("res://assets/route/kind_reserved.png"),
}
## Market chrome A selected tint. Hot route flags reuse it; no second painted frame.
const CHIP_HOT := Color(1.08, 1.04, 0.82)

var _style: StyleBoxFlat
var _shell: Control
var _kind_icon: TextureRect
var _elite_badge: TextureRect
var _id_lab: Label
var _kind_lab: Label
var _ref_lab: Label
var _node_id: String = ""


func _ready() -> void:
	custom_minimum_size = Vector2(108, 72)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_contents = false
	_style = StyleBoxFlat.new()
	_style.set_corner_radius_all(6)
	_style.set_border_width_all(2)
	_style.content_margin_left = 6
	_style.content_margin_right = 6
	_style.content_margin_top = 6
	_style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", _style)
	mouse_filter = Control.MOUSE_FILTER_STOP
	## PanelContainer lays out every direct child into the content box.
	## The badge sits on this shell (not the kind HBox) so it can overlay the corner.
	_shell = Control.new()
	_shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shell.clip_contents = false
	_shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_shell)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shell.add_child(row)
	_kind_icon = _kind_socket()
	row.add_child(_kind_icon)
	## Ellipsis labels report a 1px min width, so the 48 chip stays inside 108×72.
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(box)
	_id_lab = _line(16)
	box.add_child(_id_lab)
	_kind_lab = _line(12)
	box.add_child(_kind_lab)
	_ref_lab = _line(10)
	box.add_child(_ref_lab)
	_elite_badge = _elite_socket()
	_shell.add_child(_elite_badge)
	_anchor_elite_badge()
	if not _style.changed.is_connected(_anchor_elite_badge):
		_style.changed.connect(_anchor_elite_badge)


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
	_bind_kind_icon(node, is_current, is_past, is_draft, is_cut, is_fork, is_bound)
	_bind_elite_badge(node, is_current, is_past, is_draft, is_cut, is_fork, is_bound)


func _kind_socket() -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(KIND_PX, KIND_PX)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.visible = false
	return icon


func _bind_kind_icon(
	node: RouteNode,
	is_current: bool,
	is_past: bool,
	is_draft: bool,
	is_cut: bool,
	is_fork: bool,
	is_bound: bool
) -> void:
	## display_kind() is the file id (shop → market). Unknown kind → text only.
	var found: Variant = KIND_ICONS.get(node.display_kind())
	var tex: Texture2D = found as Texture2D
	_kind_icon.texture = tex
	_kind_icon.visible = tex != null
	if tex == null:
		return
	_kind_icon.modulate = _kind_modulate(
		is_current, is_past, is_draft, is_cut, is_fork, is_bound, node.is_reserved()
	)


## Scope A: every kind=appointment wears the badge. Later appointments inherit.
## Node id N5 is not the predicate. R7 / R8 are reserved, so they stay bare.
static func wears_elite_badge(node: RouteNode) -> bool:
	return node != null and node.kind == "appointment"


## One texture for the card and the options row. Missing png → null, no badge.
static func elite_mark_texture() -> Texture2D:
	if not ResourceLoader.exists(ELITE_MARK_PATH):
		return null
	var loaded: Variant = load(ELITE_MARK_PATH)
	return loaded as Texture2D


func _elite_socket() -> TextureRect:
	var icon := TextureRect.new()
	icon.name = "EliteMark"
	icon.custom_minimum_size = Vector2(ELITE_CARD_PX, ELITE_CARD_PX)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.visible = false
	icon.z_index = 1
	return icon


func _anchor_elite_badge() -> void:
	if _elite_badge == null:
		return
	## Content margin replaces the border in StyleBox.get_margin when it is set,
	## so the shell sits 6px in and the 20×20 mark lands on the card inset.
	var top := 6.0
	var right := 6.0
	var style := get_theme_stylebox("panel")
	if style != null:
		top = style.get_margin(SIDE_TOP)
		right = style.get_margin(SIDE_RIGHT)
	var top_off := float(ELITE_INSET) - top
	var right_off := right - float(ELITE_INSET)
	_elite_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_elite_badge.offset_left = right_off - float(ELITE_CARD_PX)
	_elite_badge.offset_top = top_off
	_elite_badge.offset_right = right_off
	_elite_badge.offset_bottom = top_off + float(ELITE_CARD_PX)


func _bind_elite_badge(
	node: RouteNode,
	is_current: bool,
	is_past: bool,
	is_draft: bool,
	is_cut: bool,
	is_fork: bool,
	is_bound: bool
) -> void:
	var tex: Texture2D = null
	if wears_elite_badge(node):
		tex = elite_mark_texture()
	if _elite_badge == null:
		return
	_elite_badge.texture = tex
	_elite_badge.visible = tex != null
	if tex == null:
		return
	_elite_badge.modulate = _kind_modulate(
		is_current, is_past, is_draft, is_cut, is_fork, is_bound, node.is_reserved()
	)


func _kind_modulate(
	is_current: bool,
	is_past: bool,
	is_draft: bool,
	is_cut: bool,
	is_fork: bool,
	is_bound: bool,
	reserved: bool
) -> Color:
	## Same flag order as the StyleBox above. One chip, no per-flag texture.
	if is_current:
		return CHIP_HOT
	if is_past:
		return Color(0.62, 0.58, 0.52)
	if is_cut:
		return Color(0.4, 0.36, 0.32)
	if is_fork:
		return CHIP_HOT
	if is_draft:
		return Color(0.8, 0.76, 0.64)
	if is_bound:
		return Color(0.95, 0.78, 0.86)
	if reserved:
		return Color(0.62, 0.58, 0.52)
	return Color.WHITE


func _line(size: int) -> Label:
	var lab := Label.new()
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", size)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lab.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lab.clip_text = true
	return lab
