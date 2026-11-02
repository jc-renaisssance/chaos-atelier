extends Node
## Headless M2 baseline smoke. Run through tools/run_m2_smoke.ps1.

const AtelierSessionScript := preload("res://src/autoload/atelier_session.gd")
const AffinityFight := preload("res://src/ui/playback/affinity_fight.gd")

const PLAYER_SCENES := [
	"res://src/ui/title/title_screen.tscn",
	"res://src/ui/schedule/schedule_board.tscn",
	"res://src/ui/craft/craft_table.tscn",
	"res://src/ui/market/market_screen.tscn",
	"res://src/ui/event/event_screen.tscn",
	"res://src/ui/dex/dex_screen.tscn",
]

var _failures: PackedStringArray = PackedStringArray()
var _checks: int = 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var started := Time.get_ticks_msec()
	_clean_test_saves()
	_smoke_resources()
	_smoke_m2_roster()
	_smoke_affinity()
	_smoke_new_run_and_harness()
	_smoke_save_continue()
	var flow := _smoke_full_chapter()
	_clean_test_saves()

	var elapsed := Time.get_ticks_msec() - started
	if _failures.is_empty():
		print(
			"M2_SMOKE PASS checks=%d elapsed_ms=%d route_steps=%d vignettes=%d fights=%d terminal=%s"
			% [
				_checks,
				elapsed,
				int(flow.get("steps", 0)),
				int(flow.get("vignettes", 0)),
				int(flow.get("fights", 0)),
				String(flow.get("terminal", "")),
			]
		)
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error("M2_SMOKE: %s" % failure)
	print("M2_SMOKE FAIL checks=%d failures=%d elapsed_ms=%d" % [_checks, _failures.size(), elapsed])
	get_tree().quit(1)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _clean_test_saves() -> void:
	for path in [AtelierSessionScript.RUN_SAVE_PATH, ProfileMeta.SAVE_PATH]:
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(path):
			var err := DirAccess.remove_absolute(absolute)
			_check(err == OK, "could not remove isolated test save %s" % absolute)


func _smoke_resources() -> void:
	for path in PLAYER_SCENES:
		var packed := load(path) as PackedScene
		_check(packed != null, "player scene failed to load: %s" % path)
		if packed == null:
			continue
		var instance := packed.instantiate()
		_check(instance != null, "player scene failed to instantiate: %s" % path)
		if instance != null:
			instance.free()


func _smoke_m2_roster() -> void:
	var m1_jobs := AdventurerCatalog.jobs_for("m1")
	var m2_jobs := AdventurerCatalog.jobs_for("m2")
	_check(m1_jobs.size() == 4, "M1 job pool must contain four jobs")
	_check(m2_jobs.size() == 4, "M2 job pool must contain four jobs")
	for job_id in m2_jobs:
		_check(not m1_jobs.has(job_id), "M1 and M2 pools overlap at %s" % job_id)

	var m2_people := AdventurerCatalog.all_named_ids("m2")
	_check(m2_people.size() == 12, "M2 named roster must contain twelve adventurers")
	for adv_id in m2_people:
		_check(AdventurerCatalog.is_named(adv_id), "M2 roster contains an unnamed row: %s" % adv_id)
		_check(AdventurerCatalog.client_in_pool(adv_id, "m2"), "M2 adventurer is outside M2 pool: %s" % adv_id)
		_check(not AdventurerCatalog.display_name(adv_id).is_empty(), "M2 adventurer has no display name: %s" % adv_id)
		_check(AdventurerCatalog.skill_id(adv_id).begins_with("ask_"), "M2 adventurer has invalid skill id: %s" % adv_id)

	var jobs_seen: Dictionary = {}
	for seed in range(1, 129):
		var draw := BossClientCatalog.pick_boss_client_m2(seed)
		var adv_id := String(draw.get("boss_client_id", ""))
		var job_id := String(draw.get("job_id", ""))
		_check(AdventurerCatalog.client_in_pool(adv_id, "m2"), "seed %d drew non-M2 adventurer %s" % [seed, adv_id])
		_check(m2_jobs.has(job_id), "seed %d drew non-M2 job %s" % [seed, job_id])
		_check(BossClientCatalog.client_matches_job(adv_id, job_id), "seed %d drew mismatched adventurer/job" % seed)
		jobs_seen[job_id] = true
	_check(jobs_seen.size() == 4, "128 deterministic M2 draws did not cover all four jobs")

	_check(MapCatalog.CURRENT_MAP_ID == MapCatalog.M2_DEMO_MAP_ID, "live map must be map_m2_demo")
	var m1_route_people := 0
	for node in MapCatalog.make_nodes(MapCatalog.M1_MAP_ID):
		if node.kind != "adventurer":
			continue
		m1_route_people += 1
		_check(
			AdventurerCatalog.client_in_pool(node.ref_id, "m1"),
			"map_m1 contains non-M1 adventurer %s at %s" % [node.ref_id, node.node_id]
		)
	var m2_route_people := 0
	for node in MapCatalog.make_nodes(MapCatalog.M2_DEMO_MAP_ID):
		if node.kind != "adventurer":
			continue
		m2_route_people += 1
		_check(
			AdventurerCatalog.client_in_pool(node.ref_id, "m2"),
			"map_m2_demo contains non-M2 adventurer %s at %s" % [node.ref_id, node.node_id]
		)
	_check(m1_route_people > 0, "map_m1 has no regression adventurers")
	_check(m2_route_people > 0, "map_m2_demo has no live adventurers")


