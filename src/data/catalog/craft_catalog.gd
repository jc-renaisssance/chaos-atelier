class_name CraftCatalog
extends RefCounted
## own_basic starter + play costs + tag/stat bags (docs/11, 12, 13, 19, 27, 39).
## Construction is order-fixed — never a hand card.

const SKILL_BLURBS := {
	"sk_next_mat_free": "Next material play costs 0 stamina.",
	"sk_metal_str_double": "Double ATK from committed Metal materials in this item.",
	"sk_wild_to_earth": "Convert the latest committed Wild material in this item to Earth affinity.",
	"sk_touch_up": "+1 to the strongest positive stat on the latest committed material in this item.",
	"sk_deep_dig": "Discard the unplayed hand and refill to hand size.",
	"sk_steady_hand": "Ignore the first negative synergy on this item.",
	"sk_ease_draw": "The next card played into a zone costs 1 less stamina, floor 0. Then draw 1",
	"sk_scrap_breath": "Discard 1 other card from hand. If that discard happens, stamina +1 (AP).",
	"sk_heavy_draw": "The next card played into a zone contributes ×1.5 stats, each stat rounded half away from zero. Tags stay as printed. Then draw 1",
}

## id → {name, family, dollar, HP, ATK, DEF, RES, MOB, PRE, tags}
const MATERIALS := {
	"mat_hemp_plain": {"name": "Plain Hemp", "family": "Cloth", "dollar": 1, "HP": 1, "ATK": 0, "DEF": 1, "RES": 0, "MOB": 0, "PRE": 0, "tags": ["Soft"]},
	"mat_cotton_spring": {"name": "Spring Cotton", "family": "Cloth", "dollar": 2, "HP": 1, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 0, "tags": ["Soft", "Pure"]},
	"mat_wool_grey": {"name": "Grey Wool", "family": "Cloth", "dollar": 2, "HP": 2, "ATK": 0, "DEF": 1, "RES": 1, "MOB": -1, "PRE": 0, "tags": ["Soft", "Earth"]},
	"mat_silk_pale": {"name": "Pale Silk", "family": "Silk", "dollar": 3, "HP": 0, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 1, "PRE": 1, "tags": ["Silk"]},
	"mat_leather_tan": {"name": "Tan Leather", "family": "Leather", "dollar": 2, "HP": 1, "ATK": 0, "DEF": 2, "RES": 0, "MOB": 0, "PRE": 0, "tags": ["Wild"]},
	"mat_leather_dusk": {"name": "Dusk Leather", "family": "Leather", "dollar": 3, "HP": 1, "ATK": 0, "DEF": 1, "RES": 0, "MOB": 2, "PRE": 0, "tags": ["Silent", "Wild"]},
	"mat_linen_storm": {"name": "Storm Linen", "family": "Cloth", "dollar": 3, "HP": 1, "ATK": 1, "DEF": 0, "RES": 1, "MOB": 1, "PRE": 0, "tags": ["Storm"]},
	"mat_velvet_court": {"name": "Court Velvet", "family": "Silk", "dollar": 4, "HP": 1, "ATK": 0, "DEF": 0, "RES": 0, "MOB": 0, "PRE": 3, "tags": ["Royal", "Silk"]},
	"mat_iron_scrap": {"name": "Iron Scrap", "family": "Metal", "dollar": 1, "HP": 1, "ATK": 0, "DEF": 1, "RES": 0, "MOB": -1, "PRE": 0, "tags": ["Metal"]},
	"mat_bronze_scale": {"name": "Bronze Scale", "family": "Metal", "dollar": 2, "HP": 2, "ATK": 0, "DEF": 2, "RES": 0, "MOB": -1, "PRE": 0, "tags": ["Metal"]},
	"mat_wirecloth": {"name": "Wirecloth", "family": "Metal", "dollar": 3, "HP": 2, "ATK": 1, "DEF": 2, "RES": 0, "MOB": -1, "PRE": 0, "tags": ["Metal"]},
	"mat_steel_plate": {"name": "Steel Plate", "family": "Metal", "dollar": 4, "HP": 3, "ATK": 0, "DEF": 3, "RES": 0, "MOB": -2, "PRE": 0, "tags": ["Metal"]},
	"mat_chainlace": {"name": "Chainlace", "family": "Metal", "dollar": 4, "HP": 2, "ATK": 0, "DEF": 3, "RES": 0, "MOB": -2, "PRE": 1, "tags": ["Metal", "Royal"]},
	"mat_skyiron_filigree": {"name": "Skyiron Filigree", "family": "Metal", "dollar": 5, "HP": 1, "ATK": 1, "DEF": 2, "RES": 1, "MOB": 0, "PRE": 1, "tags": ["Metal", "Storm"]},
	"mat_clayweave": {"name": "Clayweave", "family": "Stone", "dollar": 2, "HP": 2, "ATK": 0, "DEF": 2, "RES": 0, "MOB": -1, "PRE": 0, "tags": ["Earth"]},
	"mat_stone_shard": {"name": "Stone Shard", "family": "Stone", "dollar": 2, "HP": 2, "ATK": 0, "DEF": 2, "RES": 0, "MOB": -2, "PRE": 0, "tags": ["Earth", "Metal"]},
	"mat_stonefiber": {"name": "Stonefiber", "family": "Stone", "dollar": 3, "HP": 3, "ATK": 0, "DEF": 3, "RES": 1, "MOB": -2, "PRE": 0, "tags": ["Earth", "Metal"]},
	"mat_ember_silk": {"name": "Ember Silk", "family": "Silk", "dollar": 3, "HP": 0, "ATK": 2, "DEF": 0, "RES": -1, "MOB": 1, "PRE": 0, "tags": ["Fire", "Silk"]},
	"mat_magma_thread": {"name": "Magma Thread", "family": "Odd", "dollar": 4, "HP": 1, "ATK": 2, "DEF": 1, "RES": -2, "MOB": 0, "PRE": 0, "tags": ["Fire", "Metal"]},
	"mat_frostwool": {"name": "Frostwool", "family": "Cloth", "dollar": 3, "HP": 1, "ATK": 0, "DEF": 1, "RES": 2, "MOB": -1, "PRE": 0, "tags": ["Frost", "Soft"]},
	"mat_glacier_hide": {"name": "Glacier Hide", "family": "Leather", "dollar": 4, "HP": 2, "ATK": 0, "DEF": 2, "RES": 2, "MOB": -2, "PRE": 0, "tags": ["Frost", "Wild"]},
	"mat_moonlace": {"name": "Moonlace", "family": "Silk", "dollar": 4, "HP": 0, "ATK": 0, "DEF": 0, "RES": 2, "MOB": 1, "PRE": 2, "tags": ["Lunar", "Silk"]},
	"mat_silver_moth": {"name": "Silver Moth Silk", "family": "Silk", "dollar": 5, "HP": 0, "ATK": 1, "DEF": 0, "RES": 2, "MOB": 2, "PRE": 1, "tags": ["Lunar", "Silent", "Silk"]},
	"mat_suncloth": {"name": "Suncloth", "family": "Cloth", "dollar": 3, "HP": 1, "ATK": 1, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 1, "tags": ["Solar"]},
	"mat_aureate_foil": {"name": "Aureate Foil", "family": "Metal", "dollar": 4, "HP": 0, "ATK": 0, "DEF": 1, "RES": 0, "MOB": 0, "PRE": 3, "tags": ["Solar", "Metal", "Royal"]},
	"mat_ivy_cord": {"name": "Ivy Cord", "family": "Odd", "dollar": 2, "HP": 1, "ATK": 1, "DEF": 0, "RES": 1, "MOB": 1, "PRE": 0, "tags": ["Wild", "Earth"]},
	"mat_dire_fur": {"name": "Dire Fur", "family": "Leather", "dollar": 4, "HP": 2, "ATK": 2, "DEF": 1, "RES": 0, "MOB": 0, "PRE": -1, "tags": ["Wild", "Sharp"]},
	"mat_whisper_gauze": {"name": "Whisper Gauze", "family": "Cloth", "dollar": 3, "HP": 0, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 3, "PRE": 0, "tags": ["Silent", "Soft"]},
	"mat_tar_thread": {"name": "Tar Thread", "family": "Odd", "dollar": 2, "HP": 2, "ATK": 0, "DEF": 1, "RES": 0, "MOB": -2, "PRE": -1, "tags": ["Sticky", "Earth"]},
	"mat_resin_silk": {"name": "Resin Silk", "family": "Silk", "dollar": 3, "HP": 1, "ATK": 0, "DEF": 1, "RES": 1, "MOB": -1, "PRE": 0, "tags": ["Sticky", "Silk"]},
	"mat_needlegrass": {"name": "Needlegrass Cloth", "family": "Cloth", "dollar": 3, "HP": 0, "ATK": 3, "DEF": 0, "RES": 0, "MOB": 1, "PRE": -1, "tags": ["Sharp", "Wild"]},
	"mat_bladewool": {"name": "Bladewool", "family": "Cloth", "dollar": 4, "HP": 1, "ATK": 3, "DEF": 1, "RES": 0, "MOB": 0, "PRE": 0, "tags": ["Sharp", "Metal"]},
	"mat_downcloud": {"name": "Downcloud", "family": "Cloth", "dollar": 3, "HP": 1, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 1, "PRE": 1, "tags": ["Soft", "Solar"]},
	"mat_milkfleece": {"name": "Milkfleece", "family": "Cloth", "dollar": 2, "HP": 1, "ATK": 0, "DEF": 0, "RES": 2, "MOB": 0, "PRE": 1, "tags": ["Soft", "Pure"]},
	"mat_grave_silk": {"name": "Grave Silk", "family": "Silk", "dollar": 4, "HP": 0, "ATK": 1, "DEF": 0, "RES": 2, "MOB": 0, "PRE": -2, "tags": ["Occult", "Silk"]},
	"mat_null_ink_cloth": {"name": "Null-Ink Cloth", "family": "Odd", "dollar": 5, "HP": 1, "ATK": 0, "DEF": 1, "RES": 3, "MOB": 0, "PRE": -1, "tags": ["Occult", "Pure"]},
	"mat_altar_linen": {"name": "Altar Linen", "family": "Cloth", "dollar": 3, "HP": 1, "ATK": 0, "DEF": 1, "RES": 2, "MOB": 0, "PRE": 2, "tags": ["Pure", "Soft"]},
	"mat_skybone_weave": {"name": "Skybone Weave", "family": "Odd", "dollar": 5, "HP": 1, "ATK": 2, "DEF": 0, "RES": 2, "MOB": 2, "PRE": 0, "tags": ["Storm", "Wild"]},
}

