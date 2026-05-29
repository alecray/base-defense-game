extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = CONSTANTS.CORE_MAX_HP
	super._ready()
	add_to_group("core_building")
	play("Idle")

func _on_destroyed() -> void:
	remove_from_group("core_building")
	GameState.trigger_game_over()
	super._on_destroyed()
