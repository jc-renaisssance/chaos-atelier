extends Node
## Live travelling-atelier session. Schedule board (docs/22) + stamina craft (docs/27).

signal board_changed
signal resolve_started(payload: Dictionary)
signal chapter_finished
signal craft_started
signal craft_changed
signal piece_finished(result: Dictionary)
signal craft_order_finished

## docs/22 −reps on decline; docs/25 gate numbers still track the old 3-round shell.
const DECLINE_REPS_STUB := -1

var run_id: String = ""
var chapter_seed: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var board: ChapterSchedule
var last_stamp: HarnessStamp
var last_resolve: Dictionary = {}
var pending_order: ClientOrder
var last_event: Dictionary = {}
var resolve_open: bool = false
var declined_this_round: bool = false
var reps: int = GameConstants.REPS_START
var last_note: String = ""

var stock: WagonStock = WagonStock.new()
var craft_order: ClientOrder
var craft_session: CraftStaminaSession
var craft_open: bool = false
var awaiting_next_piece: bool = false
var order_craft_done: bool = false
var next_mat_free: bool = false
var last_piece_result: Dictionary = {}
var piece_results: Array = []


func _ready() -> void:
	start_chapter(1)


func start_chapter(chapter_id: int = 1, seed: int = 0) -> void:
	if chapter_id < 1 or chapter_id > GameConstants.CHAPTERS_PER_RUN:
		chapter_id = 1
	chapter_seed = seed if seed != 0 else randi()
	rng = RandomNumberGenerator.new()
	rng.seed = chapter_seed
	run_id = "run_%d_%d" % [chapter_seed, int(Time.get_unix_time_from_system())]
	reps = GameConstants.REPS_START
	last_note = ""
	last_resolve = {}
	last_event = {}
	pending_order = null
	resolve_open = false
	declined_this_round = false
	_reset_craft_state()
	stock = WagonStock.new()
	stock.fill_starter()
	board = ChapterSchedule.make_empty(chapter_id)
	var pins := ScheduleRules.roll_pins(chapter_id, rng)
	var boss_id := ScheduleRules.roll_boss(chapter_id, rng)
	var pool_id := String(GameConstants.BOSS_POOL_IDS.get(chapter_id, ""))
	board.begin_live(boss_id, pool_id, pins)
	last_stamp = _make_schedule_stamp()
	var errs := board.schema_errors()
	if not errs.is_empty():
		last_note = "schema: " + ", ".join(errs)
	else:
		last_note = "Boss announced at chapter start. Pins are 2–4 elite telegraphs on rounds 1–6."
	board_changed.emit()


func _reset_craft_state() -> void:
	craft_order = null
	craft_session = null
	craft_open = false
	awaiting_next_piece = false
	order_craft_done = false
	next_mat_free = false
	last_piece_result = {}
	piece_results.clear()


func legal_actions() -> Array[GameEnums.RoundAction]:
	if craft_open:
		return []
	return ScheduleRules.legal_actions(board, declined_this_round)


func can_decline() -> bool:
	if board == null or resolve_open or craft_open or board.appt_decline_used:
		return false
	return board.current_pin() != null and not board.is_current_resolved()


func decline_appointment() -> bool:
	if not can_decline():
		return false
	board.appt_decline_used = true
	declined_this_round = true
	reps = maxi(0, reps + DECLINE_REPS_STUB)
	last_note = "Appointment declined (Phase-1: once / chapter, −reps stub %d). Pick one other action." % DECLINE_REPS_STUB
	board_changed.emit()
	return true


func pick_action(action: GameEnums.RoundAction) -> bool:
	if board == null or resolve_open or craft_open:
		return false
	if not ScheduleRules.is_legal(board, action, declined_this_round):
		return false
	var pin := board.current_pin()
	if pin != null and action != GameEnums.RoundAction.APPOINTMENT and not declined_this_round:
		board.appt_decline_used = true
		declined_this_round = true
		reps = maxi(0, reps + DECLINE_REPS_STUB)
		last_note = "Pinned appointment skipped — decline used (−reps stub %d)." % DECLINE_REPS_STUB
	var order_id := ""
	pending_order = null
	last_event = {}
	match action:
		GameEnums.RoundAction.APPOINTMENT:
			if pin == null:
				return false
			pending_order = ScheduleCatalog.order_for_appointment(pin)
			order_id = pin.order_id
		GameEnums.RoundAction.WALK_IN:
			pending_order = ScheduleCatalog.make_walk_in(board.chapter_id, board.round_index, rng)
			order_id = pending_order.order_id
		GameEnums.RoundAction.PREP_CRAFT:
			pending_order = ScheduleCatalog.make_prep(board.round_index)
			order_id = pending_order.order_id
		GameEnums.RoundAction.WAGON_EVENT:
			last_event = ScheduleCatalog.pick_wagon_event(rng)
		_:
			pass
	if not board.set_primary_action(action, order_id):
		return false
	last_resolve = ScheduleRules.build_resolve(action, pending_order, last_event)
	if ScheduleRules.is_order_class(action):
		if not _begin_craft(pending_order):
			resolve_open = true
			resolve_started.emit(last_resolve)
			board_changed.emit()
		return true
	last_stamp = _make_schedule_stamp()
	resolve_open = true
	if not declined_this_round:
		last_note = "One primary action locked for round %d." % board.round_index
	resolve_started.emit(last_resolve)
	board_changed.emit()
	return true


