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
var food_cap: int = CONSTANTS.FOOD_CAP_BASE
var power: int = CONSTANTS.STARTING_POWER
var power_cap: int = CONSTANTS.POWER_CAP_BASE
var soldiers: int = 0
var enemies_killed_this_run: int = 0
var total_coins_earned: int = 0

signal coins_changed(new_amount: int)
signal building_placed(building_name: String)
signal workers_changed(count: int, cap: int, free: int)
signal food_changed(new_amount: int)
signal power_changed(new_amount: int)
signal soldiers_changed(count: int, cap: int)
signal game_reset
signal game_over
signal first_mine_worker_assigned
signal first_farm_worker_assigned
signal first_tower_worker_assigned
signal first_soldier_bought
signal first_wall_placed
signal building_attacked(world_pos: Vector2)
signal research_completed(upgrade_id: String)
signal research_progress_changed(upgrade_id: String, progress: float)

var lab_research_id: String = ""
var lab_research_progress: float = 0.0
var lab_upgrade_levels: Dictionary = {}

var _food_timer: float = 0.0
var _mine_worker_ever_assigned: bool = false
var _farm_worker_ever_assigned: bool = false
var _tower_worker_ever_assigned: bool = false
var _soldier_ever_bought: bool = false
var _wall_ever_placed: bool = false

func notify_mine_worker_assigned() -> void:
	if _mine_worker_ever_assigned:
		return
	_mine_worker_ever_assigned = true
	first_mine_worker_assigned.emit()

func notify_farm_worker_assigned() -> void:
	if _farm_worker_ever_assigned:
		return
	_farm_worker_ever_assigned = true
	first_farm_worker_assigned.emit()

func notify_tower_worker_assigned() -> void:
	if _tower_worker_ever_assigned:
		return
	_tower_worker_ever_assigned = true
	first_tower_worker_assigned.emit()

func notify_soldier_bought() -> void:
	if _soldier_ever_bought:
		return
	_soldier_ever_bought = true
	first_soldier_bought.emit()

func notify_wall_placed() -> void:
	if _wall_ever_placed:
		return
	_wall_ever_placed = true
	first_wall_placed.emit()

func restore_tutorial_flags(step: int) -> void:
	_mine_worker_ever_assigned = step >= 4
	_farm_worker_ever_assigned = step >= 6
	_tower_worker_ever_assigned = step >= 8
	_soldier_ever_bought = step >= 10
	_wall_ever_placed = step >= 11

func _process(delta: float) -> void:
	if worker_count <= 0:
		return
	_food_timer += delta
	if _food_timer >= CONSTANTS.FOOD_DRAIN_INTERVAL:
		_food_timer -= CONSTANTS.FOOD_DRAIN_INTERVAL
		food = maxi(0, food - worker_count)
		food_changed.emit(food)

func get_armory_damage_bonus() -> int:
	return get_building_count("Armory") * CONSTANTS.ARMORY_DAMAGE_BONUS

func get_armory_hp_bonus() -> int:
	return get_building_count("Armory") * CONSTANTS.ARMORY_HP_BONUS

func get_enemy_hp_multiplier() -> float:
	return 1.0 + (float(total_coins_earned) / CONSTANTS.THREAT_SCALE_COINS) * CONSTANTS.THREAT_HP_SCALE

func get_enemy_damage_multiplier() -> float:
	return 1.0 + (float(total_coins_earned) / CONSTANTS.THREAT_SCALE_COINS) * CONSTANTS.THREAT_DAMAGE_SCALE

func add_coins(amount: int) -> void:
	coins += amount
	total_coins_earned += amount
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true

func add_food(amount: int) -> void:
	food = mini(food + amount, food_cap)
	food_changed.emit(food)

func add_power(amount: int) -> void:
	power = mini(power + amount, power_cap)
	power_changed.emit(power)

func upgrade_food_cap() -> bool:
	if not spend_coins(CONSTANTS.FOOD_CAP_UPGRADE_COST):
		return false
	food_cap += CONSTANTS.FOOD_CAP_UPGRADE_AMOUNT
	food_changed.emit(food)
	return true

func upgrade_power_cap() -> bool:
	if not spend_coins(CONSTANTS.POWER_CAP_UPGRADE_COST):
		return false
	power_cap += CONSTANTS.POWER_CAP_UPGRADE_AMOUNT
	power_changed.emit(power)
	return true

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
	return get_building_count("Housing") * CONSTANTS.HOUSING_WORKER_BONUS

func get_soldier_cap() -> int:
	return get_building_count("Barracks") * CONSTANTS.BARRACKS_SOLDIER_BONUS

func buy_soldier() -> bool:
	if soldiers >= get_soldier_cap():
		return false
	if not spend_coins(CONSTANTS.SOLDIER_COST):
		return false
	soldiers += 1
	soldiers_changed.emit(soldiers, get_soldier_cap())
	notify_soldier_bought()
	return true

func record_enemy_killed() -> void:
	enemies_killed_this_run += 1

func record_soldier_killed() -> void:
	soldiers = maxi(0, soldiers - 1)
	soldiers_changed.emit(soldiers, get_soldier_cap())

func record_building_placed(building_name: String) -> void:
	building_counts[building_name] = building_counts.get(building_name, 0) + 1
	building_placed.emit(building_name)
	if building_name == "Housing":
		workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())
	if building_name == "Barracks":
		soldiers_changed.emit(soldiers, get_soldier_cap())

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
	if building_name == "Armory":
		return get_upgrade_level("armory_blueprint") > 0
	return get_building_count("Core") > 0

func record_building_destroyed(building_name: String) -> void:
	if building_name.is_empty():
		return
	var count: int = get_building_count(building_name)
	if count > 0:
		building_counts[building_name] = count - 1
	if building_name == "Housing":
		workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())
	if building_name == "Barracks":
		soldiers = mini(soldiers, get_soldier_cap())
		soldiers_changed.emit(soldiers, get_soldier_cap())

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
		"armory_blueprint":
			return CONSTANTS.LAB_RESEARCH_ARMORY_DURATION
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
	power_cap = CONSTANTS.POWER_CAP_BASE
	food_cap = CONSTANTS.FOOD_CAP_BASE
	soldiers = 0
	enemies_killed_this_run = 0
	total_coins_earned = 0
	_mine_worker_ever_assigned = false
	_farm_worker_ever_assigned = false
	_tower_worker_ever_assigned = false
	_soldier_ever_bought = false
	_wall_ever_placed = false
	game_reset.emit()
	coins_changed.emit(coins)
	food_changed.emit(food)
	power_changed.emit(power)
	soldiers_changed.emit(soldiers, get_soldier_cap())
	workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())
