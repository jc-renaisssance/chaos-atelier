class_name PlannerChipArt
extends RefCounted
## Sixteen stamped 16×16 monostack chips (Art #80, Soft paths).
## Cross is a state on two of these chips. It is not a file.

const PX := 32

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
