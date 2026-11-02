extends RefCounted
## Formula-driven own_basic affinity fight (docs/40). No RNG.

const HP_START := 12
const DEFAULT_INCOMING := 3
const DEFAULT_FOE_INITIATIVE := 3
const TAGS := ["Fire", "Soft", "Earth", "Metal", "Silk"]
const STATS := ["HP", "ATK", "DEF", "RES", "MOB", "PRE"]


static func kits_live(pieces: Array) -> bool:
	var affinity := summarize(pieces)
	for tag in TAGS:
		if int(affinity[tag].get("tier", 0)) > 0:
			return true
	return false


static func survive_charges(pieces: Array) -> int:
	return int(summarize(pieces)["Fire"].get("apex_items", 0))


static func build(
	pieces: Array,
	foe_incoming: int = DEFAULT_INCOMING,
	foe_initiative: int = DEFAULT_FOE_INITIATIVE
) -> Array:
	var affinity := summarize(pieces)
	var fire: Dictionary = affinity["Fire"]
	var soft: Dictionary = affinity["Soft"]
	var earth: Dictionary = affinity["Earth"]
	var metal: Dictionary = affinity["Metal"]
	var silk: Dictionary = affinity["Silk"]
	var rows: Array = []
	for tag in TAGS:
		var tier := int(affinity[tag].get("tier", 0))
		if tier > 0:
			_row(rows, "affinity", "in_fight", "%s T%d · %d" % [
				tag,
				tier,
				int(affinity[tag].get("magnitude", 0)),
			])

	var mend := int(soft.get("magnitude", 0)) if int(soft.get("tier", 0)) > 0 else 0
	var mend_reserve := mend
	if int(soft.get("tier", 0)) == 2:
		mend_reserve = int(ceil(float(mend) * 1.5))
	elif int(soft.get("tier", 0)) >= 3:
		mend_reserve = mend * 2
	var flow := int(silk.get("magnitude", 0)) if int(silk.get("tier", 0)) > 0 else 0
	var adventurer_initiative := int(affinity.get("base_MOB", 0)) + flow
	var state := {
		"adv_hp": HP_START,
		"foe_hp": HP_START,
		"adv_burn": 0,
		"foe_burn": 0,
		"survive": int(fire.get("apex_items", 0)),
		"mend_reserve": mend_reserve,
		"mend_first_done": false,
		"ward": 0,
		"root_hits": 0,
		"root_charges": int(earth.get("apex_items", 0)),
		"plate": int(metal.get("magnitude", 0)) if int(metal.get("tier", 0)) > 0 else 0,
		"plate_lost": 0,
		"reforge": int(metal.get("apex_items", 0)),
		"reforge_pending": false,
		"fire_applied": false,
		"flourish": int(silk.get("apex_items", 0)),
	}
	_row(rows, "open", "in_fight", "Adventurer HP %d" % HP_START)
	_row(rows, "open", "in_fight", "Foe HP %d" % HP_START)
	if int(state["plate"]) > 0:
		_row(rows, "plate", "defend", "Plate %d" % int(state["plate"]))
	if int(state["mend_reserve"]) > 0:
		_row(rows, "mend", "defend", "Mend reserve %d" % int(state["mend_reserve"]))
	if int(state["survive"]) > 0:
		_row(rows, "charges", "defend", "Survive %d" % int(state["survive"]))
	if int(earth.get("tier", 0)) >= 3:
		_row(rows, "charges", "defend", "Root %d" % int(state["root_charges"]))
	_row(rows, "initiative", "in_fight", "Initiative %d vs %d" % [
		adventurer_initiative,
		foe_initiative,
	])

	var adv_first := (
		int(silk.get("tier", 0)) > 0
		and adventurer_initiative > foe_initiative
	)
	if adv_first:
		_adventurer(rows, state, 1, affinity, true)
		_foe(rows, state, foe_incoming, affinity)
		_adventurer(rows, state, 2, affinity, true)
		_foe(rows, state, DEFAULT_INCOMING, affinity)
	else:
		_foe(rows, state, foe_incoming, affinity)
		_adventurer(rows, state, 1, affinity, false)
		_foe(rows, state, DEFAULT_INCOMING, affinity)
		_adventurer(rows, state, 2, affinity, false)
	return rows


