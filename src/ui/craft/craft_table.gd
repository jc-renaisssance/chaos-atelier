class_name CraftTable
extends Control
## Stamina craft table (docs/27). Construction from the order. No lineup / 2m1r / picker.

const INK := Color.html("#e8d5b0")
const MUTED := Color.html("#b5a48a")
const GOLD := Color.html("#c9a227")
const WOOD := Color.html("#1a1410")
const PANEL := Color.html("#2a2118")

var _title: Label
var _meta: Label
var _note: Label
var _stam_label: Label
var _stam_bar: ProgressBar
var _piece_title: Label
var _piece_body: Label
var _played: HFlowContainer
var _hand: HBoxContainer
var _stock: Label
var _dig_btn: Button
var _finish_btn: Button
var _continue_btn: Button
var _result: Label
var _stamp: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	AtelierSession.craft_started.connect(_refresh)
	AtelierSession.craft_changed.connect(_refresh)
	AtelierSession.piece_finished.connect(_on_piece)
	_refresh()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = WOOD
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	_title = _label("CRAFT  ·  stamina hand  ·  construction from the order", 24, GOLD)
	root.add_child(_title)
	_meta = _label("", 14, INK)
	_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_meta)
	_note = _label("", 13, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_note)

	root.add_child(_caption("STAMINA  ·  start 12  ·  ends at 0 or early finish"))
	var stam_panel := _panel()
	root.add_child(stam_panel)
	var stam_box := VBoxContainer.new()
	stam_box.add_theme_constant_override("separation", 6)
	stam_panel.add_child(stam_box)
	_stam_label = _label("12 / 12", 16, INK)
	stam_box.add_child(_stam_label)
	_stam_bar = ProgressBar.new()
	_stam_bar.min_value = 0
	_stam_bar.max_value = GameConstants.STAMINA_START
	_stam_bar.value = GameConstants.STAMINA_START
	_stam_bar.show_percentage = false
	_stam_bar.custom_minimum_size = Vector2(0, 18)
	_stam_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stam_box.add_child(_stam_bar)

	root.add_child(_caption("PIECE  ·  order-fixed  ·  not a hand card  ·  no construction picker"))
	var piece := _panel()
	root.add_child(piece)
	var piece_box := VBoxContainer.new()
	piece_box.add_theme_constant_override("separation", 6)
	piece.add_child(piece_box)
	_piece_title = _label("No piece", 16, GOLD)
	piece_box.add_child(_piece_title)
	_piece_body = _label("", 13, INK)
	_piece_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	piece_box.add_child(_piece_body)
	_played = HFlowContainer.new()
	_played.add_theme_constant_override("h_separation", 8)
	_played.add_theme_constant_override("v_separation", 8)
	piece_box.add_child(_played)

	root.add_child(_caption("HAND  ·  materials + enchantments + owner skills  ·  no auto-refill"))
	var hand_panel := _panel()
	hand_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(hand_panel)
	var hand_box := VBoxContainer.new()
	hand_box.add_theme_constant_override("separation", 8)
	hand_panel.add_child(hand_box)
	_hand = HBoxContainer.new()
	_hand.add_theme_constant_override("separation", 8)
	hand_box.add_child(_hand)
	_stock = _label("", 12, MUTED)
	hand_box.add_child(_stock)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	hand_box.add_child(btns)
	_dig_btn = _btn("Dig / refresh (−2 stamina)", _on_dig)
	btns.add_child(_dig_btn)
	_finish_btn = _btn("Early finish", _on_finish)
	btns.add_child(_finish_btn)
	_continue_btn = _btn("Continue", _on_continue)
	btns.add_child(_continue_btn)

	root.add_child(_caption("RESOLVER  ·  tag tally  ·  mission sim stub"))
	var res := _panel()
	root.add_child(res)
	_result = _label("Play cards into the piece, or finish empty.", 13, INK)
	_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	res.add_child(_result)

	root.add_child(_caption("STAMP  ·  docs/20 stamina session  ·  crafts_done counts pieces"))
	var stamp_panel := _panel()
	stamp_panel.custom_minimum_size.y = 88
	root.add_child(stamp_panel)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 72
	stamp_panel.add_child(scroll)
	_stamp = _label("{}", 12, MUTED)
	_stamp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stamp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_stamp)


func _caption(text: String) -> Label:
	return _label(text, 12, GOLD)


func _label(text: String, size: int, color: Color) -> Label:
	var lab := Label.new()
	lab.text = text
	lab.add_theme_font_size_override("font_size", size)
	lab.add_theme_color_override("font_color", color)
	return lab


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(1)
	sb.border_color = Color.html("#3d342c")
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", sb)
	return panel


