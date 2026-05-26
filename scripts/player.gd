extends CharacterBody2D

const SPEED: float = 200.0
const BULLET_SCENE: PackedScene = preload("res://prefabs/player_bullet.tscn")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _tile_detector: Area2D = $TileDetector
@onready var _purchase_prompt: Label = $PurchasePrompt

var _shoot_cooldown: float = 0.0
var _last_wall_key: String = ""

func _ready() -> void:
	add_to_group("player")
	_purchase_prompt.visible = false
	_purchase_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_purchase_prompt.add_theme_font_size_override("font_size", 14)
	_purchase_prompt.position = Vector2(-80.0, -72.0)

func _process(_delta: float) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_last_wall_key = ""
		return
	var grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if grid == null:
		return
	var world_pos: Vector2 = _world_mouse_position()
	var edge: Dictionary = grid.call("get_nearest_wall_edge", world_pos) as Dictionary
	if edge.is_empty():
		_last_wall_key = ""
		return
	var key: String = str(edge.get("key", ""))
	if key == _last_wall_key:
		return
	_last_wall_key = key
	_try_place_wall(world_pos)

func _physics_process(delta: float) -> void:
	_shoot_cooldown = maxf(0.0, _shoot_cooldown - delta)
	var direction: Vector2 = Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		direction.y += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		direction.y -= 1.0
	velocity = direction.normalized() * SPEED if direction.length_squared() > 0.0 else Vector2.ZERO
	if direction.x != 0.0:
		_sprite.flip_h = direction.x < 0.0
	move_and_slide()
	_update_prompt()

func _update_prompt() -> void:
	for area: Area2D in _tile_detector.get_overlapping_areas():
		if _try_show_prompt_for(area):
			return
	_purchase_prompt.visible = false

func _try_show_prompt_for(area: Area2D) -> bool:
	if not area.has_meta("tile_gp") or not area.has_meta("tile_unlocked"):
		return false
	var unlocked: bool = area.get_meta("tile_unlocked")
	var has_building: bool = area.get_meta("tile_has_building")
	var building_name: String = area.get_meta("tile_building") if area.has_meta("tile_building") else ""
	if unlocked and has_building and building_name != "Core" and building_name != "Farm" and building_name != "Tower" and building_name != "Housing" and building_name != "GoldMine" and building_name != "Lab" and building_name != "Barracks":
		return false
	if not unlocked:
		if GameState.get_building_count("Core") == 0:
			return false
		var gp: Vector2i = area.get_meta("tile_gp")
		var grid_node: Node = get_tree().get_first_node_in_group("tile_grid")
		var cost: int = int(grid_node.call("get_tile_cost", gp)) if grid_node != null else 0
		_purchase_prompt.text = "Press [E] to purchase (%d coins)" % cost
	elif building_name == "Core" or building_name == "Farm" or building_name == "Tower" or building_name == "Housing" or building_name == "GoldMine" or building_name == "Lab" or building_name == "Barracks":
		var display_name: String = "Gold Mine" if building_name == "GoldMine" else building_name
		_purchase_prompt.text = "[E] to manage %s" % display_name
	else:
		_purchase_prompt.text = "Press [E] to build"
	_purchase_prompt.visible = true
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and _shoot_cooldown <= 0.0:
			_shoot(_world_mouse_position())
		return
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.physical_keycode != KEY_E:
		return
	for area: Area2D in _tile_detector.get_overlapping_areas():
		if _handle_e_for(area):
			return

func _try_place_wall(world_pos: Vector2) -> void:
	var grid: Node = get_tree().get_first_node_in_group("tile_grid")
	if grid == null:
		return
	var err: String = str(grid.call("try_place_wall", world_pos, global_position))
	if not err.is_empty():
		_show_error(err)

