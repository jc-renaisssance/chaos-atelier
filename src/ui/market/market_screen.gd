class_name MarketScreen
extends Control
## Ugly M2 market shell — Materials / Staffs / Skills / Gear (docs/32).
## Staffs, Skills, and Gear shelves show stamped assets/m2-market icons.
## Skill deck rows stay sk_* text. Enchant + refresh stay materials-only.
## Shiny tint stays on enchanted mats.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)
const SHINE := Color(0.95, 0.82, 0.22, 0.38)
const CHIP := Color(0.227, 0.173, 0.094)
const TAB_ON := Color(0.35, 0.28, 0.1)
const SHELF_ICON_PX := 96
## Stamped Pro Flash icons (staff/artifact #48, skills #52). PNG-only; Godot imports locally.
const SHELF_ICONS := {
	"staff_apprentice": preload("res://assets/m2-market/staff_apprentice.png"),
	"staff_rune_desk": preload("res://assets/m2-market/staff_rune_desk.png"),
	"staff_loom_pair": preload("res://assets/m2-market/staff_loom_pair.png"),
	"staff_third_seam": preload("res://assets/m2-market/staff_third_seam.png"),
	"staff_rune_pair": preload("res://assets/m2-market/staff_rune_pair.png"),
	"artifact_coin_purse": preload("res://assets/m2-market/artifact_coin_purse.png"),
	"artifact_ledger_clip": preload("res://assets/m2-market/artifact_ledger_clip.png"),
	"artifact_pack_strap": preload("res://assets/m2-market/artifact_pack_strap.png"),
	"artifact_needle_tin": preload("res://assets/m2-market/artifact_needle_tin.png"),
	"artifact_wagon_hook": preload("res://assets/m2-market/artifact_wagon_hook.png"),
	"artifact_stamp_case": preload("res://assets/m2-market/artifact_stamp_case.png"),
	"artifact_road_charm": preload("res://assets/m2-market/artifact_road_charm.png"),
	"artifact_oil_rag": preload("res://assets/m2-market/artifact_oil_rag.png"),
	"sk_next_mat_free": preload("res://assets/m2-market/sk_next_mat_free.png"),
	"sk_touch_up": preload("res://assets/m2-market/sk_touch_up.png"),
	"sk_steady_hand": preload("res://assets/m2-market/sk_steady_hand.png"),
	"sk_metal_str_double": preload("res://assets/m2-market/sk_metal_str_double.png"),
	"sk_wild_to_earth": preload("res://assets/m2-market/sk_wild_to_earth.png"),
	"sk_deep_dig": preload("res://assets/m2-market/sk_deep_dig.png"),
}

var _title: Label
var _meta: Label
var _note: Label
var _tab_btns: Dictionary = {}
var _shelf_caption: Label
var _deck_caption: Label
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
	_note = _label("Materials | Staffs | Skills | Gear", 13, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_note)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	root.add_child(tabs)
	_tab_btns.clear()
	for tab in MarketCatalog.tab_ids():
		var tab_id := String(tab)
		var btn := _btn(_tab_label(tab_id), _on_tab.bind(tab_id))
		tabs.add_child(btn)
		_tab_btns[tab_id] = btn

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
	_shelf_caption = _caption("SHELF")
	shelf_wrap.add_child(_shelf_caption)
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
	_deck_caption = _caption("DECK")
	deck_wrap.add_child(_deck_caption)
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
	var hint := _label("Refresh / Enchant = materials only. Exit resolves the day.", 12, MUTED)
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
	var tab := AtelierSession.market_tab
	_meta.text = (
		"gold %d   ·   refresh next $%d   ·   count %d   ·   mats %d   ·   skills %d   ·   max_m %d  max_r %d   ·   gear %d/2"
		% [
			AtelierSession.gold,
			next_cost,
			AtelierSession.market_refresh_count,
			AtelierSession.stock.material_count() if AtelierSession.stock != null else 0,
			AtelierSession.stock.skill_count() if AtelierSession.stock != null else 0,
			AtelierSession.live_max_materials(),
			AtelierSession.live_max_runes(),
			AtelierSession.artifact_equipped_ids.size(),
		]
	)
	_note.text = AtelierSession.last_note
	if _refresh_btn != null:
		_refresh_btn.text = "Refresh $%d" % next_cost
		_refresh_btn.disabled = not AtelierSession.can_refresh_market()
		_refresh_btn.visible = tab == GameConstants.MARKET_TAB_MATERIALS
	for tab_id in _tab_btns.keys():
		var btn: Button = _tab_btns[tab_id]
		var on := String(tab_id) == tab
		btn.disabled = on
		btn.modulate = Color(1.08, 1.04, 0.82) if on else Color.WHITE


