extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = 500
	super._ready()
	add_to_group("core_building")
	play("Idle")

func _on_destroyed() -> void:
	remove_from_group("core_building")
	GameState.game_over.emit()
	super._on_destroyed()
