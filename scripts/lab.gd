extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = CONSTANTS.LAB_MAX_HP
	super._ready()

func _process(delta: float) -> void:
	_tick_regen(delta)
	if not GameState.lab_research_id.is_empty():
		GameState.advance_research(delta)
