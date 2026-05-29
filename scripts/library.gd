extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = CONSTANTS.LIBRARY_MAX_HP
	super._ready()
	play("Idle")

func _process(delta: float) -> void:
	super._process(delta)
	if not GameState.library_research_id.is_empty():
		GameState.advance_research(delta)
