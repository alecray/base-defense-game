extends Node

const SAVE_PATH: String = "user://save.json"
const AUTOSAVE_INTERVAL: float = 300.0

var _autosave_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("save_manager")
	if FileAccess.file_exists(SAVE_PATH):
		call_deferred("load_game")

func _process(delta: float) -> void:
	_autosave_timer += delta
	if _autosave_timer >= AUTOSAVE_INTERVAL:
		_autosave_timer = 0.0
		save_game()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_Z:
		save_game()

func save_game() -> void:
	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid == null:
		return

	var data: Dictionary = {}
	data["coins"] = GameState.coins
	data["food"] = GameState.food
	data["worker_count"] = GameState.worker_count
	data["building_counts"] = GameState.building_counts.duplicate()
	data["tiles"] = tile_grid.call("get_save_data")
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	data["day"] = cycle.call("get_day") if cycle != null else 1
	data["power"] = GameState.power
	data["power_cap"] = GameState.power_cap
	data["food_cap"] = GameState.food_cap
	data["soldiers"] = GameState.soldiers
	data["lab_research_id"] = GameState.lab_research_id
	data["lab_research_progress"] = GameState.lab_research_progress
	data["lab_upgrade_levels"] = GameState.lab_upgrade_levels.duplicate()
	data["workers"] = _get_worker_save_data()
	data["farms"] = tile_grid.call("get_farm_save_data")
	data["towers"] = tile_grid.call("get_tower_save_data")
	data["gold_mines"] = tile_grid.call("get_gold_mine_save_data")
	data["walls"] = tile_grid.call("get_wall_save_data")
	var hud: Node = get_tree().get_first_node_in_group("hud")
	data["tutorial_step"] = int(hud.call("get_tutorial_step")) if hud != null else 0

	var json_string: String = JSON.stringify(data, "\t")
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(json_string)
	file.close()
	_show_saved_popup()

func _get_worker_save_data() -> Array:
	var result: Array = []
	for worker: Node in get_tree().get_nodes_in_group("workers"):
		var worker_node: Node2D = worker as Node2D
		var entry: Dictionary = {}
		entry["x"] = worker_node.position.x
		entry["y"] = worker_node.position.y
		result.append(entry)
	return result

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_err: int = json.parse(json_string)
	if parse_err != OK:
		return

	var data: Dictionary = json.data as Dictionary

	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null:
		cycle.call("set_day", int(data.get("day", 1)))

	GameState.power = int(data.get("power", 0))
	GameState.power_cap = int(data.get("power_cap", CONSTANTS.POWER_CAP_BASE))
	GameState.food_cap = int(data.get("food_cap", CONSTANTS.FOOD_CAP_BASE))
	GameState.soldiers = int(data.get("soldiers", 0))
	GameState.lab_research_id = str(data.get("lab_research_id", ""))
	GameState.lab_research_progress = float(data.get("lab_research_progress", 0.0))
	GameState.lab_upgrade_levels = (data.get("lab_upgrade_levels", {}) as Dictionary).duplicate()

	GameState.coins = int(data["coins"])
	GameState.food = int(data["food"])
	GameState.worker_count = int(data["worker_count"])
	GameState.assigned_workers = 0
	GameState.building_counts = (data["building_counts"] as Dictionary).duplicate()
	GameState.coins_changed.emit(GameState.coins)
	GameState.food_changed.emit(GameState.food)
	GameState.power_changed.emit(GameState.power)
	GameState.soldiers_changed.emit(GameState.soldiers, GameState.get_soldier_cap())
	GameState.workers_changed.emit(GameState.worker_count, GameState.get_worker_cap(), GameState.get_free_workers())

	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null:
		var saved_step: int = int(data.get("tutorial_step", 0))
		var step: int = maxi(saved_step, _infer_tutorial_step(data))
		hud.call("restore_tutorial_step", step)

	if GameState.get_building_count("Core") > 0:
		GameState.building_placed.emit("Core")

	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid == null:
		return

	tile_grid.call("clear_for_load")

	var tiles_data: Array = data["tiles"] as Array
	for tile_entry: Variant in tiles_data:
		var tile_dict: Dictionary = tile_entry as Dictionary
		var gp_arr: Array = tile_dict["gp"] as Array
		var gp: Vector2i = Vector2i(int(gp_arr[0]), int(gp_arr[1]))
		var building: String = str(tile_dict["building"])
		tile_grid.call("unlock_tile_free", gp)
		if building != "":
			var shield_hp: int = int(tile_dict.get("shield_hp", 0))
			tile_grid.call("place_building_from_save", building, gp, shield_hp)

	var workers_data: Array = data["workers"] as Array
	for worker_entry: Variant in workers_data:
		var worker_dict: Dictionary = worker_entry as Dictionary
		tile_grid.call("spawn_worker_at", Vector2(float(worker_dict["x"]), float(worker_dict["y"])))

	var farms_data: Array = data.get("farms", []) as Array
	for farm_entry: Variant in farms_data:
		var farm_dict: Dictionary = farm_entry as Dictionary
		var farm_gp_arr: Array = farm_dict["gp"] as Array
		var farm_gp: Vector2i = Vector2i(int(farm_gp_arr[0]), int(farm_gp_arr[1]))
		var assigned_count: int = int(farm_dict["assigned_count"])
		var farm_node: Node = tile_grid.call("get_farm_at", farm_gp) as Node
		if farm_node != null:
			for _i: int in range(assigned_count):
				farm_node.call("assign_worker")

	var towers_data: Array = data.get("towers", []) as Array
	for tower_entry: Variant in towers_data:
		var tower_dict: Dictionary = tower_entry as Dictionary
		var tower_gp_arr: Array = tower_dict["gp"] as Array
		var tower_gp: Vector2i = Vector2i(int(tower_gp_arr[0]), int(tower_gp_arr[1]))
		var assigned_count: int = int(tower_dict["assigned_count"])
		var tower_node: Node = tile_grid.call("get_farm_at", tower_gp) as Node
		if tower_node != null:
			for _i: int in range(assigned_count):
				tower_node.call("assign_worker")

	var gold_mines_data: Array = data.get("gold_mines", []) as Array
	for mine_entry: Variant in gold_mines_data:
		var mine_dict: Dictionary = mine_entry as Dictionary
		var mine_gp_arr: Array = mine_dict["gp"] as Array
		var mine_gp: Vector2i = Vector2i(int(mine_gp_arr[0]), int(mine_gp_arr[1]))
		var reserves: int = int(mine_dict["reserves"])
		var assigned_count: int = int(mine_dict["assigned_count"])
		var mine_node: Node = tile_grid.call("get_gold_mine_at", mine_gp) as Node
		if mine_node != null:
			mine_node.call("set_reserves", reserves)
			for _i: int in range(assigned_count):
				mine_node.call("assign_worker")

	var walls_data: Array = data.get("walls", []) as Array
	for wall_entry: Variant in walls_data:
		var wall_dict: Dictionary = wall_entry as Dictionary
		tile_grid.call("place_wall_from_save", str(wall_dict["key"]), int(wall_dict["hp"]))

	var soldiers_count: int = int(data.get("soldiers", 0))
	GameState.soldiers = soldiers_count
	GameState.soldiers_changed.emit(GameState.soldiers, GameState.get_soldier_cap())
	for _i: int in range(soldiers_count):
		var spawn_pos: Vector2 = Vector2(randf_range(-64.0, 64.0), randf_range(-64.0, 64.0))
		tile_grid.call("spawn_soldier_at", spawn_pos)

