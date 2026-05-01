extends Node2D

# ---------------------------------------------------------------------------
# EXPORT — bisa diatur dari inspector
# ---------------------------------------------------------------------------
## Durasi baterai penuh dalam detik
@export var battery_max: float = 120.0
## Seberapa cepat baterai habis saat nyala
@export var drain_rate: float = 1.0
## Radius senter saat baterai penuh (pixels)
@export var range_full: float = 1200.0
## Radius senter saat baterai hampir habis
@export var range_low: float = 400.0
## Energi di bawah ini dianggap "low battery"
@export var low_battery_threshold: float = 20.0

# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var battery_current: float
var is_on: bool = true

# ---------------------------------------------------------------------------
# REFERENCES
# ---------------------------------------------------------------------------
@onready var light: PointLight2D = $PointLight2D

# Sinyal untuk HUD (nanti)
signal battery_changed(pct: float)
signal battery_empty()
signal flashlight_toggled(on: bool)

# ---------------------------------------------------------------------------
# _ready
# ---------------------------------------------------------------------------
func _ready() -> void:
	battery_current = battery_max
	_apply_battery_to_light()

# ---------------------------------------------------------------------------
# _process
# ---------------------------------------------------------------------------
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

	# Rotasikan senter ke arah kursor mouse
	_rotate_to_mouse()

# ---------------------------------------------------------------------------
# Logika Internal
# ---------------------------------------------------------------------------
func _rotate_to_mouse() -> void:
	# Guard: viewport bisa null saat scene sedang di-unload
	if not is_inside_tree() or get_viewport() == null:
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = mouse_pos - global_position
	rotation = direction.angle()

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
	light.color = Color(1.0, 0.5, 0.1)  # Oranye saat kritis

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------
func get_battery_pct() -> float:
	return battery_current / battery_max

func add_battery(amount: float) -> void:
	battery_current = minf(battery_current + amount, battery_max)
	_apply_battery_to_light()
	if battery_current > 0.0 and not is_on:
		_toggle()
