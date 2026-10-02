class_name CraftRules
extends RefCounted
## Stamina session mutations (docs/27, docs/20 asserts 12–17).
## Materials are durable: play spends stamina only — card stays in hand / stock.
## Consumable is Later / not in the stamp type enum; if that type is added it burns.
## No auto-refill. Dig costs 2 and refreshes hand from stock. Construction is not a card.

static func opening_draw(
	session: CraftStaminaSession,
	stock: WagonStock,
	rng: RandomNumberGenerator
) -> void:
	if session == null or stock == null:
		return
	session.hand = stock.draw_up_to(session.hand_size, rng)


static func return_hand_copies(session: CraftStaminaSession, stock: WagonStock) -> void:
	if session == null or stock == null:
		return
	for card in session.hand:
		stock.add_copy(card)


static func can_play(session: CraftStaminaSession, hand_index: int, next_mat_free: bool) -> bool:
	if session == null or session.is_finished():
		return false
	if hand_index < 0 or hand_index >= session.hand.size():
		return false
	var cost := CraftCatalog.play_cost(session.hand[hand_index], next_mat_free)
	return cost <= session.stamina_remaining


static func can_dig(session: CraftStaminaSession, stock: WagonStock) -> bool:
	if session == null or session.is_finished():
		return false
	if session.stamina_remaining < session.dig_refresh_cost:
		return false
	var stock_n := stock.count() if stock != null else 0
	return stock_n + session.hand.size() > 0


static func burns_on_play(type: GameEnums.HandCardType) -> bool:
	## Law (docs/11, 27, 20): materials never burn. Consumable (Later, distinct type)
	## burns when/if that type exists. Runes and skills leave the hand (not durable).
	return type != GameEnums.HandCardType.MATERIAL


static func play(
	session: CraftStaminaSession,
	hand_index: int,
	next_mat_free: bool
) -> Dictionary:
	if not can_play(session, hand_index, next_mat_free):
		return {"ok": false, "next_mat_free": next_mat_free}
	var card: HandCard = session.hand[hand_index]
	var cost := CraftCatalog.play_cost(card, next_mat_free)
	if burns_on_play(card.type):
		session.hand.remove_at(hand_index)
	_spend(session, cost)
	var played := PlayedCard.new()
	played.id = card.id
	played.type = card.type
	played.cost = cost
	session.cards_played.append(played)
	var flag := next_mat_free
	if card.type == GameEnums.HandCardType.MATERIAL and next_mat_free:
		flag = false
	elif card.type == GameEnums.HandCardType.SKILL and card.id == "sk_next_mat_free":
		flag = true
	_maybe_stamina_zero(session)
	return {"ok": true, "next_mat_free": flag, "played": played, "burned": burns_on_play(card.type)}


static func dig(
	session: CraftStaminaSession,
	stock: WagonStock,
	rng: RandomNumberGenerator
) -> Dictionary:
	if not can_dig(session, stock):
		return {"ok": false}
	## Refresh: leftover hand returns to stock, then draw up to hand_size. No auto-refill otherwise.
	for card in session.hand:
		stock.add(card)
	session.hand.clear()
	_spend(session, session.dig_refresh_cost)
	session.dig_count += 1
	session.hand = stock.draw_up_to(session.hand_size, rng)
	_maybe_stamina_zero(session)
	return {"ok": true, "dig_count": session.dig_count}


static func early_finish(session: CraftStaminaSession) -> bool:
	if session == null or session.is_finished():
		return false
	if session.stamina_remaining == 0:
		session.finish_reason = GameEnums.FinishReason.STAMINA_0
		session.early_finish = false
		return true
	session.early_finish = true
	session.finish_reason = GameEnums.FinishReason.EARLY_FINISH
	return true


static func _spend(session: CraftStaminaSession, amount: int) -> void:
	session.stamina_remaining = maxi(0, session.stamina_remaining - amount)
	session.stamina_spent += amount


static func _maybe_stamina_zero(session: CraftStaminaSession) -> void:
	if session.stamina_remaining == 0 and session.finish_reason == GameEnums.FinishReason.NONE:
		session.early_finish = false
		session.finish_reason = GameEnums.FinishReason.STAMINA_0
