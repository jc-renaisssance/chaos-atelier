class_name CraftHandSlot
extends PanelContainer
## Hand slot 1–5. Cards display here only (docs/27). Drag into a zone, or click / 1–5.

signal slot_played(hand_index: int)

const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const CHIP := Color(0.227, 0.173, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)

var hand_index: int = 0
var _locked: bool = true
var _press_pos: Vector2 = Vector2.ZERO
var _caption: Label
var _name: Label
var _meta: Label
var _blurb: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(148, 120)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_style()
	if _caption != null:
		return
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	_caption = _label("1", 11, GOLD)
	box.add_child(_caption)
	_name = _label("", 14, INK)
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_name)
	_meta = _label("", 12, MUTED)
	_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_meta)
	_blurb = _label("", 11, MUTED)
	_blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_blurb)
	gui_input.connect(_on_gui)


func bind(index: int, card: HandCard, cost: int, locked: bool, can_play: bool) -> void:
	hand_index = index
	_locked = locked or not can_play
	mouse_filter = Control.MOUSE_FILTER_IGNORE if _locked else Control.MOUSE_FILTER_STOP
	_caption.text = "SLOT %d" % (index + 1)
	_name.text = CraftCatalog.display_name(card.id, card.type)
	var tags := CraftCatalog.tags_of(card.id, card.type)
	var fate := "burns" if CraftRules.burns_on_play(card.type) else "to discard"
	_meta.text = "%s · cost %d · %s" % [GameEnums.hand_card_type_wire(card.type), cost, fate]
	_blurb.text = ", ".join(tags) if tags.size() > 0 else CraftCatalog.skill_blurb(card.id)
	_apply_style()


func _apply_style() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = CHIP
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(1)
	sb.border_color = BORDER
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	add_theme_stylebox_override("panel", sb)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if _locked:
		return null
	var preview := _label(_name.text, 13, INK)
	set_drag_preview(preview)
	return {"kind": "craft_hand", "hand_index": hand_index}


func _on_gui(event: InputEvent) -> void:
	if _locked:
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_press_pos = mouse.position
		elif _press_pos.distance_to(mouse.position) < 8.0:
			slot_played.emit(hand_index)


func _label(text: String, size: int, color: Color) -> Label:
	var lab := Label.new()
	lab.text = text
	lab.add_theme_font_size_override("font_size", size)
	lab.add_theme_color_override("font_color", color)
	return lab
