class_name MatFace
extends RefCounted
## Mat path A (docs/36). res://assets/mat/<id>.png
## The ×38 on dev (Art #84) are preloaded so the hand, the zone icon, and the shelf light.
## An id that is not in that set still hide-if-missing. look_armor is never a mat face.
## Skill cards use assets/m2-market/<sk_id>.png when that file exists. Runes stay on the chip well.

const ICON_PX := 32
const MAT_PATH := "res://assets/mat/%s.png"
const SKILL_PATH := "res://assets/m2-market/%s.png"

const TEXTURES := {
	"mat_hemp_plain": preload("res://assets/mat/mat_hemp_plain.png"),
	"mat_cotton_spring": preload("res://assets/mat/mat_cotton_spring.png"),
	"mat_wool_grey": preload("res://assets/mat/mat_wool_grey.png"),
	"mat_silk_pale": preload("res://assets/mat/mat_silk_pale.png"),
	"mat_leather_tan": preload("res://assets/mat/mat_leather_tan.png"),
	"mat_leather_dusk": preload("res://assets/mat/mat_leather_dusk.png"),
	"mat_linen_storm": preload("res://assets/mat/mat_linen_storm.png"),
	"mat_velvet_court": preload("res://assets/mat/mat_velvet_court.png"),
	"mat_iron_scrap": preload("res://assets/mat/mat_iron_scrap.png"),
	"mat_bronze_scale": preload("res://assets/mat/mat_bronze_scale.png"),
	"mat_wirecloth": preload("res://assets/mat/mat_wirecloth.png"),
	"mat_steel_plate": preload("res://assets/mat/mat_steel_plate.png"),
	"mat_chainlace": preload("res://assets/mat/mat_chainlace.png"),
	"mat_skyiron_filigree": preload("res://assets/mat/mat_skyiron_filigree.png"),
	"mat_clayweave": preload("res://assets/mat/mat_clayweave.png"),
	"mat_stone_shard": preload("res://assets/mat/mat_stone_shard.png"),
	"mat_stonefiber": preload("res://assets/mat/mat_stonefiber.png"),
	"mat_ember_silk": preload("res://assets/mat/mat_ember_silk.png"),
	"mat_magma_thread": preload("res://assets/mat/mat_magma_thread.png"),
	"mat_frostwool": preload("res://assets/mat/mat_frostwool.png"),
	"mat_glacier_hide": preload("res://assets/mat/mat_glacier_hide.png"),
	"mat_moonlace": preload("res://assets/mat/mat_moonlace.png"),
	"mat_silver_moth": preload("res://assets/mat/mat_silver_moth.png"),
	"mat_suncloth": preload("res://assets/mat/mat_suncloth.png"),
	"mat_aureate_foil": preload("res://assets/mat/mat_aureate_foil.png"),
	"mat_ivy_cord": preload("res://assets/mat/mat_ivy_cord.png"),
	"mat_dire_fur": preload("res://assets/mat/mat_dire_fur.png"),
	"mat_whisper_gauze": preload("res://assets/mat/mat_whisper_gauze.png"),
	"mat_tar_thread": preload("res://assets/mat/mat_tar_thread.png"),
	"mat_resin_silk": preload("res://assets/mat/mat_resin_silk.png"),
	"mat_needlegrass": preload("res://assets/mat/mat_needlegrass.png"),
	"mat_bladewool": preload("res://assets/mat/mat_bladewool.png"),
	"mat_downcloud": preload("res://assets/mat/mat_downcloud.png"),
	"mat_milkfleece": preload("res://assets/mat/mat_milkfleece.png"),
	"mat_grave_silk": preload("res://assets/mat/mat_grave_silk.png"),
	"mat_null_ink_cloth": preload("res://assets/mat/mat_null_ink_cloth.png"),
	"mat_altar_linen": preload("res://assets/mat/mat_altar_linen.png"),
	"mat_skybone_weave": preload("res://assets/mat/mat_skybone_weave.png"),
}


static func path_for(card_id: String, card_type: GameEnums.HandCardType) -> String:
	if card_id.is_empty() or card_id.begins_with("look_"):
		return ""
	match card_type:
		GameEnums.HandCardType.MATERIAL:
			if not card_id.begins_with("mat_"):
				return ""
			return MAT_PATH % card_id
		GameEnums.HandCardType.SKILL:
			if not card_id.begins_with("sk_"):
				return ""
			return SKILL_PATH % card_id
		_:
			return ""


static func texture_for(card_id: String, card_type: GameEnums.HandCardType) -> Texture2D:
	if card_id.begins_with("look_"):
		return null
	if card_type == GameEnums.HandCardType.MATERIAL:
		var landed: Variant = TEXTURES.get(card_id)
		if landed is Texture2D:
			return landed as Texture2D
	var path := path_for(card_id, card_type)
	return _load_optional(path)


static func _load_optional(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var loaded: Variant = load(path)
	return loaded as Texture2D
