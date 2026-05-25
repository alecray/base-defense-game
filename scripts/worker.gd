extends Node2D

const SPEED: float = 60.0
const ROAM_RADIUS: float = 192.0
const ARRIVAL_THRESHOLD: float = 12.0
const WORK_SPEED: float = 18.0

enum State { ROAMING, TRAVELING, WORKING }

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _state: State = State.ROAMING
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
		State.ROAMING:
			var to_target: Vector2 = _target - position
			if to_target.length() < ARRIVAL_THRESHOLD:
				_pick_new_target()
				return
			if to_target.x != 0.0:
				_sprite.flip_h = to_target.x < 0.0
			position += to_target.normalized() * SPEED * delta
		State.TRAVELING:
			var to_target: Vector2 = _target - position
			if to_target.length() < ARRIVAL_THRESHOLD:
				_state = State.WORKING
				_sprite.play("Working")
				return
			if to_target.x != 0.0:
				_sprite.flip_h = to_target.x < 0.0
			position += to_target.normalized() * SPEED * delta
		State.WORKING:
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
				position += to_roam.normalized() * WORK_SPEED * delta

func _pick_new_target() -> void:
	_target = _home + Vector2(
		randf_range(-ROAM_RADIUS, ROAM_RADIUS),
		randf_range(-ROAM_RADIUS, ROAM_RADIUS)
	)

func is_free() -> bool:
	return _state == State.ROAMING

func assign_to(target_pos: Vector2) -> void:
	_state = State.TRAVELING
	_work_center = target_pos + Vector2(randf_range(-20.0, 20.0), randf_range(-8.0, 8.0))
	_target = _work_center
	_roam_timer = 0.0

func unassign() -> void:
	_state = State.ROAMING
	_sprite.play("Idle")
	_pick_new_target()
