extends Control
## Boot screen (docs/35, docs/21). Not the route graph.
## Nothing on this screen writes dev_tools. Dex, Reroll, Demo, and the stamp dump stay off it.

const BOARD_SCENE := "res://src/ui/schedule/schedule_board.tscn"

var _continue_btn: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = ShellTheme.WOOD
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.custom_minimum_size = Vector2(280, 0)
	center.add_child(box)

	var title := ShellTheme.label("Wombaste", 36, ShellTheme.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	box.add_child(_btn("New run", _on_new_run))
	_continue_btn = _btn("Continue", _on_continue)
	_continue_btn.disabled = not AtelierSession.can_continue()
	box.add_child(_continue_btn)
	box.add_child(_btn("Quit", _on_quit))


func _btn(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(220, 36)
	ShellTheme.paint_button(btn, true)
	btn.pressed.connect(cb)
	return btn


func _on_new_run() -> void:
	AtelierSession.new_run()
	get_tree().change_scene_to_file(BOARD_SCENE)


func _on_continue() -> void:
	if not AtelierSession.can_continue():
		_continue_btn.disabled = true
		return
	if not AtelierSession.continue_run():
		_continue_btn.disabled = true
		return
	get_tree().change_scene_to_file(BOARD_SCENE)


func _on_quit() -> void:
	get_tree().quit()
