class_name CraftTable
extends Control
## Dedicated stamina craft screen (docs/27). Not the schedule board.
## Lower: hand + actions. Upper left: order detail. Upper right: ≤4 drop zones.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)

var _title: Label
var _note: Label
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
var _result: Label
var _stamp: Label


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
	bg.color = WOOD
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

	_title = _label("CRAFT  ·  dedicated table  ·  one session", 22, GOLD)
	root.add_child(_title)
	_note = _label("", 12, MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_note)

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
	left_box.add_child(_caption("UPPER LEFT  ·  adventurer order detail"))
	_order_title = _label("No order", 16, GOLD)
	left_box.add_child(_order_title)
	_order_stats = _label("", 13, INK)
	_order_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_order_stats)
	_order_skill = _label("", 12, MUTED)
	_order_skill.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_order_skill)
	_order_body = _label("", 13, INK)
	_order_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_order_body)
	left_box.add_child(_caption("SLICE 2  ·  syn-target planner  ·  chip 1=low 2=mid 3=apex  ·  two-tag = cross"))
	var chip_row := HFlowContainer.new()
	chip_row.add_theme_constant_override("h_separation", 4)
	chip_row.add_theme_constant_override("v_separation", 4)
	left_box.add_child(chip_row)
	_tag_chips.clear()
	for tag in PlannerCatalog.MONOSTACK_TAGS:
		var chip := Button.new()
		var tag_name := String(tag)
		chip.text = tag_name
		chip.pressed.connect(_on_planner_tag.bind(tag_name))
		chip_row.add_child(chip)
		_tag_chips[tag_name] = chip
	_planner_list = _label("?", 12, MUTED)
	_planner_list.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_planner_list)
	left_box.add_child(_caption("SLICE 3  ·  guild-quest brief  ·  showing this writes seen"))
	_brief_body = _label("", 12, INK)
	_brief_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_brief_body)
	left_box.add_child(_caption("ESTIMATE  ·  planned vs brief  ·  Test knobs  ·  locked = ?"))
	_estimate_body = _label("", 12, INK)
	_estimate_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(_estimate_body)
	left_box.add_child(_caption("STAMINA  ·  12 × N  ·  0 stays open  ·  Finish crafts"))
	_stam_label = _label("12 / 12", 15, INK)
	left_box.add_child(_stam_label)
	_stam_bar = ProgressBar.new()
	_stam_bar.min_value = 0
	_stam_bar.max_value = GameConstants.STAMINA_START
	_stam_bar.value = GameConstants.STAMINA_START
	_stam_bar.show_percentage = false
	_stam_bar.custom_minimum_size = Vector2(0, 16)
	_stam_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_box.add_child(_stam_bar)
	left_box.add_child(_caption("READOUT  ·  selected zone  ·  CURRENT  ·  POTENTIAL"))
	var readout := HBoxContainer.new()
	readout.add_theme_constant_override("separation", 8)
	readout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_box.add_child(readout)
	var current_panel := _panel()
	current_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	readout.add_child(current_panel)
	var current_box := VBoxContainer.new()
	current_box.add_theme_constant_override("separation", 4)
	current_panel.add_child(current_box)
	current_box.add_child(_label("CURRENT  ·  selected zone", 12, GOLD))
	_current_body = _label("", 13, INK)
	_current_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_box.add_child(_current_body)
	var potential_panel := _panel()
	potential_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	readout.add_child(potential_panel)
	var potential_box := VBoxContainer.new()
	potential_box.add_theme_constant_override("separation", 4)
	potential_panel.add_child(potential_box)
	potential_box.add_child(_label("POTENTIAL  ·  outlook / item", 12, GOLD))
	_potential_body = _label("", 13, INK)
	_potential_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	potential_box.add_child(_potential_body)

	var right := _panel()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.1
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	upper.add_child(right)
	var right_box := VBoxContainer.new()
	right_box.add_theme_constant_override("separation", 6)
	right.add_child(right_box)
	right_box.add_child(_caption("UPPER RIGHT  ·  craft drop zones  ·  unused hidden if N < 4"))
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

	var lower := _panel()
	lower.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(lower)
	var lower_box := VBoxContainer.new()
	lower_box.add_theme_constant_override("separation", 8)
	lower.add_child(lower_box)
	lower_box.add_child(_caption("LOWER  ·  hand slots 1–5  ·  Dig (D)  ·  Finish  ·  cards display here"))
	_hand = HBoxContainer.new()
	_hand.add_theme_constant_override("separation", 8)
	lower_box.add_child(_hand)
	_stock = _label("", 12, MUTED)
	lower_box.add_child(_stock)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	lower_box.add_child(btns)
	_dig_btn = _btn("Dig (D)  ·  −2 stamina", _on_dig)
	btns.add_child(_dig_btn)
	_finish_btn = _btn("Finish", _on_finish)
	btns.add_child(_finish_btn)
	_continue_btn = _btn("Return to schedule", _on_continue)
	btns.add_child(_continue_btn)

	root.add_child(_caption("RESOLVER  ·  one Finish → N stamps  ·  docs/20"))
	var res := _panel()
	root.add_child(res)
	_result = _label("Play into a zone. Only Finish crafts — stamina 0 stays open.", 13, INK)
	_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	res.add_child(_result)

	var stamp_panel := _panel()
	stamp_panel.custom_minimum_size.y = 64
	root.add_child(stamp_panel)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 56
	stamp_panel.add_child(scroll)
	_stamp = _label("{}", 11, MUTED)
	_stamp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stamp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_stamp)


