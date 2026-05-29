extends Node2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")
const RUNNER_SCENE: PackedScene = preload("res://prefabs/runner.tscn")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _shield_hp: int = CONSTANTS.BOSS_SHIELD_HP
var _hp: int = CONSTANTS.BOSS_MAX_HP
var _shielded: bool = true
var _target_node: Node2D = null
var _retarget_timer: float = 0.0
var _attack_timer: float = 0.0
var _attacking: bool = false
var _dying: bool = false
var _shield_bar: Node2D = null
var _health_bar: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	_hp = int(float(CONSTANTS.BOSS_MAX_HP) * GameState.get_enemy_hp_multiplier())
	_shield_hp = int(float(CONSTANTS.BOSS_SHIELD_HP) * GameState.get_enemy_hp_multiplier())

	_shield_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_shield_bar.position = Vector2(0.0, -72.0)
	_shield_bar.call("setup", _shield_hp, 52.0, true)
	_shield_bar.visible = true
	add_child(_shield_bar)

	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -60.0)
	_health_bar.call("setup", _hp, 52.0)
	_health_bar.visible = false
	add_child(_health_bar)

	_retarget_timer = CONSTANTS.ENEMY_RETARGET_INTERVAL
	_play_anim("Walk")
	_refresh_tint()

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

	if dist <= CONSTANTS.BOSS_ATTACK_RANGE:
		if not _attacking:
			_attacking = true
			_attack_timer = 0.0
			_play_anim("Attack")
		_attack_timer += delta
		if _attack_timer >= CONSTANTS.BOSS_ATTACK_INTERVAL:
			_attack_timer = 0.0
			_target_node.call("take_damage", int(float(CONSTANTS.BOSS_ATTACK_DAMAGE) * GameState.get_enemy_damage_multiplier()))
	else:
		if _attacking:
			_attacking = false
			_play_anim("Walk")
		global_position += to_target.normalized() * CONSTANTS.BOSS_SPEED * delta
		_sprite.flip_h = to_target.x < 0.0

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

func _refresh_tint() -> void:
	if _shielded:
		_sprite.modulate = Color(0.5, 0.6, 1.0, 1.0)
	else:
		_sprite.modulate = Color(0.9, 0.15, 0.15, 1.0)

func take_damage(amount: int) -> void:
	if _dying:
		return
	if _shielded:
		_shield_hp -= amount
		_shield_bar.call("set_hp", _shield_hp)
		if _shield_hp <= 0:
			_break_shield()
	else:
		_hp -= amount
		_health_bar.call("set_hp", _hp)
		if _hp <= 0:
			_dying = true
			_die()

func _break_shield() -> void:
	_shielded = false
	_shield_bar.visible = false
	_health_bar.visible = true
	_refresh_tint()
	var tween: Tween = create_tween()
	tween.tween_property(_sprite, "modulate:a", 0.2, 0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_sprite, "modulate:a", 0.2, 0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_SINE)

func _die() -> void:
	GameState.add_coins(CONSTANTS.BOSS_COIN_REWARD)
	GameState.record_enemy_killed()
	remove_from_group("enemies")
	remove_from_group("boss")
	_spawn_runners()
	_show_coin_popup()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.45)
	tween.tween_callback(queue_free)

func _spawn_runners() -> void:
	var parent: Node = get_parent()
	if parent == null:
		return
	for i: int in range(CONSTANTS.BOSS_SPLIT_COUNT):
		var angle: float = (float(i) / float(CONSTANTS.BOSS_SPLIT_COUNT)) * TAU
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * 60.0
		var runner: Node2D = RUNNER_SCENE.instantiate() as Node2D
		runner.position = global_position + offset
		parent.add_child(runner)

func _show_coin_popup() -> void:
	var label: Label = Label.new()
	label.text = "+%d" % CONSTANTS.BOSS_COIN_REWARD
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	label.position = Vector2(-36.0, -80.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -130.0, 1.2)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(label.queue_free)
