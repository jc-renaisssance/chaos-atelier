extends Node
## Live travelling-atelier session. Route graph (22) + stamina craft (27) + mission (23/24).
## Autoload singleton is already named AtelierSession — do not add class_name.

signal board_changed
signal resolve_started(payload: Dictionary)
signal chapter_finished
signal craft_started
signal craft_changed
signal piece_finished(result: Dictionary)
signal craft_order_finished

## docs/22 + docs/33 — decline −1 once / chapter. Gate is GameConstants.reps_gate_for.
const DECLINE_REPS_STUB := -1

var run_id: String = ""
var chapter_seed: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Event-pool draws only. Seeded from chapter_seed so the pick does not follow market/craft rolls.
var event_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var board: ChapterSchedule
var last_stamp: HarnessStamp
var last_resolve: Dictionary = {}
var pending_order: ClientOrder
var last_event: Dictionary = {}
var resolve_open: bool = false
var declined_this_day: bool = false
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
var piece_stamp_nodes: Array = []
## Gate A (docs/30 slice 4). A step on the existing Finish → report path.
var playback_open: bool = false
var piece_report_open: bool = false
var playback_serial: int = 0
var _playback_queue: Array = []
var _playback_cursor: int = 0
var _playback_rows: Array = []
var chapter_piece_results: Array = []
var last_mission: Dictionary = {}

var newspaper_open: bool = false
var awaiting_boss: bool = false
var boss_open: bool = false
var boss_client_id: String = ""
var boss_job_id: String = ""
## "m1" or "m2" for the boss draw that opened this beat. Assert 23 reads it. Not a dump key.
var boss_draw_pool: String = ""
var chapter_over: bool = false
var run_over: bool = false
var run_over_reason: GameEnums.RunOverReason = GameEnums.RunOverReason.NONE
var last_newspaper_event: GameEnums.NewspaperEvent = GameEnums.NewspaperEvent.NONE
var last_headline_id: String = ""
var last_letter_id: String = ""
## Fashion encyclopedia is Later (docs/04). Phase-1 unlock set for Potential readout (docs/27).
## Run-local Potential ids (syn_metal_5 etc.). Dex Builds is unlocked_builds on profile (docs/30).
var unlocked_outlooks: PackedStringArray = PackedStringArray(["plain"])

## Profile / meta save (docs/30, 31). Cross-run LOCKED. Not run state. Never cleared here.
var profile: ProfileMeta = ProfileMeta.new()
var dex_order_adventurer_id: String = ""
var last_unlocks_new: Array = []
var last_dex_crafts_new: Array = []
var last_dex_adventurer_new_met: Array = []
var last_dex_enemy_seen_new: Array = []
var last_dex_enemy_fought_new: Array = []
## Slice 2 intent (docs/30). Estimate-only. Null until the player clicks a planner chip.
var planned_build: Variant = null

## docs/32 — one gold purse + market visit + text events. Display Market; wire shop.
var gold: int = GameConstants.GOLD_START
var market_open: bool = false
var event_open: bool = false
var market_node_id: String = ""
var market_bank_id: String = ""
var market_stock: Array = []
var market_buys: Array = []
var market_sells: Array = []
var market_refresh_count: int = 0
var market_refreshes: Array = []
var market_enchants: Array = []
var market_tab: String = GameConstants.MARKET_TAB_MATERIALS
var market_staff_stock: Array = []
var market_staff_buys: Array = []
var market_staff_sells: Array = []
var staff_owned: Array = []
var staff_equipped_id: String = ""
var market_skill_stock: Array = []
var market_skill_buys: Array = []
var market_skill_sells: Array = []
var market_artifact_stock: Array = []
var market_artifact_buys: Array = []
var market_artifact_sells: Array = []
var artifact_owned: Array = []
var artifact_equipped_ids: Array = []
var visit_gold_before: int = 0
var visit_gold_after: int = 0
var event_id: String = ""
## evt_* already resolved this chapter. Draw excludes these. Cleared on chapter start.
var chapter_events_resolved: Array = []
var event_choice_id: String = ""
var event_deltas: Dictionary = {}
var event_resolved: bool = false
var event_result_line: String = ""
var event_mat_skipped: bool = false
var visit_reps_before: int = 0

## docs/35. Default false. Dex, Reroll, Demo next chapter, and the stamp dump
## are created on the board only when this is true. Never on the title screen.
var dev_tools: bool = false

const RUN_SAVE_PATH := "user://atelier_run.json"


func _ready() -> void:
	profile.load_from_disk()
	board_changed.connect(_save_run_if_idle)


func new_run() -> void:
	_delete_run_save()
	start_chapter(1)


func can_continue() -> bool:
	return FileAccess.file_exists(RUN_SAVE_PATH)


func continue_run() -> bool:
	if not can_continue():
		return false
	return _load_run_save()


func start_chapter(chapter_id: int = 1, seed: int = 0) -> void:
	if chapter_id < 1 or chapter_id > GameConstants.CHAPTERS_PER_RUN:
		chapter_id = 1
	chapter_seed = seed if seed != 0 else randi()
	rng = RandomNumberGenerator.new()
	rng.seed = chapter_seed
	event_rng = RandomNumberGenerator.new()
	event_rng.seed = chapter_seed
	chapter_events_resolved = []
	run_id = "run_%d_%d" % [chapter_seed, int(Time.get_unix_time_from_system())]
	reps = GameConstants.REPS_START
	last_note = ""
	last_resolve = {}
	last_event = {}
	last_mission = {}
	pending_order = null
	resolve_open = false
	declined_this_day = false
	newspaper_open = false
	awaiting_boss = false
	boss_open = false
	boss_client_id = ""
	boss_job_id = ""
	boss_draw_pool = ""
	chapter_over = false
	run_over = false
	run_over_reason = GameEnums.RunOverReason.NONE
	last_newspaper_event = GameEnums.NewspaperEvent.NONE
	last_headline_id = ""
	last_letter_id = ""
	unlocked_outlooks = PackedStringArray(["plain"])
	chapter_piece_results.clear()
	_reset_craft_state()
	gold = GameConstants.GOLD_START
	_clear_run_kit()
	_clear_market_visit()
	_clear_event_visit()
	market_open = false
	event_open = false
	## Dex / unlocked_builds stay on profile — do not clear on new run / death / run_over.
	profile.note_new_run()
	stock = WagonStock.new()
	stock.fill_starter()
	board = ChapterSchedule.make_empty(chapter_id)
	var boss_id := ScheduleRules.roll_boss(chapter_id, rng)
	var pool_id := String(GameConstants.BOSS_POOL_IDS.get(chapter_id, ""))
	board.begin_live(boss_id, pool_id)
	board.enter_current_day()
	newspaper_open = true
	resolve_open = true
	last_newspaper_event = GameEnums.NewspaperEvent.BOSS_ANNOUNCE
	last_headline_id = GameConstants.HEADLINE_BOSS_ANNOUNCE
	last_resolve = ScheduleRules.build_boss_announce(board)
	var seen := profile.note_enemy_seen(boss_id)
	last_dex_enemy_seen_new = Array(seen.get("dex_enemy_seen_new", []))
	last_stamp = _make_newspaper_stamp()
	var errs := board.schema_errors()
	if not errs.is_empty():
		last_note = "schema: " + ", ".join(errs)
	else:
		last_note = "Kingdom newspaper — boss announced before spend. Route graph next: D1 is N1; draft future; confirm when current."
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
	piece_stamp_nodes.clear()
	playback_open = false
	piece_report_open = false
	_playback_queue.clear()
	_playback_cursor = 0
	_playback_rows.clear()
	dex_order_adventurer_id = ""
	planned_build = null


func legal_actions() -> Array[GameEnums.RoundAction]:
	if craft_open or newspaper_open or awaiting_boss or boss_open or chapter_over or run_over:
		return []
	if market_open or event_open:
		return []
	return ScheduleRules.legal_actions(board, declined_this_day)


func can_confirm_node(node_id: String) -> bool:
	if board == null or craft_open or newspaper_open or boss_open or chapter_over or run_over:
		return false
	if market_open or event_open:
		return false
	if resolve_open:
		return false
	return board.can_confirm_node(node_id)


