extends "res://scripts/building_base.gd"

@onready var _work_point: Marker2D = $WorkPoint

var _assigned_workers: Array = []

func _ready() -> void:
	max_hp = CONSTANTS.STOREHOUSE_MAX_HP
	super._ready()
	play("Idle")

func _on_destroyed() -> void:
	for worker: Node in _assigned_workers:
		worker.call("unassign")
		GameState.record_worker_assigned(-1)
	var count: int = _assigned_workers.size()
	_assigned_workers.clear()
	_revert_caps(count)
	super._on_destroyed()

func assign_worker() -> bool:
	if _assigned_workers.size() >= CONSTANTS.STOREHOUSE_MAX_WORKERS:
		return false
	if GameState.get_free_workers() <= 0:
		return false
	var free_worker: Node = null
	for worker: Node in get_tree().get_nodes_in_group("workers"):
		if worker.call("is_free"):
			free_worker = worker
			break
	if free_worker == null:
		return false
	_assigned_workers.append(free_worker)
	free_worker.call("assign_to", _work_point.global_position)
	GameState.record_worker_assigned(1)
	GameState.food_cap += CONSTANTS.STOREHOUSE_FOOD_CAP_PER_WORKER
	GameState.power_cap += CONSTANTS.STOREHOUSE_POWER_CAP_PER_WORKER
	GameState.food_changed.emit(GameState.food)
	GameState.power_changed.emit(GameState.power)
	return true

func unassign_worker() -> bool:
	if _assigned_workers.is_empty():
		return false
	var worker: Node = _assigned_workers.pop_back()
	worker.call("unassign")
	GameState.record_worker_assigned(-1)
	_revert_caps(1)
	return true

func get_assigned_workers() -> int:
	return _assigned_workers.size()

func _revert_caps(count: int) -> void:
	GameState.food_cap = maxi(CONSTANTS.FOOD_CAP_BASE, GameState.food_cap - count * CONSTANTS.STOREHOUSE_FOOD_CAP_PER_WORKER)
	GameState.power_cap = maxi(CONSTANTS.POWER_CAP_BASE, GameState.power_cap - count * CONSTANTS.STOREHOUSE_POWER_CAP_PER_WORKER)
	GameState.food = mini(GameState.food, GameState.food_cap)
	GameState.power = mini(GameState.power, GameState.power_cap)
	GameState.food_changed.emit(GameState.food)
	GameState.power_changed.emit(GameState.power)
