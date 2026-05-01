@tool
extends EditorScript

## Jalankan script ini SEKALI dari menu Tools > Execute Script di Godot Editor
## untuk men-generate texture senter (flashlight cone gradient).
## File akan tersimpan di res://assets/flashlight_cone.png

func _run() -> void:
	var size := 256
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	# Apex (titik asal cahaya) = TENGAH gambar
	# Godot merender PointLight2D dengan pusat texture = posisi light
	# Cone membuka ke KANAN (arah +X), dirotasi oleh Flashlight node ke arah mouse
	var apex := Vector2(size / 2.0, size / 2.0)

	# Half-angle cone: 35 derajat
	var cone_half_angle := deg_to_rad(35.0)
	var max_dist := float(size) * 0.5

	for y in size:
		for x in size:
			var pixel := Vector2(float(x), float(y))
			var offset: Vector2 = pixel - apex

			# Setengah kiri gambar (di belakang player) → transparan penuh
			if offset.x <= 0.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
				continue

			var dist: float = offset.length()
			var angle: float = absf(offset.angle())

			# Faktor sudut: 1.0 di tengah cone, 0.0 di tepi
			var angle_factor := clampf(1.0 - (angle / cone_half_angle), 0.0, 1.0)
			# Faktor jarak: 1.0 di apex, 0.0 di ujung cone
			var dist_factor := clampf(1.0 - (dist / max_dist), 0.0, 1.0)

			# Soft edge dengan kurva kuadrat
			var alpha: float = pow(angle_factor, 1.5) * pow(dist_factor, 0.6)

			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	img.save_png("res://assets/flashlight_cone.png")
	print("[FlashlightTexGen] Saved to res://assets/flashlight_cone.png")