func confirm_node(node_id: String) -> bool:
	if board == null or craft_open or newspaper_open or boss_open or chapter_over or run_over:
		return false
	if market_open or event_open:
		return false
	if resolve_open:
		return false
	if not board.confirm_node(node_id):
		last_note = board.confirm_reason(node_id)
		board_changed.emit()
		return false
	last_stamp = _make_schedule_stamp()
	last_note = "Confirmed %s on D%d." % [node_id, board.day_index]
	board_changed.emit()
	return true


func can_draft_node(node_id: String) -> bool:
	if board == null or craft_open or newspaper_open or boss_open or chapter_over or run_over:
		return false
	if market_open or event_open:
		return false
	return board.can_draft_node(node_id)


func draft_node(node_id: String) -> bool:
	if not can_draft_node(node_id):
		return false
	if not board.draft_node(node_id):
		return false
	last_stamp = _make_schedule_stamp()
	last_note = "Draft ghost %s (not confirmed)." % node_id
	board_changed.emit()
	return true


func take_day() -> bool:
	var legal := legal_actions()
	if legal.is_empty():
		return false
	return pick_action(legal[0])


func can_decline() -> bool:
	if board == null or resolve_open or craft_open or board.appt_decline_used:
		return false
	if market_open or event_open:
		return false
	if newspaper_open or awaiting_boss or boss_open or chapter_over or run_over:
		return false
	return board.current_pin() != null and not board.is_current_resolved()


func decline_appointment() -> bool:
	if not can_decline():
		return false
	board.appt_decline_used = true
	declined_this_day = true
	reps = maxi(0, reps + DECLINE_REPS_STUB)
	last_note = "Appointment declined (Phase-1: once / chapter, −reps stub %d). Pick one other action." % DECLINE_REPS_STUB
	board_changed.emit()
	return true


func pick_action(action: GameEnums.RoundAction) -> bool:
	if board == null or resolve_open or craft_open:
		return false
	if market_open or event_open:
		return false
	if newspaper_open or awaiting_boss or boss_open or chapter_over or run_over:
		return false
	if not ScheduleRules.is_legal(board, action, declined_this_day):
		return false
	var pin := board.current_pin()
	var node := board.node_for_day(board.day_index)
	if pin != null and action != GameEnums.RoundAction.APPOINTMENT and not declined_this_day:
		board.appt_decline_used = true
		declined_this_day = true
		reps = maxi(0, reps + DECLINE_REPS_STUB)
		last_note = "Pinned appointment skipped — decline used (−reps stub %d)." % DECLINE_REPS_STUB
	var order_id := ""
	var event_wire := ""
	## kind=event draws on enter. ref_id stays on the graph as a sample, not this wire.
	if node != null and node.kind != "event":
		event_wire = node.node_id
	pending_order = null
	last_event = {}
	match action:
		GameEnums.RoundAction.APPOINTMENT:
			if pin == null:
				return false
			pending_order = ScheduleCatalog.order_for_appointment(pin)
			order_id = pin.order_id
		GameEnums.RoundAction.WALK_IN:
			if node != null and node.kind == "adventurer" and not node.ref_id.is_empty():
				pending_order = ScheduleCatalog.order_for_adventurer(node.ref_id, board.chapter_id, board.day_index)
			else:
				pending_order = ScheduleCatalog.make_walk_in(board.chapter_id, board.day_index, rng)
			order_id = pending_order.order_id
		GameEnums.RoundAction.PREP_CRAFT:
			pending_order = ScheduleCatalog.make_prep(board.day_index)
			order_id = pending_order.order_id
		GameEnums.RoundAction.WAGON_EVENT:
			if node == null or node.kind != "event":
				last_event = ScheduleCatalog.pick_wagon_event(rng)
		GameEnums.RoundAction.WAGON_SHOP:
			if node != null and node.kind == "shop":
				last_event = {
					"id": node.node_id,
					"title": "market · %s" % node.node_id,
					"blurb": "Market visit %s. Materials / Staffs / Skills / Gear. Refresh stays materials-only." % node.node_id,
				}
		_:
			pass
	if not board.set_primary_action(action, order_id, event_wire):
		return false
	if action == GameEnums.RoundAction.WAGON_SHOP and node != null and node.kind == "shop":
		return _begin_market(node)
	if action == GameEnums.RoundAction.WAGON_EVENT and node != null and node.kind == "event":
		return _begin_event(node)
	last_resolve = ScheduleRules.build_resolve(action, pending_order, last_event)
	if ScheduleRules.is_order_class(action):
		if not _begin_craft(pending_order):
			resolve_open = true
			resolve_started.emit(last_resolve)
			board_changed.emit()
		return true
	last_stamp = _make_schedule_stamp()
	resolve_open = true
	if not declined_this_day:
		last_note = "One primary action locked for D%d." % board.day_index
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
	## Piece cap is GONE (docs/22, 20). Stamina still gates a session. Other cant_craft causes may remain.
	craft_order = order
	pending_order = order
	piece_results.clear()
	piece_stamps.clear()
	last_piece_result = {}
	order_craft_done = false
	next_mat_free = false
	craft_open = true
	resolve_open = false
	planned_build = null
	_note_order_panel(order)
	_note_order_brief(order)
	_open_session()
	craft_started.emit()
	board_changed.emit()
	return true


func _open_session() -> void:
	next_mat_free = false
	craft_session = craft_order.open_session()
	_apply_session_kit(craft_session)
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
	piece_stamp_nodes.clear()
	playback_open = false
	piece_report_open = false
	_playback_queue.clear()
	_playback_cursor = 0
	_playback_rows.clear()
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
		_write_finish_profile(result, i == n)
		var stamp := _make_craft_stamp(result)
		piece_stamp_nodes.append(stamp)
		piece_stamps.append(stamp.to_dict())
		last_stamp = stamp
		piece_finished.emit(result)
	if craft_session.is_legal_zone(keep_zone):
		craft_session.focus_zone(keep_zone)
	order_craft_done = true
	last_note = (
		"Session finished (player_finish). %d piece(s) stamped in listed order. crafts_done=%d (unbounded)."
		% [piece_results.size(), board.crafts_done]
	)
	## Resolver already returned for each piece. Playback does not call it again.
	_begin_playback_gate()
	craft_changed.emit()
	board_changed.emit()


## Adventurer order, appointment, and boss beat. Not prep, cant_craft, market, or event.
## Empty zones still play — grade_piece already ran on the construction-only stamp.
func _gate_a_plays() -> bool:
	if craft_order == null or craft_session == null:
		return false
	if craft_session.finish_reason != GameEnums.FinishReason.PLAYER_FINISH:
		return false
	if piece_results.is_empty() or piece_stamp_nodes.size() != piece_results.size():
		return false
	if craft_order.mission_kind == GameEnums.MissionKind.BOSS:
		return true
	if craft_order.mission_kind != GameEnums.MissionKind.ORDER:
		return false
	if board == null:
		return false
	var action := board.current_day_action()
	return action == GameEnums.RoundAction.WALK_IN or action == GameEnums.RoundAction.APPOINTMENT


func _begin_playback_gate() -> void:
	playback_open = false
	piece_report_open = false
	_playback_queue.clear()
	_playback_cursor = 0
	_playback_rows.clear()
	if not _gate_a_plays():
		return
	playback_serial += 1
	var actor: Variant = _playback_actor_id()
	for i in range(piece_stamp_nodes.size()):
		var stamp: HarnessStamp = piece_stamp_nodes[i]
		var result: Dictionary = piece_results[i]
		var piece_index := int(result.get("piece_index", i + 1))
		var rows: Array = _rows_for_piece(result, piece_index, actor)
		_playback_rows.append(rows)
		stamp.playback_beats = PlaybackBeats.beat_ids(rows)
		stamp.playback_actor_id = actor
		stamp.playback_played = false
		stamp.playback_skipped = false
		_playback_queue.append(i)
		## Patch the snapshot taken while this piece was focused. Do not re-dump:
		## the live session focus is restored after the loop.
		_patch_playback_dump(i)
	if _playback_queue.is_empty():
		return
	_show_playback_cursor()


func _show_playback_cursor() -> void:
	if _playback_cursor < 0 or _playback_cursor >= _playback_queue.size():
		playback_open = false
		return
	var index: int = int(_playback_queue[_playback_cursor])
	var stamp: HarnessStamp = piece_stamp_nodes[index]
	stamp.playback_played = true
	stamp.playback_skipped = false
	_sync_piece_stamp(index)
	playback_open = true
	piece_report_open = false
	last_note = (
		"Playback · piece %d / %d. Skip ends this playback only."
		% [_piece_index_at(index), piece_results.size()]
	)


