class_name PostureSocket
extends RefCounted
## Socket A (docs/30 slice 4). One still per slot.
## res://assets/adv/posture/<adv_id>_<slot>.png at 64×64. Display at integer 2×.
## Nearest filter is the caller's TextureRect. No 96 bust substitute. No appt_* file.
## Missing in_shop hides that slot. Missing playback png is a flat placeholder.
## A texture load that fails keeps the row on a 1×1 stand-in.

const CELL_PX := 64
const DISPLAY_PX := 128
const SLOTS := ["in_shop", "in_fight", "ult", "defend", "attack"]

static var _pixel: Texture2D = null


static func still_path(adv_id: String, slot: String) -> String:
	var named := named_id(adv_id)
	if named.is_empty() or not _known_slot(slot):
		return ""
	return "res://assets/adv/posture/%s_%s.png" % [named, slot]


## Job aliases resolve to the named row. appt_* has no socket.
static func named_id(adv_id: String) -> String:
	if adv_id.is_empty() or adv_id.begins_with("appt_"):
		return ""
	var named := AdventurerCatalog.resolve_id(adv_id)
	if named.is_empty() or named.begins_with("appt_"):
		return ""
	if not named.begins_with("adv_"):
		return ""
	if not AdventurerCatalog.is_named(named):
		return ""
	return named


## Order panel / walk-in: beside the 96 bust. Missing file or failed load hides the slot.
static func shop_still(adv_id: String) -> Dictionary:
	var hidden := _hidden_shop()
	var path := still_path(adv_id, "in_shop")
	if path.is_empty() or not ResourceLoader.exists(path):
		return hidden
	var tex := _load_texture(path)
	if tex == null:
		return hidden
	return {
		"slot": "in_shop",
		"hidden": false,
		"placeholder": false,
		"fallback_1x1": false,
		"texture": tex,
	}


## Playback row. Never hides the row. Never reads a portrait bust.
static func playback_still(actor_id: Variant, slot: String) -> Dictionary:
	var use_slot := slot
	if not _known_slot(use_slot):
		use_slot = "in_fight"
	if actor_id == null:
		return _placeholder(use_slot)
	var raw := String(actor_id)
	if raw.is_empty() or raw.begins_with("appt_"):
		return _placeholder(use_slot)
	var path := still_path(raw, use_slot)
	if path.is_empty() or not ResourceLoader.exists(path):
		return _placeholder(use_slot)
	var tex := _load_texture(path)
	if tex == null:
		return _one_pixel_row(use_slot)
	return {
		"slot": use_slot,
		"hidden": false,
		"placeholder": false,
		"fallback_1x1": false,
		"texture": tex,
	}


static func _known_slot(slot: String) -> bool:
	return SLOTS.has(slot)


static func _hidden_shop() -> Dictionary:
	return {
		"slot": "in_shop",
		"hidden": true,
		"placeholder": false,
		"fallback_1x1": false,
		"texture": null,
	}


static func _placeholder(slot: String) -> Dictionary:
	return {
		"slot": slot,
		"hidden": false,
		"placeholder": true,
		"fallback_1x1": false,
		"texture": null,
	}


static func _one_pixel_row(slot: String) -> Dictionary:
	return {
		"slot": slot,
		"hidden": false,
		"placeholder": false,
		"fallback_1x1": true,
		"texture": _one_pixel(),
	}


static func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var loaded: Variant = load(path)
	return loaded as Texture2D


static func _one_pixel() -> Texture2D:
	if _pixel != null:
		return _pixel
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.set_pixel(0, 0, Color(0.45, 0.38, 0.28, 1.0))
	_pixel = ImageTexture.create_from_image(image)
	return _pixel
