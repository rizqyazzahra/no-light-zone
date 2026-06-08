extends Node2D

const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")
const ENEMY2_SCENE := preload("res://scenes/Enemy2.tscn")

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
	
	# Mulai timer untuk spawn musuh
	spawn_enemy_delayed()
	
	# Mulai timer untuk spawn enemy2
	spawn_enemy_2_delayed()

func spawn_enemy_delayed() -> void:
	await get_tree().create_timer(3.0).timeout
	
	while is_inside_tree():
		var space_state = get_world_2d().direct_space_state
		var valid_pos = false
		var spawn_pos = Vector2.ZERO
		var attempts = 0
		
		while not valid_pos and attempts < 100:
			attempts += 1
			if not is_instance_valid(player):
				break
				
			var angle = randf() * TAU
			var distance = randf_range(250, 350)
			var potential_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
			
			# Mengecek apakah koordinat spawn bertabrakan dengan bangunan/collision lain
			var query = PhysicsPointQueryParameters2D.new()
			query.position = potential_pos
			query.collision_mask = 1
			
			var result = space_state.intersect_point(query)
			# Jika result kosong, berarti posisinya aman dari bangunan
			if result.is_empty():
				valid_pos = true
				spawn_pos = potential_pos
				
		if valid_pos:
			var enemy = ENEMY_SCENE.instantiate()
			enemy.global_position = spawn_pos
			add_child(enemy)
			
		# Tunggu sampai musuh biasa hilang (pakai grup sendiri, independen dari Enemy2)
		while is_inside_tree() and get_tree().get_nodes_in_group("regular_enemy").size() > 0:
			await get_tree().create_timer(1.0).timeout
			
		if not is_inside_tree():
			break
			
		# Tunggu 10-15 detik sebelum muncul musuh berikutnya
		var wait_time = randf_range(10.0, 15.0)
		await get_tree().create_timer(wait_time).timeout

func spawn_enemy_2_delayed() -> void:
	# Enemy2 muncul pertama kali setelah 5 detik
	await get_tree().create_timer(5.0).timeout
	
	while is_inside_tree():
		var space_state = get_world_2d().direct_space_state
		var valid_pos = false
		var spawn_pos = Vector2.ZERO
		var attempts = 0
		
		while not valid_pos and attempts < 100:
			attempts += 1
			if not is_instance_valid(player):
				break
				
			var angle = randf() * TAU
			var distance = randf_range(280, 380)
			var potential_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
			
			var query = PhysicsPointQueryParameters2D.new()
			query.position = potential_pos
			query.collision_mask = 1
			
			var result = space_state.intersect_point(query)
			if result.is_empty():
				valid_pos = true
				spawn_pos = potential_pos
				
		if valid_pos:
			var stalker = ENEMY2_SCENE.instantiate()
			stalker.global_position = spawn_pos
			add_child(stalker)
		
		# Tunggu sampai Enemy2 hilang
		while is_inside_tree() and get_tree().get_nodes_in_group("shadow_enemy").size() > 0:
			await get_tree().create_timer(1.0).timeout
			
		if not is_inside_tree():
			break
			
		# Jeda sebelum Enemy2 berikutnya
		var wait_time = randf_range(15.0, 25.0)
		await get_tree().create_timer(wait_time).timeout

func _on_battery_empty() -> void:
	GameManager.trigger_lose("The battery died.\nDarkness consumed you.")

func _on_generator_activated() -> void:
	GameManager.trigger_win()
