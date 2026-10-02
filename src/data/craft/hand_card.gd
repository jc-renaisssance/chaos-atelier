class_name HandCard
extends Resource
## Live hand card. Materials + runes + owner skills only — no construction cards (docs/27).

@export var id: String = ""
@export var type: GameEnums.HandCardType = GameEnums.HandCardType.MATERIAL


func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": GameEnums.hand_card_type_wire(type),
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if id.is_empty():
		errs.append("hand card id empty")
	if id.begins_with("con_"):
		errs.append("construction cards are not legal in hand (%s)" % id)
	return errs
