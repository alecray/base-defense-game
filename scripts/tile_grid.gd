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

const COLOR_UNLOCKED: Color = Color("a9b2a2")
const COLOR_PURCHASABLE: Color = Color("6e7469")

const CORE_SCENE: PackedScene = preload("res://prefabs/core.tscn")
const HOUSING_SCENE: PackedScene = preload("res://prefabs/housing.tscn")
const FARM_SCENE: PackedScene = preload("res://prefabs/farm.tscn")
const TOWER_SCENE: PackedScene = preload("res://prefabs/tower.tscn")
const WORKER_SCENE: PackedScene = preload("res://prefabs/worker.tscn")
const GOLD_MINE_SCENE: PackedScene = preload("res://prefabs/gold_mine.tscn")
const LAB_SCENE: PackedScene = preload("res://prefabs/lab.tscn")
const SOLAR_FARM_SCENE: PackedScene = preload("res://prefabs/solar_farm.tscn")
const BARRACKS_SCENE: PackedScene = preload("res://prefabs/barracks.tscn")
const SOLDIER_SCENE: PackedScene = preload("res://prefabs/soldier.tscn")
const WALL_SCENE: PackedScene = preload("res://prefabs/wall.tscn")

var _tiles: Dictionary = {}
var _walls: Dictionary = {}

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
	_place_gold_mines(center)

func _place_gold_mines(center: Vector2i) -> void:
	var cardinal: Array[Vector2i] = [
		Vector2i(center.x, center.y - 1),
		Vector2i(center.x, center.y + 1),
		Vector2i(center.x - 1, center.y),
		Vector2i(center.x + 1, center.y),
	]
	var valid: Array[Vector2i] = []
	for gp: Vector2i in cardinal:
		if _tiles.has(gp):
			valid.append(gp)
	valid.shuffle()
	var first_gp: Vector2i = valid[0]
	_place_gold_mine_at(first_gp)

	var candidates: Array[Vector2i] = []
	for gp: Vector2i in _tiles:
		if gp != center and gp != first_gp and not _tiles[gp].unlocked:
			candidates.append(gp)
	candidates.shuffle()
	for i: int in range(mini(CONSTANTS.EXTRA_MINE_COUNT, candidates.size())):
		_place_gold_mine_at(candidates[i])

func _place_gold_mine_at(gp: Vector2i) -> void:
	var tile: TileEntry = _tiles[gp]
	tile.unlocked = true
	tile.area.set_meta("tile_unlocked", true)
	tile.label.visible = false
	tile.rect.color = COLOR_UNLOCKED if has_unlocked_neighbor(gp) else COLOR_PURCHASABLE
	tile.building = "GoldMine"
	tile.area.set_meta("tile_has_building", true)
	tile.area.set_meta("tile_building", "GoldMine")
	var instance: Node2D = GOLD_MINE_SCENE.instantiate() as Node2D
	instance.position = tile.area.position + Vector2(CONSTANTS.TILE_SIZE * 0.5, CONSTANTS.TILE_SIZE * 0.5)
	add_child(instance)
	instance.set("_tile_gp", gp)
	tile.area.set_meta("tile_building_node", instance)

