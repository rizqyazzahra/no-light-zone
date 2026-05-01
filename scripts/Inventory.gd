## Menyimpan jumlah kabel dan toolkit yang sudah dikumpulkan pemain.
## Script ini di-autoload agar bisa diakses dari mana saja.
extends Node

var cable_count: int = 0
var toolkit_count: int = 0

signal inventory_changed(cable: int, toolkit: int)

func add_item(type: int) -> void:
	# type menggunakan nilai dari Item.ItemType enum
	match type:
		1:  # CABLE
			cable_count += 1
		2:  # TOOLKIT
			toolkit_count += 1
	emit_signal("inventory_changed", cable_count, toolkit_count)

func reset() -> void:
	cable_count = 0
	toolkit_count = 0
	emit_signal("inventory_changed", cable_count, toolkit_count)
