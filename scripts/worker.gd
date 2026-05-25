extends Node2D

const SPEED: float = 60.0
const ROAM_RADIUS: float = 192.0
const ARRIVAL_THRESHOLD: float = 12.0

enum State { ROAMING, TRAVELING, WORKING }

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _state: State = State.ROAMING
var _home: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.ZERO

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
			position += to_target.normalized() * SPEED * delta
		State.TRAVELING:
			var to_target: Vector2 = _target - position
			if to_target.length() < ARRIVAL_THRESHOLD:
				_state = State.WORKING
				_sprite.play("Working")
				return
			position += to_target.normalized() * SPEED * delta
		State.WORKING:
			pass

func _pick_new_target() -> void:
	_target = _home + Vector2(
		randf_range(-ROAM_RADIUS, ROAM_RADIUS),
		randf_range(-ROAM_RADIUS, ROAM_RADIUS)
	)

func is_free() -> bool:
	return _state == State.ROAMING

func assign_to(target_pos: Vector2) -> void:
	_state = State.TRAVELING
	_target = target_pos

func unassign() -> void:
	_state = State.ROAMING
	_sprite.play("Idle")
	_pick_new_target()