const CONSTRUCTIONS := {
	"con_robe": {"name": "Robe", "HP": 1, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 1, "tags": ["Silk"]},
	"con_armor": {"name": "Armor", "HP": 2, "ATK": 0, "DEF": 2, "RES": 0, "MOB": -2, "PRE": 0, "tags": ["Metal"]},
	"con_cloak": {"name": "Cloak", "HP": 0, "ATK": 0, "DEF": 1, "RES": 1, "MOB": 1, "PRE": 0, "tags": ["Silent"]},
	"con_coat": {"name": "Coat", "HP": 1, "ATK": 0, "DEF": 1, "RES": 0, "MOB": 0, "PRE": 1, "tags": ["Royal"]},
	"con_tunic": {"name": "Tunic", "HP": 0, "ATK": 1, "DEF": 0, "RES": 0, "MOB": 1, "PRE": 0, "tags": ["Soft"]},
	"con_boots": {"name": "Boots", "HP": 0, "ATK": 0, "DEF": 1, "RES": 0, "MOB": 2, "PRE": 0, "tags": ["Earth"]},
	"con_gloves": {"name": "Gloves", "HP": 0, "ATK": 1, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 0, "tags": ["Sharp"]},
	"con_hood": {"name": "Hood", "HP": 0, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 1, "PRE": -1, "tags": ["Silent"]},
	"con_crownveil": {"name": "Crownveil", "HP": 0, "ATK": 0, "DEF": 0, "RES": 1, "MOB": -1, "PRE": 3, "tags": ["Royal", "Solar"]},
	"con_mantle": {"name": "Mantle", "HP": 1, "ATK": 0, "DEF": 1, "RES": 1, "MOB": -1, "PRE": 1, "tags": ["Royal"]},
	"con_wraps": {"name": "Wraps", "HP": 1, "ATK": 0, "DEF": 0, "RES": 0, "MOB": 1, "PRE": 0, "tags": ["Sticky"]},
	"con_cape": {"name": "Cape", "HP": 0, "ATK": 1, "DEF": 0, "RES": 0, "MOB": 1, "PRE": 1, "tags": ["Silk"]},
}

