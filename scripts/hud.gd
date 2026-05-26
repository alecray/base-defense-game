extends CanvasLayer

@onready var _coins_label: Label = $CoinsLabel

var _core_prompt: Label
var _workers_label: Label
var _food_label: Label
var _power_label: Label
var _soldiers_label: Label
var _day_label: Label
var _time_label: Label
var _game_over_root: Control = null
var _tutorial_step: int = 0

func _ready() -> void:
	layer = 5
	_coins_label.add_theme_font_size_override("font_size", 20)
	_coins_label.text = "Coins: %d" % GameState.coins
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.building_placed.connect(_on_building_placed)
	GameState.workers_changed.connect(_on_workers_changed)
	GameState.food_changed.connect(_on_food_changed)

	_workers_label = Label.new()
	_workers_label.add_theme_font_size_override("font_size", 16)
	_workers_label.text = "Workers: 0/0 (0 free)"
	_workers_label.position = Vector2(12.0, 40.0)
	add_child(_workers_label)

	_food_label = Label.new()
	_food_label.add_theme_font_size_override("font_size", 16)
	_food_label.text = "Food: %d / %d" % [GameState.food, GameState.food_cap]
	_food_label.position = Vector2(12.0, 62.0)
	add_child(_food_label)

	_power_label = Label.new()
	_power_label.add_theme_font_size_override("font_size", 16)
	_power_label.text = "Power: %d / %d" % [GameState.power, GameState.power_cap]
	_power_label.position = Vector2(12.0, 84.0)
	add_child(_power_label)
	GameState.power_changed.connect(_on_power_changed)

	_soldiers_label = Label.new()
	_soldiers_label.add_theme_font_size_override("font_size", 16)
	_soldiers_label.text = "Soldiers: 0 / 0"
	_soldiers_label.position = Vector2(12.0, 106.0)
	add_child(_soldiers_label)
	GameState.soldiers_changed.connect(_on_soldiers_changed)

	_day_label = Label.new()
	_day_label.add_theme_font_size_override("font_size", 20)
	_day_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_day_label.offset_top = 10.0
	_day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_day_label)
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null:
		_day_label.text = "Day %d" % cycle.call("get_day")
		cycle.day_changed.connect(_on_day_changed)
	else:
		_day_label.text = "Day 1"

	_time_label = Label.new()
	_time_label.add_theme_font_size_override("font_size", 14)
	_time_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_time_label.offset_top = 36.0
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.text = "6:00 AM"
	add_child(_time_label)

	_core_prompt = Label.new()
	_core_prompt.text = "Build a Core to start expanding"
	_core_prompt.add_theme_font_size_override("font_size", 16)
	_core_prompt.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_core_prompt.offset_top = 58.0
	_core_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_core_prompt.visible = GameState.get_building_count("Core") == 0
	add_child(_core_prompt)
	GameState.game_reset.connect(_on_game_reset)
	GameState.game_over.connect(_on_game_over)
	GameState.first_mine_worker_assigned.connect(_on_first_mine_worker_assigned)
	GameState.first_farm_worker_assigned.connect(_on_first_farm_worker_assigned)
	GameState.first_wall_placed.connect(_on_first_wall_placed)

func _process(_delta: float) -> void:
	if _time_label == null:
		return
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null:
		_time_label.text = cycle.call("get_time_string") as String

func _on_coins_changed(new_amount: int) -> void:
	_coins_label.text = "Coins: %d" % new_amount

func _advance_tutorial(required_step: int, text: String) -> void:
	if _tutorial_step != required_step:
		return
	_tutorial_step += 1
	if text.is_empty():
		_core_prompt.visible = false
	else:
		_core_prompt.text = text
		_core_prompt.visible = true

func _on_building_placed(building_name: String) -> void:
	match building_name:
		"Core":       _advance_tutorial(0, "Build a Solar Farm for power")
		"SolarFarm":  _advance_tutorial(1, "Build Housing to expand worker cap")
		"Housing":    _advance_tutorial(2, "Buy workers and assign them to Gold")
		"Farm":       _advance_tutorial(4, "Assign workers to the farm")
		"Tower":      _advance_tutorial(6, "Build Walls to protect your base")
		"Lab":        _advance_tutorial(8, "")

func _on_first_mine_worker_assigned() -> void:
	_advance_tutorial(3, "Buy a Farm")

func _on_first_farm_worker_assigned() -> void:
	_advance_tutorial(5, "Build a Turret")

func _on_first_wall_placed() -> void:
	_advance_tutorial(7, "Build a Lab")

func _on_workers_changed(count: int, cap: int, free: int) -> void:
	_workers_label.text = "Workers: %d/%d (%d free)" % [count, cap, free]

func _on_food_changed(new_amount: int) -> void:
	_food_label.text = "Food: %d / %d" % [new_amount, GameState.food_cap]

func _on_power_changed(new_amount: int) -> void:
	_power_label.text = "Power: %d / %d" % [new_amount, GameState.power_cap]

func _on_soldiers_changed(count: int, cap: int) -> void:
	_soldiers_label.text = "Soldiers: %d / %d" % [count, cap]

func _on_day_changed(day: int) -> void:
	_day_label.text = "Day %d" % day

func _on_game_reset() -> void:
	_day_label.text = "Day 1"
	_power_label.text = "Power: 0 / %d" % GameState.power_cap
	_soldiers_label.text = "Soldiers: 0 / 0"
	_tutorial_step = 0
	_core_prompt.text = "Build a Core to start expanding"
	_core_prompt.visible = true
	if _game_over_root != null:
		_game_over_root.queue_free()
		_game_over_root = null

func _on_game_over() -> void:
	get_tree().paused = true

	_game_over_root = Control.new()
	_game_over_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over_root.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_game_over_root)
	var root: Control = _game_over_root

	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.75)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(overlay)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.add_theme_constant_override("separation", 16)
	root.add_child(vbox)

	var title: Label = Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub: Label = Label.new()
	sub.text = "The Core was destroyed"
	sub.add_theme_font_size_override("font_size", 20)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	var restart_btn: Button = Button.new()
	restart_btn.text = "Restart"
	restart_btn.custom_minimum_size = Vector2(160.0, 48.0)
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	var sm: Node = get_tree().get_first_node_in_group("save_manager")
	if sm != null:
		sm.call("reset_game")