func finish_playback(skipped: bool) -> void:
	## Skip and the natural end both open this piece's report. Neither skips it.
	if not playback_open:
		return
	if _playback_cursor < 0 or _playback_cursor >= _playback_queue.size():
		playback_open = false
		return
	var index: int = int(_playback_queue[_playback_cursor])
	var stamp: HarnessStamp = piece_stamp_nodes[index]
	stamp.playback_played = true
	stamp.playback_skipped = skipped
	_sync_piece_stamp(index)
	playback_open = false
	piece_report_open = true
	last_note = "Piece %d report (docs/23)." % _piece_index_at(index)
	board_changed.emit()


func continue_piece_report() -> void:
	## Closing this piece's report starts the next piece. The last one opens the existing report.
	if not piece_report_open:
		return
	piece_report_open = false
	_playback_cursor += 1
	if _playback_cursor < _playback_queue.size():
		_show_playback_cursor()
		board_changed.emit()
		return
	playback_open = false
	_return_to_schedule()


func playback_snapshot() -> Dictionary:
	var index := -1
	if _playback_cursor >= 0 and _playback_cursor < _playback_queue.size():
		index = int(_playback_queue[_playback_cursor])
	var rows: Array = []
	if index >= 0 and index < _playback_rows.size():
		var got: Variant = _playback_rows[index]
		if got is Array:
			rows.assign(got)
	var piece_index := _piece_index_at(index)
	var actor: Variant = null
	if index >= 0 and index < piece_stamp_nodes.size():
		var stamp: HarnessStamp = piece_stamp_nodes[index]
		actor = stamp.playback_actor_id
	var title := ""
	var body := ""
	var note := ""
	if piece_report_open and index >= 0 and index < piece_results.size():
		var result: Dictionary = piece_results[index]
		var card := ScheduleRules.build_piece_report(craft_order, result, piece_index)
		title = String(card.get("title", ""))
		body = String(card.get("body", ""))
	if _playback_cursor + 1 < _playback_queue.size():
		note = "Piece report. Continue starts the next piece's playback."
	else:
		note = "Piece report. Continue opens the one fight."
	return {
		"report": piece_report_open,
		"beats": rows,
		"piece_index": piece_index,
		"piece_count": piece_results.size(),
		"title": title,
		"body": body,
		"note": note,
		"actor_id": actor,
		"serial": playback_serial,
	}


func _piece_index_at(index: int) -> int:
	if index >= 0 and index < piece_results.size():
		return int(piece_results[index].get("piece_index", index + 1))
	return index + 1


func _sync_piece_stamp(index: int) -> void:
	if index < 0 or index >= piece_stamp_nodes.size():
		return
	## Preview reads the live session. Focus this piece so piece_index matches its stamp.
	var piece_index := _piece_index_at(index)
	if craft_session != null and craft_session.is_legal_zone(piece_index):
		craft_session.focus_zone(piece_index)
	var stamp: HarnessStamp = piece_stamp_nodes[index]
	_patch_playback_dump(index)
	last_stamp = stamp


func _patch_playback_dump(index: int) -> void:
	if index < 0 or index >= piece_stamp_nodes.size() or index >= piece_stamps.size():
		return
	var raw: Variant = piece_stamps[index]
	if not (raw is Dictionary):
		return
	var stamp: HarnessStamp = piece_stamp_nodes[index]
	var dump: Dictionary = raw
	dump["playback_played"] = stamp.playback_played
	dump["playback_skipped"] = stamp.playback_skipped
	dump["playback_beats"] = stamp.playback_beats.duplicate()
	dump["playback_actor_id"] = stamp.playback_actor_id


func _playback_actor_id() -> Variant:
	var raw := ""
	if craft_order != null:
		raw = AdventurerCatalog.order_adventurer_id(craft_order)
	return PlaybackBeats.actor_id_for(raw)


func _appt_label() -> String:
	if board == null:
		return ""
	if board.current_day_action() != GameEnums.RoundAction.APPOINTMENT:
		return ""
	var pin := board.current_pin()
	if pin == null:
		return ""
	return pin.appointment_id


func _playback_threat_id() -> String:
	## Boss beat labels chapter_boss_id. Other orders use the stamp threat.
	if craft_order != null and craft_order.mission_kind == GameEnums.MissionKind.BOSS:
		if board != null and not board.chapter_boss_id.is_empty():
			return board.chapter_boss_id
	if craft_order != null:
		return craft_order.threat_id
	return ""


func _rows_for_piece(result: Dictionary, piece_index: int, actor: Variant) -> Array:
	var person := PlaybackBeats.open_person_label(actor, _appt_label())
	var threat_id := _playback_threat_id()
	var seen := true
	if ThreatCatalog.is_boss(threat_id):
		seen = profile.enemy_seen(threat_id)
	var threat := PlaybackBeats.threat_label(threat_id, seen)
	var skill := ""
	if actor is String:
		skill = AdventurerCatalog.skill_id(String(actor))
	return PlaybackBeats.build(result, person, threat, skill, piece_index)


func continue_after_piece() -> void:
	## Playback and the piece report own the exit until the queue is done.
	if playback_open or piece_report_open:
		return
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
		_apply_stamp_case(mission)
		if not bool(mission.get("cleared", false)):
			last_newspaper_event = GameEnums.NewspaperEvent.MID_FAIL
			last_headline_id = GameConstants.HEADLINE_MID_FAIL
	_apply_mission_payout()
	last_resolve = ScheduleRules.build_mission_return(craft_order, mission, piece_results)
	craft_open = false
	order_craft_done = false
	craft_session = null
	resolve_open = true
	last_stamp = _make_mission_return_stamp(mission)
	planned_build = null
	last_note = (
		"Mission %s · cleared %s · hp %.2f. Continue to the next graph day."
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
	if not resolve_open or craft_open or market_open or event_open:
		return
	if newspaper_open:
		newspaper_open = false
		resolve_open = false
		last_newspaper_event = GameEnums.NewspaperEvent.NONE
		last_headline_id = ""
		last_resolve = {}
		last_note = "Route graph — D1 is N1. Draft a future path; confirm a fork when that day is current."
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
	declined_this_day = false
	pending_order = null
	last_newspaper_event = GameEnums.NewspaperEvent.NONE
	last_headline_id = ""
	if not board.advance_day():
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
				"body": "reps_after < reps_gate (%d). run_over_reason=reps_gate_miss." % _reps_gate(),
				"stub": "newspaper_chrome",
				"phase": "newspaper",
			}
			last_note = "Run over — reps_gate_miss. Gate %d." % _reps_gate()
			last_stamp = _make_end_stamp()
			resolve_started.emit(last_resolve)
		else:
			awaiting_boss = true
			resolve_open = true
			last_resolve = ScheduleRules.build_awaiting_boss(board)
			last_note = "Route graph complete. Boss beat: draw a shared-pool adventurer, then sew that job's constructions."
			last_stamp = _make_schedule_stamp()
			resolve_started.emit(last_resolve)
	else:
		last_resolve = {}
		last_note = "D%d — click the next node on the graph, then take it." % board.day_index
		last_stamp = _make_schedule_stamp()
	board_changed.emit()


func _reps_gate() -> int:
	var chapter_id := 1
	if board != null:
		chapter_id = board.chapter_id
	return GameConstants.reps_gate_for(chapter_id)


func _reps_gate_miss() -> bool:
	## docs/25 — after the last graph day, reps below the chapter gate fails the run.
	return reps < _reps_gate()


func _begin_boss_client_craft() -> void:
	## Boss beat (docs/28 + 29): seeded 4-job named draw, independent of chapter_boss_id.
	## Live Steam-demo content uses M2_JOB_POOL only. The else keeps pick_boss_client for M1 smokes.
	awaiting_boss = false
	var job: Dictionary = {}
	if AdventurerCatalog.live_content_is_m2():
		boss_draw_pool = "m2"
		job = BossClientCatalog.pick_boss_client_m2(chapter_seed)
	else:
		boss_draw_pool = "m1"
		job = BossClientCatalog.pick_boss_client(chapter_seed)
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
	var threat_id := board.chapter_boss_id if board != null else ""
	var fought := profile.note_enemy_fought(threat_id)
	last_dex_enemy_seen_new = Array(fought.get("dex_enemy_seen_new", []))
	last_dex_enemy_fought_new = Array(fought.get("dex_enemy_fought_new", []))
	_apply_mission_payout()
	last_stamp = _make_boss_stamp(mission)
	planned_build = null
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
	var chapter_id := 1
	if board != null:
		chapter_id = board.chapter_id
	var applied := RepsRules.apply(reps, result, card_difficulty, chapter_id)
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


