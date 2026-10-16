class_name MarketCatalog
extends RefCounted
## Chapter-shared market bank + M1 material enchant catalog (docs/32).
## Wire stays kind=shop. Display name is market. No staff / skill / gear tabs here.

const BANK_C1 := [
	"mat_hemp_plain",
	"mat_iron_scrap",
	"mat_cotton_spring",
	"mat_wool_grey",
	"mat_leather_tan",
	"mat_bronze_scale",
	"mat_clayweave",
	"mat_stone_shard",
	"mat_milkfleece",
	"mat_ivy_cord",
	"mat_tar_thread",
	"mat_silk_pale",
	"mat_leather_dusk",
	"mat_linen_storm",
	"mat_wirecloth",
	"mat_stonefiber",
	"mat_ember_silk",
	"mat_frostwool",
	"mat_suncloth",
	"mat_whisper_gauze",
	"mat_velvet_court",
	"mat_steel_plate",
]

## Non-binding first-shelf fiction (docs/32). Refresh ignores these.
const FIRST_DRAW := {
	"N2": ["mat_hemp_plain", "mat_cotton_spring", "mat_leather_tan", "mat_wool_grey", "mat_iron_scrap"],
	"N7": ["mat_hemp_plain", "mat_silk_pale", "mat_bronze_scale", "mat_stone_shard", "mat_clayweave"],
	"N12": ["mat_cotton_spring", "mat_wool_grey", "mat_leather_tan", "mat_bronze_scale", "mat_stonefiber"],
	"N15": ["mat_hemp_plain", "mat_iron_scrap", "mat_wirecloth", "mat_stone_shard", "mat_leather_dusk"],
	"N16": ["mat_cotton_spring", "mat_linen_storm", "mat_leather_tan", "mat_iron_scrap", "mat_silk_pale"],
}

const ENCHANTS := {
	"mat_ench_thrift": {"id": "mat_ench_thrift", "label": "Thrift", "fee": 2},
	"mat_ench_heavy": {"id": "mat_ench_heavy", "label": "Heavy", "fee": 3},
}


static func bank_id() -> String:
	return GameConstants.MARKET_BANK_ID


static func bank_ids() -> Array:
	return BANK_C1.duplicate()


static func in_bank(mat_id: String) -> bool:
	return mat_id in BANK_C1


static func price_of(mat_id: String) -> int:
	return CraftCatalog.shop_dollar(mat_id, GameEnums.HandCardType.MATERIAL)


static func sell_gain(mat_id: String) -> int:
	## Base $ only — ignore thrift / heavy (docs/32 Test knob).
	return maxi(1, price_of(mat_id) / 2)


static func shelf_size() -> int:
	return clampi(
		GameConstants.MARKET_SHELF_SIZE,
		GameConstants.MARKET_SHELF_MIN,
		GameConstants.MARKET_SHELF_MAX
	)


static func refresh_cost(refresh_count: int) -> int:
	return GameConstants.MARKET_REFRESH_BASE + refresh_count * GameConstants.MARKET_REFRESH_STEP


static func enchant_ids() -> Array:
	return ["mat_ench_thrift", "mat_ench_heavy"]


static func enchant_row(enchant_id: String) -> Dictionary:
	var row: Variant = ENCHANTS.get(enchant_id, {})
	if row is Dictionary:
		return (row as Dictionary).duplicate(true)
	return {}


static func enchant_label(enchant_id: String) -> String:
	return String(enchant_row(enchant_id).get("label", enchant_id))


static func enchant_fee(enchant_id: String) -> int:
	if enchant_id == GameConstants.MAT_ENCH_THRIFT:
		return GameConstants.MAT_ENCH_THRIFT_FEE
	if enchant_id == GameConstants.MAT_ENCH_HEAVY:
		return GameConstants.MAT_ENCH_HEAVY_FEE
	return int(enchant_row(enchant_id).get("fee", 0))


static func is_enchant(enchant_id: String) -> bool:
	return ENCHANTS.has(enchant_id)


static func make_offer(mat_id: String, qty: int = -1) -> Dictionary:
	var offered := qty if qty >= 0 else GameConstants.MARKET_QTY_OFFERED
	return {
		"mat_id": mat_id,
		"price": price_of(mat_id),
		"qty_offered": offered,
	}


static func _seed_ids(node_id: String) -> Array:
	var row: Variant = FIRST_DRAW.get(node_id, [])
	if row is Array:
		return row as Array
	return []


static func _seed_legal(node_id: String, size: int) -> Array:
	var seed := _seed_ids(node_id)
	if seed.size() != size:
		return []
	var seen := {}
	for item in seed:
		var mat_id := String(item)
		if not in_bank(mat_id) or seen.has(mat_id):
			return []
		seen[mat_id] = true
	return seed


static func draw_shelf(
	rng: RandomNumberGenerator,
	node_id: String = "",
	use_seed: bool = false
) -> Array:
	var size := shelf_size()
	var ids: Array = []
	if use_seed:
		ids = _seed_legal(node_id, size)
	if ids.is_empty():
		var pool: Array = BANK_C1.duplicate()
		if rng != null:
			for i in range(pool.size() - 1, 0, -1):
				var j := rng.randi_range(0, i)
				var tmp: Variant = pool[i]
				pool[i] = pool[j]
				pool[j] = tmp
		var take := mini(size, pool.size())
		ids = pool.slice(0, take)
	var out: Array = []
	for item in ids:
		out.append(make_offer(String(item)))
	return out


static func stock_rows(stock: Array) -> Array:
	var out: Array = []
	for item in stock:
		if item is Dictionary:
			var row: Dictionary = item
			out.append({
				"mat_id": String(row.get("mat_id", "")),
				"price": int(row.get("price", 0)),
				"qty_offered": int(row.get("qty_offered", 0)),
			})
	return out
