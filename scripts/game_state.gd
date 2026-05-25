extends Node

const BUILDING_MAX_COUNTS: Dictionary = {
	"Core": 1,
	"Lab": 1
}

var coins: int = CONSTANTS.STARTING_COINS
var building_counts: Dictionary = {}
var worker_count: int = 0
var assigned_workers: int = 0
var food: int = CONSTANTS.STARTING_FOOD
var power: int = CONSTANTS.STARTING_POWER

signal coins_changed(new_amount: int)
signal building_placed(building_name: String)
signal workers_changed(count: int, cap: int, free: int)
signal food_changed(new_amount: int)
signal power_changed(new_amount: int)
signal game_reset
signal game_over
signal research_completed(upgrade_id: String)
signal research_progress_changed(upgrade_id: String, progress: float)

var lab_research_id: String = ""
var lab_research_progress: float = 0.0
var lab_upgrade_levels: Dictionary = {}

var _food_timer: float = 0.0

func _process(delta: float) -> void:
	if worker_count <= 0:
		return
	_food_timer += delta
	if _food_timer >= CONSTANTS.FOOD_DRAIN_INTERVAL:
		_food_timer -= CONSTANTS.FOOD_DRAIN_INTERVAL
		food = maxi(0, food - worker_count)
		food_changed.emit(food)

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true

func add_food(amount: int) -> void:
	food += amount
	food_changed.emit(food)

func add_power(amount: int) -> void:
	power += amount
	power_changed.emit(power)

func drain_power(amount: int) -> bool:
	if power < amount:
		return false
	power -= amount
	power_changed.emit(power)
	return true

func get_free_workers() -> int:
	return worker_count - assigned_workers

func record_worker_assigned(delta: int) -> void:
	assigned_workers += delta
	workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())

func get_worker_cap() -> int:
	return get_building_count("Barracks") * CONSTANTS.BARRACKS_WORKER_BONUS

func record_building_placed(building_name: String) -> void:
	building_counts[building_name] = building_counts.get(building_name, 0) + 1
	building_placed.emit(building_name)
	if building_name == "Barracks":
		workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())

func record_worker_hired() -> void:
	worker_count += 1
	workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())

func get_building_count(building_name: String) -> int:
	return building_counts.get(building_name, 0)

func is_at_building_limit(building_name: String) -> bool:
	if not BUILDING_MAX_COUNTS.has(building_name):
		return false
	return get_building_count(building_name) >= BUILDING_MAX_COUNTS[building_name]

func has_prerequisite(building_name: String) -> bool:
	if building_name == "Core":
		return true
	return get_building_count("Core") > 0

func record_building_destroyed(building_name: String) -> void:
	if building_name.is_empty():
		return
	var count: int = get_building_count(building_name)
	if count > 0:
		building_counts[building_name] = count - 1
	if building_name == "Barracks":
		workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())

func start_research(upgrade_id: String) -> void:
	lab_research_id = upgrade_id
	lab_research_progress = 0.0

func advance_research(delta: float) -> void:
	if lab_research_id.is_empty():
		return
	var duration: float = _get_research_duration(lab_research_id)
	lab_research_progress = minf(lab_research_progress + delta, duration)
	research_progress_changed.emit(lab_research_id, lab_research_progress / duration)
	if lab_research_progress >= duration:
		_complete_research()

func _get_research_duration(id: String) -> float:
	match id:
		"turret_damage":
			return CONSTANTS.LAB_RESEARCH_TURRET_DAMAGE_DURATION
		_:
			return 60.0

func _complete_research() -> void:
	lab_upgrade_levels[lab_research_id] = lab_upgrade_levels.get(lab_research_id, 0) + 1
	var completed_id: String = lab_research_id
	lab_research_id = ""
	lab_research_progress = 0.0
	research_completed.emit(completed_id)

func get_upgrade_level(upgrade_id: String) -> int:
	return lab_upgrade_levels.get(upgrade_id, 0)

func get_turret_damage() -> int:
	return CONSTANTS.TOWER_DAMAGE + get_upgrade_level("turret_damage") * CONSTANTS.LAB_TURRET_DAMAGE_UPGRADE_AMOUNT

func reset() -> void:
	coins = CONSTANTS.STARTING_COINS
	building_counts = {}
	worker_count = 0
	assigned_workers = 0
	food = CONSTANTS.STARTING_FOOD
	_food_timer = 0.0
	lab_research_id = ""
	lab_research_progress = 0.0
	lab_upgrade_levels = {}
	power = CONSTANTS.STARTING_POWER
	game_reset.emit()
	coins_changed.emit(coins)
	food_changed.emit(food)
	power_changed.emit(power)
	workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())
