extends Node

const ENEMY_SCENE: PackedScene = preload("res://prefabs/enemy.tscn")
const SPAWN_RADIUS: float = 1400.0
const START_DELAY: float = 30.0
const BASE_INTERVAL: float = 8.0
const MIN_INTERVAL: float = 1.5
const RAMP_DURATION: float = 300.0

var _spawn_timer: float = 0.0
var _elapsed: float = 0.0

func _ready() -> void:
	add_to_group("enemy_spawner")

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < START_DELAY:
		return
	_spawn_timer += delta
	var t: float = minf((_elapsed - START_DELAY) / RAMP_DURATION, 1.0)
	var interval: float = BASE_INTERVAL + (MIN_INTERVAL - BASE_INTERVAL) * t
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_clump()

func reset() -> void:
	_elapsed = 0.0
	_spawn_timer = 0.0

func _spawn_clump() -> void:
	var count: int = randi_range(1, 5)
	var angle: float = randf() * TAU
	var pos: Vector2 = Vector2(cos(angle), sin(angle)) * SPAWN_RADIUS
	for _i: int in range(count):
		var instance: Node2D = ENEMY_SCENE.instantiate() as Node2D
		instance.position = pos + Vector2(randf_range(-48.0, 48.0), randf_range(-48.0, 48.0))
		get_parent().add_child(instance)
