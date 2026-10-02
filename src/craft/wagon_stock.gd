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
	cards.append(HandCard.make(card.id, card.type))


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