func _rebuild_lists() -> void:
	_rebuild_queued = false
	_rebuild_shelf()
	_rebuild_deck()


func _rebuild_shelf() -> void:
	if _shelf_box == null:
		return
	for child in _shelf_box.get_children():
		child.queue_free()
	var tab := AtelierSession.market_tab
	match tab:
		GameConstants.MARKET_TAB_STAFFS:
			_shelf_caption.text = "SHELF  ·  market_staff_bank_c1  ·  unique owned"
			for item in AtelierSession.market_staff_stock:
				if item is Dictionary:
					_shelf_box.add_child(_staff_shelf_row(item as Dictionary))
		GameConstants.MARKET_TAB_SKILLS:
			_shelf_caption.text = "SHELF  ·  market_skill_bank_c1  ·  buy into own_basic kit"
			for item in AtelierSession.market_skill_stock:
				if item is Dictionary:
					_shelf_box.add_child(_skill_shelf_row(item as Dictionary))
		GameConstants.MARKET_TAB_GEAR:
			_shelf_caption.text = "SHELF  ·  market_artifact_bank_c1  ·  unique owned"
			for item in AtelierSession.market_artifact_stock:
				if item is Dictionary:
					_shelf_box.add_child(_artifact_shelf_row(item as Dictionary))
		_:
			_shelf_caption.text = "SHELF  ·  buy from market_bank_c1"
			for item in AtelierSession.market_stock:
				if item is Dictionary:
					_shelf_box.add_child(_mat_shelf_row(item as Dictionary))


func _rebuild_deck() -> void:
	if _deck_box == null:
		return
	for child in _deck_box.get_children():
		child.queue_free()
	var tab := AtelierSession.market_tab
	match tab:
		GameConstants.MARKET_TAB_STAFFS:
			var equipped := AtelierSession.staff_equipped_id
			var eq_bit := equipped if not equipped.is_empty() else "none"
			_deck_caption.text = (
				"KIT  equipped: %s    max_m %d  max_r %d"
				% [eq_bit, AtelierSession.live_max_materials(), AtelierSession.live_max_runes()]
			)
			if AtelierSession.staff_owned.is_empty():
				_deck_box.add_child(_label("No staff owned.", 13, MUTED))
			for staff_id in AtelierSession.staff_owned:
				_deck_box.add_child(_staff_kit_row(String(staff_id)))
		GameConstants.MARKET_TAB_SKILLS:
			_deck_caption.text = "DECK (skills)  ·  sell copies  ·  no equip"
			if AtelierSession.stock == null:
				return
			var any := false
			for i in range(AtelierSession.stock.cards.size()):
				var card: HandCard = AtelierSession.stock.cards[i]
				if card == null or card.type != GameEnums.HandCardType.SKILL:
					continue
				any = true
				_deck_box.add_child(_skill_deck_row(i, card))
			if not any:
				_deck_box.add_child(_label("No skill cards in the run kit.", 13, MUTED))
		GameConstants.MARKET_TAB_GEAR:
			_deck_caption.text = "KIT  slots %d/2" % AtelierSession.artifact_equipped_ids.size()
			if AtelierSession.artifact_owned.is_empty():
				_deck_box.add_child(_label("No artifacts owned.", 13, MUTED))
			for artifact_id in AtelierSession.artifact_owned:
				_deck_box.add_child(_artifact_kit_row(String(artifact_id)))
		_:
			_deck_caption.text = "DECK  ·  sell / enchant owned mat_*"
			if AtelierSession.stock == null:
				return
			for i in range(AtelierSession.stock.cards.size()):
				var card: HandCard = AtelierSession.stock.cards[i]
				if card == null or card.type != GameEnums.HandCardType.MATERIAL:
					continue
				_deck_box.add_child(_mat_deck_row(i, card))


