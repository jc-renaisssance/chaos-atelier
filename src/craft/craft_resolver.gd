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
	{"id": "syn_soft_5", "tag": "Soft", "tier": 2, "outlook_order": 13},
	{"id": "syn_soft_8", "tag": "Soft", "tier": 3, "outlook_order": 14},
	{"id": "syn_wild_3", "tag": "Wild", "tier": 1, "outlook_order": 60},
	{"id": "syn_occult_3", "tag": "Occult", "tier": 1, "outlook_order": 85},
	{"id": "syn_pure_3", "tag": "Pure", "tier": 1, "outlook_order": 65},
	{"id": "syn_metal_3", "tag": "Metal", "tier": 1, "outlook_order": 30},
	{"id": "syn_metal_5", "tag": "Metal", "tier": 2, "outlook_order": 32},
	{"id": "syn_metal_8", "tag": "Metal", "tier": 3, "outlook_order": 34},
	{"id": "syn_silk_3", "tag": "Silk", "tier": 1, "outlook_order": 10},
	{"id": "syn_silk_5", "tag": "Silk", "tier": 2, "outlook_order": 11},
	{"id": "syn_silk_8", "tag": "Silk", "tier": 3, "outlook_order": 12},
]

const BASIC_AFFINITY_TAGS := ["Fire", "Soft", "Earth", "Metal", "Silk"]
const STAT_KEYS := ["HP", "ATK", "DEF", "RES", "MOB", "PRE"]

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


static func zone_cards(session: CraftStaminaSession, zone_index: int) -> Array[PlayedCard]:
	var out: Array[PlayedCard] = []
	if session == null:
		return out
	if zone_index <= 0:
		for card in session.cards_played:
			out.append(card)
		return out
	return session.cards_for_zone(zone_index)


static func tag_counts(
	session: CraftStaminaSession,
	construction_id: String,
	zone_index: int = 0
) -> Dictionary:
	var bag := {}
	_add_pips(bag, CraftCatalog.construction_tag_pips(construction_id))
	if session == null:
		return bag
	for card in zone_cards(session, zone_index):
		if card.type == GameEnums.HandCardType.SKILL:
			continue
		_add_pips(bag, CraftCatalog.tag_pips_for_played(card))
	return bag


static func _add_pips(bag: Dictionary, pips: Dictionary) -> void:
	for tag in pips.keys():
		bag[tag] = int(bag.get(tag, 0)) + int(pips[tag])


static func _count(bag: Dictionary, tag: String) -> int:
	return int(bag.get(tag, 0))


static func unique_match(
	session: CraftStaminaSession,
	construction_id: String,
	zone_index: int = 0
) -> String:
	if session == null:
		return ""
	var mats := {}
	var runes: PackedStringArray = PackedStringArray()
	for card in zone_cards(session, zone_index):
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


static func craft_rarity(
	session: CraftStaminaSession,
	uniq_id: String,
	zone_index: int = 0
) -> GameEnums.CraftRarity:
	if uniq_id != "":
		return GameEnums.CraftRarity.LEGENDARY
	if session == null:
		return GameEnums.CraftRarity.COMMON
	var max_mat := 0
	var stack_n := 0
	var enc_cost := 0
	for card in zone_cards(session, zone_index):
		if card.type == GameEnums.HandCardType.MATERIAL:
			stack_n += 1
			max_mat = maxi(
				max_mat,
				CraftCatalog.effective_dollar_of(card.id, card.type, card.mat_enchant_id)
			)
		elif card.type == GameEnums.HandCardType.RUNE:
			enc_cost = maxi(enc_cost, CraftCatalog.shop_dollar(card.id, card.type))
	if max_mat >= 5 or (max_mat >= 4 and enc_cost >= 4):
		return GameEnums.CraftRarity.LEGENDARY
	if max_mat >= 4 or (max_mat >= 3 and stack_n >= 3 and enc_cost >= 3):
		return GameEnums.CraftRarity.RARE
	if max_mat >= 3 or stack_n >= 3 or enc_cost >= 3:
		return GameEnums.CraftRarity.UNCOMMON
	return GameEnums.CraftRarity.COMMON


