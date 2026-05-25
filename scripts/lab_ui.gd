extends CanvasLayer

var _ui_root: Control
var _progress_bar: ProgressBar
var _research_btn: Button
var _level_label: Label
var _status_label: Label

func _ready() -> void:
	add_to_group("lab_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build_ui()
	GameState.research_progress_changed.connect(_on_research_progress)
	GameState.research_completed.connect(_on_research_completed)

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
	panel.custom_minimum_size = Vector2(380.0, 280.0)
	root.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(title_row)

	var title: Label = Label.new()
	title.text = "Lab Research"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(title)

	var close_btn: Button = Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	var upgrade_vbox: VBoxContainer = VBoxContainer.new()
	upgrade_vbox.add_theme_constant_override("separation", 8)
	vbox.add_child(upgrade_vbox)

	var name_row: HBoxContainer = HBoxContainer.new()
	upgrade_vbox.add_child(name_row)

	var name_lbl: Label = Label.new()
	name_lbl.text = "Turret Damage"
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_row.add_child(name_lbl)

	_level_label = Label.new()
	_level_label.add_theme_font_size_override("font_size", 14)
	name_row.add_child(_level_label)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = "+%d tower damage per level. No cap." % CONSTANTS.LAB_TURRET_DAMAGE_UPGRADE_AMOUNT
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	upgrade_vbox.add_child(desc_lbl)

	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 12)
	_status_label.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
	upgrade_vbox.add_child(_status_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 1.0
	_progress_bar.value = 0.0
	_progress_bar.custom_minimum_size = Vector2(0.0, 18.0)
	_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_bar.show_percentage = false
	upgrade_vbox.add_child(_progress_bar)

	_research_btn = Button.new()
	_research_btn.custom_minimum_size = Vector2(0.0, 40.0)
	_research_btn.pressed.connect(_on_research_pressed)
	upgrade_vbox.add_child(_research_btn)

func open_for_lab(_gp: Vector2i, _building_node: Node) -> void:
	_refresh()
	visible = true

func _refresh() -> void:
	var level: int = GameState.get_upgrade_level("turret_damage")
	var current_dmg: int = GameState.get_turret_damage()
	_level_label.text = "Lv. %d  (%d dmg)" % [level, current_dmg]

	var researching: bool = GameState.lab_research_id == "turret_damage"
	var busy: bool = not GameState.lab_research_id.is_empty()

	_research_btn.disabled = busy
	_research_btn.text = "Research  (%d coins / %ds)" % [
		CONSTANTS.LAB_RESEARCH_TURRET_DAMAGE_COST,
		int(CONSTANTS.LAB_RESEARCH_TURRET_DAMAGE_DURATION)
	]

	if researching:
		_status_label.text = "Researching..."
		_progress_bar.value = GameState.lab_research_progress / CONSTANTS.LAB_RESEARCH_TURRET_DAMAGE_DURATION
	elif busy:
		_status_label.text = "Another research in progress"
		_progress_bar.value = 0.0
	else:
		_status_label.text = ""
		_progress_bar.value = 0.0

func _on_research_pressed() -> void:
	if not GameState.spend_coins(CONSTANTS.LAB_RESEARCH_TURRET_DAMAGE_COST):
		_show_error("Not enough coins!")
		return
	GameState.start_research("turret_damage")
	_refresh()

func _on_research_progress(id: String, progress: float) -> void:
	if not visible or id != "turret_damage":
		return
	_progress_bar.value = progress
	_status_label.text = "Researching... %d%%" % int(progress * 100.0)

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