func _begin_craft(order: ClientOrder) -> bool:
	if order == null or order.piece_count() < 1:
		return false
	if board == null or not board.can_open_piece():
		_emit_cant_craft(order)
		return false
	craft_order = order
	pending_order = order
	piece_results.clear()
	last_piece_result = {}
	awaiting_next_piece = false
	order_craft_done = false
	next_mat_free = false
	craft_open = true
	resolve_open = false
	_open_piece(1)
	craft_started.emit()
	board_changed.emit()
	return true


func _open_piece(piece_index: int) -> void:
	next_mat_free = false
	awaiting_next_piece = false
	craft_session = craft_order.open_piece_session(piece_index)
	CraftRules.opening_draw(craft_session, stock, rng)
	last_stamp = _make_craft_stamp()
	last_note = (
		"Sewing piece %d / %d — %s (order-fixed, not a hand card)."
		% [
			craft_session.piece_index,
			craft_session.piece_count,
			CraftCatalog.construction_name(craft_session.construction_id),
		]
	)
	craft_changed.emit()


func play_hand(hand_index: int) -> bool:
	if not craft_open or craft_session == null or awaiting_next_piece or order_craft_done:
		return false
	var out := CraftRules.play(craft_session, hand_index, next_mat_free)
	if not bool(out.get("ok", false)):
		return false
	next_mat_free = bool(out.get("next_mat_free", false))
	last_stamp = _make_craft_stamp()
	if craft_session.is_finished():
		_resolve_current_piece()
	else:
		last_note = "Played into the piece. Hand does not refill — dig to rummage the wagon."
		craft_changed.emit()
	return true


func dig() -> bool:
	if not craft_open or craft_session == null or awaiting_next_piece or order_craft_done:
		return false
	var out := CraftRules.dig(craft_session, stock, rng)
	if not bool(out.get("ok", false)):
		return false
	last_stamp = _make_craft_stamp()
	if craft_session.is_finished():
		_resolve_current_piece()
	else:
		last_note = "Dug the wagon stock (−%d stamina). Hand refreshed; no auto-refill." % GameConstants.DIG_REFRESH_COST
		craft_changed.emit()
	return true


func finish_early() -> bool:
	if not craft_open or craft_session == null or awaiting_next_piece or order_craft_done:
		return false
	if not CraftRules.early_finish(craft_session):
		return false
	last_stamp = _make_craft_stamp()
	_resolve_current_piece()
	return true


func _resolve_current_piece() -> void:
	CraftRules.return_hand_copies(craft_session, stock)
	var result := CraftResolver.resolve(craft_session, craft_session.construction_id)
	var counted := board.count_finished_piece()
	result["crafts_counted"] = counted
	result["crafts_done"] = board.crafts_done
	last_piece_result = result
	piece_results.append(result)
	last_stamp = _make_craft_stamp(result)
	var more := (
		craft_session.piece_index < craft_session.piece_count
		and board.can_open_piece()
	)
	if more:
		awaiting_next_piece = true
		last_note = (
			"Piece %d finished (%s). crafts_done=%d / %d (pieces, not orders). Sew the next construction."
			% [
				craft_session.piece_index,
				GameEnums.finish_reason_wire(craft_session.finish_reason),
				board.crafts_done,
				board.crafts_max,
			]
		)
	else:
		awaiting_next_piece = false
		order_craft_done = true
		last_note = (
			"Order sewn. %d piece(s). crafts_done=%d / %d. Return to the schedule."
			% [piece_results.size(), board.crafts_done, board.crafts_max]
		)
	piece_finished.emit(result)
	craft_changed.emit()
	board_changed.emit()


func continue_after_piece() -> void:
	if not craft_open:
		return
	if awaiting_next_piece and craft_session != null and craft_order != null:
		_open_piece(craft_session.piece_index + 1)
		return
	if order_craft_done:
		_return_to_schedule()


