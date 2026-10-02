class_name ScheduleRules
extends RefCounted
## Travelling-atelier board rules (docs/22, docs/20). No 1-of-3 lineup.

## Order-class actions enter stamina craft (next PR). Event-class stays on schedule.
const RESOLVE_ORDER := "order"
const RESOLVE_EVENT := "event"


static func free_actions() -> Array[GameEnums.RoundAction]:
	return [
		GameEnums.RoundAction.WALK_IN,
		GameEnums.RoundAction.WAGON_SHOP,
		GameEnums.RoundAction.WAGON_EVENT,
		GameEnums.RoundAction.PREP_CRAFT,
		GameEnums.RoundAction.REST_DIG,
	]


static func resolve_class(action: GameEnums.RoundAction) -> String:
	match action:
		GameEnums.RoundAction.APPOINTMENT, GameEnums.RoundAction.WALK_IN, GameEnums.RoundAction.PREP_CRAFT:
			return RESOLVE_ORDER
		_:
			return RESOLVE_EVENT


static func mission_kind_for(action: GameEnums.RoundAction) -> GameEnums.MissionKind:
	match action:
		GameEnums.RoundAction.APPOINTMENT, GameEnums.RoundAction.WALK_IN:
			return GameEnums.MissionKind.ORDER
		GameEnums.RoundAction.PREP_CRAFT:
			return GameEnums.MissionKind.PREP
		GameEnums.RoundAction.WAGON_EVENT:
			return GameEnums.MissionKind.EVENT
		_:
			return GameEnums.MissionKind.NONE


static func is_order_class(action: GameEnums.RoundAction) -> bool:
	return resolve_class(action) == RESOLVE_ORDER


static func legal_actions(board: ChapterSchedule, declined_this_round: bool) -> Array[GameEnums.RoundAction]:
	var out: Array[GameEnums.RoundAction] = []
	if board == null:
		return out
	var slot := board.current_round()
	if slot == null or slot.round_action != GameEnums.RoundAction.NONE:
		return out
	var pin := board.current_pin()
	var reserved := GameConstants.is_reserved_final_round(board.round_index)
	if pin != null and not reserved and not declined_this_round:
		out.append(GameEnums.RoundAction.APPOINTMENT)
		## Phase-1: decline once / chapter. Other actions on a pinned round consume it.
		if not board.appt_decline_used:
			for action in free_actions():
				out.append(action)
		return out
	for action in free_actions():
		out.append(action)
	return out


static func is_legal(board: ChapterSchedule, action: GameEnums.RoundAction, declined_this_round: bool) -> bool:
	return action in legal_actions(board, declined_this_round)


static func _shuffle(items: Array, rng: RandomNumberGenerator) -> Array:
	var copy: Array = items.duplicate()
	for i in range(copy.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = copy[i]
		copy[i] = copy[j]
		copy[j] = tmp
	return copy


static func roll_boss(chapter_id: int, rng: RandomNumberGenerator) -> String:
	var pool: Array = GameConstants.BOSS_POOLS.get(chapter_id, [])
	if pool.is_empty():
		return ""
	return String(pool[rng.randi_range(0, pool.size() - 1)])


static func roll_pins(chapter_id: int, rng: RandomNumberGenerator) -> Array[AppointmentPin]:
	var pins: Array[AppointmentPin] = []
	var catalog: Array = ScheduleCatalog.appointments_for(chapter_id)
	if catalog.is_empty():
		return pins
	var pin_n: int = rng.randi_range(GameConstants.APPOINTMENT_PIN_MIN, GameConstants.APPOINTMENT_PIN_MAX)
	pin_n = mini(pin_n, catalog.size())
	var pin_rounds: Array = []
	for r in range(GameConstants.APPOINTMENT_PIN_ROUND_MIN, GameConstants.APPOINTMENT_PIN_ROUND_MAX + 1):
		pin_rounds.append(r)
	pin_rounds = _shuffle(pin_rounds, rng)
	var rows: Array = _shuffle(catalog, rng)
	for i in range(pin_n):
		var row: Dictionary = rows[i]
		var pin := AppointmentPin.new()
		pin.appointment_id = String(row.get("appointment_id", ""))
		pin.order_id = String(row.get("order_id", ""))
		pin.pinned_round = int(pin_rounds[i])
		pins.append(pin)
	return pins


static func build_resolve(
	action: GameEnums.RoundAction,
	order: ClientOrder,
	event_row: Dictionary = {}
) -> Dictionary:
	var klass := resolve_class(action)
	var title := ScheduleCatalog.action_title(action)
	var body := ""
	var stub := ""
	match action:
		GameEnums.RoundAction.APPOINTMENT:
			stub = "craft"
			title = "Appointment"
			if order != null:
				var who := ScheduleCatalog.appointment_title(_synthetic_pin(order))
				if not who.is_empty():
					title = "Appointment — %s" % who
			body = (
				"Order path — would enter stamina craft for this pinned client (next PR). "
				+ "Pieces stay order-fixed; this slice does not increment crafts_done."
			)
			if order != null:
				body += " order_id=%s constructions=%s" % [order.order_id, str(Array(order.construction_ids))]
		GameEnums.RoundAction.WALK_IN:
			stub = "craft"
			title = "Walk-in"
			if order != null:
				title = "Walk-in — %s" % ScheduleCatalog.walk_in_title(order)
			body = (
				"Order path — a client appeared this round. Would enter stamina craft (next PR)."
			)
		GameEnums.RoundAction.PREP_CRAFT:
			stub = "craft"
			title = "Prep craft"
			body = (
				"Order path — craft without a live client into the ready rack (mission_kind=prep). "
				+ "Stamina UI is the next PR."
			)
		GameEnums.RoundAction.WAGON_SHOP:
			stub = "shop"
			title = "Wagon shop"
			body = "Event path — stock rotates with the road. Shop UI is not this slice."
		GameEnums.RoundAction.WAGON_EVENT:
			stub = "event"
			title = String(event_row.get("title", "Wagon event"))
			body = String(event_row.get("blurb", "Travel / road event. No craft unless an event later says so."))
		GameEnums.RoundAction.REST_DIG:
			stub = "rest"
			title = "Rest / dig"
			body = "Event path — light stamina meta Later; inventory dig outside craft is optional Phase-1."
		_:
			stub = "none"
			body = "No action."
	return {
		"resolve_class": klass,
		"round_action": GameEnums.round_action_wire(action),
		"mission_kind": GameEnums.mission_kind_wire(mission_kind_for(action)),
		"title": title,
		"body": body,
		"stub": stub,
		"order_id": order.order_id if order != null else "",
		"phase": GameEnums.stamp_phase_wire(GameEnums.StampPhase.SCHEDULE),
		"event_id": String(event_row.get("id", "")),
	}


static func _synthetic_pin(order: ClientOrder) -> AppointmentPin:
	var pin := AppointmentPin.new()
	if order == null:
		return pin
	pin.order_id = order.order_id
	for chapter_id in ScheduleCatalog.APPOINTMENTS.keys():
		for row in ScheduleCatalog.APPOINTMENTS[chapter_id]:
			if String(row.get("order_id", "")) == order.order_id:
				pin.appointment_id = String(row.get("appointment_id", ""))
				return pin
	return pin
