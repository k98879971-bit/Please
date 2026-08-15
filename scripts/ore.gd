extends Node2D
## Каменная руда: добывается киркой, роняет камень.

const MAX_HP := 4
const PickupScn := preload("res://scripts/pickup.gd")

var hp := MAX_HP


func _ready() -> void:
	add_to_group("ore")
	var rock := Polygon2D.new()
	rock.polygon = _circle(13.0, 16)
	rock.color = Color(0.50, 0.50, 0.53)
	add_child(rock)
	var s1 := Polygon2D.new()
	s1.polygon = _circle(4.0, 10)
	s1.color = Color(0.30, 0.25, 0.20)
	s1.position = Vector2(-4, -4)
	add_child(s1)
	var s2 := Polygon2D.new()
	s2.polygon = _circle(3.0, 10)
	s2.color = Color(0.35, 0.30, 0.25)
	s2.position = Vector2(5, 3)
	add_child(s2)


func take_hit(_damage: int) -> void:
	hp -= 1
	_spawn_pickup("stone")
	if hp <= 0:
		queue_free()


func _spawn_pickup(item_id: String) -> void:
	var pk = PickupScn.new()
	pk.item_id = item_id
	pk.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-6, 10))
	var ent = get_parent()
	if ent:
		ent.add_child(pk)


func _circle(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := i * TAU / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
