class_name CraftHandSlot
extends Panel
## Portrait hand card (docs/36). 108×148, face well 88×88, pivot at the bottom center.
## A missing mat png keeps the chip well. Drag threshold and play live on the table.
## Soft A: native tag chips sit in the face well. Type stays on line 1. Cost stays on line 2.

const PlayerChrome := preload("res://src/ui/player_chrome.gd")

var hand_index: int = 0
var card: HandCard
var cost: int = 0
var can_click: bool = false
var can_drag: bool = false
var rest_position: Vector2 = Vector2.ZERO
var rest_rotation: float = 0.0
var rest_z: int = 0
var flight_visual: bool = false

var _hovered: bool = false
var _hover_locked: bool = false
var _ghost: bool = false
var _shiny: bool = false
var _instance_id: int = 0
var _tween: Tween
var _face_well: Panel
var _face: TextureRect
var _tag_row: Control
var _shine: ColorRect
var _index: Label
var _name: Label
var _caption: Label


func _ready() -> void:
	## Cost sits on its own caption line. Clipping the card rect was eating that line.
	clip_contents = false
	custom_minimum_size = Vector2(CraftHandLayout.CARD_W, CraftHandLayout.CARD_H)
	size = custom_minimum_size
	pivot_offset = Vector2(size.x * 0.5, size.y)
	mouse_filter = Control.MOUSE_FILTER_IGNORE if flight_visual else Control.MOUSE_FILTER_STOP
	if _index != null:
		return
	_build()
	_apply_style()


func bind(index: int, next: HandCard, next_cost: int, clickable: bool, draggable: bool) -> void:
	hand_index = index
	card = next
	cost = next_cost
	can_click = clickable
	can_drag = draggable
	_instance_id = next.get_instance_id() if next != null else 0
	_shiny = next != null and next.is_enchanted()
	_index.text = str(index + 1)
	_name.text = CraftCatalog.display_name(next.id, next.type) if next != null else ""
	_caption.text = _caption_for(next, next_cost)
	_bind_face(next)
	_bind_tag_chips(next)
	if flight_visual or _ghost:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if (can_click or can_drag) else Control.CURSOR_ARROW
	_apply_style()
	if _ghost:
		_apply_ghost_look()


func tracks(instance_id: int) -> bool:
	return _instance_id == instance_id and instance_id != 0


func is_hovered() -> bool:
	return _hovered


func set_ghost(on: bool) -> void:
	_ghost = on
	if on:
		suppress_hover()
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_ghost_look()
	else:
		_face_well.visible = true
		_face.visible = _face.texture != null
		if _tag_row != null:
			_tag_row.visible = _tag_row.get_child_count() > 0
		mouse_filter = Control.MOUSE_FILTER_IGNORE if flight_visual else Control.MOUSE_FILTER_STOP
		_apply_style()


func set_hover_locked(locked: bool) -> void:
	_hover_locked = locked
	if locked:
		suppress_hover()
		position = rest_position
		rotation = rest_rotation
		scale = Vector2.ONE


func set_hovered(on: bool) -> void:
	if _ghost or _hover_locked or flight_visual:
		on = false
	if _hovered == on:
		return
	_hovered = on
	z_index = 40 if on else rest_z
	_tween_to(_shown_position(), _shown_rotation(), _shown_scale(), CraftHandLayout.HOVER_SEC)


func suppress_hover() -> void:
	_hovered = false
	z_index = rest_z
	_kill_tween()


func snap_rest(pos: Vector2, rot: float) -> void:
	rest_position = pos
	rest_rotation = rot
	_kill_tween()
	position = pos
	rotation = rot
	scale = Vector2.ONE


func apply_rest(pos: Vector2, rot: float, animate: bool, duration: float) -> void:
	rest_position = pos
	rest_rotation = rot
	if _hovered:
		z_index = 40
	else:
		z_index = rest_z
	if not animate:
		_kill_tween()
		position = _shown_position()
		rotation = _shown_rotation()
		scale = _shown_scale()
		return
	_tween_to(_shown_position(), _shown_rotation(), _shown_scale(), duration)


