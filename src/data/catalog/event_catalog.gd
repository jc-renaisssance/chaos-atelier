class_name EventCatalog
extends RefCounted
## C1 text-event catalog (docs/32). Bound rows ride map_m1 ref_id. Extras are Test-only.

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


static func event_for_node(node_id: String) -> String:
	return String(NODE_EVENTS.get(node_id, ""))


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
