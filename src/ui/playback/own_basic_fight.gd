extends RefCounted
## docs/39 kits on the one combined fight. No class_name — callers preload this file.
## Vignettes stay PlaybackBeats. hp_remaining stays the report field.
## No RNG. Both units start at 12 HP. Incoming default is 3. Burn stacks have no cap.


const HP_START := 12
const INCOMING := 3


static func kits_live(pieces: Array) -> bool:
	if pieces.is_empty():
		return false
	var num := _numbers(_combined(pieces), pieces)
	if int(num["apply"]) > 0 or int(num["metal_dmg"]) > 0 or int(num["silk_bonus"]) > 0:
		return true
	if int(num["earth_cut"]) > 0 or bool(num["earth_apex"]):
		return true
	if int(num["heal"]) > 0 or bool(num["adv_first"]):
		return true
	if int(num["open_burn"]) > 0 or int(num["open_chip"]) > 0:
		return true
	if int(num["charges"]) > 0 or bool(num["tick_plus"]):
		return true
	return false


## foe_1_incoming stays 3 on the player fight. Count 2 labels 12 on foe_1 only.
static func build(pieces: Array, foe_1_incoming: int = INCOMING) -> Array:
	var num := _numbers(_combined(pieces), pieces)
	var rows: Array = []
	for tag in ["Fire", "Soft", "Earth", "Metal", "Silk"]:
		var tier := int(num["tier_%s" % tag])
		if tier >= 3:
			_row(rows, "ascend", "in_fight", "%s %d" % [tag, tier])
	var state := {
		"adv_hp": HP_START,
		"foe_hp": HP_START,
		"adv_burn": 0,
		"foe_burn": 0,
		"charges": int(num["charges"]),
		"fire_applied": false,
		"earth_used": false,
		"tick_plus_used": false,
	}
	_row(rows, "open", "in_fight", "Charges %d" % int(state["charges"]))
	_row(rows, "open", "in_fight", "Adventurer HP %d" % HP_START)
	_row(rows, "open", "in_fight", "Foe HP %d" % HP_START)
	_row(rows, "open", "in_fight", "Burn counters 0")
	if int(num["open_burn"]) > 0:
		var gained := int(num["open_burn"])
		state["adv_burn"] = int(state["adv_burn"]) + gained
		_row(rows, "counter", "in_fight", "Counter %d" % int(state["adv_burn"]))
	var chips := int(num["open_chip"])
	while chips > 0:
		chips -= 1
		var before := int(state["adv_hp"])
		state["adv_hp"] = before - 1
		_row(rows, "chip", "defend", "1")
		_row(rows, "hp", "defend", "Adventurer HP %d → %d" % [before, int(state["adv_hp"])])
	var heal := int(num["heal"])
	if heal >= 1:
		var hp_before := int(state["adv_hp"])
		state["adv_hp"] = hp_before + heal
		_row(rows, "heal", "in_fight", "Heal pop %d" % heal)
		_row(rows, "hp", "in_fight", "Adventurer HP %d → %d" % [hp_before, int(state["adv_hp"])])
		if int(state["adv_burn"]) > 0:
			var stacks := int(state["adv_burn"])
			state["adv_burn"] = stacks - 1
			_row(rows, "counter", "in_fight", "Counter %d → %d" % [stacks, stacks - 1])
	if bool(num["adv_first"]):
		_adventurer(rows, state, 1, num)
		_foe(rows, state, foe_1_incoming, num)
		_adventurer(rows, state, 2, num)
		_foe(rows, state, INCOMING, num)
	else:
		_foe(rows, state, foe_1_incoming, num)
		_adventurer(rows, state, 1, num)
		_foe(rows, state, INCOMING, num)
		_adventurer(rows, state, 2, num)
	return rows


static func survive_charges(pieces: Array) -> int:
	## N = pieces whose own Fire is ≥ 8. The combined sum does not mint a charge.
	var n := 0
	for piece in pieces:
		if not (piece is Dictionary):
			continue
		if _count(_bag(piece), "Fire") >= 8:
			n += 1
	return n