func _shoot(target: Vector2) -> void:
	_shoot_cooldown = CONSTANTS.PLAYER_SHOOT_COOLDOWN
	var bullet: Node2D = BULLET_SCENE.instantiate() as Node2D
	bullet.global_position = global_position
	bullet.call("init", target - global_position, velocity)
	get_parent().add_child(bullet)

## Converts the mouse's screen position to a world position using the player's current
## global_position as the camera centre, bypassing the one-frame camera transform lag
## that makes get_global_mouse_position() drift when the player is moving.
func _world_mouse_position() -> Vector2:
	var viewport: Viewport = get_viewport()
	if not viewport:
		return Vector2.ZERO
	var camera: Camera2D = viewport.get_camera_2d()
	if not camera:
		return get_global_mouse_position()
	var screen_mouse: Vector2 = viewport.get_mouse_position()
	var viewport_center: Vector2 = viewport.get_visible_rect().size * 0.5
	return global_position + (screen_mouse - viewport_center) / camera.zoom.x

func _handle_e_for(area: Area2D) -> bool:
	if not area.has_meta("tile_gp") or not area.has_meta("tile_unlocked"):
		return false
	var unlocked: bool = area.get_meta("tile_unlocked")
	var has_building: bool = area.get_meta("tile_has_building")
	var building_name: String = area.get_meta("tile_building") if area.has_meta("tile_building") else ""
	if unlocked and has_building and building_name != "Core" and building_name != "Farm" and building_name != "Tower" and building_name != "Housing" and building_name != "GoldMine" and building_name != "Lab" and building_name != "Barracks":
		return false
	var gp: Vector2i = area.get_meta("tile_gp")
	if not unlocked:
		if GameState.get_building_count("Core") == 0:
			return false
		var grid_node: Node = get_tree().get_first_node_in_group("tile_grid")
		if grid_node != null and not grid_node.call("has_unlocked_neighbor", gp):
			_show_error("Need an adjacent tile!")
			return true
		var cost: int = int(grid_node.call("get_tile_cost", gp)) if grid_node != null else 0
		if GameState.coins < cost:
			_show_error("Not enough coins!")
			return true
		if grid_node != null:
			grid_node.call("purchase_tile", gp)
		return true
	elif building_name == "Core":
		var worker_ui: Node = get_tree().get_first_node_in_group("worker_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if worker_ui != null and building_node != null:
			worker_ui.call("open_for_core", gp, building_node)
		return true
	elif building_name == "Farm":
		var farm_ui: Node = get_tree().get_first_node_in_group("farm_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if farm_ui != null and building_node != null:
			farm_ui.call("open_for_farm", building_node)
		return true
	elif building_name == "Tower":
		var tower_ui: Node = get_tree().get_first_node_in_group("tower_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if tower_ui != null and building_node != null:
			tower_ui.call("open_for_tower", building_node)
		return true
	elif building_name == "Housing":
		var housing_ui: Node = get_tree().get_first_node_in_group("housing_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if housing_ui != null and building_node != null:
			housing_ui.call("open_for_housing", building_node)
		return true
	elif building_name == "GoldMine":
		var gold_mine_ui: Node = get_tree().get_first_node_in_group("gold_mine_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if gold_mine_ui != null and building_node != null:
			gold_mine_ui.call("open_for_mine", building_node)
		return true
	elif building_name == "Lab":
		var lab_ui: Node = get_tree().get_first_node_in_group("lab_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if lab_ui != null and building_node != null:
			lab_ui.call("open_for_lab", gp, building_node)
		return true
	elif building_name == "Barracks":
		var barracks_ui: Node = get_tree().get_first_node_in_group("barracks_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if barracks_ui != null and building_node != null:
			barracks_ui.call("open_for_barracks", building_node)
		return true
	elif building_name == "SiegeTower" or building_name == "Armory":
		return true
	else:
		var shop: Node = get_tree().get_first_node_in_group("shop_ui")
		if shop != null:
			shop.call("open_for_tile", gp)
		return true

func _show_error(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-80.0, -90.0)
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.tween_callback(label.queue_free)
