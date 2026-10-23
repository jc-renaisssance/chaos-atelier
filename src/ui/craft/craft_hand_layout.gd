class_name CraftHandLayout
extends RefCounted
## Hand A′ geometry (docs/36). The fan step is FAN_SPAN_DEG / (max_hand - 1).
## There is no per-step angle constant. max_hand is the hand-size setting.
## n is the cards in the hand this frame. A short hand recenters the same step.

const CARD_W := 108.0
const CARD_H := 148.0
const FACE_PX := 88.0
const FAN_SPAN_DEG := 32.0
const FAN_STRIDE_PX := 312.0
const FAN_ARC_PX := 20.0
const HOVER_LIFT_PX := 16.0
const HOVER_SCALE := 1.06
const HOVER_SEC := 0.08
const REFLOW_SEC := 0.08


static func steps(n: int, max_hand: int) -> Dictionary:
	var denom := max_hand - 1
	if n <= 1 or denom <= 0:
		return {"step_deg": 0.0, "x_step": 0.0, "arc_step": 0.0}
	return {
		"step_deg": FAN_SPAN_DEG / float(denom),
		"x_step": FAN_STRIDE_PX / float(denom),
		"arc_step": (2.0 * FAN_ARC_PX) / float(denom),
	}


static func pose(i: int, n: int, max_hand: int) -> Dictionary:
	var step := steps(n, max_hand)
	var center := float(n - 1) / 2.0
	var delta := float(i) - center
	return {
		"rotation": delta * float(step["step_deg"]),
		"x": delta * float(step["x_step"]),
		"y": absf(delta) * float(step["arc_step"]),
	}


## Lowest pivot sits on the bottom of the band. y in pose() is how far that card sits below the center card.
static func top_left(i: int, n: int, max_hand: int, band: Vector2) -> Vector2:
	var here := pose(i, n, max_hand)
	var lowest := 0.0
	if n > 1:
		lowest = float(pose(0, n, max_hand)["y"])
	var pivot := Vector2(
		band.x * 0.5 + float(here["x"]),
		band.y - lowest + float(here["y"])
	)
	return pivot - Vector2(CARD_W * 0.5, CARD_H)


static func rotation_rad(i: int, n: int, max_hand: int) -> float:
	return deg_to_rad(float(pose(i, n, max_hand)["rotation"]))


static func band_min_size() -> Vector2:
	return Vector2(FAN_STRIDE_PX + CARD_W, CARD_H + FAN_ARC_PX + HOVER_LIFT_PX)
