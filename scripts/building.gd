extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = CONSTANTS.HOUSING_MAX_HP
	super._ready()
	play("Idle")
