class_name CraftStaminaSession
extends Resource
## One parallel stamina session for an order (docs/27 / docs/20).
## N pieces share one pool (stamina_start = 12 * N) and up to 4 zones.
## Stamina 0 is state, not a finish. Only Finish sets finish_reason: player_finish.

@export var order_id: String = ""
@export var construction_ids: PackedStringArray = PackedStringArray() ## order-fixed
@export var construction_id: String = "" ## focused piece = construction_ids[piece_index-1]
@export var piece_index: int = 1 ## 1-based focused / stamp piece
@export var piece_count: int = 1
@export var zone_count: int = 1 ## == piece_count, ∈ 1..4
@export var selected_zone_index: int = 1 ## 1-based; Current/Potential + 1–5 target
@export var stamina_start: int = GameConstants.STAMINA_START
@export var stamina_remaining: int = GameConstants.STAMINA_START
@export var stamina_spent: int = 0
@export var hand_size: int = GameConstants.HAND_SIZE
@export var hand: Array[HandCard] = [] ## mats + runes + skills; no auto-refill
@export var draw_pile: Array[HandCard] = [] ## run deck remainder this session (docs/27)
@export var discard_pile: Array[HandCard] = [] ## play + dig dump; reshuffles into draw
@export var dig_refresh_cost: int = GameConstants.DIG_REFRESH_COST
@export var dig_count: int = 0
@export var cards_played: Array[PlayedCard] = []
@export var early_finish: bool = false
@export var finish_reason: GameEnums.FinishReason = GameEnums.FinishReason.NONE


func apply_order(order: ClientOrder) -> void:
	order_id = order.order_id
	construction_ids = order.construction_ids.duplicate()
	piece_count = order.piece_count()
	zone_count = piece_count
	if zone_count > GameConstants.ZONE_COUNT_MAX:
		zone_count = GameConstants.ZONE_COUNT_MAX
	if zone_count < 1:
		zone_count = 1
	stamina_start = GameConstants.session_stamina_start(piece_count)
	stamina_remaining = stamina_start
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
	focus_zone(1)


func is_finished() -> bool:
	return finish_reason != GameEnums.FinishReason.NONE


func is_legal_zone(zone_index: int) -> bool:
	return zone_index >= 1 and zone_index <= zone_count


func construction_id_for_zone(zone_index: int) -> String:
	if zone_index < 1 or zone_index > construction_ids.size():
		return ""
	return construction_ids[zone_index - 1]


func focus_zone(zone_index: int) -> bool:
	if not is_legal_zone(zone_index):
		return false
	selected_zone_index = zone_index
	piece_index = zone_index
	construction_id = construction_id_for_zone(zone_index)
	return true


func cards_for_zone(zone_index: int) -> Array[PlayedCard]:
	var out: Array[PlayedCard] = []
	for card in cards_played:
		if card.zone_index == zone_index:
			out.append(card)
	return out


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
		"zone_count": zone_count,
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
	if zone_count != piece_count:
		errs.append("zone_count %d != piece_count %d" % [zone_count, piece_count])
	if not GameConstants.is_legal_zone_count(zone_count):
		errs.append("zone_count %d not in 1..%d" % [zone_count, GameConstants.ZONE_COUNT_MAX])
	if piece_index < 1 or piece_index > piece_count:
		errs.append("piece_index %d not in 1..%d" % [piece_index, piece_count])
	if not is_legal_zone(selected_zone_index):
		errs.append("selected_zone_index %d not in 1..%d" % [selected_zone_index, zone_count])
	if construction_id.is_empty():
		errs.append("construction_id empty — must come from the order")
	elif not construction_ids.is_empty():
		var expected := construction_id_for_zone(piece_index)
		if expected != "" and construction_id != expected:
			errs.append("construction_id %s != order piece %s" % [construction_id, expected])
	if stamina_remaining < 0:
		errs.append("stamina_remaining < 0")
	var expect_start := GameConstants.session_stamina_start(piece_count)
	if stamina_start != expect_start:
		errs.append("stamina_start %d != 12 * piece_count %d (Phase-1 draft)" % [stamina_start, expect_start])
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
		if not is_legal_zone(card.zone_index):
			errs.append("played %s zone_index %d not in 1..%d" % [card.id, card.zone_index, zone_count])
		else:
			var zone_con := construction_id_for_zone(card.zone_index)
			if card.construction_id != zone_con:
				errs.append(
					"played %s construction_id %s != zone %d %s"
					% [card.id, card.construction_id, card.zone_index, zone_con]
				)
	## Stamina 0 is session state, not a craft-end. Session may stay open.
	if finish_reason == GameEnums.FinishReason.STAMINA_0:
		errs.append("finish_reason stamina_0 is superseded — only player_finish crafts")
	if finish_reason == GameEnums.FinishReason.EARLY_FINISH:
		errs.append("finish_reason early_finish is superseded — use player_finish")
	if finish_reason == GameEnums.FinishReason.PLAYER_FINISH and not early_finish:
		errs.append("player_finish must agree with early_finish (Finish click)")
	if early_finish and finish_reason != GameEnums.FinishReason.PLAYER_FINISH:
		errs.append("early_finish must agree with player_finish")
	return errs
