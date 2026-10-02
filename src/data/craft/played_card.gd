class_name PlayedCard
extends Resource
## Stamp `cards_played[]` row: { id, type, cost, zone_index, construction_id } (docs/20).

@export var id: String = ""
@export var type: GameEnums.HandCardType = GameEnums.HandCardType.MATERIAL
@export var cost: int = 0 ## ≥ 0 after modifiers
@export var zone_index: int = 1 ## 1-based ∈ 1..zone_count
@export var construction_id: String = "" ## construction_ids[zone_index-1]


func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": GameEnums.hand_card_type_wire(type),
		"cost": cost,
		"zone_index": zone_index,
		"construction_id": construction_id,
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if id.is_empty():
		errs.append("played card id empty")
	if id.begins_with("con_"):
		errs.append("construction cards are not legal in cards_played (%s)" % id)
	if cost < 0:
		errs.append("played cost %d < 0" % cost)
	if zone_index < 1 or zone_index > GameConstants.ZONE_COUNT_MAX:
		errs.append("played zone_index %d not in 1..%d" % [zone_index, GameConstants.ZONE_COUNT_MAX])
	if construction_id.is_empty():
		errs.append("played construction_id empty — play must target a zone")
	elif not construction_id.begins_with("con_"):
		errs.append("played construction_id %s is not con_*" % construction_id)
	return errs
