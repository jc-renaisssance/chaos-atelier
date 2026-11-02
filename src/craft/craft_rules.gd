class_name CraftRules
extends RefCounted
## Stamina session mutations (docs/27, docs/20 asserts 12–17).
## Skills cycle through discard. Played materials/runes commit until Finish/abort.
## Dig dumps the unplayed hand to discard, then draws. Mid-draw shortfall
## shuffles discard into draw.
## Consumable (Later / not in the stamp type enum) burns instead of discarding.
## No auto-refill. Construction is not a card.
## Stamina 0 ≠ finish (docs/20 assert 14): play / dig never auto-craft.
## Only Finish (player click) ends the session — finish_reason: player_finish.
## A play must target a zone (docs/27). Dig is session-wide.

static func opening_draw(
	session: CraftStaminaSession,
	stock: WagonStock,
	rng: RandomNumberGenerator
) -> void:
	if session == null or stock == null:
		return
	session.hand.clear()
	session.discard_pile.clear()
	session.committed.clear()
	session.draw_pile = stock.take_all()
	_shuffle_pile(session.draw_pile, rng)
	draw_up_to_hand(session, rng)


static func return_run_deck(session: CraftStaminaSession, stock: WagonStock) -> void:
	if session == null or stock == null:
		return
	for card in session.hand:
		stock.add(card)
	for card in session.draw_pile:
		stock.add(card)
	for card in session.discard_pile:
		stock.add(card)
	for card in session.committed:
		stock.add(card)
	session.hand.clear()
	session.draw_pile.clear()
	session.discard_pile.clear()
	session.committed.clear()


static func can_play(
	session: CraftStaminaSession,
	hand_index: int,
	next_mat_free: bool,
	zone_index: int = 0,
	next_cost_less: int = 0
) -> bool:
	if session == null or session.is_finished():
		return false
	if hand_index < 0 or hand_index >= session.hand.size():
		return false
	var target := zone_index if zone_index > 0 else session.selected_zone_index
	if not session.is_legal_zone(target):
		return false
	var card: HandCard = session.hand[hand_index]
	if not _zone_accepts(session, target, card.type):
		return false
	var cost := CraftCatalog.play_cost(card, next_mat_free, next_cost_less)
	return cost <= session.stamina_remaining


static func can_dig(session: CraftStaminaSession, _stock: WagonStock = null) -> bool:
	if session == null or session.is_finished():
		return false
	if session.stamina_remaining < session.dig_refresh_cost:
		return false
	return session.run_deck_count() > 0


static func zone_type_count(
	session: CraftStaminaSession,
	zone_index: int,
	card_type: GameEnums.HandCardType
) -> int:
	if session == null:
		return 0
	var n := 0
	for played in session.cards_played:
		if played != null and played.zone_index == zone_index and played.type == card_type:
			n += 1
	return n


static func _zone_accepts(
	session: CraftStaminaSession,
	zone_index: int,
	card_type: GameEnums.HandCardType
) -> bool:
	## docs/40: commitment + stamina replace hard material/rune slot caps.
	return session.is_legal_zone(zone_index) and card_type in [
		GameEnums.HandCardType.MATERIAL,
		GameEnums.HandCardType.RUNE,
		GameEnums.HandCardType.SKILL,
	]


static func burns_on_play(type: GameEnums.HandCardType) -> bool:
	## Consumable (Later, distinct type, not in the stamp enum) burns.
	return (
		type != GameEnums.HandCardType.MATERIAL
		and type != GameEnums.HandCardType.RUNE
		and type != GameEnums.HandCardType.SKILL
	)


