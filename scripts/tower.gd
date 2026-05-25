extends "res://scripts/building_base.gd"

const BULLET_SCENE: PackedScene = preload("res://prefabs/bullet.tscn")

var _assigned_workers: Array = []
var _attack_timer: float = 0.0

func _ready() -> void:
	max_hp = CONSTANTS.TOWER_MAX_HP
	super._ready()
	play("Idle")

func _process(delta: float) -> void:
	_tick_regen(delta)
	if _assigned_workers.is_empty():
		return
	var interval: float = _get_attack_interval()
	_attack_timer += delta
	if _attack_timer >= interval:
		_attack_timer = 0.0
		_attack()

func _get_attack_interval() -> float:
	match _assigned_workers.size():
		1: return CONSTANTS.TOWER_INTERVAL_1
		2: return CONSTANTS.TOWER_INTERVAL_2
		3: return CONSTANTS.TOWER_INTERVAL_3
		_: return CONSTANTS.TOWER_INTERVAL_1

func _attack() -> void:
	var target: Node2D = _find_nearest_enemy()
	if target == null:
		return
	var bullet: Node2D = BULLET_SCENE.instantiate() as Node2D
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.call("set_target", target, CONSTANTS.TOWER_DAMAGE)

func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist: float = CONSTANTS.TOWER_RANGE
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy_node: Node2D = enemy as Node2D
		var dist: float = global_position.distance_to(enemy_node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy_node
	return nearest

func assign_worker() -> bool:
	if _assigned_workers.size() >= CONSTANTS.TOWER_MAX_WORKERS:
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
	free_worker.call("assign_to", global_position + work_offset)
	GameState.record_worker_assigned(1)
	return true

func unassign_worker() -> bool:
	if _assigned_workers.is_empty():
		return false
	var worker: Node = _assigned_workers.pop_back()
	worker.call("unassign")
	GameState.record_worker_assigned(-1)
	return true

func get_assigned_workers() -> int:
	return _assigned_workers.size()

func _on_destroyed() -> void:
	for worker: Node in _assigned_workers:
		worker.call("unassign")
		GameState.record_worker_assigned(-1)
	_assigned_workers.clear()
	super._on_destroyed()
