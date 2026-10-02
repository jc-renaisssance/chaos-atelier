class_name MissionResolver
extends RefCounted
## Mission result (docs/23, 24). Simple deterministic sim — not a stub.
## cleared = (hp_remaining > 0) ∧ rating ∈ {S,A,B,C}. Newspaper copy Later.


static func cant_craft_result() -> Dictionary:
	## docs/20 assert 18 / docs/24: F, hp>0, aid 0, cleared false. No session.
	return {
		"tag_counts": {},
		"craft_rarity": GameEnums.CraftRarity.NONE,
		"powers_positive": PackedStringArray(),
		"powers_negative": PackedStringArray(),
		"outlook_id": "plain",
		"outlook_order": 0,
		"stats": GearStats.new(),
		"rating": GameEnums.Rating.F,
		"hp_remaining": 1.0,
		"damage_aid_pct": 0,
		"skill_effectiveness": 1,
		"cleared": false,
		"mission_failed": true,
		"outcome": GameEnums.Outcome.LOSE,
		"favor_tags_hit": PackedStringArray(),
		"punish_tags_hit": PackedStringArray(),
		"unique_id": "",
		"cant_craft": true,
		"mission_stub": false,
		"letter_id": "",
		"rating_score": 0,
		"cards_played_n": 0,
	}


static func combine_pieces(piece_results: Array) -> Dictionary:
	var bag := {}
	var stats := GearStats.new()
	var positives: PackedStringArray = PackedStringArray()
	var negatives: PackedStringArray = PackedStringArray()
	var rarity := GameEnums.CraftRarity.COMMON
	var outlook_id := "plain"
	var outlook_order := 0
	var cards_n := 0
	var uniq := ""
	if piece_results.is_empty():
		return {
			"tag_counts": bag,
			"craft_rarity": GameEnums.CraftRarity.NONE,
			"powers_positive": positives,
			"powers_negative": negatives,
			"outlook_id": outlook_id,
			"outlook_order": outlook_order,
			"stats": stats,
			"unique_id": "",
			"cards_played_n": 0,
		}
	for result in piece_results:
		_merge_tags(bag, Dictionary(result.get("tag_counts", {})))
		var piece_stats: GearStats = result.get("stats", null)
		if piece_stats != null:
			stats.add_bag(piece_stats.to_dict())
		_merge_ids(positives, result.get("powers_positive", PackedStringArray()))
		_merge_ids(negatives, result.get("powers_negative", PackedStringArray()))
		rarity = _max_rarity(rarity, result.get("craft_rarity", GameEnums.CraftRarity.NONE))
		var order := int(result.get("outlook_order", 0))
		if order > outlook_order:
			outlook_order = order
			outlook_id = String(result.get("outlook_id", "plain"))
		cards_n += int(result.get("cards_played_n", 0))
		var u := String(result.get("unique_id", ""))
		if u != "":
			uniq = u
	return {
		"tag_counts": bag,
		"craft_rarity": rarity,
		"powers_positive": positives,
		"powers_negative": negatives,
		"outlook_id": outlook_id if not outlook_id.is_empty() else "plain",
		"outlook_order": outlook_order,
		"stats": stats,
		"unique_id": uniq,
		"cards_played_n": cards_n,
	}


static func grade_piece(craft: Dictionary, order: ClientOrder) -> Dictionary:
	var threat_id := ""
	var kind := GameEnums.MissionKind.PREP
	var difficulty := 1
	if order != null:
		threat_id = order.threat_id
		kind = order.mission_kind
		if order.card_difficulty != GameConstants.NULL_INT:
			difficulty = order.card_difficulty
	return attach(craft, threat_id, kind, difficulty, false)


static func resolve_order(piece_results: Array, order: ClientOrder) -> Dictionary:
	var gear := combine_pieces(piece_results)
	return grade_piece(gear, order)


static func resolve_boss(piece_results: Array, boss_id: String) -> Dictionary:
	var gear := combine_pieces(piece_results)
	return attach(gear, boss_id, GameEnums.MissionKind.BOSS, 3, true)