func note_shop_brief(threat_id: String) -> void:
	## Guild-quest poster show (docs/31). Writes seen + briefs_seen++, not fought.
	var out := profile.note_enemy_brief(threat_id)
	last_dex_enemy_seen_new = Array(out.get("dex_enemy_seen_new", []))
	last_dex_enemy_fought_new = []


func brief_threat_id(order: ClientOrder = null) -> String:
	## Shop / walk-in / appointment: catalog target on the order.
	## Boss beat: announced chapter_boss_id, not the person's shop default.
	var live: ClientOrder = order if order != null else craft_order
	if live == null:
		return ""
	if live.mission_kind == GameEnums.MissionKind.BOSS:
		if board != null and not board.chapter_boss_id.is_empty():
			return board.chapter_boss_id
	return live.threat_id


func click_planner_tag(tag: String) -> void:
	## Slice 2 chip cycle. Does not change construction_ids or stamina craft.
	if not craft_open or craft_order == null:
		return
	planned_build = PlannerCatalog.after_click(planned_build, tag)
	if craft_session != null:
		last_stamp = _make_craft_stamp()
	craft_changed.emit()


func _note_order_brief(order: ClientOrder) -> void:
	## Showing the slice 3 poster writes seen, then the UI can show the name.
	if order == null:
		return
	var threat_id := brief_threat_id(order)
	if threat_id.is_empty() or not ThreatCatalog.is_boss(threat_id):
		return
	note_shop_brief(threat_id)


func _note_order_panel(order: ClientOrder) -> void:
	## Named adventurer order panel open (docs/31). Job-stub aliases resolve first.
	## Never stores appt_*. Decline / abandon / never-opened panel does not call this.
	dex_order_adventurer_id = ""
	if order == null:
		return
	var raw := AdventurerCatalog.order_adventurer_id(order)
	var out := profile.note_adventurer_order(raw)
	last_dex_adventurer_new_met = Array(out.get("dex_adventurer_new_met", []))
	dex_order_adventurer_id = AdventurerCatalog.resolve_id(raw)
	if not AdventurerCatalog.is_named(dex_order_adventurer_id):
		dex_order_adventurer_id = ""


func _write_finish_profile(result: Dictionary, last_piece: bool) -> void:
	## Finish-only (player_finish). Abandon / stamina 0 without Finish never reaches here.
	## Order win/lose/death does not matter. One completed bump per order, not per piece.
	var reason := GameEnums.FinishReason.NONE
	if craft_session != null:
		reason = craft_session.finish_reason
	var powers := PackedStringArray(result.get("powers_positive", PackedStringArray()))
	var con_id := String(result.get("construction_id", ""))
	if con_id.is_empty() and craft_session != null:
		con_id = craft_session.construction_id
	var write := profile.apply_finish(con_id, powers, run_id, reason)
	last_unlocks_new = Array(write.get("unlocks_new", []))
	last_dex_crafts_new = Array(write.get("dex_crafts_new", []))
	if last_piece and not dex_order_adventurer_id.is_empty():
		profile.complete_adventurer_order(dex_order_adventurer_id)


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
	stamp.reps_gate = _reps_gate()
	stamp.run_over = run_over
	stamp.run_over_reason = run_over_reason
	stamp.newspaper_event = last_newspaper_event
	stamp.newspaper_headline_id = last_headline_id
	stamp.letter_id = last_letter_id


func _apply_profile_logs(stamp: HarnessStamp) -> void:
	## Log-only Dex / unlock keys (docs/30, 31). Not 20 Required run-identity fields.
	var snap := profile.to_dict()
	stamp.unlocked_builds = Array(snap.get("unlocked_builds", []))
	stamp.dex_crafts = Array(snap.get("dex_crafts", []))
	stamp.dex_adventurers = Array(snap.get("dex_adventurers", []))
	stamp.dex_enemies = Array(snap.get("dex_enemies", []))
	stamp.profile_day = int(snap.get("profile_day", 0))
	stamp.unlocks_new = last_unlocks_new.duplicate(true)
	stamp.dex_crafts_new = last_dex_crafts_new.duplicate(true)
	stamp.dex_adventurer_new_met = last_dex_adventurer_new_met.duplicate(true)
	stamp.dex_enemy_seen_new = last_dex_enemy_seen_new.duplicate(true)
	stamp.dex_enemy_fought_new = last_dex_enemy_fought_new.duplicate(true)
	stamp.planned_build = PlannerCatalog.dup_plan(planned_build)
	_apply_estimate_logs(stamp)
	last_unlocks_new = []
	last_dex_crafts_new = []
	last_dex_adventurer_new_met = []
	last_dex_enemy_seen_new = []
	last_dex_enemy_fought_new = []


func _apply_estimate_logs(stamp: HarnessStamp) -> void:
	## Log-only slice 3 keys (docs/30). Gated values dump as "?" when Dex says so.
	var threat_id := brief_threat_id()
	var adv_id := ""
	var construction_ids: PackedStringArray = PackedStringArray()
	if craft_order != null:
		adv_id = AdventurerCatalog.order_adventurer_id(craft_order)
		construction_ids = craft_order.construction_ids.duplicate()
	elif stamp.mission_kind == GameEnums.MissionKind.BOSS:
		adv_id = boss_client_id
		construction_ids = stamp.construction_ids.duplicate()
		if threat_id.is_empty():
			threat_id = stamp.threat_id
	var stats := AdventurerCatalog.stats_dict(adv_id)
	var skill_id := AdventurerCatalog.skill_id(adv_id)
	var raw := EstimateLaw.compute(stats, skill_id, planned_build, construction_ids, threat_id)
	var plan: Variant = PlannerCatalog.dup_plan(planned_build)
	var build_unlocked := false
	if plan is Dictionary:
		var row: Dictionary = plan
		build_unlocked = profile.has_build(String(row.get("outlook_id", "")), String(row.get("tier", "")))
	var fought := profile.enemy_fought(threat_id)
	var gated := EstimateLaw.gated_dump(raw, planned_build, build_unlocked, fought)
	stamp.estimate_band = gated.get("estimate_band", EstimateLaw.LOCKED)
	stamp.estimate_favor_hits = gated.get("estimate_favor_hits", EstimateLaw.LOCKED)
	stamp.estimate_punish_hits = gated.get("estimate_punish_hits", EstimateLaw.LOCKED)
	stamp.estimate_skill_fired = gated.get("estimate_skill_fired", EstimateLaw.LOCKED)
	stamp.estimate_neg_warnings = gated.get("estimate_neg_warnings", EstimateLaw.LOCKED)


func _base_stamp() -> HarnessStamp:
	var stamp := HarnessStamp.new()
	stamp.run_id = run_id
	if board != null:
		stamp.apply_schedule(board)
	_apply_run_meta(stamp)
	_apply_profile_logs(stamp)
	_apply_market_event_logs(stamp)
	return stamp


func _make_schedule_stamp() -> HarnessStamp:
	return _base_stamp()


func _make_newspaper_stamp() -> HarnessStamp:
	var stamp := _base_stamp()
	stamp.phase = GameEnums.StampPhase.NEWSPAPER
	stamp.day_index = GameConstants.NULL_INT
	stamp.day_action = GameEnums.RoundAction.NONE
	stamp.session = null
	stamp.newspaper_event = GameEnums.NewspaperEvent.BOSS_ANNOUNCE
	stamp.newspaper_headline_id = GameConstants.HEADLINE_BOSS_ANNOUNCE
	return stamp


func _apply_boss_draw_pool(stamp: HarnessStamp) -> void:
	if stamp == null:
		return
	if stamp.mission_kind != GameEnums.MissionKind.BOSS:
		stamp.adventurer_pool_id = ""
		return
	if not boss_draw_pool.is_empty():
		stamp.adventurer_pool_id = boss_draw_pool
		return
	stamp.adventurer_pool_id = AdventurerCatalog.pool_id_for_job(stamp.boss_job_id)


