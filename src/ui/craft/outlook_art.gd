class_name OutlookArt
extends RefCounted
## Current + Potential sockets (docs/35 Current A). 28 Soft slots only.
## Load res://assets/outlook/<filename>.png when that Art copy is present.
## A missing file hides the TextureRect. Do not read the armor packs.
## Not slots: royal alias, cross _3 / _8, mat_*.png, monostacks with no file.

const PX := 96

## Winning outlook_id → filename under res://assets/outlook/.
const FILES := {
	"plain": "look_armor_plain.png",
	"syn_metal_3": "look_armor_metal_2.png",
	"syn_metal_5": "look_armor_metal_3.png",
	"syn_metal_8": "look_armor_metal_8.png",
	"syn_earth_3": "look_armor_earth_2.png",
	"syn_earth_5": "look_armor_earth_3.png",
	"syn_earth_8": "look_armor_earth_8.png",
	"syn_fire_3": "look_armor_fire_2.png",
	"syn_fire_5": "look_armor_fire_3.png",
	"syn_fire_8": "look_armor_fire_8.png",
	"syn_frost_3": "look_armor_frost_2.png",
	"syn_frost_5": "look_armor_frost_3.png",
	"syn_frost_8": "look_armor_frost_8.png",
	"syn_silent_3": "look_armor_silent_3.png",
	"syn_silent_5": "look_armor_silent_5.png",
	"syn_silent_8": "look_armor_silent_8.png",
	"syn_royal_3": "look_armor_royal_3.png",
	"syn_royal_5": "look_armor_royal_5.png",
	"syn_royal_8": "look_armor_royal_8.png",
	"syn_silk_3": "look_armor_silk_3.png",
	"syn_silk_5": "look_armor_silk_5.png",
	"syn_silk_8": "look_armor_silk_8.png",
	"syn_fire_frost_clash": "look_armor_cross_storm_5.png",
	"syn_wild_earth": "look_armor_cross_beastbloom_5.png",
	"syn_sticky_sharp": "look_armor_cross_snaretooth_5.png",
	"syn_royal_silent": "look_armor_cross_masked_crown_5.png",
	"syn_solar_pure": "look_armor_cross_dawn_vestment_5.png",
	"syn_lunar_occult": "look_armor_cross_pale_hex_5.png",
}


static func texture_for(outlook_id: String) -> Texture2D:
	var file := String(FILES.get(outlook_id, ""))
	if file.is_empty():
		return null
	var path := "res://assets/outlook/%s" % file
	if ResourceLoader.exists(path):
		var res: Variant = load(path)
		if res is Texture2D:
			return res as Texture2D
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)
