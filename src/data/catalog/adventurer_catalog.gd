class_name AdventurerCatalog
extends RefCounted
## M1 named adventurers (docs/29). Job constructions stay in BossClientCatalog (docs/28).
## Slice 1 order panel: name, job, six stats, one ask_* line, requirement taste.

const M1_JOB_POOL := [
	"job_knight",
	"job_mage",
	"job_blade_dancer",
	"job_lagoon",
]

## Job-stub ids from docs/28. Not people. Old smokes still parse; panel resolves to the named row.
const JOB_DEFAULT_ALIASES := {
	"adv_knight": "adv_halden_rook",
	"adv_mage": "adv_quill_lumen",
	"adv_blade_dancer": "adv_kite_thornreel",
	"adv_lagoon": "adv_tide_glass",
}

const PEOPLE_BY_JOB := {
	"job_knight": ["adv_halden_rook", "adv_vex_bramble", "adv_solenne_ward"],
	"job_mage": ["adv_quill_lumen", "adv_neri_paleink", "adv_marrowveil"],
	"job_blade_dancer": ["adv_kite_thornreel", "adv_mask_circlet", "adv_whisper_hem"],
	"job_lagoon": ["adv_tide_glass", "adv_brine_latch", "adv_rime_peddler"],
}

## id → row. Stats are test knobs (docs/29). Construction lists are job-fixed in docs/28.
const PEOPLE := {
	"adv_halden_rook": {
		"id": "adv_halden_rook",
		"display": "Ser Halden Rook",
		"job_id": "job_knight",
		"skill_id": "ask_plate_oath",
		"skill_name": "Plate Oath",
		"skill_line": "If planned Metal ≥ mid, the estimate (and sim) ignores the first physical punish chip.",
		"requirement_taste": "Metal mid",
		"requirement_tags": ["Metal"],
		"target_threat_id": "boss_ash_drake",
		"stats": {"HP": 14, "ATK": 4, "DEF": 6, "RES": 3, "MOB": 2, "PRE": 4},
	},
	"adv_vex_bramble": {
		"id": "adv_vex_bramble",
		"display": "Vex Bramble",
		"job_id": "job_knight",
		"skill_id": "ask_thorn_latch",
		"skill_name": "Thorn Latch",
		"skill_line": "If Sticky ∧ Sharp both present, estimate first-ambush bind + chip (Snaretooth).",
		"requirement_taste": "Sticky + Sharp (Snaretooth)",
		"requirement_tags": ["Sticky", "Sharp"],
		"target_threat_id": "boss_salt_widow",
		"stats": {"HP": 11, "ATK": 6, "DEF": 4, "RES": 3, "MOB": 5, "PRE": 2},
	},
	"adv_solenne_ward": {
		"id": "adv_solenne_ward",
		"display": "Dame Solenne Ward",
		"job_id": "job_knight",
		"skill_id": "ask_clean_court",
		"skill_name": "Clean Court",
		"skill_line": "Any planned syn_neg_* is a hard estimate warning. If no neg and Royal ≥ low, +PRE vs court threats.",
		"requirement_taste": "Royal mid",
		"requirement_tags": ["Royal"],
		"target_threat_id": "boss_gilded_warden",
		"stats": {"HP": 12, "ATK": 3, "DEF": 5, "RES": 4, "MOB": 3, "PRE": 6},
	},
	"adv_quill_lumen": {
		"id": "adv_quill_lumen",
		"display": "Quill Lumen",
		"job_id": "job_mage",
		"skill_id": "ask_night_ledger",
		"skill_name": "Night Ledger",
		"skill_line": "If planned Lunar ≥ mid, estimate applies the night / omen bonus; Solar punish is shown.",
		"requirement_taste": "Lunar mid",
		"requirement_tags": ["Lunar"],
		"target_threat_id": "boss_pale_choir",
		"stats": {"HP": 9, "ATK": 3, "DEF": 2, "RES": 6, "MOB": 4, "PRE": 5},
	},
	"adv_neri_paleink": {
		"id": "adv_neri_paleink",
		"display": "Neri Pale-Ink",
		"job_id": "job_mage",
		"skill_id": "ask_pale_signature",
		"skill_name": "Pale Signature",
		"skill_line": "If Lunar ∧ Occult both present, estimate Pale Hex vs the brief; Pure on the bag is a risk flag.",
		"requirement_taste": "Lunar + Occult (Pale Hex)",
		"requirement_tags": ["Lunar", "Occult"],
		"target_threat_id": "boss_mire_bride",
		"stats": {"HP": 8, "ATK": 4, "DEF": 2, "RES": 7, "MOB": 3, "PRE": 4},
	},
	"adv_marrowveil": {
		"id": "adv_marrowveil",
		"display": "Sister Marrowveil",
		"job_id": "job_mage",
		"skill_id": "ask_clean_hood",
		"skill_name": "Clean Hood",
		"skill_line": "Estimate fail-warns if Metal ≥1 on this hood order, or if Occult ∧ Pure both present. Silk mid adds MOB on grace beats only if those warns are clear.",
		"requirement_taste": "Silk mid",
		"requirement_tags": ["Silk"],
		"target_threat_id": "boss_ivory_judge",
		"stats": {"HP": 10, "ATK": 2, "DEF": 3, "RES": 5, "MOB": 5, "PRE": 5},
	},
	"adv_kite_thornreel": {
		"id": "adv_kite_thornreel",
		"display": "Kite Thornreel",
		"job_id": "job_blade_dancer",
		"skill_id": "ask_edge_count",
		"skill_name": "Edge Count",
		"skill_line": "If planned Sharp ≥ mid, estimate reflect-chip vs physical threats (Razor Choir band).",
		"requirement_taste": "Sharp mid",
		"requirement_tags": ["Sharp"],
		"target_threat_id": "boss_rust_knave",
		"stats": {"HP": 10, "ATK": 7, "DEF": 3, "RES": 2, "MOB": 7, "PRE": 3},
	},
	"adv_mask_circlet": {
		"id": "adv_mask_circlet",
		"display": "Mask Circlet",
		"job_id": "job_blade_dancer",
		"skill_id": "ask_incognito_bow",
		"skill_name": "Incognito Bow",
		"skill_line": "If Royal ∧ Silent both present, estimate Masked Crown +PRE on intrigue. Metal on the bag → fail-open (spotted / clang).",
		"requirement_taste": "Royal + Silent (Masked Crown)",
		"requirement_tags": ["Royal", "Silent"],
		"target_threat_id": "boss_ivory_judge",
		"stats": {"HP": 9, "ATK": 5, "DEF": 3, "RES": 3, "MOB": 6, "PRE": 6},
	},
	"adv_whisper_hem": {
		"id": "adv_whisper_hem",
		"display": "Whisper Hem",
		"job_id": "job_blade_dancer",
		"skill_id": "ask_hush_check",
		"skill_name": "Hush Check",
		"skill_line": "Silent mid → stealth bonus in the estimate. Any Metal, or Soft ∧ Sharp, marks the hush spoiled.",
		"requirement_taste": "Silent mid",
		"requirement_tags": ["Silent"],
		"target_threat_id": "boss_bog_king",
		"stats": {"HP": 8, "ATK": 4, "DEF": 2, "RES": 3, "MOB": 8, "PRE": 2},
	},
	"adv_tide_glass": {
		"id": "adv_tide_glass",
		"display": "Tide Glass",
		"job_id": "job_lagoon",
		"skill_id": "ask_sky_step",
		"skill_name": "Sky Step",
		"skill_line": "If planned Storm ≥ mid, estimate +MOB on first-move; Shock vulnerability is shown.",
		"requirement_taste": "Storm mid",
		"requirement_tags": ["Storm"],
		"target_threat_id": "boss_bog_king",
		"stats": {"HP": 11, "ATK": 5, "DEF": 3, "RES": 5, "MOB": 6, "PRE": 3},
	},
	"adv_brine_latch": {
		"id": "adv_brine_latch",
		"display": "Brine Latch",
		"job_id": "job_lagoon",
		"skill_id": "ask_temper_brine",
		"skill_name": "Temper Brine",
		"skill_line": "If Fire ∧ Frost both present, estimate Temper (+RES, −HP steam). Soft on the bag with Fire → Scorched Down warning.",
		"requirement_taste": "Fire + Frost (Temper)",
		"requirement_tags": ["Fire", "Frost"],
		"target_threat_id": "boss_sunspear_captain",
		"stats": {"HP": 10, "ATK": 6, "DEF": 3, "RES": 6, "MOB": 5, "PRE": 2},
	},
	"adv_rime_peddler": {
		"id": "adv_rime_peddler",
		"display": "Rime Peddler",
		"job_id": "job_lagoon",
		"skill_id": "ask_rime_walk",
		"skill_name": "Rime Walk",
		"skill_line": "If planned Frost ≥ mid, estimate ignores the first heat punish. Metal ≥1 on the cloak → Iron Mantle Fail warning (−MOB / PRE odd).",
		"requirement_taste": "Frost mid",
		"requirement_tags": ["Frost"],
		"target_threat_id": "boss_salt_widow",
		"stats": {"HP": 12, "ATK": 3, "DEF": 4, "RES": 6, "MOB": 5, "PRE": 3},
	},
}


