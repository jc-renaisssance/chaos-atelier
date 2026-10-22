class_name HarnessStamp
extends Resource
## One dump = one stamp (docs/20). crafts_done_this_chapter counts finished pieces.

@export_group("Identity")
@export var run_id: String = ""
@export var player_owner_id: String = GameConstants.PHASE1_OWNER_ID
@export var chapter_id: int = 1
@export var chapter_boss_id: String = ""
@export var boss_pool_id: String = ""
@export var boss_client_id: String = "" ## adv_* on mission_kind=boss; dump null otherwise
@export var boss_job_id: String = "" ## job_* on mission_kind=boss; dump null otherwise
@export var adventurer_skill_id: String = "" ## ask_* log-only (docs/30 slice 1); not a 20 Required field
@export var adventurer_stats: Dictionary = {} ## panel knobs {HP,ATK,DEF,RES,MOB,PRE}; log-only

@export_group("Route map")
@export var CHAPTER_DAY_COUNT: int = 0 ## = map.day_count this chapter — not always-8
@export var day_index: int = GameConstants.NULL_INT ## null on chapter-start newspaper
@export var days_left: int = 0
@export var day_action: GameEnums.RoundAction = GameEnums.RoundAction.NONE
@export var route_map_id: String = ""
@export var route_nodes: Array[RouteNode] = []
@export var route_edges: Array[RouteEdge] = []
@export var route_path: Array[String] = []
@export var draft_path: Array[String] = []
@export var current_node_id: String = ""
@export var bound_block_id: String = ""
@export var fork_options: Array = []
@export var appointment_pins: Array[AppointmentPin] = []
@export var appt_decline_used: bool = false
## Unbounded piece telemetry. Not a gate. Do not emit crafts_max.
@export var crafts_done_this_chapter: int = 0
@export var phase: GameEnums.StampPhase = GameEnums.StampPhase.SCHEDULE

@export_group("Mission")
@export var mission_kind: GameEnums.MissionKind = GameEnums.MissionKind.NONE
@export var order_id: String = ""
@export var threat_id: String = ""
@export var construction_ids: PackedStringArray = PackedStringArray()
@export var construction_id: String = ""
@export var card_difficulty: int = GameConstants.NULL_INT

@export_group("Stamina session")
@export var session: CraftStaminaSession ## null when not in a legal craft

@export_group("Resolver outputs")
@export var tag_counts: Dictionary = {}
@export var craft_rarity: GameEnums.CraftRarity = GameEnums.CraftRarity.NONE
@export var powers_positive: PackedStringArray = PackedStringArray()
@export var powers_negative: PackedStringArray = PackedStringArray()
@export var outlook_id: String = ""
@export var outlook_order: int = 0
@export var stats: GearStats
@export var rating: GameEnums.Rating = GameEnums.Rating.NONE
@export var hp_remaining: float = GameConstants.NULL_FLOAT
@export var damage_aid_pct: int = GameConstants.NULL_INT
@export var skill_effectiveness: int = GameConstants.NULL_INT
@export var cleared: bool = false
@export var mission_failed: bool = false
@export var outcome: GameEnums.Outcome = GameEnums.Outcome.NONE
@export var favor_tags_hit: PackedStringArray = PackedStringArray()
@export var punish_tags_hit: PackedStringArray = PackedStringArray()
@export var run_over: bool = false
@export var run_over_reason: GameEnums.RunOverReason = GameEnums.RunOverReason.NONE
@export var reps_before: int = 0
@export var reps_after: int = 0
@export var reps_delta: int = 0
@export var reps_gate: int = 0 ## docs/25 — C1 8 / C2 14 / C3 20 from the live chapter
@export var newspaper_event: GameEnums.NewspaperEvent = GameEnums.NewspaperEvent.NONE
@export var newspaper_headline_id: String = ""
@export var letter_id: String = ""
@export var cant_craft: bool = false