func _make_craft_stamp(result: Dictionary = {}) -> HarnessStamp:
	var stamp := _base_stamp()
	if craft_order != null and craft_session != null:
		stamp.apply_piece_session(craft_order, craft_session)
	if not result.is_empty():
		stamp.apply_resolver(result)
	_apply_boss_draw_pool(stamp)
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
	stamp.mission_purse = true
	_apply_boss_draw_pool(stamp)
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
	_apply_boss_draw_pool(stamp)
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
	stamp.mission_purse = true
	_apply_boss_draw_pool(stamp)
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


func _clear_run_kit() -> void:
	staff_owned.clear()
	staff_equipped_id = ""
	artifact_owned.clear()
	artifact_equipped_ids.clear()


func _clear_market_visit() -> void:
	market_node_id = ""
	market_bank_id = ""
	market_stock.clear()
	market_buys.clear()
	market_sells.clear()
	market_refresh_count = 0
	market_refreshes.clear()
	market_enchants.clear()
	market_tab = GameConstants.MARKET_TAB_MATERIALS
	market_staff_stock.clear()
	market_staff_buys.clear()
	market_staff_sells.clear()
	market_skill_stock.clear()
	market_skill_buys.clear()
	market_skill_sells.clear()
	market_artifact_stock.clear()
	market_artifact_buys.clear()
	market_artifact_sells.clear()
	visit_gold_before = gold
	visit_gold_after = gold


func _clear_event_visit() -> void:
	event_id = ""
	event_choice_id = ""
	event_deltas = {}
	event_resolved = false
	event_result_line = ""
	event_mat_skipped = false
	visit_reps_before = reps
	visit_gold_before = gold
	visit_gold_after = gold


func _touch_visit_gold() -> void:
	visit_gold_after = gold
	last_stamp = _make_schedule_stamp()
	board_changed.emit()


func _set_gold(value: int) -> void:
	gold = maxi(GameConstants.GOLD_FLOOR, value)


func _begin_market(node: RouteNode) -> bool:
	if node == null:
		return false
	_clear_market_visit()
	market_open = true
	resolve_open = false
	market_node_id = node.node_id
	market_bank_id = MarketCatalog.bank_id()
	market_stock = MarketCatalog.draw_shelf(rng, node.node_id, true)
	market_tab = GameConstants.MARKET_TAB_MATERIALS
	market_staff_stock = MarketCatalog.staff_stock()
	market_skill_stock = MarketCatalog.skill_stock()
	market_artifact_stock = MarketCatalog.artifact_stock()
	visit_gold_before = gold
	if artifact_is_equipped("artifact_ledger_clip"):
		_set_gold(gold + 1)
		last_note = "Market %s — Ledger Clip +1 gold. Tabs: Materials / Staffs / Skills / Gear." % node.node_id
	else:
		last_note = "Market %s — Materials / Staffs / Skills / Gear. Refresh stays materials-only." % node.node_id
	visit_gold_after = gold
	last_stamp = _make_schedule_stamp()
	board_changed.emit()
	return true


func _begin_event(node: RouteNode) -> bool:
	if node == null or board == null:
		return false
	_clear_event_visit()
	event_open = true
	resolve_open = false
	## Draw on enter. Not a draft. ref_id is only the exhausted-pool fallback.
	event_id = EventCatalog.draw(
		node.day_index,
		board.day_count,
		chapter_events_resolved,
		event_rng,
		node.ref_id
	)
	var slot := board.current_day()
	if slot != null:
		slot.event_id = event_id
	last_event = {
		"id": event_id,
		"title": "event · %s" % node.node_id,
		"blurb": EventCatalog.blurb(event_id),
	}
	visit_gold_before = gold
	visit_gold_after = gold
	visit_reps_before = reps
	last_note = "Event %s — pick one choice." % event_id
	last_stamp = _make_schedule_stamp()
	board_changed.emit()
	return true


func can_buy_market(mat_id: String) -> bool:
	if not market_open or mat_id.is_empty():
		return false
	for item in market_stock:
		if not (item is Dictionary):
			continue
		var row: Dictionary = item
		if String(row.get("mat_id", "")) != mat_id:
			continue
		var price := int(row.get("price", 0))
		var qty := int(row.get("qty_offered", 0))
		return qty > 0 and gold >= price
	return false


func buy_market(mat_id: String) -> bool:
	if not can_buy_market(mat_id):
		last_note = "Cannot buy %s." % mat_id
		board_changed.emit()
		return false
	for item in market_stock:
		if not (item is Dictionary):
			continue
		var row: Dictionary = item
		if String(row.get("mat_id", "")) != mat_id:
			continue
		var price := int(row.get("price", 0))
		row["qty_offered"] = int(row.get("qty_offered", 0)) - 1
		_set_gold(gold - price)
		stock.add_material(mat_id)
		market_buys.append({"mat_id": mat_id, "price": price})
		last_note = "Bought %s for %d gold." % [mat_id, price]
		_touch_visit_gold()
		return true
	return false


func can_sell_market(stock_index: int) -> bool:
	if not market_open or stock == null:
		return false
	if stock_index < 0 or stock_index >= stock.cards.size():
		return false
	var card: HandCard = stock.cards[stock_index]
	if card == null or card.type != GameEnums.HandCardType.MATERIAL:
		return false
	return stock.can_remove_material()


func sell_market(stock_index: int) -> bool:
	if not can_sell_market(stock_index):
		last_note = "Cannot sell — material floor is %d." % GameConstants.MARKET_MATERIAL_FLOOR
		board_changed.emit()
		return false
	var card := stock.remove_at(stock_index)
	if card == null:
		return false
	var gain := material_sell_gain(card.id)
	_set_gold(gold + gain)
	market_sells.append({"mat_id": card.id, "gold_gained": gain})
	last_note = "Sold %s for %d gold." % [card.id, gain]
	_touch_visit_gold()
	return true


func can_refresh_market() -> bool:
	if not market_open:
		return false
	return gold >= MarketCatalog.refresh_cost(market_refresh_count)


func refresh_market() -> bool:
	if not can_refresh_market():
		last_note = "Cannot refresh — short gold."
		board_changed.emit()
		return false
	var cost := MarketCatalog.refresh_cost(market_refresh_count)
	_set_gold(gold - cost)
	market_refresh_count += 1
	market_refreshes.append({"n": market_refresh_count, "cost": cost})
	market_stock = MarketCatalog.draw_shelf(rng, market_node_id, false)
	last_note = "Refresh %d paid %d gold." % [market_refresh_count, cost]
	_touch_visit_gold()
	return true


func can_enchant_market(stock_index: int, enchant_id: String) -> bool:
	if not market_open or stock == null or not MarketCatalog.is_enchant(enchant_id):
		return false
	if stock_index < 0 or stock_index >= stock.cards.size():
		return false
	var card: HandCard = stock.cards[stock_index]
	if card == null or card.type != GameEnums.HandCardType.MATERIAL:
		return false
	if card.is_enchanted():
		return false
	return gold >= MarketCatalog.enchant_fee(enchant_id)


func enchant_market(stock_index: int, enchant_id: String) -> bool:
	if not can_enchant_market(stock_index, enchant_id):
		last_note = "Cannot enchant — already stamped, short gold, or not a material."
		board_changed.emit()
		return false
	var card: HandCard = stock.cards[stock_index]
	var fee := MarketCatalog.enchant_fee(enchant_id)
	_set_gold(gold - fee)
	card.mat_enchant_id = enchant_id
	card.shiny = true
	market_enchants.append({
		"mat_id": card.id,
		"mat_enchant_id": enchant_id,
		"fee": fee,
	})
	last_note = "Enchanted %s with %s for %d gold." % [card.id, enchant_id, fee]
	_touch_visit_gold()
	return true