func _caption(text: String) -> Label:
	return _label(text, 11, GOLD)


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


func _btn(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
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
	if session == null or order == null:
		_title.text = "CRAFT  ·  dedicated table"
		_order_title.text = "No session."
		_order_stats.text = ""
		_order_skill.text = ""
		_order_body.text = "Leave the schedule board to sew an order here."
		_planner_list.text = "?"
		_brief_body.text = ""
		_estimate_body.text = ""
		_refresh_planner_chips(null)
		return
	var threat := ThreatCatalog.display_name(order.threat_id) if not order.threat_id.is_empty() else "—"
	_title.text = "CRAFT  ·  %s  ·  own_basic  ·  one session" % order.order_id
	_note.text = AtelierSession.last_note
	var adv_id := AdventurerCatalog.order_adventurer_id(order)
	var person := AdventurerCatalog.row_resolved(adv_id)
	if not person.is_empty():
		_order_title.text = "%s  ·  %s  ·  %s" % [
			String(person.get("display", adv_id)),
			BossClientCatalog.display_name(String(person.get("job_id", ""))),
			GameEnums.mission_kind_wire(order.mission_kind),
		]
		_order_stats.text = AdventurerCatalog.stats_line(adv_id)
		_order_skill.text = AdventurerCatalog.skill_panel_line(adv_id)
	else:
		_order_title.text = "%s  ·  %s" % [
			ScheduleCatalog.order_title(order),
			GameEnums.mission_kind_wire(order.mission_kind),
		]
		_order_stats.text = ""
		_order_skill.text = ""
	var listed: PackedStringArray = PackedStringArray()
	for i in range(session.construction_ids.size()):
		var con_id := session.construction_ids[i]
		listed.append("%d %s" % [i + 1, CraftCatalog.construction_name(con_id)])
	var taste := AdventurerCatalog.requirement_taste(adv_id)
	if taste.is_empty():
		taste = ", ".join(order.requirement_tags) if order.requirement_tags.size() > 0 else "—"
	_order_body.text = (
		"Order %s   ·   threat %s   ·   difficulty %s   ·   listed %s   ·   taste %s   ·   zones %d / %d   ·   draw %d   ·   discard %d   ·   next-mat-free %s   ·   pieces sewn %d / %d   ·   construction from the order, not a hand card"
		% [
			order.order_id,
			threat,
			str(order.card_difficulty) if order.card_difficulty != GameConstants.NULL_INT else "—",
			", ".join(listed),
			taste,
			session.zone_count,
			GameConstants.ZONE_COUNT_MAX,
			session.draw_pile.size(),
			session.discard_pile.size(),
			"yes" if AtelierSession.next_mat_free else "no",
			AtelierSession.board.crafts_done if AtelierSession.board != null else 0,
			GameConstants.CRAFTS_MAX,
		]
	)
	_stam_label.text = (
		"Stamina %d / %d   ·   12 × %d   ·   spent %d   ·   digs %d   ·   dig costs %d (not × N)"
		% [
			session.stamina_remaining,
			session.stamina_start,
			session.piece_count,
			session.stamina_spent,
			session.dig_count,
			session.dig_refresh_cost,
		]
	)
	_stam_bar.max_value = session.stamina_start
	_stam_bar.value = session.stamina_remaining
	_rebuild_zones(session)
	_rebuild_hand(session)
	_refresh_readout(session)
	_stock.text = (
		"Draw %d  ·  discard %d  ·  run deck %d. Play leaves the hand → discard into the target zone. Dig (D) dumps remaining hand, then draws (reshuffle if short). Empty hand is legal."
		% [session.draw_pile.size(), session.discard_pile.size(), session.run_deck_count()]
	)
	var busy := session.is_finished() or AtelierSession.order_craft_done
	_dig_btn.disabled = busy or not CraftRules.can_dig(session, AtelierSession.stock)
	_finish_btn.disabled = busy
	_continue_btn.visible = AtelierSession.order_craft_done
	if order.mission_kind == GameEnums.MissionKind.BOSS:
		_continue_btn.text = "Resolve the fight"
	else:
		_continue_btn.text = "Return to schedule"
	_refresh_result(session)
	_refresh_planner()
	_refresh_brief_and_estimate(order)
	_stamp.text = JSON.stringify(AtelierSession.stamp_preview(), "  ")


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


func _rebuild_hand(session: CraftStaminaSession) -> void:
	for child in _hand.get_children():
		child.queue_free()
	if session.hand.is_empty():
		_hand.add_child(_label("Hand empty — Dig (D) or Finish.", 14, MUTED))
		return
	var locked := session.is_finished() or AtelierSession.order_craft_done
	for i in range(session.hand.size()):
		var card: HandCard = session.hand[i]
		var cost := CraftCatalog.play_cost(card, AtelierSession.next_mat_free)
		var slot := CraftHandSlot.new()
		_hand.add_child(slot)
		slot.bind(
			i,
			card,
			cost,
			locked,
			CraftRules.can_play(session, i, AtelierSession.next_mat_free, session.selected_zone_index)
		)
		slot.slot_played.connect(_on_play)


func _refresh_readout(session: CraftStaminaSession) -> void:
	var preview := CraftReadout.preview(session, session.selected_zone_index)
	_current_body.text = CraftReadout.current_line(preview)
	var unlocked := AtelierSession.unlocked_outlooks
	var open := CraftReadout.potential_unlocked(preview, unlocked)
	_potential_body.text = CraftReadout.potential_label(preview, unlocked)
	_potential_body.add_theme_color_override("font_color", INK if open else MUTED)


func _refresh_result(session: CraftStaminaSession) -> void:
	if AtelierSession.piece_results.is_empty() or not session.is_finished():
		_result.text = "One Finish ends the session and stamps each zone in listed order (docs/20, 23). Empty zones use the construction-only bag."
		return
	var bits: PackedStringArray = PackedStringArray()
	for result in AtelierSession.piece_results:
		var row: Dictionary = result
		bits.append(
			"z%d %s · %s · %s · %s"
			% [
				int(row.get("zone_index", 0)),
				CraftCatalog.construction_name(String(row.get("construction_id", ""))),
				GameEnums.craft_rarity_wire(row.get("craft_rarity", GameEnums.CraftRarity.NONE)),
				String(row.get("outlook_id", "plain")),
				GameEnums.rating_wire(row.get("rating", GameEnums.Rating.NONE)),
			]
		)
	_result.text = (
		"Finish %s   ·   %s   ·   crafts_done %d / %d"
		% [
			GameEnums.finish_reason_wire(session.finish_reason),
			"  |  ".join(bits),
			AtelierSession.board.crafts_done if AtelierSession.board != null else 0,
			GameConstants.CRAFTS_MAX,
		]
	)


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
	_planner_list.text = "unlocked  ·  %s" % "  |  ".join(lines)


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
	_estimate_body.text = (
		"planned %s   ·   favor hits %s   ·   punish hits %s   ·   skill %s   ·   neg %s   ·   band %s   ·   knobs FAVOR_W %d PUNISH_W %d SKILL_W %d NEG_W %d STAT_W %d"
		% [
			_gate_text(gated.get("planned_outlook", EstimateLaw.LOCKED)),
			_gate_text(gated.get("estimate_favor_hits", EstimateLaw.LOCKED)),
			_gate_text(gated.get("estimate_punish_hits", EstimateLaw.LOCKED)),
			skill_txt,
			_gate_text(gated.get("estimate_neg_warnings", EstimateLaw.LOCKED)),
			_gate_text(gated.get("estimate_band", EstimateLaw.LOCKED)),
			EstimateLaw.FAVOR_W,
			EstimateLaw.PUNISH_W,
			EstimateLaw.SKILL_W,
			EstimateLaw.NEG_W,
			EstimateLaw.STAT_W,
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