@export_group("Profile / Dex logs (docs/30, 31) — not 20 Required")
@export var unlocked_builds: Array = []
@export var unlocks_new: Array = []
@export var dex_crafts: Array = []
@export var dex_crafts_new: Array = []
@export var dex_adventurers: Array = []
@export var dex_adventurer_new_met: Array = []
@export var dex_enemies: Array = []
@export var dex_enemy_seen_new: Array = []
@export var dex_enemy_fought_new: Array = []
@export var profile_day: int = 0
## Slice 2/3 logs (docs/30). Not 20 Required. planned_build is {outlook_id, tier} or null.
var planned_build: Variant = null
var estimate_band: Variant = "?"
var estimate_favor_hits: Variant = "?"
var estimate_punish_hits: Variant = "?"
var estimate_skill_fired: Variant = "?"
var estimate_neg_warnings: Variant = "?"
## Slice 4 playback logs (docs/30, docs/20). Not Required. No new assert.
var playback_played: bool = false
var playback_skipped: bool = false
var playback_beats: Array = []
var playback_actor_id: Variant = null

## docs/32 market / event visit logs. Null the unused block in to_dict.
## mission_purse reuses gold_before / gold_after on a mission return. Not its own dump key.
var mission_purse: bool = false
var gold: int = 0
var gold_before: int = GameConstants.NULL_INT
var gold_after: int = GameConstants.NULL_INT
var deck_material_count: int = GameConstants.NULL_INT
var market_node_id: String = ""
var market_bank_id: String = ""
var market_stock: Array = []
var market_buys: Array = []
var market_sells: Array = []
var market_refresh_base: int = GameConstants.NULL_INT
var market_refresh_step: int = GameConstants.NULL_INT
var market_refresh_count: int = 0
var market_refresh_cost_next: int = GameConstants.NULL_INT
var market_refreshes: Array = []
var market_enchants: Array = []
var market_tab: String = ""
var market_staff_bank_id: String = ""
var market_staff_stock: Array = []
var market_staff_buys: Array = []
var market_staff_sells: Array = []
var staff_owned: Array = []
var staff_equipped_id: String = ""
var max_materials: int = GameConstants.DEFAULT_MAX_MATERIALS
var max_runes: int = GameConstants.DEFAULT_MAX_RUNES
var market_skill_bank_id: String = ""
var market_skill_stock: Array = []
var market_skill_buys: Array = []
var market_skill_sells: Array = []
var deck_skill_count: int = GameConstants.NULL_INT
var market_artifact_bank_id: String = ""
var market_artifact_stock: Array = []
var market_artifact_buys: Array = []
var market_artifact_sells: Array = []
var artifact_owned: Array = []
var artifact_equipped_ids: Array = []
var event_id: String = ""
var event_choice_id: String = ""
var event_deltas: Dictionary = {}
var event_resolved: bool = false
var event_result_line: String = ""
var event_mat_skipped: bool = false


func emit_mission() -> bool:
	return phase == GameEnums.StampPhase.CRAFT or phase == GameEnums.StampPhase.BOSS


func emit_session() -> bool:
	return phase == GameEnums.StampPhase.CRAFT and not cant_craft and session != null


func emit_resolver() -> bool:
	return emit_mission() and rating != GameEnums.Rating.NONE


func _emit_market() -> bool:
	return day_action == GameEnums.RoundAction.WAGON_SHOP


func _emit_event() -> bool:
	return day_action == GameEnums.RoundAction.WAGON_EVENT and event_id.begins_with("evt_")


func apply_schedule(board: ChapterSchedule) -> void:
	player_owner_id = board.player_owner_id
	chapter_id = board.chapter_id
	chapter_boss_id = board.chapter_boss_id
	boss_pool_id = board.boss_pool_id
	CHAPTER_DAY_COUNT = board.day_count
	day_index = board.day_index
	days_left = board.days_left
	day_action = board.current_day_action()
	route_map_id = board.map_id
	route_nodes = board.route_nodes.duplicate()
	route_edges = board.route_edges.duplicate()
	route_path = board.route_path.duplicate()
	draft_path = board.draft_path.duplicate()
	current_node_id = board.current_node_id
	bound_block_id = board.bound_block_id()
	fork_options = board.fork_option_rows()
	appointment_pins = board.appointment_pins.duplicate()
	appt_decline_used = board.appt_decline_used
	crafts_done_this_chapter = board.crafts_done
	phase = GameEnums.StampPhase.SCHEDULE
	session = null
	adventurer_skill_id = ""
	adventurer_stats = {}


