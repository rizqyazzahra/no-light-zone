## GameManager — autoload singleton untuk mengelola state dan transisi scene.
extends Node

enum GameState { MENU, PLAYING, WIN, LOSE }

var state: GameState = GameState.MENU
var lose_reason: String = "The battery died.\nDarkness consumed you."

# ---------------------------------------------------------------------------
# Trigger Win / Lose
# ---------------------------------------------------------------------------
func trigger_win() -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.WIN
	get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")

func trigger_lose(reason: String = "The battery died.\nDarkness consumed you.") -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.LOSE
	lose_reason = reason
	get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")

# ---------------------------------------------------------------------------
# Navigasi Scene
# ---------------------------------------------------------------------------
func start_game() -> void:
	state = GameState.PLAYING
	Inventory.reset()
	get_tree().change_scene_to_file("res://scenes/MainLevel.tscn")

func go_to_menu() -> void:
	state = GameState.MENU
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func restart() -> void:
	start_game()
