class_name CraftZone
extends PanelContainer
## Drop zone for one ordered piece (docs/27). Hidden if unused (N < 4).

signal zone_selected(zone_index: int)
signal card_dropped(hand_index: int, zone_index: int)

const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const PANEL := Color(0.165, 0.129, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)
const SELECTED := Color(0.788, 0.635, 0.153)
const CHIP := Color(0.227, 0.173, 0.094)

var zone_index: int = 1
var _title: Label
var _body: Label
var _played: VBoxContainer
var _selected: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(140, 160)
	_apply_style()
	if _title != null:
		return
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	_title = _label("Zone", 13, GOLD)
	box.add_child(_title)
	_body = _label("", 12, MUTED)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_body)
	_played = VBoxContainer.new()
	_played.add_theme_constant_override("separation", 4)
	box.add_child(_played)
	gui_input.connect(_on_gui)


func bind(
	zone_index_: int,
	construction_id: String,
	selected: bool,
	cards: Array[PlayedCard],
	locked: bool
) -> void:
	zone_index = zone_index_
	_selected = selected
	mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else Control.MOUSE_FILTER_STOP
	_apply_style()
	var name := CraftCatalog.construction_name(construction_id)
	_title.text = "ZONE %d%s  ·  %s" % [zone_index, "  ·  selected" if selected else "", name]
	if cards.is_empty():
		_body.text = "Empty — Finish uses the construction-only bag."
	else:
		_body.text = "%d play(s) in this bag." % cards.size()
	for child in _played.get_children():
		child.queue_free()
	for card in cards:
		var line := "%s  ·  %s  ·  −%d" % [
			CraftCatalog.display_name(card.id, card.type),
			GameEnums.hand_card_type_wire(card.type),
			card.cost,
		]
		_played.add_child(_chip(line))


func _apply_style() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(2 if _selected else 1)
	sb.border_color = SELECTED if _selected else BORDER
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	add_theme_stylebox_override("panel", sb)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	var row: Dictionary = data
	return String(row.get("kind", "")) == "craft_hand" and int(row.get("hand_index", -1)) >= 0


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	var row: Dictionary = data
	card_dropped.emit(int(row.get("hand_index", -1)), zone_index)


func _on_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			zone_selected.emit(zone_index)


func _label(text: String, size: int, color: Color) -> Label:
	var lab := Label.new()
	lab.text = text
	lab.add_theme_font_size_override("font_size", size)
	lab.add_theme_color_override("font_color", color)
	return lab


func _chip(text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = CHIP
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", sb)
	panel.add_child(_label(text, 11, INK))
	return panel
