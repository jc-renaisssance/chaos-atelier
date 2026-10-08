class_name UnlockLaw
extends RefCounted
## Maps fired CraftResolver powers → profile unlock / Dex craft keys (docs/14, 30, 31).
## Reuses the live synergy tables. Does not invent a second threshold system.
## Neg syn and uniq_* are not planner / Builds keys.

## Cross-tag chrome slugs (docs/30). Storm monostack stays storm + tier.
const CROSS_UNLOCK := {
	"syn_fire_frost_clash": "temper",
	"syn_wild_earth": "beastbloom",
	"syn_sticky_sharp": "snaretooth",
	"syn_royal_silent": "masked_crown",
	"syn_solar_pure": "dawn",
	"syn_lunar_occult": "pale_hex",
}


static func key_for_power(power: String) -> Dictionary:
	if CROSS_UNLOCK.has(power):
		return {"outlook_id": String(CROSS_UNLOCK[power]), "tier": "cross"}
	for row in CraftResolver.POSITIVE_TAG_ROWS:
		if String(row["id"]) != power:
			continue
		var tag := String(row["tag"]).to_lower()
		var tier := "low"
		match int(row["tier"]):
			2:
				tier = "mid"
			3:
				tier = "apex"
			_:
				tier = "low"
		return {"outlook_id": tag, "tier": tier}
	return {}


static func keys_from_powers(powers: PackedStringArray) -> Array:
	var keys: Array = []
	var seen := {}
	for power in powers:
		var key := key_for_power(String(power))
		if key.is_empty():
			continue
		_union_key(keys, seen, key)
		if String(key.get("tier", "")) == "apex":
			_union_key(keys, seen, {"outlook_id": String(key.get("outlook_id", "")), "tier": "low"})
			_union_key(keys, seen, {"outlook_id": String(key.get("outlook_id", "")), "tier": "mid"})
	return keys


static func build_key_id(outlook_id: String, tier: String) -> String:
	return "%s/%s" % [outlook_id, tier]


static func craft_key_id(construction_id: String, outlook_id: String, tier: String) -> String:
	return "%s/%s/%s" % [construction_id, outlook_id, tier]


static func _union_key(keys: Array, seen: Dictionary, key: Dictionary) -> void:
	var outlook_id := String(key.get("outlook_id", ""))
	var tier := String(key.get("tier", ""))
	if outlook_id.is_empty() or tier.is_empty():
		return
	var id := build_key_id(outlook_id, tier)
	if seen.has(id):
		return
	seen[id] = true
	keys.append({"outlook_id": outlook_id, "tier": tier})
