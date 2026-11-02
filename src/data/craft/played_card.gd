class_name PlayedCard
extends Resource
## Stamp `cards_played[]` row: { id, type, cost, zone_index, construction_id } (docs/20).

@export var id: String = ""
@export var type: GameEnums.HandCardType = GameEnums.HandCardType.MATERIAL
@export var cost: int = 0 ## ≥ 0 after modifiers
@export var zone_index: int = 1 ## 1-based ∈ 1..zone_count
@export var construction_id: String = "" ## construction_ids[zone_index-1]
@export var mat_enchant_id: String = ""
## docs/39. Copied from the hand card. Not a harness Required key.
@export var starter_role: String = ""
## docs/39 sk_heavy_draw. Next zone play contributes ×1.5 stats. Tags stay printed.
@export var stat_one_and_half: bool = false
## Deterministic production effects for the six market skills.
@export var double_atk: bool = false
@export var stat_bonus_key: String = ""
@export var tag_pip_bonus: Dictionary = {}
@export var suppressed_tags: PackedStringArray = PackedStringArray()


func to_dict() -> Dictionary:
	var out := {
		"id": id,
		"type": GameEnums.hand_card_type_wire(type),
		"cost": cost,
		"zone_index": zone_index,
		"construction_id": construction_id,
	}
	if not mat_enchant_id.is_empty():
		out["mat_enchant_id"] = mat_enchant_id
		out["shiny"] = true
	if not starter_role.is_empty():
		out["starter_role"] = starter_role
	if stat_one_and_half:
		out["stat_one_and_half"] = true
	if double_atk:
		out["double_atk"] = true
	if not stat_bonus_key.is_empty():
		out["stat_bonus_key"] = stat_bonus_key
	if not tag_pip_bonus.is_empty():
		out["tag_pip_bonus"] = tag_pip_bonus.duplicate()
	if not suppressed_tags.is_empty():
		out["suppressed_tags"] = Array(suppressed_tags)
	return out


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
