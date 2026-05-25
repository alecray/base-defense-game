extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = 150
	super._ready()
	play("Idle")
