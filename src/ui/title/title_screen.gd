extends Control
## Boot screen (docs/35, docs/21). Not the route graph.
## Dev is a flag. Dex, Reroll, Demo, and the stamp dump are not on this screen.

const BOARD_SCENE := "res://src/ui/schedule/schedule_board.tscn"

var _continue_btn: Button
var _dev: CheckButton


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

	_dev = CheckButton.new()
	_dev.text = "Dev"
	_dev.button_pressed = false
	_dev.focus_mode = Control.FOCUS_NONE
	_dev.add_theme_color_override("font_color", ShellTheme.MUTED)
	_dev.add_theme_color_override("font_hover_color", ShellTheme.INK)
	_dev.add_theme_font_size_override("font_size", ShellTheme.BODY_PX)
	box.add_child(_dev)


func _btn(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(220, 36)
	ShellTheme.paint_button(btn, true)
	btn.pressed.connect(cb)
	return btn


func _apply_dev() -> void:
	AtelierSession.dev_tools = _dev != null and _dev.button_pressed


func _on_new_run() -> void:
	_apply_dev()
	AtelierSession.new_run()
	get_tree().change_scene_to_file(BOARD_SCENE)


func _on_continue() -> void:
	if not AtelierSession.can_continue():
		_continue_btn.disabled = true
		return
	_apply_dev()
	if not AtelierSession.continue_run():
		_continue_btn.disabled = true
		return
	get_tree().change_scene_to_file(BOARD_SCENE)


func _on_quit() -> void:
	get_tree().quit()
