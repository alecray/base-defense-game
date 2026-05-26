extends Node2D

var _target_pos: Vector2 = Vector2.ZERO
var _damage: int = 0
var _lifetime: float = 5.0

func init(target_pos: Vector2, damage: int) -> void:
	_target_pos = target_pos
	_damage = damage

func _process(delta: float) -> void:
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()
		return
	var to_target: Vector2 = _target_pos - global_position
	if to_target.length() < 10.0:
		_deal_damage()
		queue_free()
		return
	global_position += to_target.normalized() * CONSTANTS.FLYING_ENEMY_PROJECTILE_SPEED * delta
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.45, 0.1))
	draw_circle(Vector2.ZERO, 2.5, Color(1.0, 0.85, 0.5))

func _deal_damage() -> void:
	var nearest: Node2D = null
	var nearest_dist: float = 100.0
	for building: Node in get_tree().get_nodes_in_group("buildings"):
		var b: Node2D = building as Node2D
		var dist: float = _target_pos.distance_to(b.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = b
	if nearest != null:
		nearest.call("take_damage", _damage)
