extends Control

const MM_SIZE: float = 160.0
const MM_PAD: float = 12.0
const BORDER: float = 2.0

const COLOR_UNLOCKED: Color = Color(0.56, 0.60, 0.54, 0.95)
const COLOR_LOCKED: Color   = Color(0.22, 0.24, 0.21, 0.85)

const BUILDING_COLORS: Dictionary = {
	"Core":      Color(0.30, 0.60, 1.00),
	"Housing":   Color(0.80, 0.70, 0.50),
	"Farm":      Color(0.25, 0.85, 0.30),
	"Tower":     Color(1.00, 0.80, 0.20),
	"Lab":       Color(0.75, 0.35, 0.95),
	"SolarFarm": Color(1.00, 0.65, 0.15),
	"Barracks":  Color(0.85, 0.30, 0.30),
	"GoldMine":  Color(1.00, 0.85, 0.20),
	"Armory":    Color(1.00, 0.55, 0.10),
}

var _grid_cols: int = 15
var _grid_rows: int = 15

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	offset_left   = MM_PAD
	offset_bottom = -MM_PAD
	offset_right  = offset_left  + MM_SIZE + BORDER * 2.0
	offset_top    = offset_bottom - MM_SIZE - BORDER * 2.0
	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid != null:
		_grid_cols = int(tile_grid.get("grid_cols"))
		_grid_rows = int(tile_grid.get("grid_rows"))

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var total: Vector2 = Vector2(MM_SIZE + BORDER * 2.0, MM_SIZE + BORDER * 2.0)
	draw_rect(Rect2(Vector2.ZERO, total), Color(0.0, 0.0, 0.0, 0.85))
	draw_rect(Rect2(Vector2(BORDER, BORDER), Vector2(MM_SIZE, MM_SIZE)), Color(0.12, 0.13, 0.11, 1.0))

	var tile_grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if tile_grid != null:
		var tile_data: Array = tile_grid.call("get_minimap_tile_data") as Array
		var cw: float = MM_SIZE / float(_grid_cols)
		var ch: float = MM_SIZE / float(_grid_rows)
		for entry: Variant in tile_data:
			var d: Dictionary = entry as Dictionary
			var gp: Vector2i = d["gp"] as Vector2i
			var unlocked: bool = bool(d["unlocked"])
			var building: String = str(d["building"])
			var rx: float = BORDER + float(gp.x) * cw
			var ry: float = BORDER + float(gp.y) * ch
			var gap: float = 0.5
			draw_rect(Rect2(rx + gap, ry + gap, cw - gap * 2.0, ch - gap * 2.0),
					  COLOR_UNLOCKED if unlocked else COLOR_LOCKED)
			if unlocked and not building.is_empty() and BUILDING_COLORS.has(building):
				var inset: float = 2.0
				draw_rect(Rect2(rx + inset, ry + inset, cw - inset * 2.0, ch - inset * 2.0),
						  BUILDING_COLORS[building])

	for soldier: Node in get_tree().get_nodes_in_group("soldiers"):
		var mp: Vector2 = _world_to_mm((soldier as Node2D).global_position)
		draw_circle(mp, 2.0, Color(0.3, 0.6, 1.0, 0.9))

	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		if (enemy as Node2D).is_in_group("enemy_camps"):
			continue
		var mp: Vector2 = _world_to_mm((enemy as Node2D).global_position)
		draw_circle(mp, 2.0, Color(1.0, 0.2, 0.2, 0.9))

	for camp: Node in get_tree().get_nodes_in_group("enemy_camps"):
		var mp: Vector2 = _world_to_mm((camp as Node2D).global_position)
		draw_rect(Rect2(mp - Vector2(4.0, 4.0), Vector2(8.0, 8.0)), Color(0.85, 0.15, 0.15, 1.0))

	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		var pp: Vector2 = _world_to_mm(player.global_position)
		draw_circle(pp, 3.5, Color(1.0, 0.95, 0.15))

func _world_to_mm(world_pos: Vector2) -> Vector2:
	var half_w: float = float(_grid_cols * CONSTANTS.TILE_SIZE) * 0.5
	var half_h: float = float(_grid_rows * CONSTANTS.TILE_SIZE) * 0.5
	var u: float = (world_pos.x + half_w) / float(_grid_cols * CONSTANTS.TILE_SIZE)
	var v: float = (world_pos.y + half_h) / float(_grid_rows * CONSTANTS.TILE_SIZE)
	return Vector2(BORDER + u * MM_SIZE, BORDER + v * MM_SIZE)
