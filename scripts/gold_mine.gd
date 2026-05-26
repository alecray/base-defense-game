extends Node2D

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _work_point: Marker2D = $WorkPoint

var _tile_gp: Vector2i = Vector2i(-1, -1)
var _assigned_workers: Array = []
var _reserves: int = CONSTANTS.MINE_MAX_RESERVES
var _tick_timer: float = 0.0

func _ready() -> void:
	if _sprite != null and _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation("Idle"):
		_sprite.play("Idle")

func _process(delta: float) -> void:
	if _sprite != null:
		_sprite.modulate = Color.WHITE if has_unlocked_neighbor() else Color(0.4, 0.4, 0.4)
	if _assigned_workers.is_empty():
		return
	_tick_timer += delta
	if _tick_timer >= CONSTANTS.MINE_TICK_INTERVAL:
		_tick_timer = 0.0
		_mine_tick()

func _mine_tick() -> void:
	var earned: int = mini(_assigned_workers.size() * CONSTANTS.MINE_COINS_PER_WORKER, _reserves)
	_reserves -= earned
	GameState.add_coins(earned)
	_show_coin_popup(earned)
	if _reserves <= 0:
		_deplete()

func _deplete() -> void:
	for worker: Node in _assigned_workers:
		worker.call("unassign")
		GameState.record_worker_assigned(-1)
	_assigned_workers.clear()
	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid != null and _tile_gp != Vector2i(-1, -1):
		tile_grid.call("destroy_building_at", _tile_gp)
	queue_free()

func _show_coin_popup(amount: int) -> void:
	var label: Label = Label.new()
	label.text = "+%d" % amount
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	label.position = Vector2(-20.0, -80.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -120.0, 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

func has_unlocked_neighbor() -> bool:
	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid == null or _tile_gp == Vector2i(-1, -1):
		return false
	return bool(tile_grid.call("has_unlocked_neighbor", _tile_gp))

func assign_worker() -> bool:
	if _assigned_workers.size() >= CONSTANTS.MINE_MAX_WORKERS:
		return false
	if GameState.get_free_workers() <= 0:
		return false
	if not has_unlocked_neighbor():
		return false
	var free_worker: Node = null
	for worker: Node in get_tree().get_nodes_in_group("workers"):
		if worker.call("is_free"):
			free_worker = worker
			break
	if free_worker == null:
		return false
	_assigned_workers.append(free_worker)
	free_worker.call("assign_to", _work_point.global_position)
	GameState.record_worker_assigned(1)
	return true

func unassign_worker() -> bool:
	if _assigned_workers.is_empty():
		return false
	var worker: Node = _assigned_workers.pop_back()
	worker.call("unassign")
	GameState.record_worker_assigned(-1)
	return true

func get_assigned_workers() -> int:
	return _assigned_workers.size()

func get_reserves() -> int:
	return _reserves

func set_reserves(value: int) -> void:
	_reserves = maxi(0, value)

func is_fortified() -> bool: return false
func get_shield_hp() -> int: return 0
