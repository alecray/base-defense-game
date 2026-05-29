extends CanvasLayer

var _coins_label: Label
var _core_prompt: Label
var _workers_label: Label
var _food_label: Label
var _food_rate_label: Label
var _power_label: Label
var _soldiers_label: Label
var _day_label: Label
var _time_label: Label
var _game_over_root: Control = null
var _tutorial_step: int = 0
var _repair_hint_label: Label = null
var _vignette: ColorRect = null
var _vignette_tween: Tween = null
var _indicator_cooldown: float = 0.0
var _lp_total_label: Label = null
var _shop_container: VBoxContainer = null

const _TUTORIAL_PROMPTS: Array = [
	"Build a Core to start expanding",
	"Build a Solar Farm for power — towers need power to fire",
	"Build Housing to expand worker cap",
	"Press [E] on Core to buy workers, then [E] on a Gold Mine to assign one",
	"Buy a Farm — farms produce food, which workers consume over time",
	"Press [E] on the Farm to assign workers to it",
	"Build a Tower",
	"Press [E] on the Tower to assign a worker — towers need both a worker and power to fire",
	"Build a Barracks",
	"Buy a Soldier — soldiers patrol and attack enemies automatically",
	"Build Walls to protect your base — right-click near a tile edge to place one",
	"Build a Library to research permanent upgrades",
	"Night is coming — enemies spawn from outside the map. Towers and soldiers defend automatically.",
]

func _ready() -> void:
	layer = 5
	add_to_group("hud")

	# --- Full-width top resource bar ---
	var bar_bg: ColorRect = ColorRect.new()
	bar_bg.color = Color(0.06, 0.06, 0.06, 0.82)
	bar_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar_bg.offset_bottom = 40.0
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar_bg)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hbox.offset_bottom = 40.0
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 6)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hbox)

	_coins_label = _make_bar_label("Coins: %d" % GameState.coins)
	hbox.add_child(_coins_label)
	hbox.add_child(_make_sep())

	_food_label = _make_bar_label("Food: %d / %d" % [GameState.food, GameState.food_cap])
	hbox.add_child(_food_label)
	_food_rate_label = _make_bar_label("")
	_food_rate_label.add_theme_font_size_override("font_size", 11)
	hbox.add_child(_food_rate_label)
	hbox.add_child(_make_sep())

	_power_label = _make_bar_label("Power: %d / %d" % [GameState.power, GameState.power_cap])
	hbox.add_child(_power_label)
	hbox.add_child(_make_sep())

	_workers_label = _make_bar_label("Workers: 0/0")
	hbox.add_child(_workers_label)
	hbox.add_child(_make_sep())

	_soldiers_label = _make_bar_label("Soldiers: 0 / 0")
	hbox.add_child(_soldiers_label)

	# --- Day / Time (below bar, center) ---
	_day_label = Label.new()
	_day_label.add_theme_font_size_override("font_size", 18)
	_day_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_day_label.offset_top = 46.0
	_day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_day_label)
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null:
		_day_label.text = "Day %d" % cycle.call("get_day")
		cycle.day_changed.connect(_on_day_changed)
	else:
		_day_label.text = "Day 1"

	_time_label = Label.new()
	_time_label.add_theme_font_size_override("font_size", 13)
	_time_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_time_label.offset_top = 68.0
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.text = "6:00 AM"
	add_child(_time_label)

	# --- Tutorial prompt ---
	_core_prompt = Label.new()
	_core_prompt.text = "Build a Core to start expanding"
	_core_prompt.add_theme_font_size_override("font_size", 15)
	_core_prompt.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_core_prompt.offset_top = 88.0
	_core_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_core_prompt.visible = GameState.get_building_count("Core") == 0
	add_child(_core_prompt)

	_repair_hint_label = Label.new()
	_repair_hint_label.text = "Hold [R] + [LMB] to repair damaged buildings"
	_repair_hint_label.add_theme_font_size_override("font_size", 14)
	_repair_hint_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_repair_hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_repair_hint_label.offset_top = 108.0
	_repair_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_repair_hint_label.visible = false
	add_child(_repair_hint_label)

	# --- Minimap (bottom-left) ---
	var minimap: Control = load("res://scripts/minimap.gd").new()
	add_child(minimap)

	# --- Signals ---
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.building_placed.connect(_on_building_placed)
	GameState.workers_changed.connect(_on_workers_changed)
	GameState.food_changed.connect(_on_food_changed)
	GameState.food_rate_changed.connect(_on_food_rate_changed)
	GameState.power_changed.connect(_on_power_changed)
	GameState.soldiers_changed.connect(_on_soldiers_changed)
	GameState.game_reset.connect(_on_game_reset)
	GameState.game_over.connect(_on_game_over)
	GameState.first_mine_worker_assigned.connect(_on_first_mine_worker_assigned)
	GameState.first_farm_worker_assigned.connect(_on_first_farm_worker_assigned)
	GameState.first_tower_worker_assigned.connect(_on_first_tower_worker_assigned)
	GameState.first_soldier_bought.connect(_on_first_soldier_bought)
	GameState.first_wall_placed.connect(_on_first_wall_placed)
	GameState.first_building_repaired.connect(_on_first_building_repaired)
	GameState.building_attacked.connect(_on_building_attacked)

