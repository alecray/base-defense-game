extends Node

const ENEMY_SCENE: PackedScene = preload("res://prefabs/enemy.tscn")

var _spawn_timer: float = 0.0
var _elapsed: float = 0.0

func _ready() -> void:
	add_to_group("enemy_spawner")

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < CONSTANTS.ENEMY_SPAWN_START_DELAY:
		return
	_spawn_timer += delta
	var t: float = minf((_elapsed - CONSTANTS.ENEMY_SPAWN_START_DELAY) / CONSTANTS.ENEMY_SPAWN_RAMP_DURATION, 1.0)
	var interval: float = CONSTANTS.ENEMY_SPAWN_BASE_INTERVAL + (CONSTANTS.ENEMY_SPAWN_MIN_INTERVAL - CONSTANTS.ENEMY_SPAWN_BASE_INTERVAL) * t
	if _is_night():
		interval *= CONSTANTS.NIGHT_SPAWN_INTERVAL_MULT
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_clump()

func reset() -> void:
	_elapsed = 0.0
	_spawn_timer = 0.0

func _is_night() -> bool:
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	return cycle != null and bool(cycle.call("is_night"))

func _spawn_clump() -> void:
	var max_clump: int = CONSTANTS.NIGHT_SPAWN_CLUMP_MAX if _is_night() else CONSTANTS.ENEMY_SPAWN_CLUMP_MAX
	var count: int = randi_range(1, max_clump)
	var angle: float = randf() * TAU
	var pos: Vector2 = Vector2(cos(angle), sin(angle)) * CONSTANTS.ENEMY_SPAWN_RADIUS
	for _i: int in range(count):
		var instance: Node2D = ENEMY_SCENE.instantiate() as Node2D
		instance.position = pos + Vector2(randf_range(-CONSTANTS.ENEMY_SPAWN_SCATTER, CONSTANTS.ENEMY_SPAWN_SCATTER), randf_range(-CONSTANTS.ENEMY_SPAWN_SCATTER, CONSTANTS.ENEMY_SPAWN_SCATTER))
		get_parent().add_child(instance)
