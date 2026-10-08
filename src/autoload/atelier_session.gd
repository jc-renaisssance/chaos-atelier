extends Node
## Live travelling-atelier session. Schedule (22) + stamina craft (27) + mission (23/24).
## Autoload singleton is already named AtelierSession — do not add class_name.

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
var order_craft_done: bool = false
var next_mat_free: bool = false
var last_piece_result: Dictionary = {}
var piece_results: Array = []
var piece_stamps: Array = []
var chapter_piece_results: Array = []
var last_mission: Dictionary = {}

var newspaper_open: bool = false
var awaiting_boss: bool = false
var boss_open: bool = false
var boss_client_id: String = ""
var boss_job_id: String = ""
var chapter_over: bool = false
var run_over: bool = false
var run_over_reason: GameEnums.RunOverReason = GameEnums.RunOverReason.NONE
var last_newspaper_event: GameEnums.NewspaperEvent = GameEnums.NewspaperEvent.NONE
var last_headline_id: String = ""
var last_letter_id: String = ""
## Fashion encyclopedia is Later (docs/04). Phase-1 unlock set for Potential readout (docs/27).
var unlocked_outlooks: PackedStringArray = PackedStringArray(["plain"])


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
	last_mission = {}
	pending_order = null
	resolve_open = false
	declined_this_round = false
	newspaper_open = false
	awaiting_boss = false
	boss_open = false
	boss_client_id = ""
	boss_job_id = ""
	chapter_over = false
	run_over = false
	run_over_reason = GameEnums.RunOverReason.NONE
	last_newspaper_event = GameEnums.NewspaperEvent.NONE
	last_headline_id = ""
	last_letter_id = ""
	unlocked_outlooks = PackedStringArray(["plain"])
	chapter_piece_results.clear()
	_reset_craft_state()
	stock = WagonStock.new()
	stock.fill_starter()
	board = ChapterSchedule.make_empty(chapter_id)
	var pins := ScheduleRules.roll_pins(chapter_id, rng)
	var boss_id := ScheduleRules.roll_boss(chapter_id, rng)
	var pool_id := String(GameConstants.BOSS_POOL_IDS.get(chapter_id, ""))
	board.begin_live(boss_id, pool_id, pins)
	newspaper_open = true
	resolve_open = true
	last_newspaper_event = GameEnums.NewspaperEvent.BOSS_ANNOUNCE
	last_headline_id = GameConstants.HEADLINE_BOSS_ANNOUNCE
	last_resolve = ScheduleRules.build_boss_announce(board)
	last_stamp = _make_newspaper_stamp()
	var errs := board.schema_errors()
	if not errs.is_empty():
		last_note = "schema: " + ", ".join(errs)
	else:
		last_note = "Kingdom newspaper — boss announced before spend. Pins are 2–4 elite telegraphs on rounds 1–6."
	resolve_started.emit(last_resolve)
	board_changed.emit()


func _reset_craft_state() -> void:
	craft_order = null
	craft_session = null
	craft_open = false
	order_craft_done = false
	next_mat_free = false
	last_piece_result = {}
	piece_results.clear()
	piece_stamps.clear()


func legal_actions() -> Array[GameEnums.RoundAction]:
	if craft_open or newspaper_open or awaiting_boss or boss_open or chapter_over or run_over:
		return []
	return ScheduleRules.legal_actions(board, declined_this_round)


func can_decline() -> bool:
	if board == null or resolve_open or craft_open or board.appt_decline_used:
		return false
	if newspaper_open or awaiting_boss or boss_open or chapter_over or run_over:
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
	if newspaper_open or awaiting_boss or boss_open or chapter_over or run_over:
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


func _is_boss_order(order: ClientOrder) -> bool:
	return order != null and order.mission_kind == GameEnums.MissionKind.BOSS


func _begin_craft(order: ClientOrder) -> bool:
	if order == null or order.piece_count() < 1:
		return false
	if order.piece_count() > GameConstants.ZONE_COUNT_MAX:
		last_note = "Order lists more than 4 constructions — Later / split. No fifth zone."
		return false
	## Boss-client sew is the boss beat — not one of the 4 chapter pieces (docs/20, 28).
	if not _is_boss_order(order) and (board == null or not board.can_open_piece()):
		_emit_cant_craft(order)
		return false
	craft_order = order
	pending_order = order
	piece_results.clear()
	piece_stamps.clear()
	last_piece_result = {}
	order_craft_done = false
	next_mat_free = false
	craft_open = true
	resolve_open = false
	_open_session()
	craft_started.emit()
	board_changed.emit()
	return true


