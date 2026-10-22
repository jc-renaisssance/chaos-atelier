class_name EventCatalog
extends RefCounted
## C1 text-event catalog (docs/32 outcomes). Live attach is draw() (docs/33).
## map_m1 ref_ids / NODE_EVENTS are a sample legal draw, not the resolver.

const EVENTS := {
	"evt_c1_heat_mirage": {
		"blurb": "The road shimmers. The horse-car's water skins feel light.",
		"choices": [
			{
				"id": "choice_share_skin",
				"label": "Share the last skin",
				"gold": -1,
				"reps": 1,
				"result": "A walker nods and steps aside.",
			},
			{
				"id": "choice_press_on",
				"label": "Press on",
				"result": "The haze holds. You keep the skins.",
			},
		],
	},
	"evt_c1_ashfall": {
		"blurb": "Fine ash coats the bolts. Someone will pay to brush it — or you keep a scrap.",
		"choices": [
			{
				"id": "choice_brush",
				"label": "Brush the bolts",
				"gold": 2,
				"result": "A ditch clerk pays for the clean-up.",
			},
			{
				"id": "choice_keep_ash",
				"label": "Pocket a charred scrap",
				"mat_add": "mat_iron_scrap",
				"result": "One noisy scrap joins the deck.",
			},
		],
	},
	"evt_c1_scrap_market": {
		"blurb": "A ditch stall after the elite road. Junk, and a polite price.",
		"choices": [
			{
				"id": "choice_buy_scrap",
				"label": "Pay for iron scrap",
				"gold": -1,
				"mat_add": "mat_iron_scrap",
				"result": "You buy one scrap.",
			},
			{
				"id": "choice_walk",
				"label": "Walk on",
				"result": "The stall stays behind.",
			},
		],
	},
	"evt_c1_salt_spray": {
		"blurb": "Salt wind on the last stretch. Leather takes the wet.",
		"choices": [
			{
				"id": "choice_oil",
				"label": "Oil the hides",
				"gold": -2,
				"reps": 1,
				"result": "The deck stays supple.",
			},
			{
				"id": "choice_sell_damp",
				"label": "Sell a damp hide",
				"gold": 2,
				"mat_remove": "mat_leather_tan",
				"result": "One tan leather leaves if owned and the ≥3 floor holds; else gold +2 only and the line notes the skip.",
			},
		],
	},
	"evt_c1_kind_stranger": {
		"blurb": "A walker flags the wagon and leaves a thank-you coin.",
		"choices": [
			{
				"id": "choice_take",
				"label": "Take the coin",
				"gold": 2,
				"result": "The coin hits the purse.",
			},
		],
	},
	"evt_c1_wagon_rattle": {
		"blurb": "A crate lid pops. Lash it, or let a bolt walk.",
		"choices": [
			{
				"id": "choice_lash",
				"label": "Lash the crate",
				"gold": -1,
				"result": "The lid holds.",
			},
			{
				"id": "choice_let_go",
				"label": "Let one bolt walk",
				"mat_remove": "mat_hemp_plain",
				"result": "One hemp leaves if owned and the ≥3 floor holds; else nothing lost.",
			},
		],
	},
	"evt_c1_toll_post": {
		"blurb": "A ditch clerk wants a road tax. Not a run-kill.",
		"choices": [
			{
				"id": "choice_pay",
				"label": "Pay the tax",
				"gold": -2,
				"result": "The ledger closes.",
			},
			{
				"id": "choice_argue",
				"label": "Argue the ledger",
				"reps": -1,
				"result": "The clerk scowls. You roll on.",
			},
		],
	},
}

