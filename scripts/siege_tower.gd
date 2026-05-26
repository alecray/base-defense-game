extends "res://scripts/building_base.gd"

const SIEGE_PROJECTILE_SCENE: PackedScene = preload("res://prefabs/siege_projectile.tscn")

var _attack_timer: float = 0.0
var _power_drain_timer: float = 0.0

func _ready() -> void:
	max_hp = CONSTANTS.SIEGE_TOWER_MAX_HP
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	_power_drain_timer += delta
	if _power_drain_timer >= CONSTANTS.SIEGE_TOWER_POWER_DRAIN_INTERVAL:
		_power_drain_timer -= CONSTANTS.SIEGE_TOWER_POWER_DRAIN_INTERVAL
		GameState.drain_power(CONSTANTS.SIEGE_TOWER_POWER_DRAIN_AMOUNT)
	if GameState.power <= 0:
		return
	_attack_timer += delta
	if _attack_timer >= CONSTANTS.SIEGE_TOWER_INTERVAL:
		_attack_timer = 0.0
		_attack()

func _attack() -> void:
	var target_pos: Vector2 = _find_cluster_target()
	if target_pos == Vector2.INF:
		return
	var proj: Node2D = SIEGE_PROJECTILE_SCENE.instantiate() as Node2D
	get_parent().add_child(proj)
	proj.global_position = global_position
	proj.call("init", target_pos, CONSTANTS.SIEGE_TOWER_DAMAGE, CONSTANTS.SIEGE_TOWER_AOE_RADIUS)

func _find_cluster_target() -> Vector2:
	var best_pos: Vector2 = Vector2.INF
	var best_score: int = 0
	var all_enemies: Array = get_tree().get_nodes_in_group("enemies")
	for enemy: Node in all_enemies:
		var e: Node2D = enemy as Node2D
		if e.is_in_group("enemy_camps"):
			continue
		if global_position.distance_to(e.global_position) > CONSTANTS.SIEGE_TOWER_RANGE:
			continue
		var score: int = 0
		for other: Node in all_enemies:
			var o: Node2D = other as Node2D
			if o.is_in_group("enemy_camps"):
				continue
			if e.global_position.distance_to(o.global_position) <= CONSTANTS.SIEGE_TOWER_AOE_RADIUS:
				score += 1
		if score > best_score:
			best_score = score
			best_pos = e.global_position
	return best_pos