func _smoke_affinity() -> void:
	_check(GameConstants.session_stamina_start(1) == 10, "one-item stamina must be 10")
	_check(GameConstants.session_stamina_start(2) == 18, "two-item stamina must be 18")
	_check(GameConstants.session_stamina_start(4) == 34, "four-item stamina must be 34")

	var starter := CraftCatalog.own_basic_starter()
	_check(starter.size() == 10, "starter deck must contain ten cards")
	var ember_n := 0
	var neutral_n := 0
	for card in starter:
		if card.starter_role == "bolt_ember":
			ember_n += 1
			_check(CraftCatalog.tags_for_card(card) == PackedStringArray(["Fire"]), "starter Ember must withhold Silk")
		elif card.starter_role == "no_tag":
			neutral_n += 1
			_check(CraftCatalog.tags_for_card(card).is_empty(), "neutral starter printing leaked a tag")
	_check(ember_n == 3, "default starter bolt must contain three Ember copies")
	_check(neutral_n == 4, "starter deck must contain four neutral copies")

	var fire_session := _affinity_session(["con_cloak"])
	for _i in range(3):
		fire_session.cards_played.append(_played("mat_ember_silk", 1, "bolt_ember"))
	var fire_piece := CraftResolver.resolve(fire_session, "con_cloak", 1)
	var fire: Dictionary = fire_piece["affinity"]["Fire"]
	_check(int(fire["intensity"]) == 3, "three Ember copies must provide Fire intensity 3")
	_check(int(fire["tier"]) == 1, "Fire intensity 3 must be tier 1")
	_check(int(fire["ATK"]) == 6, "Fire affinity must retain tagged ATK contribution")
	_check(int(fire["magnitude"]) == 2, "starter Fire formula must produce 2 Burn")
	_check(int(fire_piece["affinity"]["Silk"]["intensity"]) == 0, "starter Ember leaked Silk affinity")
	var graded_fire := MissionResolver.attach(
		fire_piece,
		"",
		GameEnums.MissionKind.ORDER,
		1,
		false
	)
	_check(int(graded_fire.get("affinity_punch", 0)) == 2, "Fire affinity did not affect mission output")

	var split_session := _affinity_session(["con_cloak", "con_cloak"])
	for zone in [1, 2]:
		for _i in range(2):
			split_session.cards_played.append(_played("mat_ember_silk", zone, "bolt_ember"))
	var split_pieces := [
		CraftResolver.resolve(split_session, "con_cloak", 1),
		CraftResolver.resolve(split_session, "con_cloak", 2),
	]
	_check(not AffinityFight.kits_live(split_pieces), "two partial Fire items combined into an active tier")
	var split_affinity := CraftResolver.combine_affinity(split_pieces)
	_check(int(split_affinity["Fire"]["tier"]) == 0, "combined mission minted a tier from partial items")

	var heavy_session := _affinity_session(["con_cloak"])
	heavy_session.cards_played.append(
		_played("mat_ember_silk", 1, "", GameConstants.MAT_ENCH_HEAVY)
	)
	var heavy_piece := CraftResolver.resolve(heavy_session, "con_cloak", 1)
	var heavy_fire: Dictionary = heavy_piece["affinity"]["Fire"]
	_check(int(heavy_fire["intensity"]) == 2, "Heavy must double effective tag pips")
	_check(int(heavy_fire["ATK"]) == 4, "Heavy must double affinity stat contribution")

	_check(
		CraftResolver.affinity_magnitude("Soft", {"HP": 6, "RES": 3, "intensity": 3}) == 2,
		"starter Soft formula must produce Mend 2"
	)
	_check(
		CraftResolver.affinity_magnitude("Earth", {"HP": 6, "DEF": 3, "intensity": 3}) == 2,
		"starter Earth formula must produce Root Guard 2"
	)
	_check(
		CraftResolver.affinity_magnitude("Metal", {"HP": 3, "DEF": 3, "intensity": 3}) == 2,
		"starter Metal formula must produce Plate 2"
	)
	_check(
		CraftResolver.affinity_magnitude("Silk", {"MOB": 3, "PRE": 0, "intensity": 3}) == 2,
		"starter Silk formula must produce Flow 2"
	)
	_check(
		CraftResolver.affinity_magnitude("Fire", {"ATK": 10, "intensity": 10})
		> CraftResolver.affinity_magnitude("Fire", {"ATK": 8, "intensity": 8}),
		"affinity magnitude stopped scaling above intensity 8"
	)

	var commit_session := _affinity_session(["con_cloak"])
	commit_session.hand = [
		HandCard.make("mat_ember_silk", GameEnums.HandCardType.MATERIAL),
		HandCard.make("sk_next_mat_free", GameEnums.HandCardType.SKILL),
	]
	var play_mat := CraftRules.play(commit_session, 0, false, 1)
	_check(bool(play_mat.get("ok", false)), "material commitment play failed")
	_check(commit_session.committed.size() == 1, "played material did not enter committed")
	_check(commit_session.discard_pile.is_empty(), "played material entered discard")
	var play_skill := CraftRules.play(commit_session, 0, false, 1)
	_check(bool(play_skill.get("ok", false)), "skill cycle play failed")
	_check(commit_session.discard_pile.size() == 1, "played skill did not enter discard")
	_check(commit_session.committed.size() == 1, "skill incorrectly entered committed")
	var returned := WagonStock.new()
	CraftRules.return_run_deck(commit_session, returned)
	_check(returned.count() == 2, "Finish did not return committed and cycling cards")

	var metal_skill_session := _affinity_session(["con_cloak"])
	metal_skill_session.hand = [
		HandCard.make("mat_wirecloth", GameEnums.HandCardType.MATERIAL),
		HandCard.make("sk_metal_str_double", GameEnums.HandCardType.SKILL),
	]
	CraftRules.play(metal_skill_session, 0, false, 1)
	CraftRules.play(metal_skill_session, 0, false, 1)
	var metal_skill_piece := CraftResolver.resolve(metal_skill_session, "con_cloak", 1)
	_check(metal_skill_session.cards_played[0].double_atk, "Metal skill did not mark committed Metal")
	_check((metal_skill_piece["stats"] as GearStats).ATK == 2, "Metal skill did not double tagged ATK")

	var wild_skill_session := _affinity_session(["con_cloak"])
	wild_skill_session.hand = [
		HandCard.make("mat_leather_tan", GameEnums.HandCardType.MATERIAL),
		HandCard.make("sk_wild_to_earth", GameEnums.HandCardType.SKILL),
	]
	CraftRules.play(wild_skill_session, 0, false, 1)
	CraftRules.play(wild_skill_session, 0, false, 1)
	var wild_skill_piece := CraftResolver.resolve(wild_skill_session, "con_cloak", 1)
	_check(int(wild_skill_piece["tag_counts"].get("Wild", 0)) == 0, "Wild conversion retained Wild pips")
	_check(int(wild_skill_piece["tag_counts"].get("Earth", 0)) == 1, "Wild conversion did not add Earth pips")

	var touch_session := _affinity_session(["con_cloak"])
	touch_session.hand = [
		HandCard.make("mat_ember_silk", GameEnums.HandCardType.MATERIAL),
		HandCard.make("sk_touch_up", GameEnums.HandCardType.SKILL),
	]
	CraftRules.play(touch_session, 0, false, 1)
	CraftRules.play(touch_session, 0, false, 1)
	var touch_piece := CraftResolver.resolve(touch_session, "con_cloak", 1)
	_check((touch_piece["stats"] as GearStats).ATK == 3, "Touch Up did not add one strongest-stat point")

	var steady_session := _affinity_session(["con_cloak"])
	steady_session.cards_played = [
		_played("mat_ember_silk", 1),
		_played("mat_hemp_plain", 1),
		_played_skill("sk_steady_hand", 1),
	]
	var steady_piece := CraftResolver.resolve(steady_session, "con_cloak", 1)
	_check(steady_piece["powers_negative"].is_empty(), "Steady Hand did not ignore the first negative synergy")

	var deep_session := _affinity_session(["con_cloak"])
	deep_session.hand = [
		HandCard.make("sk_deep_dig", GameEnums.HandCardType.SKILL),
		HandCard.make("mat_hemp_plain", GameEnums.HandCardType.MATERIAL),
	]
	for _i in range(4):
		deep_session.draw_pile.append(HandCard.make("mat_iron_scrap", GameEnums.HandCardType.MATERIAL))
	var deep_rng := RandomNumberGenerator.new()
	deep_rng.seed = 77
	CraftRules.play(deep_session, 0, false, 1, 0, false, deep_rng)
	_check(deep_session.hand.size() == 5, "Deep Dig did not refill to hand size")

	var fire_rows := AffinityFight.build([
		_affinity_piece("Fire", 8, {"ATK": 16}),
	])
	_check(_labels_contain(fire_rows, "Burn +"), "Fire did not apply formula Burn")
	_check(_labels_contain(fire_rows, "Feed +"), "Fire tier 2 did not heal from its Burn tick")
	_check(_labels_contain(fire_rows, "Survive 1"), "Fire apex item did not mint one Survive charge")

	var soft_rows := AffinityFight.build([
		_affinity_piece("Soft", 8, {"HP": 12, "RES": 8}),
	])
	_check(_labels_contain(soft_rows, "Mend reserve"), "Soft did not create a Mend reserve")
	_check(_labels_contain(soft_rows, "Mend +"), "Soft did not mend nonlethal HP damage")
	_check(_labels_contain(soft_rows, "Cleanse"), "Soft apex did not run its first-Mend cleanse")
	var comfort_rows := AffinityFight.build([
		_affinity_piece("Soft", 3, {"HP": 20, "RES": 10}),
	])
	_check(_labels_count(comfort_rows, "Mend +") == 1, "Soft tier 1 Mend triggered more than once")

	var earth_rows := AffinityFight.build([
		_affinity_piece("Earth", 5, {"HP": 8, "DEF": 8}),
	])
	_check(_labels_count(earth_rows, "Root −") == 2, "Earth tier 2 did not guard every incoming hit")

	var metal_rows := AffinityFight.build([
		_affinity_piece("Metal", 8, {"HP": 8, "DEF": 8}),
	])
	_check(_labels_contain(metal_rows, "Plate 6"), "Metal did not create formula Plate")
	_check(_labels_contain(metal_rows, "Temper"), "Metal tier 2 did not convert lost Plate")
	_check(_labels_contain(metal_rows, "Plate reforged"), "Metal apex did not spend a Reforge charge")

	var silk_rows := AffinityFight.build([
		_affinity_piece("Silk", 8, {"MOB": 8, "PRE": 4}),
	])
	_check(_labels_contain(silk_rows, "Flow"), "Silk tier 2 did not reward winning initiative")
	_check(_labels_contain(silk_rows, "Flourish"), "Silk apex did not spend a Flourish charge")


