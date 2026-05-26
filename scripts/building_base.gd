extends AnimatedSprite2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")
const FORTIFY_SCENE: PackedScene = preload("res://prefabs/fortification.tscn")

var max_hp: int = 100
var foot_y_offset: float = 64.0
var upgrade_level: int = 0
var _hp: int = 0
var _health_bar: Node2D = null
var _fortification: Node = null
var _tile_gp: Vector2i = Vector2i(-1, -1)
var _building_name: String = ""
var _dying: bool = false
var _damage_cooldown: float = 0.0
var _regen_timer: float = 0.0

func _ready() -> void:
	_hp = max_hp
	add_to_group("buildings")
	offset = Vector2(0.0, -foot_y_offset)
	_health_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_health_bar.position = Vector2(0.0, -38.0 - foot_y_offset)
	_health_bar.call("setup", max_hp, 60.0)
	add_child(_health_bar)

func _process(delta: float) -> void:
	_tick_regen(delta)

func _tick_regen(delta: float) -> void:
	if _dying or _hp >= max_hp:
		return
	if _damage_cooldown > 0.0:
		_damage_cooldown -= delta
		return
	_regen_timer += delta
	if _regen_timer >= CONSTANTS.REGEN_INTERVAL:
		_regen_timer = 0.0
		_hp = mini(_hp + maxi(1, int(float(max_hp) * CONSTANTS.REGEN_PERCENT)), max_hp)
		_health_bar.call("set_hp", _hp)

func take_damage(amount: int) -> void:
	if _dying:
		return
	_damage_cooldown = CONSTANTS.REGEN_COOLDOWN
	_regen_timer = 0.0
	var remaining: int = amount
	if _fortification != null and is_instance_valid(_fortification):
		remaining = int(_fortification.call("absorb_damage", amount))
	if remaining <= 0:
		return
	_hp = maxi(0, _hp - remaining)
	_health_bar.call("set_hp", _hp)
	GameState.notify_building_attacked(global_position)
	if _hp <= 0:
		_dying = true
		_on_destroyed()

func fortify() -> bool:
	if _fortification != null and is_instance_valid(_fortification):
		return false
	if not GameState.spend_coins(CONSTANTS.FORTIFY_COST):
		return false
	_fortification = FORTIFY_SCENE.instantiate() as Node
	_fortification.tree_exiting.connect(_on_fortification_removed)
	add_child(_fortification)
	return true

func restore_fortification(shield_hp: int) -> void:
	if _fortification != null and is_instance_valid(_fortification):
		return
	_fortification = FORTIFY_SCENE.instantiate() as Node
	_fortification.tree_exiting.connect(_on_fortification_removed)
	add_child(_fortification)
	_fortification.call("set_shield", shield_hp)

func is_fortified() -> bool:
	return _fortification != null and is_instance_valid(_fortification)

func get_shield_hp() -> int:
	if _fortification == null or not is_instance_valid(_fortification):
		return 0
	return int(_fortification.call("get_shield"))

func do_upgrade(cost: int, max_level: int) -> bool:
	if upgrade_level >= max_level:
		return false
	if not GameState.spend_coins(cost):
		return false
	upgrade_level += 1
	return true

func _on_fortification_removed() -> void:
	_fortification = null

func get_hp_info() -> Array:
	return [_hp, max_hp]

func repair() -> String:
	if _dying:
		return ""
	if _hp >= max_hp:
		return "Already at full HP."
	var missing: int = max_hp - _hp
	var cost: int = ceili(float(missing) / float(CONSTANTS.BUILDING_REPAIR_HP_PER_COIN))
	if not GameState.spend_coins(cost):
		return "Not enough coins! (%d needed)" % cost
	_hp = max_hp
	_health_bar.call("set_hp", _hp)
	GameState.notify_building_repaired()
	return ""

func _on_destroyed() -> void:
	GameState.record_building_destroyed(_building_name)
	remove_from_group("buildings")
	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid != null and _tile_gp != Vector2i(-1, -1):
		tile_grid.call("destroy_building_at", _tile_gp)
	queue_free()
