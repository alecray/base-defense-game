extends CanvasLayer

signal worker_purchased(gp: Vector2i)

var _target_tile: Vector2i = Vector2i(-1, -1)
var _core_node: Node = null
var _buy_btn: Button
var _food_cap_btn: Button
var _power_cap_btn: Button
var _ui_root: Control

func _ready() -> void:
	add_to_group("worker_ui")
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
	panel.custom_minimum_size = Vector2(300.0, 320.0)
	root.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(title_row)

	var title: Label = Label.new()
	title.text = "Core Management"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(title)

	var close_btn: Button = Button.new()
	close_btn.text = "✕"
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	_buy_btn = Button.new()
	_buy_btn.custom_minimum_size = Vector2(0.0, 48.0)
	_buy_btn.pressed.connect(_on_buy_worker)
	vbox.add_child(_buy_btn)

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	_food_cap_btn = Button.new()
	_food_cap_btn.custom_minimum_size = Vector2(0.0, 40.0)
	_food_cap_btn.pressed.connect(_on_upgrade_food_cap)
	vbox.add_child(_food_cap_btn)

	_power_cap_btn = Button.new()
	_power_cap_btn.custom_minimum_size = Vector2(0.0, 40.0)
	_power_cap_btn.pressed.connect(_on_upgrade_power_cap)
	vbox.add_child(_power_cap_btn)

func open_for_core(gp: Vector2i, core_node: Node) -> void:
	_target_tile = gp
	_core_node = core_node
	_refresh()
	visible = true

func _refresh() -> void:
	_buy_btn.text = "Buy Worker\n%d coins" % CONSTANTS.WORKER_COST
	_buy_btn.disabled = GameState.coins < CONSTANTS.WORKER_COST
	_food_cap_btn.text = "Upgrade Food Cap  +%d  (%d coins)\n[Current: %d]" % [CONSTANTS.FOOD_CAP_UPGRADE_AMOUNT, CONSTANTS.FOOD_CAP_UPGRADE_COST, GameState.food_cap]
	_food_cap_btn.disabled = GameState.coins < CONSTANTS.FOOD_CAP_UPGRADE_COST
	_power_cap_btn.text = "Upgrade Power Cap  +%d  (%d coins)\n[Current: %d]" % [CONSTANTS.POWER_CAP_UPGRADE_AMOUNT, CONSTANTS.POWER_CAP_UPGRADE_COST, GameState.power_cap]
	_power_cap_btn.disabled = GameState.coins < CONSTANTS.POWER_CAP_UPGRADE_COST

func _close() -> void:
	visible = false
	_target_tile = Vector2i(-1, -1)
	_core_node = null

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_close()

func _on_buy_worker() -> void:
	if _target_tile == Vector2i(-1, -1):
		return
	if GameState.worker_count >= GameState.get_worker_cap():
		_show_error("Needs more Housing!")
		return
	if not GameState.spend_coins(CONSTANTS.WORKER_COST):
		_show_error("Not enough coins!")
		return
	worker_purchased.emit(_target_tile)
	_refresh()

func _on_upgrade_food_cap() -> void:
	if not GameState.upgrade_food_cap():
		_show_error("Not enough coins!")
		return
	_refresh()

func _on_upgrade_power_cap() -> void:
	if not GameState.upgrade_power_cap():
		_show_error("Not enough coins!")
		return
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
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
			_close()
