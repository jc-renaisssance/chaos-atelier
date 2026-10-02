class_name ThreatCatalog
extends RefCounted
## Client / boss favor-punish bags (docs/17, 28). Not a 1-of-3 lineup.
## C2/C3 de-favor own_basic starter tags (docs/19). C1 may stay approachable.

## Soft / Earth / Metal staples on own_basic mats (docs/19). C2/C3 punish these.
const OWN_BASIC_STARTER_TAGS := ["Soft", "Earth", "Metal", "Wild", "Silk", "Pure"]

const CLIENTS := {
	"cli_c1_ember_scout": {
		"name": "Ember Scout",
		"threat_tags": ["Fire"],
		"favor_tags": ["Metal", "Earth"],
		"punish_tags": ["Soft"],
	},
	"cli_c1_dock_hauler": {
		"name": "Dock Hauler",
		"threat_tags": ["Frost", "Sticky"],
		"favor_tags": ["Metal", "Frost"],
		"punish_tags": ["Soft"],
	},
	"cli_c1_scrap_duelist": {
		"name": "Scrap Duelist",
		"threat_tags": ["Metal", "Sharp"],
		"favor_tags": ["Metal", "Sharp"],
		"punish_tags": ["Soft"],
	},
	"cli_c1_glassblower": {
		"name": "Glassblower",
		"threat_tags": ["Solar", "Sharp"],
		"favor_tags": ["Silk", "Pure"],
		"punish_tags": ["Sticky"],
	},
	"cli_c1_pit_fighter": {
		"name": "Pit Fighter",
		"threat_tags": ["Sharp", "Wild"],
		"favor_tags": ["Sharp", "Metal"],
		"punish_tags": ["Soft"],
	},
	"cli_c2_bog_messenger": {
		"name": "Bog Messenger",
		"threat_tags": ["Sticky", "Earth"],
		"favor_tags": ["Silent", "Wild"],
		"punish_tags": ["Royal"],
	},
	"cli_c2_night_nun": {
		"name": "Night Nun",
		"threat_tags": ["Lunar", "Pure"],
		"favor_tags": ["Lunar", "Soft"],
		"punish_tags": ["Occult"],
	},
	"cli_c2_possessed_tailor": {
		"name": "Possessed Tailor",
		"threat_tags": ["Occult"],
		"favor_tags": ["Occult", "Silent"],
		"punish_tags": ["Pure"],
	},
	"cli_c2_mire_acolyte": {
		"name": "Mire Acolyte",
		"threat_tags": ["Occult", "Sticky"],
		"favor_tags": ["Silent", "Occult"],
		"punish_tags": ["Pure"],
	},
	"cli_c2_bog_ferry": {
		"name": "Bog Ferryman",
		"threat_tags": ["Earth", "Sticky"],
		"favor_tags": ["Earth", "Wild"],
		"punish_tags": ["Royal"],
	},
	"cli_c2_pale_cantor": {
		"name": "Pale Cantor",
		"threat_tags": ["Lunar", "Occult"],
		"favor_tags": ["Lunar", "Soft"],
		"punish_tags": ["Sharp"],
	},
	"cli_c2_root_warden": {
		"name": "Root Warden",
		"threat_tags": ["Earth", "Wild"],
		"favor_tags": ["Earth", "Sticky"],
		"punish_tags": ["Royal"],
	},
	"cli_c2_reed_runner": {
		"name": "Reed Runner",
		"threat_tags": ["Sticky", "Wild"],
		"favor_tags": ["Silent", "Earth"],
		"punish_tags": ["Royal"],
	},
	"cli_c2_choir_novice": {
		"name": "Choir Novice",
		"threat_tags": ["Lunar", "Soft"],
		"favor_tags": ["Lunar", "Occult"],
		"punish_tags": ["Metal"],
	},
	"cli_c3_court_duelist": {
		"name": "Court Duelist",
		"threat_tags": ["Royal", "Sharp"],
		"favor_tags": ["Royal", "Metal"],
		"punish_tags": ["Sticky"],
	},
	"cli_c3_tax_auditor": {
		"name": "Tax Auditor",
		"threat_tags": ["Royal", "Pure"],
		"favor_tags": ["Pure", "Metal"],
		"punish_tags": ["Silent"],
	},
	"cli_c3_parade_mage": {
		"name": "Parade Mage",
		"threat_tags": ["Solar", "Silk"],
		"favor_tags": ["Solar", "Silk"],
		"punish_tags": ["Occult"],
	},
	"cli_c3_court_scribe": {
		"name": "Court Scribe",
		"threat_tags": ["Royal", "Pure"],
		"favor_tags": ["Pure", "Royal"],
		"punish_tags": ["Occult"],
	},
	"cli_c3_ivory_second": {
		"name": "Ivory Second",
		"threat_tags": ["Royal", "Pure"],
		"favor_tags": ["Pure", "Metal"],
		"punish_tags": ["Occult"],
	},
	"cli_c3_parade_captain": {
		"name": "Parade Captain",
		"threat_tags": ["Solar", "Sharp"],
		"favor_tags": ["Solar", "Metal"],
		"punish_tags": ["Silent"],
	},
	"cli_c3_marble_host": {
		"name": "Marble Host",
		"threat_tags": ["Royal", "Solar"],
		"favor_tags": ["Royal", "Pure"],
		"punish_tags": ["Sticky"],
	},
	"cli_c3_court_page": {
		"name": "Court Page",
		"threat_tags": ["Royal"],
		"favor_tags": ["Silk", "Pure"],
		"punish_tags": ["Wild"],
	},
	"cli_c3_gilded_ward": {
		"name": "Gilded Ward",
		"threat_tags": ["Royal", "Metal"],
		"favor_tags": ["Metal", "Royal"],
		"punish_tags": ["Silent"],
	},
}