func _open_session() -> void:
	next_mat_free = false
	craft_session = craft_order.open_session()
	CraftRules.opening_draw(craft_session, stock, rng)
	last_stamp = _make_craft_stamp()
	var names: PackedStringArray = PackedStringArray()
	for con_id in craft_session.construction_ids:
		names.append(CraftCatalog.construction_name(con_id))
	last_note = (
		"One session · %d zone(s) · stamina %d (12×%d). Listed: %s. Play must target a zone."
		% [
			craft_session.zone_count,
			craft_session.stamina_start,
			craft_session.piece_count,
			", ".join(names),
		]
	)
	craft_changed.emit()


func select_zone(zone_index: int) -> bool:
	if not craft_open or craft_session == null or order_craft_done:
		return false
	if not craft_session.focus_zone(zone_index):
		return false
	last_stamp = _make_craft_stamp()
	last_note = (
		"Selected zone %d — %s. 1–5 plays into this zone. Drag also targets a zone."
		% [zone_index, CraftCatalog.construction_name(craft_session.construction_id)]
	)
	craft_changed.emit()
	return true


func play_hand(hand_index: int, zone_index: int = 0) -> bool:
	if not craft_open or craft_session == null or order_craft_done:
		return false
	var target := zone_index if zone_index > 0 else craft_session.selected_zone_index
	if not craft_session.is_legal_zone(target):
		return false
	var out := CraftRules.play(craft_session, hand_index, next_mat_free, target)
	if not bool(out.get("ok", false)):
		return false
	next_mat_free = bool(out.get("next_mat_free", false))
	last_stamp = _make_craft_stamp()
	## Stamina 0 does not finish. Only Finish (finish_early) crafts.
	if craft_session.is_finished():
		_resolve_session()
	else:
		last_note = (
			"Played into zone %d — card left the hand to discard. "
			% target
			+ "Hand does not refill — dig dumps remaining cards, then draws. "
			+ "Stamina 0 keeps the session open until Finish."
		)
		craft_changed.emit()
	return true


func dig() -> bool:
	if not craft_open or craft_session == null or order_craft_done:
		return false
	var out := CraftRules.dig(craft_session, stock, rng)
	if not bool(out.get("ok", false)):
		return false
	last_stamp = _make_craft_stamp()
	## Stamina 0 does not finish. Only Finish (finish_early) crafts.
	if craft_session.is_finished():
		_resolve_session()
	else:
		last_note = (
			"Dug (−%d, session-wide). Remaining hand to discard; drew a new hand (reshuffle if draw was short). Stamina 0 keeps the session open until Finish."
			% GameConstants.DIG_REFRESH_COST
		)
		craft_changed.emit()
	return true


func finish_early() -> bool:
	## Explicit Finish — the only Phase-1 legal craft end (player_finish).
	## One click ends the whole session and resolves listed pieces in order.
	if not craft_open or craft_session == null or order_craft_done:
		return false
	if not CraftRules.early_finish(craft_session):
		return false
	_resolve_session()
	return true


func _resolve_session() -> void:
	CraftRules.return_run_deck(craft_session, stock)
	piece_results.clear()
	piece_stamps.clear()
	var keep_zone := craft_session.selected_zone_index
	var n := craft_session.zone_count
	for i in range(1, n + 1):
		craft_session.focus_zone(i)
		var craft := CraftResolver.resolve(craft_session, craft_session.construction_id, i)
		var result := MissionResolver.grade_piece(craft, craft_order)
		var counted := false
		if not _is_boss_order(craft_order):
			counted = board.count_finished_piece()
		result["crafts_counted"] = counted
		result["crafts_done"] = board.crafts_done
		result["piece_index"] = i
		result["zone_index"] = i
		result["construction_id"] = craft_session.construction_id
		last_piece_result = result
		piece_results.append(result)
		_unlock_outlook(String(result.get("outlook_id", "plain")))
		if counted:
			chapter_piece_results.append(result)
		var stamp := _make_craft_stamp(result)
		piece_stamps.append(stamp.to_dict())
		last_stamp = stamp
		piece_finished.emit(result)
	if craft_session.is_legal_zone(keep_zone):
		craft_session.focus_zone(keep_zone)
	order_craft_done = true
	last_note = (
		"Session finished (player_finish). %d piece(s) stamped in listed order. crafts_done=%d / %d."
		% [piece_results.size(), board.crafts_done, board.crafts_max]
	)
	craft_changed.emit()
	board_changed.emit()


func continue_after_piece() -> void:
	if not craft_open:
		return
	if order_craft_done:
		_return_to_schedule()


