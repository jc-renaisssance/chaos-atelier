extends Node
## Phase-1 bible numbers. Docs 22 / 27 / 20 / 14. Not a resolver or loop.
## Autoload singleton is already named GameConstants — do not add class_name
## (Godot 4.7 hides the autoload behind the named class and fails to compile).

const SCHEMA_SLICE := "1B"
const PHASE1_OWNER_ID := "own_basic"

## docs/22 — travelling atelier schedule board (not a path map, not 1-of-3 lineup).
const CHAPTERS_PER_RUN := 3
const CHAPTER_ROUND_COUNT := 8
const CRAFTS_MAX := 4 ## lock: crafts_done / crafts_max=4 counts pieces, not orders (armor+gloves = 2 of 4)
const APPOINTMENT_PIN_MIN := 2
const APPOINTMENT_PIN_MAX := 4
const RESERVED_FINAL_ROUND_COUNT := 2
const APPOINTMENT_PIN_ROUND_MIN := 1
const APPOINTMENT_PIN_ROUND_MAX := 6 ## last 2 rounds (7–8) cannot take pins
const PRIMARY_ACTIONS_PER_ROUND := 1

## docs/27 — stamina craft (replaces 2m1r). Per-piece session knobs.
const STAMINA_START := 12
const HAND_SIZE := 5
const DIG_REFRESH_COST := 2
const MAT_PLAY_COST_COMMON := 1
const MAT_PLAY_COST_UNCOMMON := 2
const MAT_PLAY_COST_RARE := 3
const ENC_PLAY_COST := 2
const HAND_AUTO_REFILL := false ## dig dumps hand → discard then draws; empty hand is legal

## docs/14 — retuned thresholds. Gen-list outlook ids stay _2/_3 through 1C.
const SYN_THRESHOLD_TIER_1 := 3 ## old ≥2
const SYN_THRESHOLD_TIER_2 := 5 ## old ≥3
const SYN_THRESHOLD_APEX := 8 ## Fire · Metal · Earth only
const SYN_CROSS_TAG_MIN := 1
const SYN_APEX_TAGS := ["Fire", "Metal", "Earth"]

## Nullable int/float sentinels on Resources (Godot has no Option).
const NULL_INT := -1
const NULL_FLOAT := -1.0

## docs/17 — three chapter pools kept. Schema ids only; no boss loop.
const BOSS_POOL_IDS := {
	1: "pool_c1_outer_holdings",
	2: "pool_c2_mire_chapel",
	3: "pool_c3_marble_court",
}
const BOSS_POOLS := {
	1: ["boss_ash_drake", "boss_salt_widow", "boss_rust_knave"],
	2: ["boss_mire_bride", "boss_bog_king", "boss_pale_choir"],
	3: ["boss_gilded_warden", "boss_ivory_judge", "boss_sunspear_captain"],
}

## docs/27 draft owner skills — costs only, no effects.
const OWNER_SKILL_DRAFT_COSTS := {
	"sk_next_mat_free": 1,
	"sk_metal_str_double": 2,
	"sk_wild_to_earth": 2,
	"sk_touch_up": 1,
	"sk_deep_dig": 3,
	"sk_steady_hand": 1,
}

## docs/25 algorithm is live; C1=8 / C2=14 / C3=20 still track the old 3-round shell.
const REPS_START := 0
const REPS_GATE_STUB := 0

## Newspaper / letter chrome ids (docs/26, 23). Copy tables Later; ids stable for harness.
const HEADLINE_BOSS_ANNOUNCE := "hd_boss_announce"
const HEADLINE_MID_FAIL := "hd_mid_fail"
const HEADLINE_CHAPTER_RESULT := "hd_chapter_result"
const HEADLINE_RUN_OVER := "hd_run_over"
const LETTER_NEG_COMPLAINT := "let_neg_complaint"
const LETTER_RARE_IMPRESSED := "let_rare_impressed"
const LETTER_LEG_AWE := "let_leg_awe"
const LETTER_BOSS_VICTORY := "let_boss_victory"


static func is_appointment_pin_round(round_index: int) -> bool:
	return round_index >= APPOINTMENT_PIN_ROUND_MIN and round_index <= APPOINTMENT_PIN_ROUND_MAX


static func is_reserved_final_round(round_index: int) -> bool:
	return (
		round_index > APPOINTMENT_PIN_ROUND_MAX
		and round_index <= CHAPTER_ROUND_COUNT
	)


static func is_schedule_round(round_index: int) -> bool:
	return round_index >= 1 and round_index <= CHAPTER_ROUND_COUNT


static func material_play_cost(rarity: GameEnums.CraftRarity) -> int:
	match rarity:
		GameEnums.CraftRarity.UNCOMMON:
			return MAT_PLAY_COST_UNCOMMON
		GameEnums.CraftRarity.RARE, GameEnums.CraftRarity.LEGENDARY:
			return MAT_PLAY_COST_RARE
		_:
			return MAT_PLAY_COST_COMMON


static func play_cost_for_type(card_type: GameEnums.HandCardType, mat_rarity: GameEnums.CraftRarity = GameEnums.CraftRarity.COMMON) -> int:
	match card_type:
		GameEnums.HandCardType.RUNE:
			return ENC_PLAY_COST
		GameEnums.HandCardType.SKILL:
			return NULL_INT ## skill costs are per-id (OWNER_SKILL_DRAFT_COSTS)
		_:
			return material_play_cost(mat_rarity)