const BOSSES := {
	"boss_ash_drake": {
		"name": "Ash Drake",
		"threat_tags": ["Fire", "Sharp"],
		"favor_tags": ["Metal", "Earth", "Frost", "Pure"],
		"punish_tags": ["Soft", "Sticky"],
	},
	"boss_salt_widow": {
		"name": "Salt Widow",
		"threat_tags": ["Frost", "Sticky", "Storm"],
		"favor_tags": ["Frost", "Silent", "Metal"],
		"punish_tags": ["Soft", "Solar"],
	},
	"boss_rust_knave": {
		"name": "Rust Knave",
		"threat_tags": ["Metal", "Earth", "Sharp"],
		"favor_tags": ["Metal", "Earth", "Sharp"],
		"punish_tags": ["Soft", "Silk"],
	},
	"boss_mire_bride": {
		"name": "Mire Bride",
		"threat_tags": ["Occult", "Sticky", "Lunar"],
		"favor_tags": ["Silent", "Occult", "Lunar", "Sticky"],
		"punish_tags": ["Soft", "Pure", "Silk"],
	},
	"boss_bog_king": {
		"name": "Bog King",
		"threat_tags": ["Sticky", "Wild", "Earth"],
		"favor_tags": ["Frost", "Occult", "Storm", "Silent"],
		"punish_tags": ["Soft", "Earth", "Metal", "Wild"],
	},
	"boss_pale_choir": {
		"name": "Pale Choir",
		"threat_tags": ["Lunar", "Occult", "Storm"],
		"favor_tags": ["Lunar", "Occult", "Silent", "Frost"],
		"punish_tags": ["Soft", "Metal", "Silk"],
	},
	"boss_gilded_warden": {
		"name": "Gilded Warden",
		"threat_tags": ["Royal", "Solar", "Sharp"],
		"favor_tags": ["Royal", "Solar", "Fire", "Sharp"],
		"punish_tags": ["Soft", "Earth", "Wild", "Metal"],
	},
	"boss_ivory_judge": {
		"name": "Ivory Judge",
		"threat_tags": ["Royal", "Lunar", "Silent"],
		"favor_tags": ["Royal", "Lunar", "Silent", "Occult"],
		"punish_tags": ["Soft", "Metal", "Pure", "Silk"],
	},
	"boss_sunspear_captain": {
		"name": "Sunspear Captain",
		"threat_tags": ["Solar", "Sharp", "Fire"],
		"favor_tags": ["Solar", "Sharp", "Fire", "Royal"],
		"punish_tags": ["Soft", "Silk", "Pure", "Earth"],
	},
}


static func row(threat_id: String) -> Dictionary:
	if CLIENTS.has(threat_id):
		return CLIENTS[threat_id]
	if BOSSES.has(threat_id):
		return BOSSES[threat_id]
	return {
		"name": threat_id,
		"threat_tags": [],
		"favor_tags": [],
		"punish_tags": [],
	}


static func is_boss(threat_id: String) -> bool:
	return BOSSES.has(threat_id)


static func display_name(threat_id: String) -> String:
	return String(row(threat_id).get("name", threat_id))


static func favor_tags(threat_id: String) -> PackedStringArray:
	return PackedStringArray(row(threat_id).get("favor_tags", []))


static func punish_tags(threat_id: String) -> PackedStringArray:
	return PackedStringArray(row(threat_id).get("punish_tags", []))


static func threat_tags(threat_id: String) -> PackedStringArray:
	return PackedStringArray(row(threat_id).get("threat_tags", []))
