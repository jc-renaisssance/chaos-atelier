class_name WagonStock
extends RefCounted
## Remaining wagon inventory. Dig draws from here; played cards leave (docs/27).

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