func _make_bar_label(text: String) -> Label:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl

func _make_sep() -> Label:
	var sep: Label = Label.new()
	sep.text = "|"
	sep.add_theme_font_size_override("font_size", 12)
	sep.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.55))
	sep.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sep

func _process(delta: float) -> void:
	if _time_label == null:
		return
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null:
		_time_label.text = cycle.call("get_time_string") as String
		if _tutorial_step == 12 and float(cycle.call("get_night_intensity")) > 0.0:
			_advance_tutorial(12)
	if _indicator_cooldown > 0.0:
		_indicator_cooldown -= delta

func _on_building_attacked(world_pos: Vector2) -> void:
	_flash_vignette()
	if _indicator_cooldown <= 0.0 and _is_world_pos_off_screen(world_pos):
		_indicator_cooldown = 1.5
		_show_direction_indicator(world_pos)
	if _repair_hint_label != null and not _repair_hint_label.visible and not GameState._building_ever_repaired:
		_repair_hint_label.visible = true

func _on_first_building_repaired() -> void:
	if _repair_hint_label != null:
		_repair_hint_label.visible = false

func _flash_vignette() -> void:
	if _vignette == null:
		_vignette = ColorRect.new()
		_vignette.color = Color(0.8, 0.0, 0.0, 0.0)
		_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_vignette)
	if _vignette_tween != null:
		_vignette_tween.kill()
	_vignette.color.a = 0.3
	_vignette_tween = create_tween()
	_vignette_tween.tween_property(_vignette, "color:a", 0.0, 0.5)

func _world_to_screen(world_pos: Vector2) -> Vector2:
	var viewport: Viewport = get_viewport()
	var camera: Camera2D = viewport.get_camera_2d()
	if camera == null:
		return world_pos
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	return viewport_size / 2.0 + (world_pos - camera.global_position) * camera.zoom.x

func _is_world_pos_off_screen(world_pos: Vector2) -> bool:
	var screen_pos: Vector2 = _world_to_screen(world_pos)
	var size: Vector2 = get_viewport().get_visible_rect().size
	return screen_pos.x < 0.0 or screen_pos.x > size.x or screen_pos.y < 0.0 or screen_pos.y > size.y

func _show_direction_indicator(world_pos: Vector2) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var center: Vector2 = viewport_size / 2.0
	var dir: Vector2 = (_world_to_screen(world_pos) - center).normalized()
	var edge_pos: Vector2 = _screen_edge_point(dir, viewport_size, 36.0)
	var label: Label = Label.new()
	label.text = "▶"
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1.0, 0.15, 0.15))
	label.position = edge_pos - Vector2(11.0, 11.0)
	label.pivot_offset = Vector2(11.0, 11.0)
	label.rotation = dir.angle()
	add_child(label)
	var tween: Tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)

