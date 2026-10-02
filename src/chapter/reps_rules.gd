class_name RepsRules
extends RefCounted
## docs/25 Δ formula. Gate numbers (8/14/20) still track the old 3-round shell — Later.

const RATING_MULT := {
	GameEnums.Rating.S: 3.0,
	GameEnums.Rating.A: 2.0,
	GameEnums.Rating.B: 1.5,
	GameEnums.Rating.C: 1.0,
	GameEnums.Rating.D: 0.0,
	GameEnums.Rating.F: 0.0,
}


static func difficulty_or_default(card_difficulty: int) -> int:
	if card_difficulty == GameConstants.NULL_INT:
		return 0
	return clampi(card_difficulty, 1, 3)


static func delta(result: Dictionary, card_difficulty: int) -> int:
	var diff := difficulty_or_default(card_difficulty)
	if diff == 0:
		return 0
	var cleared := bool(result.get("cleared", false))
	var rating = result.get("rating", GameEnums.Rating.F)
	if cleared:
		return int(round(float(RATING_MULT.get(rating, 0.0)) * float(diff)))
	## cant_craft: F + hp>0 → normal fail Δ, not death Δ (docs/24, 25).
	var hp := float(result.get("hp_remaining", 1.0))
	var cant := bool(result.get("cant_craft", false))
	if not cant and hp <= 0.0:
		return -3 * diff
	return -diff


static func apply(reps_before: int, result: Dictionary, card_difficulty: int) -> Dictionary:
	var d := delta(result, card_difficulty)
	var after := maxi(0, reps_before + d)
	return {
		"reps_before": reps_before,
		"reps_after": after,
		"reps_delta": after - reps_before,
		"reps_gate": GameConstants.REPS_GATE_STUB,
	}