const ENCHANTMENTS := {
	"enc_rune_ember": {"name": "Ember Rune", "dollar": 2, "HP": 0, "ATK": 1, "DEF": 0, "RES": 0, "MOB": 0, "PRE": 0, "tags": ["Fire"]},
	"enc_rune_frost": {"name": "Frost Rune", "dollar": 2, "HP": 0, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 0, "tags": ["Frost"]},
	"enc_rune_gale": {"name": "Gale Rune", "dollar": 2, "HP": 0, "ATK": 0, "DEF": 0, "RES": 0, "MOB": 1, "PRE": 0, "tags": ["Storm"]},
	"enc_rune_stone": {"name": "Stone Rune", "dollar": 2, "HP": 1, "ATK": 0, "DEF": 1, "RES": 0, "MOB": -1, "PRE": 0, "tags": ["Earth"]},
	"enc_rune_moon": {"name": "Moon Rune", "dollar": 3, "HP": 0, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 1, "tags": ["Lunar"]},
	"enc_rune_sun": {"name": "Sun Rune", "dollar": 3, "HP": 0, "ATK": 1, "DEF": 0, "RES": 0, "MOB": 0, "PRE": 1, "tags": ["Solar"]},
	"enc_rune_quiet": {"name": "Quiet Rune", "dollar": 2, "HP": 0, "ATK": 0, "DEF": 0, "RES": 0, "MOB": 1, "PRE": 0, "tags": ["Silent"]},
	"enc_rune_bind": {"name": "Bind Rune", "dollar": 2, "HP": 1, "ATK": 0, "DEF": 0, "RES": 0, "MOB": -1, "PRE": 0, "tags": ["Sticky"]},
	"enc_rune_thorn": {"name": "Thorn Rune", "dollar": 2, "HP": 0, "ATK": 1, "DEF": 0, "RES": 0, "MOB": 0, "PRE": 0, "tags": ["Sharp"]},
	"enc_rune_balm": {"name": "Balm Rune", "dollar": 2, "HP": 1, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 0, "tags": ["Soft", "Pure"]},
	"enc_rune_beast": {"name": "Beast Rune", "dollar": 3, "HP": 0, "ATK": 1, "DEF": 0, "RES": 0, "MOB": 1, "PRE": -1, "tags": ["Wild"]},
	"enc_rune_crown": {"name": "Crown Rune", "dollar": 3, "HP": 0, "ATK": 0, "DEF": 0, "RES": 0, "MOB": 0, "PRE": 2, "tags": ["Royal"]},
	"enc_rune_hex": {"name": "Hex Rune", "dollar": 4, "HP": 0, "ATK": 1, "DEF": 0, "RES": 1, "MOB": 0, "PRE": -2, "tags": ["Occult"]},
	"enc_rune_ward": {"name": "Ward Rune", "dollar": 3, "HP": 1, "ATK": 0, "DEF": 1, "RES": 1, "MOB": 0, "PRE": 0, "tags": ["Pure"]},
	"enc_rune_iron": {"name": "Iron Rune", "dollar": 2, "HP": 1, "ATK": 0, "DEF": 1, "RES": 0, "MOB": -1, "PRE": 0, "tags": ["Metal"]},
	"enc_sigil_dragon": {"name": "Dragon Sigil", "dollar": 5, "HP": 0, "ATK": 2, "DEF": 0, "RES": 0, "MOB": 0, "PRE": 1, "tags": ["Fire", "Wild"]},
	"enc_sigil_ghost": {"name": "Ghost Sigil", "dollar": 5, "HP": 0, "ATK": 0, "DEF": 0, "RES": 2, "MOB": 1, "PRE": -1, "tags": ["Lunar", "Silent", "Occult"]},
	"enc_sigil_vow": {"name": "Vow Sigil", "dollar": 5, "HP": 1, "ATK": 0, "DEF": 0, "RES": 1, "MOB": 0, "PRE": 2, "tags": ["Royal", "Pure"]},
}

