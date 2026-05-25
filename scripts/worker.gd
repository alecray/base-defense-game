extends Node2D

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _state: int = 0 # 0=ROAMING, 1=TRAVELING, 2=WORKING
var _home: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.ZERO
var _work_center: Vector2 = Vector2.ZERO
var _work_roam_target: Vector2 = Vector2.ZERO
var _roam_timer: float = 0.0

func _ready() -> void:
	add_to_group("workers")
	_home = position
	_pick_new_target()
	_sprite.play("Idle")

func _process(delta: float) -> void:
	match _state:
		0: # ROAMING
			var to_target: Vector2 = _target - position
			if to_target.length() < CONSTANTS.WORKER_ARRIVAL_THRESHOLD:
				_pick_new_target()
				return
			if to_target.x != 0.0:
				_sprite.flip_h = to_target.x < 0.0
			position += to_target.normalized() * CONSTANTS.WORKER_SPEED * delta
		1: # TRAVELING
			var to_target: Vector2 = _target - position
			if to_target.length() < CONSTANTS.WORKER_ARRIVAL_THRESHOLD:
				_state = 2
				_sprite.play("Working")
				return
			if to_target.x != 0.0:
				_sprite.flip_h = to_target.x < 0.0
			position += to_target.normalized() * CONSTANTS.WORKER_SPEED * delta
		2: # WORKING
			_roam_timer -= delta
			if _roam_timer <= 0.0:
				_roam_timer = randf_range(2.0, 4.0)
				_work_roam_target = _work_center + Vector2(
					randf_range(-20.0, 20.0),
					randf_range(-4.0, 4.0)
				)
			var to_roam: Vector2 = _work_roam_target - position
			if to_roam.length() > 2.0:
				if to_roam.x != 0.0:
					_sprite.flip_h = to_roam.x < 0.0
				position += to_roam.normalized() * CONSTANTS.WORKER_WORK_SPEED * delta

func _pick_new_target() -> void:
	_target = _home + Vector2(
		randf_range(-CONSTANTS.WORKER_ROAM_RADIUS, CONSTANTS.WORKER_ROAM_RADIUS),
		randf_range(-CONSTANTS.WORKER_ROAM_RADIUS, CONSTANTS.WORKER_ROAM_RADIUS)
	)

func is_free() -> bool:
	return _state == 0

func assign_to(target_pos: Vector2) -> void:
	_state = 1
	_work_center = target_pos + Vector2(randf_range(-20.0, 20.0), randf_range(-8.0, 8.0))
	_target = _work_center
	_roam_timer = 0.0

func unassign() -> void:
	_state = 0
	_sprite.play("Idle")
	_pick_new_target()
