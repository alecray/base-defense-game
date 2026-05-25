extends "res://scripts/building_base.gd"

@onready var _work_point: Marker2D = $WorkPoint

var _assigned_workers: Array = []
var _food_timer: float = 0.0

func _ready() -> void:
	max_hp = CONSTANTS.FARM_MAX_HP
	super._ready()
	play("Idle")

func _process(delta: float) -> void:
	_tick_regen(delta)
	if _assigned_workers.is_empty():
		return
	_food_timer += delta
	if _food_timer >= CONSTANTS.FARM_FOOD_INTERVAL:
		_food_timer -= CONSTANTS.FARM_FOOD_INTERVAL
		var amount: int = _assigned_workers.size() * CONSTANTS.FARM_FOOD_PER_WORKER
		GameState.add_food(amount)
		_show_food_popup(amount)

func _on_destroyed() -> void:
	for worker: Node in _assigned_workers:
		worker.call("unassign")
		GameState.record_worker_assigned(-1)
	_assigned_workers.clear()
	super._on_destroyed()

func assign_worker() -> bool:
	if GameState.get_free_workers() <= 0:
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

func _show_food_popup(amount: int) -> void:
	var label: Label = Label.new()
	label.text = "+%d food" % amount
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.3))
	label.position = Vector2(-40.0, -80.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -120.0, 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)
