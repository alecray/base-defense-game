extends Node2D

const SPEED: float = 500.0

var _target: Node2D = null
var _damage: int = 25

func set_target(target: Node2D, damage: int) -> void:
	_target = target
	_damage = damage

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		queue_free()
		return
	var to_target: Vector2 = _target.global_position - global_position
	if to_target.length() < 10.0:
		_target.call("take_damage", _damage)
		queue_free()
		return
	global_position += to_target.normalized() * SPEED * delta
	rotation = to_target.angle()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color(1.0, 0.85, 0.2))
	draw_circle(Vector2(6.0, 0.0), 2.5, Color(1.0, 0.95, 0.6))
