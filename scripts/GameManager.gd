extends Node

enum GameState { MENU, PLAYING, WIN, LOSE }

var state: GameState = GameState.MENU
var lose_reason: String = "The battery died.\nDarkness consumed you."

var bgm_player: AudioStreamPlayer

func _ready() -> void:
	# Setup Background Music
	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = load("res://assets/Sound/backsound music.mp3")
	bgm_player.volume_db = -10.0
	bgm_player.finished.connect(func(): bgm_player.play())
	add_child(bgm_player)
	bgm_player.play()

func play_sfx(path: String) -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load(path)
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

func trigger_win() -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.WIN
	play_sfx("res://assets/Sound/you-have-reached-the-save-point.mp3")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/EndScreen.tscn")

func trigger_lose(reason: String = "The battery died.\nDarkness consumed you.") -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.LOSE
	lose_reason = reason
	play_sfx("res://assets/Sound/game-over-sound.mp3")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/EndScreen.tscn")

func start_game() -> void:
	state = GameState.PLAYING
	Inventory.reset()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/MainLevel.tscn")

func go_to_menu() -> void:
	state = GameState.MENU
	get_tree().call_deferred("change_scene_to_file", "res://scenes/MainMenu.tscn")

func restart() -> void:
	start_game()
