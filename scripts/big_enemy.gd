extends Node2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _hp: int = CONSTANTS.BIG_ENEMY_MAX_HP
var _target_node: Node2D = null
var _retarget_timer: float = 0.0
var _attack_timer: float = 0.0
var _attacking: bool = false
var _dying: bool = false
var _health_bar: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -52.0)
	_health_bar.call("setup", CONSTANTS.BIG_ENEMY_MAX_HP, 40.0)
	add_child(_health_bar)
	_retarget_timer = CONSTANTS.ENEMY_RETARGET_INTERVAL
	_play_anim("Walk")

func _process(delta: float) -> void:
	if _dying:
		return

	_retarget_timer += delta
	var target_gone: bool = _target_node != null and not is_instance_valid(_target_node)
	if target_gone:
		_target_node = null
	if _retarget_timer >= CONSTANTS.ENEMY_RETARGET_INTERVAL or target_gone:
		_retarget_timer = 0.0
		_find_target()

	if _target_node == null or not is_instance_valid(_target_node):
		return

	var to_target: Vector2 = _target_node.global_position - global_position
	var dist: float = to_target.length()

	if dist <= CONSTANTS.BIG_ENEMY_ATTACK_RANGE:
		if not _attacking:
			_attacking = true
			_attack_timer = 0.0
			_play_anim("Attack")
		_attack_timer += delta
		if _attack_timer >= CONSTANTS.BIG_ENEMY_ATTACK_INTERVAL:
			_attack_timer = 0.0
			_target_node.call("take_damage", CONSTANTS.BIG_ENEMY_ATTACK_DAMAGE)
	else:
		if _attacking:
			_attacking = false
			_play_anim("Walk")
		global_position += to_target.normalized() * CONSTANTS.BIG_ENEMY_SPEED * delta
		_sprite.flip_h = to_target.x < 0

func _find_target() -> void:
	var non_core: Array[Node2D] = []
	var core: Array[Node2D] = []
	for building: Node in get_tree().get_nodes_in_group("buildings"):
		var building_node: Node2D = building as Node2D
		if building.is_in_group("core_building"):
			core.append(building_node)
		else:
			non_core.append(building_node)
	var candidates: Array[Node2D] = non_core if not non_core.is_empty() else core
	var nearest_dist: float = INF
	var nearest: Node2D = null
	for candidate: Node2D in candidates:
		var dist: float = global_position.distance_to(candidate.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = candidate
	_target_node = nearest

func _play_anim(anim_name: String) -> void:
	if _sprite.sprite_frames == null:
		return
	if _sprite.sprite_frames.has_animation(anim_name):
		_sprite.play(anim_name)
	elif _sprite.sprite_frames.has_animation("Idle"):
		_sprite.play("Idle")

func take_damage(amount: int) -> void:
	if _dying:
		return
	_hp -= amount
	_health_bar.call("set_hp", _hp)
	if _hp <= 0:
		_dying = true
		_die()

func _die() -> void:
	GameState.add_coins(CONSTANTS.BIG_ENEMY_COIN_REWARD)
	remove_from_group("enemies")
	_show_coin_popup()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _show_coin_popup() -> void:
	var label: Label = Label.new()
	label.text = "+%d" % CONSTANTS.BIG_ENEMY_COIN_REWARD
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	label.position = Vector2(-24.0, -56.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -90.0, 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tween.tween_callback(label.queue_free)
