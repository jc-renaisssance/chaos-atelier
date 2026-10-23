class_name CraftHandFan
extends Control
## Arc fan for the cards in hand this frame (docs/36 Hand A′).
## Empty frames are not kept. The fan does not draw more cards than max_hand.

var hold_layout: bool = false

var _order: Array[CraftHandSlot] = []
var _max_hand: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	custom_minimum_size = CraftHandLayout.band_min_size()
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_END
	resized.connect(_on_resized)


func clear_cards() -> void:
	_order.clear()
	_max_hand = 0
	for child in get_children():
		if child is CraftHandSlot:
			var slot := child as CraftHandSlot
			slot.visible = false
			slot.queue_free()


func present(slots: Array[CraftHandSlot], max_hand: int, animate: bool, deal: bool) -> void:
	_order = slots
	_max_hand = max_hand
	for i in range(_order.size()):
		var slot := _order[i]
		if slot.get_parent() != self:
			add_child(slot)
		move_child(slot, i)
		slot.rest_z = i
		if not slot.is_hovered():
			slot.z_index = i
	_layout(animate, deal)


func cards() -> Array[CraftHandSlot]:
	return _order


func detach_cards() -> Array[CraftHandSlot]:
	var taken: Array[CraftHandSlot] = []
	var kids: Array[Node] = []
	for child in get_children():
		kids.append(child)
	for child in kids:
		if not (child is CraftHandSlot):
			continue
		var slot := child as CraftHandSlot
		slot.suppress_hover()
		slot.set_meta("dump_pos", slot.global_position)
		slot.set_meta("dump_rot", slot.rotation)
		slot.set_meta("dump_scale", slot.scale)
		remove_child(slot)
		taken.append(slot)
	_order.clear()
	return taken


func set_cards_hover_locked(locked: bool) -> void:
	for slot in _order:
		slot.set_hover_locked(locked)


func _on_resized() -> void:
	if hold_layout or _order.is_empty():
		return
	_layout(false, false)


func _layout(animate: bool, deal: bool) -> void:
	var n := _order.size()
	if n == 0:
		return
	var band := size
	var min_band := CraftHandLayout.band_min_size()
	if band.x < CraftHandLayout.CARD_W:
		band.x = min_band.x
	if band.y < CraftHandLayout.CARD_H:
		band.y = min_band.y
	for i in range(n):
		var slot := _order[i]
		var pos := CraftHandLayout.top_left(i, n, _max_hand, band)
		var rot := CraftHandLayout.rotation_rad(i, n, _max_hand)
		slot.pivot_offset = Vector2(CraftHandLayout.CARD_W * 0.5, CraftHandLayout.CARD_H)
		if deal:
			slot.snap_rest(pos, rot)
		else:
			slot.apply_rest(pos, rot, animate, CraftHandLayout.REFLOW_SEC)
