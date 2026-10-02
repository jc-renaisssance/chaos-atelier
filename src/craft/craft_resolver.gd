class_name CraftResolver
extends RefCounted
## Tag tally + rarity + synergy rows (docs/14, 18, 20). Mission grade is MissionResolver.

const POSITIVE_TAG_ROWS := [
	{"id": "syn_fire_3", "tag": "Fire", "tier": 1, "outlook_order": 90},
	{"id": "syn_fire_5", "tag": "Fire", "tier": 2, "outlook_order": 100},
	{"id": "syn_fire_8", "tag": "Fire", "tier": 3, "outlook_order": 110},
	{"id": "syn_frost_3", "tag": "Frost", "tier": 1, "outlook_order": 50},
	{"id": "syn_storm_3", "tag": "Storm", "tier": 1, "outlook_order": 55},
	{"id": "syn_earth_3", "tag": "Earth", "tier": 1, "outlook_order": 20},
	{"id": "syn_earth_5", "tag": "Earth", "tier": 2, "outlook_order": 25},
	{"id": "syn_earth_8", "tag": "Earth", "tier": 3, "outlook_order": 28},
	{"id": "syn_lunar_3", "tag": "Lunar", "tier": 1, "outlook_order": 80},
	{"id": "syn_solar_3", "tag": "Solar", "tier": 1, "outlook_order": 75},
	{"id": "syn_royal_3", "tag": "Royal", "tier": 1, "outlook_order": 70},
	{"id": "syn_silent_3", "tag": "Silent", "tier": 1, "outlook_order": 35},
	{"id": "syn_sticky_3", "tag": "Sticky", "tier": 1, "outlook_order": 40},
	{"id": "syn_sharp_3", "tag": "Sharp", "tier": 1, "outlook_order": 45},
	{"id": "syn_soft_3", "tag": "Soft", "tier": 1, "outlook_order": 12},
	{"id": "syn_wild_3", "tag": "Wild", "tier": 1, "outlook_order": 60},
	{"id": "syn_occult_3", "tag": "Occult", "tier": 1, "outlook_order": 85},
	{"id": "syn_pure_3", "tag": "Pure", "tier": 1, "outlook_order": 65},
	{"id": "syn_metal_3", "tag": "Metal", "tier": 1, "outlook_order": 30},
	{"id": "syn_metal_5", "tag": "Metal", "tier": 2, "outlook_order": 32},
	{"id": "syn_metal_8", "tag": "Metal", "tier": 3, "outlook_order": 34},
	{"id": "syn_silk_3", "tag": "Silk", "tier": 1, "outlook_order": 10},
]

const CROSS_ROWS := [
	{"id": "syn_fire_frost_clash", "a": "Fire", "b": "Frost", "outlook_order": 15},
	{"id": "syn_royal_silent", "a": "Royal", "b": "Silent", "outlook_order": 72},
	{"id": "syn_sticky_sharp", "a": "Sticky", "b": "Sharp", "outlook_order": 48},
	{"id": "syn_lunar_occult", "a": "Lunar", "b": "Occult", "outlook_order": 88},
	{"id": "syn_solar_pure", "a": "Solar", "b": "Pure", "outlook_order": 78},
	{"id": "syn_wild_earth", "a": "Wild", "b": "Earth", "outlook_order": 22},
]

const NEG_ROWS := [
	{"id": "syn_neg_metal_silk", "a": "Metal", "amin": 3, "b": "Silk", "bmin": 3, "outlook_order": 36},
	{"id": "syn_neg_hood_metal", "construction": "con_hood", "tag": "Metal", "min": 1, "outlook_order": 39},
	{"id": "syn_neg_cloak_metal", "construction": "con_cloak", "tag": "Metal", "min": 1, "outlook_order": 41},
	{"id": "syn_neg_metal_silent", "a": "Metal", "amin": 1, "b": "Silent", "bmin": 1, "outlook_order": 44},
	{"id": "syn_neg_soft_sharp", "a": "Soft", "amin": 1, "b": "Sharp", "bmin": 1, "outlook_order": 52},
	{"id": "syn_neg_sticky_royal", "a": "Sticky", "amin": 1, "b": "Royal", "bmin": 1, "outlook_order": 82},
	{"id": "syn_neg_occult_pure", "a": "Occult", "amin": 1, "b": "Pure", "bmin": 1, "outlook_order": 92},
	{"id": "syn_neg_fire_soft", "a": "Fire", "amin": 1, "b": "Soft", "bmin": 1, "outlook_order": 105},
]


static func _tier_min(tier: int) -> int:
	match tier:
		2:
			return GameConstants.SYN_THRESHOLD_TIER_2
		3:
			return GameConstants.SYN_THRESHOLD_APEX
		_:
			return GameConstants.SYN_THRESHOLD_TIER_1


static func tag_counts(session: CraftStaminaSession, construction_id: String) -> Dictionary:
	var bag := {}
	_add_tags(bag, CraftCatalog.construction_tags(construction_id))
	if session == null:
		return bag
	for card in session.cards_played:
		if card.type == GameEnums.HandCardType.SKILL:
			continue
		_add_tags(bag, CraftCatalog.tags_of(card.id, card.type))
	return bag


static func _add_tags(bag: Dictionary, tags: PackedStringArray) -> void:
	for tag in tags:
		bag[tag] = int(bag.get(tag, 0)) + 1


static func _count(bag: Dictionary, tag: String) -> int:
	return int(bag.get(tag, 0))