## docs/40 — one selected bolt supplies three tagged copies. Run-start selection is Later;
## Ember is the production default until the three-start screen owns that choice.
const STARTER_BOLTS := {
	"ember": ["mat_ember_silk", "bolt_ember"],
	"hearth": ["mat_hemp_plain", "bolt_hearth"],
	"cairn": ["mat_clayweave", "bolt_cairn"],
	"forge": ["mat_iron_scrap", "bolt_forge"],
	"fineweave": ["mat_silk_pale", "bolt_fineweave"],
}
const DEFAULT_STARTER_BOLT := "ember"

## 10 cards: 3 bolt materials / 4 neutral materials / 3 skills.
const OWN_BASIC_COMMON_STARTER := [
	["mat_hemp_plain", GameEnums.HandCardType.MATERIAL, "no_tag"],
	["mat_hemp_plain", GameEnums.HandCardType.MATERIAL, "no_tag"],
	["mat_hemp_plain", GameEnums.HandCardType.MATERIAL, "no_tag"],
	["mat_hemp_plain", GameEnums.HandCardType.MATERIAL, "no_tag"],
	["sk_ease_draw", GameEnums.HandCardType.SKILL, "skill"],
	["sk_scrap_breath", GameEnums.HandCardType.SKILL, "skill"],
	["sk_heavy_draw", GameEnums.HandCardType.SKILL, "skill"],
]


