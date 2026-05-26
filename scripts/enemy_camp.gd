extends Node2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")
const ENEMY_SCENE: PackedScene = preload("res://prefabs/enemy.tscn")

var _hp: int = CONSTANTS.ENEMY_CAMP_HP
var _health_bar: Node2D = null
var _dying: bool = false
var _spawn_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("enemy_camps")
	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -48.0)
	_health_bar.call("setup", CONSTANTS.ENEMY_CAMP_HP, 44.0)
	add_child(_health_bar)
	_spawn_timer = CONSTANTS.ENEMY_CAMP_SPAWN_INTERVAL * 0.5

func _process(delta: float) -> void:
	if _dying:
		return
	_spawn_timer += delta
	if _spawn_timer >= CONSTANTS.ENEMY_CAMP_SPAWN_INTERVAL:
		_spawn_timer = 0.0
		_spawn_burst()
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 24.0, Color(0.45, 0.08, 0.08))
	draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 32, Color(0.85, 0.2, 0.2), 2.5)
	draw_circle(Vector2.ZERO, 10.0, Color(0.7, 0.15, 0.15))
	# Skull-like crossed lines
	draw_line(Vector2(-7.0, -7.0), Vector2(7.0, 7.0), Color(1.0, 0.3, 0.3), 2.0)
	draw_line(Vector2(7.0, -7.0), Vector2(-7.0, 7.0), Color(1.0, 0.3, 0.3), 2.0)

func _spawn_burst() -> void:
	for _i: int in range(CONSTANTS.ENEMY_CAMP_BURST_SIZE):
		var instance: Node2D = ENEMY_SCENE.instantiate() as Node2D
		var offset: Vector2 = Vector2(randf_range(-30.0, 30.0), randf_range(-30.0, 30.0))
		instance.position = global_position + offset
		get_parent().add_child(instance)

func take_damage(amount: int) -> void:
	if _dying:
		return
	_hp = maxi(0, _hp - amount)
	_health_bar.call("set_hp", _hp)
	if _hp <= 0:
		_dying = true
		_die()

func _die() -> void:
	GameState.add_coins(CONSTANTS.ENEMY_CAMP_REWARD)
	GameState.record_enemy_killed()
	remove_from_group("enemies")
	remove_from_group("enemy_camps")
	_show_coin_popup()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _show_coin_popup() -> void:
	var label: Label = Label.new()
	label.text = "+%d" % CONSTANTS.ENEMY_CAMP_REWARD
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	label.position = Vector2(-24.0, -60.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -100.0, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)
