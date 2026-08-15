extends Node2D
## Сундук на базе разбойников. Открывается ударом рядом — даёт случайный лут.

var opened := false


func _ready() -> void:
	add_to_group("chests")
	z_index = 6
	_build()


func open() -> void:
	if opened:
		return
	opened = true
	_loot()
	_build()


func _loot() -> void:
	Inv.add("wood", randi_range(5, 15))
	Inv.add("stone", randi_range(2, 8))
	if randf() < 0.5:
		Inv.add("meat", randi_range(2, 5))
	if randf() < 0.4:
		var tools := ["axe", "sword", "bow", "crossbow", "rod", "pickaxe"]
		Inv.give_tool(tools[randi() % tools.size()])


func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.free()
	var box := Polygon2D.new()
	box.polygon = PackedVector2Array([Vector2(-12, -10), Vector2(12, -10), Vector2(12, 12), Vector2(-12, 12)])
	box.color = Color(0.5, 0.34, 0.18) if not opened else Color(0.30, 0.22, 0.12)
	add_child(box)
	var lid := Polygon2D.new()
	lid.polygon = PackedVector2Array([Vector2(-12, -10), Vector2(12, -10), Vector2(12, -4), Vector2(-12, -4)])
	lid.color = Color(0.40, 0.26, 0.13) if not opened else Color(0.25, 0.18, 0.10)
	add_child(lid)
	if not opened:
		var lock := Polygon2D.new()
		lock.polygon = PackedVector2Array([Vector2(-3, -7), Vector2(3, -7), Vector2(3, -2), Vector2(-3, -2)])
		lock.color = Color(1, 0.85, 0.2)
		add_child(lock)
