extends Control

@onready var play_btn: Button  = $VBox/PlayButton
@onready var quit_btn: Button  = $VBox/QuitButton
@onready var blink_label: Label = $BlinkLabel

var _blink_timer: float = 0.0

func _ready() -> void:
	GameManager.state = GameManager.GameState.MENU
	play_btn.pressed.connect(_on_play_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	# Fokus ke tombol play agar bisa langsung keyboard
	play_btn.grab_focus()

func _process(delta: float) -> void:
	# Animasi kedip pada hint label
	_blink_timer += delta
	if _blink_timer >= 0.8:
		_blink_timer = 0.0
		blink_label.visible = !blink_label.visible

func _on_play_pressed() -> void:
	GameManager.start_game()

func _on_quit_pressed() -> void:
	get_tree().quit()
