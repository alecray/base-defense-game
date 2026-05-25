extends "res://scripts/building_base.gd"

const COIN_INTERVAL: float = 5.0
const COIN_AMOUNT: int = 10

var _timer: float = 0.0

func _ready() -> void:
	max_hp = 500
	super._ready()
	add_to_group("core_building")
	play("Idle")

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= COIN_INTERVAL:
		_timer -= COIN_INTERVAL
		_generate_coins()

func _on_destroyed() -> void:
	remove_from_group("core_building")
	GameState.game_over.emit()
	super._on_destroyed()

func _generate_coins() -> void:
	GameState.add_coins(COIN_AMOUNT)
	_show_coin_popup()

func _show_coin_popup() -> void:
	var label: Label = Label.new()
	label.text = "+%d" % COIN_AMOUNT
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	label.position = Vector2(-20.0, -80.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -120.0, 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)