func play_deal(from_y: float, from_scale: float, duration: float, delay: float, done: Callable) -> void:
	suppress_hover()
	position = rest_position + Vector2(0, from_y)
	rotation = rest_rotation
	scale = Vector2(from_scale, from_scale)
	modulate.a = 0.0
	var tw := _begin_tween()
	tw.tween_property(self, "position", rest_position, duration).set_delay(delay)
	tw.tween_property(self, "scale", Vector2.ONE, duration).set_delay(delay)
	tw.tween_property(self, "modulate:a", 1.0, duration).set_delay(delay)
	if done.is_valid():
		tw.finished.connect(done, CONNECT_ONE_SHOT)


func play_dump(drop_px: float, duration: float, delay: float, done: Callable) -> void:
	suppress_hover()
	var tw := _begin_tween()
	tw.tween_property(self, "position:y", position.y + drop_px, duration).set_delay(delay)
	tw.tween_property(self, "modulate:a", 0.0, duration).set_delay(delay)
	tw.finished.connect(func() -> void:
		if done.is_valid():
			done.call()
		if is_instance_valid(self):
			queue_free()
	, CONNECT_ONE_SHOT)


func _get_tooltip(at_position: Vector2) -> String:
	return _chip_word_at(at_position)


func _chip_word_at(local: Vector2) -> String:
	if _tag_row == null or not _tag_row.visible or _face_well == null or not _face_well.visible:
		return ""
	var in_row := local - _face_well.position - _tag_row.position
	for child in _tag_row.get_children():
		var chip := child as TextureRect
		if chip == null:
			continue
		if Rect2(chip.position, chip.size).has_point(in_row):
			return chip.tooltip_text
	return ""


func contains_global(point: Vector2) -> bool:
	if not is_visible_in_tree():
		return false
	var xform := get_global_transform()
	if is_zero_approx(xform.determinant()):
		return false
	var local: Vector2 = xform.affine_inverse() * point
	return Rect2(Vector2.ZERO, size).has_point(local)


func _shown_position() -> Vector2:
	if _hovered:
		return rest_position + Vector2(0, -CraftHandLayout.HOVER_LIFT_PX)
	return rest_position


func _shown_rotation() -> float:
	if _hovered:
		return 0.0
	return rest_rotation


func _shown_scale() -> Vector2:
	if _hovered:
		return Vector2(CraftHandLayout.HOVER_SCALE, CraftHandLayout.HOVER_SCALE)
	return Vector2.ONE