static func resolve_id(adv_id: String) -> String:
	if PEOPLE.has(adv_id):
		return adv_id
	if JOB_DEFAULT_ALIASES.has(adv_id):
		return String(JOB_DEFAULT_ALIASES[adv_id])
	return ""


static func is_named(adv_id: String) -> bool:
	return PEOPLE.has(adv_id)


static func is_alias(adv_id: String) -> bool:
	return JOB_DEFAULT_ALIASES.has(adv_id)


static func is_known(adv_id: String) -> bool:
	return is_named(adv_id) or is_alias(adv_id)


static func row(adv_id: String) -> Dictionary:
	if PEOPLE.has(adv_id):
		return PEOPLE[adv_id]
	return {}


static func row_resolved(adv_id: String) -> Dictionary:
	return row(resolve_id(adv_id))


static func ids_for_job(job_id: String) -> PackedStringArray:
	if PEOPLE_BY_JOB.has(job_id):
		return PackedStringArray(PEOPLE_BY_JOB[job_id])
	return PackedStringArray()


static func all_named_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for job_id in M1_JOB_POOL:
		ids.append_array(ids_for_job(String(job_id)))
	return ids


static func job_id_for(adv_id: String) -> String:
	var person := row_resolved(adv_id)
	if person.is_empty():
		return ""
	return String(person.get("job_id", ""))