static func own_basic_starter(bolt_id: String = DEFAULT_STARTER_BOLT) -> Array[HandCard]:
	var out: Array[HandCard] = []
	var bolt: Array = STARTER_BOLTS.get(bolt_id, STARTER_BOLTS[DEFAULT_STARTER_BOLT])
	for _i in range(3):
		out.append(HandCard.make(String(bolt[0]), GameEnums.HandCardType.MATERIAL, "", false, String(bolt[1])))
	for row in OWN_BASIC_COMMON_STARTER:
		var kind: GameEnums.HandCardType = row[1]
		out.append(HandCard.make(String(row[0]), kind, "", false, String(row[2])))
	return out


static func material(id: String) -> Dictionary:
	return MATERIALS.get(id, {})


static func construction(id: String) -> Dictionary:
	return CONSTRUCTIONS.get(id, {})


static func enchantment(id: String) -> Dictionary:
	return ENCHANTMENTS.get(id, {})


static func display_name(id: String, type: GameEnums.HandCardType) -> String:
	match type:
		GameEnums.HandCardType.MATERIAL:
			return String(material(id).get("name", id))
		GameEnums.HandCardType.RUNE:
			return String(enchantment(id).get("name", id))
		GameEnums.HandCardType.SKILL:
			return id.trim_prefix("sk_").replace("_", " ")
		_:
			return id


static func construction_name(id: String) -> String:
	return String(construction(id).get("name", id))