func _mat_shelf_row(offer: Dictionary) -> Control:
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
	var buy := _btn("Buy", _on_buy_mat.bind(mat_id))
	buy.disabled = not AtelierSession.can_buy_market(mat_id)
	box.add_child(buy)
	return row


func _mat_deck_row(index: int, card: HandCard) -> Control:
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
	var gain := AtelierSession.material_sell_gain(card.id)
	var shiny_bit := ""
	if card.is_enchanted():
		shiny_bit = "   shiny %s" % card.mat_enchant_id
	var lab := _label("%s     sell +%d%s" % [card.id, gain, shiny_bit], 13, INK)
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 6)
	box.add_child(btns)
	var sell := _btn("Sell +%d" % gain, _on_sell_mat.bind(index))
	sell.disabled = not AtelierSession.can_sell_market(index)
	btns.add_child(sell)
	for ench_id in MarketCatalog.enchant_ids():
		var fee := MarketCatalog.enchant_fee(String(ench_id))
		var label := "%s $%d" % [MarketCatalog.enchant_label(String(ench_id)), fee]
		var ench := _btn(label, _on_enchant.bind(index, String(ench_id)))
		ench.disabled = not AtelierSession.can_enchant_market(index, String(ench_id))
		btns.add_child(ench)
	return row


func _staff_shelf_row(offer: Dictionary) -> Control:
	var staff_id := String(offer.get("staff_id", ""))
	var price := int(offer.get("price", 0))
	var row := _chip()
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	row.add_child(box)
	box.add_child(_shelf_icon(staff_id))
	var own_bit := "owned" if AtelierSession.owns_staff(staff_id) else "own 0"
	var lab := _label(
		"%s     $%d   %s   %s" % [staff_id, price, MarketCatalog.staff_delta_bit(staff_id), own_bit],
		13,
		INK
	)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var buy := _btn("Buy", _on_buy_staff.bind(staff_id))
	buy.disabled = not AtelierSession.can_buy_staff(staff_id)
	box.add_child(buy)
	return row


func _staff_kit_row(staff_id: String) -> Control:
	var equipped := AtelierSession.staff_equipped_id == staff_id
	var row := _chip(equipped)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	row.add_child(box)
	var mark := "equipped" if equipped else "owned"
	var gain := MarketCatalog.kit_sell_gain(MarketCatalog.staff_price(staff_id))
	var lab := _label(
		"%s     %s   %s   sell +%d" % [staff_id, mark, MarketCatalog.staff_delta_bit(staff_id), gain],
		13,
		INK
	)
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 6)
	box.add_child(btns)
	if equipped:
		var uneq := _btn("Unequip", _on_unequip_staff)
		uneq.disabled = not AtelierSession.can_unequip_staff()
		btns.add_child(uneq)
	else:
		var eq := _btn("Equip", _on_equip_staff.bind(staff_id))
		eq.disabled = not AtelierSession.can_equip_staff(staff_id)
		btns.add_child(eq)
	var sell := _btn("Sell +%d" % gain, _on_sell_staff.bind(staff_id))
	sell.disabled = not AtelierSession.can_sell_staff(staff_id)
	btns.add_child(sell)
	return row


func _skill_shelf_row(offer: Dictionary) -> Control:
	var skill_id := String(offer.get("skill_id", ""))
	var price := int(offer.get("price", 0))
	var own := 0
	if AtelierSession.stock != null:
		own = AtelierSession.stock.owned_count(skill_id)
	var row := _chip()
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	row.add_child(box)
	box.add_child(_shelf_icon(skill_id))
	var lab := _label(
		"%s     $%d   own %d   %s" % [skill_id, price, own, CraftCatalog.skill_blurb(skill_id)],
		13,
		INK
	)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var buy := _btn("Buy", _on_buy_skill.bind(skill_id))
	buy.disabled = not AtelierSession.can_buy_skill(skill_id)
	box.add_child(buy)
	return row


func _skill_deck_row(index: int, card: HandCard) -> Control:
	var row := _chip()
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	row.add_child(box)
	var gain := MarketCatalog.kit_sell_gain(MarketCatalog.skill_price(card.id))
	var lab := _label("%s     sell +%d" % [card.id, gain], 13, INK)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var sell := _btn("Sell +%d" % gain, _on_sell_skill.bind(index))
	sell.disabled = not AtelierSession.can_sell_skill(index)
	box.add_child(sell)
	return row


