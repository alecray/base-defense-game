extends CanvasLayer

var _farm: Node = null
var _assigned_label: Label
var _free_label: Label
var _assign_btn: Button
var _unassign_btn: Button
var _fortify_btn: Button
var _upgrade_btn: Button
var _ui_root: Control

func _ready() -> void:
	add_to_group("farm_ui")
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
	panel.custom_minimum_size = Vector2(260.0, 250.0)
	root.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(title_row)

	var title: Label = Label.new()
	title.text = "Farm Management"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(title)

	var close_btn: Button = Button.new()
	close_btn.text = "✕"
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	_assigned_label = Label.new()
	_assigned_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_assigned_label)

	_free_label = Label.new()
	_free_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_free_label)

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	_unassign_btn = Button.new()
	_unassign_btn.text = "- Remove Worker"
	_unassign_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_unassign_btn.pressed.connect(_on_unassign)
	btn_row.add_child(_unassign_btn)

	_assign_btn = Button.new()
	_assign_btn.text = "+ Assign Worker"
	_assign_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_assign_btn.pressed.connect(_on_assign)
	btn_row.add_child(_assign_btn)

	var sep3: HSeparator = HSeparator.new()
	vbox.add_child(sep3)

	_fortify_btn = Button.new()
	_fortify_btn.custom_minimum_size = Vector2(0.0, 40.0)
	_fortify_btn.pressed.connect(_on_fortify)
	vbox.add_child(_fortify_btn)

	_upgrade_btn = Button.new()
	_upgrade_btn.custom_minimum_size = Vector2(0.0, 40.0)
	_upgrade_btn.pressed.connect(_on_upgrade)
	vbox.add_child(_upgrade_btn)

func open_for_farm(farm_node: Node) -> void:
	_farm = farm_node
	_refresh()
	visible = true

func _refresh() -> void:
	if _farm == null:
		return
	var assigned: int = int(_farm.call("get_assigned_workers"))
	var free: int = GameState.get_free_workers()
	_assigned_label.text = "Assigned Workers: %d" % assigned
	_free_label.text = "Free Workers: %d" % free
	_assign_btn.disabled = free <= 0
	_unassign_btn.disabled = assigned <= 0
	if bool(_farm.call("is_fortified")):
		_fortify_btn.text = "Fortified  (Shield: %d / %d)" % [int(_farm.call("get_shield_hp")), CONSTANTS.SHIELD_MAX_HP]
		_fortify_btn.disabled = true
	else:
		_fortify_btn.text = "Fortify  (%d coins)" % CONSTANTS.FORTIFY_COST
		_fortify_btn.disabled = GameState.coins < CONSTANTS.FORTIFY_COST
	var ulevel: int = int(_farm.get("upgrade_level"))
	if ulevel >= CONSTANTS.FARM_UPGRADE_MAX:
		_upgrade_btn.text = "Upgraded  (+%d food/worker)" % (ulevel * CONSTANTS.FARM_UPGRADE_FOOD_BONUS)
		_upgrade_btn.disabled = true
	else:
		_upgrade_btn.text = "Upgrade Farm  (%d coins) → +%d food/worker" % [CONSTANTS.FARM_UPGRADE_COST, CONSTANTS.FARM_UPGRADE_FOOD_BONUS]
		_upgrade_btn.disabled = GameState.coins < CONSTANTS.FARM_UPGRADE_COST

func _close() -> void:
	visible = false
	_farm = null

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_close()

func _on_assign() -> void:
	if _farm == null:
		return
	_farm.call("assign_worker")
	_refresh()

func _on_unassign() -> void:
	if _farm == null:
		return
	_farm.call("unassign_worker")
	_refresh()

func _on_fortify() -> void:
	if _farm == null:
		return
	if not bool(_farm.call("fortify")):
		_show_error("Not enough coins!")
		return
	_refresh()

func _on_upgrade() -> void:
	if _farm == null:
		return
	if not bool(_farm.call("do_upgrade", CONSTANTS.FARM_UPGRADE_COST, CONSTANTS.FARM_UPGRADE_MAX)):
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