func _screen_edge_point(dir: Vector2, viewport_size: Vector2, margin: float) -> Vector2:
	var center: Vector2 = viewport_size / 2.0
	var t: float = INF
	if absf(dir.x) > 0.001:
		var tx: float = (((viewport_size.x - margin) if dir.x > 0.0 else margin) - center.x) / dir.x
		t = minf(t, tx)
	if absf(dir.y) > 0.001:
		var ty: float = (((viewport_size.y - margin) if dir.y > 0.0 else margin) - center.y) / dir.y
		t = minf(t, ty)
	return center + dir * t

func _on_coins_changed(new_amount: int) -> void:
	_coins_label.text = "Coins: %d" % new_amount

func get_tutorial_step() -> int:
	return _tutorial_step

func restore_tutorial_step(step: int) -> void:
	_tutorial_step = step
	GameState.restore_tutorial_flags(step)
	if step >= _TUTORIAL_PROMPTS.size():
		_core_prompt.visible = false
	else:
		_core_prompt.text = _TUTORIAL_PROMPTS[step]
		_core_prompt.visible = true

func _advance_tutorial(required_step: int) -> void:
	if _tutorial_step != required_step:
		return
	_tutorial_step += 1
	if _tutorial_step >= _TUTORIAL_PROMPTS.size():
		_core_prompt.text = "You're ready — survive as long as you can!"
		_core_prompt.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
		_core_prompt.modulate = Color.WHITE
		_core_prompt.visible = true
		var tween: Tween = create_tween()
		tween.tween_interval(3.5)
		tween.tween_property(_core_prompt, "modulate:a", 0.0, 1.5)
		tween.tween_callback(func() -> void: _core_prompt.visible = false)
	else:
		_core_prompt.text = _TUTORIAL_PROMPTS[_tutorial_step]
		_core_prompt.visible = true

func _on_building_placed(building_name: String) -> void:
	match building_name:
		"Core":      _advance_tutorial(0)
		"SolarFarm": _advance_tutorial(1)
		"Housing":   _advance_tutorial(2)
		"Farm":      _advance_tutorial(4)
		"Tower":
			_advance_tutorial(6)
		"Barracks":  _advance_tutorial(8)
		"Library":   _advance_tutorial(11)

func _on_first_mine_worker_assigned() -> void:
	_advance_tutorial(3)

func _on_first_farm_worker_assigned() -> void:
	_advance_tutorial(5)

func _on_first_tower_worker_assigned() -> void:
	_advance_tutorial(7)

func _on_first_soldier_bought() -> void:
	_advance_tutorial(9)

func _on_first_wall_placed() -> void:
	_advance_tutorial(10)

func _on_workers_changed(count: int, cap: int, _free: int) -> void:
	_workers_label.text = "Workers: %d/%d" % [count, cap]

func _on_food_changed(new_amount: int) -> void:
	_food_label.text = "Food: %d / %d" % [new_amount, GameState.food_cap]

func _on_food_rate_changed(net_per_5s: int) -> void:
	if net_per_5s > 0:
		_food_rate_label.text = "(+%d/5s)" % net_per_5s
		_food_rate_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.3))
	elif net_per_5s < 0:
		_food_rate_label.text = "(%d/5s)" % net_per_5s
		_food_rate_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	else:
		_food_rate_label.text = ""

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
	_core_prompt.modulate = Color.WHITE
	_core_prompt.remove_theme_color_override("font_color")
	_core_prompt.visible = true
	if _repair_hint_label != null:
		_repair_hint_label.visible = false
	if _game_over_root != null:
		_game_over_root.queue_free()
		_game_over_root = null