func _return_to_schedule() -> void:
	if _is_boss_order(craft_order):
		_run_boss()
		return
	var mission := MissionResolver.resolve_order(piece_results, craft_order)
	last_mission = mission
	last_letter_id = String(mission.get("letter_id", ""))
	var apply_order_reps := craft_order != null and craft_order.mission_kind == GameEnums.MissionKind.ORDER
	if apply_order_reps:
		_apply_reps(mission, craft_order.card_difficulty)
		if not bool(mission.get("cleared", false)):
			last_newspaper_event = GameEnums.NewspaperEvent.MID_FAIL
			last_headline_id = GameConstants.HEADLINE_MID_FAIL
	last_resolve = ScheduleRules.build_mission_return(craft_order, mission, piece_results)
	craft_open = false
	order_craft_done = false
	craft_session = null
	resolve_open = true
	last_stamp = _make_mission_return_stamp(mission)
	last_note = (
		"Mission %s · cleared %s · hp %.2f. Continue to the next schedule round."
		% [
			GameEnums.rating_wire(mission.get("rating", GameEnums.Rating.NONE)),
			str(bool(mission.get("cleared", false))),
			float(mission.get("hp_remaining", 0.0)),
		]
	)
	craft_order_finished.emit()
	resolve_started.emit(last_resolve)
	board_changed.emit()


func _emit_cant_craft(order: ClientOrder) -> void:
	var result := MissionResolver.cant_craft_result()
	last_piece_result = result
	last_mission = result
	last_letter_id = ""
	if order != null and order.mission_kind == GameEnums.MissionKind.ORDER:
		_apply_reps(result, order.card_difficulty)
	last_newspaper_event = GameEnums.NewspaperEvent.MID_FAIL
	last_headline_id = GameConstants.HEADLINE_MID_FAIL
	last_stamp = _make_cant_craft_stamp(order, result)
	last_resolve = ScheduleRules.build_cant_craft(order, result)
	last_note = "cant_craft — F, hp>0, aid 0. crafts_done unchanged. Mid-fail continues."
	resolve_open = true


func acknowledge_resolve() -> void:
	if not resolve_open or craft_open:
		return
	if newspaper_open:
		newspaper_open = false
		resolve_open = false
		last_newspaper_event = GameEnums.NewspaperEvent.NONE
		last_headline_id = ""
		last_resolve = {}
		last_note = "Round %d — pick one action." % board.round_index
		last_stamp = _make_schedule_stamp()
		board_changed.emit()
		return
	if boss_open:
		resolve_open = false
		chapter_over = true
		if run_over:
			last_note = "Run over (%s). No retry." % GameEnums.run_over_reason_wire(run_over_reason)
		else:
			last_note = "Chapter clear. Next chapter is a demo cycle."
			chapter_finished.emit()
		last_stamp = _make_end_stamp()
		board_changed.emit()
		return
	if awaiting_boss:
		_begin_boss_client_craft()
		return
	if chapter_over or run_over:
		return
	resolve_open = false
	declined_this_round = false
	pending_order = null
	last_newspaper_event = GameEnums.NewspaperEvent.NONE
	last_headline_id = ""
	if not board.advance_round():
		if _reps_gate_miss():
			run_over = true
			run_over_reason = GameEnums.RunOverReason.REPS_GATE_MISS
			last_newspaper_event = GameEnums.NewspaperEvent.RUN_OVER
			last_headline_id = GameConstants.HEADLINE_RUN_OVER
			resolve_open = true
			chapter_over = true
			last_resolve = {
				"resolve_class": "newspaper",
				"title": "Run over — reps gate",
				"body": "reps_after < reps_gate (stub gate %d). run_over_reason=reps_gate_miss." % GameConstants.REPS_GATE_STUB,
				"stub": "newspaper_chrome",
				"phase": "newspaper",
			}
			last_note = "Run over — reps_gate_miss. Gate numbers Later; stub gate is 0."
			last_stamp = _make_end_stamp()
			resolve_started.emit(last_resolve)
		else:
			awaiting_boss = true
			resolve_open = true
			last_resolve = ScheduleRules.build_awaiting_boss(board)
			last_note = "Schedule complete. Boss beat: draw a shared-pool adventurer, then sew that job's constructions."
			last_stamp = _make_schedule_stamp()
			resolve_started.emit(last_resolve)
	else:
		last_resolve = {}
		last_note = "Round %d — pick one action." % board.round_index
		last_stamp = _make_schedule_stamp()
	board_changed.emit()


func _reps_gate_miss() -> bool:
	## docs/20 assert 19. Gate numbers Later — stub 0 never trips a started-at-0 run.
	return reps < GameConstants.REPS_GATE_STUB