static func attach(
	craft: Dictionary,
	threat_id: String,
	kind: GameEnums.MissionKind,
	difficulty: int,
	is_boss: bool
) -> Dictionary:
	var out := craft.duplicate(true)
	if out.get("stats", null) == null:
		out["stats"] = GearStats.new()
	var stats: GearStats = out["stats"]
	var bag: Dictionary = Dictionary(out.get("tag_counts", {}))
	var empty := int(out.get("cards_played_n", 0)) == 0
	if kind == GameEnums.MissionKind.PREP:
		## Ready-rack: still grade the garment. No live client pressure (docs/20).
		threat_id = ""
	## Favor / punish come from the announced boss row (docs/17). C2/C3 rows de-favor
	## own_basic starter tags (Soft, Earth, Metal, Wild, Silk, Pure). Job requirement
	## tags (docs/28) are a separate order-taste axis — not this bag.
	var favor := _hits(bag, ThreatCatalog.favor_tags(threat_id)) if threat_id != "" else PackedStringArray()
	var punish := _hits(bag, ThreatCatalog.punish_tags(threat_id)) if threat_id != "" else PackedStringArray()
	var negatives: PackedStringArray = PackedStringArray(out.get("powers_negative", PackedStringArray()))
	var positives: PackedStringArray = PackedStringArray(out.get("powers_positive", PackedStringArray()))
	var rarity = out.get("craft_rarity", GameEnums.CraftRarity.NONE)
	var soak := float(maxi(0, stats.HP + stats.DEF + stats.RES))
	var punch := float(maxi(0, stats.ATK)) + float(maxi(0, stats.MOB)) * 0.35 + float(maxi(0, stats.PRE)) * 0.35
	var pressure := _pressure(difficulty, is_boss, kind)
	var soak_ratio := clampf(soak / float(8 + 2 * maxi(difficulty, 1)), 0.0, 0.55)
	var favor_n := favor.size()
	var punish_n := punish.size()
	var neg_n := negatives.size()
	var empty_pen := 0.22 if empty and kind != GameEnums.MissionKind.PREP else 0.0
	var hp := clampf(
		1.0 - pressure + soak_ratio + 0.08 * float(favor_n) - 0.12 * float(punish_n) - 0.07 * float(neg_n) - empty_pen,
		0.0,
		1.0
	)
	if kind == GameEnums.MissionKind.PREP:
		hp = 1.0
	var aid := 0
	if not empty:
		aid = clampi(int(round(punch * 8.0 + 6.0 * float(positives.size()) + 12.0 * float(favor_n))), 0, 100)
	var stars := _stars(stats, positives.size(), rarity, empty)
	var score := (
		hp * 42.0
		+ float(aid) * 0.32
		+ float(stars) * 5.0
		+ _rarity_bonus(rarity)
		+ 5.0 * float(favor_n)
		- 7.0 * float(punish_n)
		- 6.0 * float(neg_n)
	)
	if kind == GameEnums.MissionKind.PREP and empty:
		score = mini(score, 30.0)
	var rating := _letter(score, hp, empty, false)
	var cleared := hp > 0.0 and GameEnums.rating_clears(rating)
	var failed := not cleared
	var outcome := GameEnums.Outcome.WIN
	if not cleared:
		if hp <= 0.0 or rating == GameEnums.Rating.F:
			outcome = GameEnums.Outcome.LOSE
		else:
			outcome = GameEnums.Outcome.MIXED
	out["rating"] = rating
	out["hp_remaining"] = hp
	out["damage_aid_pct"] = aid
	out["skill_effectiveness"] = stars
	out["cleared"] = cleared
	out["mission_failed"] = failed
	out["outcome"] = outcome
	out["favor_tags_hit"] = favor
	out["punish_tags_hit"] = punish
	out["cant_craft"] = false
	out["mission_stub"] = false
	out["letter_id"] = _letter_id(rarity, negatives, is_boss, cleared, rating)
	out["rating_score"] = clampi(int(round(score)), 0, 100)
	return out


