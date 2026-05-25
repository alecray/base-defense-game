extends Node

const ENEMY_SCENE: PackedScene = preload("res://prefabs/enemy.tscn")
const SPAWN_RADIUS: float = 1400.0
const BASE_INTERVAL: float = 8.0
const MIN_INTERVAL: float = 1.5
const RAMP_DURATION: float = 300.0

var _spawn_timer: float = 0.0
var _elapsed: float = 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	_spawn_timer += delta
	var t: float = minf(_elapsed / RAMP_DURATION, 1.0)
	var interval: float = BASE_INTERVAL + (MIN_INTERVAL - BASE_INTERVAL) * t
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_enemy()

func _spawn_enemy() -> void:
	var angle: float = randf() * TAU
	var pos: Vector2 = Vector2(cos(angle), sin(angle)) * SPAWN_RADIUS
	var instance: Node2D = ENEMY_SCENE.instantiate() as Node2D
	instance.position = pos
	get_parent().add_child(instance)
