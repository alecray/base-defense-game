extends CharacterBody2D

const SPEED: float = 200.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _tile_detector: Area2D = $TileDetector
@onready var _purchase_prompt: Label = $PurchasePrompt

func _ready() -> void:
	add_to_group("player")
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
	if unlocked and has_building and building_name != "Core" and building_name != "Farm" and building_name != "Tower" and building_name != "Housing" and building_name != "GoldMine" and building_name != "Lab":
		return false
	if not unlocked:
		if GameState.get_building_count("Core") == 0:
			return false
		var gp: Vector2i = area.get_meta("tile_gp")
		var grid_node: Node = get_tree().get_first_node_in_group("tile_grid")
		var cost: int = int(grid_node.call("get_tile_cost", gp)) if grid_node != null else 0
		_purchase_prompt.text = "Press [E] to purchase (%d coins)" % cost
	elif building_name == "Core" or building_name == "Farm" or building_name == "Tower" or building_name == "Housing" or building_name == "GoldMine" or building_name == "Lab":
		var display_name: String = "Gold Mine" if building_name == "GoldMine" else building_name
		_purchase_prompt.text = "[E] to manage %s" % display_name
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
	if unlocked and has_building and building_name != "Core" and building_name != "Farm" and building_name != "Tower" and building_name != "Housing" and building_name != "GoldMine" and building_name != "Lab":
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
