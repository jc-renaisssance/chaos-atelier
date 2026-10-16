class_name HandCard
extends Resource
## Live hand card. Materials + runes + owner skills only — no construction cards (docs/27).

@export var id: String = ""
@export var type: GameEnums.HandCardType = GameEnums.HandCardType.MATERIAL
@export var mat_enchant_id: String = "" ## docs/32 mat_ench_*; empty = unenchanted
@export var shiny: bool = false


static func make(
	id_: String,
	type_: GameEnums.HandCardType,
	mat_enchant_id_: String = "",
	shiny_: bool = false
) -> HandCard:
	var card := HandCard.new()
	card.id = id_
	card.type = type_
	card.mat_enchant_id = mat_enchant_id_
	card.shiny = shiny_
	return card


func is_enchanted() -> bool:
	return type == GameEnums.HandCardType.MATERIAL and not mat_enchant_id.is_empty()


func duplicate_live() -> HandCard:
	return make(id, type, mat_enchant_id, shiny)


func to_dict() -> Dictionary:
	var out := {
		"id": id,
		"type": GameEnums.hand_card_type_wire(type),
	}
	if is_enchanted():
		out["mat_enchant_id"] = mat_enchant_id
		out["shiny"] = true
	return out


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if id.is_empty():
		errs.append("hand card id empty")
	if id.begins_with("con_"):
		errs.append("construction cards are not legal in hand (%s)" % id)
	return errs
