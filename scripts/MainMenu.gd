extends Control

@onready var play_btn: Button  = $VBox/PlayButton
@onready var quit_btn: Button  = $VBox/QuitButton

var _blink_timer: float = 0.0

func _ready() -> void:
	GameManager.state = GameManager.GameState.MENU
	play_btn.pressed.connect(_on_play_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	play_btn.grab_focus()

func _on_play_pressed() -> void:
	GameManager.start_game()

func _on_quit_pressed() -> void:
	get_tree().quit()
