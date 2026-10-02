class_name GameEnums
extends RefCounted
## Wire enums for schedule + stamina + stamp. No lineup / shop / craft_task phases.

enum RoundAction {
	NONE,
	APPOINTMENT,
	WALK_IN,
	WAGON_SHOP,
	WAGON_EVENT,
	PREP_CRAFT,
	REST_DIG,
}

enum StampPhase {
	SCHEDULE,
	CRAFT,
	BOSS,
	NEWSPAPER,
}

enum MissionKind {
	NONE,
	ORDER,
	EVENT,
	BOSS,
	PREP,
}

## Hand / cards_played only. Construction is order-fixed — never a card type.
## Consumable is Later (round-generated, burns on use) — not in this stamp enum.
enum HandCardType {
	MATERIAL,
	RUNE,
	SKILL,
}

enum FinishReason {
	NONE,
	STAMINA_0,
	EARLY_FINISH,
}

enum CraftRarity {
	NONE,
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
}

enum Rating {
	NONE,
	S,
	A,
	B,
	C,
	D,
	F,
}

enum Outcome {
	NONE,
	WIN,
	LOSE,
	MIXED,
}

enum NewspaperEvent {
	NONE,
	BOSS_ANNOUNCE,
	MID_FAIL,
	CHAPTER_RESULT,
	RUN_OVER,
}

enum RunOverReason {
	NONE,
	REPS_GATE_MISS,
	BOSS_DEATH,
}

const ROUND_ACTION_WIRE := {
	RoundAction.APPOINTMENT: "appointment",
	RoundAction.WALK_IN: "walk_in",
	RoundAction.WAGON_SHOP: "wagon_shop",
	RoundAction.WAGON_EVENT: "wagon_event",
	RoundAction.PREP_CRAFT: "prep_craft",
	RoundAction.REST_DIG: "rest_dig",
}

const STAMP_PHASE_WIRE := {
	StampPhase.SCHEDULE: "schedule",
	StampPhase.CRAFT: "craft",
	StampPhase.BOSS: "boss",
	StampPhase.NEWSPAPER: "newspaper",
}

const MISSION_KIND_WIRE := {
	MissionKind.ORDER: "order",
	MissionKind.EVENT: "event",
	MissionKind.BOSS: "boss",
	MissionKind.PREP: "prep",
}

const HAND_CARD_TYPE_WIRE := {
	HandCardType.MATERIAL: "material",
	HandCardType.RUNE: "rune",
	HandCardType.SKILL: "skill",
}

const FINISH_REASON_WIRE := {
	FinishReason.STAMINA_0: "stamina_0",
	FinishReason.EARLY_FINISH: "early_finish",
}

const CRAFT_RARITY_WIRE := {
	CraftRarity.COMMON: "common",
	CraftRarity.UNCOMMON: "uncommon",
	CraftRarity.RARE: "rare",
	CraftRarity.LEGENDARY: "legendary",
}

const RATING_WIRE := {
	Rating.S: "S",
	Rating.A: "A",
	Rating.B: "B",
	Rating.C: "C",
	Rating.D: "D",
	Rating.F: "F",
}

const OUTCOME_WIRE := {
	Outcome.WIN: "win",
	Outcome.LOSE: "lose",
	Outcome.MIXED: "mixed",
}

const NEWSPAPER_EVENT_WIRE := {
	NewspaperEvent.BOSS_ANNOUNCE: "boss_announce",
	NewspaperEvent.MID_FAIL: "mid_fail",
	NewspaperEvent.CHAPTER_RESULT: "chapter_result",
	NewspaperEvent.RUN_OVER: "run_over",
}

const RUN_OVER_REASON_WIRE := {
	RunOverReason.REPS_GATE_MISS: "reps_gate_miss",
	RunOverReason.BOSS_DEATH: "boss_death",
}


static func _wire_or_null(table: Dictionary, key: int, none_value: int) -> Variant:
	if key == none_value:
		return null
	return table.get(key, null)


static func round_action_wire(value: RoundAction) -> Variant:
	return _wire_or_null(ROUND_ACTION_WIRE, value, RoundAction.NONE)


static func stamp_phase_wire(value: StampPhase) -> String:
	return STAMP_PHASE_WIRE[value]


static func mission_kind_wire(value: MissionKind) -> Variant:
	return _wire_or_null(MISSION_KIND_WIRE, value, MissionKind.NONE)


static func hand_card_type_wire(value: HandCardType) -> String:
	return HAND_CARD_TYPE_WIRE[value]


static func finish_reason_wire(value: FinishReason) -> Variant:
	return _wire_or_null(FINISH_REASON_WIRE, value, FinishReason.NONE)


static func craft_rarity_wire(value: CraftRarity) -> Variant:
	return _wire_or_null(CRAFT_RARITY_WIRE, value, CraftRarity.NONE)


static func rating_wire(value: Rating) -> Variant:
	return _wire_or_null(RATING_WIRE, value, Rating.NONE)


static func outcome_wire(value: Outcome) -> Variant:
	return _wire_or_null(OUTCOME_WIRE, value, Outcome.NONE)


static func newspaper_event_wire(value: NewspaperEvent) -> Variant:
	return _wire_or_null(NEWSPAPER_EVENT_WIRE, value, NewspaperEvent.NONE)


static func run_over_reason_wire(value: RunOverReason) -> Variant:
	return _wire_or_null(RUN_OVER_REASON_WIRE, value, RunOverReason.NONE)


static func rating_clears(value: Rating) -> bool:
	return value == Rating.S or value == Rating.A or value == Rating.B or value == Rating.C
