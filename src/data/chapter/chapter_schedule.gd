class_name ChapterSchedule
extends Resource
## 8-round travelling atelier board (docs/22). No 1-of-3 lineup picker.

@export var player_owner_id: String = GameConstants.PHASE1_OWNER_ID
@export var chapter_id: int = 1
@export var chapter_boss_id: String = ""
@export var boss_pool_id: String = ""
@export var round_index: int = GameConstants.NULL_INT ## 1..8 once a round is live
@export var rounds_left: int = GameConstants.CHAPTER_ROUND_COUNT
@export var rounds: Array[ScheduleRound] = []
@export var appointment_pins: Array[AppointmentPin] = []
@export var appt_decline_used: bool = false
## Lock (docs/20, docs/22): crafts_done / crafts_max=4 counts pieces
## (each construction in a multi-piece order), not whole orders. Armor+gloves = 2 of 4.
@export var crafts_done: int = 0
@export var crafts_max: int = GameConstants.CRAFTS_MAX


static func make_empty(chapter_id_: int = 1) -> ChapterSchedule:
	var board := ChapterSchedule.new()
	board.chapter_id = chapter_id_
	board.player_owner_id = GameConstants.PHASE1_OWNER_ID
	board.boss_pool_id = String(GameConstants.BOSS_POOL_IDS.get(chapter_id_, ""))
	board.rounds_left = GameConstants.CHAPTER_ROUND_COUNT
	board.crafts_max = GameConstants.CRAFTS_MAX
	for i in range(1, GameConstants.CHAPTER_ROUND_COUNT + 1):
		var slot := ScheduleRound.new()
		slot.round_index = i
		board.rounds.append(slot)
	return board


func slot_at(round_i: int) -> ScheduleRound:
	for slot in rounds:
		if slot.round_index == round_i:
			return slot
	return null


func pin_at(round_i: int) -> AppointmentPin:
	for pin in appointment_pins:
		if pin.pinned_round == round_i:
			return pin
	return null


func current_round() -> ScheduleRound:
	if not GameConstants.is_schedule_round(round_index):
		return null
	return slot_at(round_index)


func current_round_action() -> GameEnums.RoundAction:
	var slot := current_round()
	if slot == null:
		return GameEnums.RoundAction.NONE
	return slot.round_action


func current_pin() -> AppointmentPin:
	if not GameConstants.is_schedule_round(round_index):
		return null
	return pin_at(round_index)


func resolved_count() -> int:
	var n := 0
	for slot in rounds:
		if slot.round_action != GameEnums.RoundAction.NONE:
			n += 1
	return n


func sync_rounds_left() -> void:
	rounds_left = GameConstants.CHAPTER_ROUND_COUNT - resolved_count()


func is_current_resolved() -> bool:
	var slot := current_round()
	return slot != null and slot.round_action != GameEnums.RoundAction.NONE


func is_schedule_complete() -> bool:
	return resolved_count() >= GameConstants.CHAPTER_ROUND_COUNT


func begin_live(boss_id: String, pool_id: String, pins: Array[AppointmentPin]) -> void:
	chapter_boss_id = boss_id
	boss_pool_id = pool_id
	appointment_pins = pins
	appt_decline_used = false
	crafts_done = 0
	crafts_max = GameConstants.CRAFTS_MAX
	player_owner_id = GameConstants.PHASE1_OWNER_ID
	round_index = 1
	for slot in rounds:
		slot.round_action = GameEnums.RoundAction.NONE
		slot.order_id = ""
	sync_rounds_left()


## Phase-1: exactly one primary action per round (docs/22, docs/20).
func set_primary_action(action: GameEnums.RoundAction, order_id_: String = "") -> bool:
	if action == GameEnums.RoundAction.NONE:
		return false
	var slot := current_round()
	if slot == null or slot.round_action != GameEnums.RoundAction.NONE:
		return false
	if slot.is_reserved_final() and action == GameEnums.RoundAction.APPOINTMENT:
		return false
	slot.round_action = action
	slot.order_id = order_id_
	sync_rounds_left()
	return true


## Lock: crafts_done counts finished pieces, not whole orders (docs/20).
func count_finished_piece() -> bool:
	if crafts_done >= crafts_max:
		return false
	crafts_done += 1
	return true


func can_open_piece() -> bool:
	return crafts_done < crafts_max


func advance_round() -> bool:
	if not GameConstants.is_schedule_round(round_index):
		return false
	if round_index >= GameConstants.CHAPTER_ROUND_COUNT:
		return false
	round_index += 1
	return true


func to_dict() -> Dictionary:
	var pin_rows: Array = []
	for pin in appointment_pins:
		pin_rows.append(pin.to_dict())
	var round_rows: Array = []
	for slot in rounds:
		round_rows.append(slot.to_dict())
	return {
		"player_owner_id": player_owner_id,
		"chapter_id": chapter_id,
		"chapter_boss_id": chapter_boss_id,
		"boss_pool_id": boss_pool_id,
		"CHAPTER_ROUND_COUNT": GameConstants.CHAPTER_ROUND_COUNT,
		"round_index": null if round_index == GameConstants.NULL_INT else round_index,
		"rounds_left": rounds_left,
		"round_action": GameEnums.round_action_wire(current_round_action()),
		"appointment_pins": pin_rows,
		"rounds": round_rows,
		"appt_decline_used": appt_decline_used,
		"crafts_done": crafts_done,
		"crafts_max": crafts_max,
	}


func schema_errors() -> PackedStringArray:
	var errs := PackedStringArray()
	if player_owner_id != GameConstants.PHASE1_OWNER_ID:
		errs.append("player_owner_id must be %s in Phase-1" % GameConstants.PHASE1_OWNER_ID)
	if chapter_id < 1 or chapter_id > GameConstants.CHAPTERS_PER_RUN:
		errs.append("chapter_id %d not in 1..%d" % [chapter_id, GameConstants.CHAPTERS_PER_RUN])
	if rounds.size() != GameConstants.CHAPTER_ROUND_COUNT:
		errs.append("rounds size %d != CHAPTER_ROUND_COUNT %d" % [rounds.size(), GameConstants.CHAPTER_ROUND_COUNT])
	if round_index != GameConstants.NULL_INT and not GameConstants.is_schedule_round(round_index):
		errs.append("round_index %d not in 1..8" % round_index)
	var pin_n := appointment_pins.size()
	if pin_n < GameConstants.APPOINTMENT_PIN_MIN or pin_n > GameConstants.APPOINTMENT_PIN_MAX:
		errs.append("appointment_pins length %d not in 2..4" % pin_n)
	var seen_pin_rounds := {}
	var seen_pin_ids := {}
	for pin in appointment_pins:
		errs.append_array(pin.schema_errors())
		if seen_pin_rounds.has(pin.pinned_round):
			errs.append("duplicate appointment pin on round %d" % pin.pinned_round)
		seen_pin_rounds[pin.pinned_round] = true
		if seen_pin_ids.has(pin.appointment_id):
			errs.append("duplicate appointment_id %s" % pin.appointment_id)
		seen_pin_ids[pin.appointment_id] = true
	for slot in rounds:
		errs.append_array(slot.schema_errors())
	if crafts_max != GameConstants.CRAFTS_MAX:
		errs.append("crafts_max %d != 4" % crafts_max)
	if crafts_done < 0 or crafts_done > crafts_max:
		errs.append("crafts_done %d out of 0..%d (counts pieces)" % [crafts_done, crafts_max])
	return errs