func apply_piece_session(order: ClientOrder, piece_session: CraftStaminaSession) -> void:
	mission_kind = order.mission_kind
	order_id = order.order_id
	threat_id = order.threat_id
	construction_ids = order.construction_ids.duplicate()
	construction_id = piece_session.construction_id if piece_session != null else ""
	card_difficulty = order.card_difficulty
	session = piece_session
	phase = GameEnums.StampPhase.CRAFT
	if order.mission_kind == GameEnums.MissionKind.BOSS:
		boss_client_id = order.boss_client_id
		boss_job_id = order.boss_job_id
	else:
		boss_client_id = ""
		boss_job_id = ""
	apply_adventurer_logs(AdventurerCatalog.order_adventurer_id(order))


func apply_resolver(result: Dictionary) -> void:
	tag_counts = Dictionary(result.get("tag_counts", {})).duplicate()
	craft_rarity = result.get("craft_rarity", GameEnums.CraftRarity.NONE)
	powers_positive = PackedStringArray(result.get("powers_positive", PackedStringArray()))
	powers_negative = PackedStringArray(result.get("powers_negative", PackedStringArray()))
	outlook_id = String(result.get("outlook_id", "plain"))
	outlook_order = int(result.get("outlook_order", 0))
	stats = result.get("stats", GearStats.new())
	if stats == null:
		stats = GearStats.new()
	rating = result.get("rating", GameEnums.Rating.NONE)
	hp_remaining = float(result.get("hp_remaining", GameConstants.NULL_FLOAT))
	damage_aid_pct = int(result.get("damage_aid_pct", GameConstants.NULL_INT))
	skill_effectiveness = int(result.get("skill_effectiveness", GameConstants.NULL_INT))
	cleared = bool(result.get("cleared", false))
	mission_failed = bool(result.get("mission_failed", false))
	outcome = result.get("outcome", GameEnums.Outcome.NONE)
	favor_tags_hit = PackedStringArray(result.get("favor_tags_hit", PackedStringArray()))
	punish_tags_hit = PackedStringArray(result.get("punish_tags_hit", PackedStringArray()))
	cant_craft = bool(result.get("cant_craft", false))
	if result.has("letter_id"):
		letter_id = String(result.get("letter_id", ""))
	if result.has("run_over"):
		run_over = bool(result.get("run_over", false))
	if result.has("run_over_reason"):
		run_over_reason = result.get("run_over_reason", GameEnums.RunOverReason.NONE)


func _reserved_day_action() -> bool:
	if day_action == GameEnums.RoundAction.NONE:
		return false
	return GameConstants.is_reserved_final_day(day_index, CHAPTER_DAY_COUNT)


func _null_int(value: int) -> Variant:
	return null if value == GameConstants.NULL_INT else value


func _null_float(value: float) -> Variant:
	return null if is_equal_approx(value, GameConstants.NULL_FLOAT) else value


func _null_str(value: String) -> Variant:
	return null if value.is_empty() else value


func _is_boss_mission() -> bool:
	return emit_mission() and mission_kind == GameEnums.MissionKind.BOSS


func _boss_client_wire() -> Variant:
	if not _is_boss_mission():
		return null
	return _null_str(boss_client_id)


func _boss_job_wire() -> Variant:
	if not _is_boss_mission():
		return null
	return _null_str(boss_job_id)


func apply_adventurer_logs(adv_id: String) -> void:
	var person := AdventurerCatalog.row_resolved(adv_id)
	if person.is_empty():
		adventurer_skill_id = ""
		adventurer_stats = {}
		return
	adventurer_skill_id = String(person.get("skill_id", ""))
	adventurer_stats = AdventurerCatalog.stats_dict(adv_id)


