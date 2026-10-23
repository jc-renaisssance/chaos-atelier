class_name CraftTable
extends Control
## Dedicated stamina craft screen (docs/27, docs/34). Not the route-graph board.
## Shell v1: palette A, bust A, text-only planner chips. Theme and titles only.
## Regions stay: UPPER LEFT adventurer order detail, UPPER RIGHT zones, LOWER hand.
## CURRENT and POTENTIAL read the selected zone. They are not on the order column.
## Construction comes from the order, not a hand card.
## Plan is the syn-target planner. Brief is the guild-quest brief.
## Order-detail portrait socket (docs/29): one 96×96 bust left of the name and job.
## Name + job stay if the texture is missing. in_shop sits beside the bust.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const PORTRAIT_PX := 96
## Stamped busts (M1 art #54, M2 art #65). PNG-only; Godot imports locally.
## Job stubs have no file — resolve_id maps them onto these named rows.
const PORTRAITS := {
	"adv_halden_rook": preload("res://assets/adv/adv_halden_rook.png"),
	"adv_vex_bramble": preload("res://assets/adv/adv_vex_bramble.png"),
	"adv_solenne_ward": preload("res://assets/adv/adv_solenne_ward.png"),
	"adv_quill_lumen": preload("res://assets/adv/adv_quill_lumen.png"),
	"adv_neri_paleink": preload("res://assets/adv/adv_neri_paleink.png"),
	"adv_marrowveil": preload("res://assets/adv/adv_marrowveil.png"),
	"adv_kite_thornreel": preload("res://assets/adv/adv_kite_thornreel.png"),
	"adv_mask_circlet": preload("res://assets/adv/adv_mask_circlet.png"),
	"adv_whisper_hem": preload("res://assets/adv/adv_whisper_hem.png"),
	"adv_tide_glass": preload("res://assets/adv/adv_tide_glass.png"),
	"adv_brine_latch": preload("res://assets/adv/adv_brine_latch.png"),
	"adv_rime_peddler": preload("res://assets/adv/adv_rime_peddler.png"),
	"adv_vesper_cant": preload("res://assets/adv/adv_vesper_cant.png"),
	"adv_nyx_vellum": preload("res://assets/adv/adv_nyx_vellum.png"),
	"adv_orin_goldink": preload("res://assets/adv/adv_orin_goldink.png"),
	"adv_soot_cord": preload("res://assets/adv/adv_soot_cord.png"),
	"adv_tar_veil": preload("res://assets/adv/adv_tar_veil.png"),
	"adv_ashen_cowl": preload("res://assets/adv/adv_ashen_cowl.png"),
	"adv_harrow_gale": preload("res://assets/adv/adv_harrow_gale.png"),
	"adv_flint_rime": preload("res://assets/adv/adv_flint_rime.png"),
	"adv_lark_mute": preload("res://assets/adv/adv_lark_mute.png"),
	"adv_aurel_vow": preload("res://assets/adv/adv_aurel_vow.png"),
	"adv_clarion_mantle": preload("res://assets/adv/adv_clarion_mantle.png"),
	"adv_pell_white": preload("res://assets/adv/adv_pell_white.png"),
}

