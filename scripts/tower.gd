extends "res://scripts/building_base.gd"

const RANGE: float = 300.0
const ATTACK_INTERVAL: float = 1.5
const DAMAGE: int = 25

const BULLET_SCENE: PackedScene = preload("res://prefabs/bullet.tscn")

var _attack_timer: float = 0.0

func _ready() -> void:
	max_hp = 200
	super._ready()
	play("Idle")

func _process(delta: float) -> void:
	_attack_timer += delta
	if _attack_timer >= ATTACK_INTERVAL:
		_attack_timer = 0.0
		_attack()

func _attack() -> void:
	var target: Node2D = _find_nearest_enemy()
	if target == null:
		return
	var bullet: Node2D = BULLET_SCENE.instantiate() as Node2D
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.call("set_target", target, DAMAGE)

func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist: float = RANGE
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy_node: Node2D = enemy as Node2D
		var dist: float = global_position.distance_to(enemy_node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy_node
	return nearest
