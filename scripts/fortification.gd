extends Node2D

const HEALTH_BAR_SCENE: PackedScene = preload("res://prefabs/health_bar.tscn")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _shield: int = 0
var _shield_bar: Node2D = null

func _ready() -> void:
	_shield = CONSTANTS.SHIELD_MAX_HP
	_shield_bar = HEALTH_BAR_SCENE.instantiate() as Node2D
	_shield_bar.position = Vector2(0.0, -50.0)
	_shield_bar.call("setup", CONSTANTS.SHIELD_MAX_HP, 60.0, true)
	add_child(_shield_bar)
	if _sprite != null and _sprite.sprite_frames != null:
		if _sprite.sprite_frames.has_animation("Idle"):
			_sprite.play("Idle")

func absorb_damage(amount: int) -> int:
	var absorbed: int = mini(amount, _shield)
	_shield -= absorbed
	_shield_bar.call("set_hp", _shield)
	if _shield <= 0:
		queue_free()
	return amount - absorbed

func get_shield() -> int:
	return _shield

func set_shield(value: int) -> void:
	_shield = value
	_shield_bar.call("set_hp", _shield)
	if _shield <= 0:
		queue_free()