static func display_name(adv_id: String) -> String:
	var person := row_resolved(adv_id)
	if person.is_empty():
		return adv_id
	return String(person.get("display", adv_id))


static func skill_id(adv_id: String) -> String:
	var person := row_resolved(adv_id)
	return String(person.get("skill_id", ""))


static func skill_panel_line(adv_id: String) -> String:
	var person := row_resolved(adv_id)
	if person.is_empty():
		return ""
	return "%s  ·  %s. %s" % [
		String(person.get("skill_id", "")),
		String(person.get("skill_name", "")),
		String(person.get("skill_line", "")),
	]


static func requirement_taste(adv_id: String) -> String:
	var person := row_resolved(adv_id)
	return String(person.get("requirement_taste", ""))


static func stats_dict(adv_id: String) -> Dictionary:
	var person := row_resolved(adv_id)
	var bag := Dictionary(person.get("stats", {}))
	return {
		"HP": int(bag.get("HP", 0)),
		"ATK": int(bag.get("ATK", 0)),
		"DEF": int(bag.get("DEF", 0)),
		"RES": int(bag.get("RES", 0)),
		"MOB": int(bag.get("MOB", 0)),
		"PRE": int(bag.get("PRE", 0)),
	}


static func stats_line(adv_id: String) -> String:
	var bag := stats_dict(adv_id)
	return "HP %d   ATK %d   DEF %d   RES %d   MOB %d   PRE %d" % [
		int(bag.get("HP", 0)),
		int(bag.get("ATK", 0)),
		int(bag.get("DEF", 0)),
		int(bag.get("RES", 0)),
		int(bag.get("MOB", 0)),
		int(bag.get("PRE", 0)),
	]


static func order_adventurer_id(order: ClientOrder) -> String:
	if order == null:
		return ""
	if not order.adventurer_id.is_empty():
		return order.adventurer_id
	return order.boss_client_id


static func pick_named(rng: RandomNumberGenerator) -> Dictionary:
	var ids := all_named_ids()
	var n := ids.size()
	if n <= 0 or rng == null:
		return {}
	return row(String(ids[rng.randi_range(0, n - 1)]))


## Job row + named person for a live draw / order bind. Constructions stay on the job.
static func draw_payload(adv_id: String) -> Dictionary:
	var named := resolve_id(adv_id)
	var person := row(named)
	if person.is_empty():
		return {}
	var job := BossClientCatalog.row(String(person.get("job_id", "")))
	if job.is_empty():
		return {}
	var payload: Dictionary = job.duplicate(true)
	payload["boss_client_id"] = named
	payload["adventurer_id"] = named
	payload["adventurer_display"] = String(person.get("display", named))
	payload["skill_id"] = String(person.get("skill_id", ""))
	payload["skill_name"] = String(person.get("skill_name", ""))
	payload["skill_line"] = String(person.get("skill_line", ""))
	payload["requirement_taste"] = String(person.get("requirement_taste", ""))
	payload["requirement_tags"] = person.get("requirement_tags", [])
	payload["stats"] = stats_dict(named)
	payload["target_threat_id"] = String(person.get("target_threat_id", ""))
	return payload
