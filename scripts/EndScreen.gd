extends Control

@onready var title_label: Label    = $Card/VBox/TitleLabel
@onready var subtitle_label: Label = $Card/VBox/SubtitleLabel
@onready var retry_btn: Button     = $Card/VBox/Buttons/RetryButton
@onready var menu_btn: Button      = $Card/VBox/Buttons/MenuButton

func _ready() -> void:
	retry_btn.pressed.connect(_on_retry_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

	match GameManager.state:
		GameManager.GameState.WIN:
			_show_win()
		GameManager.GameState.LOSE:
			_show_lose()
		_:
			# Fallback jika diakses langsung dari editor
			_show_lose()

	retry_btn.grab_focus()

func _show_win() -> void:
	title_label.text   = "⚡ POWER RESTORED"
	subtitle_label.text = "The city lights up.\nYou saved everyone."
	title_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.4))
	retry_btn.text = "Play Again"

func _show_lose() -> void:
	title_label.text    = "CONSUMED BY DARKNESS"
	subtitle_label.text = GameManager.lose_reason
	title_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.15))
	retry_btn.text = "Try Again"

func _on_retry_pressed() -> void:
	GameManager.restart()

func _on_menu_pressed() -> void:
	GameManager.go_to_menu()