func _affinity_session(constructions: Array) -> CraftStaminaSession:
	var order := ClientOrder.new()
	order.order_id = "test_affinity"
	order.construction_ids = PackedStringArray(constructions)
	return order.open_session()


func _played(
	id: String,
	zone_index: int,
	starter_role: String = "",
	mat_enchant_id: String = ""
) -> PlayedCard:
	var card := PlayedCard.new()
	card.id = id
	card.type = GameEnums.HandCardType.MATERIAL
	card.zone_index = zone_index
	card.construction_id = "con_cloak"
	card.starter_role = starter_role
	card.mat_enchant_id = mat_enchant_id
	return card


func _played_skill(id: String, zone_index: int) -> PlayedCard:
	var card := PlayedCard.new()
	card.id = id
	card.type = GameEnums.HandCardType.SKILL
	card.zone_index = zone_index
	card.construction_id = "con_cloak"
	return card


func _affinity_piece(tag: String, intensity: int, stat_bag: Dictionary) -> Dictionary:
	var row := {
		"intensity": intensity,
		"tier": CraftResolver.affinity_tier(intensity),
	}
	for stat in ["HP", "ATK", "DEF", "RES", "MOB", "PRE"]:
		row[stat] = int(stat_bag.get(stat, 0))
	row["magnitude"] = CraftResolver.affinity_magnitude(tag, row)
	var stats := GearStats.new()
	stats.add_bag(stat_bag)
	return {
		"affinity": {tag: row},
		"stats": stats,
		"tag_counts": {tag: intensity},
	}


