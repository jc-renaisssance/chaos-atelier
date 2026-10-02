class_name HarnessStamp
extends Resource
## One dump = one stamp (docs/20). crafts_done_this_chapter counts finished pieces.

@export_group("Identity")
@export var run_id: String = ""
@export var player_owner_id: String = GameConstants.PHASE1_OWNER_ID
@export var chapter_id: int = 1
@export var chapter_boss_id: String = ""
@export var boss_pool_id: String = ""

@export_group("Schedule board")
@export var CHAPTER_ROUND_COUNT: int = GameConstants.CHAPTER_ROUND_COUNT
@export var round_index: int = GameConstants.NULL_INT ## null on chapter-start newspaper
@export var rounds_left: int = GameConstants.CHAPTER_ROUND_COUNT
@export var round_action: GameEnums.RoundAction = GameEnums.RoundAction.NONE
@export var appointment_pins: Array[AppointmentPin] = []
@export var appt_decline_used: bool = false
## Lock: crafts_done_this_chapter / crafts_max=4 counts pieces, not whole orders.
## Each construction in a multi-piece order; armor+gloves = 2 of 4.
@export var crafts_done_this_chapter: int = 0
@export var crafts_max: int = GameConstants.CRAFTS_MAX
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
@export var reps_gate: int = 0 ## docs/25 draft numbers are not locked on this slice
@export var newspaper_event: GameEnums.NewspaperEvent = GameEnums.NewspaperEvent.NONE
@export var newspaper_headline_id: String = ""
@export var letter_id: String = ""
@export var cant_craft: bool = false


func emit_mission() -> bool:
	return phase == GameEnums.StampPhase.CRAFT or phase == GameEnums.StampPhase.BOSS


func emit_session() -> bool:
	return phase == GameEnums.StampPhase.CRAFT and not cant_craft and session != null


func emit_resolver() -> bool:
	return emit_mission() and rating != GameEnums.Rating.NONE


func apply_schedule(board: ChapterSchedule) -> void:
	player_owner_id = board.player_owner_id
	chapter_id = board.chapter_id
	chapter_boss_id = board.chapter_boss_id
	boss_pool_id = board.boss_pool_id
	CHAPTER_ROUND_COUNT = GameConstants.CHAPTER_ROUND_COUNT
	round_index = board.round_index
	rounds_left = board.rounds_left
	round_action = board.current_round_action()
	appointment_pins = board.appointment_pins.duplicate()
	appt_decline_used = board.appt_decline_used
	crafts_done_this_chapter = board.crafts_done
	crafts_max = board.crafts_max
	phase = GameEnums.StampPhase.SCHEDULE
	session = null


func apply_piece_session(order: ClientOrder, piece_session: CraftStaminaSession) -> void:
	mission_kind = order.mission_kind
	order_id = order.order_id
	threat_id = order.threat_id
	construction_ids = order.construction_ids.duplicate()
	construction_id = piece_session.construction_id if piece_session != null else ""
	card_difficulty = order.card_difficulty
	session = piece_session
	phase = GameEnums.StampPhase.CRAFT


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
	cant_craft = bool(result.get("cant_craft", false))


func _null_int(value: int) -> Variant:
	return null if value == GameConstants.NULL_INT else value


func _null_float(value: float) -> Variant:
	return null if is_equal_approx(value, GameConstants.NULL_FLOAT) else value


func _null_str(value: String) -> Variant:
	return null if value.is_empty() else value


func _pin_rows() -> Array:
	var rows: Array = []
	for pin in appointment_pins:
		rows.append(pin.to_dict())
	return rows


func to_dict() -> Dictionary:
	var dump := {
		"run_id": run_id,
		"player_owner_id": player_owner_id,
		"chapter_id": chapter_id,
		"chapter_boss_id": chapter_boss_id,
		"boss_pool_id": boss_pool_id,
		"CHAPTER_ROUND_COUNT": CHAPTER_ROUND_COUNT,
		"round_index": _null_int(round_index),
		"rounds_left": rounds_left,
		"round_action": GameEnums.round_action_wire(round_action),
		"appointment_pins": _pin_rows(),
		"appt_decline_used": appt_decline_used,
		"crafts_done_this_chapter": crafts_done_this_chapter,
		"crafts_max": crafts_max,
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
	return dump


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if player_owner_id != GameConstants.PHASE1_OWNER_ID:
		errs.append("player_owner_id must be own_basic")
	if CHAPTER_ROUND_COUNT != GameConstants.CHAPTER_ROUND_COUNT:
		errs.append("CHAPTER_ROUND_COUNT != 8")
	if crafts_max != GameConstants.CRAFTS_MAX:
		errs.append("crafts_max != 4")
	if crafts_done_this_chapter < 0 or crafts_done_this_chapter > crafts_max:
		errs.append("crafts_done_this_chapter out of 0..4 (counts pieces, not orders)")
	# cant_craft must not increment crafts_done_this_chapter (docs/20 assert 10).
	if phase == GameEnums.StampPhase.SCHEDULE or phase == GameEnums.StampPhase.CRAFT:
		if round_index != GameConstants.NULL_INT and not GameConstants.is_schedule_round(round_index):
			errs.append("round_index not in 1..8")
	var pin_n := appointment_pins.size()
	if pin_n != 0 and (pin_n < GameConstants.APPOINTMENT_PIN_MIN or pin_n > GameConstants.APPOINTMENT_PIN_MAX):
		errs.append("appointment_pins length %d not in 2..4" % pin_n)
	for pin in appointment_pins:
		errs.append_array(pin.schema_errors())
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
	return errs