static func play(
	session: CraftStaminaSession,
	hand_index: int,
	next_mat_free: bool,
	zone_index: int = 0,
	next_cost_less: int = 0,
	next_stat_heavy: bool = false,
	rng: RandomNumberGenerator = null
) -> Dictionary:
	if session == null:
		return {
			"ok": false,
			"next_mat_free": next_mat_free,
			"next_cost_less": next_cost_less,
			"next_stat_heavy": next_stat_heavy,
		}
	var target := zone_index if zone_index > 0 else session.selected_zone_index
	if not can_play(session, hand_index, next_mat_free, target, next_cost_less):
		return {
			"ok": false,
			"next_mat_free": next_mat_free,
			"next_cost_less": next_cost_less,
			"next_stat_heavy": next_stat_heavy,
		}
	var card: HandCard = session.hand[hand_index]
	var cost := CraftCatalog.play_cost(card, next_mat_free, next_cost_less)
	## The played card leaves before a starter skill discards or draws (docs/39).
	session.hand.remove_at(hand_index)
	var committed := (
		card.type == GameEnums.HandCardType.MATERIAL
		or card.type == GameEnums.HandCardType.RUNE
	)
	var burned := burns_on_play(card.type)
	if committed:
		session.committed.append(card)
	elif not burned:
		session.discard_pile.append(card)
	_spend(session, cost)
	session.focus_zone(target)
	var played := PlayedCard.new()
	played.id = card.id
	played.type = card.type
	played.cost = cost
	played.zone_index = target
	played.construction_id = session.construction_id_for_zone(target)
	played.mat_enchant_id = card.mat_enchant_id
	played.starter_role = card.starter_role
	session.cards_played.append(played)
	## Incoming next-card modifiers apply to this zone play, then this skill may set the next one.
	## Dig does not enter this function. Finish ends the session and clears the flags outside.
	var free := next_mat_free
	var less := next_cost_less
	var heavy := next_stat_heavy
	var scrap_pick := false
	if card.type == GameEnums.HandCardType.MATERIAL and free:
		free = false
	if less > 0:
		less = 0
	if heavy and card.type == GameEnums.HandCardType.MATERIAL:
		heavy = false
		played.stat_one_and_half = true
	if card.type == GameEnums.HandCardType.SKILL:
		if card.id == "sk_next_mat_free":
			free = true
		elif card.id == "sk_metal_str_double":
			_double_committed_metal_atk(session, target)
		elif card.id == "sk_wild_to_earth":
			_convert_latest_wild_to_earth(session, target)
		elif card.id == "sk_touch_up":
			_touch_up_latest_material(session, target)
		elif card.id == "sk_deep_dig":
			_refresh_hand_free(session, rng)
		elif card.id == "sk_ease_draw":
			less = 1
			draw_one(session, rng)
		elif card.id == "sk_heavy_draw":
			heavy = true
			draw_one(session, rng)
		elif card.id == "sk_scrap_breath":
			scrap_pick = _scrap_breath_after_leave(session)
	return {
		"ok": true,
		"next_mat_free": free,
		"next_cost_less": less,
		"next_stat_heavy": heavy,
		"scrap_pick": scrap_pick,
		"played": played,
		"burned": burned,
		"committed": committed,
	}


static func _double_committed_metal_atk(
	session: CraftStaminaSession,
	zone_index: int
) -> void:
	for played in session.cards_played:
		if played.type != GameEnums.HandCardType.MATERIAL or played.zone_index != zone_index:
			continue
		if int(CraftCatalog.tag_pips_for_played(played).get("Metal", 0)) > 0:
			played.double_atk = true


static func _convert_latest_wild_to_earth(
	session: CraftStaminaSession,
	zone_index: int
) -> void:
	for i in range(session.cards_played.size() - 1, -1, -1):
		var played: PlayedCard = session.cards_played[i]
		if played.type != GameEnums.HandCardType.MATERIAL or played.zone_index != zone_index:
			continue
		var raw_pips := CraftCatalog.tag_pips_of(played.id, played.type)
		var wild_pips := int(raw_pips.get("Wild", 0))
		if wild_pips <= 0 or "Wild" in played.suppressed_tags:
			continue
		played.suppressed_tags.append("Wild")
		played.tag_pip_bonus["Earth"] = int(played.tag_pip_bonus.get("Earth", 0)) + wild_pips
		return


