extends Node2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")

@onready var _sprite_h: AnimatedSprite2D = $SpriteH
@onready var _sprite_v: AnimatedSprite2D = $SpriteV
@onready var _shape_h: CollisionShape2D = $Body/ShapeH
@onready var _shape_v: CollisionShape2D = $Body/ShapeV

var _hp: int = CONSTANTS.WALL_MAX_HP
var _health_bar: Node2D = null
var _dying: bool = false
var _edge_key: String = ""
var _player_ref: Node2D = null
var _repairing: bool = false
var _repair_accum: float = 0.0

func init(vertical: bool, edge_key: String) -> void:
	_edge_key = edge_key
	_sprite_h.visible = not vertical
	_sprite_v.visible = vertical
	_shape_h.disabled = vertical
	_shape_v.disabled = not vertical

func _ready() -> void:
	z_as_relative = false
	add_to_group("buildings")
	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -20.0)
	_health_bar.call("setup", CONSTANTS.WALL_MAX_HP, 36.0)
	add_child(_health_bar)

func _process(delta: float) -> void:
	if _player_ref == null or not is_instance_valid(_player_ref):
		_player_ref = get_tree().get_first_node_in_group("player") as Node2D
	if _player_ref != null:
		z_index = 0 if _player_ref.global_position.y >= global_position.y else 1
	if _repairing:
		_repair_accum += CONSTANTS.WALL_REPAIR_RATE * delta
		var gained: int = int(_repair_accum)
		if gained > 0:
			_repair_accum -= float(gained)
			_hp = mini(CONSTANTS.WALL_MAX_HP, _hp + gained)
			_health_bar.call("set_hp", _hp)
			if _hp >= CONSTANTS.WALL_MAX_HP:
				_repairing = false

func take_damage(amount: int) -> void:
	if _dying:
		return
	_hp = maxi(0, _hp - amount)
	_health_bar.call("set_hp", _hp)
	if _hp <= 0:
		_dying = true
		_die()

func _die() -> void:
	remove_from_group("buildings")
	var grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if grid != null:
		grid.call("on_wall_destroyed", _edge_key)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(queue_free)

func start_repair() -> String:
	if _repairing:
		return "Already repairing."
	if not GameState.spend_coins(CONSTANTS.WALL_REPAIR_COST):
		return "Not enough coins!"
	_repairing = true
	_repair_accum = 0.0
	return ""

func is_fortified() -> bool:
	return false

func get_shield_hp() -> int:
	return 0
