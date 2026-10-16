class_name MarketScreen
extends Control
## Ugly M1 market shell — materials tab only (docs/32). Staffs / skills / gear = M2.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)
const SHINE := Color(0.95, 0.82, 0.22, 0.38)
const CHIP := Color(0.227, 0.173, 0.094)

var _title: Label
var _meta: Label
var _note: Label
var _shelf_box: VBoxContainer
var _deck_box: VBoxContainer
var _refresh_btn: Button
var _rebuild_queued: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	refresh()


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
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	root.add_child(head)
	_title = _label("market · —", 22, GOLD)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_title)
	head.add_child(_btn("Exit", _on_exit))

	_meta = _label("gold 0   ·   refresh next $2", 15, INK)
	_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_meta)
	_note = _label("Materials tab. Staffs / skill cards / gear = M2.", 13, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_note)

	root.add_child(_caption("TAB  ·  Materials (M1 live)  ·  Staffs / Skills / Gear parked M2"))

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)

	var shelf_wrap := VBoxContainer.new()
	shelf_wrap.add_theme_constant_override("separation", 6)
	shelf_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(shelf_wrap)
	shelf_wrap.add_child(_caption("SHELF  ·  buy from market_bank_c1"))
	var shelf_panel := _panel()
	shelf_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shelf_wrap.add_child(shelf_panel)
	var shelf_scroll := ScrollContainer.new()
	shelf_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shelf_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shelf_panel.add_child(shelf_scroll)
	_shelf_box = VBoxContainer.new()
	_shelf_box.add_theme_constant_override("separation", 6)
	_shelf_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_scroll.add_child(_shelf_box)

	var deck_wrap := VBoxContainer.new()
	deck_wrap.add_theme_constant_override("separation", 6)
	deck_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(deck_wrap)
	deck_wrap.add_child(_caption("DECK  ·  sell / enchant owned mat_*"))
	var deck_panel := _panel()
	deck_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_wrap.add_child(deck_panel)
	var deck_scroll := ScrollContainer.new()
	deck_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	deck_panel.add_child(deck_scroll)
	_deck_box = VBoxContainer.new()
	_deck_box.add_theme_constant_override("separation", 6)
	_deck_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_scroll.add_child(_deck_box)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	root.add_child(actions)
	_refresh_btn = _btn("Refresh $2", _on_refresh)
	actions.add_child(_refresh_btn)
	actions.add_child(_btn("Exit", _on_exit))
	var hint := _label("Refresh / Enchant do not resolve the day. Exit does.", 12, MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	actions.add_child(hint)


func refresh() -> void:
	if not is_inside_tree():
		return
	_sync_header()
	if _rebuild_queued:
		return
	_rebuild_queued = true
	call_deferred("_rebuild_lists")


func _sync_header() -> void:
	var node_id := AtelierSession.market_node_id
	if node_id.is_empty():
		node_id = "—"
	_title.text = "market · %s" % node_id
	var next_cost := MarketCatalog.refresh_cost(AtelierSession.market_refresh_count)
	_meta.text = (
		"gold %d   ·   refresh next $%d   ·   count %d   ·   mats %d   ·   bank %s"
		% [
			AtelierSession.gold,
			next_cost,
			AtelierSession.market_refresh_count,
			AtelierSession.stock.material_count() if AtelierSession.stock != null else 0,
			MarketCatalog.bank_id(),
		]
	)
	_note.text = AtelierSession.last_note
	if _refresh_btn != null:
		_refresh_btn.text = "Refresh $%d" % next_cost
		_refresh_btn.disabled = not AtelierSession.can_refresh_market()


func _rebuild_lists() -> void:
	_rebuild_queued = false
	_rebuild_shelf()
	_rebuild_deck()


func _rebuild_shelf() -> void:
	if _shelf_box == null:
		return
	for child in _shelf_box.get_children():
		child.queue_free()
	for item in AtelierSession.market_stock:
		if item is Dictionary:
			_shelf_box.add_child(_shelf_row(item as Dictionary))


func _rebuild_deck() -> void:
	if _deck_box == null:
		return
	for child in _deck_box.get_children():
		child.queue_free()
	if AtelierSession.stock == null:
		return
	for i in range(AtelierSession.stock.cards.size()):
		var card: HandCard = AtelierSession.stock.cards[i]
		if card == null or card.type != GameEnums.HandCardType.MATERIAL:
			continue
		_deck_box.add_child(_deck_row(i, card))


func _shelf_row(offer: Dictionary) -> Control:
	var mat_id := String(offer.get("mat_id", ""))
	var price := int(offer.get("price", 0))
	var qty := int(offer.get("qty_offered", 0))
	var own := 0
	if AtelierSession.stock != null:
		own = AtelierSession.stock.owned_count(mat_id)
	var row := _chip()
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	row.add_child(box)
	var lab := _label(
		"%s     $%d   own %d   qty %d" % [mat_id, price, own, qty],
		13,
		INK
	)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var buy := _btn("Buy", _on_buy.bind(mat_id))
	buy.disabled = not AtelierSession.can_buy_market(mat_id)
	box.add_child(buy)
	return row


func _deck_row(index: int, card: HandCard) -> Control:
	var row := _chip(card.is_enchanted())
	if card.is_enchanted():
		row.modulate = Color(1.08, 1.04, 0.82)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	row.add_child(box)
	if card.is_enchanted():
		var bar := ColorRect.new()
		bar.color = SHINE
		bar.custom_minimum_size = Vector2(0, 8)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(bar)
	var gain := MarketCatalog.sell_gain(card.id)
	var shiny_bit := ""
	if card.is_enchanted():
		shiny_bit = "   shiny %s" % card.mat_enchant_id
	var lab := _label("%s     sell +%d%s" % [card.id, gain, shiny_bit], 13, INK)
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 6)
	box.add_child(btns)
	var sell := _btn("Sell +%d" % gain, _on_sell.bind(index))
	sell.disabled = not AtelierSession.can_sell_market(index)
	btns.add_child(sell)
	for ench_id in MarketCatalog.enchant_ids():
		var fee := MarketCatalog.enchant_fee(String(ench_id))
		var label := "%s $%d" % [MarketCatalog.enchant_label(String(ench_id)), fee]
		var ench := _btn(label, _on_enchant.bind(index, String(ench_id)))
		ench.disabled = not AtelierSession.can_enchant_market(index, String(ench_id))
		btns.add_child(ench)
	return row


func _on_buy(mat_id: String) -> void:
	AtelierSession.buy_market(mat_id)


func _on_sell(index: int) -> void:
	AtelierSession.sell_market(index)


func _on_enchant(index: int, enchant_id: String) -> void:
	AtelierSession.enchant_market(index, enchant_id)


func _on_refresh() -> void:
	AtelierSession.refresh_market()


func _on_exit() -> void:
	AtelierSession.exit_market()


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
	sb.border_color = BORDER
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)
	return panel


func _chip(shiny: bool = false) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.35, 0.28, 0.1) if shiny else CHIP
	sb.set_corner_radius_all(6)
	sb.set_border_width_all(2 if shiny else 1)
	sb.border_color = GOLD if shiny else BORDER
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", sb)
	return panel


func _btn(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.pressed.connect(cb)
	return btn