static func piece_is_empty(craft: Dictionary) -> bool:
	if int(craft.get("cards_played_n", 0)) > 0:
		return false
	var stats: GearStats = craft.get("stats", null)
	if stats != null and (stats.HP + stats.ATK + stats.DEF + stats.RES + stats.MOB + stats.PRE) > 2:
		return false
	return true


static func derive_cleared(hp_remaining: float, rating: GameEnums.Rating) -> bool:
	return hp_remaining > 0.0 and GameEnums.rating_clears(rating)


static func _pressure(difficulty: int, is_boss: bool, kind: GameEnums.MissionKind) -> float:
	if kind == GameEnums.MissionKind.PREP:
		return 0.0
	if is_boss:
		return 0.84
	match clampi(difficulty, 1, 3):
		1:
			return 0.28
		3:
			return 0.52
		_:
			return 0.40


static func _rarity_bonus(rarity: GameEnums.CraftRarity) -> float:
	match rarity:
		GameEnums.CraftRarity.LEGENDARY:
			return 18.0
		GameEnums.CraftRarity.RARE:
			return 12.0
		GameEnums.CraftRarity.UNCOMMON:
			return 6.0
		_:
			return 0.0


static func _stars(
	stats: GearStats,
	pos_n: int,
	rarity: GameEnums.CraftRarity,
	empty: bool
) -> int:
	if empty:
		return 1
	var n := 2
	if stats != null:
		if stats.MOB > 0:
			n += 1
		if stats.PRE > 0:
			n += 1
	if pos_n > 0 or rarity == GameEnums.CraftRarity.RARE or rarity == GameEnums.CraftRarity.LEGENDARY:
		n += 1
	return clampi(n, 1, 5)


static func _letter(score: float, hp: float, empty: bool, cant: bool) -> GameEnums.Rating:
	if cant:
		return GameEnums.Rating.F
	if hp <= 0.0:
		return GameEnums.Rating.F
	if empty:
		return GameEnums.Rating.D
	if score >= 82.0:
		return GameEnums.Rating.S
	if score >= 68.0:
		return GameEnums.Rating.A
	if score >= 54.0:
		return GameEnums.Rating.B
	if score >= 40.0:
		return GameEnums.Rating.C
	if score >= 24.0:
		return GameEnums.Rating.D
	return GameEnums.Rating.F


static func _hits(bag: Dictionary, wanted: PackedStringArray) -> PackedStringArray:
	var out := PackedStringArray()
	for tag in wanted:
		if int(bag.get(tag, 0)) > 0:
			out.append(tag)
	return out


static func _merge_tags(bag: Dictionary, other: Dictionary) -> void:
	for tag in other.keys():
		bag[tag] = int(bag.get(tag, 0)) + int(other[tag])


static func _merge_ids(into: PackedStringArray, extra) -> void:
	for item in extra:
		var id := String(item)
		if id != "" and not (id in into):
			into.append(id)


static func _max_rarity(a: GameEnums.CraftRarity, b: GameEnums.CraftRarity) -> GameEnums.CraftRarity:
	if _rarity_rank(b) > _rarity_rank(a):
		return b
	return a


static func _rarity_rank(rarity: GameEnums.CraftRarity) -> int:
	match rarity:
		GameEnums.CraftRarity.LEGENDARY:
			return 4
		GameEnums.CraftRarity.RARE:
			return 3
		GameEnums.CraftRarity.UNCOMMON:
			return 2
		GameEnums.CraftRarity.COMMON:
			return 1
		_:
			return 0


static func _letter_id(
	rarity: GameEnums.CraftRarity,
	negatives: PackedStringArray,
	is_boss: bool,
	cleared: bool,
	rating: GameEnums.Rating
) -> String:
	if negatives.size() > 0:
		return GameConstants.LETTER_NEG_COMPLAINT
	if rarity == GameEnums.CraftRarity.LEGENDARY:
		return GameConstants.LETTER_LEG_AWE
	if rarity == GameEnums.CraftRarity.RARE:
		return GameConstants.LETTER_RARE_IMPRESSED
	if is_boss and cleared and (rating == GameEnums.Rating.S or rating == GameEnums.Rating.A):
		return GameConstants.LETTER_BOSS_VICTORY
	return ""
