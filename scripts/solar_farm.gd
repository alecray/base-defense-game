extends "res://scripts/building_base.gd"

var _power_timer: float = 0.0

func _ready() -> void:
	max_hp = CONSTANTS.SOLAR_FARM_MAX_HP
	super._ready()
	play("Idle")

func _process(delta: float) -> void:
	super._process(delta)
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null and bool(cycle.call("is_night")):
		return
	_power_timer += delta
	if _power_timer >= CONSTANTS.SOLAR_FARM_POWER_INTERVAL:
		_power_timer -= CONSTANTS.SOLAR_FARM_POWER_INTERVAL
		GameState.add_power(CONSTANTS.SOLAR_FARM_POWER_AMOUNT)
