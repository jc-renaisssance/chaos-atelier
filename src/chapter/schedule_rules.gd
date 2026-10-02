class_name ScheduleRules
extends RefCounted
## Travelling-atelier board rules (docs/22, docs/20). No 1-of-3 lineup.

## Order-class actions enter stamina craft (docs/27). Event-class stays on schedule.
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
				"Order path — enter stamina craft for this pinned client. "
				+ "Construction is order-fixed; each piece is one session / one stamp / one crafts_done."
			)
			if order != null:
				body += " order_id=%s constructions=%s" % [order.order_id, str(Array(order.construction_ids))]
		GameEnums.RoundAction.WALK_IN:
			stub = "craft"
			title = "Walk-in"
			if order != null:
				title = "Walk-in — %s" % ScheduleCatalog.walk_in_title(order)
			body = (
				"Order path — a client appeared this round. Enter stamina craft. "
				+ "Pieces stay order-fixed."
			)
		GameEnums.RoundAction.PREP_CRAFT:
			stub = "craft"
			title = "Prep craft"
			body = (
				"Order path — craft without a live client into the ready rack (mission_kind=prep). "
				+ "Same stamina session as a live order."
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


static func build_mission_return(order: ClientOrder, mission: Dictionary, piece_results: Array) -> Dictionary:
	var cons := PackedStringArray()
	if order != null:
		cons = order.construction_ids
	var lines: PackedStringArray = PackedStringArray()
	var kind := GameEnums.mission_kind_wire(order.mission_kind) if order != null else null
	var rating = mission.get("rating", GameEnums.Rating.NONE)
	var cleared := bool(mission.get("cleared", false))
	var hp := float(mission.get("hp_remaining", 0.0))
	var aid := int(mission.get("damage_aid_pct", 0))
	var stars := int(mission.get("skill_effectiveness", 1))
	lines.append(
		"Mission result (docs/23, 24): rating %s · cleared %s · hp %s · aid %d%% · ★%d."
		% [GameEnums.rating_wire(rating), str(cleared), _hp_text(hp), aid, stars]
	)
	lines.append(
		"Gate: cleared = (hp > 0) ∧ rating ∈ {S,A,B,C}. %d piece stamp(s); crafts_done counts pieces."
		% piece_results.size()
	)
	if bool(mission.get("cant_craft", false)):
		lines.append("cant_craft — F, hp>0, aid 0. Normal fail reps, not death Δ.")
	elif not cleared:
		if hp <= 0.0:
			lines.append("Mid death — large −reps. Chapter continues (newspaper mid_fail chrome).")
		else:
			lines.append("Mid-fail — chapter continues. Newspaper mid_fail chrome (copy Later).")
	if kind == "prep":
		lines.append("Prep rack — resolver ran; no live client. Reps not applied.")
	var i := 0
	for result in piece_results:
		i += 1
		var rarity = result.get("craft_rarity", GameEnums.CraftRarity.NONE)
		var piece_rating = result.get("rating", GameEnums.Rating.NONE)
		var outlook := String(result.get("outlook_id", "plain"))
		lines.append(
			"Piece %d · rarity %s · rating %s · look %s."
			% [i, GameEnums.craft_rarity_wire(rarity), GameEnums.rating_wire(piece_rating), outlook]
		)
	return {
		"resolve_class": RESOLVE_ORDER,
		"round_action": null,
		"mission_kind": kind,
		"title": "Mission — %s" % GameEnums.rating_wire(rating),
		"body": "\n".join(lines),
		"stub": "",
		"order_id": order.order_id if order != null else "",
		"phase": GameEnums.stamp_phase_wire(GameEnums.StampPhase.SCHEDULE),
		"construction_ids": Array(cons),
		"piece_count": piece_results.size(),
		"cleared": cleared,
		"rating": GameEnums.rating_wire(rating),
	}


static func build_cant_craft(order: ClientOrder, mission: Dictionary = {}) -> Dictionary:
	var rating = mission.get("rating", GameEnums.Rating.F)
	var hp := float(mission.get("hp_remaining", 1.0))
	return {
		"resolve_class": RESOLVE_ORDER,
		"round_action": null,
		"mission_kind": GameEnums.mission_kind_wire(order.mission_kind) if order != null else null,
		"title": "cant_craft — F",
		"body": (
			"Could not open a legal craft session (crafts_done already at crafts_max=4). "
			+ "No stamina session. crafts_done does not increment. "
			+ "rating %s · hp %s · aid 0 · cleared false (docs/24)."
			% [GameEnums.rating_wire(rating), _hp_text(hp)]
		),
		"stub": "",
		"order_id": order.order_id if order != null else "",
		"phase": GameEnums.stamp_phase_wire(GameEnums.StampPhase.CRAFT),
		"cleared": false,
		"cant_craft": true,
		"rating": "F",
	}


static func build_boss_announce(board: ChapterSchedule) -> Dictionary:
	var boss_id := board.chapter_boss_id if board != null else ""
	var title := ScheduleCatalog.boss_title(boss_id)
	var tags := ", ".join(ThreatCatalog.threat_tags(boss_id))
	var favors := ", ".join(ThreatCatalog.favor_tags(boss_id))
	var punishes := ", ".join(ThreatCatalog.punish_tags(boss_id))
	return {
		"resolve_class": "newspaper",
		"round_action": null,
		"mission_kind": null,
		"title": "Kingdom newspaper — %s" % title,
		"body": (
			"Boss announced before spend (docs/17, 26). %s  ·  pool %s.\n"
			% [title, board.boss_pool_id if board != null else ""]
			+ "Threat %s. Favors %s. Punishes %s.\n" % [tags, favors, punishes]
			+ "Headline id %s (copy Later). Dismiss into the schedule board."
			% GameConstants.HEADLINE_BOSS_ANNOUNCE
		),
		"stub": "newspaper_chrome",
		"newspaper_event": "boss_announce",
		"phase": GameEnums.stamp_phase_wire(GameEnums.StampPhase.NEWSPAPER),
	}


static func build_awaiting_boss(board: ChapterSchedule) -> Dictionary:
	var title := ScheduleCatalog.boss_title(board.chapter_boss_id) if board != null else "Boss"
	return {
		"resolve_class": "boss",
		"round_action": null,
		"mission_kind": "boss",
		"title": "Final prep — face %s" % title,
		"body": (
			"Eight rounds resolved. Appointments never claimed 7–8. "
			+ "Face the announced boss. Fail (adventurer dead / hard loss) = run_over, no retry (docs/24)."
		),
		"stub": "boss_encounter",
		"phase": GameEnums.stamp_phase_wire(GameEnums.StampPhase.SCHEDULE),
	}


static func build_boss_result(board: ChapterSchedule, mission: Dictionary, run_over: bool) -> Dictionary:
	var title := ScheduleCatalog.boss_title(board.chapter_boss_id) if board != null else "Boss"
	var rating = mission.get("rating", GameEnums.Rating.NONE)
	var cleared := bool(mission.get("cleared", false))
	var hp := float(mission.get("hp_remaining", 0.0))
	var lines: PackedStringArray = PackedStringArray()
	lines.append(
		"Boss result vs %s: rating %s · cleared %s · hp %s."
		% [title, GameEnums.rating_wire(rating), str(cleared), _hp_text(hp)]
	)
	if run_over:
		lines.append("run_over · boss_death — no retry (docs/24). Newspaper chrome hd_run_over.")
	else:
		lines.append("Chapter boss cleared. Newspaper chrome hd_chapter_result (copy Later).")
	return {
		"resolve_class": "boss",
		"round_action": null,
		"mission_kind": "boss",
		"title": ("Run over — %s" % title) if run_over else ("Boss clear — %s" % title),
		"body": "\n".join(lines),
		"stub": "boss_encounter",
		"phase": GameEnums.stamp_phase_wire(GameEnums.StampPhase.BOSS),
		"cleared": cleared,
		"run_over": run_over,
		"rating": GameEnums.rating_wire(rating),
	}


static func _hp_text(hp: float) -> String:
	return "%.2f" % hp


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