func _get_neighbors(gp: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dx: int in [-1, 0, 1]:
		for dy: int in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var neighbor: Vector2i = Vector2i(gp.x + dx, gp.y + dy)
			if _tiles.has(neighbor):
				result.append(neighbor)
	return result

func has_unlocked_neighbor(gp: Vector2i) -> bool:
	for neighbor: Vector2i in _get_neighbors(gp):
		if _tiles[neighbor].unlocked:
			return true
	return false

func reset_gold_mines() -> void:
	@warning_ignore("integer_division")
	_place_gold_mines(Vector2i(grid_cols / 2, grid_rows / 2))

func _create_tile(gp: Vector2i, unlocked: bool) -> void:
	var half: Vector2 = Vector2(grid_cols * CONSTANTS.TILE_SIZE * 0.5, grid_rows * CONSTANTS.TILE_SIZE * 0.5)

	var area: Area2D = Area2D.new()
	area.position = Vector2(gp.x * CONSTANTS.TILE_SIZE, gp.y * CONSTANTS.TILE_SIZE) - half
	area.collision_layer = 2
	area.collision_mask = 0
	area.z_index = -1
	area.set_meta("tile_gp", gp)
	area.set_meta("tile_unlocked", unlocked)
	area.set_meta("tile_has_building", false)

	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(CONSTANTS.TILE_SIZE - CONSTANTS.TILE_GAP, CONSTANTS.TILE_SIZE - CONSTANTS.TILE_GAP)

	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = rect_shape
	shape.position = Vector2(CONSTANTS.TILE_SIZE * 0.5, CONSTANTS.TILE_SIZE * 0.5)
	area.add_child(shape)

	var color_rect: ColorRect = ColorRect.new()
	color_rect.size = Vector2(CONSTANTS.TILE_SIZE - CONSTANTS.TILE_GAP, CONSTANTS.TILE_SIZE - CONSTANTS.TILE_GAP)
	color_rect.position = Vector2(CONSTANTS.TILE_GAP * 0.5, CONSTANTS.TILE_GAP * 0.5)
	color_rect.color = COLOR_UNLOCKED if unlocked else COLOR_PURCHASABLE
	area.add_child(color_rect)

	var cost_label: Label = Label.new()
	cost_label.size = Vector2(CONSTANTS.TILE_SIZE - CONSTANTS.TILE_GAP, CONSTANTS.TILE_SIZE - CONSTANTS.TILE_GAP)
	cost_label.position = Vector2(CONSTANTS.TILE_GAP * 0.5, CONSTANTS.TILE_GAP * 0.5)
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
	return int(round(CONSTANTS.TILE_COST_BASE * pow(CONSTANTS.TILE_COST_SCALE, float(dist - 1))))

func purchase_tile(gp: Vector2i) -> void:
	if not _tiles.has(gp):
		return
	var tile: TileEntry = _tiles[gp]
	if tile.unlocked:
		return
	if GameState.get_building_count("Core") == 0:
		return
	if not has_unlocked_neighbor(gp):
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
		"Housing":
			scene = HOUSING_SCENE
		"Farm":
			scene = FARM_SCENE
		"Tower":
			scene = TOWER_SCENE
		"Lab":
			scene = LAB_SCENE
		"SolarFarm":
			scene = SOLAR_FARM_SCENE
		"Barracks":
			scene = BARRACKS_SCENE
		_:
			return

	if not GameState.has_prerequisite(building_name) or GameState.is_at_building_limit(building_name):
		return

	var cost: int = CONSTANTS.BUILDING_COSTS.get(building_name, 0)
	if not GameState.spend_coins(cost):
		return

	tile.building = building_name
	tile.area.set_meta("tile_has_building", true)
	tile.area.set_meta("tile_building", building_name)
	GameState.record_building_placed(building_name)
	_update_tile_visual(gp)

	var instance: Node2D = scene.instantiate() as Node2D
	instance.position = tile.area.position + Vector2(CONSTANTS.TILE_SIZE * 0.5, CONSTANTS.TILE_SIZE * 0.5)
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
		_refresh_adjacent_mine_colors(gp)
	_update_tile_visual(gp)

func _refresh_adjacent_mine_colors(gp: Vector2i) -> void:
	for neighbor: Vector2i in _get_neighbors(gp):
		if not _tiles.has(neighbor):
			continue
		var neighbor_tile: TileEntry = _tiles[neighbor]
		if neighbor_tile.building == "GoldMine":
			neighbor_tile.rect.color = COLOR_UNLOCKED if has_unlocked_neighbor(neighbor) else COLOR_PURCHASABLE

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
	instance.position = tile.area.position + Vector2(CONSTANTS.TILE_SIZE * 0.5, CONSTANTS.TILE_SIZE * 0.5)
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
		if not tile.building.is_empty() and tile.area.has_meta("tile_building_node"):
			var bnode: Node = tile.area.get_meta("tile_building_node") as Node
			if bool(bnode.call("is_fortified")):
				entry["shield_hp"] = int(bnode.call("get_shield_hp"))
			var ulevel: int = int(bnode.get("upgrade_level"))
			if ulevel > 0:
				entry["upgrade_level"] = ulevel
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
	clear_walls()
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

func place_building_from_save(building_name: String, gp: Vector2i, shield_hp: int = 0, upgrade_level: int = 0) -> void:
	if not _tiles.has(gp):
		return
	var tile: TileEntry = _tiles[gp]
	if not tile.unlocked:
		return
	var scene: PackedScene
	match building_name:
		"Core":
			scene = CORE_SCENE
		"Housing":
			scene = HOUSING_SCENE
		"Farm":
			scene = FARM_SCENE
		"Tower":
			scene = TOWER_SCENE
		"GoldMine":
			scene = GOLD_MINE_SCENE
		"Lab":
			scene = LAB_SCENE
		"SolarFarm":
			scene = SOLAR_FARM_SCENE
		"Barracks":
			scene = BARRACKS_SCENE
		_:
			return
	tile.building = building_name
	tile.area.set_meta("tile_has_building", true)
	tile.area.set_meta("tile_building", building_name)
	_update_tile_visual(gp)
	var instance: Node2D = scene.instantiate() as Node2D
	instance.position = tile.area.position + Vector2(CONSTANTS.TILE_SIZE * 0.5, CONSTANTS.TILE_SIZE * 0.5)
	add_child(instance)
	instance.set("_tile_gp", gp)
	instance.set("_building_name", building_name)
	tile.area.set_meta("tile_building_node", instance)
	if shield_hp > 0 and building_name != "GoldMine":
		instance.call("restore_fortification", shield_hp)
	if upgrade_level > 0:
		instance.set("upgrade_level", upgrade_level)

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

func get_tower_save_data() -> Array:
	var result: Array = []
	for gp: Vector2i in _tiles:
		var tile: TileEntry = _tiles[gp]
		if tile.building != "Tower":
			continue
		if not tile.area.has_meta("tile_building_node"):
			continue
		var tower_node: Node = tile.area.get_meta("tile_building_node") as Node
		var entry: Dictionary = {}
		entry["gp"] = [gp.x, gp.y]
		entry["assigned_count"] = int(tower_node.call("get_assigned_workers"))
		result.append(entry)
	return result

func get_gold_mine_at(gp: Vector2i) -> Node:
	if not _tiles.has(gp):
		return null
	var tile: TileEntry = _tiles[gp]
	if not tile.area.has_meta("tile_building_node"):
		return null
	return tile.area.get_meta("tile_building_node") as Node

func get_gold_mine_save_data() -> Array:
	var result: Array = []
	for gp: Vector2i in _tiles:
		var tile: TileEntry = _tiles[gp]
		if tile.building != "GoldMine":
			continue
		if not tile.area.has_meta("tile_building_node"):
			continue
		var mine_node: Node = tile.area.get_meta("tile_building_node") as Node
		var entry: Dictionary = {}
		entry["gp"] = [gp.x, gp.y]
		entry["reserves"] = int(mine_node.call("get_reserves"))
		entry["assigned_count"] = int(mine_node.call("get_assigned_workers"))
		result.append(entry)
	return result

func get_farm_at(gp: Vector2i) -> Node:
	if not _tiles.has(gp):
		return null
	var tile: TileEntry = _tiles[gp]
	if not tile.area.has_meta("tile_building_node"):
		return null
	return tile.area.get_meta("tile_building_node") as Node

func spawn_soldier_at(pos: Vector2) -> void:
	var instance: Node2D = SOLDIER_SCENE.instantiate() as Node2D
	instance.position = pos
	add_child(instance)

func _tile_origin(gp: Vector2i) -> Vector2:
	var half: Vector2 = Vector2(grid_cols * CONSTANTS.TILE_SIZE * 0.5, grid_rows * CONSTANTS.TILE_SIZE * 0.5)
	return Vector2(gp.x * CONSTANTS.TILE_SIZE, gp.y * CONSTANTS.TILE_SIZE) - half

func get_nearest_wall_edge(world_pos: Vector2) -> Dictionary:
	var half: Vector2 = Vector2(grid_cols * CONSTANTS.TILE_SIZE * 0.5, grid_rows * CONSTANTS.TILE_SIZE * 0.5)
	var local: Vector2 = world_pos + half
	var gp_x: int = int(local.x / CONSTANTS.TILE_SIZE)
	var gp_y: int = int(local.y / CONSTANTS.TILE_SIZE)
	var best_dist: float = CONSTANTS.WALL_SNAP_DISTANCE
	var best: Dictionary = {}
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var tgp: Vector2i = Vector2i(gp_x + dx, gp_y + dy)
			if not _tiles.has(tgp):
				continue
			var origin: Vector2 = _tile_origin(tgp)
			var ts: float = CONSTANTS.TILE_SIZE
			# Vertical wall: right edge of tgp — measure distance to the full line segment
			var vx: float = origin.x + ts
			var near_v: Vector2 = Vector2(vx, clampf(world_pos.y, origin.y, origin.y + ts))
			var dist_v: float = world_pos.distance_to(near_v)
			if dist_v < best_dist:
				best_dist = dist_v
				best = {"key": "V,%d,%d" % [tgp.x, tgp.y], "vertical": true, "world_pos": origin + Vector2(ts, ts * 0.5), "gp": tgp}
			# Horizontal wall: bottom edge of tgp — measure distance to the full line segment
			var hy: float = origin.y + ts
			var near_h: Vector2 = Vector2(clampf(world_pos.x, origin.x, origin.x + ts), hy)
			var dist_h: float = world_pos.distance_to(near_h)
			if dist_h < best_dist:
				best_dist = dist_h
				best = {"key": "H,%d,%d" % [tgp.x, tgp.y], "vertical": false, "world_pos": origin + Vector2(ts * 0.5, ts), "gp": tgp}
	return best

func try_place_wall(world_pos: Vector2, player_pos: Vector2) -> String:
	var edge: Dictionary = get_nearest_wall_edge(world_pos)
	if edge.is_empty():
		return "No wall edge nearby."
	var gp_check: Vector2i = edge["gp"] as Vector2i
	var origin_check: Vector2 = _tile_origin(gp_check)
	var ts: float = CONSTANTS.TILE_SIZE
	var near_player: Vector2
	if bool(edge["vertical"]):
		near_player = Vector2(origin_check.x + ts, clampf(player_pos.y, origin_check.y, origin_check.y + ts))
	else:
		near_player = Vector2(clampf(player_pos.x, origin_check.x, origin_check.x + ts), origin_check.y + ts)
	if player_pos.distance_to(near_player) > CONSTANTS.WALL_PLAYER_RANGE:
		return "Too far away."
	var gp: Vector2i = edge["gp"] as Vector2i
	var is_vert: bool = edge["vertical"] as bool
	var neighbor: Vector2i = gp + (Vector2i(1, 0) if is_vert else Vector2i(0, 1))
	var gp_owned: bool = _tiles.has(gp) and _tiles[gp].unlocked
	var neighbor_owned: bool = _tiles.has(neighbor) and _tiles[neighbor].unlocked
	if not gp_owned and not neighbor_owned:
		return "Must be on owned tile."
	var key: String = edge["key"] as String
	if _walls.has(key):
		var wall: Node2D = _walls[key] as Node2D
		if int(wall.get("_hp")) < CONSTANTS.WALL_MAX_HP:
			return str(wall.call("start_repair"))
		_walls.erase(key)
		wall.remove_from_group("buildings")
		GameState.add_coins(CONSTANTS.WALL_COST)
		var remove_tween: Tween = wall.create_tween()
		remove_tween.tween_property(wall, "scale", Vector2.ZERO, 0.15)
		remove_tween.tween_callback(wall.queue_free)
		return ""
	if not GameState.spend_coins(CONSTANTS.WALL_COST):
		return "Not enough coins!"
	var instance: Node2D = WALL_SCENE.instantiate() as Node2D
	instance.position = edge["world_pos"] as Vector2
	add_child(instance)
	instance.call("init", edge["vertical"], key)
	_walls[key] = instance
	GameState.notify_wall_placed()
	return ""

func on_wall_destroyed(edge_key: String) -> void:
	_walls.erase(edge_key)

func get_wall_save_data() -> Array:
	var result: Array = []
	for key: String in _walls:
		var wall: Node2D = _walls[key] as Node2D
		if not is_instance_valid(wall):
			continue
		result.append({"key": key, "hp": int(wall.get("_hp"))})
	return result

func place_wall_from_save(key: String, hp: int) -> void:
	if _walls.has(key):
		return
	var parts: PackedStringArray = key.split(",")
	if parts.size() != 3:
		return
	var vertical: bool = parts[0] == "V"
	var gp: Vector2i = Vector2i(int(parts[1]), int(parts[2]))
	if not _tiles.has(gp):
		return
	var origin: Vector2 = _tile_origin(gp)
	var wall_pos: Vector2 = origin + (Vector2(CONSTANTS.TILE_SIZE, CONSTANTS.TILE_SIZE * 0.5) if vertical else Vector2(CONSTANTS.TILE_SIZE * 0.5, CONSTANTS.TILE_SIZE))
	var instance: Node2D = WALL_SCENE.instantiate() as Node2D
	instance.position = wall_pos
	add_child(instance)
	instance.call("init", vertical, key)
	instance.set("_hp", hp)
	_walls[key] = instance

func get_minimap_tile_data() -> Array:
	var result: Array = []
	for gp: Vector2i in _tiles:
		var tile: TileEntry = _tiles[gp]
		var entry: Dictionary = {}
		entry["gp"] = gp
		entry["unlocked"] = tile.unlocked
		entry["building"] = tile.building
		result.append(entry)
	return result

func clear_walls() -> void:
	for key: String in _walls:
		var wall: Node2D = _walls[key] as Node2D
		if is_instance_valid(wall):
			wall.queue_free()
	_walls.clear()

func get_patrol_points() -> Array:
	var center: Vector2 = Vector2.ZERO
	var points: Array = []

	if not _walls.is_empty():
		for key: String in _walls:
			var wall_node: Node2D = _walls[key] as Node2D
			if not is_instance_valid(wall_node):
				continue
			var wall_pos: Vector2 = wall_node.global_position
			var outward: Vector2 = wall_pos - center
			outward = outward.normalized() if outward.length() > 0.1 else Vector2.RIGHT
			points.append(wall_pos + outward * CONSTANTS.SOLDIER_PATROL_OFFSET)
	else:
		for gp: Vector2i in _tiles:
			var tile: TileEntry = _tiles[gp]
			if not tile.unlocked:
				continue
			var is_edge: bool = false
			for dx: int in [-1, 0, 1]:
				for dy: int in [-1, 0, 1]:
					if dx == 0 and dy == 0:
						continue
					var neighbor: Vector2i = Vector2i(gp.x + dx, gp.y + dy)
					if not _tiles.has(neighbor) or not _tiles[neighbor].unlocked:
						is_edge = true
						break
				if is_edge:
					break
			if is_edge:
				var world_pos: Vector2 = tile.area.position + Vector2(CONSTANTS.TILE_SIZE * 0.5, CONSTANTS.TILE_SIZE * 0.5)
				var dir: Vector2 = world_pos.normalized() if world_pos.length() > 0.1 else Vector2.RIGHT
				points.append(world_pos + dir * float(CONSTANTS.TILE_SIZE) * 0.6)

	points.sort_custom(func(a: Vector2, b: Vector2) -> bool:
		return (a - center).angle() < (b - center).angle()
	)

	# Thin out points that are too close together for smooth perimeter walking
	var min_dist: float = float(CONSTANTS.TILE_SIZE) * 1.2
	var thinned: Array = []
	for pt: Vector2 in points:
		if thinned.is_empty() or pt.distance_to(thinned.back() as Vector2) >= min_dist:
			thinned.append(pt)
	return thinned

func get_soldier_spawn_pos() -> Vector2:
	var pts: Array = get_patrol_points()
	if pts.is_empty():
		return Vector2(randf_range(-150.0, 150.0), randf_range(-150.0, 150.0))
	return pts[randi() % pts.size()]