static func _numbers(bag: Dictionary, pieces: Array) -> Dictionary:
	var fire := _count(bag, "Fire")
	var soft := _count(bag, "Soft")
	var earth := _count(bag, "Earth")
	var metal := _count(bag, "Metal")
	var silk := _count(bag, "Silk")
	var skip := _skip_neg(pieces)
	var cloak := _any_cloak(pieces)
	var apply := 0
	if fire >= 8:
		apply = 4
	elif fire >= 5:
		apply = 3
	elif fire >= 3:
		apply = 2
	## Metal apex adds 1 on that Fire apply. No apply yet → no rider.
	if apply > 0 and metal >= 8:
		apply += 1
	if fire >= 1 and metal >= 1:
		apply += 1
	var metal_dmg := 0
	if metal >= 5:
		metal_dmg = 4
	elif metal >= 3:
		metal_dmg = 2
	if soft >= 1 and metal >= 1:
		metal_dmg += 1
	if not skip and cloak and metal >= 1:
		metal_dmg = 0
	var silk_bonus := 0
	if silk >= 8:
		silk_bonus = 2
	elif silk >= 5:
		silk_bonus = 1
	if soft >= 1 and silk >= 1:
		silk_bonus += 1
	var earth_cut := 0
	if earth >= 5:
		earth_cut = 4
	elif earth >= 3:
		earth_cut = 2
	if earth >= 1 and metal >= 1:
		earth_cut += 1
	if earth >= 1 and silk >= 1:
		earth_cut += 1
	var heal := 0
	if soft >= 5:
		heal = 3
	elif soft >= 3:
		heal = 2
	if not skip and fire >= 1 and soft >= 1:
		heal = heal // 2
	var adv_first := silk >= 3
	if not skip and metal >= 3 and silk >= 3:
		adv_first = false
	var open_burn := 0
	var open_chip := 0
	if not skip and fire >= 1 and soft >= 1:
		open_burn = 1
	if not skip and metal >= 3 and silk >= 3:
		open_chip += 1
	if not skip and cloak and metal >= 1:
		open_chip += 1
	return {
		"apply": apply,
		"metal_dmg": metal_dmg,
		"silk_bonus": silk_bonus,
		"earth_cut": earth_cut,
		"earth_apex": earth >= 8,
		"heal": heal,
		"adv_first": adv_first,
		"open_burn": open_burn,
		"open_chip": open_chip,
		"tick_plus": fire >= 1 and earth >= 1,
		"charges": survive_charges(pieces),
		"tier_Fire": _met(fire),
		"tier_Soft": _met(soft),
		"tier_Earth": _met(earth),
		"tier_Metal": _met(metal),
		"tier_Silk": _met(silk),
	}


static func _adventurer(rows: Array, state: Dictionary, which: int, num: Dictionary) -> void:
	_tick(rows, state, "adv", bool(num["tick_plus"]))
	if which != 1:
		return
	var apply := int(num["apply"])
	if apply > 0:
		var old := int(state["foe_burn"])
		## Uncapped. A later apply that reaches 6 stays 6.
		state["foe_burn"] = old + apply
		state["fire_applied"] = true
		_row(rows, "apply", "attack", "Apply %d" % apply)
		if old == 0:
			_row(rows, "counter", "attack", "Counter %d" % int(state["foe_burn"]))
		else:
			_row(rows, "counter", "attack", "Counter %d → %d" % [old, int(state["foe_burn"])])
	var metal_dmg := int(num["metal_dmg"])
	if metal_dmg > 0:
		var before := int(state["foe_hp"])
		state["foe_hp"] = before - metal_dmg
		_row(rows, "damage", "attack", "Metal damage %d" % metal_dmg)
		_row(rows, "hp", "attack", "Foe HP %d → %d" % [before, int(state["foe_hp"])])
	var silk_bonus := int(num["silk_bonus"])
	if silk_bonus > 0:
		var before_silk := int(state["foe_hp"])
		state["foe_hp"] = before_silk - silk_bonus
		_row(rows, "damage", "attack", "First attack +%d" % silk_bonus)
		_row(rows, "hp", "attack", "Foe HP %d → %d" % [before_silk, int(state["foe_hp"])])


