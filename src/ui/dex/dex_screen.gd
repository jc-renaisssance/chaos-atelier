class_name DexScreen
extends Control
## Ugly Dex list (docs/31). Shop / menu overlay. Read-only of the profile / meta save.
## Tabs: Builds | Crafts | Adventurers | Enemies. No portraits, no lore, no write paths.

## Godot 4.7: Color.html is not a constant expression — use Color(r, g, b) literals.
const INK := Color(0.91, 0.835, 0.69)
const MUTED := Color(0.71, 0.643, 0.541)
const GOLD := Color(0.788, 0.635, 0.153)
const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const BORDER := Color(0.239, 0.204, 0.173)
const TABS := ["Builds", "Crafts", "Adventurers", "Enemies"]
const UNKNOWN := "?"

signal closed

var _title: Label
var _note: Label
var _tab_caption: Label
var _source: Label
var _tab_row: HBoxContainer
var _tab_buttons: Dictionary = {}
var _list: ItemList
var _tab: String = "Builds"


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
	_title = _label("DEX  ·  ugly list  ·  profile / meta  ·  no art", 22, GOLD)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_title)
	head.add_child(_btn("Close", _on_close))

	_note = _label(
		"One screen from the shop / menu. Unknown / unmet rows are ?. No lore. Builds reads unlocked_builds only.",
		13,
		MUTED
	)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_note)

	_tab_caption = _label("TAB STRIP  ·  Builds | Crafts | Adventurers | Enemies", 12, GOLD)
	root.add_child(_tab_caption)

	_tab_row = HBoxContainer.new()
	_tab_row.add_theme_constant_override("separation", 8)
	root.add_child(_tab_row)
	_tab_buttons.clear()
	for tab in TABS:
		var tab_name := String(tab)
		var chip := _btn(tab_name, _on_tab.bind(tab_name))
		_tab_row.add_child(chip)
		_tab_buttons[tab_name] = chip

	_source = _label("Reads unlocked_builds", 13, INK)
	_source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_source)

	var list_panel := _panel()
	list_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(list_panel)
	_list = ItemList.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_panel.add_child(_list)


func open_screen() -> void:
	## Refresh on open so cross-run persisted rows show immediately.
	visible = true
	refresh()


func refresh() -> void:
	if AtelierSession.profile != null:
		AtelierSession.profile.load_from_disk()
	_refresh_tabs()
	_source.text = _source_line()
	_rebuild_list()


func _refresh_tabs() -> void:
	for tab in _tab_buttons.keys():
		var chip: Button = _tab_buttons[tab]
		chip.disabled = String(tab) == _tab


func _source_line() -> String:
	match _tab:
		"Builds":
			return "Reads unlocked_builds  ·  outlook + tier  ·  known family missing a tier → Metal ?"
		"Crafts":
			return "Reads dex_crafts  ·  construction + outlook/tier + first_day / run id"
		"Adventurers":
			return "Reads dex_adventurers  ·  12 slots  ·  met = name + job + received/completed  ·  else ?  ·  no appt_*"
		"Enemies":
			return "Reads dex_enemies  ·  M1 boss_*  ·  name+env if seen else ?  ·  favor/punish if fought else ?"
		_:
			return "Reads profile"


func _rebuild_list() -> void:
	if _list == null:
		return
	_list.clear()
	var lines: PackedStringArray = _lines_for_tab(_tab)
	if lines.is_empty():
		_list.add_item(UNKNOWN)
		return
	for line in lines:
		_list.add_item(String(line))


func _lines_for_tab(tab: String) -> PackedStringArray:
	match tab:
		"Builds":
			return _build_lines()
		"Crafts":
			return _craft_lines()
		"Adventurers":
			return _adventurer_lines()
		"Enemies":
			return _enemy_lines()
		_:
			return PackedStringArray([UNKNOWN])


func _profile() -> ProfileMeta:
	return AtelierSession.profile


func _build_lines() -> PackedStringArray:
	## Dex Builds tab lists unlocked_builds. Do not invent a second Builds store.
	var profile := _profile()
	var rows: Array = []
	if profile != null:
		rows = profile.unlocked_builds
	return PlannerCatalog.list_lines(rows)