func _btn(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.pressed.connect(cb)
	return btn


func refresh() -> void:
	_refresh()


func _refresh() -> void:
	var session: CraftStaminaSession = AtelierSession.craft_session
	var order: ClientOrder = AtelierSession.craft_order
	if session == null or order == null:
		_title.text = "CRAFT  ·  stamina hand"
		_meta.text = "No session."
		return
	var con_name := CraftCatalog.construction_name(session.construction_id)
	_title.text = "CRAFT  ·  %s  ·  own_basic" % order.order_id
	_meta.text = (
		"Piece %d / %d   ·   %s   ·   %s   ·   stock %d   ·   next-mat-free %s   ·   pieces sewn %d / %d"
		% [
			session.piece_index,
			session.piece_count,
			con_name,
			GameEnums.mission_kind_wire(order.mission_kind),
			AtelierSession.stock.count() if AtelierSession.stock != null else 0,
			"yes" if AtelierSession.next_mat_free else "no",
			AtelierSession.board.crafts_done if AtelierSession.board != null else 0,
			GameConstants.CRAFTS_MAX,
		]
	)
	_note.text = AtelierSession.last_note
	_stam_label.text = (
		"Stamina %d / %d   ·   spent %d   ·   digs %d   ·   dig costs %d"
		% [
			session.stamina_remaining,
			session.stamina_start,
			session.stamina_spent,
			session.dig_count,
			session.dig_refresh_cost,
		]
	)
	_stam_bar.max_value = session.stamina_start
	_stam_bar.value = session.stamina_remaining
	var tags := CraftCatalog.construction_tags(session.construction_id)
	var stats := CraftCatalog.construction_stats(session.construction_id)
	_piece_title.text = "Sewing %s  ·  construction_ids from the order, not a pick" % con_name
	_piece_body.text = (
		"Tags %s   ·   stats HP %+d  ATK %+d  DEF %+d  RES %+d  MOB %+d  PRE %+d   ·   infinite monostack (stamina + stock gate)"
		% [
			", ".join(tags) if tags.size() > 0 else "—",
			int(stats.get("HP", 0)),
			int(stats.get("ATK", 0)),
			int(stats.get("DEF", 0)),
			int(stats.get("RES", 0)),
			int(stats.get("MOB", 0)),
			int(stats.get("PRE", 0)),
		]
	)
	_rebuild_played(session)
	_rebuild_hand(session)
	_stock.text = (
		"Wagon stock %d remaining. Empty hand is legal. Dig rummages leftover + stock; played cards stay sewn."
		% (AtelierSession.stock.count() if AtelierSession.stock != null else 0)
	)
	var busy := session.is_finished() or AtelierSession.awaiting_next_piece or AtelierSession.order_craft_done
	_dig_btn.disabled = busy or not CraftRules.can_dig(session, AtelierSession.stock)
	_finish_btn.disabled = busy
	_continue_btn.visible = AtelierSession.awaiting_next_piece or AtelierSession.order_craft_done
	if AtelierSession.awaiting_next_piece:
		_continue_btn.text = "Sew next piece"
	elif AtelierSession.order_craft_done:
		_continue_btn.text = "Return to schedule"
	_refresh_result(session)
	_stamp.text = JSON.stringify(AtelierSession.stamp_preview(), "  ")


func _rebuild_played(session: CraftStaminaSession) -> void:
	for child in _played.get_children():
		child.queue_free()
	if session.cards_played.is_empty():
		_played.add_child(_label("Nothing sewn yet.", 13, MUTED))
		return
	for card in session.cards_played:
		var text := "%s  ·  %s  ·  −%d" % [
			CraftCatalog.display_name(card.id, card.type),
			GameEnums.hand_card_type_wire(card.type),
			card.cost,
		]
		_played.add_child(_chip(text))


func _rebuild_hand(session: CraftStaminaSession) -> void:
	for child in _hand.get_children():
		child.queue_free()
	if session.hand.is_empty():
		_hand.add_child(_label("Hand empty — dig (2 stamina) or early finish.", 14, MUTED))
		return
	var locked := session.is_finished() or AtelierSession.awaiting_next_piece or AtelierSession.order_craft_done
	for i in range(session.hand.size()):
		var card: HandCard = session.hand[i]
		var cost := CraftCatalog.play_cost(card, AtelierSession.next_mat_free)
		var tags := CraftCatalog.tags_of(card.id, card.type)
		var blurb := ", ".join(tags) if tags.size() > 0 else CraftCatalog.skill_blurb(card.id)
		var btn := Button.new()
		btn.text = "%s\n%s · cost %d\n%s" % [
			CraftCatalog.display_name(card.id, card.type),
			GameEnums.hand_card_type_wire(card.type),
			cost,
			blurb,
		]
		btn.custom_minimum_size = Vector2(148, 96)
		btn.disabled = locked or not CraftRules.can_play(session, i, AtelierSession.next_mat_free)
		btn.pressed.connect(_on_play.bind(i))
		_hand.add_child(btn)


func _chip(text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.html("#3a2c18")
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", sb)
	panel.add_child(_label(text, 12, INK))
	return panel


func _refresh_result(session: CraftStaminaSession) -> void:
	if AtelierSession.last_piece_result.is_empty() or not session.is_finished():
		_result.text = "Mission / boss sim is stubbed. Tag tally + rarity + synergies stamp on finish."
		return
	var result: Dictionary = AtelierSession.last_piece_result
	_result.text = (
		"Finish %s   ·   rarity %s   ·   look %s (%d)   ·   rating %s (stub)   ·   tags %s   ·   +%s   ·   −%s"
		% [
			GameEnums.finish_reason_wire(session.finish_reason),
			GameEnums.craft_rarity_wire(result.get("craft_rarity", GameEnums.CraftRarity.NONE)),
			String(result.get("outlook_id", "plain")),
			int(result.get("outlook_order", 0)),
			GameEnums.rating_wire(result.get("rating", GameEnums.Rating.NONE)),
			str(result.get("tag_counts", {})),
			str(result.get("powers_positive", [])),
			str(result.get("powers_negative", [])),
		]
	)


func _on_piece(_result: Dictionary) -> void:
	_refresh()


func _on_play(index: int) -> void:
	AtelierSession.play_hand(index)


func _on_dig() -> void:
	AtelierSession.dig()


func _on_finish() -> void:
	AtelierSession.finish_early()


func _on_continue() -> void:
	AtelierSession.continue_after_piece()
