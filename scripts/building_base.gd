extends AnimatedSprite2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")

var max_hp: int = 100
var _hp: int = 0
var _health_bar: Node2D = null
var _tile_gp: Vector2i = Vector2i(-1, -1)
var _building_name: String = ""
var _dying: bool = false

func _ready() -> void:
	_hp = max_hp
	add_to_group("buildings")
	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -75.0)
	_health_bar.call("setup", max_hp, 60.0)
	add_child(_health_bar)

func take_damage(amount: int) -> void:
	if _dying:
		return
	_hp = maxi(0, _hp - amount)
	_health_bar.call("set_hp", _hp)
	if _hp <= 0:
		_dying = true
		_on_destroyed()

func _on_destroyed() -> void:
	GameState.record_building_destroyed(_building_name)
	remove_from_group("buildings")
	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid != null and _tile_gp != Vector2i(-1, -1):
		tile_grid.call("destroy_building_at", _tile_gp)
	queue_free()
