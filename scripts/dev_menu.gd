extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	visible = false
	_build_ui()

func _build_ui() -> void:
	var root: Control = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(overlay)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(260.0, 320.0)
	root.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(title_row)

	var title: Label = Label.new()
	title.text = "Developer Menu"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(title)

	var close_btn: Button = Button.new()
	close_btn.text = "✕"
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	var add_100: Button = Button.new()
	add_100.text = "Add 100 Coins"
	add_100.pressed.connect(func() -> void: GameState.add_coins(100))
	vbox.add_child(add_100)

	var add_1000: Button = Button.new()
	add_1000.text = "Add 1000 Coins"
	add_1000.pressed.connect(func() -> void: GameState.add_coins(1000))
	vbox.add_child(add_1000)

	var add_power: Button = Button.new()
	add_power.text = "Add 50 Power"
	add_power.pressed.connect(func() -> void: GameState.add_power(50))
	vbox.add_child(add_power)

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	var skip_dusk_btn: Button = Button.new()
	skip_dusk_btn.text = "Skip to Dusk"
	skip_dusk_btn.pressed.connect(_on_skip_dusk_pressed)
	vbox.add_child(skip_dusk_btn)

	var sep3: HSeparator = HSeparator.new()
	vbox.add_child(sep3)

	var reset_btn: Button = Button.new()
	reset_btn.text = "Reset Game"
	reset_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	reset_btn.pressed.connect(_on_reset_pressed)
	vbox.add_child(reset_btn)

	var reset_legacy_btn: Button = Button.new()
	reset_legacy_btn.text = "Reset Legacy Data"
	reset_legacy_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	reset_legacy_btn.pressed.connect(_on_reset_legacy_pressed)
	vbox.add_child(reset_legacy_btn)

func _on_skip_dusk_pressed() -> void:
	var cycle: Node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle != null:
		cycle.call("skip_to_dusk")
	_close()

func _on_reset_pressed() -> void:
	var sm: Node = get_tree().get_first_node_in_group("save_manager")
	if sm != null:
		sm.call("reset_game")
	_close()

func _on_reset_legacy_pressed() -> void:
	LegacyState.reset_all()
	_close()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.physical_keycode == KEY_U:
		if visible:
			_close()
		else:
			_open()
	elif key_event.physical_keycode == KEY_ESCAPE and visible:
		_close()

func _open() -> void:
	visible = true
	get_tree().paused = true

func _close() -> void:
	visible = false
	get_tree().paused = false
