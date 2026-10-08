class_name EstimateLaw
extends RefCounted
## Slice 3 deterministic estimate (docs/30). Test knobs — not a locked cutoff table.
## No RNG. Planned chips + construction tags vs docs/17 favor / punish.
## Do not assert estimate band == post-sim rating (bags ≠ planned chips).

## Test knobs (LOCKED leave-as-knobs, Jonathan 2026-10-08).
const FAVOR_W := 2
const PUNISH_W := 3
const SKILL_W := 2
const NEG_W := 3
const STAT_W := 1

const BAND_S := 10
const BAND_A := 7
const BAND_B := 4
const BAND_C := 1
const BAND_D := -2

const LOCKED := "?"


static func letter_from_score(score: int) -> String:
	if score >= BAND_S:
		return "S"
	if score >= BAND_A:
		return "A"
	if score >= BAND_B:
		return "B"
	if score >= BAND_C:
		return "C"
	if score >= BAND_D:
		return "D"
	return "F"


static func tag_count(bag: Dictionary, tag: String) -> int:
	return int(bag.get(tag, 0))


static func count_hits(bag: Dictionary, listed: PackedStringArray) -> PackedStringArray:
	var hits: PackedStringArray = PackedStringArray()
	for tag in listed:
		var name := String(tag)
		if tag_count(bag, name) > 0 and not (name in hits):
			hits.append(name)
	return hits


static func would_fire_neg(bag: Dictionary, construction_ids: PackedStringArray) -> PackedStringArray:
	## Planned estimate has no craft rarity — treat as common so syn_neg_* can fire.
	var fired: PackedStringArray = PackedStringArray()
	for row in CraftResolver.NEG_ROWS:
		var item: Dictionary = row
		var ok := false
		if item.has("construction"):
			var need := String(item.get("construction", ""))
			ok = need in construction_ids and tag_count(bag, String(item.get("tag", ""))) >= int(item.get("min", 1))
		else:
			ok = (
				tag_count(bag, String(item.get("a", ""))) >= int(item.get("amin", 1))
				and tag_count(bag, String(item.get("b", ""))) >= int(item.get("bmin", 1))
			)
		if ok:
			var syn_id := String(item.get("id", ""))
			if not syn_id.is_empty() and not (syn_id in fired):
				fired.append(syn_id)
	return fired


static func skill_condition_met(
	skill_id: String,
	bag: Dictionary,
	construction_ids: PackedStringArray,
	neg_warnings: PackedStringArray
) -> bool:
	match skill_id:
		"ask_plate_oath":
			return tag_count(bag, "Metal") >= PlannerCatalog.tier_min("mid")
		"ask_thorn_latch":
			return tag_count(bag, "Sticky") >= 1 and tag_count(bag, "Sharp") >= 1
		"ask_clean_court":
			return neg_warnings.is_empty() and tag_count(bag, "Royal") >= PlannerCatalog.tier_min("low")
		"ask_night_ledger":
			return tag_count(bag, "Lunar") >= PlannerCatalog.tier_min("mid")
		"ask_pale_signature":
			return tag_count(bag, "Lunar") >= 1 and tag_count(bag, "Occult") >= 1
		"ask_clean_hood":
			var hood_metal := "con_hood" in construction_ids and tag_count(bag, "Metal") >= 1
			var schism := tag_count(bag, "Occult") >= 1 and tag_count(bag, "Pure") >= 1
			return (
				tag_count(bag, "Silk") >= PlannerCatalog.tier_min("mid")
				and not hood_metal
				and not schism
			)
		"ask_edge_count":
			return tag_count(bag, "Sharp") >= PlannerCatalog.tier_min("mid")
		"ask_incognito_bow":
			return (
				tag_count(bag, "Royal") >= 1
				and tag_count(bag, "Silent") >= 1
				and tag_count(bag, "Metal") < 1
			)
		"ask_hush_check":
			var spoiled := tag_count(bag, "Metal") >= 1 or (
				tag_count(bag, "Soft") >= 1 and tag_count(bag, "Sharp") >= 1
			)
			return tag_count(bag, "Silent") >= PlannerCatalog.tier_min("mid") and not spoiled
		"ask_sky_step":
			return tag_count(bag, "Storm") >= PlannerCatalog.tier_min("mid")
		"ask_temper_brine":
			return tag_count(bag, "Fire") >= 1 and tag_count(bag, "Frost") >= 1
		"ask_rime_walk":
			return tag_count(bag, "Frost") >= PlannerCatalog.tier_min("mid")
		_:
			return false


static func compute(
	adventurer_stats: Dictionary,
	skill_id: String,
	planned: Variant,
	construction_ids: PackedStringArray,
	threat_id: String
) -> Dictionary:
	var tags := PlannerCatalog.add_construction_tags(
		PlannerCatalog.planned_tags(planned),
		construction_ids
	)
	var atk := int(adventurer_stats.get("ATK", 0))
	var def := int(adventurer_stats.get("DEF", 0))
	var res := int(adventurer_stats.get("RES", 0))
	var score: int = floori(float(atk + def + res) / 3.0) * STAT_W
	var favors := ThreatCatalog.favor_tags(threat_id) if not threat_id.is_empty() else PackedStringArray()
	var punishes := ThreatCatalog.punish_tags(threat_id) if not threat_id.is_empty() else PackedStringArray()
	var favor_hits := count_hits(tags, favors)
	var punish_hits := count_hits(tags, punishes)
	score += favor_hits.size() * FAVOR_W
	score -= punish_hits.size() * PUNISH_W
	var neg_warnings := would_fire_neg(tags, construction_ids)
	var skill_fired := skill_condition_met(skill_id, tags, construction_ids, neg_warnings)
	if skill_fired:
		score += SKILL_W
	if not neg_warnings.is_empty():
		score -= NEG_W
	return {
		"score": score,
		"band": letter_from_score(score),
		"favor_hits": favor_hits,
		"punish_hits": punish_hits,
		"skill_fired": skill_fired,
		"neg_warnings": neg_warnings,
		"tags": tags,
	}


## Display / dump gates (docs/30, 31). Internal compute always runs.
static func gated_dump(
	raw: Dictionary,
	planned: Variant,
	build_unlocked: bool,
	enemy_fought: bool
) -> Dictionary:
	var plan: Variant = PlannerCatalog.dup_plan(planned)
	var outlook_open := build_unlocked and plan is Dictionary
	var favor: Variant = LOCKED
	var punish: Variant = LOCKED
	var band: Variant = LOCKED
	if enemy_fought:
		favor = Array(raw.get("favor_hits", PackedStringArray()))
		punish = Array(raw.get("punish_hits", PackedStringArray()))
		band = String(raw.get("band", "F"))
	var skill: Variant = LOCKED
	var negs: Variant = LOCKED
	if outlook_open:
		skill = bool(raw.get("skill_fired", false))
		negs = Array(raw.get("neg_warnings", PackedStringArray()))
	var outlook: Variant = LOCKED
	if outlook_open:
		outlook = PlannerCatalog.plan_label(plan)
	return {
		"planned_outlook": outlook,
		"estimate_band": band,
		"estimate_favor_hits": favor,
		"estimate_punish_hits": punish,
		"estimate_skill_fired": skill,
		"estimate_neg_warnings": negs,
		"score": int(raw.get("score", 0)),
	}