func _begin_boss_client_craft() -> void:
	## Boss beat (docs/28 + 29): seeded 4-job named draw, independent of chapter_boss_id.
	awaiting_boss = false
	var job := BossClientCatalog.pick_boss_client(chapter_seed)
	boss_client_id = String(job.get("boss_client_id", ""))
	boss_job_id = String(job.get("job_id", ""))
	var boss_id := board.chapter_boss_id if board != null else ""
	var order := BossClientCatalog.make_order(job, boss_id)
	last_resolve = ScheduleRules.build_boss_client_draw(board, job)
	if _begin_craft(order):
		var who := AdventurerCatalog.display_name(boss_client_id)
		last_note = (
			"Boss beat — %s · %s (%s) sews %s vs %s. Player is the clothier."
			% [
				who,
				BossClientCatalog.display_name(boss_job_id),
				boss_client_id,
				", ".join(Array(order.construction_ids)),
				ScheduleCatalog.boss_title(boss_id),
			]
		)
		craft_changed.emit()
		return
	piece_results.clear()
	_run_boss()


func _run_boss() -> void:
	awaiting_boss = false
	boss_open = true
	craft_open = false
	order_craft_done = false
	craft_session = null
	## Sim uses this adventurer's gear (the boss-client sew), not mid-chapter pieces.
	var mission := MissionResolver.resolve_boss(piece_results, board.chapter_boss_id if board != null else "")
	last_mission = mission
	last_letter_id = String(mission.get("letter_id", ""))
	var cleared := bool(mission.get("cleared", false))
	if not cleared:
		run_over = true
		run_over_reason = GameEnums.RunOverReason.BOSS_DEATH
		last_newspaper_event = GameEnums.NewspaperEvent.RUN_OVER
		last_headline_id = GameConstants.HEADLINE_RUN_OVER
	else:
		last_newspaper_event = GameEnums.NewspaperEvent.CHAPTER_RESULT
		last_headline_id = GameConstants.HEADLINE_CHAPTER_RESULT
	mission["run_over"] = run_over
	mission["run_over_reason"] = run_over_reason
	last_resolve = ScheduleRules.build_boss_result(board, mission, run_over, boss_job_id, boss_client_id)
	last_stamp = _make_boss_stamp(mission)
	last_note = (
		"Boss %s · %s vs %s · rating %s · cleared %s · run_over %s."
		% [
			AdventurerCatalog.display_name(boss_client_id),
			BossClientCatalog.display_name(boss_job_id),
			ScheduleCatalog.boss_title(board.chapter_boss_id) if board != null else "",
			GameEnums.rating_wire(mission.get("rating", GameEnums.Rating.NONE)),
			str(cleared),
			str(run_over),
		]
	)
	resolve_open = true
	resolve_started.emit(last_resolve)
	board_changed.emit()


func _apply_reps(result: Dictionary, card_difficulty: int) -> void:
	var applied := RepsRules.apply(reps, result, card_difficulty)
	reps = int(applied.get("reps_after", reps))
	result["reps_before"] = applied["reps_before"]
	result["reps_after"] = applied["reps_after"]
	result["reps_delta"] = applied["reps_delta"]
	result["reps_gate"] = applied["reps_gate"]


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
	## Full docs/20 dump — Test smoke pairs against this, not a subset.
	return last_stamp.to_dict()


func is_outlook_unlocked(outlook_id: String) -> bool:
	return CraftReadout.is_outlook_unlocked(outlook_id, unlocked_outlooks)


func _unlock_outlook(outlook_id: String) -> void:
	var id := outlook_id
	if id.is_empty():
		id = "plain"
	if id in unlocked_outlooks:
		return
	unlocked_outlooks.append(id)


func _apply_run_meta(stamp: HarnessStamp) -> void:
	stamp.reps_before = int(last_mission.get("reps_before", reps)) if last_mission.has("reps_before") else reps
	stamp.reps_after = int(last_mission.get("reps_after", reps)) if last_mission.has("reps_after") else reps
	stamp.reps_delta = int(last_mission.get("reps_delta", 0)) if last_mission.has("reps_delta") else (stamp.reps_after - stamp.reps_before)
	stamp.reps_gate = GameConstants.REPS_GATE_STUB
	stamp.run_over = run_over
	stamp.run_over_reason = run_over_reason
	stamp.newspaper_event = last_newspaper_event
	stamp.newspaper_headline_id = last_headline_id
	stamp.letter_id = last_letter_id