func _labels_contain(rows: Array, fragment: String) -> bool:
	return _labels_count(rows, fragment) > 0


func _labels_count(rows: Array, fragment: String) -> int:
	var n := 0
	for row in rows:
		if fragment in String(row.get("label", "")):
			n += 1
	return n


func _smoke_new_run_and_harness() -> void:
	var session = AtelierSessionScript.new()
	session.start_chapter(1, 424242)
	_check(session.board != null, "new run did not create a chapter board")
	_check(session.newspaper_open, "new run did not open the boss newspaper")
	_check(session.resolve_open, "new run did not open the newspaper resolve")
	_check(session.board.chapter_boss_id.begins_with("boss_"), "new run did not announce a boss")
	_check(session.board.map_id == MapCatalog.M2_DEMO_MAP_ID, "new run did not select map_m2_demo")
	_check(session.board.route_path == ["N1"], "new run did not confirm the D1 start node")
	_check(
		AdventurerCatalog.client_in_pool(session.board.current_node().ref_id, "m2"),
		"D1 route order is not an M2 adventurer"
	)
	_check(session.last_stamp.schema_errors().is_empty(), "new-run harness schema errors: %s" % ", ".join(session.last_stamp.schema_errors()))

	session.acknowledge_resolve()
	_check(not session.newspaper_open, "newspaper acknowledgement did not close the newspaper")
	_check(not session.resolve_open, "newspaper acknowledgement left resolve open")
	_check(session.legal_actions().size() == 1, "D1 should expose exactly one route action")
	session.free()


