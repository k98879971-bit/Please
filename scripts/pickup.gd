extends Node2D
## Подбираемый предмет. Собирается игроком при приближении.

@export var item_id: String = "wood"


func _ready() -> void:
	add_to_group("pickups")
	_build_visual()


func _physics_process(_delta: float) -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p and global_position.distance_to(p.global_position) < 28.0:
		Inv.add(item_id)
		queue_free()


func _build_visual() -> void:
	match item_id:
		"meat":
			_circle(Color(0.85, 0.25, 0.25), 7.0)
		"wood":
			_circle(Color(0.5, 0.34, 0.18), 6.0)
		_:
			_circle(Color(0.9, 0.9, 0.2), 6.0)


func _circle(color: Color, r: float) -> void:
	var p := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var a := i * TAU / 16.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	p.polygon = pts
	p.color = color
	add_child(p)
