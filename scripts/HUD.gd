extends CanvasLayer

@onready var battery_bar: ProgressBar       = %BatteryBar
@onready var battery_label: Label           = %BatteryLabel
@onready var flashlight_label: Label        = %FlashlightLabel
@onready var low_batt_warning: Control      = %LowBattWarning
@onready var low_batt_label: Label          = %LowBattLabel
@onready var anim_player: AnimationPlayer   = %AnimationPlayer
@onready var cable_label: Label             = %CableLabel
@onready var toolkit_label: Label           = %ToolkitLabel

# State
var _is_low: bool = false
var _low_batt_sfx: AudioStreamPlayer = null

func _ready() -> void:
	_update_battery_display(1.0)
	low_batt_warning.visible = false
	flashlight_label.text = "ON"
	flashlight_label.modulate = Color(0.4, 1.0, 0.6)
	# Connect inventory
	Inventory.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed(0, 0)

# Dipanggil oleh MainLevel setelah scene siap
func connect_to_flashlight(flashlight: Node) -> void:
	flashlight.battery_changed.connect(_on_battery_changed)
	flashlight.battery_empty.connect(_on_battery_empty)
	flashlight.flashlight_toggled.connect(_on_flashlight_toggled)

func _on_battery_changed(pct: float) -> void:
	_update_battery_display(pct)

	# Trigger low battery warning
	var threshold := 0.2
	if pct < threshold and not _is_low:
		_is_low = true
		_show_low_battery_warning()
	elif pct >= threshold and (_is_low or low_batt_warning.visible):
		_is_low = false
		if anim_player.is_playing():
			anim_player.stop()
		low_batt_warning.visible = false
		_stop_low_batt_sfx()

func _on_battery_empty() -> void:
	battery_label.text = "DEAD"
	battery_bar.value = 0.0
	battery_bar.modulate = Color(0.3, 0.3, 0.3)
	low_batt_label.text = "BATTERY DEAD"
	low_batt_warning.visible = true
	_stop_low_batt_sfx()

func _on_flashlight_toggled(on: bool) -> void:
	if on:
		flashlight_label.text = "ON"
		flashlight_label.modulate = Color(0.4, 1.0, 0.6)
	else:
		flashlight_label.text = "OFF"
		flashlight_label.modulate = Color(0.6, 0.6, 0.6)

# UI Helpers
func _update_battery_display(pct: float) -> void:
	battery_bar.value = pct * 100.0

	# Label persentase
	battery_label.text = "%d%%" % int(pct * 100.0)

	# Warna bar berubah seiring level
	if pct > 0.5:
		battery_bar.modulate = Color(0.3, 1.0, 0.5)        # Hijau
	elif pct > 0.2:
		battery_bar.modulate = Color(1.0, 0.75, 0.1)       # Kuning
	else:
		# Oranye→merah pulsing (handled by animation)
		battery_bar.modulate = Color(1.0, 0.25, 0.1)

func _show_low_battery_warning() -> void:
	low_batt_label.text = "LOW BATTERY"
	low_batt_warning.visible = true
	if anim_player.has_animation("blink_warning"):
		anim_player.play("blink_warning")
	# Mulai low battery sound looping
	if not is_instance_valid(_low_batt_sfx):
		_low_batt_sfx = AudioStreamPlayer.new()
		_low_batt_sfx.stream = load("res://assets/Sound/low-battery.mp3")
		_low_batt_sfx.volume_db = -3.0
		_low_batt_sfx.finished.connect(func(): if is_instance_valid(_low_batt_sfx): _low_batt_sfx.play())
		add_child(_low_batt_sfx)
		_low_batt_sfx.play()

func _stop_low_batt_sfx() -> void:
	if is_instance_valid(_low_batt_sfx):
		_low_batt_sfx.stop()
		_low_batt_sfx.queue_free()
		_low_batt_sfx = null

func _on_inventory_changed(cable: int, toolkit: int) -> void:
	cable_label.text = "%d / 5" % cable
	toolkit_label.text = "%d / 2" % toolkit
