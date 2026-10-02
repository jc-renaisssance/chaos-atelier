class_name CraftStaminaSession
extends Resource
## One piece's stamina session. Multi-piece orders open N of these (docs/27 / docs/20).
## Stamina 0 is state, not a finish. Only Finish sets finish_reason: player_finish.

@export var order_id: String = ""
@export var construction_ids: PackedStringArray = PackedStringArray() ## order-fixed
@export var construction_id: String = "" ## construction_ids[piece_index-1]
@export var piece_index: int = 1 ## 1-based
@export var piece_count: int = 1
@export var stamina_start: int = GameConstants.STAMINA_START
@export var stamina_remaining: int = GameConstants.STAMINA_START
@export var stamina_spent: int = 0
@export var hand_size: int = GameConstants.HAND_SIZE
@export var hand: Array[HandCard] = [] ## mats + runes + skills; no auto-refill
@export var draw_pile: Array[HandCard] = [] ## run deck remainder this piece (docs/27)
@export var discard_pile: Array[HandCard] = [] ## play + dig dump; reshuffles into draw
@export var dig_refresh_cost: int = GameConstants.DIG_REFRESH_COST
@export var dig_count: int = 0
@export var cards_played: Array[PlayedCard] = []
@export var early_finish: bool = false
@export var finish_reason: GameEnums.FinishReason = GameEnums.FinishReason.NONE


func apply_order(order: ClientOrder, piece_index_: int) -> void:
	order_id = order.order_id
	construction_ids = order.construction_ids.duplicate()
	piece_count = order.piece_count()
	piece_index = piece_index_
	construction_id = order.piece_construction_id(piece_index_)
	stamina_start = GameConstants.STAMINA_START
	stamina_remaining = GameConstants.STAMINA_START
	stamina_spent = 0
	hand_size = GameConstants.HAND_SIZE
	dig_refresh_cost = GameConstants.DIG_REFRESH_COST
	dig_count = 0
	early_finish = false
	finish_reason = GameEnums.FinishReason.NONE
	hand.clear()
	draw_pile.clear()
	discard_pile.clear()
	cards_played.clear()


func is_finished() -> bool:
	return finish_reason != GameEnums.FinishReason.NONE


func run_deck_count() -> int:
	return hand.size() + draw_pile.size() + discard_pile.size()


func to_session_dict() -> Dictionary:
	var played: Array = []
	for card in cards_played:
		played.append(card.to_dict())
	var hand_rows: Array = []
	for card in hand:
		hand_rows.append(card.to_dict())
	var draw_rows: Array = []
	for card in draw_pile:
		draw_rows.append(card.to_dict())
	var discard_rows: Array = []
	for card in discard_pile:
		discard_rows.append(card.to_dict())
	return {
		"piece_index": piece_index,
		"piece_count": piece_count,
		"stamina_start": stamina_start,
		"stamina_remaining": stamina_remaining,
		"stamina_spent": stamina_spent,
		"hand_size": hand_size,
		"hand": hand_rows,
		"draw_pile": draw_rows,
		"discard_pile": discard_rows,
		"dig_refresh_cost": dig_refresh_cost,
		"dig_count": dig_count,
		"cards_played": played,
		"early_finish": early_finish,
		"finish_reason": GameEnums.finish_reason_wire(finish_reason),
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if piece_count < 1:
		errs.append("piece_count < 1")
	if piece_index < 1 or piece_index > piece_count:
		errs.append("piece_index %d not in 1..%d" % [piece_index, piece_count])
	if construction_id.is_empty():
		errs.append("construction_id empty — must come from the order")
	elif not construction_ids.is_empty():
		var expected := ""
		if piece_index >= 1 and piece_index <= construction_ids.size():
			expected = construction_ids[piece_index - 1]
		if expected != "" and construction_id != expected:
			errs.append("construction_id %s != order piece %s" % [construction_id, expected])
	if stamina_remaining < 0:
		errs.append("stamina_remaining < 0")
	if stamina_start != GameConstants.STAMINA_START:
		errs.append("stamina_start %d != 12 (Phase-1 draft)" % stamina_start)
	if hand_size != GameConstants.HAND_SIZE:
		errs.append("hand_size %d != 5 (Phase-1 draft)" % hand_size)
	if dig_refresh_cost != GameConstants.DIG_REFRESH_COST:
		errs.append("dig_refresh_cost %d != 2 (Phase-1 draft)" % dig_refresh_cost)
	if hand.size() > hand_size:
		errs.append("hand size %d exceeds hand_size %d" % [hand.size(), hand_size])
	for card in hand:
		errs.append_array(card.schema_errors())
	for card in draw_pile:
		errs.append_array(card.schema_errors())
	for card in discard_pile:
		errs.append_array(card.schema_errors())
	for card in cards_played:
		errs.append_array(card.schema_errors())
	## Stamina 0 is session state, not a craft-end. Piece may stay open.
	if finish_reason == GameEnums.FinishReason.STAMINA_0:
		errs.append("finish_reason stamina_0 is superseded — only player_finish crafts")
	if finish_reason == GameEnums.FinishReason.EARLY_FINISH:
		errs.append("finish_reason early_finish is superseded — use player_finish")
	if finish_reason == GameEnums.FinishReason.PLAYER_FINISH and not early_finish:
		errs.append("player_finish must agree with early_finish (Finish click)")
	if early_finish and finish_reason != GameEnums.FinishReason.PLAYER_FINISH:
		errs.append("early_finish must agree with player_finish")
	return errs
