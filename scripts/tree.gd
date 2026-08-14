extends Node2D
## Дерево-заглушка: ствол + крона. Спавнится скриптом мира. Начало координат — у основания.

@export var scale_rand: float = 1.0


func _ready() -> void:
	var s := scale_rand
	var trunk := Polygon2D.new()
	trunk.polygon = PackedVector2Array([
		Vector2(-3, -14), Vector2(3, -14), Vector2(3, 0), Vector2(-3, 0)])
	trunk.color = Color(0.34, 0.22, 0.12)
	add_child(trunk)

	var canopy := Polygon2D.new()
	canopy.polygon = _circle(15.0 * s, 16)
	canopy.color = Color(0.16, 0.40, 0.16)
	canopy.position = Vector2(0, -22)
	add_child(canopy)

	var canopy2 := Polygon2D.new()
	canopy2.polygon = _circle(10.0 * s, 14)
	canopy2.color = Color(0.26, 0.55, 0.24)
	canopy2.position = Vector2(-3, -26)
	add_child(canopy2)


func _circle(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := i * TAU / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
