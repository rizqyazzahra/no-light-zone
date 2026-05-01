extends Area2D

# ---------------------------------------------------------------------------
# Tipe item yang tersedia
# ---------------------------------------------------------------------------
enum ItemType { BATTERY, CABLE, TOOLKIT }

# ---------------------------------------------------------------------------
# EXPORT — diatur dari Inspector per-instance
# ---------------------------------------------------------------------------
@export var item_type: ItemType = ItemType.BATTERY
## Jumlah isi baterai yang ditambahkan (0.0–1.0, hanya berlaku untuk BATTERY)
@export var battery_refill_amount: float = 1.0

# ---------------------------------------------------------------------------
# Preload semua tekstur agar selalu tersedia
# ---------------------------------------------------------------------------
const TEX_BATTERY := preload("res://assets/Item/battery.png")
const TEX_CABLE   := preload("res://assets/Item/wires.png")
const TEX_TOOLKIT := preload("res://assets/Item/toolbox.png")

# Ukuran tampilan item dalam world pixels
const TARGET_SIZE := Vector2(32.0, 32.0)

# ---------------------------------------------------------------------------
# REFERENCES
# ---------------------------------------------------------------------------
@onready var sprite: Sprite2D             = $Sprite2D
@onready var interact_hint: Label         = $InteractHint
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Sinyal ke Player / MainLevel
signal collected(type: ItemType)

# ---------------------------------------------------------------------------
# _ready
# ---------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("item")
	_apply_visuals()
	interact_hint.visible = false
	# Hubungkan sinyal Area2D secara programatik
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	# Mulai animasi float
	if anim_player.has_animation("float"):
		anim_player.play("float")

func _apply_visuals() -> void:
	if not is_instance_valid(sprite):
		return
	match item_type:
		ItemType.BATTERY:
			sprite.texture = TEX_BATTERY
		ItemType.CABLE:
			sprite.texture = TEX_CABLE
		ItemType.TOOLKIT:
			sprite.texture = TEX_TOOLKIT
	# Auto-scale agar tampil TARGET_SIZE
	if sprite.texture != null:
		var tex_size := Vector2(
			float(sprite.texture.get_width()),
			float(sprite.texture.get_height())
		)
		if tex_size.x > 0 and tex_size.y > 0:
			sprite.scale = TARGET_SIZE / tex_size

# ---------------------------------------------------------------------------
# Area2D signals — show/hide interact hint
# ---------------------------------------------------------------------------
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact_hint.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact_hint.visible = false

# ---------------------------------------------------------------------------
# Dipanggil oleh Player saat tekan E
# ---------------------------------------------------------------------------
func try_collect(collector: Node) -> void:
	if not collector.is_in_group("player"):
		return
	if not collected.is_connected(collector._on_item_collected):
		collected.connect(collector._on_item_collected)
	emit_signal("collected", item_type)
	queue_free()
