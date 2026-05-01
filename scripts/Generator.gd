extends Area2D

signal activated

## Item yang dibutuhkan untuk mengaktifkan generator
@export var required_cables: int  = 5
@export var required_toolkits: int = 2

@onready var interact_hint: Label  = $InteractHint
@onready var popup_label: Label    = $PopupLabel
@onready var popup_timer: Timer    = $PopupTimer

var _player_nearby: bool = false
var _activated: bool = false

func _ready() -> void:
	# Connect Area2D signals secara code karena tidak di-setup lewat editor
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interact_hint.visible = false
	if popup_label:
		popup_label.visible = false
	if popup_timer:
		popup_timer.timeout.connect(_on_popup_timeout)

func _process(_delta: float) -> void:
	if _activated:
		return

	if _player_nearby and Input.is_action_just_pressed("interact"):
		if _can_activate():
			_on_activated()
		else:
			_show_missing_popup()

func _show_missing_popup() -> void:
	if popup_label and popup_timer:
		popup_label.text = "Kamu belum mengumpulkan cukup item!"
		popup_label.visible = true
		popup_timer.start(2.0)

func _on_popup_timeout() -> void:
	if popup_label:
		popup_label.visible = false

func _can_activate() -> bool:
	return (Inventory.cable_count >= required_cables
		and Inventory.toolkit_count >= required_toolkits)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		interact_hint.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		interact_hint.visible = false

func _on_activated() -> void:
	_activated = true
	interact_hint.visible = false
	if popup_label:
		popup_label.visible = false
	emit_signal("activated")
	GameManager.trigger_win()
