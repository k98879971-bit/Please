extends Node2D
## Рыба: плавает в воде, отскакивает от суши. Показывает, где можно рыбачить.

var _dir := Vector2.ZERO
var _timer := 0.0
var _world


func _ready() -> void:
	add_to_group("fish")
	_world = get_tree().get_first_node_in_group("world")
	_build()
	_pick()


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_pick()
	if _dir != Vector2.ZERO and _world:
		var next := global_position + _dir * 42.0 * delta
		if not _world.is_water_at(next):
			_dir = -_dir
		else:
			global_position = next
			rotation = _dir.angle()


func _pick() -> void:
	if randf() < 0.4:
		_dir = Vector2.ZERO
	else:
		var a := randf() * TAU
		_dir = Vector2(cos(a), sin(a))
	_timer = randf_range(1.0, 3.0)


func _build() -> void:
	var body := Polygon2D.new()
	body.polygon = _ellipse(7.0, 4.0)
	body.color = Color(0.3, 0.6, 0.9)
	add_child(body)
	var tail := Polygon2D.new()
	tail.polygon = PackedVector2Array([Vector2(-7, 0), Vector2(-13, -5), Vector2(-13, 5)])
	tail.color = Color(0.25, 0.5, 0.8)
	add_child(tail)


func _ellipse(rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(16):
		var a := i * TAU / 16.0
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	return pts
