class_name PlannerChipArt
extends RefCounted
## Sixteen stamped 16×16 monostack chips (Art #80, Soft paths).
## Cross is a state on two of these chips. It is not a file.
## Soft A draws the same files at native 16 on the craft card. The planner button stays PX.

const PX := 32
const CARD_PX := 16
const CARD_GAP := 2
const CARD_INSET := 2
const PATH := "res://assets/ui/planner/chip_%s.png"

const TEXTURES := {
	"Fire": preload("res://assets/ui/planner/chip_fire.png"),
	"Frost": preload("res://assets/ui/planner/chip_frost.png"),
	"Storm": preload("res://assets/ui/planner/chip_storm.png"),
	"Earth": preload("res://assets/ui/planner/chip_earth.png"),
	"Lunar": preload("res://assets/ui/planner/chip_lunar.png"),
	"Solar": preload("res://assets/ui/planner/chip_solar.png"),
	"Royal": preload("res://assets/ui/planner/chip_royal.png"),
	"Silent": preload("res://assets/ui/planner/chip_silent.png"),
	"Sticky": preload("res://assets/ui/planner/chip_sticky.png"),
	"Sharp": preload("res://assets/ui/planner/chip_sharp.png"),
	"Soft": preload("res://assets/ui/planner/chip_soft.png"),
	"Wild": preload("res://assets/ui/planner/chip_wild.png"),
	"Occult": preload("res://assets/ui/planner/chip_occult.png"),
	"Pure": preload("res://assets/ui/planner/chip_pure.png"),
	"Metal": preload("res://assets/ui/planner/chip_metal.png"),
	"Silk": preload("res://assets/ui/planner/chip_silk.png"),
}


static func texture_for(tag: String) -> Texture2D:
	return TEXTURES[tag] as Texture2D


## Soft A card chip. Null when this id has no file. Cross is not a seventeenth file.
## look_* is an outlook, never a tag chip.
static func card_texture(tag: String) -> Texture2D:
	var slug := tag.to_lower()
	if slug.is_empty() or slug == "cross" or slug.begins_with("look"):
		return null
	var landed: Variant = TEXTURES.get(tag)
	if landed is Texture2D:
		return landed as Texture2D
	var path := PATH % slug
	if not ResourceLoader.exists(path):
		return null
	var loaded: Variant = load(path)
	return loaded as Texture2D


## Words that stay on the hand caption: the tag has no Soft chip file.
static func tags_without_chip(tags: PackedStringArray) -> PackedStringArray:
	var words := PackedStringArray()
	for tag in tags:
		var name := String(tag)
		if card_texture(name) == null:
			words.append(name)
	return words


static func make_card_chip(tag: String) -> TextureRect:
	var tex := card_texture(tag)
	if tex == null:
		return null
	var icon := TextureRect.new()
	icon.name = tag
	icon.texture = tex
	icon.custom_minimum_size = Vector2(CARD_PX, CARD_PX)
	icon.size = Vector2(CARD_PX, CARD_PX)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	## Mouse-ignore: not the drag handle and not the settle slot. Tooltip text is the tag word.
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.focus_mode = Control.FOCUS_NONE
	icon.tooltip_text = tag
	icon.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icon


static func make_card_chips(tags: PackedStringArray) -> Array[TextureRect]:
	var chips: Array[TextureRect] = []
	for tag in tags:
		var chip := make_card_chip(String(tag))
		if chip == null:
			continue
		chips.append(chip)
	return chips
