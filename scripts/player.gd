extends CharacterBody2D

const SPEED: float = 200.0

@onready var _tile_detector: Area2D = $TileDetector
@onready var _purchase_prompt: Label = $PurchasePrompt

func _ready() -> void:
	_purchase_prompt.visible = false
	_purchase_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_purchase_prompt.add_theme_font_size_override("font_size", 14)
	_purchase_prompt.position = Vector2(-80.0, -72.0)

func _physics_process(_delta: float) -> void:
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
	if unlocked and has_building and building_name != "Core" and building_name != "Farm":
		return false
	if not unlocked:
		if GameState.get_building_count("Core") == 0:
			return false
		var gp: Vector2i = area.get_meta("tile_gp")
		var grid_node: Node = get_tree().get_first_node_in_group("tile_grid")
		var cost: int = int(grid_node.call("get_tile_cost", gp)) if grid_node != null else 0
		_purchase_prompt.text = "Press [E] to purchase (%d coins)" % cost
	elif building_name == "Core" or building_name == "Farm":
		_purchase_prompt.text = "Press [E] to manage"
	else:
		_purchase_prompt.text = "Press [E] to build"
	_purchase_prompt.visible = true
	return true

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.physical_keycode != KEY_E:
		return
	for area: Area2D in _tile_detector.get_overlapping_areas():
		if _handle_e_for(area):
			return

func _handle_e_for(area: Area2D) -> bool:
	if not area.has_meta("tile_gp") or not area.has_meta("tile_unlocked"):
		return false
	var unlocked: bool = area.get_meta("tile_unlocked")
	var has_building: bool = area.get_meta("tile_has_building")
	var building_name: String = area.get_meta("tile_building") if area.has_meta("tile_building") else ""
	if unlocked and has_building and building_name != "Core" and building_name != "Farm":
		return false
	var gp: Vector2i = area.get_meta("tile_gp")
	if not unlocked:
		if GameState.get_building_count("Core") == 0:
			return false
		var grid_node: Node = get_tree().get_first_node_in_group("tile_grid")
		if grid_node != null:
			grid_node.call("purchase_tile", gp)
		return true
	elif building_name == "Core":
		var worker_ui: Node = get_tree().get_first_node_in_group("worker_ui")
		if worker_ui != null:
			worker_ui.call("open_for_tile", gp)
		return true
	elif building_name == "Farm":
		var farm_ui: Node = get_tree().get_first_node_in_group("farm_ui")
		var building_node: Node = area.get_meta("tile_building_node") if area.has_meta("tile_building_node") else null
		if farm_ui != null and building_node != null:
			farm_ui.call("open_for_farm", building_node)
		return true
	else:
		var shop: Node = get_tree().get_first_node_in_group("shop_ui")
		if shop != null:
			shop.call("open_for_tile", gp)
		return true