static func skill_blurb(id: String) -> String:
	return String(SKILL_BLURBS.get(id, "Owner skill — manipulates the session, then leaves."))


## Starter printings may withhold catalog tags so one bolt opens one readable direction.
static func tags_for_card(card: HandCard) -> PackedStringArray:
	if card == null:
		return PackedStringArray()
	var override: Variant = _starter_tag_override(card.starter_role)
	if override != null:
		return override
	return tags_of(card.id, card.type)


static func tags_for_played(card: PlayedCard) -> PackedStringArray:
	if card == null:
		return PackedStringArray()
	var override: Variant = _starter_tag_override(card.starter_role)
	if override != null:
		return override
	return tags_of(card.id, card.type)


static func _starter_tag_override(starter_role: String):
	match starter_role:
		"no_tag":
			return PackedStringArray()
		"bolt_ember":
			return PackedStringArray(["Fire"])
		"bolt_hearth":
			return PackedStringArray(["Soft"])
		"bolt_cairn":
			return PackedStringArray(["Earth"])
		"bolt_forge":
			return PackedStringArray(["Metal"])
		"bolt_fineweave":
			return PackedStringArray(["Silk"])
		_:
			return null


## n × 1.5, half away from zero (docs/39 sk_heavy_draw). 1 → 2, 2 → 3, −1 → −2.
static func scale_half_away(n: int) -> int:
	var mag := absi(n * 3)
	var rounded := (mag + 1) / 2
	if n < 0:
		return -rounded
	return rounded


static func scaled_stat_bag(bag: Dictionary) -> Dictionary:
	return {
		"HP": scale_half_away(int(bag.get("HP", 0))),
		"ATK": scale_half_away(int(bag.get("ATK", 0))),
		"DEF": scale_half_away(int(bag.get("DEF", 0))),
		"RES": scale_half_away(int(bag.get("RES", 0))),
		"MOB": scale_half_away(int(bag.get("MOB", 0))),
		"PRE": scale_half_away(int(bag.get("PRE", 0))),
	}


static func tags_of(id: String, type: GameEnums.HandCardType) -> PackedStringArray:
	var row := {}
	match type:
		GameEnums.HandCardType.MATERIAL:
			row = material(id)
		GameEnums.HandCardType.RUNE:
			row = enchantment(id)
		_:
			return PackedStringArray()
	var tags: Array = row.get("tags", [])
	return PackedStringArray(tags)


## Existing tags migrate to one pip. Rows may author tag_pips overrides without
## coupling intensity to price or rarity.
static func tag_pips_of(id: String, type: GameEnums.HandCardType) -> Dictionary:
	var row := {}
	match type:
		GameEnums.HandCardType.MATERIAL:
			row = material(id)
		GameEnums.HandCardType.RUNE:
			row = enchantment(id)
		_:
			return {}
	return _tag_pips_from_row(row)


static func tag_pips_for_played(card: PlayedCard) -> Dictionary:
	if card == null:
		return {}
	var override: Variant = _starter_tag_override(card.starter_role)
	var pips := {}
	if override != null:
		for tag in override:
			pips[String(tag)] = 1
	else:
		pips = tag_pips_of(card.id, card.type)
	for tag in card.suppressed_tags:
		pips.erase(String(tag))
	for tag in card.tag_pip_bonus.keys():
		pips[tag] = int(pips.get(tag, 0)) + int(card.tag_pip_bonus[tag])
	if card.type == GameEnums.HandCardType.MATERIAL and tag_copies(card.mat_enchant_id) > 1:
		for tag in pips.keys():
			pips[tag] = int(pips[tag]) * 2
	return pips


static func construction_tag_pips(id: String) -> Dictionary:
	return _tag_pips_from_row(construction(id))


static func _tag_pips_from_row(row: Dictionary) -> Dictionary:
	var out := {}
	var authored: Dictionary = Dictionary(row.get("tag_pips", {}))
	for tag in row.get("tags", []):
		var key := String(tag)
		out[key] = maxi(0, int(authored.get(key, 1)))
	return out


