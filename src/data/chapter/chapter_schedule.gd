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


func current_round() -> ScheduleRound:
	if not GameConstants.is_schedule_round(round_index):
		return null
	for slot in rounds:
		if slot.round_index == round_index:
			return slot
	return null


func current_round_action() -> GameEnums.RoundAction:
	var slot := current_round()
	if slot == null:
		return GameEnums.RoundAction.NONE
	return slot.round_action


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
	for pin in appointment_pins:
		errs.append_array(pin.schema_errors())
	for slot in rounds:
		errs.append_array(slot.schema_errors())
	if crafts_max != GameConstants.CRAFTS_MAX:
		errs.append("crafts_max %d != 4" % crafts_max)
	if crafts_done < 0 or crafts_done > crafts_max:
		errs.append("crafts_done %d out of 0..%d (counts pieces)" % [crafts_done, crafts_max])
	return errs
