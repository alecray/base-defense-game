extends Node2D

var _max_hp: int = 100
var _current_hp: int = 100
var _bar_width: float = 48.0

const BAR_HEIGHT: float = 5.0

func setup(max_hp: int, bar_width: float = 48.0) -> void:
	_max_hp = max_hp
	_current_hp = max_hp
	_bar_width = bar_width
	visible = false

func set_hp(current_hp: int) -> void:
	_current_hp = current_hp
	visible = _current_hp < _max_hp
	queue_redraw()

func _draw() -> void:
	var ratio: float = float(_current_hp) / float(_max_hp)
	var x: float = -_bar_width * 0.5
	var y: float = -BAR_HEIGHT * 0.5
	draw_rect(Rect2(x, y, _bar_width, BAR_HEIGHT), Color(0.1, 0.0, 0.0, 0.9))
	var r: float = lerpf(0.15, 1.0, 1.0 - ratio)
	var g: float = lerpf(0.0, 0.75, ratio)
	draw_rect(Rect2(x, y, _bar_width * ratio, BAR_HEIGHT), Color(r, g, 0.05))