func _return_to_schedule() -> void:
	last_resolve = ScheduleRules.build_craft_return(craft_order, piece_results)
	craft_open = false
	awaiting_next_piece = false
	order_craft_done = false
	craft_session = null
	resolve_open = true
	last_stamp = _make_schedule_stamp()
	last_note = "Craft closed. Continue to the next schedule round."
	craft_order_finished.emit()
	resolve_started.emit(last_resolve)
	board_changed.emit()


func _emit_cant_craft(order: ClientOrder) -> void:
	var result := CraftResolver.cant_craft_result()
	last_piece_result = result
	last_stamp = _make_cant_craft_stamp(order, result)
	last_resolve = ScheduleRules.build_cant_craft(order)
	last_note = "cant_craft — crafts_max pieces already sewn this chapter. No session, crafts_done unchanged."
	resolve_open = true


func acknowledge_resolve() -> void:
	if not resolve_open or craft_open:
		return
	resolve_open = false
	declined_this_round = false
	pending_order = null
	if not board.advance_round():
		last_note = "Schedule complete. Final prep / boss is the next slice (not this PR)."
		chapter_finished.emit()
	else:
		last_note = "Round %d — pick one action." % board.round_index
	last_stamp = _make_schedule_stamp()
	board_changed.emit()


func cycle_demo_chapter() -> void:
	var next_id := 1
	if board != null:
		next_id = board.chapter_id + 1
		if next_id > GameConstants.CHAPTERS_PER_RUN:
			next_id = 1
	start_chapter(next_id)


func stamp_preview() -> Dictionary:
	if last_stamp == null:
		return {}
	var dump := last_stamp.to_dict()
	var preview := {
		"run_id": dump.get("run_id"),
		"player_owner_id": dump.get("player_owner_id"),
		"chapter_id": dump.get("chapter_id"),
		"chapter_boss_id": dump.get("chapter_boss_id"),
		"boss_pool_id": dump.get("boss_pool_id"),
		"CHAPTER_ROUND_COUNT": dump.get("CHAPTER_ROUND_COUNT"),
		"round_index": dump.get("round_index"),
		"rounds_left": dump.get("rounds_left"),
		"round_action": dump.get("round_action"),
		"appointment_pins": dump.get("appointment_pins"),
		"appt_decline_used": dump.get("appt_decline_used"),
		"crafts_done_this_chapter": dump.get("crafts_done_this_chapter"),
		"crafts_max": dump.get("crafts_max"),
		"phase": dump.get("phase"),
		"mission_kind": dump.get("mission_kind"),
		"order_id": dump.get("order_id"),
		"construction_ids": dump.get("construction_ids"),
		"construction_id": dump.get("construction_id"),
		"piece_index": dump.get("piece_index"),
		"piece_count": dump.get("piece_count"),
		"stamina_start": dump.get("stamina_start"),
		"stamina_remaining": dump.get("stamina_remaining"),
		"stamina_spent": dump.get("stamina_spent"),
		"hand_size": dump.get("hand_size"),
		"dig_refresh_cost": dump.get("dig_refresh_cost"),
		"dig_count": dump.get("dig_count"),
		"cards_played": dump.get("cards_played"),
		"early_finish": dump.get("early_finish"),
		"finish_reason": dump.get("finish_reason"),
		"tag_counts": dump.get("tag_counts"),
		"craft_rarity": dump.get("craft_rarity"),
		"powers_positive": dump.get("powers_positive"),
		"powers_negative": dump.get("powers_negative"),
		"outlook_id": dump.get("outlook_id"),
		"outlook_order": dump.get("outlook_order"),
		"rating": dump.get("rating"),
		"cleared": dump.get("cleared"),
		"cant_craft": dump.get("cant_craft"),
	}
	return preview


func _base_stamp() -> HarnessStamp:
	var stamp := HarnessStamp.new()
	stamp.run_id = run_id
	if board != null:
		stamp.apply_schedule(board)
	stamp.reps_before = reps
	stamp.reps_after = reps
	return stamp


func _make_schedule_stamp() -> HarnessStamp:
	return _base_stamp()


func _make_craft_stamp(result: Dictionary = {}) -> HarnessStamp:
	var stamp := _base_stamp()
	if craft_order != null and craft_session != null:
		stamp.apply_piece_session(craft_order, craft_session)
	if not result.is_empty():
		stamp.apply_resolver(result)
	return stamp


func _make_cant_craft_stamp(order: ClientOrder, result: Dictionary) -> HarnessStamp:
	var stamp := _base_stamp()
	if order != null:
		stamp.mission_kind = order.mission_kind
		stamp.order_id = order.order_id
		stamp.threat_id = order.threat_id
		stamp.construction_ids = order.construction_ids.duplicate()
		stamp.card_difficulty = order.card_difficulty
	stamp.phase = GameEnums.StampPhase.CRAFT
	stamp.session = null
	stamp.cant_craft = true
	stamp.apply_resolver(result)
	return stamp
