extends CanvasLayer

var _ui_root: Control
var _status_labels: Dictionary = {}
var _progress_bars: Dictionary = {}
var _buttons: Dictionary = {}

func _ready() -> void:
	add_to_group("lab_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build_ui()
	GameState.research_progress_changed.connect(_on_research_progress)
	GameState.research_completed.connect(_on_research_completed)

func _get_research_defs() -> Array:
	return [
		{
			"id": "turret_damage",
			"name": "Turret Damage",
			"cost": CONSTANTS.LAB_RESEARCH_TURRET_DAMAGE_COST,
			"duration": CONSTANTS.LAB_RESEARCH_TURRET_DAMAGE_DURATION,
			"one_time": false,
			"desc": "+%d tower damage per level. No cap." % CONSTANTS.LAB_TURRET_DAMAGE_UPGRADE_AMOUNT,
		},
		{
			"id": "armory_blueprint",
			"name": "Armory Blueprint",
			"cost": CONSTANTS.LAB_RESEARCH_ARMORY_COST,
			"duration": CONSTANTS.LAB_RESEARCH_ARMORY_DURATION,
			"one_time": true,
			"desc": "Unlocks the Armory building. Each Armory gives soldiers +%d attack and new soldiers spawn with +%d HP." % [CONSTANTS.ARMORY_DAMAGE_BONUS, CONSTANTS.ARMORY_HP_BONUS],
		},
		{
			"id": "soldier_damage",
			"name": "Combat Training",
			"cost": CONSTANTS.LAB_RESEARCH_SOLDIER_DAMAGE_COST,
			"duration": CONSTANTS.LAB_RESEARCH_SOLDIER_DAMAGE_DURATION,
			"one_time": false,
			"desc": "+%d soldier attack damage per level. No cap." % CONSTANTS.LAB_SOLDIER_DAMAGE_UPGRADE_AMOUNT,
		},
		{
			"id": "soldier_hp",
			"name": "Soldier Endurance",
			"cost": CONSTANTS.LAB_RESEARCH_SOLDIER_HP_COST,
			"duration": CONSTANTS.LAB_RESEARCH_SOLDIER_HP_DURATION,
			"one_time": false,
			"desc": "+%d soldier max HP per level (applies to newly spawned soldiers)." % CONSTANTS.LAB_SOLDIER_HP_UPGRADE_AMOUNT,
		},
		{
			"id": "worker_speed",
			"name": "Efficient Workers",
			"cost": CONSTANTS.LAB_RESEARCH_WORKER_SPEED_COST,
			"duration": CONSTANTS.LAB_RESEARCH_WORKER_SPEED_DURATION,
			"one_time": false,
			"desc": "+%d worker travel speed per level. No cap." % int(CONSTANTS.LAB_WORKER_SPEED_UPGRADE_AMOUNT),
		},
		{
			"id": "farm_yield",
			"name": "Agricultural Methods",
			"cost": CONSTANTS.LAB_RESEARCH_FARM_YIELD_COST,
			"duration": CONSTANTS.LAB_RESEARCH_FARM_YIELD_DURATION,
			"one_time": false,
			"desc": "+%d food per farm worker per harvest tick per level." % CONSTANTS.LAB_FARM_YIELD_UPGRADE_AMOUNT,
		},
	]

func _build_ui() -> void:
	var root: Control = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	_ui_root = root

	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.gui_input.connect(_on_overlay_input)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(overlay)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(420.0, 580.0)
	root.add_child(panel)

	var outer_vbox: VBoxContainer = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 8)
	panel.add_child(outer_vbox)

	var title_row: HBoxContainer = HBoxContainer.new()
	outer_vbox.add_child(title_row)

	var title: Label = Label.new()
	title.text = "Lab Research"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(title)

	var close_btn: Button = Button.new()
	close_btn.text = "✕"
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	outer_vbox.add_child(HSeparator.new())

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 0)
	scroll.add_child(content)

	var defs: Array = _get_research_defs()
	for i: int in range(defs.size()):
		var def: Dictionary = defs[i] as Dictionary
		_build_research_row(content, def)
		if i < defs.size() - 1:
			content.add_child(HSeparator.new())

