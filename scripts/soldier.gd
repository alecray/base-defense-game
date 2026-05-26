extends Node2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

enum State { PATROL, CHASE, ATTACK }

var _state: State = State.PATROL
var _target: Node2D = null
var _patrol_points: Array = []
var _patrol_index: int = 0
var _retarget_timer: float = 0.0
var _attack_timer: float = 0.0
var _patrol_refresh_timer: float = 0.0
var _hp: int = CONSTANTS.SOLDIER_HP
var _health_bar: Node2D = null
var _dying: bool = false

func _ready() -> void:
	add_to_group("soldiers")
	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -38.0)
	_health_bar.call("setup", CONSTANTS.SOLDIER_HP, 28.0)
	add_child(_health_bar)
	_refresh_patrol_points()
	_sprite.play("Idle")

func _process(delta: float) -> void:
	if _dying:
		return
	_retarget_timer += delta
	if _retarget_timer >= CONSTANTS.SOLDIER_RETARGET_INTERVAL:
		_retarget_timer = 0.0
		_update_target()
	if _state == State.PATROL:
		_patrol_refresh_timer += delta
		if _patrol_refresh_timer >= CONSTANTS.SOLDIER_PATROL_REFRESH:
			_patrol_refresh_timer = 0.0
			_refresh_patrol_points()
	match _state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.ATTACK:
			_do_attack(delta)

func _update_target() -> void:
	if _target != null and not is_instance_valid(_target):
		_target = null
	var threat: Node2D = _find_threat()
	if threat != null:
		_target = threat
		var dist: float = global_position.distance_to(_target.global_position)
		_state = State.ATTACK if dist <= CONSTANTS.SOLDIER_ATTACK_RANGE else State.CHASE
	else:
		if _target != null:
			_refresh_patrol_points()
		_target = null
		_state = State.PATROL

func _find_threat() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		var e: Node2D = enemy as Node2D
		if _is_threatening(e):
			var dist: float = global_position.distance_to(e.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = e
	return nearest

func _is_threatening(enemy: Node2D) -> bool:
	for building: Node in get_tree().get_nodes_in_group("buildings"):
		var b: Node2D = building as Node2D
		if b.global_position.distance_to(enemy.global_position) <= CONSTANTS.SOLDIER_THREAT_RANGE:
			return true
	return false

func _do_patrol(delta: float) -> void:
	if _patrol_points.is_empty():
		_refresh_patrol_points()
		return
	var dest: Vector2 = _patrol_points[_patrol_index] as Vector2
	var to_dest: Vector2 = dest - global_position
	if to_dest.length() < CONSTANTS.WORKER_ARRIVAL_THRESHOLD:
		_patrol_index = (_patrol_index + 1) % _patrol_points.size()
		return
	if to_dest.x != 0.0:
		_sprite.flip_h = to_dest.x < 0.0
	global_position += to_dest.normalized() * CONSTANTS.SOLDIER_SPEED * delta

func _do_chase(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_state = State.PATROL
		return
	if global_position.distance_to(Vector2.ZERO) > CONSTANTS.SOLDIER_CHASE_RADIUS:
		_state = State.PATROL
		return
	var to_target: Vector2 = _target.global_position - global_position
	if to_target.length() <= CONSTANTS.SOLDIER_ATTACK_RANGE:
		_state = State.ATTACK
		_attack_timer = 0.0
		return
	if to_target.x != 0.0:
		_sprite.flip_h = to_target.x < 0.0
	global_position += to_target.normalized() * CONSTANTS.SOLDIER_SPEED * delta

func _do_attack(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_state = State.PATROL
		return
	if global_position.distance_to(_target.global_position) > CONSTANTS.SOLDIER_ATTACK_RANGE:
		_state = State.CHASE
		return
	_attack_timer += delta
	if _attack_timer >= CONSTANTS.SOLDIER_ATTACK_INTERVAL:
		_attack_timer = 0.0
		_target.call("take_damage", CONSTANTS.SOLDIER_ATTACK_DAMAGE)

func _refresh_patrol_points() -> void:
	var grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if grid == null:
		return
	_patrol_points = grid.call("get_patrol_points") as Array
	if _patrol_points.is_empty():
		return
	# Start from the patrol point closest to current position
	var best_idx: int = 0
	var best_dist: float = INF
	for i: int in range(_patrol_points.size()):
		var d: float = global_position.distance_to(_patrol_points[i] as Vector2)
		if d < best_dist:
			best_dist = d
			best_idx = i
	_patrol_index = best_idx

func take_damage(amount: int) -> void:
	if _dying:
		return
	_hp = maxi(0, _hp - amount)
	_health_bar.call("set_hp", _hp)
	if _hp <= 0:
		_dying = true
		_die()

func _die() -> void:
	GameState.record_soldier_killed()
	remove_from_group("soldiers")
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
