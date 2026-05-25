extends Node2D

class TileEntry:
	var area: Area2D
	var rect: ColorRect
	var label: Label
	var unlocked: bool
	var building: String

	func _init(a: Area2D, r: ColorRect, lbl: Label, u: bool) -> void:
		area = a
		rect = r
		label = lbl
		unlocked = u
		building = ""

@export var grid_cols: int = 15
@export var grid_rows: int = 15

const TILE_SIZE: int = 128
const TILE_GAP: int = 2

const COLOR_UNLOCKED: Color = Color("a9b2a2")
const COLOR_PURCHASABLE: Color = Color("6e7469")

const CORE_SCENE: PackedScene = preload("res://prefabs/core.tscn")
const BARRACKS_SCENE: PackedScene = preload("res://prefabs/barracks.tscn")
const FARM_SCENE: PackedScene = preload("res://prefabs/farm.tscn")
const TOWER_SCENE: PackedScene = preload("res://prefabs/tower.tscn")
const WORKER_SCENE: PackedScene = preload("res://prefabs/worker.tscn")

var _tiles: Dictionary = {}

func _ready() -> void:
	add_to_group("tile_grid")
	_generate_grid()
	_connect_shop()

func _generate_grid() -> void:
	@warning_ignore("integer_division")
	var center: Vector2i = Vector2i(grid_cols / 2, grid_rows / 2)
	for y: int in range(grid_rows):
		for x: int in range(grid_cols):
			var gp: Vector2i = Vector2i(x, y)
			_create_tile(gp, gp == center)

func _create_tile(gp: Vector2i, unlocked: bool) -> void:
	var half: Vector2 = Vector2(grid_cols * TILE_SIZE * 0.5, grid_rows * TILE_SIZE * 0.5)

	var area: Area2D = Area2D.new()
	area.position = Vector2(gp.x * TILE_SIZE, gp.y * TILE_SIZE) - half
	area.collision_layer = 2
	area.collision_mask = 0
	area.z_index = -1
	area.set_meta("tile_gp", gp)
	area.set_meta("tile_unlocked", unlocked)
	area.set_meta("tile_has_building", false)

	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(TILE_SIZE - TILE_GAP, TILE_SIZE - TILE_GAP)

	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = rect_shape
	shape.position = Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	area.add_child(shape)

	var color_rect: ColorRect = ColorRect.new()
	color_rect.size = Vector2(TILE_SIZE - TILE_GAP, TILE_SIZE - TILE_GAP)
	color_rect.position = Vector2(TILE_GAP * 0.5, TILE_GAP * 0.5)
	color_rect.color = COLOR_UNLOCKED if unlocked else COLOR_PURCHASABLE
	area.add_child(color_rect)

	var cost_label: Label = Label.new()
	cost_label.size = Vector2(TILE_SIZE - TILE_GAP, TILE_SIZE - TILE_GAP)
	cost_label.position = Vector2(TILE_GAP * 0.5, TILE_GAP * 0.5)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.text = "%d" % get_tile_cost(gp)
	cost_label.visible = not unlocked
	area.add_child(cost_label)

	add_child(area)
	_tiles[gp] = TileEntry.new(area, color_rect, cost_label, unlocked)

func _connect_shop() -> void:
	var shop: Node = get_tree().get_first_node_in_group("shop_ui")
	if shop != null:
		shop.connect("building_purchased", Callable(self, "place_building"))
	var worker_ui: Node = get_tree().get_first_node_in_group("worker_ui")
	if worker_ui != null:
		worker_ui.connect("worker_purchased", Callable(self, "_on_worker_purchased"))


func get_tile_cost(gp: Vector2i) -> int:
	@warning_ignore("integer_division")
	var center: Vector2i = Vector2i(grid_cols / 2, grid_rows / 2)
	var dist: int = maxi(absi(gp.x - center.x), absi(gp.y - center.y))
	if dist <= 0:
		return 0
	return int(round(10.0 * pow(1.5, float(dist - 1))))

func purchase_tile(gp: Vector2i) -> void:
	if not _tiles.has(gp):
		return
	var tile: TileEntry = _tiles[gp]
	if tile.unlocked:
		return
	if GameState.get_building_count("Core") == 0:
		return
	var cost: int = get_tile_cost(gp)
	if not GameState.spend_coins(cost):
		return
	_set_unlocked(gp, true)

func place_building(building_name: String, gp: Vector2i) -> void:
	if not _tiles.has(gp):
		return
	var tile: TileEntry = _tiles[gp]
	if not tile.unlocked or not tile.building.is_empty():
		return

	var scene: PackedScene
	match building_name:
		"Core":
			scene = CORE_SCENE
		"Barracks":
			scene = BARRACKS_SCENE
		"Farm":
			scene = FARM_SCENE
		"Tower":
			scene = TOWER_SCENE
		_:
			return

	if not GameState.has_prerequisite(building_name) or GameState.is_at_building_limit(building_name):
		return

	var cost: int = GameState.BUILDING_COSTS.get(building_name, 0)
	if not GameState.spend_coins(cost):
		return

	tile.building = building_name
	tile.area.set_meta("tile_has_building", true)
	tile.area.set_meta("tile_building", building_name)
	GameState.record_building_placed(building_name)
	_update_tile_visual(gp)

	var instance: Node2D = scene.instantiate() as Node2D
	instance.position = tile.area.position + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	add_child(instance)
	instance.set("_tile_gp", gp)
	instance.set("_building_name", building_name)
	tile.area.set_meta("tile_building_node", instance)

