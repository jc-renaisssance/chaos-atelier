class_name PlayedCard
extends Resource
## Stamp `cards_played[]` row: { id, type, cost } after modifiers (docs/20).

@export var id: String = ""
@export var type: GameEnums.HandCardType = GameEnums.HandCardType.MATERIAL
@export var cost: int = 0 ## ≥ 0 after modifiers


func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": GameEnums.hand_card_type_wire(type),
		"cost": cost,
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if id.is_empty():
		errs.append("played card id empty")
	if id.begins_with("con_"):
		errs.append("construction cards are not legal in cards_played (%s)" % id)
	if cost < 0:
		errs.append("played cost %d < 0" % cost)
	return errs
