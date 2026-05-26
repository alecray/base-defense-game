extends Node2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

enum Phase { TUNNELING, EMERGING, SURFACED }

var _phase: Phase = Phase.TUNNELING
var _emerge_pos: Vector2 = Vector2.ZERO
var _target: Node2D = null
var _hp: int = 0
var _health_bar: Node2D = null
var _dying: bool = false
var _attack_timer: float = 0.0
var _emerge_timer: float = 0.0
var _retarget_timer: float = 0.0
var _attacking: bool = false

func _ready() -> void:
	_hp = int(float(CONSTANTS.BURROWER_MAX_HP) * GameState.get_enemy_hp_multiplier())
	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -38.0)
	_health_bar.call("setup", _hp, 28.0)
	_health_bar.visible = false
	add_child(_health_bar)
	_sprite.visible = false
	_pick_emerge_point()

func _pick_emerge_point() -> void:
	var angle: float = randf() * TAU
	var dist: float = randf_range(30.0, CONSTANTS.BURROWER_EMERGE_RADIUS)
	_emerge_pos = Vector2(cos(angle), sin(angle)) * dist

func _process(delta: float) -> void:
	if _dying:
		return
	match _phase:
		Phase.TUNNELING:
			_do_tunneling(delta)
		Phase.EMERGING:
			_do_emerging(delta)
		Phase.SURFACED:
			_do_surfaced(delta)
	queue_redraw()

func _draw() -> void:
	match _phase:
		Phase.TUNNELING:
			draw_circle(Vector2.ZERO, 9.0, Color(0.52, 0.36, 0.18, 0.55))
			draw_circle(Vector2.ZERO, 5.0, Color(0.68, 0.50, 0.28, 0.45))
		Phase.EMERGING:
			var t: float = minf(_emerge_timer / CONSTANTS.BURROWER_EMERGE_WARN_TIME, 1.0)
			var pulse: float = abs(sin(_emerge_timer * TAU * 2.0))
			var radius: float = lerpf(14.0, 28.0, t) + pulse * 6.0
			draw_circle(Vector2.ZERO, radius, Color(0.52, 0.36, 0.18, 0.75))
			draw_circle(Vector2.ZERO, radius * 0.5, Color(0.72, 0.55, 0.3, 0.5 + pulse * 0.3))

func _do_tunneling(delta: float) -> void:
	var to_emerge: Vector2 = _emerge_pos - global_position
	if to_emerge.length() <= 10.0:
		global_position = _emerge_pos
		_phase = Phase.EMERGING
		_emerge_timer = 0.0
		return
	global_position += to_emerge.normalized() * CONSTANTS.BURROWER_TUNNEL_SPEED * delta

func _do_emerging(delta: float) -> void:
	_emerge_timer += delta
	if _emerge_timer >= CONSTANTS.BURROWER_EMERGE_WARN_TIME:
		_surface()

func _surface() -> void:
	add_to_group("enemies")
	_sprite.visible = true
	_health_bar.visible = true
	_play_anim("Idle")
	_phase = Phase.SURFACED
	_retarget_timer = CONSTANTS.ENEMY_RETARGET_INTERVAL

func _do_surfaced(delta: float) -> void:
	_retarget_timer += delta
	var target_gone: bool = _target != null and not is_instance_valid(_target)
	if target_gone:
		_target = null
	if _retarget_timer >= CONSTANTS.ENEMY_RETARGET_INTERVAL or target_gone:
		_retarget_timer = 0.0
		_find_target()

	if _target == null or not is_instance_valid(_target):
		return

	var to_target: Vector2 = _target.global_position - global_position
	var dist: float = to_target.length()

	if dist <= CONSTANTS.BURROWER_ATTACK_RANGE:
		if not _attacking:
			_attacking = true
			_attack_timer = 0.0
		_attack_timer += delta
		if _attack_timer >= CONSTANTS.BURROWER_ATTACK_INTERVAL:
			_attack_timer = 0.0
			_target.call("take_damage", int(float(CONSTANTS.BURROWER_ATTACK_DAMAGE) * GameState.get_enemy_damage_multiplier()))
	else:
		_attacking = false
		if to_target.x != 0.0:
			_sprite.flip_h = to_target.x < 0.0
		global_position += to_target.normalized() * CONSTANTS.BURROWER_SURFACE_SPEED * delta

func _find_target() -> void:
	var non_core: Array[Node2D] = []
	var core: Array[Node2D] = []
	for building: Node in get_tree().get_nodes_in_group("buildings"):
		var b: Node2D = building as Node2D
		if building.is_in_group("core_building"):
			core.append(b)
		else:
			non_core.append(b)
	var candidates: Array[Node2D] = non_core if not non_core.is_empty() else core
	var nearest_dist: float = INF
	var nearest: Node2D = null
	for candidate: Node2D in candidates:
		var dist: float = global_position.distance_to(candidate.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = candidate
	_target = nearest

func _play_anim(anim_name: String) -> void:
	if _sprite.sprite_frames == null:
		return
	if _sprite.sprite_frames.has_animation(anim_name):
		_sprite.play(anim_name)
	elif _sprite.sprite_frames.has_animation("Idle"):
		_sprite.play("Idle")

func take_damage(amount: int) -> void:
	if _dying or _phase != Phase.SURFACED:
		return
	_hp = maxi(0, _hp - amount)
	_health_bar.call("set_hp", _hp)
	if _hp <= 0:
		_dying = true
		_die()

func _die() -> void:
	GameState.add_coins(CONSTANTS.BURROWER_COIN_REWARD)
	GameState.record_enemy_killed()
	remove_from_group("enemies")
	_show_coin_popup()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
	tween.tween_callback(queue_free)

func _show_coin_popup() -> void:
	var label: Label = Label.new()
	label.text = "+%d" % CONSTANTS.BURROWER_COIN_REWARD
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	label.position = Vector2(-20.0, -40.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -70.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)
