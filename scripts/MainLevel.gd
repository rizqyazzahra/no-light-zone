extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer        = $HUD
@onready var generator: Area2D       = $Generator

func _ready() -> void:
	# Connect Flashlight → HUD + lose condition
	var flashlight: Node = player.get_node("Flashlight")
	hud.connect_to_flashlight(flashlight)
	flashlight.battery_empty.connect(_on_battery_empty)

	# Connect Generator → win condition
	generator.activated.connect(_on_generator_activated)

func _on_battery_empty() -> void:
	GameManager.trigger_lose("The battery died.\nDarkness consumed you.")

func _on_generator_activated() -> void:
	GameManager.trigger_win()