func _artifact_shelf_row(offer: Dictionary) -> Control:
	var artifact_id := String(offer.get("artifact_id", ""))
	var price := int(offer.get("price", 0))
	var row := _chip()
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	row.add_child(box)
	box.add_child(_shelf_icon(artifact_id))
	var own_bit := "owned" if AtelierSession.owns_artifact(artifact_id) else "own 0"
	var lab := _label(
		"%s     $%d   %s   %s" % [artifact_id, price, MarketCatalog.artifact_label(artifact_id), own_bit],
		13,
		INK
	)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var buy := _btn("Buy", _on_buy_artifact.bind(artifact_id))
	buy.disabled = not AtelierSession.can_buy_artifact(artifact_id)
	box.add_child(buy)
	return row


func _artifact_kit_row(artifact_id: String) -> Control:
	var equipped := AtelierSession.artifact_is_equipped(artifact_id)
	var row := _chip(equipped)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	row.add_child(box)
	var mark := "equipped" if equipped else "owned"
	var gain := MarketCatalog.kit_sell_gain(MarketCatalog.artifact_price(artifact_id))
	var lab := _label(
		"%s     %s   %s   sell +%d" % [artifact_id, mark, MarketCatalog.artifact_label(artifact_id), gain],
		13,
		INK
	)
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lab)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 6)
	box.add_child(btns)
	if equipped:
		var uneq := _btn("Unequip", _on_unequip_artifact.bind(artifact_id))
		uneq.disabled = not AtelierSession.can_unequip_artifact(artifact_id)
		btns.add_child(uneq)
	else:
		var eq := _btn("Equip", _on_equip_artifact.bind(artifact_id))
		eq.disabled = not AtelierSession.can_equip_artifact(artifact_id)
		btns.add_child(eq)
	var sell := _btn("Sell +%d" % gain, _on_sell_artifact.bind(artifact_id))
	sell.disabled = not AtelierSession.can_sell_artifact(artifact_id)
	btns.add_child(sell)
	return row


func _tab_label(tab: String) -> String:
	match tab:
		GameConstants.MARKET_TAB_STAFFS:
			return "Staffs"
		GameConstants.MARKET_TAB_SKILLS:
			return "Skills"
		GameConstants.MARKET_TAB_GEAR:
			return "Gear"
		_:
			return "Materials"


func _on_tab(tab: String) -> void:
	AtelierSession.set_market_tab(tab)


func _on_buy_mat(mat_id: String) -> void:
	AtelierSession.buy_market(mat_id)


func _on_sell_mat(index: int) -> void:
	AtelierSession.sell_market(index)


func _on_enchant(index: int, enchant_id: String) -> void:
	AtelierSession.enchant_market(index, enchant_id)


func _on_buy_staff(staff_id: String) -> void:
	AtelierSession.buy_staff(staff_id)


func _on_sell_staff(staff_id: String) -> void:
	AtelierSession.sell_staff(staff_id)


func _on_equip_staff(staff_id: String) -> void:
	AtelierSession.equip_staff(staff_id)


func _on_unequip_staff() -> void:
	AtelierSession.unequip_staff()


func _on_buy_skill(skill_id: String) -> void:
	AtelierSession.buy_skill(skill_id)


func _on_sell_skill(index: int) -> void:
	AtelierSession.sell_skill(index)


func _on_buy_artifact(artifact_id: String) -> void:
	AtelierSession.buy_artifact(artifact_id)


func _on_sell_artifact(artifact_id: String) -> void:
	AtelierSession.sell_artifact(artifact_id)


func _on_equip_artifact(artifact_id: String) -> void:
	AtelierSession.equip_artifact(artifact_id)


func _on_unequip_artifact(artifact_id: String) -> void:
	AtelierSession.unequip_artifact(artifact_id)


func _on_refresh() -> void:
	AtelierSession.refresh_market()


func _on_exit() -> void:
	AtelierSession.exit_market()


func _shelf_icon(item_id: String) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(SHELF_ICON_PX, SHELF_ICON_PX)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var found: Variant = SHELF_ICONS.get(item_id)
	var tex: Texture2D = found as Texture2D
	icon.texture = tex
	return icon


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
	sb.bg_color = TAB_ON if shiny else CHIP
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
