class_name ScheduleCatalog
extends RefCounted
## Placeholder appointments / walk-ins / wagon events for the board (docs/22).
## Not a 1-of-3 lineup and not a client encyclopedia.

const BOSS_TITLES := {
	"boss_ash_drake": "Ash Drake",
	"boss_salt_widow": "Salt Widow",
	"boss_rust_knave": "Rust Knave",
	"boss_mire_bride": "Mire Bride",
	"boss_bog_king": "Bog King",
	"boss_pale_choir": "Pale Choir",
	"boss_gilded_warden": "Gilded Warden",
	"boss_ivory_judge": "Ivory Judge",
	"boss_sunspear_captain": "Sunspear Captain",
}

const ROUND_ACTION_TITLE := {
	GameEnums.RoundAction.APPOINTMENT: "Appointment",
	GameEnums.RoundAction.WALK_IN: "Walk-in",
	GameEnums.RoundAction.WAGON_SHOP: "Wagon shop",
	GameEnums.RoundAction.WAGON_EVENT: "Wagon event",
	GameEnums.RoundAction.PREP_CRAFT: "Prep craft",
	GameEnums.RoundAction.REST_DIG: "Rest / dig",
}

## C1–C3 named appointments. Length ≥ APPOINTMENT_PIN_MAX so a chapter can pin 2–4.
const APPOINTMENTS := {
	1: [
		{
			"appointment_id": "appt_c1_ember_patron",
			"order_id": "ord_c1_ember_cloak",
			"title": "Ember Patron",
			"threat_id": "cli_c1_ember_scout",
			"construction_ids": ["con_cloak"],
			"card_difficulty": 2,
		},
		{
			"appointment_id": "appt_c1_dock_captain",
			"order_id": "ord_c1_dock_coat",
			"title": "Dock Captain",
			"threat_id": "cli_c1_dock_hauler",
			"construction_ids": ["con_coat"],
			"card_difficulty": 2,
		},
		{
			"appointment_id": "appt_c1_scrap_duelist",
			"order_id": "ord_c1_scrap_set",
			"title": "Scrap Duelist",
			"threat_id": "cli_c1_scrap_duelist",
			"construction_ids": ["con_armor", "con_gloves"],
			"card_difficulty": 3,
		},
		{
			"appointment_id": "appt_c1_glass_singer",
			"order_id": "ord_c1_glass_robe",
			"title": "Glass Singer",
			"threat_id": "cli_c1_glassblower",
			"construction_ids": ["con_robe"],
			"card_difficulty": 1,
		},
	],
	2: [
		{
			"appointment_id": "appt_c2_mire_acolyte",
			"order_id": "ord_c2_mire_hood",
			"title": "Mire Acolyte",
			"threat_id": "cli_c2_mire_acolyte",
			"construction_ids": ["con_hood"],
			"card_difficulty": 2,
		},
		{
			"appointment_id": "appt_c2_bog_ferry",
			"order_id": "ord_c2_bog_boots",
			"title": "Bog Ferryman",
			"threat_id": "cli_c2_bog_ferry",
			"construction_ids": ["con_boots"],
			"card_difficulty": 2,
		},
		{
			"appointment_id": "appt_c2_pale_cantor",
			"order_id": "ord_c2_pale_robe",
			"title": "Pale Cantor",
			"threat_id": "cli_c2_pale_cantor",
			"construction_ids": ["con_robe"],
			"card_difficulty": 3,
		},
		{
			"appointment_id": "appt_c2_root_warden",
			"order_id": "ord_c2_root_mantle",
			"title": "Root Warden",
			"threat_id": "cli_c2_root_warden",
			"construction_ids": ["con_mantle"],
			"card_difficulty": 2,
		},
	],
	3: [
		{
			"appointment_id": "appt_c3_court_scribe",
			"order_id": "ord_c3_scribe_coat",
			"title": "Court Scribe",
			"threat_id": "cli_c3_court_scribe",
			"construction_ids": ["con_coat"],
			"card_difficulty": 2,
		},
		{
			"appointment_id": "appt_c3_ivory_second",
			"order_id": "ord_c3_ivory_veil",
			"title": "Ivory Second",
			"threat_id": "cli_c3_ivory_second",
			"construction_ids": ["con_crownveil"],
			"card_difficulty": 3,
		},
		{
			"appointment_id": "appt_c3_parade_captain",
			"order_id": "ord_c3_parade_cape",
			"title": "Parade Captain",
			"threat_id": "cli_c3_parade_captain",
			"construction_ids": ["con_cape"],
			"card_difficulty": 2,
		},
		{
			"appointment_id": "appt_c3_marble_host",
			"order_id": "ord_c3_host_set",
			"title": "Marble Host",
			"threat_id": "cli_c3_marble_host",
			"construction_ids": ["con_armor", "con_gloves"],
			"card_difficulty": 3,
		},
	],
}