func _craft_lines() -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	var profile := _profile()
	if profile == null or profile.dex_crafts.is_empty():
		return PackedStringArray([UNKNOWN])
	for row in profile.dex_crafts:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		var con_id := String(item.get("construction_id", ""))
		var outlook_id := String(item.get("outlook_id", ""))
		var tier := String(item.get("tier", ""))
		var day := int(item.get("first_day", 0))
		var run_id := String(item.get("first_run_id", ""))
		var con_name := CraftCatalog.construction_name(con_id)
		if con_name.is_empty():
			con_name = con_id
		var outlook := PlannerCatalog.display_outlook(outlook_id)
		lines.append(
			"%s  ·  %s %s  ·  day %d  ·  %s"
			% [con_name, outlook, tier, day, run_id]
		)
	if lines.is_empty():
		return PackedStringArray([UNKNOWN])
	return lines


func _adventurer_lines() -> PackedStringArray:
	## Fresh = 12 unknown slots, no names. Never spoiler unmet people. No appt_* / Scrap Duelist.
	var lines: PackedStringArray = PackedStringArray()
	var ids := AdventurerCatalog.all_named_ids()
	for raw in ids:
		var adv_id := String(raw)
		if adv_id.is_empty() or adv_id.begins_with("appt_"):
			continue
		var row := _adventurer_row(adv_id)
		if row.is_empty() or not bool(row.get("met", false)):
			lines.append(UNKNOWN)
			continue
		var job_id := AdventurerCatalog.job_id_for(adv_id)
		var job := BossClientCatalog.display_name(job_id)
		if job.is_empty():
			job = job_id
		lines.append(
			"%s  ·  %s  ·  received %d  ·  completed %d"
			% [
				AdventurerCatalog.display_name(adv_id),
				job,
				int(row.get("orders_received", 0)),
				int(row.get("orders_completed", 0)),
			]
		)
	if lines.is_empty():
		return PackedStringArray([UNKNOWN])
	return lines


func _enemy_lines() -> PackedStringArray:
	## M1 = the 9 boss_* in docs/17. Name+env if seen else ?. Tags only if fought else ?.
	var lines: PackedStringArray = PackedStringArray()
	for raw in ThreatCatalog.BOSSES.keys():
		var threat_id := String(raw)
		if threat_id.is_empty() or not ThreatCatalog.is_boss(threat_id):
			continue
		lines.append(_enemy_line(threat_id, _enemy_row(threat_id)))
	if lines.is_empty():
		return PackedStringArray([UNKNOWN])
	return lines


func _enemy_line(threat_id: String, row: Dictionary) -> String:
	var seen := bool(row.get("seen", false))
	var fought := bool(row.get("fought", false))
	if not seen and not fought:
		return UNKNOWN
	var boss_name := ThreatCatalog.display_name(threat_id)
	var env := ThreatCatalog.environment(threat_id)
	if env.is_empty():
		env = "—"
	var briefs := int(row.get("briefs_seen", 0))
	var fights := int(row.get("fights", 0))
	var favor := UNKNOWN
	var punish := UNKNOWN
	if fought:
		favor = ", ".join(ThreatCatalog.favor_tags(threat_id))
		punish = ", ".join(ThreatCatalog.punish_tags(threat_id))
		if favor.is_empty():
			favor = "(none)"
		if punish.is_empty():
			punish = "(none)"
	return (
		"%s  ·  %s  ·  briefs %d  ·  fights %d  ·  favor %s  ·  punish %s"
		% [boss_name, env, briefs, fights, favor, punish]
	)


func _adventurer_row(adv_id: String) -> Dictionary:
	var profile := _profile()
	if profile == null or adv_id.is_empty():
		return {}
	for row in profile.dex_adventurers:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		if String(item.get("adventurer_id", "")) == adv_id:
			return item
	return {}


func _enemy_row(threat_id: String) -> Dictionary:
	var profile := _profile()
	if profile == null or threat_id.is_empty():
		return {}
	for row in profile.dex_enemies:
		if not row is Dictionary:
			continue
		var item: Dictionary = row
		if String(item.get("threat_id", "")) == threat_id:
			return item
	return {}


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


func _on_tab(tab: String) -> void:
	_tab = tab
	refresh()


func _on_close() -> void:
	visible = false
	closed.emit()
