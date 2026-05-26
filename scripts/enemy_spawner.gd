extends Node

const ENEMY_SCENE: PackedScene = preload("res://prefabs/enemy.tscn")
const BIG_ENEMY_SCENE: PackedScene = preload("res://prefabs/big_enemy.tscn")

var _elapsed: float = 0.0
var _big_spawn_timer: float = 0.0
var _in_night: bool = false
var _wave_number: int = 0
var _wave_timer: float = 0.0
var _wave_angle: float = 0.0
var _burst_queue: int = 0
var _burst_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy_spawner")

func _process(delta: float) -> void:
	_elapsed += delta

	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	var intensity: float = float(cycle.call("get_night_intensity")) if cycle != null else 0.0

	if intensity <= 0.0:
		if _in_night:
			_in_night = false
			_burst_queue = 0
		return

	var day: int = int(cycle.call("get_day")) if cycle != null else 1

	if not _in_night:
		_in_night = true
		_wave_number = 0
		_wave_timer = CONSTANTS.WAVE_INITIAL_DELAY
		_burst_queue = 0

	# Big enemy — independent of wave system, starts after first full cycle
	var first_cycle: float = CONSTANTS.DAY_DURATION + CONSTANTS.NIGHT_DURATION
	if _elapsed >= first_cycle:
		_big_spawn_timer += delta
		var t: float = minf(float(day - 1) / float(CONSTANTS.ENEMY_SPAWN_RAMP_DAYS), 1.0)
		var big_interval: float = lerpf(CONSTANTS.BIG_ENEMY_SPAWN_INTERVAL, CONSTANTS.BIG_ENEMY_SPAWN_MIN_INTERVAL, t)
		if _big_spawn_timer >= big_interval:
			_big_spawn_timer = 0.0
			_spawn_big_enemy()

	# Drain burst queue — one enemy every WAVE_BURST_INTERVAL
	if _burst_queue > 0:
		_burst_timer -= delta
		if _burst_timer <= 0.0:
			_burst_timer = CONSTANTS.WAVE_BURST_INTERVAL
			_spawn_wave_enemy()
			_burst_queue -= 1
			if _burst_queue == 0:
				_wave_timer = CONSTANTS.WAVE_COOLDOWN
		return

	# Countdown to next wave
	_wave_timer -= delta
	if _wave_timer <= 0.0:
		_start_wave(day)

func reset() -> void:
	_elapsed = 0.0
	_big_spawn_timer = 0.0
	_in_night = false
	_wave_number = 0
	_wave_timer = 0.0
	_burst_queue = 0
	_burst_timer = 0.0

func _start_wave(day: int) -> void:
	_wave_number += 1
	var count: int = CONSTANTS.WAVE_BASE_COUNT + (day - 1) * CONSTANTS.WAVE_COUNT_PER_DAY + (_wave_number - 1) * CONSTANTS.WAVE_COUNT_PER_WAVE
	_wave_angle = randf() * TAU
	_burst_queue = count
	_burst_timer = 0.0

func _spawn_wave_enemy() -> void:
	var pos: Vector2 = Vector2(cos(_wave_angle), sin(_wave_angle)) * CONSTANTS.ENEMY_SPAWN_RADIUS
	pos += Vector2(randf_range(-CONSTANTS.ENEMY_SPAWN_SCATTER, CONSTANTS.ENEMY_SPAWN_SCATTER),
				   randf_range(-CONSTANTS.ENEMY_SPAWN_SCATTER, CONSTANTS.ENEMY_SPAWN_SCATTER))
	var instance: Node2D = ENEMY_SCENE.instantiate() as Node2D
	instance.position = pos
	get_parent().add_child(instance)

func _spawn_big_enemy() -> void:
	var angle: float = randf() * TAU
	var pos: Vector2 = Vector2(cos(angle), sin(angle)) * CONSTANTS.ENEMY_SPAWN_RADIUS
	var instance: Node2D = BIG_ENEMY_SCENE.instantiate() as Node2D
	instance.position = pos
	get_parent().add_child(instance)