func _smoke_save_continue() -> void:
	var original = AtelierSessionScript.new()
	original.start_chapter(1, 515151)
	original.acknowledge_resolve()
	original._write_run_save()
	_check(FileAccess.file_exists(AtelierSessionScript.RUN_SAVE_PATH), "run save was not written")

	var restored = AtelierSessionScript.new()
	_check(restored._load_run_save(), "continue could not load the run save")
	_check(restored.chapter_seed == original.chapter_seed, "continue changed chapter seed")
	_check(restored.board != null, "continue did not restore the chapter board")
	if restored.board != null:
		_check(restored.board.day_index == original.board.day_index, "continue changed day index")
		_check(restored.board.map_id == original.board.map_id, "continue changed map id")
		_check(restored.board.route_path == original.board.route_path, "continue changed confirmed route")
		_check(restored.board.chapter_boss_id == original.board.chapter_boss_id, "continue changed announced boss")
	_check(restored.gold == original.gold, "continue changed gold")

	var save_file := FileAccess.open(AtelierSessionScript.RUN_SAVE_PATH, FileAccess.READ)
	var legacy_data: Variant = JSON.parse_string(save_file.get_as_text()) if save_file != null else null
	_check(legacy_data is Dictionary, "could not parse run save for legacy compatibility smoke")
	if legacy_data is Dictionary:
		(legacy_data as Dictionary).erase("map_id")
		save_file = FileAccess.open(AtelierSessionScript.RUN_SAVE_PATH, FileAccess.WRITE)
		if save_file != null:
			save_file.store_string(JSON.stringify(legacy_data))
			save_file = null
		var legacy = AtelierSessionScript.new()
		_check(legacy._load_run_save(), "legacy run save without map_id did not load")
		if legacy.board != null:
			_check(legacy.board.map_id == MapCatalog.M1_MAP_ID, "legacy run save did not fall back to map_m1")
		legacy.free()

	original._delete_run_save()
	original.free()
	restored.free()