static func construction_tags(id: String) -> PackedStringArray:
	var tags: Array = construction(id).get("tags", [])
	return PackedStringArray(tags)


static func stat_bag(id: String, type: GameEnums.HandCardType) -> Dictionary:
	var row := {}
	match type:
		GameEnums.HandCardType.MATERIAL:
			row = material(id)
		GameEnums.HandCardType.RUNE:
			row = enchantment(id)
		_:
			return {"HP": 0, "ATK": 0, "DEF": 0, "RES": 0, "MOB": 0, "PRE": 0}
	return {
		"HP": int(row.get("HP", 0)),
		"ATK": int(row.get("ATK", 0)),
		"DEF": int(row.get("DEF", 0)),
		"RES": int(row.get("RES", 0)),
		"MOB": int(row.get("MOB", 0)),
		"PRE": int(row.get("PRE", 0)),
	}


static func construction_stats(id: String) -> Dictionary:
	var row := construction(id)
	return {
		"HP": int(row.get("HP", 0)),
		"ATK": int(row.get("ATK", 0)),
		"DEF": int(row.get("DEF", 0)),
		"RES": int(row.get("RES", 0)),
		"MOB": int(row.get("MOB", 0)),
		"PRE": int(row.get("PRE", 0)),
	}


static func shop_dollar(id: String, type: GameEnums.HandCardType) -> int:
	match type:
		GameEnums.HandCardType.MATERIAL:
			return int(material(id).get("dollar", 1))
		GameEnums.HandCardType.RUNE:
			return int(enchantment(id).get("dollar", 2))
		_:
			return 0


static func effective_dollar(card: HandCard) -> int:
	if card == null:
		return 0
	return effective_dollar_of(card.id, card.type, card.mat_enchant_id)


static func effective_dollar_of(id: String, type: GameEnums.HandCardType, mat_enchant_id: String) -> int:
	var base := shop_dollar(id, type)
	if type != GameEnums.HandCardType.MATERIAL or mat_enchant_id.is_empty():
		return base
	if mat_enchant_id == GameConstants.MAT_ENCH_THRIFT:
		return maxi(1, base / 2)
	if mat_enchant_id == GameConstants.MAT_ENCH_HEAVY:
		return base * 2
	return base


static func tag_copies(mat_enchant_id: String) -> int:
	if mat_enchant_id == GameConstants.MAT_ENCH_HEAVY:
		return 2
	return 1


## Play-cost rarity from shop $ (docs/27 knobs 1 / 2 / 3). $1–2 common, $3 uncommon, $4–5 rare.
static func dollar_to_play_rarity(dollar: int) -> GameEnums.CraftRarity:
	if dollar >= 4:
		return GameEnums.CraftRarity.RARE
	if dollar >= 3:
		return GameEnums.CraftRarity.UNCOMMON
	return GameEnums.CraftRarity.COMMON


## AP and stamina are one meter (docs/39 lock 3). next_cost_less is sk_ease_draw: −1, floor 0.
## Dig is not a card. next_mat_free still zeroes the next material (the bought skill).
static func play_cost(card: HandCard, next_mat_free: bool, next_cost_less: int = 0) -> int:
	if card == null:
		return 0
	var cost := 0
	match card.type:
		GameEnums.HandCardType.SKILL:
			cost = int(GameConstants.OWNER_SKILL_DRAFT_COSTS.get(card.id, 1))
		GameEnums.HandCardType.RUNE:
			cost = GameConstants.ENC_PLAY_COST
		_:
			if next_mat_free:
				cost = 0
			else:
				cost = GameConstants.material_play_cost(dollar_to_play_rarity(effective_dollar(card)))
	if next_cost_less > 0:
		cost = maxi(0, cost - next_cost_less)
	return cost


static func type_label(type: GameEnums.HandCardType) -> String:
	return GameEnums.hand_card_type_wire(type)