func _build_research_row(parent: VBoxContainer, def: Dictionary) -> void:
	var id: String = str(def["id"])

	var row: VBoxContainer = VBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.add_child(row)
	parent.add_child(margin)

	var name_row: HBoxContainer = HBoxContainer.new()
	row.add_child(name_row)

	var name_lbl: Label = Label.new()
	name_lbl.text = str(def["name"])
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_row.add_child(name_lbl)

	var level_lbl: Label = Label.new()
	level_lbl.add_theme_font_size_override("font_size", 13)
	level_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0))
	name_row.add_child(level_lbl)
	_status_labels[id + "_level"] = level_lbl

	var desc_lbl: Label = Label.new()
	desc_lbl.text = str(def["desc"])
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	row.add_child(desc_lbl)

	var status_lbl: Label = Label.new()
	status_lbl.add_theme_font_size_override("font_size", 12)
	status_lbl.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
	row.add_child(status_lbl)
	_status_labels[id] = status_lbl

	var pb: ProgressBar = ProgressBar.new()
	pb.min_value = 0.0
	pb.max_value = 1.0
	pb.value = 0.0
	pb.custom_minimum_size = Vector2(0.0, 14.0)
	pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pb.show_percentage = false
	row.add_child(pb)
	_progress_bars[id] = pb

	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(0.0, 36.0)
	btn.pressed.connect(_on_research_pressed.bind(id))
	row.add_child(btn)
	_buttons[id] = btn

func open_for_lab(_gp: Vector2i, _building_node: Node) -> void:
	_refresh()
	visible = true

func _refresh() -> void:
	var busy: bool = not GameState.lab_research_id.is_empty()
	var active_id: String = GameState.lab_research_id

	for def: Variant in _get_research_defs():
		var d: Dictionary = def as Dictionary
		var id: String = str(d["id"])
		var one_time: bool = bool(d["one_time"])
		var level: int = GameState.get_upgrade_level(id)
		var done: bool = one_time and level > 0
		var cost: int = int(d["cost"])
		var duration: float = float(d["duration"])
		var is_active: bool = active_id == id

		var level_lbl: Label = _status_labels.get(id + "_level") as Label
		var status_lbl: Label = _status_labels.get(id) as Label
		var pb: ProgressBar = _progress_bars.get(id) as ProgressBar
		var btn: Button = _buttons.get(id) as Button

		if done:
			level_lbl.text = "Unlocked"
			level_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
			status_lbl.text = ""
			pb.value = 1.0
			btn.disabled = true
			btn.text = "Already Researched"
		else:
			if one_time:
				level_lbl.text = ""
			else:
				level_lbl.text = "Lv. %d" % level
				level_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0))

			btn.disabled = busy
			btn.text = "Research  (%d coins / %ds)" % [cost, int(duration)]

			if is_active:
				var progress: float = GameState.lab_research_progress / duration
				status_lbl.text = "Researching... %d%%" % int(progress * 100.0)
				pb.value = progress
			elif busy:
				status_lbl.text = "Another research in progress"
				pb.value = 0.0
			else:
				status_lbl.text = ""
				pb.value = 0.0

func _on_research_pressed(id: String) -> void:
	var defs: Array = _get_research_defs()
	var cost: int = 0
	for def: Variant in defs:
		var d: Dictionary = def as Dictionary
		if str(d["id"]) == id:
			cost = int(d["cost"])
			break
	if not GameState.spend_coins(cost):
		_show_error("Not enough coins!")
		return
	GameState.start_research(id)
	_refresh()

func _on_research_progress(id: String, progress: float) -> void:
	if not visible:
		return
	var pb: ProgressBar = _progress_bars.get(id) as ProgressBar
	var status_lbl: Label = _status_labels.get(id) as Label
	if pb != null:
		pb.value = progress
	if status_lbl != null:
		status_lbl.text = "Researching... %d%%" % int(progress * 100.0)

func _on_research_completed(_id: String) -> void:
	if visible:
		_refresh()

func _close() -> void:
	visible = false

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_close()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
			_close()

func _show_error(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	label.add_theme_font_size_override("font_size", 16)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_top = 120.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ui_root.add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.tween_callback(label.queue_free)