## Scan order is this table, top to bottom. Weight is the only roll. Rarity is not a second roll.
const EVENT_POOL := {
	"evt_c1_heat_mirage": {"weight": 3, "bands": ["early", "mid"]},
	"evt_c1_ashfall": {"weight": 3, "bands": ["early", "mid"]},
	"evt_c1_kind_stranger": {"weight": 2, "bands": ["early", "mid"]},
	"evt_c1_wagon_rattle": {"weight": 2, "bands": ["early", "mid", "late"]},
	"evt_c1_scrap_market": {"weight": 2, "bands": ["mid", "late"]},
	"evt_c1_salt_spray": {"weight": 2, "bands": ["late"]},
	"evt_c1_toll_post": {"weight": 1, "bands": ["mid", "late"]},
}

## Sample legal draw on map_m1. Not the resolver.
const NODE_EVENTS := {
	"N4": "evt_c1_heat_mirage",
	"N6": "evt_c1_ashfall",
	"N10": "evt_c1_scrap_market",
	"N17": "evt_c1_salt_spray",
}


static func has(event_id: String) -> bool:
	return EVENTS.has(event_id)


static func row(event_id: String) -> Dictionary:
	var found: Variant = EVENTS.get(event_id, {})
	if found is Dictionary:
		return found as Dictionary
	return {}


static func blurb(event_id: String) -> String:
	return String(row(event_id).get("blurb", ""))


## Sample weld only. Live chapter attach is draw().
static func event_for_node(node_id: String) -> String:
	return String(NODE_EVENTS.get(node_id, ""))


## early 1..2, mid 3..4, late 5..(N-2), reserved (N-1) and N. N = day_count.
static func band_for_day(day_index: int, day_count: int) -> String:
	var graph_last := day_count - 2
	if day_index < 1 or day_index > day_count:
		return ""
	if day_index > graph_last:
		return "reserved"
	if day_index <= 2:
		return "early"
	if day_index <= 4:
		return "mid"
	return "late"


## On enter of kind=event. Stable on rng, which the session seeds from chapter_seed.
## 1 in-band unused, 2 any unused, 3 fallback ref if it is in the pool (only then a repeat).
static func draw(
	day_index: int,
	day_count: int,
	resolved: Array,
	rng: RandomNumberGenerator,
	fallback_ref: String
) -> String:
	var band := band_for_day(day_index, day_count)
	if band == "reserved" or band.is_empty():
		return ""
	var picked := _weighted_pick(rng, _pool_candidates(band, resolved, true))
	if not picked.is_empty():
		return picked
	picked = _weighted_pick(rng, _pool_candidates("", resolved, false))
	if not picked.is_empty():
		return picked
	if EVENT_POOL.has(fallback_ref):
		return fallback_ref
	return ""


static func _pool_candidates(band: String, resolved: Array, use_band: bool) -> Array:
	var ids: Array = []
	for key in EVENT_POOL.keys():
		var event_id := String(key)
		if resolved.has(event_id):
			continue
		if use_band:
			var row: Dictionary = EVENT_POOL[key]
			var bands: Array = row.get("bands", [])
			if not bands.has(band):
				continue
		ids.append(event_id)
	return ids


static func _weight_of(event_id: String) -> int:
	var row: Dictionary = EVENT_POOL[event_id]
	return int(row.get("weight", 0))


static func _weighted_pick(rng: RandomNumberGenerator, ids: Array) -> String:
	if ids.is_empty() or rng == null:
		return ""
	var total := 0
	for event_id in ids:
		total += _weight_of(String(event_id))
	if total <= 0:
		return ""
	var roll := rng.randi_range(0, total - 1)
	var acc := 0
	for event_id in ids:
		acc += _weight_of(String(event_id))
		if roll < acc:
			return String(event_id)
	return String(ids[ids.size() - 1])


static func choices(event_id: String) -> Array:
	var found: Variant = row(event_id).get("choices", [])
	if found is Array:
		return found as Array
	return []


static func choice(event_id: String, choice_id: String) -> Dictionary:
	for item in choices(event_id):
		if item is Dictionary:
			var ch: Dictionary = item
			if String(ch.get("id", "")) == choice_id:
				return ch
	return {}


static func gold_cost(ch: Dictionary) -> int:
	var delta := int(ch.get("gold", 0))
	if delta < 0:
		return -delta
	return 0
