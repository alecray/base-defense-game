extends Node

const ENEMY_SCENE: PackedScene = preload("res://prefabs/enemy.tscn")
const BIG_ENEMY_SCENE: PackedScene = preload("res://prefabs/big_enemy.tscn")

var _spawn_timer: float = 0.0
var _big_spawn_timer: float = 0.0
var _elapsed: float = 0.0

func _ready() -> void:
	add_to_group("enemy_spawner")

func _process(delta: float) -> void:
	_elapsed += delta

	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	var intensity: float = float(cycle.call("get_night_intensity")) if cycle != null else 0.0

	if intensity <= 0.0:
		_spawn_timer = 0.0
		_big_spawn_timer = 0.0
		return

	var day: int = int(cycle.call("get_day")) if cycle != null else 1
	var t: float = minf(float(day - 1) / float(CONSTANTS.ENEMY_SPAWN_RAMP_DAYS), 1.0)

	_spawn_timer += delta
	var base_interval: float = lerpf(CONSTANTS.ENEMY_SPAWN_BASE_INTERVAL, CONSTANTS.ENEMY_SPAWN_MIN_INTERVAL, t)
	if _spawn_timer >= base_interval / intensity:
		_spawn_timer = 0.0
		_spawn_clump(t, intensity)

	var first_cycle: float = CONSTANTS.DAY_DURATION + CONSTANTS.NIGHT_DURATION
	if _elapsed >= first_cycle:
		_big_spawn_timer += delta
		var big_base: float = lerpf(CONSTANTS.BIG_ENEMY_SPAWN_INTERVAL, CONSTANTS.BIG_ENEMY_SPAWN_MIN_INTERVAL, t)
		if _big_spawn_timer >= big_base / intensity:
			_big_spawn_timer = 0.0
			_spawn_big_enemy()

func reset() -> void:
	_elapsed = 0.0
	_spawn_timer = 0.0
	_big_spawn_timer = 0.0

func _spawn_clump(t: float, intensity: float) -> void:
	var max_clump: int = maxi(1, roundi(lerpf(1.0, float(CONSTANTS.NIGHT_SPAWN_CLUMP_MAX), t) * intensity))
	var count: int = randi_range(1, max_clump)
	var angle: float = randf() * TAU
	var pos: Vector2 = Vector2(cos(angle), sin(angle)) * CONSTANTS.ENEMY_SPAWN_RADIUS
	for _i: int in range(count):
		var instance: Node2D = ENEMY_SCENE.instantiate() as Node2D
		instance.position = pos + Vector2(randf_range(-CONSTANTS.ENEMY_SPAWN_SCATTER, CONSTANTS.ENEMY_SPAWN_SCATTER), randf_range(-CONSTANTS.ENEMY_SPAWN_SCATTER, CONSTANTS.ENEMY_SPAWN_SCATTER))
		get_parent().add_child(instance)

func _spawn_big_enemy() -> void:
	var angle: float = randf() * TAU
	var pos: Vector2 = Vector2(cos(angle), sin(angle)) * CONSTANTS.ENEMY_SPAWN_RADIUS
	var instance: Node2D = BIG_ENEMY_SCENE.instantiate() as Node2D
	instance.position = pos
	get_parent().add_child(instance)