static func _foe(rows: Array, state: Dictionary, amount: int, num: Dictionary) -> void:
	_tick(rows, state, "foe", bool(num["tick_plus"]))
	var shown := amount
	if not bool(state["earth_used"]):
		state["earth_used"] = true
		shown = maxi(0, amount - int(num["earth_cut"]))
		if bool(num["earth_apex"]) and shown >= 1:
			shown = 0
	_row(rows, "incoming", "defend", "Incoming %d" % shown)
	if shown == 0:
		return
	var before := int(state["adv_hp"])
	var would := before - shown
	if before >= 1 and would <= 0:
		if int(state["charges"]) > 0:
			var had := int(state["charges"])
			state["adv_hp"] = 1
			state["charges"] = had - 1
			_row(rows, "survive", "defend", "Survive")
			_row(rows, "hp", "defend", "Adventurer HP %d → 1" % before)
			_row(rows, "charges", "defend", "Charges %d → %d" % [had, had - 1])
		else:
			state["adv_hp"] = 0
			_row(rows, "hp", "defend", "Adventurer HP %d → 0" % before)
		return
	state["adv_hp"] = would
	_row(rows, "hp", "defend", "Adventurer HP %d → %d" % [before, would])


static func _tick(rows: Array, state: Dictionary, unit: String, tick_plus: bool) -> void:
	var burn_key := "%s_burn" % unit
	var hp_key := "%s_hp" % unit
	var stacks := int(state[burn_key])
	if stacks <= 0:
		return
	var dmg := stacks
	if tick_plus and not bool(state["tick_plus_used"]):
		dmg += 1
		state["tick_plus_used"] = true
	var before := int(state[hp_key])
	state[hp_key] = before - dmg
	state[burn_key] = stacks - 1
	var who := "Foe" if unit == "foe" else "Adventurer"
	var slot := "attack" if unit == "foe" else "defend"
	_row(rows, "tick", slot, "Tick %d" % dmg)
	_row(rows, "hp", slot, "%s HP %d → %d" % [who, before, int(state[hp_key])])
	_row(rows, "counter", slot, "Counter %d → %d" % [stacks, stacks - 1])
	if unit != "foe" or not bool(state["fire_applied"]):
		return
	var leech := dmg // 2
	if leech < 1:
		return
	var adv_before := int(state["adv_hp"])
	state["adv_hp"] = adv_before + leech
	_row(rows, "heal", "in_fight", "Heal pop %d" % leech)
	_row(rows, "hp", "in_fight", "Adventurer HP %d → %d" % [adv_before, int(state["adv_hp"])])


static func _combined(pieces: Array) -> Dictionary:
	var bag := {}
	for piece in pieces:
		if not (piece is Dictionary):
			continue
		var part := _bag(piece)
		for key in part.keys():
			bag[key] = int(bag.get(key, 0)) + int(part[key])
	return bag


static func _bag(piece: Dictionary) -> Dictionary:
	var raw: Variant = piece.get("tag_counts", {})
	if raw is Dictionary:
		return raw
	return {}


static func _count(bag: Dictionary, tag: String) -> int:
	return int(bag.get(tag, 0))


static func _met(n: int) -> int:
	if n >= 8:
		return 8
	if n >= 5:
		return 5
	if n >= 3:
		return 3
	return 0


static func _skip_neg(pieces: Array) -> bool:
	for piece in pieces:
		if not (piece is Dictionary):
			continue
		var rarity := int(piece.get("craft_rarity", GameEnums.CraftRarity.COMMON))
		if rarity == GameEnums.CraftRarity.RARE or rarity == GameEnums.CraftRarity.LEGENDARY:
			return true
	return false


static func _any_cloak(pieces: Array) -> bool:
	for piece in pieces:
		if not (piece is Dictionary):
			continue
		if String(piece.get("construction_id", "")) == "con_cloak":
			return true
	return false


static func _row(rows: Array, beat_id: String, slot: String, label: String) -> void:
	rows.append({
		"id": beat_id,
		"slot": slot,
		"label": label,
		"piece_index": -1,
	})
