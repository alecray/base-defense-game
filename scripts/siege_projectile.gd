extends Node2D

const EXPLODE_DURATION: float = 0.4

var _target_pos: Vector2 = Vector2.ZERO
var _damage: int = 0
var _aoe_radius: float = 0.0
var _in_flight: bool = true
var _exploding: bool = false
var _explode_timer: float = 0.0

func init(target_pos: Vector2, damage: int, aoe_radius: float) -> void:
	_target_pos = target_pos
	_damage = damage
	_aoe_radius = aoe_radius

func _process(delta: float) -> void:
	queue_redraw()
	if _in_flight:
		var to_target: Vector2 = _target_pos - global_position
		if to_target.length() < 12.0:
			_start_explode()
			return
		global_position += to_target.normalized() * CONSTANTS.SIEGE_PROJECTILE_SPEED * delta
	elif _exploding:
		_explode_timer += delta
		if _explode_timer >= EXPLODE_DURATION:
			queue_free()

func _start_explode() -> void:
	_in_flight = false
	_exploding = true
	global_position = _target_pos
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		var e: Node2D = enemy as Node2D
		if global_position.distance_to(e.global_position) <= _aoe_radius:
			e.call("take_damage", _damage)

func _draw() -> void:
	if _in_flight:
		draw_circle(Vector2.ZERO, 7.0, Color(0.2, 0.12, 0.05))
		draw_circle(Vector2.ZERO, 4.5, Color(0.55, 0.35, 0.12))
	elif _exploding:
		var t: float = minf(_explode_timer / EXPLODE_DURATION, 1.0)
		var r: float = _aoe_radius * t
		var a: float = 1.0 - t
		draw_circle(Vector2.ZERO, r, Color(1.0, 0.45, 0.1, a * 0.35))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(1.0, 0.65, 0.2, a), 3.0)