func exit_market() -> bool:
	if not market_open:
		return false
	market_open = false
	visit_gold_after = gold
	last_resolve = {
		"resolve_class": "event",
		"day_action": "shop",
		"title": "market · %s" % market_node_id,
		"body": (
			"Market closed. mats buy/sell %d/%d · staff %d/%d · skills %d/%d · gear %d/%d · refreshes %d · enchants %d · gold %d→%d · mats %d · skills %d."
			% [
				market_buys.size(),
				market_sells.size(),
				market_staff_buys.size(),
				market_staff_sells.size(),
				market_skill_buys.size(),
				market_skill_sells.size(),
				market_artifact_buys.size(),
				market_artifact_sells.size(),
				market_refreshes.size(),
				market_enchants.size(),
				visit_gold_before,
				visit_gold_after,
				stock.material_count() if stock != null else 0,
				stock.skill_count() if stock != null else 0,
			]
		),
		"stub": "market",
		"phase": "schedule",
		"event_id": market_node_id,
	}
	resolve_open = true
	last_note = "Left market %s. Continue to the next graph day." % market_node_id
	last_stamp = _make_schedule_stamp()
	resolve_started.emit(last_resolve)
	board_changed.emit()
	return true


func set_market_tab(tab: String) -> bool:
	if not market_open or not MarketCatalog.is_tab(tab):
		return false
	if market_tab == tab:
		return true
	market_tab = tab
	last_note = "Market tab %s." % tab
	last_stamp = _make_schedule_stamp()
	board_changed.emit()
	return true


func live_max_materials() -> int:
	return MarketCatalog.max_materials_for(staff_equipped_id)


func live_max_runes() -> int:
	return MarketCatalog.max_runes_for(staff_equipped_id)


func owns_staff(staff_id: String) -> bool:
	return staff_id in staff_owned


func owns_artifact(artifact_id: String) -> bool:
	return artifact_id in artifact_owned


func artifact_is_equipped(artifact_id: String) -> bool:
	return artifact_id in artifact_equipped_ids


func can_buy_staff(staff_id: String) -> bool:
	if not market_open or not MarketCatalog.is_staff(staff_id) or owns_staff(staff_id):
		return false
	return gold >= MarketCatalog.staff_price(staff_id)


func buy_staff(staff_id: String) -> bool:
	if not can_buy_staff(staff_id):
		last_note = "Cannot buy %s." % staff_id
		board_changed.emit()
		return false
	var price := MarketCatalog.staff_price(staff_id)
	_set_gold(gold - price)
	staff_owned.append(staff_id)
	market_staff_buys.append({"staff_id": staff_id, "price": price})
	last_note = "Bought %s for %d gold. Equip from the Staffs tab." % [staff_id, price]
	_touch_visit_gold()
	return true


func can_sell_staff(staff_id: String) -> bool:
	return market_open and owns_staff(staff_id)


func sell_staff(staff_id: String) -> bool:
	if not can_sell_staff(staff_id):
		last_note = "Cannot sell %s." % staff_id
		board_changed.emit()
		return false
	if staff_equipped_id == staff_id:
		staff_equipped_id = ""
	staff_owned.erase(staff_id)
	var gain := MarketCatalog.kit_sell_gain(MarketCatalog.staff_price(staff_id))
	_set_gold(gold + gain)
	market_staff_sells.append({"staff_id": staff_id, "gold_gained": gain})
	last_note = "Sold %s for %d gold." % [staff_id, gain]
	_touch_visit_gold()
	return true


func can_equip_staff(staff_id: String) -> bool:
	return market_open and owns_staff(staff_id) and staff_equipped_id != staff_id


func equip_staff(staff_id: String) -> bool:
	if not can_equip_staff(staff_id):
		last_note = "Cannot equip %s." % staff_id
		board_changed.emit()
		return false
	staff_equipped_id = staff_id
	last_note = "Equipped %s. max_m %d  max_r %d." % [
		staff_id,
		live_max_materials(),
		live_max_runes(),
	]
	_touch_visit_gold()
	return true


func can_unequip_staff() -> bool:
	return market_open and not staff_equipped_id.is_empty()


func unequip_staff() -> bool:
	if not can_unequip_staff():
		return false
	var was := staff_equipped_id
	staff_equipped_id = ""
	last_note = "Unequipped %s. Caps back to %d / %d." % [
		was,
		live_max_materials(),
		live_max_runes(),
	]
	_touch_visit_gold()
	return true


func can_buy_skill(skill_id: String) -> bool:
	if not market_open or not MarketCatalog.is_skill(skill_id):
		return false
	return gold >= MarketCatalog.skill_price(skill_id)


func buy_skill(skill_id: String) -> bool:
	if not can_buy_skill(skill_id):
		last_note = "Cannot buy %s." % skill_id
		board_changed.emit()
		return false
	var price := MarketCatalog.skill_price(skill_id)
	_set_gold(gold - price)
	stock.add_skill(skill_id)
	market_skill_buys.append({"skill_id": skill_id, "price": price})
	last_note = "Bought %s into the run kit for %d gold." % [skill_id, price]
	_touch_visit_gold()
	return true


func can_sell_skill(stock_index: int) -> bool:
	if not market_open or stock == null:
		return false
	if stock_index < 0 or stock_index >= stock.cards.size():
		return false
	var card: HandCard = stock.cards[stock_index]
	return card != null and card.type == GameEnums.HandCardType.SKILL and MarketCatalog.is_skill(card.id)


func sell_skill(stock_index: int) -> bool:
	if not can_sell_skill(stock_index):
		last_note = "Cannot sell that skill."
		board_changed.emit()
		return false
	var card := stock.remove_at(stock_index)
	if card == null:
		return false
	var gain := MarketCatalog.kit_sell_gain(MarketCatalog.skill_price(card.id))
	_set_gold(gold + gain)
	market_skill_sells.append({"skill_id": card.id, "gold_gained": gain})
	last_note = "Sold %s for %d gold." % [card.id, gain]
	_touch_visit_gold()
	return true


func can_buy_artifact(artifact_id: String) -> bool:
	if not market_open or not MarketCatalog.is_artifact(artifact_id) or owns_artifact(artifact_id):
		return false
	return gold >= MarketCatalog.artifact_price(artifact_id)


func buy_artifact(artifact_id: String) -> bool:
	if not can_buy_artifact(artifact_id):
		last_note = "Cannot buy %s." % artifact_id
		board_changed.emit()
		return false
	var price := MarketCatalog.artifact_price(artifact_id)
	_set_gold(gold - price)
	artifact_owned.append(artifact_id)
	market_artifact_buys.append({"artifact_id": artifact_id, "price": price})
	last_note = "Bought %s for %d gold. Equip from the Gear tab." % [artifact_id, price]
	_touch_visit_gold()
	return true


func can_sell_artifact(artifact_id: String) -> bool:
	return market_open and owns_artifact(artifact_id)


func sell_artifact(artifact_id: String) -> bool:
	if not can_sell_artifact(artifact_id):
		last_note = "Cannot sell %s." % artifact_id
		board_changed.emit()
		return false
	artifact_equipped_ids.erase(artifact_id)
	artifact_owned.erase(artifact_id)
	var gain := MarketCatalog.kit_sell_gain(MarketCatalog.artifact_price(artifact_id))
	_set_gold(gold + gain)
	market_artifact_sells.append({"artifact_id": artifact_id, "gold_gained": gain})
	last_note = "Sold %s for %d gold." % [artifact_id, gain]
	_touch_visit_gold()
	return true


func can_equip_artifact(artifact_id: String) -> bool:
	if not market_open or not owns_artifact(artifact_id) or artifact_is_equipped(artifact_id):
		return false
	return artifact_equipped_ids.size() < GameConstants.ARTIFACT_GEAR_SLOTS


func equip_artifact(artifact_id: String) -> bool:
	if not can_equip_artifact(artifact_id):
		last_note = "Cannot equip %s — own it and keep a free slot (2)." % artifact_id
		board_changed.emit()
		return false
	artifact_equipped_ids.append(artifact_id)
	last_note = "Equipped %s. Gear slots %d/2." % [artifact_id, artifact_equipped_ids.size()]
	_touch_visit_gold()
	return true


func can_unequip_artifact(artifact_id: String) -> bool:
	return market_open and artifact_is_equipped(artifact_id)


func unequip_artifact(artifact_id: String) -> bool:
	if not can_unequip_artifact(artifact_id):
		return false
	artifact_equipped_ids.erase(artifact_id)
	last_note = "Unequipped %s. Gear slots %d/2." % [artifact_id, artifact_equipped_ids.size()]
	_touch_visit_gold()
	return true


func material_sell_gain(mat_id: String) -> int:
	var gain := MarketCatalog.sell_gain(mat_id)
	if artifact_is_equipped("artifact_wagon_hook"):
		gain += 1
	return gain


