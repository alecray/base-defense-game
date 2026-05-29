extends "res://scripts/building_base.gd"

func _ready() -> void:
	max_hp = CONSTANTS.MARKET_MAX_HP
	super._ready()
	play("Idle")
	GameState.food_changed.connect(_on_food_changed)
	GameState.power_changed.connect(_on_power_changed)

func _on_food_changed(new_amount: int) -> void:
	var threshold: int = int(float(GameState.food_cap) * CONSTANTS.MARKET_FOOD_THRESHOLD_FRACTION)
	var excess: int = new_amount - threshold
	if excess <= 0:
		return
	var coins_earned: int = int(excess / float(CONSTANTS.MARKET_FOOD_PER_COIN))
	if coins_earned <= 0:
		return
	GameState.consume_food(coins_earned * CONSTANTS.MARKET_FOOD_PER_COIN)
	GameState.add_coins(coins_earned)
	_show_coins_pop(coins_earned)

func _on_power_changed(new_amount: int) -> void:
	var threshold: int = int(float(GameState.power_cap) * CONSTANTS.MARKET_POWER_THRESHOLD_FRACTION)
	var excess: int = new_amount - threshold
	if excess <= 0:
		return
	var coins_earned: int = int(excess / float(CONSTANTS.MARKET_POWER_PER_COIN))
	if coins_earned <= 0:
		return
	GameState.drain_power(coins_earned * CONSTANTS.MARKET_POWER_PER_COIN)
	GameState.add_coins(coins_earned)
	_show_coins_pop(coins_earned)

func _show_coins_pop(amount: int) -> void:
	var label: Label = Label.new()
	label.text = "+%d" % amount
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	label.add_theme_font_size_override("font_size", 14)
	label.position = Vector2(-16.0, -48.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 28.0, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.4)
	tween.tween_callback(label.queue_free)