func _infer_tutorial_step(data: Dictionary) -> int:
	var bc: Dictionary = data.get("building_counts", {}) as Dictionary
	var step: int = 0
	if int(bc.get("Core", 0)) > 0:
		step = 1
	if int(bc.get("SolarFarm", 0)) > 0:
		step = maxi(step, 2)
	if int(bc.get("Housing", 0)) > 0:
		step = maxi(step, 3)
	for mine: Variant in (data.get("gold_mines", []) as Array):
		if int((mine as Dictionary).get("assigned_count", 0)) > 0:
			step = maxi(step, 4)
			break
	if int(bc.get("Farm", 0)) > 0:
		step = maxi(step, 5)
	for farm: Variant in (data.get("farms", []) as Array):
		if int((farm as Dictionary).get("assigned_count", 0)) > 0:
			step = maxi(step, 6)
			break
	if int(bc.get("Tower", 0)) > 0:
		step = maxi(step, 7)
	for tower: Variant in (data.get("towers", []) as Array):
		if int((tower as Dictionary).get("assigned_count", 0)) > 0:
			step = maxi(step, 8)
			break
	if int(bc.get("Barracks", 0)) > 0:
		step = maxi(step, 9)
	if int(data.get("soldiers", 0)) > 0:
		step = maxi(step, 10)
	if not (data.get("walls", []) as Array).is_empty():
		step = maxi(step, 11)
	if int(bc.get("Lab", 0)) > 0:
		step = maxi(step, 12)
	if int(bc.get("Tower", 0)) >= 3:
		step = maxi(step, 13)
	return step

func reset_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	for soldier: Node in get_tree().get_nodes_in_group("soldiers"):
		soldier.queue_free()

	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid != null:
		tile_grid.call("clear_for_load")
		tile_grid.call("reset_gold_mines")

	var spawner: Node = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner != null:
		spawner.call("reset")

	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null:
		cycle.call("reset")

	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		player.position = Vector2.ZERO

	GameState.reset()

func _show_saved_popup() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 15
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(canvas)

	var label: Label = Label.new()
	label.text = "Game Saved"
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.4))
	label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	label.offset_left = -160.0
	label.offset_top = 10.0
	label.offset_right = -10.0
	label.offset_bottom = 40.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	canvas.add_child(label)

	var tween: Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(canvas.queue_free)
