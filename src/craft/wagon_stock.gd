class_name WagonStock
extends RefCounted
## Atelier inventory between beats (docs/27). During a piece the run deck is
## session hand + draw + discard. Shop sell / explicit loss still change stock.
## Play leaves the hand → discard; persist via reshuffle, not in-hand.

var cards: Array[HandCard] = []


func fill_starter() -> void:
	cards.clear()
	for card in CraftCatalog.own_basic_starter():
		cards.append(card)


func count() -> int:
	return cards.size()


func is_empty() -> bool:
	return cards.is_empty()


func add(card: HandCard) -> void:
	if card != null:
		cards.append(card)


func add_copy(card: HandCard) -> void:
	if card == null:
		return
	cards.append(card.duplicate_live())


func add_material(mat_id: String) -> HandCard:
	var card := HandCard.make(mat_id, GameEnums.HandCardType.MATERIAL)
	add(card)
	return card


func material_count() -> int:
	var n := 0
	for card in cards:
		if card != null and card.type == GameEnums.HandCardType.MATERIAL:
			n += 1
	return n


func owned_count(card_id: String) -> int:
	var n := 0
	for card in cards:
		if card != null and card.id == card_id:
			n += 1
	return n


func can_remove_material() -> bool:
	return material_count() > GameConstants.MARKET_MATERIAL_FLOOR


func remove_at(index: int) -> HandCard:
	if index < 0 or index >= cards.size():
		return null
	var card: HandCard = cards[index]
	cards.remove_at(index)
	return card


func remove_one_material(mat_id: String) -> HandCard:
	for i in range(cards.size()):
		var card: HandCard = cards[i]
		if card != null and card.type == GameEnums.HandCardType.MATERIAL and card.id == mat_id:
			cards.remove_at(i)
			return card
	return null


func take_all() -> Array[HandCard]:
	var out: Array[HandCard] = []
	for card in cards:
		out.append(card)
	cards.clear()
	return out


func shuffle(rng: RandomNumberGenerator) -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: HandCard = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp


func draw_up_to(n: int, rng: RandomNumberGenerator) -> Array[HandCard]:
	var out: Array[HandCard] = []
	if n <= 0:
		return out
	shuffle(rng)
	while out.size() < n and not cards.is_empty():
		out.append(cards.pop_back())
	return out
