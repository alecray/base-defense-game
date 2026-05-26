extends Node

const SAVE_PATH: String = "user://legacy.json"

const UPGRADE_DEFS: Array = [
	{"id": "coin_cache",      "name": "Coin Cache",        "desc": "+75 starting coins",    "cost": 30, "max": 5, "bonus": 75},
	{"id": "food_reserve",    "name": "Food Reserve",      "desc": "+30 starting food",     "cost": 25, "max": 3, "bonus": 30},
	{"id": "power_grid",      "name": "Power Grid",        "desc": "+20 starting power cap", "cost": 40, "max": 3, "bonus": 20},
	{"id": "veteran_workers", "name": "Veteran Workforce", "desc": "+1 starting worker",    "cost": 50, "max": 3, "bonus": 1},
]

var legacy_points: int = 0
var best_days: int = 0
var total_runs: int = 0
var upgrades: Dictionary = {}

func _ready() -> void:
	load_data()

func get_upgrade_level(id: String) -> int:
	return int(upgrades.get(id, 0))

func get_upgrade_max(id: String) -> int:
	for def_variant: Variant in UPGRADE_DEFS:
		var def: Dictionary = def_variant as Dictionary
		if str(def["id"]) == id:
			return int(def["max"])
	return 0

func get_upgrade_cost(id: String) -> int:
	for def_variant: Variant in UPGRADE_DEFS:
		var def: Dictionary = def_variant as Dictionary
		if str(def["id"]) == id:
			return int(def["cost"])
	return -1

func is_maxed(id: String) -> bool:
	return get_upgrade_level(id) >= get_upgrade_max(id)

func can_afford(id: String) -> bool:
	if is_maxed(id):
		return false
	return legacy_points >= get_upgrade_cost(id)

func buy_upgrade(id: String) -> bool:
	if not can_afford(id):
		return false
	legacy_points -= get_upgrade_cost(id)
	upgrades[id] = get_upgrade_level(id) + 1
	save()
	return true

func award_points(days: int) -> int:
	var earned: int = days * CONSTANTS.LEGACY_POINTS_PER_DAY
	legacy_points += earned
	total_runs += 1
	if days > best_days:
		best_days = days
	save()
	return earned

func apply_bonuses() -> void:
	var coin_bonus: int = get_upgrade_level("coin_cache") * _get_bonus("coin_cache")
	if coin_bonus > 0:
		GameState.coins += coin_bonus
		GameState.coins_changed.emit(GameState.coins)

	var food_bonus: int = get_upgrade_level("food_reserve") * _get_bonus("food_reserve")
	if food_bonus > 0:
		GameState.add_food(food_bonus)

	var power_bonus: int = get_upgrade_level("power_grid") * _get_bonus("power_grid")
	if power_bonus > 0:
		GameState.power_cap += power_bonus
		GameState.power_changed.emit(GameState.power)

func get_worker_bonus() -> int:
	return get_upgrade_level("veteran_workers") * _get_bonus("veteran_workers")

func _get_bonus(id: String) -> int:
	for def_variant: Variant in UPGRADE_DEFS:
		var def: Dictionary = def_variant as Dictionary
		if str(def["id"]) == id:
			return int(def["bonus"])
	return 0

func save() -> void:
	var data: Dictionary = {}
	data["legacy_points"] = legacy_points
	data["best_days"] = best_days
	data["total_runs"] = total_runs
	data["upgrades"] = upgrades.duplicate()
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))
	file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return
	var data: Dictionary = json.data as Dictionary
	legacy_points = int(data.get("legacy_points", 0))
	best_days = int(data.get("best_days", 0))
	total_runs = int(data.get("total_runs", 0))
	upgrades = (data.get("upgrades", {}) as Dictionary).duplicate()

func reset_all() -> void:
	legacy_points = 0
	best_days = 0
	total_runs = 0
	upgrades = {}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