const WALK_INS := {
	1: [
		{
			"order_id": "ord_walk_c1_pit",
			"title": "Pit Fighter",
			"threat_id": "cli_c1_pit_fighter",
			"construction_ids": ["con_tunic"],
			"card_difficulty": 1,
		},
		{
			"order_id": "ord_walk_c1_hauler",
			"title": "Dock Hauler",
			"threat_id": "cli_c1_dock_hauler",
			"construction_ids": ["con_wraps"],
			"card_difficulty": 2,
		},
	],
	2: [
		{
			"order_id": "ord_walk_c2_reed",
			"title": "Reed Runner",
			"threat_id": "cli_c2_reed_runner",
			"construction_ids": ["con_boots"],
			"card_difficulty": 1,
		},
		{
			"order_id": "ord_walk_c2_choir",
			"title": "Choir Novice",
			"threat_id": "cli_c2_choir_novice",
			"construction_ids": ["con_robe"],
			"card_difficulty": 2,
		},
	],
	3: [
		{
			"order_id": "ord_walk_c3_page",
			"title": "Court Page",
			"threat_id": "cli_c3_court_page",
			"construction_ids": ["con_tunic"],
			"card_difficulty": 1,
		},
		{
			"order_id": "ord_walk_c3_ward",
			"title": "Gilded Ward",
			"threat_id": "cli_c3_gilded_ward",
			"construction_ids": ["con_mantle"],
			"card_difficulty": 2,
		},
	],
}

const WAGON_EVENTS := [
	{"id": "ev_wagon_rut", "title": "Wheel in a rut", "blurb": "The wagon sinks to the axle. Afternoon lost to hauling."},
	{"id": "ev_toll_gate", "title": "Road toll", "blurb": "A bar across the road. Pay, talk, or wait the column out."},
	{"id": "ev_rain_delay", "title": "Storm delay", "blurb": "Canvas drums all afternoon. No new client in this weather."},
	{"id": "ev_road_market", "title": "Road market", "blurb": "Other wagons circle. News and leftover stock — shop UI is the next slice."},
]


static func boss_title(boss_id: String) -> String:
	return String(BOSS_TITLES.get(boss_id, boss_id))


static func action_title(action: GameEnums.RoundAction) -> String:
	return String(ROUND_ACTION_TITLE.get(action, GameEnums.round_action_wire(action)))


static func appointments_for(chapter_id: int) -> Array:
	return APPOINTMENTS.get(chapter_id, APPOINTMENTS[1])


static func walk_ins_for(chapter_id: int) -> Array:
	return WALK_INS.get(chapter_id, WALK_INS[1])


static func appointment_row(appointment_id: String) -> Dictionary:
	for chapter_id in APPOINTMENTS.keys():
		for row in APPOINTMENTS[chapter_id]:
			if String(row.get("appointment_id", "")) == appointment_id:
				return row
	return {}


static func appointment_title(pin: AppointmentPin) -> String:
	if pin == null:
		return ""
	var row := appointment_row(pin.appointment_id)
	if row.is_empty():
		return pin.appointment_id
	return String(row.get("title", pin.appointment_id))


static func _apply_row(order: ClientOrder, row: Dictionary, mission_kind: GameEnums.MissionKind) -> ClientOrder:
	order.order_id = String(row.get("order_id", ""))
	order.threat_id = String(row.get("threat_id", ""))
	var cons: Array = row.get("construction_ids", ["con_tunic"])
	order.construction_ids = PackedStringArray(cons)
	order.card_difficulty = int(row.get("card_difficulty", 2))
	order.mission_kind = mission_kind
	return order


static func order_for_appointment(pin: AppointmentPin) -> ClientOrder:
	var order := ClientOrder.new()
	var row := appointment_row(pin.appointment_id)
	if row.is_empty():
		order.order_id = pin.order_id
		order.construction_ids = PackedStringArray(["con_tunic"])
		order.mission_kind = GameEnums.MissionKind.ORDER
		return order
	_apply_row(order, row, GameEnums.MissionKind.ORDER)
	order.order_id = pin.order_id
	return order


static func make_walk_in(chapter_id: int, round_index: int, rng: RandomNumberGenerator) -> ClientOrder:
	var pool: Array = walk_ins_for(chapter_id)
	var row: Dictionary = pool[rng.randi_range(0, pool.size() - 1)].duplicate()
	row["order_id"] = "ord_walk_c%d_r%d" % [chapter_id, round_index]
	var order := ClientOrder.new()
	return _apply_row(order, row, GameEnums.MissionKind.ORDER)


static func walk_in_title(order: ClientOrder) -> String:
	if order == null:
		return "Walk-in"
	for chapter_id in WALK_INS.keys():
		for row in WALK_INS[chapter_id]:
			if String(row.get("threat_id", "")) == order.threat_id:
				return String(row.get("title", "Walk-in"))
	return "Walk-in"


static func order_title(order: ClientOrder) -> String:
	if order == null:
		return ""
	if order.mission_kind == GameEnums.MissionKind.PREP:
		return "Prep craft"
	for chapter_id in APPOINTMENTS.keys():
		for row in APPOINTMENTS[chapter_id]:
			if String(row.get("order_id", "")) == order.order_id:
				return String(row.get("title", order.order_id))
			if String(row.get("threat_id", "")) == order.threat_id and not order.threat_id.is_empty():
				return String(row.get("title", order.order_id))
	var walk := walk_in_title(order)
	if walk != "Walk-in":
		return walk
	if not order.threat_id.is_empty():
		return ThreatCatalog.display_name(order.threat_id)
	return order.order_id


static func make_prep(round_index: int) -> ClientOrder:
	var order := ClientOrder.new()
	order.order_id = "ord_prep_r%d" % round_index
	order.threat_id = ""
	order.construction_ids = PackedStringArray(["con_tunic"])
	order.card_difficulty = GameConstants.NULL_INT
	order.mission_kind = GameEnums.MissionKind.PREP
	return order


static func pick_wagon_event(rng: RandomNumberGenerator) -> Dictionary:
	return WAGON_EVENTS[rng.randi_range(0, WAGON_EVENTS.size() - 1)]
