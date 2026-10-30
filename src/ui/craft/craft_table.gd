class_name CraftTable
extends Control
## Dedicated stamina craft screen (docs/27, docs/34, docs/36). Not the route-graph board.
## Shell v1: palette A, bust A. Planner chips are the 16 stamped icons.
## Hand A′ arc, Drag A, Drop A. Mat faces load from res://assets/mat/<id>.png.
## Current and Potential take the same Soft outlook png when that slot is unlocked.
## Locked outlooks hide both. Paths are res://assets/outlook/ (docs/35 ×28).
## A mat png is not an outlook. Regions stay: UPPER LEFT order, UPPER RIGHT zones, LOWER hand.
## CURRENT and POTENTIAL read the selected zone. They are not on the order column.
## Construction comes from the order, not a hand card.
## Plan is the syn-target planner. Brief is the guild-quest brief.
## Order-detail portrait socket (docs/29): one 96×96 bust left of the name and job.
## Name + job stay if the texture is missing. in_shop sits beside the bust.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const PlayerChrome := preload("res://src/ui/player_chrome.gd")
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
var _brief_header: Label
var _brief_body: Label
var _estimate_header: Label
var _estimate_body: Label
var _stam_label: Label
var _stam_bar: ProgressBar
var _current_body: Label
var _current_art: TextureRect
var _potential_body: Label
var _potential_art: TextureRect
var _zones: Array[CraftZone] = []
var _hand_fan: CraftHandFan
var _overlay: Control
var _stock: Label
var _dig_btn: Button
var _finish_btn: Button
var _continue_btn: Button

enum _Phase { IDLE, DRAG, SETTLE, SNAP, DIG }

## docs/36 Drag A. The follow clamp is drag motion. It is not the fan step.
const _CLICK_DRAG_PX := 8.0
const _PICKUP_SEC := 0.12
const _PICKUP_SCALE := 1.12
const _PICKUP_TILT_DEG := 6.0
const _FOLLOW_ORIGIN_PX := 24.0
const _FOLLOW_TILT_PER_PX := 0.04
const _FOLLOW_TILT_LIMIT_DEG := 8.0
const _DROP_SEC := 0.16
const _CANCEL_SEC := 0.18
const _FLY_SEC := 0.20
const _GHOST_ALPHA := 0.35
const _DUMP_DROP_PX := 48.0
const _DUMP_SEC := 0.20
const _DUMP_STAGGER_SEC := 0.03
const _DEAL_FROM_Y := 24.0
const _DEAL_FROM_SCALE := 0.9
const _DEAL_SEC := 0.20
const _DEAL_STAGGER_SEC := 0.04

var _phase: _Phase = _Phase.IDLE
var _armed: CraftHandSlot
var _press_global: Vector2 = Vector2.ZERO
var _ghost: CraftHandSlot
var _follower: Control
var _pickup_tween: Tween
var _motion_tween: Tween
var _pickup_done: bool = false
var _vel_x: float = 0.0
var _motion_this_frame: bool = false
var _reflow: bool = false
var _deal_in: bool = false
var _motion_left: int = 0
var _settle_zone: CraftZone
var _settle_sec: float = 0.0
var _aim_tries: int = 0
var _settle_instance: int = 0
var _settle_gen: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	set_process_input(true)
	set_process(true)
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
		chip.text = ""
		chip.custom_minimum_size = Vector2(PlannerChipArt.PX + 8, PlannerChipArt.PX + 8)
		chip.clip_contents = false
		ShellTheme.paint_button(chip, false)
		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.custom_minimum_size = Vector2(PlannerChipArt.PX, PlannerChipArt.PX)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = PlannerChipArt.texture_for(tag_name)
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		chip.add_child(icon)
		chip.pressed.connect(_on_planner_tag.bind(tag_name))
		chip_row.add_child(chip)
		_tag_chips[tag_name] = chip
	_planner_list = _label("?", ShellTheme.CAPTION_PX, ShellTheme.MUTED)
	_planner_list.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_planner_list)
	_brief_header = _section("Brief")
	left_box.add_child(_brief_header)
	_brief_body = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_brief_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_brief_body)
	_estimate_header = _section("Estimate")
	left_box.add_child(_estimate_header)
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
	_current_art = _outlook_socket()
	current_box.add_child(_current_art)
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
	_potential_art = _outlook_socket()
	potential_box.add_child(_potential_art)
	_potential_body = _label("", ShellTheme.BODY_PX, ShellTheme.INK)
	_potential_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	potential_box.add_child(_potential_body)

	var lower := _panel()
	lower.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lower.clip_contents = false
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
	hand_col.clip_contents = false
	lower_row.add_child(hand_col)
	hand_col.add_child(_section("Hand"))
	_hand_fan = CraftHandFan.new()
	hand_col.add_child(_hand_fan)
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

	_overlay = Control.new()
	_overlay.name = "HandMotion"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.z_index = 20
	add_child(_overlay)


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


