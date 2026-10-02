class_name BossClientCatalog
extends RefCounted
## Shared adventurer / boss-client pool (docs/28). One pool for all bosses / chapters.
## Not a fixed client per boss. Not appointments (Scrap Duelist stays appt_*).

const SHARED_BOSS_CLIENT_POOL := [
	"job_knight",
	"job_mage",
	"job_lagoon",
	"job_wizard",
	"job_blade_dancer",
	"job_hexer",
	"job_outrider",
	"job_oathbound",
]

## job_id → row. Order constructions are law (con_* from docs/12 only).
const JOBS := {
	"job_knight": {
		"job_id": "job_knight",
		"display": "Knight",
		"boss_client_id": "adv_knight",
		"order_id": "ord_knight",
		"construction_ids": ["con_armor", "con_gloves"],
		"requirement_tags": ["Metal", "Sharp"],
	},
	"job_mage": {
		"job_id": "job_mage",
		"display": "Mage",
		"boss_client_id": "adv_mage",
		"order_id": "ord_mage",
		"construction_ids": ["con_robe", "con_hood"],
		"requirement_tags": ["Silk", "Pure", "Lunar"],
	},
	"job_lagoon": {
		"job_id": "job_lagoon",
		"display": "Lagoon",
		"boss_client_id": "adv_lagoon",
		"order_id": "ord_lagoon",
		"construction_ids": ["con_cloak", "con_boots"],
		"requirement_tags": ["Frost", "Sticky", "Storm"],
	},
	"job_wizard": {
		"job_id": "job_wizard",
		"display": "Wizard",
		"boss_client_id": "adv_wizard",
		"order_id": "ord_wizard",
		"construction_ids": ["con_robe", "con_mantle"],
		"requirement_tags": ["Occult", "Lunar", "Royal"],
	},
	"job_blade_dancer": {
		"job_id": "job_blade_dancer",
		"display": "Blade Dancer",
		"boss_client_id": "adv_blade_dancer",
		"order_id": "ord_blade_dancer",
		"construction_ids": ["con_tunic", "con_cape"],
		"requirement_tags": ["Sharp", "Silk", "Silent"],
	},
	"job_hexer": {
		"job_id": "job_hexer",
		"display": "Hexer",
		"boss_client_id": "adv_hexer",
		"order_id": "ord_hexer",
		"construction_ids": ["con_wraps", "con_hood"],
		"requirement_tags": ["Occult", "Sticky", "Silent"],
	},
	"job_outrider": {
		"job_id": "job_outrider",
		"display": "Outrider",
		"boss_client_id": "adv_outrider",
		"order_id": "ord_outrider",
		"construction_ids": ["con_coat", "con_boots"],
		"requirement_tags": ["Wild", "Storm", "Silent"],
	},
	"job_oathbound": {
		"job_id": "job_oathbound",
		"display": "Oathbound",
		"boss_client_id": "adv_oathbound",
		"order_id": "ord_oathbound",
		"construction_ids": ["con_armor", "con_mantle"],
		"requirement_tags": ["Royal", "Solar", "Pure"],
	},
}


## Seeded draw from the shared pool. Do not pass chapter_boss_id — independent of the announced boss.
static func pick_boss_client(seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var n := SHARED_BOSS_CLIENT_POOL.size()
	if n <= 0:
		return {}
	var job_id := String(SHARED_BOSS_CLIENT_POOL[rng.randi_range(0, n - 1)])
	return row(job_id)


static func row(job_id: String) -> Dictionary:
	if JOBS.has(job_id):
		return JOBS[job_id]
	return {}


static func row_for_client(boss_client_id: String) -> Dictionary:
	for job_id in SHARED_BOSS_CLIENT_POOL:
		var job: Dictionary = JOBS[job_id]
		if String(job.get("boss_client_id", "")) == boss_client_id:
			return job
	return {}


static func has_job(job_id: String) -> bool:
	return JOBS.has(job_id)


static func is_adv_id(boss_client_id: String) -> bool:
	return boss_client_id.begins_with("adv_") and not row_for_client(boss_client_id).is_empty()


static func is_appointment_id(id: String) -> bool:
	return id.begins_with("appt_")


static func display_name(job_id: String) -> String:
	var job := row(job_id)
	if job.is_empty():
		return job_id
	return String(job.get("display", job_id))


static func construction_ids(job_id: String) -> PackedStringArray:
	var job := row(job_id)
	return PackedStringArray(job.get("construction_ids", []))


static func requirement_tags(job_id: String) -> PackedStringArray:
	var job := row(job_id)
	return PackedStringArray(job.get("requirement_tags", []))


static func constructions_match(job_id: String, listed: PackedStringArray) -> bool:
	var expect := construction_ids(job_id)
	if expect.size() != listed.size():
		return false
	for i in range(expect.size()):
		if String(expect[i]) != String(listed[i]):
			return false
	return true


static func make_order(job: Dictionary, chapter_boss_id: String) -> ClientOrder:
	var order := ClientOrder.new()
	if job.is_empty():
		return order
	order.order_id = String(job.get("order_id", ""))
	order.threat_id = chapter_boss_id
	order.construction_ids = PackedStringArray(job.get("construction_ids", []))
	order.card_difficulty = 3
	order.mission_kind = GameEnums.MissionKind.BOSS
	order.boss_client_id = String(job.get("boss_client_id", ""))
	order.boss_job_id = String(job.get("job_id", ""))
	order.requirement_tags = PackedStringArray(job.get("requirement_tags", []))
	return order
