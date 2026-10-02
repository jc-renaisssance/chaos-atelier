class_name GearStats
extends Resource
## Primary stats bag (docs/10). Used on harness stamp `stats`.

@export var HP: int = 0
@export var ATK: int = 0
@export var DEF: int = 0
@export var RES: int = 0
@export var MOB: int = 0
@export var PRE: int = 0


func to_dict() -> Dictionary:
	return {"HP": HP, "ATK": ATK, "DEF": DEF, "RES": RES, "MOB": MOB, "PRE": PRE}