static func resolve(
	session: CraftStaminaSession,
	construction_id: String,
	zone_index: int = 0
) -> Dictionary:
	var bag := tag_counts(session, construction_id, zone_index)
	var uniq := unique_match(session, construction_id, zone_index)
	var rarity := craft_rarity(session, uniq, zone_index)
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
	var ignore_first_neg := false
	for card in zone_cards(session, zone_index):
		if card.type == GameEnums.HandCardType.SKILL and card.id == "sk_steady_hand":
			ignore_first_neg = true
			break
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
				if ignore_first_neg:
					ignore_first_neg = false
					continue
				negatives.append(String(row["id"]))
				if int(row["outlook_order"]) > outlook_order:
					outlook_order = int(row["outlook_order"])
					outlook_id = String(row["id"])
	if uniq != "":
		positives.append(uniq)
		outlook_id = uniq
		outlook_order = 200
	var stats := GearStats.new()
	var construction_stats := CraftCatalog.construction_stats(construction_id)
	stats.add_bag(construction_stats)
	var affinity := _empty_affinity()
	_add_affinity_layer(
		affinity,
		CraftCatalog.construction_tag_pips(construction_id),
		construction_stats
	)
	var zone_played := zone_cards(session, zone_index)
	for card in zone_played:
		if card.type == GameEnums.HandCardType.SKILL:
			continue
		var copies := 1
		if card.type == GameEnums.HandCardType.MATERIAL:
			copies = CraftCatalog.tag_copies(card.mat_enchant_id)
		var bag_stats := CraftCatalog.stat_bag(card.id, card.type)
		if card.stat_one_and_half:
			bag_stats = CraftCatalog.scaled_stat_bag(bag_stats)
		if card.double_atk:
			bag_stats["ATK"] = int(bag_stats.get("ATK", 0)) * 2
		if not card.stat_bonus_key.is_empty():
			var stat_key := card.stat_bonus_key
			bag_stats[stat_key] = int(bag_stats.get(stat_key, 0)) + 1
		stats.add_bag(bag_stats)
		if copies > 1:
			stats.add_bag(bag_stats)
		var affinity_stats := bag_stats.duplicate()
		if copies > 1:
			for stat in STAT_KEYS:
				affinity_stats[stat] = int(affinity_stats.get(stat, 0)) * copies
		_add_affinity_layer(
			affinity,
			CraftCatalog.tag_pips_for_played(card),
			affinity_stats
		)
	_finalize_affinity(affinity)
	var played_n := zone_played.size()
	return {
		"tag_counts": bag,
		"affinity": affinity,
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


static func affinity_tier(intensity: int) -> int:
	if intensity >= GameConstants.SYN_THRESHOLD_APEX:
		return 3
	if intensity >= GameConstants.SYN_THRESHOLD_TIER_2:
		return 2
	if intensity >= GameConstants.SYN_THRESHOLD_TIER_1:
		return 1
	return 0


static func affinity_magnitude(tag: String, row: Dictionary) -> int:
	var intensity := int(row.get("intensity", 0))
	var value := 0.0
	match tag:
		"Fire":
			value = 0.25 * float(row.get("ATK", 0)) + 0.20 * intensity
		"Soft":
			value = (
				0.15 * float(row.get("HP", 0))
				+ 0.30 * float(row.get("RES", 0))
				+ 0.20 * intensity
			)
		"Earth":
			value = (
				0.10 * float(row.get("HP", 0))
				+ 0.25 * float(row.get("DEF", 0))
				+ 0.15 * intensity
			)
		"Metal":
			value = (
				0.15 * float(row.get("HP", 0))
				+ 0.40 * float(row.get("DEF", 0))
				+ 0.20 * intensity
			)
		"Silk":
			value = (
				0.30 * float(row.get("MOB", 0))
				+ 0.20 * float(row.get("PRE", 0))
				+ 0.20 * intensity
			)
	return maxi(1, int(floor(value + 0.5)))


static func _empty_affinity() -> Dictionary:
	var out := {}
	for tag in BASIC_AFFINITY_TAGS:
		var row := {"intensity": 0, "tier": 0, "magnitude": 0}
		for stat in STAT_KEYS:
			row[stat] = 0
		out[tag] = row
	return out


static func _add_affinity_layer(
	affinity: Dictionary,
	pips: Dictionary,
	stats: Dictionary
) -> void:
	for tag in BASIC_AFFINITY_TAGS:
		var pip_n := int(pips.get(tag, 0))
		if pip_n <= 0:
			continue
		var row: Dictionary = affinity[tag]
		row["intensity"] = int(row["intensity"]) + pip_n
		for stat in STAT_KEYS:
			row[stat] = int(row[stat]) + maxi(0, int(stats.get(stat, 0)))


static func _finalize_affinity(affinity: Dictionary) -> void:
	for tag in BASIC_AFFINITY_TAGS:
		var row: Dictionary = affinity[tag]
		row["tier"] = affinity_tier(int(row["intensity"]))
		if int(row["tier"]) > 0:
			row["magnitude"] = affinity_magnitude(tag, row)


## Combined fight payload: tier is the highest item tier; magnitude sums inputs
## only from items that individually reached Tier 1.
static func combine_affinity(piece_results: Array) -> Dictionary:
	var out := _empty_affinity()
	for piece in piece_results:
		if not (piece is Dictionary):
			continue
		var piece_affinity: Dictionary = Dictionary(piece.get("affinity", {}))
		for tag in BASIC_AFFINITY_TAGS:
			var source: Dictionary = Dictionary(piece_affinity.get(tag, {}))
			var source_tier := int(source.get("tier", 0))
			if source_tier <= 0:
				continue
			var target: Dictionary = out[tag]
			target["tier"] = maxi(int(target["tier"]), source_tier)
			target["intensity"] = int(target["intensity"]) + int(source.get("intensity", 0))
			target["apex_items"] = int(target.get("apex_items", 0))
			if source_tier >= 3:
				target["apex_items"] = int(target["apex_items"]) + 1
			for stat in STAT_KEYS:
				target[stat] = int(target[stat]) + int(source.get(stat, 0))
	for tag in BASIC_AFFINITY_TAGS:
		var row: Dictionary = out[tag]
		if int(row["tier"]) > 0:
			row["magnitude"] = affinity_magnitude(tag, row)
	return out


static func cant_craft_result() -> Dictionary:
	return MissionResolver.cant_craft_result()