func _set_unlocked(gp: Vector2i, value: bool) -> void:
	var tile: TileEntry = _tiles[gp]
	tile.unlocked = value
	tile.area.set_meta("tile_unlocked", value)
	if value:
		tile.label.visible = false
	_update_tile_visual(gp)

func _update_tile_visual(gp: Vector2i) -> void:
	var tile: TileEntry = _tiles[gp]
	if tile.unlocked:
		tile.rect.color = COLOR_UNLOCKED
	else:
		tile.rect.color = COLOR_PURCHASABLE

func _on_worker_purchased(gp: Vector2i) -> void:
	if not _tiles.has(gp):
		return
	var tile: TileEntry = _tiles[gp]
	var instance: Node2D = WORKER_SCENE.instantiate() as Node2D
	instance.position = tile.area.position + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	add_child(instance)
	GameState.record_worker_hired()

func get_save_data() -> Array:
	var result: Array = []
	for gp: Vector2i in _tiles:
		var tile: TileEntry = _tiles[gp]
		if not tile.unlocked:
			continue
		var entry: Dictionary = {}
		entry["gp"] = [gp.x, gp.y]
		entry["building"] = tile.building
		result.append(entry)
	return result

func get_farm_save_data() -> Array:
	var result: Array = []
	for gp: Vector2i in _tiles:
		var tile: TileEntry = _tiles[gp]
		if tile.building != "Farm":
			continue
		if not tile.area.has_meta("tile_building_node"):
			continue
		var farm_node: Node = tile.area.get_meta("tile_building_node") as Node
		var entry: Dictionary = {}
		entry["gp"] = [gp.x, gp.y]
		entry["assigned_count"] = int(farm_node.call("get_assigned_workers"))
		result.append(entry)
	return result

func clear_for_load() -> void:
	for worker: Node in get_tree().get_nodes_in_group("workers"):
		worker.queue_free()
	@warning_ignore("integer_division")
	var center: Vector2i = Vector2i(grid_cols / 2, grid_rows / 2)
	for gp: Vector2i in _tiles:
		var tile: TileEntry = _tiles[gp]
		if tile.area.has_meta("tile_building_node"):
			var node: Node = tile.area.get_meta("tile_building_node") as Node
			node.queue_free()
			tile.area.remove_meta("tile_building_node")
		if tile.area.has_meta("tile_building"):
			tile.area.remove_meta("tile_building")
		tile.area.set_meta("tile_has_building", false)
		tile.building = ""
		var is_center: bool = gp == center
		tile.unlocked = is_center
		tile.area.set_meta("tile_unlocked", is_center)
		tile.label.visible = not is_center
		_update_tile_visual(gp)

func unlock_tile_free(gp: Vector2i) -> void:
	if not _tiles.has(gp):
		return
	_set_unlocked(gp, true)

func place_building_from_save(building_name: String, gp: Vector2i) -> void:
	if not _tiles.has(gp):
		return
	var tile: TileEntry = _tiles[gp]
	if not tile.unlocked:
		return
	var scene: PackedScene
	match building_name:
		"Core":
			scene = CORE_SCENE
		"Barracks":
			scene = BARRACKS_SCENE
		"Farm":
			scene = FARM_SCENE
		"Tower":
			scene = TOWER_SCENE
		_:
			return
	tile.building = building_name
	tile.area.set_meta("tile_has_building", true)
	tile.area.set_meta("tile_building", building_name)
	_update_tile_visual(gp)
	var instance: Node2D = scene.instantiate() as Node2D
	instance.position = tile.area.position + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	add_child(instance)
	instance.set("_tile_gp", gp)
	instance.set("_building_name", building_name)
	tile.area.set_meta("tile_building_node", instance)

func destroy_building_at(gp: Vector2i) -> void:
	if not _tiles.has(gp):
		return
	var tile: TileEntry = _tiles[gp]
	tile.building = ""
	tile.area.set_meta("tile_has_building", false)
	if tile.area.has_meta("tile_building"):
		tile.area.remove_meta("tile_building")
	if tile.area.has_meta("tile_building_node"):
		tile.area.remove_meta("tile_building_node")

func spawn_worker_at(pos: Vector2) -> void:
	var instance: Node2D = WORKER_SCENE.instantiate() as Node2D
	instance.position = pos
	add_child(instance)

func get_farm_at(gp: Vector2i) -> Node:
	if not _tiles.has(gp):
		return null
	var tile: TileEntry = _tiles[gp]
	if not tile.area.has_meta("tile_building_node"):
		return null
	return tile.area.get_meta("tile_building_node") as Node