func _set_session_headers(on: bool) -> void:
	if _brief_header != null:
		_brief_header.visible = on
	if _estimate_header != null:
		_estimate_header.visible = on
	if _brief_body != null:
		_brief_body.visible = on
	if _estimate_body != null:
		_estimate_body.visible = on


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


func _process(_dt: float) -> void:
	if _phase != _Phase.DRAG or _follower == null:
		return
	## Button-up can miss _input (handled motion, captured control). Poll so a drop still commits.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_end_drag(get_global_mouse_position())
		return
	if not _motion_this_frame:
		_vel_x = 0.0
	_motion_this_frame = false
	var pointer := get_global_mouse_position()
	_place_follower(pointer)
	_update_drop_hot(pointer)
	if _pickup_done:
		var tilt := clampf(_vel_x * _FOLLOW_TILT_PER_PX, -_FOLLOW_TILT_LIMIT_DEG, _FOLLOW_TILT_LIMIT_DEG)
		_follower.rotation = deg_to_rad(tilt)


func _input(event: InputEvent) -> void:
	if not visible or not AtelierSession.craft_open:
		return
	if event is InputEventKey:
		_on_key(event as InputEventKey)
		return
	if event is InputEventMouseButton:
		_on_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if _phase == _Phase.DRAG:
			if (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
				_end_drag(get_global_mouse_position())
				get_viewport().set_input_as_handled()
				return
			_vel_x = motion.velocity.x
			_motion_this_frame = true
			_place_follower(get_global_mouse_position())
			_update_drop_hot(get_global_mouse_position())
			get_viewport().set_input_as_handled()
		elif _armed != null and _armed.can_drag and motion.global_position.distance_to(_press_global) >= _CLICK_DRAG_PX:
			_begin_drag(motion.global_position)
			get_viewport().set_input_as_handled()
		elif _phase == _Phase.IDLE:
			_update_hover(motion.global_position)


func _refresh() -> void:
	var session: CraftStaminaSession = AtelierSession.craft_session
	var order: ClientOrder = AtelierSession.craft_order
	_title.text = "Craft"
	if session == null or order == null:
		_bind_order_portrait("")
		if AtelierSession.dev_tools:
			_order_title.text = "No session."
			_order_body.text = "Leave the route graph to sew an order here."
			_set_session_headers(true)
		else:
			_order_title.text = ""
			_order_body.text = ""
			_set_session_headers(false)
		_order_stats.text = ""
		_order_skill.text = ""
		_planner_list.text = "?"
		_brief_body.text = ""
		_estimate_body.text = ""
		if _current_art != null:
			_current_art.visible = false
		if _potential_art != null:
			_potential_art.visible = false
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
		_paint_tag_chips(null)
		return
	_set_session_headers(true)
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
		var raw_skill := AdventurerCatalog.skill_panel_line(adv_id)
		if AtelierSession.dev_tools:
			_order_skill.text = raw_skill
		else:
			_order_skill.text = PlayerChrome.skill_line(adv_id)
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
	_abort_motion()
	if _hand_fan != null:
		_hand_fan.clear_cards()


func _rebuild_hand(session: CraftStaminaSession) -> void:
	## n is the cards in hand this frame. max_hand is the setting. No empty frames.
	var max_hand := session.hand_size
	var n := mini(session.hand.size(), max_hand)
	var pool: Array[CraftHandSlot] = []
	for child in _hand_fan.get_children():
		if child is CraftHandSlot:
			pool.append(child as CraftHandSlot)
	var live: Array[CraftHandSlot] = []
	var closed := session.is_finished() or AtelierSession.order_craft_done
	for i in range(n):
		var card: HandCard = session.hand[i]
		var slot := _take_slot(pool, card)
		if slot == null:
			slot = CraftHandSlot.new()
			_hand_fan.add_child(slot)
		var cost := CraftCatalog.play_cost(card, AtelierSession.next_mat_free, AtelierSession.next_cost_less)
		slot.bind(i, card, cost, _can_click(session, i, closed), _can_drag(session, i, closed))
		if slot == _ghost:
			slot.set_ghost(true)
		live.append(slot)
	for leftover in pool:
		if leftover == _ghost:
			continue
		leftover.visible = false
		leftover.queue_free()
	_hand_fan.hold_layout = _phase != _Phase.IDLE
	_hand_fan.present(live, max_hand, _reflow, _deal_in)
	if _ghost != null and is_instance_valid(_ghost) and _phase != _Phase.IDLE:
		_ghost.set_ghost(true)
	if _deal_in:
		for i in range(live.size()):
			live[i].play_deal(
				_DEAL_FROM_Y,
				_DEAL_FROM_SCALE,
				_DEAL_SEC,
				float(i) * _DEAL_STAGGER_SEC,
				_note_motion_done
			)


func _outlook_socket() -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(OutlookArt.PX, OutlookArt.PX)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.visible = false
	return icon


func _bind_outlook_art(preview: Dictionary, unlocked: PackedStringArray) -> void:
	## Same Soft file on Current and Potential when unlocked. Hide both when locked.
	var tex: Texture2D = null
	if CraftReadout.potential_unlocked(preview, unlocked):
		tex = OutlookArt.texture_for(CraftReadout.outlook_id_of(preview))
	if _current_art != null:
		_current_art.texture = tex
		_current_art.visible = tex != null
	if _potential_art != null:
		_potential_art.texture = tex
		_potential_art.visible = tex != null


func _refresh_readout(session: CraftStaminaSession) -> void:
	var preview := CraftReadout.preview(session, session.selected_zone_index)
	_current_body.text = CraftReadout.current_line(preview)
	var unlocked := AtelierSession.unlocked_outlooks
	var open := CraftReadout.potential_unlocked(preview, unlocked)
	if AtelierSession.dev_tools:
		_potential_body.text = CraftReadout.potential_label(preview, unlocked)
	elif not open:
		_potential_body.text = "locked"
	else:
		_potential_body.text = PlayerChrome.outlook_name(CraftReadout.outlook_id_of(preview))
	_potential_body.add_theme_color_override("font_color", ShellTheme.INK if open else ShellTheme.MUTED)
	_bind_outlook_art(preview, unlocked)


func _on_piece(_result: Dictionary) -> void:
	_refresh()


func _on_planner_tag(tag: String) -> void:
	AtelierSession.click_planner_tag(tag)


func _paint_tag_chips(planned: Variant) -> void:
	for tag in _tag_chips.keys():
		var chip: Button = _tag_chips[tag]
		chip.text = ""
		var mark := PlannerCatalog.chip_mark(String(tag), planned)
		ShellTheme.paint_button(chip, mark != "")
		var icon := chip.get_node_or_null("Icon") as TextureRect
		if icon == null:
			continue
		match mark:
			"mid":
				icon.modulate = Color(1.12, 1.06, 0.86)
			"apex":
				icon.modulate = Color(1.28, 1.16, 0.72)
			"cross":
				icon.modulate = Color(1.08, 0.92, 1.12)
			_:
				icon.modulate = Color(1, 1, 1)


func _refresh_planner() -> void:
	var planned: Variant = AtelierSession.planned_build
	_paint_tag_chips(planned)
	var plan_line := "?"
	var row: Variant = PlannerCatalog.dup_plan(planned)
	if row is Dictionary:
		var item: Dictionary = row
		if AtelierSession.profile.has_build(String(item.get("outlook_id", "")), String(item.get("tier", ""))):
			plan_line = PlannerCatalog.plan_label(row)
	_planner_list.text = plan_line


func _refresh_brief_and_estimate(order: ClientOrder) -> void:
	## Guild-quest brief. Three lines when the enemy is seen. Unseen body is ?.
	var threat_id := AtelierSession.brief_threat_id(order)
	if threat_id.is_empty():
		_brief_body.text = "?"
		_estimate_body.text = DemoFacing.locked_estimate()
		return
	var seen := AtelierSession.profile.enemy_seen(threat_id)
	if not ThreatCatalog.is_boss(threat_id):
		seen = true
	var fought := AtelierSession.profile.enemy_fought(threat_id)
	_brief_body.text = DemoFacing.brief_text(
		seen,
		ThreatCatalog.display_name(threat_id),
		ThreatCatalog.environment(threat_id),
		ThreatCatalog.flavor(threat_id)
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
	## Weight integers stay in EstimateLaw and the test log. They are not on this label.
	_estimate_body.text = DemoFacing.estimate_text(
		gated,
		AdventurerCatalog.skill_name(adv_id),
		AdventurerCatalog.skill_clause(adv_id)
	)


func _play_slot(index: int) -> void:
	if _phase != _Phase.IDLE or AtelierSession.order_craft_done:
		return
	var session := AtelierSession.craft_session
	if session == null or index < 0 or index >= session.hand.size() or index >= session.hand_size:
		return
	if AtelierSession.scrap_pick_open:
		AtelierSession.pick_scrap(index)
		return
	for slot in _hand_fan.cards():
		if slot.hand_index == index:
			_begin_fly(slot)
			return


func _on_zone_selected(zone_index: int) -> void:
	if _phase != _Phase.IDLE:
		return
	AtelierSession.select_zone(zone_index)


func _on_dig() -> void:
	if _phase != _Phase.IDLE:
		return
	var session := AtelierSession.craft_session
	if session == null or not CraftRules.can_dig(session, AtelierSession.stock):
		return
	var departing := _hand_fan.detach_cards()
	for slot in departing:
		var saved: Variant = slot.get_meta("dump_pos")
		_overlay.add_child(slot)
		slot.global_position = saved as Vector2
		slot.rotation = float(slot.get_meta("dump_rot"))
		slot.scale = slot.get_meta("dump_scale") as Vector2
	_phase = _Phase.DIG
	_deal_in = true
	_hand_fan.hold_layout = true
	var ok := AtelierSession.dig()
	_deal_in = false
	if not ok:
		for slot in departing:
			slot.queue_free()
		_phase = _Phase.IDLE
		_hand_fan.hold_layout = false
		_refresh()
		return
	_motion_left = departing.size() + _hand_fan.cards().size()
	if _motion_left == 0:
		_phase = _Phase.IDLE
		_hand_fan.hold_layout = false
		return
	for i in range(departing.size()):
		departing[i].play_dump(_DUMP_DROP_PX, _DUMP_SEC, float(i) * _DUMP_STAGGER_SEC, _note_motion_done)


func _on_finish() -> void:
	_abort_motion()
	AtelierSession.finish_early()


func _on_continue() -> void:
	_abort_motion()
	AtelierSession.continue_after_piece()


func _on_key(key: InputEventKey) -> void:
	if not key.pressed or key.echo:
		return
	if key.keycode == KEY_ESCAPE and _phase == _Phase.DRAG:
		_begin_cancel()
		get_viewport().set_input_as_handled()
		return
	var index := _key_index(key.keycode)
	if _phase != _Phase.IDLE:
		if index >= 0 or key.keycode == KEY_D:
			get_viewport().set_input_as_handled()
		return
	if index >= 0:
		_play_slot(index)
		get_viewport().set_input_as_handled()
	elif key.keycode == KEY_D:
		_on_dig()
		get_viewport().set_input_as_handled()


func _key_index(code: Key) -> int:
	## Keys 1..max_hand. Pack strap raises the setting by one, so 6 is live when that gear is on.
	match code:
		KEY_1, KEY_KP_1:
			return 0
		KEY_2, KEY_KP_2:
			return 1
		KEY_3, KEY_KP_3:
			return 2
		KEY_4, KEY_KP_4:
			return 3
		KEY_5, KEY_KP_5:
			return 4
		KEY_6, KEY_KP_6:
			return 5
		_:
			return -1


func _on_mouse_button(mouse: InputEventMouseButton) -> void:
	if mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	if _phase == _Phase.DRAG and not mouse.pressed:
		_end_drag(get_global_mouse_position())
		get_viewport().set_input_as_handled()
		return
	if _phase != _Phase.IDLE:
		return
	if mouse.pressed:
		var slot := _top_slot(mouse.global_position)
		if slot == null or not (slot.can_click or slot.can_drag):
			_armed = null
			return
		_armed = slot
		_press_global = mouse.global_position
		get_viewport().set_input_as_handled()
		return
	if _armed == null:
		return
	var slot := _armed
	var moved := _press_global.distance_to(mouse.global_position)
	_armed = null
	get_viewport().set_input_as_handled()
	if moved < _CLICK_DRAG_PX and slot.can_click:
		_begin_fly(slot)


func _update_hover(point: Vector2) -> void:
	if _phase != _Phase.IDLE or _hand_fan == null:
		return
	var hot := _top_slot(point)
	for slot in _hand_fan.cards():
		slot.set_hovered(slot == hot)


func _top_slot(point: Vector2) -> CraftHandSlot:
	var best: CraftHandSlot = null
	var best_z := -100000
	for slot in _hand_fan.cards():
		if slot == _ghost or not slot.contains_global(point):
			continue
		if slot.z_index >= best_z:
			best = slot
			best_z = slot.z_index
	return best


func _begin_drag(pointer: Vector2) -> void:
	if _armed == null:
		return
	var slot := _armed
	slot.suppress_hover()
	slot.snap_rest(slot.rest_position, slot.rest_rotation)
	_phase = _Phase.DRAG
	_pickup_done = false
	_ghost = slot
	_hand_fan.hold_layout = true
	_hand_fan.set_cards_hover_locked(true)
	_spawn_follower(slot)
	slot.set_ghost(true)
	var center_x := slot.global_position.x + slot.size.x * 0.5
	var tilt := 0.0
	if pointer.x > center_x:
		tilt = _PICKUP_TILT_DEG
	elif pointer.x < center_x:
		tilt = -_PICKUP_TILT_DEG
	_kill_pickup()
	_pickup_tween = create_tween()
	_pickup_tween.set_parallel(true)
	_pickup_tween.set_ease(Tween.EASE_OUT)
	_pickup_tween.set_trans(Tween.TRANS_QUAD)
	_pickup_tween.tween_property(_follower, "scale", Vector2(_PICKUP_SCALE, _PICKUP_SCALE), _PICKUP_SEC)
	_pickup_tween.tween_property(_follower, "rotation", deg_to_rad(tilt), _PICKUP_SEC)
	_pickup_tween.finished.connect(func() -> void:
		_pickup_done = true
	, CONNECT_ONE_SHOT)
	_place_follower(pointer)
	_update_drop_hot(pointer)


func _end_drag(pointer: Vector2) -> void:
	if _phase != _Phase.DRAG:
		return
	if AtelierSession.scrap_pick_open:
		_begin_cancel()
		return
	var zone := _zone_at(pointer)
	_clear_drop_hot(true)
	if zone != null and _ghost != null and _can_commit(_ghost.hand_index, zone.zone_index):
		_begin_settle(zone, _ghost.hand_index, _DROP_SEC)
		return
	_begin_cancel()


func _begin_fly(slot: CraftHandSlot) -> void:
	if _phase != _Phase.IDLE or slot == null or not slot.can_click:
		return
	## scrap_breath A: a click names one other card. It is not a zone play.
	if AtelierSession.scrap_pick_open:
		AtelierSession.pick_scrap(slot.hand_index)
		return
	var session := AtelierSession.craft_session
	if session == null:
		return
	var zone := _zone_by_index(session.selected_zone_index)
	if zone == null or not zone.visible or zone.is_locked():
		return
	if not _can_commit(slot.hand_index, zone.zone_index):
		return
	slot.suppress_hover()
	slot.snap_rest(slot.rest_position, slot.rest_rotation)
	_spawn_follower(slot)
	slot.set_ghost(true)
	_ghost = slot
	_hand_fan.set_cards_hover_locked(true)
	_begin_settle(zone, slot.hand_index, _FLY_SEC)


func _begin_settle(zone: CraftZone, hand_index: int, sec: float) -> void:
	_phase = _Phase.SETTLE
	_hand_fan.hold_layout = true
	_kill_pickup()
	_clear_drop_hot(true)
	_settle_instance = 0
	if _ghost != null and _ghost.card != null:
		_settle_instance = _ghost.card.get_instance_id()
	_reflow = true
	var ok := AtelierSession.play_hand(hand_index, zone.zone_index)
	_reflow = false
	if not ok:
		_settle_instance = 0
		_begin_cancel()
		return
	_settle_zone = zone
	_settle_sec = sec
	_aim_tries = 0
	_arm_settle_timeout(sec)
	call_deferred("_aim_settle")


func _arm_settle_timeout(sec: float) -> void:
	_settle_gen += 1
	var gen := _settle_gen
	var timer := get_tree().create_timer(sec + 0.08)
	timer.timeout.connect(func() -> void:
		if gen != _settle_gen:
			return
		if _phase == _Phase.SETTLE:
			_finish_settle()
	, CONNECT_ONE_SHOT)


func _aim_settle() -> void:
	if _phase != _Phase.SETTLE:
		return
	if _follower == null:
		_finish_settle()
		return
	var rect := Rect2()
	if _settle_zone != null and is_instance_valid(_settle_zone):
		rect = _settle_zone.last_face_global_rect()
	var zone_rect := Rect2()
	if _settle_zone != null and is_instance_valid(_settle_zone):
		zone_rect = _settle_zone.get_global_rect()
	var laid_out := rect.size.x >= float(MatFace.ICON_PX) - 1.0 and zone_rect.grow(12.0).intersects(rect)
	if not laid_out and _aim_tries < 4:
		_aim_tries += 1
		call_deferred("_aim_settle")
		return
	if not laid_out and _settle_zone != null:
		var fallback := _settle_zone.get_global_rect()
		rect = Rect2(fallback.position + fallback.size * 0.5 - Vector2(16, 16), Vector2(MatFace.ICON_PX, MatFace.ICON_PX))
	_tween_onto(rect, _settle_sec)


func _tween_onto(rect: Rect2, sec: float) -> void:
	if _follower == null:
		_finish_settle()
		return
	var land := float(MatFace.ICON_PX) / CraftHandLayout.CARD_W
	var icon_center := rect.position + rect.size * 0.5
	var end_pos := icon_center - Vector2(
		CraftHandLayout.CARD_W * 0.5,
		CraftHandLayout.CARD_H - CraftHandLayout.CARD_H * 0.5 * land
	)
	_kill_motion()
	_motion_tween = create_tween()
	_motion_tween.set_parallel(true)
	_motion_tween.set_ease(Tween.EASE_OUT)
	_motion_tween.set_trans(Tween.TRANS_QUAD)
	_motion_tween.tween_property(_follower, "global_position", end_pos, sec)
	_motion_tween.tween_property(_follower, "rotation", 0.0, sec)
	_motion_tween.tween_property(_follower, "scale", Vector2(land, land), sec)
	_motion_tween.finished.connect(_finish_settle, CONNECT_ONE_SHOT)


func _begin_cancel() -> void:
	_clear_drop_hot(false)
	_kill_pickup()
	if _follower == null or _ghost == null or not is_instance_valid(_ghost):
		_abort_motion()
		return
	_phase = _Phase.SNAP
	_hand_fan.hold_layout = true
	var goal := _ghost.global_position
	var rot := _ghost.rotation
	_kill_motion()
	_motion_tween = create_tween()
	_motion_tween.set_parallel(true)
	_motion_tween.set_ease(Tween.EASE_OUT)
	_motion_tween.set_trans(Tween.TRANS_QUAD)
	_motion_tween.tween_property(_follower, "global_position", goal, _CANCEL_SEC)
	_motion_tween.tween_property(_follower, "rotation", rot, _CANCEL_SEC)
	_motion_tween.tween_property(_follower, "scale", Vector2.ONE, _CANCEL_SEC)
	_motion_tween.finished.connect(_finish_cancel, CONNECT_ONE_SHOT)


func _finish_settle() -> void:
	if _phase != _Phase.SETTLE:
		return
	## Idle before killing the tween so a finished callback cannot re-enter.
	_phase = _Phase.IDLE
	_settle_gen += 1
	_kill_motion()
	_free_follower()
	_release_played_from_hand()
	_ghost = null
	_armed = null
	_settle_zone = null
	_settle_instance = 0
	if _hand_fan != null:
		_hand_fan.hold_layout = false
		_hand_fan.set_cards_hover_locked(false)


func _release_played_from_hand() -> void:
	## Commit already removed the card from the session. Drop the fan slot and the ghost.
	if _hand_fan == null:
		return
	var seen: Dictionary = {}
	var drop: Array[CraftHandSlot] = []
	var consider: Array[CraftHandSlot] = []
	if _ghost != null and is_instance_valid(_ghost):
		consider.append(_ghost)
	for child in _hand_fan.get_children():
		if child is CraftHandSlot:
			consider.append(child as CraftHandSlot)
	for slot in consider:
		if slot == null or not is_instance_valid(slot):
			continue
		var node_id := slot.get_instance_id()
		if seen.has(node_id):
			continue
		var played := slot == _ghost or (_settle_instance != 0 and slot.tracks(_settle_instance))
		if not played:
			continue
		seen[node_id] = true
		drop.append(slot)
	var live: Array[CraftHandSlot] = []
	for slot in _hand_fan.cards():
		if not is_instance_valid(slot):
			continue
		if seen.has(slot.get_instance_id()):
			continue
		live.append(slot)
	for slot in drop:
		slot.visible = false
		if slot.get_parent() != null:
			slot.get_parent().remove_child(slot)
		slot.queue_free()
	var max_hand := 1
	var session := AtelierSession.craft_session
	if session != null:
		max_hand = session.hand_size
	_hand_fan.hold_layout = false
	_hand_fan.present(live, max_hand, true, false)


func _finish_cancel() -> void:
	if _ghost != null and is_instance_valid(_ghost):
		_ghost.set_ghost(false)
	_free_follower()
	_ghost = null
	_armed = null
	_phase = _Phase.IDLE
	if _hand_fan != null:
		_hand_fan.hold_layout = false
		_hand_fan.set_cards_hover_locked(false)


func _abort_motion() -> void:
	_settle_gen += 1
	_kill_pickup()
	_kill_motion()
	_free_follower()
	if _ghost != null and is_instance_valid(_ghost):
		_ghost.set_ghost(false)
	_ghost = null
	_armed = null
	_phase = _Phase.IDLE
	_deal_in = false
	_reflow = false
	_motion_left = 0
	if _hand_fan != null:
		_hand_fan.hold_layout = false
		_hand_fan.set_cards_hover_locked(false)
	_clear_drop_hot(true)


func _note_motion_done() -> void:
	if _phase != _Phase.DIG:
		return
	_motion_left -= 1
	if _motion_left > 0:
		return
	_motion_left = 0
	_phase = _Phase.IDLE
	if _hand_fan != null:
		_hand_fan.hold_layout = false


func _place_follower(pointer: Vector2) -> void:
	if _follower == null:
		return
	var origin := pointer + Vector2(0, -_FOLLOW_ORIGIN_PX)
	_follower.global_position = origin - _follower.pivot_offset


func _spawn_follower(source: CraftHandSlot) -> void:
	_free_follower()
	var wrap := Control.new()
	wrap.name = "DragFollower"
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.size = Vector2(CraftHandLayout.CARD_W, CraftHandLayout.CARD_H)
	wrap.pivot_offset = Vector2(CraftHandLayout.CARD_W * 0.5, CraftHandLayout.CARD_H)
	var shadow := ColorRect.new()
	shadow.color = Color(0, 0, 0, _GHOST_ALPHA)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shadow.position = Vector2(0, 6)
	shadow.size = Vector2(CraftHandLayout.CARD_W, CraftHandLayout.CARD_H)
	wrap.add_child(shadow)
	var card := CraftHandSlot.new()
	card.flight_visual = true
	_overlay.add_child(wrap)
	wrap.add_child(card)
	card.bind(source.hand_index, source.card, source.cost, false, false)
	card.position = Vector2.ZERO
	card.rotation = 0.0
	card.scale = Vector2.ONE
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.z_index = 80
	wrap.global_position = source.global_position
	wrap.rotation = source.rotation
	wrap.scale = source.scale
	_follower = wrap


func _free_follower() -> void:
	if _follower != null and is_instance_valid(_follower):
		_follower.queue_free()
	_follower = null


func _update_drop_hot(pointer: Vector2) -> void:
	var hot := _zone_at(pointer)
	for zone in _zones:
		zone.set_drop_hot(zone == hot)


func _clear_drop_hot(immediate: bool) -> void:
	for zone in _zones:
		zone.clear_drop_hot(immediate)


func _zone_at(pointer: Vector2) -> CraftZone:
	for zone in _zones:
		if zone == null or not zone.visible or zone.is_locked():
			continue
		if zone.contains_global(pointer):
			return zone
	return null


func _zone_by_index(zone_index: int) -> CraftZone:
	for zone in _zones:
		if zone.zone_index == zone_index:
			return zone
	return null


func _can_commit(hand_index: int, zone_index: int) -> bool:
	var session := AtelierSession.craft_session
	if session == null:
		return false
	return CraftRules.can_play(session, hand_index, AtelierSession.next_mat_free, zone_index, AtelierSession.next_cost_less)


func _can_click(session: CraftStaminaSession, index: int, closed: bool) -> bool:
	if closed or session == null:
		return false
	if AtelierSession.scrap_pick_open:
		return index >= 0 and index < session.hand.size()
	if not CraftRules.can_play(session, index, AtelierSession.next_mat_free, session.selected_zone_index, AtelierSession.next_cost_less):
		return false
	var zone := _zone_by_index(session.selected_zone_index)
	return zone != null and zone.visible and not zone.is_locked()


func _can_drag(session: CraftStaminaSession, index: int, closed: bool) -> bool:
	if closed or session == null or AtelierSession.scrap_pick_open:
		return false
	for z in range(1, session.zone_count + 1):
		if CraftRules.can_play(session, index, AtelierSession.next_mat_free, z, AtelierSession.next_cost_less):
			return true
	return false


func _take_slot(pool: Array[CraftHandSlot], card: HandCard) -> CraftHandSlot:
	var id := card.get_instance_id()
	for i in range(pool.size()):
		if pool[i].tracks(id):
			var slot := pool[i]
			pool.remove_at(i)
			return slot
	return null


func _kill_pickup() -> void:
	if _pickup_tween != null and _pickup_tween.is_valid():
		_pickup_tween.kill()
	_pickup_tween = null


func _kill_motion() -> void:
	if _motion_tween != null and _motion_tween.is_valid():
		_motion_tween.kill()
	_motion_tween = null
