class_name CraftPlayCosts
extends Resource
## Per-piece stamina knobs + play costs (docs/27). Infinite monostack — no max_materials / max_runes.

@export var stamina_start: int = 12
@export var hand_size: int = 5
@export var dig_refresh_cost: int = 2
@export var common_mat: int = 1
@export var uncommon_mat: int = 2
@export var rare_mat: int = 3
@export var enchantment: int = 2
@export var auto_refill: bool = false


func matches_phase1() -> bool:
	return (
		stamina_start == GameConstants.STAMINA_START
		and hand_size == GameConstants.HAND_SIZE
		and dig_refresh_cost == GameConstants.DIG_REFRESH_COST
		and common_mat == GameConstants.MAT_PLAY_COST_COMMON
		and uncommon_mat == GameConstants.MAT_PLAY_COST_UNCOMMON
		and rare_mat == GameConstants.MAT_PLAY_COST_RARE
		and enchantment == GameConstants.ENC_PLAY_COST
		and auto_refill == GameConstants.HAND_AUTO_REFILL
	)


func material_cost(rarity: GameEnums.CraftRarity) -> int:
	match rarity:
		GameEnums.CraftRarity.UNCOMMON:
			return uncommon_mat
		GameEnums.CraftRarity.RARE, GameEnums.CraftRarity.LEGENDARY:
			return rare_mat
		_:
			return common_mat
