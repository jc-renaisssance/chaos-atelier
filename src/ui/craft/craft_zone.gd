class_name CraftZone
extends PanelContainer
## Drop zone for one ordered piece (docs/27, docs/34, docs/36 Drop A).
## Hidden if unused (N < 4). Selected reads as the gold border.
## While a card is dragged over a visible zone: 2px gold, inner well, scale 1.03.
## A played card keeps its text line and adds a 32×32 face on the left.

signal zone_selected(zone_index: int)

const DROP_WELL_ALPHA := 0.12
const DROP_SCALE := 1.03
const DROP_SEC := 0.08

var zone_index: int = 1
var _title: Label
var _index: Label
var _body: Label
var _played: VBoxContainer
var _well: ColorRect
var _selected: bool = false
var _locked: bool = false
var _drop_hot: bool = false
var _drop_tween: Tween
var _last_face: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(140, 160)
	resized.connect(_on_resized)
	_apply_style()
	if _title != null:
		return
	_well = ColorRect.new()
	_well.color = Color(ShellTheme.GOLD.r, ShellTheme.GOLD.g, ShellTheme.GOLD.b, DROP_WELL_ALPHA)
	_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_well.visible = false
	add_child(_well)
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
	_played.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	_locked = locked
	mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else Control.MOUSE_FILTER_STOP
	if locked:
		set_drop_hot(false)
	_apply_style()
	_title.text = CraftCatalog.construction_name(construction_id)
	_index.text = str(zone_index)
	if cards.is_empty():
		_body.text = "Empty — Finish uses the construction-only bag."
	else:
		_body.text = ""
	for child in _played.get_children():
		child.queue_free()
	_last_face = null
	for card in cards:
		_played.add_child(_played_row(card))


func is_locked() -> bool:
	return _locked


func set_drop_hot(on: bool) -> void:
	if _locked:
		on = false
	if _drop_hot == on:
		return
	_drop_hot = on
	if _well != null:
		_well.visible = on
	_on_resized()
	_apply_style()
	_tween_scale(DROP_SCALE if on else 1.0)


func clear_drop_hot(immediate: bool) -> void:
	var was := _drop_hot
	_drop_hot = false
	if _well != null:
		_well.visible = false
	_apply_style()
	if not was and is_equal_approx(scale.x, 1.0):
		return
	if immediate:
		if _drop_tween != null and _drop_tween.is_valid():
			_drop_tween.kill()
		scale = Vector2.ONE
		return
	_tween_scale(1.0)


func last_face_global_rect() -> Rect2:
	if _last_face == null or not is_instance_valid(_last_face):
		return Rect2()
	return _last_face.get_global_rect()


func contains_global(point: Vector2) -> bool:
	if not visible or not is_visible_in_tree():
		return false
	var xform := get_global_transform()
	if is_zero_approx(xform.determinant()):
		return false
	var local: Vector2 = xform.affine_inverse() * point
	return Rect2(Vector2.ZERO, size).has_point(local)


func _played_row(card: PlayedCard) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var face := _played_face(card)
	row.add_child(face)
	_last_face = face
	var line := "%s  ·  %s  ·  −%d" % [
		CraftCatalog.display_name(card.id, card.type),
		GameEnums.hand_card_type_wire(card.type),
		card.cost,
	]
	var lab := _label(line, ShellTheme.BODY_PX, ShellTheme.INK)
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lab)
	return row


func _played_face(card: PlayedCard) -> Control:
	var well := Panel.new()
	well.custom_minimum_size = Vector2(MatFace.ICON_PX, MatFace.ICON_PX)
	well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well.add_theme_stylebox_override("panel", ShellTheme.chip_well(2))
	var tex := MatFace.texture_for(card.id, card.type)
	if tex != null:
		var icon := TextureRect.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = tex
		well.add_child(icon)
	return well


func _apply_style() -> void:
	var gold := _selected or _drop_hot
	var sb := ShellTheme.zone_selected() if gold else ShellTheme.zone_idle()
	add_theme_stylebox_override("panel", sb)


func _tween_scale(target: float) -> void:
	if _drop_tween != null and _drop_tween.is_valid():
		_drop_tween.kill()
	_drop_tween = create_tween()
	_drop_tween.set_ease(Tween.EASE_OUT)
	_drop_tween.set_trans(Tween.TRANS_QUAD)
	_drop_tween.tween_property(self, "scale", Vector2(target, target), DROP_SEC)


func _on_resized() -> void:
	pivot_offset = size * 0.5


func _on_gui(event: InputEvent) -> void:
	if _locked:
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			zone_selected.emit(zone_index)


func _label(text: String, font_size: int, color: Color) -> Label:
	var lab := ShellTheme.label(text, font_size, color)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lab
