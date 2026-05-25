extends CanvasLayer

signal building_purchased(building_name: String, gp: Vector2i)

var _target_tile: Vector2i = Vector2i(-1, -1)
var _buttons: Dictionary = {}
var _ui_root: Control

func _ready() -> void:
	add_to_group("shop_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build_ui()

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
	panel.custom_minimum_size = Vector2(340.0, 220.0)
	root.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(title_row)

	var title: Label = Label.new()
	title.text = "Build"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(title)

	var close_btn: Button = Button.new()
	close_btn.text = "✕"
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	var grid: GridContainer = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)

	for building_name: String in GameState.BUILDING_COSTS.keys():
		var cost: int = GameState.BUILDING_COSTS[building_name]
		var btn: Button = Button.new()
		btn.text = "%s\n%d coins" % [building_name, cost]
		btn.custom_minimum_size = Vector2(72.0, 72.0)
		btn.pressed.connect(_on_building_selected.bind(building_name))
		grid.add_child(btn)
		_buttons[building_name] = btn

func open_for_tile(gp: Vector2i) -> void:
	_target_tile = gp
	_refresh_buttons()
	visible = true

func _refresh_buttons() -> void:
	for building_name: String in _buttons:
		var btn: Button = _buttons[building_name] as Button
		btn.disabled = GameState.is_at_building_limit(building_name) \
			or not GameState.has_prerequisite(building_name)

func _close() -> void:
	visible = false
	_target_tile = Vector2i(-1, -1)

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_close()

func _on_building_selected(building_name: String) -> void:
	if _target_tile == Vector2i(-1, -1):
		return
	var cost: int = GameState.BUILDING_COSTS.get(building_name, 0)
	if GameState.coins < cost:
		_show_error("Not enough coins!")
		return
	building_purchased.emit(building_name, _target_tile)
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
			_close()