func _base_stamp() -> HarnessStamp:
	var stamp := HarnessStamp.new()
	stamp.run_id = run_id
	if board != null:
		stamp.apply_schedule(board)
	_apply_run_meta(stamp)
	return stamp


func _make_schedule_stamp() -> HarnessStamp:
	return _base_stamp()


func _make_newspaper_stamp() -> HarnessStamp:
	var stamp := _base_stamp()
	stamp.phase = GameEnums.StampPhase.NEWSPAPER
	stamp.round_index = GameConstants.NULL_INT
	stamp.round_action = GameEnums.RoundAction.NONE
	stamp.session = null
	stamp.newspaper_event = GameEnums.NewspaperEvent.BOSS_ANNOUNCE
	stamp.newspaper_headline_id = GameConstants.HEADLINE_BOSS_ANNOUNCE
	return stamp


func _make_craft_stamp(result: Dictionary = {}) -> HarnessStamp:
	var stamp := _base_stamp()
	if craft_order != null and craft_session != null:
		stamp.apply_piece_session(craft_order, craft_session)
	if not result.is_empty():
		stamp.apply_resolver(result)
	return stamp


func _make_mission_return_stamp(mission: Dictionary) -> HarnessStamp:
	var stamp := _base_stamp()
	if craft_order != null:
		stamp.mission_kind = craft_order.mission_kind
		stamp.order_id = craft_order.order_id
		stamp.threat_id = craft_order.threat_id
		stamp.construction_ids = craft_order.construction_ids.duplicate()
		stamp.card_difficulty = craft_order.card_difficulty
		if craft_order.mission_kind == GameEnums.MissionKind.BOSS:
			stamp.boss_client_id = craft_order.boss_client_id
			stamp.boss_job_id = craft_order.boss_job_id
		stamp.apply_adventurer_logs(AdventurerCatalog.order_adventurer_id(craft_order))
	stamp.phase = GameEnums.StampPhase.CRAFT
	stamp.session = null
	stamp.apply_resolver(mission)
	return stamp


func _make_cant_craft_stamp(order: ClientOrder, result: Dictionary) -> HarnessStamp:
	var stamp := _base_stamp()
	if order != null:
		stamp.mission_kind = order.mission_kind
		stamp.order_id = order.order_id
		stamp.threat_id = order.threat_id
		stamp.construction_ids = order.construction_ids.duplicate()
		stamp.card_difficulty = order.card_difficulty
		if order.mission_kind == GameEnums.MissionKind.BOSS:
			stamp.boss_client_id = order.boss_client_id
			stamp.boss_job_id = order.boss_job_id
		stamp.apply_adventurer_logs(AdventurerCatalog.order_adventurer_id(order))
	stamp.phase = GameEnums.StampPhase.CRAFT
	stamp.session = null
	stamp.cant_craft = true
	stamp.apply_resolver(result)
	return stamp


func _make_boss_stamp(result: Dictionary) -> HarnessStamp:
	var stamp := _base_stamp()
	stamp.phase = GameEnums.StampPhase.BOSS
	stamp.mission_kind = GameEnums.MissionKind.BOSS
	stamp.boss_client_id = boss_client_id
	stamp.boss_job_id = boss_job_id
	stamp.apply_adventurer_logs(boss_client_id)
	if craft_order != null:
		stamp.order_id = craft_order.order_id
		stamp.construction_ids = craft_order.construction_ids.duplicate()
		stamp.card_difficulty = craft_order.card_difficulty
	else:
		var job := BossClientCatalog.row(boss_job_id)
		stamp.order_id = String(job.get("order_id", ""))
		stamp.construction_ids = BossClientCatalog.construction_ids(boss_job_id)
		stamp.card_difficulty = 3
	stamp.threat_id = board.chapter_boss_id if board != null else ""
	stamp.construction_id = ""
	stamp.session = null
	stamp.apply_resolver(result)
	stamp.run_over = run_over
	stamp.run_over_reason = run_over_reason
	return stamp


func _make_end_stamp() -> HarnessStamp:
	var stamp := _base_stamp()
	if run_over:
		stamp.phase = GameEnums.StampPhase.NEWSPAPER
		stamp.newspaper_event = GameEnums.NewspaperEvent.RUN_OVER
		stamp.newspaper_headline_id = GameConstants.HEADLINE_RUN_OVER
	else:
		stamp.phase = GameEnums.StampPhase.NEWSPAPER
		stamp.newspaper_event = GameEnums.NewspaperEvent.CHAPTER_RESULT
		stamp.newspaper_headline_id = GameConstants.HEADLINE_CHAPTER_RESULT
	stamp.session = null
	return stamp