func _build() -> void:
	_shine = ColorRect.new()
	_shine.color = ShellTheme.SHINE_BAR
	_shine.position = Vector2.ZERO
	_shine.size = Vector2(CraftHandLayout.CARD_W, 4)
	_shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shine.visible = false
	add_child(_shine)

	_face_well = Panel.new()
	_face_well.position = Vector2(
		(CraftHandLayout.CARD_W - CraftHandLayout.FACE_PX) * 0.5,
		18
	)
	_face_well.size = Vector2(CraftHandLayout.FACE_PX, CraftHandLayout.FACE_PX)
	_face_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face_well.add_theme_stylebox_override("panel", ShellTheme.chip_well(4))
	add_child(_face_well)

	_face = TextureRect.new()
	_face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.visible = false
	_face_well.add_child(_face)

	## Bottom of the well, left inset 2. Three native chips end at x = 54 inside the 88 well.
	_tag_row = Control.new()
	_tag_row.name = "TagChips"
	_tag_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tag_row.position = Vector2(
		PlannerChipArt.CARD_INSET,
		CraftHandLayout.FACE_PX - PlannerChipArt.CARD_INSET - PlannerChipArt.CARD_PX
	)
	_tag_row.size = Vector2(
		3 * PlannerChipArt.CARD_PX + 2 * PlannerChipArt.CARD_GAP,
		PlannerChipArt.CARD_PX
	)
	_tag_row.visible = false
	_face_well.add_child(_tag_row)

	_index = _label("", ShellTheme.SLOT_PX, ShellTheme.GOLD)
	_index.position = Vector2(8, 3)
	_index.size = Vector2(36, 14)
	add_child(_index)

	_name = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_name.position = Vector2(8, 106)
	_name.size = Vector2(CraftHandLayout.CARD_W - 16, 14)
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name.clip_text = true
	add_child(_name)

	## Line 1 is the type, or the skill blurb. Line 2 is only the cost, so it cannot wrap off.
	## Soft A: tag names leave this caption. A tag with no chip file keeps that word on line 1.
	_caption = _label("", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	_caption.position = Vector2(8, 120)
	_caption.size = Vector2(CraftHandLayout.CARD_W - 16, 28)
	_caption.autowrap_mode = TextServer.AUTOWRAP_OFF
	_caption.max_lines_visible = 2
	_caption.clip_text = true
	_caption.add_theme_constant_override("line_spacing", 0)
	add_child(_caption)


func _bind_face(next: HandCard) -> void:
	var tex: Texture2D = null
	if next != null:
		tex = MatFace.texture_for(next.id, next.type)
	_face.texture = tex
	_face.visible = tex != null and not _ghost
	_face_well.visible = not _ghost


func _bind_tag_chips(next: HandCard) -> void:
	if _tag_row == null:
		return
	for child in _tag_row.get_children():
		_tag_row.remove_child(child)
		child.free()
	var show := false
	if next != null and next.type != GameEnums.HandCardType.SKILL:
		var chips := PlannerChipArt.make_card_chips(CraftCatalog.tags_of(next.id, next.type))
		var step := PlannerChipArt.CARD_PX + PlannerChipArt.CARD_GAP
		for i in chips.size():
			var chip := chips[i]
			chip.position = Vector2(i * step, 0)
			_tag_row.add_child(chip)
		show = not chips.is_empty()
	_tag_row.visible = show


func _caption_for(next: HandCard, next_cost: int) -> String:
	if next == null:
		return ""
	var cost_line := "cost %d" % next_cost
	if next.type == GameEnums.HandCardType.SKILL:
		var blurb := CraftCatalog.skill_blurb(next.id)
		if not AtelierSession.dev_tools:
			blurb = PlayerChrome.skill_blurb(next.id)
		if blurb.is_empty():
			return "skill\n%s" % cost_line
		return "skill · %s\n%s" % [blurb, cost_line]
	var kind := GameEnums.hand_card_type_wire(next.type)
	var words := PlannerChipArt.tags_without_chip(CraftCatalog.tags_of(next.id, next.type))
	var head := kind
	if not words.is_empty():
		head = "%s · %s" % [kind, ", ".join(words)]
	return "%s\n%s" % [head, cost_line]


func _apply_style() -> void:
	var sb := ShellTheme.hand_shiny() if _shiny else ShellTheme.hand()
	add_theme_stylebox_override("panel", sb)
	if _shine != null:
		_shine.visible = _shiny and not _ghost
	if _ghost:
		_apply_ghost_look()
		return
	var tint := ShellTheme.SHINY_MODULATE if _shiny else Color(1, 1, 1)
	tint.a = 1.0
	modulate = tint


func _apply_ghost_look() -> void:
	if _face_well != null:
		_face_well.visible = false
	if _face != null:
		_face.visible = false
	if _shine != null:
		_shine.visible = false
	var tint := ShellTheme.SHINY_MODULATE if _shiny else Color(1, 1, 1)
	tint.a = 0.35
	modulate = tint


func _tween_to(pos: Vector2, rot: float, next_scale: Vector2, duration: float) -> void:
	var tw := _begin_tween()
	tw.tween_property(self, "position", pos, duration)
	tw.tween_property(self, "rotation", rot, duration)
	tw.tween_property(self, "scale", next_scale, duration)


func _begin_tween() -> Tween:
	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	return _tween


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null


func _label(text: String, font_size: int, color: Color) -> Label:
	var lab := ShellTheme.label(text, font_size, color)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lab