func _adventurer_stats_wire() -> Variant:
	if adventurer_stats.is_empty():
		return null
	return {
		"HP": int(adventurer_stats.get("HP", 0)),
		"ATK": int(adventurer_stats.get("ATK", 0)),
		"DEF": int(adventurer_stats.get("DEF", 0)),
		"RES": int(adventurer_stats.get("RES", 0)),
		"MOB": int(adventurer_stats.get("MOB", 0)),
		"PRE": int(adventurer_stats.get("PRE", 0)),
	}


func _pin_rows() -> Array:
	var rows: Array = []
	for pin in appointment_pins:
		rows.append(pin.to_dict())
	return rows


func _route_node_rows() -> Array:
	var rows: Array = []
	for node in route_nodes:
		rows.append(node.to_dict())
	return rows


func _route_edge_rows() -> Array:
	var rows: Array = []
	for edge in route_edges:
		rows.append(edge.to_dict())
	return rows


func _path_rows(path: Array[String]) -> Array:
	var rows: Array = []
	for nid in path:
		rows.append(nid)
	return rows


func to_dict() -> Dictionary:
	var dump := {
		"run_id": run_id,
		"player_owner_id": player_owner_id,
		"chapter_id": chapter_id,
		"chapter_boss_id": chapter_boss_id,
		"boss_pool_id": boss_pool_id,
		"boss_client_id": _boss_client_wire(),
		"boss_job_id": _boss_job_wire(),
		"adventurer_skill_id": _null_str(adventurer_skill_id),
		"adventurer_stats": _adventurer_stats_wire(),
		"CHAPTER_DAY_COUNT": CHAPTER_DAY_COUNT,
		"day_index": _null_int(day_index),
		"days_left": days_left,
		"day_action": GameEnums.day_action_wire(day_action) if not _reserved_day_action() else "reserved",
		"route_map_id": route_map_id,
		"route_nodes": _route_node_rows(),
		"route_edges": _route_edge_rows(),
		"route_path": _path_rows(route_path),
		"draft_path": _path_rows(draft_path),
		"current_node_id": _null_str(current_node_id),
		"bound_block_id": _null_str(bound_block_id),
		"fork_options": fork_options.duplicate(true),
		"appointment_pins": _pin_rows(),
		"appt_decline_used": appt_decline_used,
		"crafts_done_this_chapter": crafts_done_this_chapter,
		"phase": GameEnums.stamp_phase_wire(phase),
		"cant_craft": cant_craft,
		"newspaper_event": GameEnums.newspaper_event_wire(newspaper_event),
		"newspaper_headline_id": _null_str(newspaper_headline_id),
		"letter_id": _null_str(letter_id),
		"run_over": run_over,
		"run_over_reason": GameEnums.run_over_reason_wire(run_over_reason),
		"reps_before": reps_before,
		"reps_after": reps_after,
		"reps_delta": reps_delta,
		"reps_gate": reps_gate,
		"unlocked_builds": unlocked_builds.duplicate(true),
		"unlocks_new": unlocks_new.duplicate(true),
		"planned_build": planned_build,
		"estimate_band": estimate_band,
		"estimate_favor_hits": estimate_favor_hits,
		"estimate_punish_hits": estimate_punish_hits,
		"estimate_skill_fired": estimate_skill_fired,
		"estimate_neg_warnings": estimate_neg_warnings,
		"dex_crafts": dex_crafts.duplicate(true),
		"dex_crafts_new": dex_crafts_new.duplicate(true),
		"dex_adventurers": dex_adventurers.duplicate(true),
		"dex_adventurer_new_met": dex_adventurer_new_met.duplicate(true),
		"dex_enemies": dex_enemies.duplicate(true),
		"dex_enemy_seen_new": dex_enemy_seen_new.duplicate(true),
		"dex_enemy_fought_new": dex_enemy_fought_new.duplicate(true),
		"profile_day": profile_day,
	}
	if emit_mission():
		dump["mission_kind"] = GameEnums.mission_kind_wire(mission_kind)
		dump["order_id"] = _null_str(order_id)
		dump["threat_id"] = _null_str(threat_id)
		dump["construction_ids"] = Array(construction_ids)
		dump["construction_id"] = _null_str(construction_id)
		dump["card_difficulty"] = _null_int(card_difficulty)
	else:
		dump["mission_kind"] = null
		dump["order_id"] = null
		dump["threat_id"] = null
		dump["construction_ids"] = []
		dump["construction_id"] = null
		dump["card_difficulty"] = null
	if emit_session():
		dump.merge(session.to_session_dict())
	else:
		dump["piece_index"] = null
		dump["piece_count"] = null
		dump["zone_count"] = null
		dump["stamina_start"] = null
		dump["stamina_remaining"] = null
		dump["stamina_spent"] = null
		dump["hand_size"] = null
		dump["dig_refresh_cost"] = null
		dump["dig_count"] = null
		dump["cards_played"] = null
		dump["early_finish"] = null
		dump["finish_reason"] = null
	if emit_resolver():
		var stat_bag: Dictionary = stats.to_dict() if stats != null else GearStats.new().to_dict()
		dump["tag_counts"] = tag_counts.duplicate()
		dump["craft_rarity"] = GameEnums.craft_rarity_wire(craft_rarity)
		dump["powers_positive"] = Array(powers_positive)
		dump["powers_negative"] = Array(powers_negative)
		dump["outlook_id"] = outlook_id if not outlook_id.is_empty() else "plain"
		dump["outlook_order"] = outlook_order
		dump["stats"] = stat_bag
		dump["rating"] = GameEnums.rating_wire(rating)
		dump["hp_remaining"] = _null_float(hp_remaining)
		dump["damage_aid_pct"] = _null_int(damage_aid_pct)
		dump["skill_effectiveness"] = _null_int(skill_effectiveness)
		dump["cleared"] = cleared
		dump["mission_failed"] = mission_failed
		dump["outcome"] = GameEnums.outcome_wire(outcome)
		dump["favor_tags_hit"] = Array(favor_tags_hit)
		dump["punish_tags_hit"] = Array(punish_tags_hit)
	else:
		dump["tag_counts"] = {}
		dump["craft_rarity"] = null
		dump["powers_positive"] = []
		dump["powers_negative"] = []
		dump["outlook_id"] = null
		dump["outlook_order"] = null
		dump["stats"] = null
		dump["rating"] = null
		dump["hp_remaining"] = null
		dump["damage_aid_pct"] = null
		dump["skill_effectiveness"] = null
		dump["cleared"] = null
		dump["mission_failed"] = null
		dump["outcome"] = null
		dump["favor_tags_hit"] = []
		dump["punish_tags_hit"] = []
	dump["gold"] = gold
	dump["deck_material_count"] = _null_int(deck_material_count)
	if _emit_market():
		dump["gold_before"] = gold_before
		dump["gold_after"] = gold_after
		dump["gold_delta"] = gold_after - gold_before
		dump["market_node_id"] = _null_str(market_node_id)
		dump["market_bank_id"] = _null_str(market_bank_id)
		dump["market_stock"] = market_stock.duplicate(true)
		dump["market_buys"] = market_buys.duplicate(true)
		dump["market_sells"] = market_sells.duplicate(true)
		dump["market_refresh_base"] = market_refresh_base
		dump["market_refresh_step"] = market_refresh_step
		dump["market_refresh_count"] = market_refresh_count
		dump["market_refresh_cost_next"] = market_refresh_cost_next
		dump["market_refreshes"] = market_refreshes.duplicate(true)
		dump["market_enchants"] = market_enchants.duplicate(true)
		dump["market_tab"] = _null_str(market_tab)
		dump["market_staff_bank_id"] = _null_str(market_staff_bank_id)
		dump["market_staff_stock"] = market_staff_stock.duplicate(true)
		dump["market_staff_buys"] = market_staff_buys.duplicate(true)
		dump["market_staff_sells"] = market_staff_sells.duplicate(true)
		dump["staff_owned"] = staff_owned.duplicate(true)
		dump["staff_equipped_id"] = _null_str(staff_equipped_id)
		dump["max_materials"] = max_materials
		dump["max_runes"] = max_runes
		dump["market_skill_bank_id"] = _null_str(market_skill_bank_id)
		dump["market_skill_stock"] = market_skill_stock.duplicate(true)
		dump["market_skill_buys"] = market_skill_buys.duplicate(true)
		dump["market_skill_sells"] = market_skill_sells.duplicate(true)
		dump["deck_skill_count"] = deck_skill_count
		dump["market_artifact_bank_id"] = _null_str(market_artifact_bank_id)
		dump["market_artifact_stock"] = market_artifact_stock.duplicate(true)
		dump["market_artifact_buys"] = market_artifact_buys.duplicate(true)
		dump["market_artifact_sells"] = market_artifact_sells.duplicate(true)
		dump["artifact_owned"] = artifact_owned.duplicate(true)
		dump["artifact_equipped_ids"] = artifact_equipped_ids.duplicate(true)
	else:
		dump["gold_before"] = null
		dump["gold_after"] = null
		dump["gold_delta"] = null
		dump["market_node_id"] = null
		dump["market_bank_id"] = null
		dump["market_stock"] = null
		dump["market_buys"] = null
		dump["market_sells"] = null
		dump["market_refresh_base"] = null
		dump["market_refresh_step"] = null
		dump["market_refresh_count"] = null
		dump["market_refresh_cost_next"] = null
		dump["market_refreshes"] = null
		dump["market_enchants"] = null
		dump["market_tab"] = null
		dump["market_staff_bank_id"] = null
		dump["market_staff_stock"] = null
		dump["market_staff_buys"] = null
		dump["market_staff_sells"] = null
		dump["staff_owned"] = null
		dump["staff_equipped_id"] = null
		dump["market_skill_bank_id"] = null
		dump["market_skill_stock"] = null
		dump["market_skill_buys"] = null
		dump["market_skill_sells"] = null
		dump["deck_skill_count"] = null
		dump["market_artifact_bank_id"] = null
		dump["market_artifact_stock"] = null
		dump["market_artifact_buys"] = null
		dump["market_artifact_sells"] = null
		dump["artifact_owned"] = null
		dump["artifact_equipped_ids"] = null
		if phase == GameEnums.StampPhase.CRAFT:
			dump["max_materials"] = max_materials
			dump["max_runes"] = max_runes
		else:
			dump["max_materials"] = null
			dump["max_runes"] = null
	if _emit_event():
		if not _emit_market():
			dump["gold_before"] = gold_before
			dump["gold_after"] = gold_after
			dump["gold_delta"] = gold_after - gold_before
		dump["event_id"] = _null_str(event_id)
		dump["event_choice_id"] = _null_str(event_choice_id)
		dump["event_deltas"] = event_deltas.duplicate(true)
		dump["event_resolved"] = event_resolved
		dump["event_result_line"] = _null_str(event_result_line)
		dump["event_mat_skipped"] = event_mat_skipped
	else:
		dump["event_id"] = null
		dump["event_choice_id"] = null
		dump["event_deltas"] = null
		dump["event_resolved"] = null
		dump["event_result_line"] = null
		dump["event_mat_skipped"] = null
	if mission_purse and not _emit_market() and not _emit_event():
		dump["gold_before"] = gold_before
		dump["gold_after"] = gold_after
		dump["gold_delta"] = gold_after - gold_before
	## Log-only. Not a Required column. cant_craft / market / event stay played=false, beats=[].
	dump["playback_played"] = playback_played
	dump["playback_skipped"] = playback_skipped
	dump["playback_beats"] = playback_beats.duplicate()
	dump["playback_actor_id"] = playback_actor_id
	return dump


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if player_owner_id != GameConstants.PHASE1_OWNER_ID:
		errs.append("player_owner_id must be own_basic")
	if CHAPTER_DAY_COUNT <= 0:
		errs.append("CHAPTER_DAY_COUNT must equal map.day_count")
	if crafts_done_this_chapter < 0:
		errs.append("crafts_done_this_chapter must be >= 0 (unbounded telemetry, not a gate)")
	# cant_craft must not increment crafts_done_this_chapter (docs/20 assert 10).
	if phase == GameEnums.StampPhase.SCHEDULE or phase == GameEnums.StampPhase.CRAFT:
		if day_index != GameConstants.NULL_INT and not GameConstants.is_schedule_day(day_index, CHAPTER_DAY_COUNT):
			errs.append("day_index not in 1..CHAPTER_DAY_COUNT")
	for pin in appointment_pins:
		errs.append_array(pin.schema_errors(CHAPTER_DAY_COUNT))
	for node in route_nodes:
		errs.append_array(node.schema_errors(CHAPTER_DAY_COUNT))
	for edge in route_edges:
		errs.append_array(edge.schema_errors())
	if fork_options.size() == 1 or fork_options.size() > 4:
		errs.append("fork_options length must be 0 or 2..4")
	for nid in draft_path:
		if nid in route_path:
			errs.append("draft_path must not overlap route_path")
			break
	if emit_session():
		errs.append_array(session.schema_errors())
		if session.construction_id != construction_id and not construction_id.is_empty():
			errs.append("stamp construction_id != session construction_id")
	if emit_resolver():
		if (
			craft_rarity == GameEnums.CraftRarity.RARE
			or craft_rarity == GameEnums.CraftRarity.LEGENDARY
		):
			if powers_negative.size() != 0:
				errs.append("rare/legendary must skip syn_neg_*")
		var hp_ok := hp_remaining > 0.0
		var expect_clear := hp_ok and GameEnums.rating_clears(rating)
		if cleared != expect_clear and hp_remaining != GameConstants.NULL_FLOAT:
			errs.append("cleared != (hp_remaining > 0 ∧ rating ∈ S,A,B,C)")
	if cant_craft:
		if rating != GameEnums.Rating.F:
			errs.append("cant_craft must be rating F")
		if hp_remaining <= 0.0:
			errs.append("cant_craft must keep hp_remaining > 0")
		if damage_aid_pct != 0 and damage_aid_pct != GameConstants.NULL_INT:
			errs.append("cant_craft must have damage_aid_pct 0")
		if cleared:
			errs.append("cant_craft must not clear")
	if run_over and run_over_reason == GameEnums.RunOverReason.NONE:
		errs.append("run_over without run_over_reason")
	## unlocked_builds / Dex / estimate keys are log-only (docs/30, 31). Do not schema-require them.
	## playback_played / playback_skipped / playback_beats / playback_actor_id are log-only too.
	## Builds tab reads unlocked_builds only — no parallel builds list.
	## Planned-chip estimate is a prediction window, not the live resolver letter.
	if mission_kind == GameEnums.MissionKind.BOSS:
		if BossClientCatalog.is_appointment_id(boss_client_id):
			errs.append("boss_client_id must never be appt_*")
		if not BossClientCatalog.is_adv_id(boss_client_id):
			errs.append("mission_kind=boss requires boss_client_id adv_* from the shared pool")
		if not BossClientCatalog.has_job(boss_job_id):
			errs.append("mission_kind=boss requires boss_job_id from the shared pool")
		if not BossClientCatalog.client_matches_job(boss_client_id, boss_job_id):
			errs.append("boss_job_id does not match boss_client_id")
		if not BossClientCatalog.constructions_match(boss_job_id, construction_ids):
			errs.append("construction_ids must equal that job's listed con_*")
		if threat_id != chapter_boss_id or chapter_boss_id.is_empty():
			errs.append("mission_kind=boss threat_id must equal chapter_boss_id")
	return errs
