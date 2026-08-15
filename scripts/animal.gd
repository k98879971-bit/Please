extends Node2D
## Животное: блуждает по суше, отскакивает от воды. Имеет HP, получает урон от удара игрока.

enum Kind { CHICKEN, SHEEP, COW }

const SPEEDS := {
	Kind.CHICKEN: 48.0,
	Kind.SHEEP: 32.0,
	Kind.COW: 24.0,
}

const HP := {
	Kind.CHICKEN: 1,
	Kind.SHEEP: 2,
	Kind.COW: 3,
}

@export var kind: int = Kind.SHEEP

var hp := 1
var _dir := Vector2.ZERO
var _timer := 0.0
var _world: TileMapLayer


func _ready() -> void:
	add_to_group("animals")
	hp = HP[kind]
	_world = get_tree().get_first_node_in_group("world")
	_build_visual()
	_pick_wander()


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_pick_wander()
	if _dir != Vector2.ZERO and _world:
		var next: Vector2 = global_position + _dir * float(SPEEDS[kind]) * delta
		if _world.is_water_at(next):
			_dir = -_dir
		else:
			global_position = next


func _pick_wander() -> void:
	if randf() < 0.3:
		_dir = Vector2.ZERO
	else:
		var a := randf() * TAU
		_dir = Vector2(cos(a), sin(a))
	_timer = randf_range(1.2, 3.5)


func take_hit(from_pos: Vector2) -> void:
	hp -= 1
	if hp <= 0:
		queue_free()
		return
	# отбрасывание от игрока
	var push := global_position - from_pos
	if push.length() > 0.1:
		global_position += push.normalized() * 14.0
		_dir = push.normalized()
	_timer = 0.4


func _build_visual() -> void:
	match kind:
		Kind.CHICKEN:
			_build_chicken()
		Kind.SHEEP:
			_build_sheep()
		Kind.COW:
			_build_cow()


func _add_circle(r: float, color: Color, pos := Vector2.ZERO, n := 18) -> void:
	var p := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(n):
		var a := i * TAU / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r + pos)
	p.polygon = pts
	p.color = color
	add_child(p)


func _build_chicken() -> void:
	_add_circle(6.0, Color(1.0, 0.96, 0.85), Vector2(0, -3))
	_add_circle(4.0, Color(1.0, 0.9, 0.7), Vector2(0, -9))
	_add_circle(1.6, Color(0.9, 0.2, 0.2), Vector2(2, -10))
	var beak := Polygon2D.new()
	beak.polygon = PackedVector2Array([Vector2(3, -10), Vector2(7, -9), Vector2(3, -8)])
	beak.color = Color(1.0, 0.7, 0.1)
	add_child(beak)


func _build_sheep() -> void:
	_add_circle(11.0, Color(0.93, 0.93, 0.9), Vector2(0, -4))
	_add_circle(5.0, Color(0.32, 0.28, 0.26), Vector2(8, -6))
	_add_circle(2.0, Color(0.32, 0.28, 0.26), Vector2(-7, 2))
	_add_circle(2.0, Color(0.32, 0.28, 0.26), Vector2(7, 2))


func _build_cow() -> void:
	_add_circle(14.0, Color(0.97, 0.97, 0.95), Vector2(0, -5))
	_add_circle(5.0, Color(0.12, 0.12, 0.12), Vector2(-7, -9))
	_add_circle(4.0, Color(0.12, 0.12, 0.12), Vector2(6, -3))
	_add_circle(5.0, Color(0.85, 0.7, 0.5), Vector2(12, -7))
	_add_circle(2.0, Color(0.12, 0.12, 0.12), Vector2(-8, 3))
	_add_circle(2.0, Color(0.12, 0.12, 0.12), Vector2(8, 3))
