class_name ClientOrder
extends Resource
## Order-fixed construction list. Multi-piece = one parallel session, N zones (docs/27).

@export var order_id: String = ""
@export var threat_id: String = ""
@export var construction_ids: PackedStringArray = PackedStringArray() ## con_* in listed order
@export var card_difficulty: int = GameConstants.NULL_INT ## 1..3 reps Δ; not a lineup card
@export var mission_kind: GameEnums.MissionKind = GameEnums.MissionKind.ORDER


func piece_count() -> int:
	return construction_ids.size()


func piece_construction_id(piece_index: int) -> String:
	if piece_index < 1 or piece_index > construction_ids.size():
		return ""
	return construction_ids[piece_index - 1]


func open_session() -> CraftStaminaSession:
	var session := CraftStaminaSession.new()
	session.apply_order(self)
	return session


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if order_id.is_empty():
		errs.append("order_id empty")
	if construction_ids.is_empty():
		errs.append("construction_ids empty — order must fix at least one piece")
	if construction_ids.size() > GameConstants.ZONE_COUNT_MAX:
		errs.append("construction_ids length %d > max zones %d (Later / split)" % [construction_ids.size(), GameConstants.ZONE_COUNT_MAX])
	for con_id in construction_ids:
		if not String(con_id).begins_with("con_"):
			errs.append("construction id '%s' is not con_*" % con_id)
	if card_difficulty != GameConstants.NULL_INT and (card_difficulty < 1 or card_difficulty > 3):
		errs.append("card_difficulty %d not in 1..3" % card_difficulty)
	return errs
