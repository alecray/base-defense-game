extends Node

var _cycle_timer: float = 0.0
var _overlay: ColorRect = null

func _ready() -> void:
	add_to_group("day_night_cycle")
	_build_overlay()

func _build_overlay() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 1
	add_child(canvas)
	_overlay = ColorRect.new()
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.color = Color(0.02, 0.02, 0.12, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_overlay)

func _process(delta: float) -> void:
	_cycle_timer += delta
	var cycle_duration: float = CONSTANTS.DAY_DURATION + CONSTANTS.NIGHT_DURATION
	if _cycle_timer >= cycle_duration:
		_cycle_timer -= cycle_duration
	_update_overlay(cycle_duration)

func _update_overlay(cycle_duration: float) -> void:
	var t: float = _cycle_timer / cycle_duration
	var day_frac: float = CONSTANTS.DAY_DURATION / cycle_duration
	var trans: float = CONSTANTS.DAY_NIGHT_TRANSITION / cycle_duration
	var alpha: float
	if t < day_frac - trans:
		alpha = 0.0
	elif t < day_frac:
		alpha = smoothstep(0.0, 1.0, (t - (day_frac - trans)) / trans) * 0.5
	elif t < 1.0 - trans:
		alpha = 0.5
	else:
		alpha = smoothstep(0.0, 1.0, 1.0 - (t - (1.0 - trans)) / trans) * 0.5
	_overlay.color.a = alpha

func is_night() -> bool:
	return _cycle_timer >= CONSTANTS.DAY_DURATION

func reset() -> void:
	_cycle_timer = 0.0
	if _overlay != null:
		_overlay.color.a = 0.0