var _title: Label
var _order_portrait: TextureRect
var _shop_posture: TextureRect
var _order_title: Label
var _order_stats: Label
var _order_skill: Label
var _order_body: Label
var _tag_chips: Dictionary = {}
var _planner_list: Label
var _brief_body: Label
var _estimate_body: Label
var _stam_label: Label
var _stam_bar: ProgressBar
var _current_body: Label
var _potential_body: Label
var _zones: Array[CraftZone] = []
var _hand: HBoxContainer
var _stock: Label
var _dig_btn: Button
var _finish_btn: Button
var _continue_btn: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	set_process_input(true)
	AtelierSession.craft_started.connect(_refresh)
	AtelierSession.craft_changed.connect(_refresh)
	AtelierSession.piece_finished.connect(_on_piece)
	_refresh()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = ShellTheme.WOOD
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(header)
	_title = _label("Craft", ShellTheme.TITLE_PX, ShellTheme.GOLD)
	header.add_child(_title)
	var header_gap := Control.new()
	header_gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(header_gap)
	_stam_label = _label("Stamina  — / —", ShellTheme.BODY_PX, ShellTheme.INK)
	header.add_child(_stam_label)
	_stam_bar = ProgressBar.new()
	_stam_bar.min_value = 0
	_stam_bar.max_value = GameConstants.STAMINA_START
	_stam_bar.value = 0
	_stam_bar.custom_minimum_size = Vector2(168, 16)
	_stam_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ShellTheme.paint_stamina(_stam_bar)
	header.add_child(_stam_bar)

	var upper := HBoxContainer.new()
	upper.add_theme_constant_override("separation", 10)
	upper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(upper)

	var left := _panel()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.9
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	upper.add_child(left)
	var left_scroll := ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(left_scroll)
	var left_box := VBoxContainer.new()
	left_box.add_theme_constant_override("separation", 6)
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.add_child(left_box)
	left_box.add_child(_section("Order"))
	## Bust row: left bust, posture beside it, name and job on the right.
	## Gap inside this row is the only freestyle. Do not stack the bust above the text.
	var order_head := HBoxContainer.new()
	order_head.add_theme_constant_override("separation", 10)
	order_head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	order_head.alignment = BoxContainer.ALIGNMENT_BEGIN
	left_box.add_child(order_head)
	var bust_row := HBoxContainer.new()
	bust_row.add_theme_constant_override("separation", 8)
	bust_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	order_head.add_child(bust_row)
	_order_portrait = _portrait_socket()
	bust_row.add_child(_order_portrait)
	## in_shop beside the 96 bust, not instead of it. Missing file hides this slot.
	_shop_posture = _posture_socket()
	bust_row.add_child(_shop_posture)
	var order_text := VBoxContainer.new()
	order_text.add_theme_constant_override("separation", 4)
	order_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	order_head.add_child(order_text)
	_order_title = _label("No order", ShellTheme.NAME_PX, ShellTheme.GOLD)
	_order_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_text.add_child(_order_title)
	_order_stats = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_order_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_text.add_child(_order_stats)
	_order_skill = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_order_skill.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_order_skill)
	_order_body = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_order_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_order_body)
	left_box.add_child(_section("Plan"))
	var chip_row := HFlowContainer.new()
	chip_row.add_theme_constant_override("h_separation", 4)
	chip_row.add_theme_constant_override("v_separation", 4)
	left_box.add_child(chip_row)
	_tag_chips.clear()
	for tag in PlannerCatalog.MONOSTACK_TAGS:
		var chip := Button.new()
		var tag_name := String(tag)
		chip.text = tag_name
		## Text-only interim. No TextureRect icon socket. Icon chips are Later.
		ShellTheme.paint_button(chip, false)
		chip.pressed.connect(_on_planner_tag.bind(tag_name))
		chip_row.add_child(chip)
		_tag_chips[tag_name] = chip
	_planner_list = _label("?", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	_planner_list.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_planner_list)
	left_box.add_child(_section("Brief"))
	_brief_body = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_brief_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_brief_body)
	left_box.add_child(_section("Estimate"))
	_estimate_body = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_estimate_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_estimate_body)

	var right := _panel()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.1
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	upper.add_child(right)
	var right_box := VBoxContainer.new()
	right_box.add_theme_constant_override("separation", 6)
	right.add_child(right_box)
	right_box.add_child(_section("Zones"))
	var zone_row := HBoxContainer.new()
	zone_row.add_theme_constant_override("separation", 8)
	zone_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zone_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_box.add_child(zone_row)
	_zones.clear()
	for i in range(GameConstants.ZONE_COUNT_MAX):
		var zone := CraftZone.new()
		zone.zone_index = i + 1
		zone.zone_selected.connect(_on_zone_selected)
		zone.card_dropped.connect(_on_card_dropped)
		zone_row.add_child(zone)
		_zones.append(zone)
	var readout := HBoxContainer.new()
	readout.add_theme_constant_override("separation", 8)
	right_box.add_child(readout)
	var current_panel := _panel()
	current_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	readout.add_child(current_panel)
	var current_box := VBoxContainer.new()
	current_box.add_theme_constant_override("separation", 4)
	current_panel.add_child(current_box)
	current_box.add_child(_section("Current"))
	_current_body = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_current_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_box.add_child(_current_body)
	var potential_panel := _panel()
	potential_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	readout.add_child(potential_panel)
	var potential_box := VBoxContainer.new()
	potential_box.add_theme_constant_override("separation", 4)
	potential_panel.add_child(potential_box)
	potential_box.add_child(_section("Potential"))
	_potential_body = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_potential_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	potential_box.add_child(_potential_body)

	var lower := _panel()
	lower.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(lower)
	var lower_box := VBoxContainer.new()
	lower_box.add_theme_constant_override("separation", 8)
	lower.add_child(lower_box)
	var lower_row := HBoxContainer.new()
	lower_row.add_theme_constant_override("separation", 12)
	lower_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lower_box.add_child(lower_row)
	var hand_col := VBoxContainer.new()
	hand_col.add_theme_constant_override("separation", 6)
	hand_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lower_row.add_child(hand_col)
	hand_col.add_child(_section("Hand"))
	_hand = HBoxContainer.new()
	_hand.add_theme_constant_override("separation", 8)
	_hand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_col.add_child(_hand)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	actions.alignment = BoxContainer.ALIGNMENT_END
	lower_row.add_child(actions)
	_dig_btn = _btn("Dig · 2", _on_dig, false)
	actions.add_child(_dig_btn)
	_finish_btn = _btn("Finish", _on_finish, true)
	actions.add_child(_finish_btn)
	_continue_btn = _btn("Return", _on_continue, false)
	actions.add_child(_continue_btn)
	_stock = _label("", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	lower_box.add_child(_stock)


func _portrait_socket() -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(PORTRAIT_PX, PORTRAIT_PX)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	icon.visible = false
	return icon


func _bind_order_portrait(adv_id: String) -> void:
	## Alias resolves to the named file (adv_knight → adv_halden_rook). No stub PNG.
	var named := AdventurerCatalog.resolve_id(adv_id)
	var found: Variant = PORTRAITS.get(named)
	var tex: Texture2D = found as Texture2D
	_order_portrait.texture = tex
	## Missing preload → hide the socket. Display name + job stay on the panel.
	_order_portrait.visible = tex != null
	_bind_in_shop(adv_id)


func _posture_socket() -> TextureRect:
	var icon := TextureRect.new()
	icon.name = "InShopPosture"
	icon.custom_minimum_size = Vector2(PostureSocket.DISPLAY_PX, PostureSocket.DISPLAY_PX)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	icon.visible = false
	return icon


func _bind_in_shop(adv_id: String) -> void:
	## Socket A in_shop. Hide when the still is missing. Never substitute the 96 bust.
	var still: Dictionary = PostureSocket.shop_still(adv_id)
	var show := not bool(still.get("hidden", true))
	_shop_posture.visible = show
	if not show:
		_shop_posture.texture = null
		return
	_shop_posture.texture = still.get("texture") as Texture2D


func _section(text: String) -> Label:
	return _label(text, ShellTheme.SECTION_PX, ShellTheme.GOLD)


func _label(text: String, size: int, color: Color) -> Label:
	return ShellTheme.label(text, size, color)


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	ShellTheme.paint_panel(panel, ShellTheme.frame())
	return panel


func _btn(text: String, cb: Callable, primary: bool) -> Button:
	var btn := Button.new()
	btn.text = text
	ShellTheme.paint_button(btn, primary)
	btn.pressed.connect(cb)
	return btn


func refresh() -> void:
	_refresh()


func _input(event: InputEvent) -> void:
	if not visible or not AtelierSession.craft_open:
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed or key.echo:
			return
		match key.keycode:
			KEY_1, KEY_KP_1:
				_play_slot(0)
				get_viewport().set_input_as_handled()
			KEY_2, KEY_KP_2:
				_play_slot(1)
				get_viewport().set_input_as_handled()
			KEY_3, KEY_KP_3:
				_play_slot(2)
				get_viewport().set_input_as_handled()
			KEY_4, KEY_KP_4:
				_play_slot(3)
				get_viewport().set_input_as_handled()
			KEY_5, KEY_KP_5:
				_play_slot(4)
				get_viewport().set_input_as_handled()
			KEY_D:
				_on_dig()
				get_viewport().set_input_as_handled()


func _refresh() -> void:
	var session: CraftStaminaSession = AtelierSession.craft_session
	var order: ClientOrder = AtelierSession.craft_order
	_title.text = "Craft"
	if session == null or order == null:
		_bind_order_portrait("")
		_order_title.text = "No session."
		_order_stats.text = ""
		_order_skill.text = ""
		_order_body.text = "Leave the route graph to sew an order here."
		_planner_list.text = "?"
		_brief_body.text = ""
		_estimate_body.text = ""
		_stam_label.text = "Stamina  — / —"
		_stam_bar.max_value = GameConstants.STAMINA_START
		_stam_bar.value = 0
		_stock.text = ""
		_dig_btn.disabled = true
		_finish_btn.disabled = true
		_continue_btn.visible = false
		_clear_hand()
		for zone in _zones:
			zone.visible = false
		_refresh_planner_chips(null)
		return
	_bind_order_portrait(AdventurerCatalog.order_adventurer_id(order))
	_fill_order(session, order)
	_stam_label.text = "Stamina  %d / %d" % [session.stamina_remaining, session.stamina_start]
	_stam_bar.max_value = session.stamina_start
	_stam_bar.value = session.stamina_remaining
	_rebuild_zones(session)
	_rebuild_hand(session)
	_refresh_readout(session)
	_stock.text = "Draw %d  ·  Discard %d" % [session.draw_pile.size(), session.discard_pile.size()]
	var busy := session.is_finished() or AtelierSession.order_craft_done
	_dig_btn.disabled = busy or not CraftRules.can_dig(session, AtelierSession.stock)
	_finish_btn.disabled = busy
	## Gate A owns the exit while a playback or piece report is up.
	_continue_btn.visible = (
		AtelierSession.order_craft_done
		and not AtelierSession.playback_open
		and not AtelierSession.piece_report_open
	)
	if order.mission_kind == GameEnums.MissionKind.BOSS:
		_continue_btn.text = "Resolve the fight"
	else:
		_continue_btn.text = "Return"
	_refresh_planner()
	_refresh_brief_and_estimate(order)


func _fill_order(session: CraftStaminaSession, order: ClientOrder) -> void:
	var adv_id := AdventurerCatalog.order_adventurer_id(order)
	var person := AdventurerCatalog.row_resolved(adv_id)
	if not person.is_empty():
		_order_title.text = "%s  ·  %s" % [
			String(person.get("display", adv_id)),
			BossClientCatalog.display_name(String(person.get("job_id", ""))),
		]
		_order_stats.text = AdventurerCatalog.stats_line(adv_id)
		_order_skill.text = AdventurerCatalog.skill_panel_line(adv_id)
	else:
		_order_title.text = ScheduleCatalog.order_title(order)
		_order_stats.text = ""
		_order_skill.text = ""
	var listed: PackedStringArray = PackedStringArray()
	for i in range(session.construction_ids.size()):
		var con_id := session.construction_ids[i]
		listed.append("%d %s" % [i + 1, CraftCatalog.construction_name(con_id)])
	var taste := AdventurerCatalog.requirement_taste(adv_id)
	if taste.is_empty():
		taste = ", ".join(order.requirement_tags) if order.requirement_tags.size() > 0 else "—"
	var lines: PackedStringArray = PackedStringArray()
	if order.mission_kind == GameEnums.MissionKind.BOSS:
		var boss_id := AtelierSession.brief_threat_id(order)
		var boss_name := ScheduleCatalog.boss_title(boss_id)
		if boss_name.is_empty():
			boss_name = ThreatCatalog.display_name(boss_id)
		if not boss_name.is_empty():
			lines.append("Fighting %s" % boss_name)
	if listed.size() > 0:
		lines.append("Listed  %s" % "   ·   ".join(listed))
	lines.append("Taste  %s" % taste)
	_order_body.text = "\n".join(lines)


func _rebuild_zones(session: CraftStaminaSession) -> void:
	var locked := session.is_finished() or AtelierSession.order_craft_done
	for i in range(_zones.size()):
		var zone: CraftZone = _zones[i]
		var zone_index := i + 1
		if zone_index > session.zone_count:
			zone.visible = false
			continue
		zone.visible = true
		zone.bind(
			zone_index,
			session.construction_id_for_zone(zone_index),
			session.selected_zone_index == zone_index,
			session.cards_for_zone(zone_index),
			locked
		)


func _clear_hand() -> void:
	for child in _hand.get_children():
		child.queue_free()


func _rebuild_hand(session: CraftStaminaSession) -> void:
	_clear_hand()
	var locked := session.is_finished() or AtelierSession.order_craft_done
	var slots := session.hand_size
	if slots < GameConstants.HAND_SIZE:
		slots = GameConstants.HAND_SIZE
	if session.hand.size() > slots:
		slots = session.hand.size()
	for i in range(slots):
		var slot := CraftHandSlot.new()
		_hand.add_child(slot)
		if i < session.hand.size():
			var card: HandCard = session.hand[i]
			var cost := CraftCatalog.play_cost(card, AtelierSession.next_mat_free)
			slot.bind(
				i,
				card,
				cost,
				locked,
				CraftRules.can_play(session, i, AtelierSession.next_mat_free, session.selected_zone_index)
			)
			slot.slot_played.connect(_on_play)
		else:
			slot.bind_empty(i)


func _refresh_readout(session: CraftStaminaSession) -> void:
	var preview := CraftReadout.preview(session, session.selected_zone_index)
	_current_body.text = CraftReadout.current_line(preview)
	var unlocked := AtelierSession.unlocked_outlooks
	var open := CraftReadout.potential_unlocked(preview, unlocked)
	_potential_body.text = CraftReadout.potential_label(preview, unlocked)
	_potential_body.add_theme_color_override("font_color", ShellTheme.INK if open else ShellTheme.MUTED)


func _on_piece(_result: Dictionary) -> void:
	_refresh()


func _on_planner_tag(tag: String) -> void:
	AtelierSession.click_planner_tag(tag)


func _refresh_planner_chips(planned: Variant) -> void:
	for tag in _tag_chips.keys():
		var chip: Button = _tag_chips[tag]
		chip.text = PlannerCatalog.chip_caption(String(tag), planned)


func _refresh_planner() -> void:
	var planned: Variant = AtelierSession.planned_build
	_refresh_planner_chips(planned)
	var lines := PlannerCatalog.list_lines(AtelierSession.profile.unlocked_builds)
	if lines.size() == 1 and lines[0] == "?":
		_planner_list.text = "?"
	else:
		_planner_list.text = "  |  ".join(lines)


func _gate_text(value: Variant) -> String:
	if value == null:
		return EstimateLaw.LOCKED
	if value is String:
		return String(value)
	if value is bool:
		return "fires" if bool(value) else "does not"
	if value is Array:
		var bits: PackedStringArray = PackedStringArray()
		for item in value:
			bits.append(str(item))
		if bits.is_empty():
			return "(none)"
		return ", ".join(bits)
	return str(value)


func _refresh_brief_and_estimate(order: ClientOrder) -> void:
	var threat_id := AtelierSession.brief_threat_id(order)
	if threat_id.is_empty():
		_brief_body.text = "No guild-quest brief on this order (prep has no threat)."
		_estimate_body.text = "Estimate waits on a brief + a planned chip."
		return
	var seen := AtelierSession.profile.enemy_seen(threat_id)
	if not ThreatCatalog.is_boss(threat_id):
		seen = true
	var fought := AtelierSession.profile.enemy_fought(threat_id)
	var name_line := ThreatCatalog.display_name(threat_id) if seen else EstimateLaw.LOCKED
	var env := ThreatCatalog.environment(threat_id) if seen else EstimateLaw.LOCKED
	if seen and env.is_empty():
		env = "—"
	var flavor := ThreatCatalog.flavor(threat_id) if seen else EstimateLaw.LOCKED
	if seen and flavor.is_empty():
		flavor = "—"
	var favor_line := EstimateLaw.LOCKED
	var punish_line := EstimateLaw.LOCKED
	if fought:
		favor_line = ", ".join(ThreatCatalog.favor_tags(threat_id))
		punish_line = ", ".join(ThreatCatalog.punish_tags(threat_id))
		if favor_line.is_empty():
			favor_line = "(none)"
		if punish_line.is_empty():
			punish_line = "(none)"
	_brief_body.text = (
		"threat %s   ·   name %s   ·   env %s   ·   flavor %s   ·   favor %s   ·   punish %s   ·   seen %s   ·   fought %s"
		% [
			threat_id,
			name_line,
			env,
			flavor,
			favor_line,
			punish_line,
			"yes" if AtelierSession.profile.enemy_seen(threat_id) else "no",
			"yes" if fought else "no",
		]
	)
	var adv_id := AdventurerCatalog.order_adventurer_id(order)
	var raw := EstimateLaw.compute(
		AdventurerCatalog.stats_dict(adv_id),
		AdventurerCatalog.skill_id(adv_id),
		AtelierSession.planned_build,
		order.construction_ids,
		threat_id
	)
	var plan: Variant = PlannerCatalog.dup_plan(AtelierSession.planned_build)
	var build_unlocked := false
	if plan is Dictionary:
		var row: Dictionary = plan
		build_unlocked = AtelierSession.profile.has_build(
			String(row.get("outlook_id", "")),
			String(row.get("tier", ""))
		)
	var gated := EstimateLaw.gated_dump(raw, AtelierSession.planned_build, build_unlocked, fought)
	var skill_line := AdventurerCatalog.skill_panel_line(adv_id)
	var skill_txt := _gate_text(gated.get("estimate_skill_fired", EstimateLaw.LOCKED))
	if skill_txt != EstimateLaw.LOCKED and not skill_line.is_empty():
		skill_txt = "%s  ·  %s" % [skill_txt, skill_line]
	## Weight integers stay in EstimateLaw and the test log. They are not on this label.
	_estimate_body.text = (
		"planned %s   ·   favor hits %s   ·   punish hits %s   ·   skill %s   ·   neg %s   ·   band %s"
		% [
			_gate_text(gated.get("planned_outlook", EstimateLaw.LOCKED)),
			_gate_text(gated.get("estimate_favor_hits", EstimateLaw.LOCKED)),
			_gate_text(gated.get("estimate_punish_hits", EstimateLaw.LOCKED)),
			skill_txt,
			_gate_text(gated.get("estimate_neg_warnings", EstimateLaw.LOCKED)),
			_gate_text(gated.get("estimate_band", EstimateLaw.LOCKED)),
		]
	)


func _play_slot(index: int) -> void:
	if AtelierSession.order_craft_done:
		return
	AtelierSession.play_hand(index)


func _on_play(index: int) -> void:
	AtelierSession.play_hand(index)


func _on_zone_selected(zone_index: int) -> void:
	AtelierSession.select_zone(zone_index)


func _on_card_dropped(hand_index: int, zone_index: int) -> void:
	AtelierSession.play_hand(hand_index, zone_index)


func _on_dig() -> void:
	AtelierSession.dig()


func _on_finish() -> void:
	AtelierSession.finish_early()


func _on_continue() -> void:
	AtelierSession.continue_after_piece()
