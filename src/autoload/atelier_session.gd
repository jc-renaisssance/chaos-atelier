extends Node
## Live travelling-atelier session. Schedule board only (docs/22). No craft loop.

signal board_changed
signal resolve_started(payload: Dictionary)
signal chapter_finished

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
	board = ChapterSchedule.make_empty(chapter_id)
	var pins := ScheduleRules.roll_pins(chapter_id, rng)
	var boss_id := ScheduleRules.roll_boss(chapter_id, rng)
	var pool_id := String(GameConstants.BOSS_POOL_IDS.get(chapter_id, ""))
	board.begin_live(boss_id, pool_id, pins)
	last_stamp = _make_stamp()
	var errs := board.schema_errors()
	if not errs.is_empty():
		last_note = "schema: " + ", ".join(errs)
	else:
		last_note = "Boss announced at chapter start. Pins are 2–4 elite telegraphs on rounds 1–6."
	board_changed.emit()


func legal_actions() -> Array[GameEnums.RoundAction]:
	return ScheduleRules.legal_actions(board, declined_this_round)


func can_decline() -> bool:
	if board == null or resolve_open or board.appt_decline_used:
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
	if board == null or resolve_open:
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
	last_stamp = _make_stamp()
	last_resolve = ScheduleRules.build_resolve(action, pending_order, last_event)
	resolve_open = true
	if not declined_this_round:
		last_note = "One primary action locked for round %d." % board.round_index
	resolve_started.emit(last_resolve)
	board_changed.emit()
	return true


func acknowledge_resolve() -> void:
	if not resolve_open:
		return
	resolve_open = false
	declined_this_round = false
	## Craft / shop are later slices — do not increment crafts_done here.
	if not board.advance_round():
		last_note = "Schedule complete. Final prep / boss is the next slice (not this PR)."
		chapter_finished.emit()
	else:
		last_note = "Round %d — pick one action." % board.round_index
	last_stamp = _make_stamp()
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
	## Schedule-board fields only — stamina / resolver stay null on this slice.
	return {
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
	}


func _make_stamp() -> HarnessStamp:
	var stamp := HarnessStamp.new()
	stamp.run_id = run_id
	if board != null:
		stamp.apply_schedule(board)
	stamp.reps_before = reps
	stamp.reps_after = reps
	return stamp