static func summarize(pieces: Array) -> Dictionary:
	var out := CraftResolver.combine_affinity(pieces)
	out["base_MOB"] = 0
	for piece in pieces:
		if not (piece is Dictionary):
			continue
		var stats: GearStats = piece.get("stats", null)
		if stats != null:
			out["base_MOB"] = int(out["base_MOB"]) + stats.MOB
	return out


static func _adventurer(
	rows: Array,
	state: Dictionary,
	which: int,
	affinity: Dictionary,
	acted_first: bool
) -> void:
	_tick(rows, state, "adv", false)
	var fire: Dictionary = affinity["Fire"]
	var metal: Dictionary = affinity["Metal"]
	var silk: Dictionary = affinity["Silk"]
	if which == 1 and int(fire.get("tier", 0)) > 0:
		var apply := int(fire.get("magnitude", 0))
		var before_burn := int(state["foe_burn"])
		state["foe_burn"] = before_burn + apply
		state["fire_applied"] = true
		_row(rows, "apply", "attack", "Burn +%d · %d → %d" % [
			apply,
			before_burn,
			int(state["foe_burn"]),
		])
	var temper := 0
	if int(metal.get("tier", 0)) >= 2:
		temper = int(state["plate_lost"]) / 2
	state["plate_lost"] = 0
	if temper > 0:
		_damage_foe(rows, state, temper, "Temper")
	if which == 1 and int(silk.get("tier", 0)) >= 2 and acted_first:
		_damage_foe(
			rows,
			state,
			maxi(1, int(ceil(float(silk.get("magnitude", 0)) / 2.0))),
			"Flow"
		)
	if bool(state["reforge_pending"]) and int(state["reforge"]) > 0:
		var restored := maxi(1, int(ceil(float(metal.get("magnitude", 0)) / 3.0)))
		state["plate"] = restored
		state["reforge"] = int(state["reforge"]) - 1
		state["reforge_pending"] = false
		_row(rows, "reforge", "defend", "Plate reforged %d" % restored)
	if which == 2 and int(silk.get("tier", 0)) >= 3 and int(state["flourish"]) > 0:
		state["flourish"] = int(state["flourish"]) - 1
		_damage_foe(rows, state, int(silk.get("magnitude", 0)), "Flourish")


static func _foe(
	rows: Array,
	state: Dictionary,
	amount: int,
	affinity: Dictionary
) -> void:
	var fire: Dictionary = affinity["Fire"]
	var earth: Dictionary = affinity["Earth"]
	var metal: Dictionary = affinity["Metal"]
	var soft: Dictionary = affinity["Soft"]
	var tick_damage := _tick(rows, state, "foe", int(fire.get("tier", 0)) >= 2)
	if tick_damage > 0 and int(fire.get("tier", 0)) >= 2:
		var heal := tick_damage / 2
		if heal > 0:
			_heal_adv(rows, state, heal, "Feed")

	var incoming := maxi(0, amount)
	var earth_tier := int(earth.get("tier", 0))
	var earth_eligible := (
		earth_tier >= 2
		or (earth_tier == 1 and int(state["root_hits"]) == 0)
	)
	if earth_eligible and incoming > 0:
		var cap_ratio := 0.75 if earth_tier >= 3 else 0.50
		var reduced := mini(
			int(earth.get("magnitude", 0)),
			int(floor(float(incoming) * cap_ratio))
		)
		incoming -= reduced
		state["root_hits"] = int(state["root_hits"]) + 1
		_row(rows, "root", "defend", "Root −%d" % reduced)

	if int(state["ward"]) > 0 and incoming > 0:
		var ward_spent := mini(incoming, int(state["ward"]))
		incoming -= ward_spent
		state["ward"] = int(state["ward"]) - ward_spent
		_row(rows, "ward", "defend", "Ward −%d · %d left" % [
			ward_spent,
			int(state["ward"]),
		])
	if int(state["plate"]) > 0 and incoming > 0:
		var plate_spent := mini(incoming, int(state["plate"]))
		incoming -= plate_spent
		state["plate"] = int(state["plate"]) - plate_spent
		state["plate_lost"] = int(state["plate_lost"]) + plate_spent
		_row(rows, "plate", "defend", "Plate −%d · %d left" % [
			plate_spent,
			int(state["plate"]),
		])
		if int(state["plate"]) == 0 and int(metal.get("tier", 0)) >= 3 and int(state["reforge"]) > 0:
			state["reforge_pending"] = true

	_row(rows, "incoming", "defend", "Incoming %d" % incoming)
	if incoming <= 0:
		return
	var before := int(state["adv_hp"])
	var after := before - incoming
	if after <= 0:
		if int(state["survive"]) > 0:
			state["survive"] = int(state["survive"]) - 1
			state["adv_hp"] = 1
			_row(rows, "survive", "defend", "Survive · HP %d → 1" % before)
		else:
			state["adv_hp"] = 0
			_row(rows, "hp", "defend", "Adventurer HP %d → 0" % before)
		return
	state["adv_hp"] = after
	_row(rows, "hp", "defend", "Adventurer HP %d → %d" % [before, after])
	if int(soft.get("tier", 0)) > 0:
		_mend(rows, state, soft)