func _event_gold_delta(raw: int) -> int:
	if raw >= 0:
		return raw
	if not artifact_is_equipped("artifact_road_charm"):
		return raw
	return mini(0, raw + 1)


func _event_gold_cost(ch: Dictionary) -> int:
	var applied := _event_gold_delta(int(ch.get("gold", 0)))
	if applied < 0:
		return -applied
	return 0


func _apply_session_kit(session: CraftStaminaSession) -> void:
	if session == null:
		return
	session.max_materials = live_max_materials()
	session.max_runes = live_max_runes()
	if artifact_is_equipped("artifact_pack_strap"):
		session.hand_size = GameConstants.HAND_SIZE + 1
	if artifact_is_equipped("artifact_needle_tin"):
		session.dig_refresh_cost = maxi(1, GameConstants.DIG_REFRESH_COST - 1)
	if artifact_is_equipped("artifact_oil_rag"):
		session.stamina_start += 2
		session.stamina_remaining = session.stamina_start


func _apply_stamp_case(mission: Dictionary) -> void:
	if not artifact_is_equipped("artifact_stamp_case"):
		return
	var rating: Variant = mission.get("rating", GameEnums.Rating.NONE)
	if rating != GameEnums.Rating.S and rating != GameEnums.Rating.A:
		return
	reps = maxi(0, reps + 1)
	if mission.has("reps_after"):
		mission["reps_after"] = reps
		mission["reps_delta"] = reps - int(mission.get("reps_before", reps))


func _mission_gold_multiplier(rating: Variant) -> int:
	## Clear ladder: S3 / A2 / B2 / C1 / D0 / F0.
	match rating:
		GameEnums.Rating.S:
			return 3
		GameEnums.Rating.A:
			return 2
		GameEnums.Rating.B:
			return 2
		GameEnums.Rating.C:
			return 1
		_:
			return 0


func _mission_gold_base() -> int:
	## Cleared order or boss beat only. Boss difficulty stays 3. Not cleared pays 0.
	if craft_order == null or not bool(last_mission.get("cleared", false)):
		return 0
	var kind: GameEnums.MissionKind = craft_order.mission_kind
	if kind != GameEnums.MissionKind.ORDER and kind != GameEnums.MissionKind.BOSS:
		return 0
	var mult := _mission_gold_multiplier(last_mission.get("rating", GameEnums.Rating.F))
	var diff := 3
	if kind != GameEnums.MissionKind.BOSS:
		diff = craft_order.card_difficulty
		if diff == GameConstants.NULL_INT:
			diff = 0
	return diff * mult


func _apply_mission_payout() -> void:
	var before := gold
	var base := _mission_gold_base()
	if base > 0:
		_set_gold(gold + base)
		if artifact_is_equipped("artifact_coin_purse"):
			_set_gold(gold + 1)
	visit_gold_before = before
	visit_gold_after = gold


func can_pick_event_choice(choice_id: String) -> bool:
	if not event_open or event_resolved:
		return false
	var ch := EventCatalog.choice(event_id, choice_id)
	if ch.is_empty():
		return false
	var cost := _event_gold_cost(ch)
	if cost > 0 and gold < cost:
		return false
	return true


func pick_event_choice(choice_id: String) -> bool:
	if not can_pick_event_choice(choice_id):
		last_note = "Cannot pick %s." % choice_id
		board_changed.emit()
		return false
	var ch := EventCatalog.choice(event_id, choice_id)
	var gold_delta := _event_gold_delta(int(ch.get("gold", 0)))
	var reps_delta := int(ch.get("reps", 0))
	var mat_add := String(ch.get("mat_add", ""))
	var mat_remove := String(ch.get("mat_remove", ""))
	var applied_add: Variant = null
	var applied_remove: Variant = null
	event_mat_skipped = false
	if gold_delta != 0:
		_set_gold(gold + gold_delta)
	if reps_delta != 0:
		reps = maxi(0, reps + reps_delta)
	if not mat_add.is_empty():
		stock.add_material(mat_add)
		applied_add = mat_add
	if not mat_remove.is_empty():
		var can_remove := stock.owned_count(mat_remove) > 0 and stock.can_remove_material()
		if can_remove:
			stock.remove_one_material(mat_remove)
			applied_remove = mat_remove
		else:
			event_mat_skipped = true
	event_choice_id = choice_id
	event_resolved = true
	if not event_id.is_empty() and not chapter_events_resolved.has(event_id):
		chapter_events_resolved.append(event_id)
	event_deltas = {
		"gold": gold_delta,
		"mat_add": applied_add,
		"mat_remove": applied_remove,
		"reps": reps_delta,
	}
	var line := String(ch.get("result", ""))
	if event_mat_skipped:
		line += " (mat skip — missing or floor)"
	event_result_line = line
	visit_gold_after = gold
	last_note = "Picked %s. %s" % [choice_id, event_result_line]
	last_stamp = _make_schedule_stamp()
	board_changed.emit()
	return true


func finish_event() -> bool:
	if not event_open or not event_resolved:
		return false
	event_open = false
	last_resolve = {
		"resolve_class": "event",
		"day_action": "event",
		"title": "event · %s" % event_id,
		"body": event_result_line,
		"stub": "event",
		"phase": "schedule",
		"event_id": event_id,
	}
	resolve_open = true
	last_note = "Event %s resolved. Continue to the next graph day." % event_id
	last_stamp = _make_schedule_stamp()
	resolve_started.emit(last_resolve)
	board_changed.emit()
	return true


func _apply_market_event_logs(stamp: HarnessStamp) -> void:
	stamp.gold = gold
	stamp.gold_before = visit_gold_before
	stamp.gold_after = visit_gold_after
	stamp.deck_material_count = stock.material_count() if stock != null else 0
	stamp.market_node_id = market_node_id
	stamp.market_bank_id = market_bank_id
	stamp.market_stock = MarketCatalog.stock_rows(market_stock)
	stamp.market_buys = market_buys.duplicate(true)
	stamp.market_sells = market_sells.duplicate(true)
	stamp.market_refresh_base = GameConstants.MARKET_REFRESH_BASE
	stamp.market_refresh_step = GameConstants.MARKET_REFRESH_STEP
	stamp.market_refresh_count = market_refresh_count
	stamp.market_refresh_cost_next = MarketCatalog.refresh_cost(market_refresh_count)
	stamp.market_refreshes = market_refreshes.duplicate(true)
	stamp.market_enchants = market_enchants.duplicate(true)
	stamp.market_tab = market_tab
	stamp.market_staff_bank_id = MarketCatalog.staff_bank_id()
	stamp.market_staff_stock = MarketCatalog.staff_stock_rows(market_staff_stock)
	stamp.market_staff_buys = market_staff_buys.duplicate(true)
	stamp.market_staff_sells = market_staff_sells.duplicate(true)
	stamp.staff_owned = staff_owned.duplicate(true)
	stamp.staff_equipped_id = staff_equipped_id
	stamp.max_materials = live_max_materials()
	stamp.max_runes = live_max_runes()
	stamp.market_skill_bank_id = MarketCatalog.skill_bank_id()
	stamp.market_skill_stock = MarketCatalog.skill_stock_rows(market_skill_stock)
	stamp.market_skill_buys = market_skill_buys.duplicate(true)
	stamp.market_skill_sells = market_skill_sells.duplicate(true)
	stamp.deck_skill_count = stock.skill_count() if stock != null else 0
	stamp.market_artifact_bank_id = MarketCatalog.artifact_bank_id()
	stamp.market_artifact_stock = MarketCatalog.artifact_stock_rows(market_artifact_stock)
	stamp.market_artifact_buys = market_artifact_buys.duplicate(true)
	stamp.market_artifact_sells = market_artifact_sells.duplicate(true)
	stamp.artifact_owned = artifact_owned.duplicate(true)
	stamp.artifact_equipped_ids = artifact_equipped_ids.duplicate(true)
	stamp.event_id = event_id
	stamp.event_choice_id = event_choice_id
	stamp.event_deltas = event_deltas.duplicate(true)
	stamp.event_resolved = event_resolved
	stamp.event_result_line = event_result_line
	stamp.event_mat_skipped = event_mat_skipped
	if event_resolved and int(event_deltas.get("reps", 0)) != 0:
		stamp.reps_before = visit_reps_before
		stamp.reps_after = reps
		stamp.reps_delta = reps - visit_reps_before


