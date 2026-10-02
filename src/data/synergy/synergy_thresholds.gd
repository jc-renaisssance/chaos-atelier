class_name SynergyThresholds
extends Resource
## Threshold constants only — not a resolver (docs/14). Ids stay syn_*_3 / gen-list *_2/*_3.

@export var tier_1: int = 3 ## old ≥2
@export var tier_2: int = 5 ## old ≥3
@export var apex: int = 8
@export var apex_tags: PackedStringArray = PackedStringArray(["Fire", "Metal", "Earth"])
@export var cross_tag_min: int = 1


func matches_phase1() -> bool:
	if tier_1 != GameConstants.SYN_THRESHOLD_TIER_1:
		return false
	if tier_2 != GameConstants.SYN_THRESHOLD_TIER_2:
		return false
	if apex != GameConstants.SYN_THRESHOLD_APEX:
		return false
	if cross_tag_min != GameConstants.SYN_CROSS_TAG_MIN:
		return false
	if apex_tags.size() != GameConstants.SYN_APEX_TAGS.size():
		return false
	for i in range(apex_tags.size()):
		if apex_tags[i] != GameConstants.SYN_APEX_TAGS[i]:
			return false
	return true


func is_apex_tag(tag: String) -> bool:
	return tag in apex_tags


func to_dict() -> Dictionary:
	return {
		"tier_1": tier_1,
		"tier_2": tier_2,
		"apex": apex,
		"apex_tags": Array(apex_tags),
		"cross_tag_min": cross_tag_min,
	}
