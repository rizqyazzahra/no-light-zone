extends Node2D

@export var battery_max: float = 120.0
@export var drain_rate: float = 1.0
@export var range_full: float = 1200.0
@export var range_low: float = 400.0
@export var low_battery_threshold: float = 20.0

var battery_current: float
var is_on: bool = true

@onready var light: PointLight2D = $PointLight2D

# Sinyal untuk HUD
signal battery_changed(pct: float)
signal battery_empty()
signal flashlight_toggled(on: bool)

func _ready() -> void:
	battery_current = battery_max
	_apply_battery_to_light()

func _process(delta: float) -> void:
	# Toggle senter dengan F
	if Input.is_action_just_pressed("toggle_flashlight"):
		_toggle()

	if not is_on:
		return

	# Drain baterai
	if battery_current > 0.0:
		battery_current -= drain_rate * delta
		battery_current = maxf(battery_current, 0.0)
		_apply_battery_to_light()
		emit_signal("battery_changed", get_battery_pct())

		if battery_current <= 0.0:
			emit_signal("battery_empty")
			_force_off()
	else:
		_apply_battery_to_light()

	# Update arah senter
	_update_flashlight_direction(delta)

var _mouse_aim_timer: float = 0.0
var _last_mouse_pos: Vector2 = Vector2.ZERO

func _update_flashlight_direction(delta: float) -> void:
	if not is_inside_tree() or get_viewport() == null:
		return
		
	var current_mouse_pos = get_viewport().get_mouse_position()
	
	if current_mouse_pos.distance_squared_to(_last_mouse_pos) > 1.0:
		_mouse_aim_timer = 1.5 # Aktifkan mode mouse selama 1.5 detik
		_last_mouse_pos = current_mouse_pos
	
	if _mouse_aim_timer > 0.0:
		_mouse_aim_timer -= delta
		# Mode: Mengikuti Mouse
		var direction: Vector2 = get_global_mouse_position() - global_position
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, 25.0 * delta)
	else:
		# Mode: Mengikuti Arah Gerakan Karakter
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir != Vector2.ZERO:
			var target_angle = input_dir.angle()
			rotation = lerp_angle(rotation, target_angle, 10.0 * delta)

func _toggle() -> void:
	if battery_current <= 0.0:
		return  # Tidak bisa nyala kalau baterai habis
	is_on = !is_on
	light.enabled = is_on
	emit_signal("flashlight_toggled", is_on)

func _force_off() -> void:
	is_on = false
	light.enabled = false
	emit_signal("flashlight_toggled", false)

func _apply_battery_to_light() -> void:
	var pct := get_battery_pct()

	if not is_on or pct <= 0.0:
		light.enabled = false
		return

	light.enabled = true

	# Radius mengecil seiring baterai berkurang
	light.texture_scale = lerpf(range_low, range_full, pct) / 100.0

	# Efek kedip jika low battery
	if pct < (low_battery_threshold / battery_max):
		_apply_flicker(pct)
	else:
		# Warna senter: putih kebiruan saat penuh, oranye redup saat hampir habis
		light.color = Color(1.0, lerpf(0.6, 1.0, pct), lerpf(0.3, 1.0, pct))

func _apply_flicker(pct: float) -> void:
	# Flicker makin parah saat baterai makin habis
	var flicker_intensity := (1.0 - pct * (battery_max / low_battery_threshold))
	if randf() < flicker_intensity * 0.3:
		light.enabled = !light.enabled
	light.color = Color(1.0, 0.5, 0.1)

func get_battery_pct() -> float:
	return battery_current / battery_max

func add_battery(amount: float) -> void:
	battery_current = minf(battery_current + amount, battery_max)
	_apply_battery_to_light()
	if battery_current > 0.0 and not is_on:
		_toggle()
