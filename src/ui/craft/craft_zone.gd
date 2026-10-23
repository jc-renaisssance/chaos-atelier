class_name CraftZone
extends PanelContainer
## Drop zone for one ordered piece (docs/27, docs/34). Hidden if unused (N < 4).
## Selected reads as the gold border. The word "selected" is not a suffix.

signal zone_selected(zone_index: int)
signal card_dropped(hand_index: int, zone_index: int)

var zone_index: int = 1
var _title: Label
var _index: Label
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
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	_index = _label("", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	box.add_child(_index)
	_title = _label("", ShellTheme.SECTION_PX, ShellTheme.GOLD)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_title)
	_body = _label("", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_body)
	_played = VBoxContainer.new()
	_played.add_theme_constant_override("separation", 2)
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
	_title.text = CraftCatalog.construction_name(construction_id)
	_index.text = str(zone_index)
	if cards.is_empty():
		_body.text = "Empty — Finish uses the construction-only bag."
	else:
		_body.text = ""
	for child in _played.get_children():
		child.queue_free()
	for card in cards:
		var line := "%s  ·  %s  ·  −%d" % [
			CraftCatalog.display_name(card.id, card.type),
			GameEnums.hand_card_type_wire(card.type),
			card.cost,
		]
		var lab := _label(line, ShellTheme.BODY_PX, ShellTheme.INK)
		lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_played.add_child(lab)


func _apply_style() -> void:
	var sb := ShellTheme.zone_selected() if _selected else ShellTheme.zone_idle()
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
	return ShellTheme.label(text, size, color)
