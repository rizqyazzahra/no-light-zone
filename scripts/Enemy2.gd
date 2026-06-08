extends CharacterBody2D

@export var speed: float = 45.0
@export var catch_distance: float = 30.0

@onready var catch_area: Area2D = $CatchArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var eye_light_left: PointLight2D = $EyeLightLeft
@onready var eye_light_right: PointLight2D = $EyeLightRight

var player: Node2D = null
var _time: float = 0.0

# Posisi mata
const EYE_LEFT_X_RIGHT  := -4.0
const EYE_RIGHT_X_RIGHT :=  4.0
const EYE_LEFT_X_LEFT   :=  4.0
const EYE_RIGHT_X_LEFT  := -4.0
const EYE_Y             := -8.0

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("shadow_enemy")

	player = get_tree().get_first_node_in_group("player")

	if catch_area:
		catch_area.body_entered.connect(_on_catch_area_body_entered)

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")

	# Buat tekstur radial (lingkaran) agar cahaya mata tidak punya arah
	var gradient := Gradient.new()
	gradient.colors = [Color(1.0, 0.15, 0.05, 1.0), Color(1.0, 0.05, 0.0, 0.0)]
	gradient.offsets = [0.0, 1.0]
	var eye_tex := GradientTexture2D.new()
	eye_tex.gradient = gradient
	eye_tex.fill = GradientTexture2D.FILL_RADIAL
	eye_tex.fill_from = Vector2(0.5, 0.5)
	eye_tex.fill_to = Vector2(1.0, 0.5)
	eye_tex.width = 64
	eye_tex.height = 64
	eye_light_left.texture  = eye_tex
	eye_light_right.texture = eye_tex

	_update_eye_positions(false)

	var sfx := AudioStreamPlayer2D.new()
	sfx.stream = load("res://assets/Sound/monster.mp3")
	sfx.max_distance = 600.0
	sfx.attenuation = 2.0
	sfx.pitch_scale = 0.65
	sfx.finished.connect(func(): sfx.play())
	add_child(sfx)
	sfx.play()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# Despawn jika terlalu jauh
	if global_position.distance_to(player.global_position) > 600.0:
		queue_free()
		return

	_time += delta

	# Efek denyut mata (pulse)
	var pulse := 2.0 + 0.5 * sin(_time * 2.8)
	eye_light_left.energy  = pulse
	eye_light_right.energy = pulse

	# Gerak mendekat ke player
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * speed

	# Flip sprite & atur posisi mata sesuai arah hadap
	if velocity.x < 0:
		animated_sprite.flip_h = true
		_update_eye_positions(true)   # hadap kiri
	elif velocity.x > 0:
		animated_sprite.flip_h = false
		_update_eye_positions(false)  # hadap kanan

	move_and_slide()

func _update_eye_positions(facing_left: bool) -> void:
	if facing_left:
		eye_light_left.position  = Vector2(EYE_LEFT_X_LEFT,  EYE_Y)
		eye_light_right.position = Vector2(EYE_RIGHT_X_LEFT, EYE_Y)
	else:
		eye_light_left.position  = Vector2(EYE_LEFT_X_RIGHT,  EYE_Y)
		eye_light_right.position = Vector2(EYE_RIGHT_X_RIGHT, EYE_Y)

func _on_catch_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.trigger_lose(
			"Sesuatu merenggutmu dari kegelapan...\nMata itu yang terakhir kamu lihat."
		)
