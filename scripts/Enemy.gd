extends CharacterBody2D

@export var speed: float = 80.0
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
		
	# Jalankan animasi default jika ada
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	# Arahkan musuh langsung ke posisi player (karena tembus pandang/tembus tembok)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	
	# Atur arah hadap sprite berdasarkan pergerakan (opsional)
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false
		
	# move_and_slide tanpa collision_mask akan membuatnya melayang menembus apa saja
	move_and_slide()

func _on_catch_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Player tertangkap!
		GameManager.trigger_lose("Tertangkap oleh makhluk tak dikenal!\nJangan biarkan dia mendekat.")
