extends CharacterBody2D

# ---------------------------------------------------------------------------
# CONSTANTS
# ---------------------------------------------------------------------------
const SPEED: float = 120.0
const ACCELERATION: float = 800.0
const FRICTION: float = 600.0
## Radius pickup item (pixels)
const PICKUP_RADIUS: float = 30.0

# ---------------------------------------------------------------------------
# STATE MACHINE
# ---------------------------------------------------------------------------
enum State { IDLE, WALK }
var current_state: State = State.IDLE

# ---------------------------------------------------------------------------
# REFERENCES
# ---------------------------------------------------------------------------
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: Node2D = $Flashlight

# List item yang saat ini ada di dalam radius pickup
var _items_in_range: Array[Node] = []

# ---------------------------------------------------------------------------
# _ready
# ---------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("player")

# ---------------------------------------------------------------------------
# _physics_process
# ---------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	var input_dir := _get_input_direction()

	# --- Velocity ---
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()

	# --- State & Animasi ---
	_update_state(input_dir)
	_update_animation(input_dir)

# ---------------------------------------------------------------------------
# _process — input non-fisik (pickup)
# ---------------------------------------------------------------------------
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_try_pickup_nearest()

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
func _get_input_direction() -> Vector2:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("move_left", "move_right")
	dir.y = Input.get_axis("move_up", "move_down")
	return dir.normalized()

# ---------------------------------------------------------------------------
# Item Pickup
# ---------------------------------------------------------------------------
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
		1:  # CABLE
			Inventory.add_item(type)
		2:  # TOOLKIT
			Inventory.add_item(type)

# ---------------------------------------------------------------------------
# State Machine
# ---------------------------------------------------------------------------
func _update_state(input_dir: Vector2) -> void:
	var new_state: State
	if input_dir == Vector2.ZERO:
		new_state = State.IDLE
	else:
		new_state = State.WALK

	if new_state != current_state:
		current_state = new_state
		_on_state_enter(current_state)

func _on_state_enter(state: State) -> void:
	match state:
		State.IDLE:
			animated_sprite.play("idle")
		State.WALK:
			animated_sprite.play("walk")

# ---------------------------------------------------------------------------
# Animasi
# ---------------------------------------------------------------------------
func _update_animation(input_dir: Vector2) -> void:
	if input_dir.x != 0:
		animated_sprite.flip_h = input_dir.x < 0
