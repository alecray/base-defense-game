extends Node2D

func _ready() -> void:
	GameState.rally_point_changed.connect(_on_rally_point_changed)
	GameState.game_reset.connect(_on_reset)
	visible = false

func _on_rally_point_changed(pos: Vector2) -> void:
	global_position = pos
	visible = GameState.has_custom_rally_point
	queue_redraw()

func _on_reset() -> void:
	visible = false

func _draw() -> void:
	var color: Color = Color(0.3, 0.9, 1.0, 0.85)
	draw_circle(Vector2.ZERO, 14.0, Color(color.r, color.g, color.b, 0.18))
	draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 24, color, 2.0)
	draw_line(Vector2(-10.0, 0.0), Vector2(10.0, 0.0), color, 2.0)
	draw_line(Vector2(0.0, -10.0), Vector2(0.0, 10.0), color, 2.0)
	draw_circle(Vector2.ZERO, 3.0, color)
