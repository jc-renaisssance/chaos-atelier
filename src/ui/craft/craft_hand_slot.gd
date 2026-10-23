class_name CraftHandSlot
extends PanelContainer
## Hand slot. Cards display here only (docs/27, docs/34). Drag into a zone, or click / 1–5.
## An empty slot is still a frame: index, no name.

signal slot_played(hand_index: int)

var hand_index: int = 0
var _locked: bool = true
var _press_pos: Vector2 = Vector2.ZERO
var _dragged: bool = false
var _shiny: bool = false
var _shine_bar: ColorRect
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
	_shine_bar = ColorRect.new()
	_shine_bar.color = ShellTheme.SHINE_BAR
	_shine_bar.custom_minimum_size = Vector2(0, 8)
	_shine_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shine_bar.visible = false
	box.add_child(_shine_bar)
	_caption = _label("1", ShellTheme.SLOT_PX, ShellTheme.GOLD)
	box.add_child(_caption)
	_name = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_name)
	_meta = _label("", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_meta)
	_blurb = _label("", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	_blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_blurb)
	gui_input.connect(_on_gui)


func bind(index: int, card: HandCard, cost: int, locked: bool, can_play: bool) -> void:
	hand_index = index
	_locked = locked or not can_play
	mouse_filter = Control.MOUSE_FILTER_IGNORE if _locked else Control.MOUSE_FILTER_STOP
	_shiny = card != null and card.is_enchanted()
	_caption.text = str(index + 1)
	_name.text = CraftCatalog.display_name(card.id, card.type)
	var tags := CraftCatalog.tags_of(card.id, card.type)
	var fate := "burns" if CraftRules.burns_on_play(card.type) else "to discard"
	var meta := "%s · cost %d · %s" % [GameEnums.hand_card_type_wire(card.type), cost, fate]
	if _shiny:
		meta += " · shiny %s" % card.mat_enchant_id
	_meta.text = meta
	_blurb.text = ", ".join(tags) if tags.size() > 0 else CraftCatalog.skill_blurb(card.id)
	_apply_style()


func bind_empty(index: int) -> void:
	hand_index = index
	_locked = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_shiny = false
	_caption.text = str(index + 1)
	_name.text = ""
	_meta.text = ""
	_blurb.text = ""
	_apply_style()


func _apply_style() -> void:
	var sb := ShellTheme.hand_shiny() if _shiny else ShellTheme.hand()
	modulate = ShellTheme.SHINY_MODULATE if _shiny else Color(1, 1, 1)
	if _shine_bar != null:
		_shine_bar.visible = _shiny
	add_theme_stylebox_override("panel", sb)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if _locked:
		return null
	_dragged = true
	var preview := _label(_name.text, ShellTheme.BODY_PX, ShellTheme.INK)
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
			_dragged = false
		elif not _dragged and _press_pos.distance_to(mouse.position) < 8.0:
			slot_played.emit(hand_index)


func _label(text: String, size: int, color: Color) -> Label:
	return ShellTheme.label(text, size, color)
