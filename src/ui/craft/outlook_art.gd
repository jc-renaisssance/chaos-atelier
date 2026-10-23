class_name OutlookArt
extends RefCounted
## Current + Potential sockets (docs/35 Current A). 28 Soft slots (Art #81).
## Same texture on both sockets when the winning outlook is unlocked.
## Locked outlooks hide both. Ids outside this table have no file.
## Not slots: royal alias, cross _3 / _8, mat_*.png, monostacks with no file.

const PX := 96

const TEXTURES := {
	"plain": preload("res://assets/outlook/look_armor_plain.png"),
	"syn_metal_3": preload("res://assets/outlook/look_armor_metal_2.png"),
	"syn_metal_5": preload("res://assets/outlook/look_armor_metal_3.png"),
	"syn_metal_8": preload("res://assets/outlook/look_armor_metal_8.png"),
	"syn_earth_3": preload("res://assets/outlook/look_armor_earth_2.png"),
	"syn_earth_5": preload("res://assets/outlook/look_armor_earth_3.png"),
	"syn_earth_8": preload("res://assets/outlook/look_armor_earth_8.png"),
	"syn_fire_3": preload("res://assets/outlook/look_armor_fire_2.png"),
	"syn_fire_5": preload("res://assets/outlook/look_armor_fire_3.png"),
	"syn_fire_8": preload("res://assets/outlook/look_armor_fire_8.png"),
	"syn_frost_3": preload("res://assets/outlook/look_armor_frost_2.png"),
	"syn_frost_5": preload("res://assets/outlook/look_armor_frost_3.png"),
	"syn_frost_8": preload("res://assets/outlook/look_armor_frost_8.png"),
	"syn_silent_3": preload("res://assets/outlook/look_armor_silent_3.png"),
	"syn_silent_5": preload("res://assets/outlook/look_armor_silent_5.png"),
	"syn_silent_8": preload("res://assets/outlook/look_armor_silent_8.png"),
	"syn_royal_3": preload("res://assets/outlook/look_armor_royal_3.png"),
	"syn_royal_5": preload("res://assets/outlook/look_armor_royal_5.png"),
	"syn_royal_8": preload("res://assets/outlook/look_armor_royal_8.png"),
	"syn_silk_3": preload("res://assets/outlook/look_armor_silk_3.png"),
	"syn_silk_5": preload("res://assets/outlook/look_armor_silk_5.png"),
	"syn_silk_8": preload("res://assets/outlook/look_armor_silk_8.png"),
	"syn_fire_frost_clash": preload("res://assets/outlook/look_armor_cross_storm_5.png"),
	"syn_wild_earth": preload("res://assets/outlook/look_armor_cross_beastbloom_5.png"),
	"syn_sticky_sharp": preload("res://assets/outlook/look_armor_cross_snaretooth_5.png"),
	"syn_royal_silent": preload("res://assets/outlook/look_armor_cross_masked_crown_5.png"),
	"syn_solar_pure": preload("res://assets/outlook/look_armor_cross_dawn_vestment_5.png"),
	"syn_lunar_occult": preload("res://assets/outlook/look_armor_cross_pale_hex_5.png"),
}


static func texture_for(outlook_id: String) -> Texture2D:
	var res: Variant = TEXTURES.get(outlook_id, null)
	if res is Texture2D:
		return res as Texture2D
	return null
