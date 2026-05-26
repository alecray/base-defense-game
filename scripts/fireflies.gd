extends Node2D

var _particles: GPUParticles2D = null
var _cycle: Node = null

func _ready() -> void:
	_particles = GPUParticles2D.new()
	_particles.amount = 150
	_particles.lifetime = 6.0
	_particles.randomness = 1.0
	_particles.explosiveness = 0.0
	_particles.preprocess = 6.0
	_particles.texture = _make_glow_texture()
	_particles.emitting = true

	var proc_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	proc_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	proc_mat.emission_box_extents = Vector3(700.0, 500.0, 1.0)
	proc_mat.direction = Vector3(0.0, -1.0, 0.0)
	proc_mat.spread = 180.0
	proc_mat.gravity = Vector3.ZERO
	proc_mat.initial_velocity_min = 3.0
	proc_mat.initial_velocity_max = 14.0
	proc_mat.scale_min = 0.7
	proc_mat.scale_max = 2.2
	proc_mat.turbulence_enabled = true
	proc_mat.turbulence_noise_strength = 14.0
	proc_mat.turbulence_noise_scale = 1.8
	proc_mat.turbulence_noise_speed_random = 0.35

	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([
		Color(1.0, 1.0, 0.5, 0.0),
		Color(1.0, 0.95, 0.35, 1.0),
		Color(0.65, 1.0, 0.3, 1.0),
		Color(1.0, 1.0, 0.5, 0.0),
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.12, 0.8, 1.0])
	var color_ramp: GradientTexture1D = GradientTexture1D.new()
	color_ramp.gradient = gradient
	proc_mat.color_ramp = color_ramp

	_particles.process_material = proc_mat

	var canvas_mat: CanvasItemMaterial = CanvasItemMaterial.new()
	canvas_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_particles.material = canvas_mat

	_particles.modulate.a = 0.0
	add_child(_particles)

func _process(_delta: float) -> void:
	if _cycle == null:
		_cycle = get_tree().get_first_node_in_group("day_night_cycle")
	if _cycle == null:
		return
	_particles.modulate.a = float(_cycle.call("get_night_intensity"))

func _make_glow_texture() -> ImageTexture:
	var size: int = 16
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(float(size) * 0.5, float(size) * 0.5)
	for x: int in range(size):
		for y: int in range(size):
			var d: float = Vector2(float(x), float(y)).distance_to(center) / (float(size) * 0.5)
			var a: float = clampf(1.0 - d, 0.0, 1.0)
			a = a * a
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
	return ImageTexture.create_from_image(img)
