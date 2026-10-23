class_name ShellTheme
extends RefCounted
## Palette A (docs/34). One named block for craft, zone cards, hand slots,
## and the playback step. Godot 4.7: Color(r, g, b) literals, not Color.html.
## No theme texture. No font file. Default font, size overrides only.

const WOOD := Color(0.102, 0.078, 0.063)
const PANEL := Color(0.165, 0.129, 0.094)
const CHIP := Color(0.227, 0.173, 0.094)
const PLATE := Color(0.240, 0.200, 0.160)
const BORDER := Color(0.239, 0.204, 0.173)
const GOLD := Color(0.788, 0.635, 0.153)
const INK := Color(0.910, 0.835, 0.690)
const MUTED := Color(0.710, 0.643, 0.541)

## Existing enchanted-material tint already on the hand slot. Not a new token.
const SHINY_FILL := Color(0.35, 0.28, 0.1)
const SHINY_MODULATE := Color(1.1, 1.05, 0.82)
const SHINE_BAR := Color(0.95, 0.82, 0.22, 0.38)

const RADIUS := 8

const TITLE_PX := 22
const NAME_PX := 16
const SECTION_PX := 13
const BODY_PX := 13
const CAPTION_PX := 12
const SLOT_PX := 11


static func frame() -> StyleBoxFlat:
	return _box(PANEL, BORDER, 1, 10, 10, 8, 8)


static func zone_idle() -> StyleBoxFlat:
	return _box(PANEL, BORDER, 1, 10, 10, 8, 8)


static func zone_selected() -> StyleBoxFlat:
	return _box(PANEL, GOLD, 2, 10, 10, 8, 8)


static func hand() -> StyleBoxFlat:
	return _box(CHIP, BORDER, 1, 8, 8, 8, 8)


static func hand_shiny() -> StyleBoxFlat:
	return _box(SHINY_FILL, GOLD, 2, 8, 8, 8, 8)


## Chip fill, 1px border. Hand face well and the 32×32 played square (docs/36).
static func chip_well(corner: int = 4) -> StyleBoxFlat:
	var sb := _box(CHIP, BORDER, 1, 0, 0, 0, 0)
	sb.set_corner_radius_all(corner)
	return sb


static func button_primary() -> StyleBoxFlat:
	return _box(PANEL, GOLD, 2, 10, 10, 6, 6)


static func button_secondary() -> StyleBoxFlat:
	return _box(PANEL, BORDER, 1, 10, 10, 6, 6)


static func stamina_track() -> StyleBoxFlat:
	return _box(WOOD, WOOD, 0, 0, 0, 0, 0)


static func stamina_fill() -> StyleBoxFlat:
	return _box(GOLD, GOLD, 0, 0, 0, 0, 0)


static func paint_panel(panel: PanelContainer, box: StyleBoxFlat) -> void:
	panel.add_theme_stylebox_override("panel", box)


static func paint_button(btn: Button, primary: bool) -> void:
	var font := GOLD if primary else INK
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		var box := button_primary() if primary else button_secondary()
		btn.add_theme_stylebox_override(String(state), box)
	btn.add_theme_color_override("font_color", font)
	btn.add_theme_color_override("font_hover_color", font)
	btn.add_theme_color_override("font_pressed_color", font)
	btn.add_theme_color_override("font_focus_color", font)
	btn.add_theme_color_override("font_disabled_color", MUTED)
	btn.add_theme_font_size_override("font_size", BODY_PX)


static func paint_stamina(bar: ProgressBar) -> void:
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", stamina_track())
	bar.add_theme_stylebox_override("fill", stamina_fill())


static func label(text: String, size: int, color: Color) -> Label:
	var lab := Label.new()
	lab.text = text
	lab.add_theme_font_size_override("font_size", size)
	lab.add_theme_color_override("font_color", color)
	return lab


static func _box(
	fill: Color,
	border: Color,
	border_px: int,
	left: int,
	right: int,
	top: int,
	bottom: int
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(RADIUS)
	sb.set_border_width_all(border_px)
	sb.border_color = border
	sb.content_margin_left = left
	sb.content_margin_right = right
	sb.content_margin_top = top
	sb.content_margin_bottom = bottom
	return sb