static func _touch_up_latest_material(
	session: CraftStaminaSession,
	zone_index: int
) -> void:
	for i in range(session.cards_played.size() - 1, -1, -1):
		var played: PlayedCard = session.cards_played[i]
		if played.type != GameEnums.HandCardType.MATERIAL or played.zone_index != zone_index:
			continue
		var stats := CraftCatalog.stat_bag(played.id, played.type)
		var best_key := ""
		var best_value := 0
		for stat in ["HP", "ATK", "DEF", "RES", "MOB", "PRE"]:
			var value := int(stats.get(stat, 0))
			if value > best_value:
				best_value = value
				best_key = stat
		if not best_key.is_empty():
			played.stat_bonus_key = best_key
		return


static func _refresh_hand_free(
	session: CraftStaminaSession,
	rng: RandomNumberGenerator
) -> void:
	for remaining in session.hand:
		session.discard_pile.append(remaining)
	session.hand.clear()
	draw_up_to_hand(session, rng)


static func dig(
	session: CraftStaminaSession,
	_stock: WagonStock,
	rng: RandomNumberGenerator
) -> Dictionary:
	if not can_dig(session):
		return {"ok": false}
	## Refresh: leftover hand drops to discard, then draw up to hand_size.
	## Mid-draw shortfall shuffles discard into draw. No auto-refill otherwise.
	for card in session.hand:
		session.discard_pile.append(card)
	session.hand.clear()
	_spend(session, session.dig_refresh_cost)
	session.dig_count += 1
	draw_up_to_hand(session, rng)
	return {"ok": true, "dig_count": session.dig_count}


## One card from the draw pile. A short pile shuffles discard into draw. Empty after that draws 0.
static func draw_one(session: CraftStaminaSession, rng: RandomNumberGenerator) -> bool:
	if session == null:
		return false
	if session.draw_pile.is_empty():
		if not reshuffle_discard_into_draw(session, rng):
			return false
	if session.draw_pile.is_empty():
		return false
	session.hand.append(session.draw_pile.pop_back())
	return true


## docs/39 scrap_breath A. The skill has already left the hand.
## 0 other cards: no discard, no stamina. Exactly 1: that card, then +1.
## 2 or more: the player picks. This returns true and does not choose a card.
static func _scrap_breath_after_leave(session: CraftStaminaSession) -> bool:
	if session == null or session.hand.is_empty():
		return false
	if session.hand.size() != 1:
		return true
	discard_scrap_other(session, 0)
	return false


## The picked other card leaves the hand to discard, then stamina +1.
static func discard_scrap_other(session: CraftStaminaSession, hand_index: int) -> bool:
	if session == null or hand_index < 0 or hand_index >= session.hand.size():
		return false
	var other: HandCard = session.hand[hand_index]
	session.hand.remove_at(hand_index)
	session.discard_pile.append(other)
	session.stamina_remaining += 1
	return true


static func draw_up_to_hand(session: CraftStaminaSession, rng: RandomNumberGenerator) -> void:
	if session == null:
		return
	while session.hand.size() < session.hand_size:
		if session.draw_pile.is_empty():
			if not reshuffle_discard_into_draw(session, rng):
				break
		if session.draw_pile.is_empty():
			break
		session.hand.append(session.draw_pile.pop_back())


static func reshuffle_discard_into_draw(
	session: CraftStaminaSession,
	rng: RandomNumberGenerator
) -> bool:
	if session == null or session.discard_pile.is_empty():
		return false
	for card in session.discard_pile:
		session.draw_pile.append(card)
	session.discard_pile.clear()
	_shuffle_pile(session.draw_pile, rng)
	return true


static func early_finish(session: CraftStaminaSession) -> bool:
	## Finish button — the only Phase-1 legal end (docs/20 assert 14).
	## stamina_remaining == 0 does not change this path.
	if session == null or session.is_finished():
		return false
	session.early_finish = true
	session.finish_reason = GameEnums.FinishReason.PLAYER_FINISH
	return true


static func _spend(session: CraftStaminaSession, amount: int) -> void:
	session.stamina_remaining = maxi(0, session.stamina_remaining - amount)
	session.stamina_spent += amount


static func _shuffle_pile(cards: Array[HandCard], rng: RandomNumberGenerator) -> void:
	if rng == null or cards.size() < 2:
		return
	for i in range(cards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: HandCard = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp
