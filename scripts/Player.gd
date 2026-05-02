extends CharacterBody2D

const SPEED: float = 120.0
const ACCELERATION: float = 800.0
const FRICTION: float = 600.0
const PICKUP_RADIUS: float = 30.0 # Radius pickup item

enum State { IDLE, WALK }
var current_state: State = State.IDLE
var facing_dir: String = "side"

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var flashlight: Node2D = $Flashlight

# List item yang saat ini ada di dalam radius pickup
var _items_in_range: Array[Node] = []

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var input_dir := _get_input_direction()

	# Velocity
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()

	# State & Animasi
	_update_state(input_dir)
	_update_animation(input_dir)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_try_pickup_nearest()

func _get_input_direction() -> Vector2:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("move_left", "move_right")
	dir.y = Input.get_axis("move_up", "move_down")
	return dir.normalized()

func _try_pickup_nearest() -> void:
	# Cari item terdekat dalam radius PICKUP_RADIUS
	var nearest: Node = null
	var nearest_dist: float = PICKUP_RADIUS

	# Scan semua node di group "item"
	for item in get_tree().get_nodes_in_group("item"):
		var dist: float = global_position.distance_to(item.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = item

	if nearest != null:
		nearest.try_collect(self)

func _on_item_collected(type: int) -> void:
	match type:
		0:  # BATTERY
			if flashlight:
				flashlight.add_battery(flashlight.battery_max)
			GameManager.play_sfx("res://assets/Sound/health-at-100.mp3")
		1:  # CABLE
			Inventory.add_item(type)
			GameManager.play_sfx("res://assets/Sound/item-pick-up.mp3")
		2:  # TOOLKIT
			Inventory.add_item(type)
			GameManager.play_sfx("res://assets/Sound/item-pick-up.mp3")

func _update_state(input_dir: Vector2) -> void:
	var new_state: State = State.IDLE if input_dir == Vector2.ZERO else State.WALK
	var new_facing: String = facing_dir
	
	if input_dir != Vector2.ZERO:
		if abs(input_dir.x) > abs(input_dir.y):
			new_facing = "side"
		elif input_dir.y < 0:
			new_facing = "up"
		elif input_dir.y > 0:
			new_facing = "down"

	if new_state != current_state or new_facing != facing_dir:
		current_state = new_state
		facing_dir = new_facing
		_play_current_animation()

func _play_current_animation() -> void:
	match current_state:
		State.IDLE:
			if facing_dir == "up":
				anim_player.play("idle_up")
			elif facing_dir == "down":
				anim_player.play("idle_down")
			else:
				anim_player.play("idle")
		State.WALK:
			if facing_dir == "up":
				anim_player.play("walk_up")
			elif facing_dir == "down":
				anim_player.play("walk_down")
			else:
				anim_player.play("walk")

func _update_animation(input_dir: Vector2) -> void:
	if input_dir.x != 0:
		sprite.flip_h = input_dir.x < 0