static func _mend(rows: Array, state: Dictionary, soft: Dictionary) -> void:
	var reserve := int(state["mend_reserve"])
	if reserve <= 0:
		return
	var mend := int(soft.get("magnitude", 0))
	var tier := int(soft.get("tier", 0))
	var allowance := reserve
	if tier == 2:
		allowance = mini(reserve, int(ceil(float(mend) / 2.0)))
	elif tier >= 3:
		allowance = mini(reserve, mend)
	var missing := maxi(0, HP_START - int(state["adv_hp"]))
	var heal := mini(missing, allowance)
	var spent := heal
	var ward_gain := 0
	if tier == 1:
		## Comfort is a one-shot reserve on the first nonlethal enemy hit.
		spent = reserve
	elif tier >= 3:
		spent = allowance
		ward_gain = mini(mend - int(state["ward"]), allowance - heal)
	state["mend_reserve"] = reserve - spent
	if heal > 0:
		_heal_adv(rows, state, heal, "Mend")
	if ward_gain > 0:
		state["ward"] = int(state["ward"]) + ward_gain
		_row(rows, "ward", "defend", "Ward +%d · %d" % [ward_gain, int(state["ward"])])
	if tier >= 3 and not bool(state["mend_first_done"]):
		var cleanse := maxi(1, int(soft.get("intensity", 0)) / 8)
		var removed := mini(cleanse, int(state["adv_burn"]))
		state["adv_burn"] = int(state["adv_burn"]) - removed
		_row(rows, "cleanse", "defend", "Cleanse %d" % removed)
	state["mend_first_done"] = true


static func _tick(
	rows: Array,
	state: Dictionary,
	unit: String,
	_feed_live: bool
) -> int:
	var burn_key := "%s_burn" % unit
	var hp_key := "%s_hp" % unit
	var stacks := int(state[burn_key])
	if stacks <= 0:
		return 0
	var before := int(state[hp_key])
	state[hp_key] = before - stacks
	state[burn_key] = stacks - 1
	var who := "Foe" if unit == "foe" else "Adventurer"
	var slot := "attack" if unit == "foe" else "defend"
	_row(rows, "tick", slot, "%s Burn %d · HP %d → %d" % [
		who,
		stacks,
		before,
		int(state[hp_key]),
	])
	return stacks


static func _heal_adv(
	rows: Array,
	state: Dictionary,
	amount: int,
	source: String
) -> void:
	if amount <= 0:
		return
	var before := int(state["adv_hp"])
	state["adv_hp"] = mini(HP_START, before + amount)
	_row(rows, "heal", "defend", "%s +%d · HP %d → %d" % [
		source,
		int(state["adv_hp"]) - before,
		before,
		int(state["adv_hp"]),
	])


static func _damage_foe(
	rows: Array,
	state: Dictionary,
	amount: int,
	source: String
) -> void:
	if amount <= 0:
		return
	var before := int(state["foe_hp"])
	state["foe_hp"] = before - amount
	_row(rows, "damage", "attack", "%s %d · HP %d → %d" % [
		source,
		amount,
		before,
		int(state["foe_hp"]),
	])


static func _row(rows: Array, beat_id: String, slot: String, label: String) -> void:
	rows.append({
		"id": beat_id,
		"slot": slot,
		"label": label,
		"piece_index": -1,
	})