func _on_game_over() -> void:
	get_tree().paused = true

	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	var days: int = int(cycle.call("get_day")) if cycle != null else 1
	var enemies_killed: int = GameState.enemies_killed_this_run
	var lp_earned: int = LegacyState.award_points(days)

	_lp_total_label = null
	_shop_container = null

	_game_over_root = Control.new()
	_game_over_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over_root.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_game_over_root)

	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.82)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_game_over_root.add_child(overlay)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	scroll.custom_minimum_size = Vector2(420.0, 560.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_game_over_root.add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.custom_minimum_size = Vector2(400.0, 0.0)
	scroll.add_child(vbox)

	var title: Label = Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub: Label = Label.new()
	sub.text = "The Core was destroyed"
	sub.add_theme_font_size_override("font_size", 16)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	vbox.add_child(HSeparator.new())

	var stats_hbox: HBoxContainer = HBoxContainer.new()
	stats_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_hbox.add_theme_constant_override("separation", 30)
	vbox.add_child(stats_hbox)
	_add_stat_block(stats_hbox, "Days", str(days))
	_add_stat_block(stats_hbox, "Enemies Killed", str(enemies_killed))
	_add_stat_block(stats_hbox, "Best Run", "%d days" % LegacyState.best_days)

	var lp_label: Label = Label.new()
	lp_label.text = "+%d Legacy Points earned" % lp_earned
	lp_label.add_theme_font_size_override("font_size", 17)
	lp_label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.2))
	lp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lp_label)

	vbox.add_child(HSeparator.new())

	var shop_title: Label = Label.new()
	shop_title.text = "LEGACY SHOP"
	shop_title.add_theme_font_size_override("font_size", 18)
	shop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(shop_title)

	_lp_total_label = Label.new()
	_lp_total_label.add_theme_font_size_override("font_size", 14)
	_lp_total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lp_total_label)

	_shop_container = VBoxContainer.new()
	_shop_container.add_theme_constant_override("separation", 6)
	vbox.add_child(_shop_container)

	_rebuild_legacy_shop()

	vbox.add_child(HSeparator.new())

	var play_btn: Button = Button.new()
	play_btn.text = "Play Again"
	play_btn.custom_minimum_size = Vector2(180.0, 44.0)
	play_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(play_btn)

func _add_stat_block(parent: HBoxContainer, label_text: String, value_text: String) -> void:
	var vb: VBoxContainer = VBoxContainer.new()
	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 11)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(label)
	var val: Label = Label.new()
	val.text = value_text
	val.add_theme_font_size_override("font_size", 22)
	val.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(val)
	parent.add_child(vb)

func _rebuild_legacy_shop() -> void:
	if _shop_container == null or _lp_total_label == null:
		return
	_lp_total_label.text = "Available: %d LP" % LegacyState.legacy_points
	for child: Node in _shop_container.get_children():
		child.queue_free()
	for def_variant: Variant in LegacyState.UPGRADE_DEFS:
		var def: Dictionary = def_variant as Dictionary
		var id: String = str(def["id"])
		var level: int = LegacyState.get_upgrade_level(id)
		var max_level: int = int(def["max"])
		var cost: int = int(def["cost"])
		var maxed: bool = LegacyState.is_maxed(id)
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_shop_container.add_child(row)
		var info: VBoxContainer = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var name_lbl: Label = Label.new()
		name_lbl.text = str(def["name"])
		name_lbl.add_theme_font_size_override("font_size", 14)
		info.add_child(name_lbl)
		var desc_lbl: Label = Label.new()
		var level_str: String = "  [MAX]" if maxed else "  (Lv %d/%d)" % [level, max_level]
		desc_lbl.text = str(def["desc"]) + level_str
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4) if maxed else Color(0.7, 0.7, 0.7))
		info.add_child(desc_lbl)
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(88.0, 30.0)
		if maxed:
			btn.text = "MAXED"
			btn.disabled = true
		else:
			btn.text = "%d LP" % cost
			btn.disabled = not LegacyState.can_afford(id)
		btn.pressed.connect(_on_buy_legacy_upgrade.bind(id))
		row.add_child(btn)

func _on_buy_legacy_upgrade(id: String) -> void:
	if LegacyState.buy_upgrade(id):
		_rebuild_legacy_shop()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	_lp_total_label = null
	_shop_container = null
	var sm: Node = get_tree().get_first_node_in_group("save_manager")
	if sm != null:
		sm.call("reset_game")
