extends Node2D

const HIT_RADIUS: float = 10.0

var _direction: Vector2 = Vector2.ZERO
var _lifetime: float = CONSTANTS.PLAYER_BULLET_LIFETIME
var _spent: bool = false

func init(dir: Vector2) -> void:
	_direction = dir.normalized()

func _process(delta: float) -> void:
	if _spent:
		return
	global_position += _direction * CONSTANTS.PLAYER_BULLET_SPEED * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()
		return
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy_node: Node2D = enemy as Node2D
		if global_position.distance_to(enemy_node.global_position) <= HIT_RADIUS:
			enemy_node.call("take_damage", CONSTANTS.PLAYER_BULLET_DAMAGE)
			_spent = true
			queue_free()
			return

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color(1.0, 0.9, 0.2))
