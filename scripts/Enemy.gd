extends CharacterBody2D

@export var speed: float = 60.0
@export var catch_distance: float = 30.0

@onready var catch_area: Area2D = $CatchArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	
	# Cari player di dalam scene
	player = get_tree().get_first_node_in_group("player")
	
	if catch_area:
		catch_area.body_entered.connect(_on_catch_area_body_entered)
		
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
		
	# Setup suara monster
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://assets/Sound/monster.mp3")
	sfx.max_distance = 600.0  # Jarak maksimal suara terdengar (pas dengan despawn)
	sfx.attenuation = 2.0
	sfx.finished.connect(func(): sfx.play())
	add_child(sfx)
	sfx.play()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	# Cek jika player sudah lari cukup jauh
	if global_position.distance_to(player.global_position) > 600.0:
		queue_free()
		return
		
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	
	# Atur arah hadap sprite berdasarkan pergerakan (opsional)
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false
		
	move_and_slide()

func _on_catch_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.trigger_lose("Tertangkap oleh makhluk tak dikenal!\nJangan biarkan dia mendekat.")