func _smoke_full_chapter() -> Dictionary:
	var session = AtelierSessionScript.new()
	session.start_chapter(1, 616161)
	## The smoke exercises the boss path, not balance. Prevent an empty-build route from ending at the reps gate.
	session.reps = 999

	var steps := 0
	var vignettes := 0
	var fights := 0
	var saw_market := false
	var saw_event := false
	var saw_boss_craft := false
	var prior_playback_key := ""

	while steps < 500 and not session.chapter_over and not session.run_over:
		steps += 1
		if session.craft_open:
			if not session.order_craft_done:
				_check(session.finish_early(), "could not finish an open craft session")
				continue
			if session.playback_open:
				var snapshot: Dictionary = session.playback_snapshot()
				var kind := String(snapshot.get("kind", ""))
				var key := "%s:%s:%s" % [
					kind,
					str(snapshot.get("piece_index", "")),
					str(snapshot.get("serial", "")),
				]
				if key != prior_playback_key:
					if kind == "vignette":
						vignettes += 1
					elif kind == "fight":
						fights += 1
					prior_playback_key = key
				session.finish_playback(true)
				continue
			if session.piece_report_open:
				session.continue_piece_report()
				continue
			session.continue_after_piece()
			continue

		if session.market_open:
			saw_market = true
			_check(session.exit_market(), "could not exit an open market")
			continue

		if session.event_open:
			saw_event = true
			if not session.event_resolved:
				var picked := false
				for choice in EventCatalog.choices(session.event_id):
					var row: Dictionary = choice
					var choice_id := String(row.get("id", ""))
					if session.can_pick_event_choice(choice_id):
						picked = session.pick_event_choice(choice_id)
						break
				_check(picked, "event exposed no affordable choice: %s" % session.event_id)
			else:
				_check(session.finish_event(), "could not finish resolved event %s" % session.event_id)
			continue

		if session.resolve_open:
			session.acknowledge_resolve()
			if session.craft_open and session.craft_order != null:
				saw_boss_craft = saw_boss_craft or session.craft_order.mission_kind == GameEnums.MissionKind.BOSS
			continue

		var options: Array[RouteNode] = session.board.fork_options()
		if not options.is_empty():
			var preferred_by_day := {2: "N4", 4: "N11"}
			var selected: RouteNode = options[0]
			var preferred := String(preferred_by_day.get(session.board.day_index, ""))
			for option in options:
				if option.node_id == preferred:
					selected = option
					break
			_check(session.confirm_node(selected.node_id), "could not confirm route option %s" % selected.node_id)
			continue

		var legal: Array[GameEnums.RoundAction] = session.legal_actions()
		_check(not legal.is_empty(), "full chapter stalled on D%d at %s" % [session.board.day_index, session.board.current_node_id])
		if legal.is_empty():
			break
		_check(session.pick_action(legal[0]), "could not take legal action on D%d" % session.board.day_index)

	_check(steps < 500, "full chapter exceeded 500 state transitions")
	_check(session.chapter_over or session.run_over, "full chapter did not reach a terminal state")
	_check(saw_market, "full chapter did not visit the market")
	_check(saw_event, "full chapter did not resolve an event")
	_check(saw_boss_craft, "full chapter did not enter the boss craft")
	_check(session.boss_draw_pool == "m2", "live boss beat did not use M2 pool")
	_check(AdventurerCatalog.client_in_pool(session.boss_client_id, "m2"), "live boss beat drew non-M2 adventurer")
	_check(vignettes >= 4, "full chapter did not play expected per-piece vignettes")
	_check(fights >= 2, "full chapter did not play expected combined fights")
	_check(session.last_stamp != null, "full chapter produced no final harness stamp")
	if session.last_stamp != null:
		_check(session.last_stamp.schema_errors().is_empty(), "final harness schema errors: %s" % ", ".join(session.last_stamp.schema_errors()))

	var result := {
		"steps": steps,
		"vignettes": vignettes,
		"fights": fights,
		"terminal": "run_over" if session.run_over else "chapter_over",
	}
	session.free()
	return result
