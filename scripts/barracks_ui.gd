extends CanvasLayer

var _building: Node = null
var _soldiers_label: Label
var _buy_btn: Button
var _fortify_btn: Button
var _ui_root: Control

func _ready() -> void:
	add_to_group("barracks_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build_ui()
	GameState.soldiers_changed.connect(_on_soldiers_changed)

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
	panel.custom_minimum_size = Vector2(300.0, 210.0)
	root.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(title_row)

	var title: Label = Label.new()
	title.text = "Barracks"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(title)

	var close_btn: Button = Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	_soldiers_label = Label.new()
	_soldiers_label.add_theme_font_size_override("font_size", 15)
	_soldiers_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	vbox.add_child(_soldiers_label)

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	_buy_btn = Button.new()
	_buy_btn.custom_minimum_size = Vector2(0.0, 48.0)
	_buy_btn.pressed.connect(_on_buy_soldier)
	vbox.add_child(_buy_btn)

	var sep3: HSeparator = HSeparator.new()
	vbox.add_child(sep3)

	_fortify_btn = Button.new()
	_fortify_btn.custom_minimum_size = Vector2(0.0, 40.0)
	_fortify_btn.pressed.connect(_on_fortify)
	vbox.add_child(_fortify_btn)

func open_for_barracks(building_node: Node) -> void:
	_building = building_node
	_refresh()
	visible = true

func _refresh() -> void:
	if _building == null:
		return
	var cap: int = GameState.get_soldier_cap()
	_soldiers_label.text = "Soldiers: %d / %d  (+%d cap per Barracks)" % [GameState.soldiers, cap, CONSTANTS.BARRACKS_SOLDIER_BONUS]
	_buy_btn.text = "Buy Soldier  (%d coins)" % CONSTANTS.SOLDIER_COST
	_buy_btn.disabled = GameState.soldiers >= cap or GameState.coins < CONSTANTS.SOLDIER_COST
	if bool(_building.call("is_fortified")):
		_fortify_btn.text = "Fortified  (Shield: %d / %d)" % [int(_building.call("get_shield_hp")), CONSTANTS.SHIELD_MAX_HP]
		_fortify_btn.disabled = true
	else:
		_fortify_btn.text = "Fortify  (%d coins)" % CONSTANTS.FORTIFY_COST
		_fortify_btn.disabled = GameState.coins < CONSTANTS.FORTIFY_COST

func _close() -> void:
	visible = false
	_building = null

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_close()

func _on_buy_soldier() -> void:
	if not GameState.buy_soldier():
		var msg: String = "Soldier cap reached!" if GameState.coins >= CONSTANTS.SOLDIER_COST else "Not enough coins!"
		_show_error(msg)
		return
	if _building != null:
		var grid: Node = get_tree().get_first_node_in_group("tile_grid")
		if grid != null:
			grid.call("spawn_soldier_at", (_building as Node2D).global_position)
	_refresh()

func _on_fortify() -> void:
	if _building == null:
		return
	if not bool(_building.call("fortify")):
		_show_error("Not enough coins!")
		return
	_refresh()

func _on_soldiers_changed(_count: int, _cap: int) -> void:
	if visible:
		_refresh()

func _show_error(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	label.add_theme_font_size_override("font_size", 16)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_top = 100.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ui_root.add_child(label)
	var tween: Tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.tween_callback(label.queue_free)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
			_close()