func _save_run_if_idle() -> void:
	if board == null:
		return
	if craft_open or market_open or event_open or playback_open or piece_report_open:
		return
	_write_run_save()


func _delete_run_save() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("atelier_run.json"):
		dir.remove("atelier_run.json")


func _write_run_save() -> void:
	if board == null:
		return
	var days: Array = []
	for slot in board.days:
		var action := ""
		var wire: Variant = GameEnums.round_action_wire(slot.day_action)
		if wire != null:
			action = String(wire)
		days.append({
			"day_index": slot.day_index,
			"action": action,
			"order_id": slot.order_id,
			"event_id": slot.event_id,
			"node_id": slot.node_id,
		})
	var cards: Array = []
	if stock != null:
		for card in stock.cards:
			if card == null:
				continue
			cards.append({
				"id": card.id,
				"type": GameEnums.hand_card_type_wire(card.type),
				"mat_enchant_id": card.mat_enchant_id,
				"shiny": card.shiny,
			})
	var payload := {
		"run_id": run_id,
		"chapter_seed": chapter_seed,
		"rng_state": rng.state,
		"event_rng_state": event_rng.state,
		"reps": reps,
		"gold": gold,
		"newspaper_open": newspaper_open,
		"resolve_open": resolve_open,
		"awaiting_boss": awaiting_boss,
		"boss_open": boss_open,
		"boss_client_id": boss_client_id,
		"boss_job_id": boss_job_id,
		"boss_draw_pool": boss_draw_pool,
		"chapter_over": chapter_over,
		"run_over": run_over,
		"run_over_reason": String(GameEnums.run_over_reason_wire(run_over_reason) if GameEnums.run_over_reason_wire(run_over_reason) != null else ""),
		"declined_this_day": declined_this_day,
		"last_note": last_note,
		"last_resolve": last_resolve.duplicate(true),
		"unlocked_outlooks": Array(unlocked_outlooks),
		"staff_equipped_id": staff_equipped_id,
		"staff_owned": staff_owned.duplicate(true),
		"artifact_owned": artifact_owned.duplicate(true),
		"artifact_equipped_ids": artifact_equipped_ids.duplicate(true),
		"chapter_events_resolved": chapter_events_resolved.duplicate(true),
		"stock": cards,
		"chapter_id": board.chapter_id,
		"chapter_boss_id": board.chapter_boss_id,
		"boss_pool_id": board.boss_pool_id,
		"day_index": board.day_index,
		"route_path": Array(board.route_path),
		"draft_path": Array(board.draft_path),
		"current_node_id": board.current_node_id,
		"appt_decline_used": board.appt_decline_used,
		"crafts_done": board.crafts_done,
		"days": days,
	}
	var file := FileAccess.open(RUN_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(payload))


func _load_run_save() -> bool:
	var file := FileAccess.open(RUN_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return false
	var data: Dictionary = parsed
	var chapter_id := int(data.get("chapter_id", 1))
	_reset_craft_state()
	market_open = false
	event_open = false
	_clear_market_visit()
	_clear_event_visit()
	chapter_seed = int(data.get("chapter_seed", 0))
	rng = RandomNumberGenerator.new()
	rng.seed = chapter_seed
	rng.state = int(data.get("rng_state", 0))
	event_rng = RandomNumberGenerator.new()
	event_rng.seed = chapter_seed
	event_rng.state = int(data.get("event_rng_state", 0))
	run_id = String(data.get("run_id", ""))
	reps = int(data.get("reps", GameConstants.REPS_START))
	gold = int(data.get("gold", GameConstants.GOLD_START))
	newspaper_open = bool(data.get("newspaper_open", false))
	resolve_open = bool(data.get("resolve_open", false))
	awaiting_boss = bool(data.get("awaiting_boss", false))
	boss_open = bool(data.get("boss_open", false))
	boss_client_id = String(data.get("boss_client_id", ""))
	boss_job_id = String(data.get("boss_job_id", ""))
	boss_draw_pool = String(data.get("boss_draw_pool", ""))
	chapter_over = bool(data.get("chapter_over", false))
	run_over = bool(data.get("run_over", false))
	run_over_reason = _run_over_from_wire(String(data.get("run_over_reason", "")))
	declined_this_day = bool(data.get("declined_this_day", false))
	last_note = String(data.get("last_note", ""))
	var resolve_raw: Variant = data.get("last_resolve", {})
	last_resolve = resolve_raw if resolve_raw is Dictionary else {}
	unlocked_outlooks = PackedStringArray()
	var outlooks: Variant = data.get("unlocked_outlooks", ["plain"])
	if outlooks is Array:
		for item in outlooks:
			var id := String(item)
			if not id.is_empty() and not (id in unlocked_outlooks):
				unlocked_outlooks.append(id)
	if not ("plain" in unlocked_outlooks):
		unlocked_outlooks.append("plain")
	staff_equipped_id = String(data.get("staff_equipped_id", ""))
	staff_owned = _string_array(data.get("staff_owned", []))
	artifact_owned = _string_array(data.get("artifact_owned", []))
	artifact_equipped_ids = _string_array(data.get("artifact_equipped_ids", []))
	chapter_events_resolved = _string_array(data.get("chapter_events_resolved", []))
	stock = WagonStock.new()
	stock.cards.clear()
	var cards: Variant = data.get("stock", [])
	if cards is Array:
		for item in cards:
			if not (item is Dictionary):
				continue
			var row: Dictionary = item
			stock.cards.append(HandCard.make(
				String(row.get("id", "")),
				_card_type_from_wire(String(row.get("type", "material"))),
				String(row.get("mat_enchant_id", "")),
				bool(row.get("shiny", false))
			))
	board = ChapterSchedule.make_empty(chapter_id)
	board.begin_live(String(data.get("chapter_boss_id", "")), String(data.get("boss_pool_id", "")))
	board.day_index = int(data.get("day_index", 1))
	board.route_path = _packed_ids(data.get("route_path", []))
	board.draft_path = _packed_ids(data.get("draft_path", []))
	board.current_node_id = String(data.get("current_node_id", ""))
	board.appt_decline_used = bool(data.get("appt_decline_used", false))
	board.crafts_done = int(data.get("crafts_done", 0))
	var day_rows: Variant = data.get("days", [])
	if day_rows is Array:
		for item in day_rows:
			if not (item is Dictionary):
				continue
			var row: Dictionary = item
			var slot := board.slot_at(int(row.get("day_index", 0)))
			if slot == null:
				continue
			slot.day_action = _action_from_wire(String(row.get("action", "")))
			slot.order_id = String(row.get("order_id", ""))
			slot.event_id = String(row.get("event_id", ""))
			slot.node_id = String(row.get("node_id", ""))
	board.sync_days_left()
	if newspaper_open:
		last_stamp = _make_newspaper_stamp()
	else:
		last_stamp = _make_schedule_stamp()
	board_changed.emit()
	return true


func _packed_ids(value: Variant) -> Array[String]:
	var out: Array[String] = []
	if value is Array:
		for item in value:
			var id := String(item)
			if not id.is_empty():
				out.append(id)
	return out


func _string_array(value: Variant) -> Array:
	var out: Array = []
	if value is Array:
		for item in value:
			out.append(String(item))
	return out


func _action_from_wire(wire: String) -> GameEnums.RoundAction:
	match wire:
		"appointment":
			return GameEnums.RoundAction.APPOINTMENT
		"walk_in":
			return GameEnums.RoundAction.WALK_IN
		"wagon_shop":
			return GameEnums.RoundAction.WAGON_SHOP
		"wagon_event":
			return GameEnums.RoundAction.WAGON_EVENT
		"prep_craft":
			return GameEnums.RoundAction.PREP_CRAFT
		"rest_dig":
			return GameEnums.RoundAction.REST_DIG
		_:
			return GameEnums.RoundAction.NONE


func _card_type_from_wire(wire: String) -> GameEnums.HandCardType:
	match wire:
		"rune":
			return GameEnums.HandCardType.RUNE
		"skill":
			return GameEnums.HandCardType.SKILL
		_:
			return GameEnums.HandCardType.MATERIAL


func _run_over_from_wire(wire: String) -> GameEnums.RunOverReason:
	match wire:
		"reps_gate_miss":
			return GameEnums.RunOverReason.REPS_GATE_MISS
		"boss_death":
			return GameEnums.RunOverReason.BOSS_DEATH
		_:
			return GameEnums.RunOverReason.NONE

