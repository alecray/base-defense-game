extends Node

const BUILDING_COSTS: Dictionary = {
	"Core": 100,
	"Barracks": 50,
	"Farm": 75,
	"Tower": 60
}

const WORKER_COST: int = 20
const FORTIFY_COST: int = 75

const BUILDING_MAX_COUNTS: Dictionary = {
	"Core": 1
}

const FOOD_DRAIN_INTERVAL: float = 5.0

var coins: int = 150
var building_counts: Dictionary = {}
var worker_count: int = 0
var assigned_workers: int = 0
var food: int = 100

signal coins_changed(new_amount: int)
signal building_placed(building_name: String)
signal workers_changed(count: int, cap: int, free: int)
signal food_changed(new_amount: int)
signal game_reset
signal game_over

var _food_timer: float = 0.0

func _process(delta: float) -> void:
	if worker_count <= 0:
		return
	_food_timer += delta
	if _food_timer >= FOOD_DRAIN_INTERVAL:
		_food_timer -= FOOD_DRAIN_INTERVAL
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

func get_free_workers() -> int:
	return worker_count - assigned_workers

func record_worker_assigned(delta: int) -> void:
	assigned_workers += delta
	workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())

func get_worker_cap() -> int:
	return get_building_count("Barracks") * 5

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

func reset() -> void:
	coins = 150
	building_counts = {}
	worker_count = 0
	assigned_workers = 0
	food = 100
	_food_timer = 0.0
	game_reset.emit()
	coins_changed.emit(coins)
	food_changed.emit(food)
	workers_changed.emit(worker_count, get_worker_cap(), get_free_workers())