static func unique_match(session: CraftStaminaSession, construction_id: String) -> String:
	if session == null:
		return ""
	var mats := {}
	var runes: PackedStringArray = PackedStringArray()
	for card in session.cards_played:
		if card.type == GameEnums.HandCardType.MATERIAL:
			mats[card.id] = int(mats.get(card.id, 0)) + 1
		elif card.type == GameEnums.HandCardType.RUNE:
			runes.append(card.id)
	if construction_id == "con_mantle" and int(mats.get("mat_ember_silk", 0)) >= 1 and "enc_rune_ember" in runes:
		return "uniq_ashen_mantle"
	if construction_id == "con_crownveil" and int(mats.get("mat_silver_moth", 0)) >= 1 and "enc_sigil_ghost" in runes:
		return "uniq_ghost_bride_veil"
	if construction_id == "con_coat" and int(mats.get("mat_velvet_court", 0)) >= 1 and "enc_sigil_vow" in runes:
		return "uniq_vowthread_coat"
	if construction_id == "con_wraps" and int(mats.get("mat_tar_thread", 0)) >= 2 and "enc_rune_bind" in runes:
		return "uniq_tar_snare_wraps"
	if construction_id == "con_robe" and int(mats.get("mat_null_ink_cloth", 0)) >= 1 and "enc_rune_hex" in runes:
		return "uniq_null_choir_robe"
	if construction_id == "con_armor" and int(mats.get("mat_stone_shard", 0)) >= 5:
		return "uniq_cairnplate"
	return ""


static func craft_rarity(session: CraftStaminaSession, uniq_id: String) -> GameEnums.CraftRarity:
	if uniq_id != "":
		return GameEnums.CraftRarity.LEGENDARY
	if session == null:
		return GameEnums.CraftRarity.COMMON
	var max_mat := 0
	var stack_n := 0
	var enc_cost := 0
	for card in session.cards_played:
		if card.type == GameEnums.HandCardType.MATERIAL:
			stack_n += 1
			max_mat = maxi(max_mat, CraftCatalog.shop_dollar(card.id, card.type))
		elif card.type == GameEnums.HandCardType.RUNE:
			enc_cost = maxi(enc_cost, CraftCatalog.shop_dollar(card.id, card.type))
	if max_mat >= 5 or (max_mat >= 4 and enc_cost >= 4):
		return GameEnums.CraftRarity.LEGENDARY
	if max_mat >= 4 or (max_mat >= 3 and stack_n >= 3 and enc_cost >= 3):
		return GameEnums.CraftRarity.RARE
	if max_mat >= 3 or stack_n >= 3 or enc_cost >= 3:
		return GameEnums.CraftRarity.UNCOMMON
	return GameEnums.CraftRarity.COMMON


static func resolve(session: CraftStaminaSession, construction_id: String) -> Dictionary:
	var bag := tag_counts(session, construction_id)
	var uniq := unique_match(session, construction_id)
	var rarity := craft_rarity(session, uniq)
	var positives: PackedStringArray = PackedStringArray()
	var negatives: PackedStringArray = PackedStringArray()
	var outlook_id := "plain"
	var outlook_order := 0
	for row in POSITIVE_TAG_ROWS:
		if _count(bag, String(row["tag"])) >= _tier_min(int(row["tier"])):
			positives.append(String(row["id"]))
			if int(row["outlook_order"]) > outlook_order:
				outlook_order = int(row["outlook_order"])
				outlook_id = String(row["id"])
	for row in CROSS_ROWS:
		if (
			_count(bag, String(row["a"])) >= GameConstants.SYN_CROSS_TAG_MIN
			and _count(bag, String(row["b"])) >= GameConstants.SYN_CROSS_TAG_MIN
		):
			positives.append(String(row["id"]))
			if int(row["outlook_order"]) > outlook_order:
				outlook_order = int(row["outlook_order"])
				outlook_id = String(row["id"])
	var skip_neg := (
		rarity == GameEnums.CraftRarity.RARE
		or rarity == GameEnums.CraftRarity.LEGENDARY
	)
	if not skip_neg:
		for row in NEG_ROWS:
			var fired := false
			if row.has("construction"):
				fired = (
					construction_id == String(row["construction"])
					and _count(bag, String(row["tag"])) >= int(row["min"])
				)
			else:
				fired = (
					_count(bag, String(row["a"])) >= int(row["amin"])
					and _count(bag, String(row["b"])) >= int(row["bmin"])
				)
			if fired:
				negatives.append(String(row["id"]))
				if int(row["outlook_order"]) > outlook_order:
					outlook_order = int(row["outlook_order"])
					outlook_id = String(row["id"])
	if uniq != "":
		positives.append(uniq)
		outlook_id = uniq
		outlook_order = 200
	var stats := GearStats.new()
	stats.add_bag(CraftCatalog.construction_stats(construction_id))
	if session != null:
		for card in session.cards_played:
			if card.type == GameEnums.HandCardType.SKILL:
				continue
			stats.add_bag(CraftCatalog.stat_bag(card.id, card.type))
	var played_n := session.cards_played.size() if session != null else 0
	return {
		"tag_counts": bag,
		"craft_rarity": rarity,
		"powers_positive": positives,
		"powers_negative": negatives,
		"outlook_id": outlook_id,
		"outlook_order": outlook_order,
		"stats": stats,
		"unique_id": uniq,
		"cards_played_n": played_n,
		"mission_stub": false,
	}


static func cant_craft_result() -> Dictionary:
	return MissionResolver.cant_craft_result()
