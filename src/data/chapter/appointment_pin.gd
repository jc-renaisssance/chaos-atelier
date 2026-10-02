class_name AppointmentPin
extends Resource
## Chapter-start elite telegraph. pinned_round ∈ 1..6 (docs/22, docs/20).

@export var appointment_id: String = ""
@export var order_id: String = ""
@export var pinned_round: int = 1


func to_dict() -> Dictionary:
	return {
		"appointment_id": appointment_id,
		"order_id": order_id,
		"pinned_round": pinned_round,
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if appointment_id.is_empty():
		errs.append("appointment_id empty")
	if order_id.is_empty():
		errs.append("order_id empty")
	if not GameConstants.is_appointment_pin_round(pinned_round):
		errs.append("pinned_round %d not in 1..6 (reserved finals 7–8)" % pinned_round)
	return errs
