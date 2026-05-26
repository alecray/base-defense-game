extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = CONSTANTS.ARCANUM_MAX_HP
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if not GameState.arcanum_research_id.is_empty():
		GameState.advance_research(delta)
