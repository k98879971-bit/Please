extends CharacterBody2D
## Игрок. Яркий персонаж со стрелкой-направлением. HP = 100.
## Движение: джойстик (Controls.move_vector) + WASD/стрелки. Бег: кнопка. Удар: кнопка.

@export var speed: float = 260.0
@export var sprint_mult: float = 1.6

const MAX_HP := 100
const ATTACK_RANGE := 80.0

var hp := MAX_HP
var hp_max := MAX_HP
var _facing: Node2D


func _ready() -> void:
	add_to_group("player")
	z_index = 10  # всегда поверх деревьев и животных
	var cam := get_node_or_null("Camera2D")
	if cam is Camera2D:
		cam.make_current()
	_build_visual()


func _physics_process(_delta: float) -> void:
	var dir := _keyboard_vector()
	dir += Controls.move_vector
	dir = dir.limit_length(1.0)
	var mult := sprint_mult if Controls.sprint else 1.0
	velocity = dir * speed * mult
	move_and_slide()
	if velocity.length() > 1.0 and _facing:
		_facing.rotation = velocity.angle()
	if Controls.attack_queued:
		Controls.attack_queued = false
		_attack()


func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, hp_max)


func _attack() -> void:
	_spawn_swing()
	for a in get_tree().get_nodes_in_group("animals"):
		if is_instance_valid(a) and global_position.distance_to(a.global_position) < ATTACK_RANGE:
			a.take_hit(global_position)


func _spawn_swing() -> void:
	if not _facing:
		return
	var swing := Polygon2D.new()
	swing.polygon = PackedVector2Array([
		Vector2(18, -34), Vector2(72, -10), Vector2(72, 10), Vector2(18, 34)])
	swing.color = Color(1, 1, 1, 0.7)
	_facing.add_child(swing)
	var t := get_tree().create_timer(0.16)
	t.timeout.connect(swing.queue_free)


func _build_visual() -> void:
	_add_circle(13.0, Color(0, 0, 0, 0.25), Vector2(0, 10))  # тень
	_add_circle(20.0, Color(0.10, 0.07, 0.04))               # контур
	_add_circle(16.0, Color(1.0, 0.52, 0.06))                # тело
	# стрелка-направление
	_facing = Node2D.new()
	add_child(_facing)
	var tri := Polygon2D.new()
	tri.polygon = PackedVector2Array([Vector2(23, 0), Vector2(12, -7), Vector2(12, 7)])
	tri.color = Color(1.0, 0.95, 0.2)
	_facing.add_child(tri)


func _add_circle(r: float, color: Color, pos := Vector2.ZERO, n := 22) -> void:
	var p := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(n):
		var a := i * TAU / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r + pos)
	p.polygon = pts
	p.color = color
	add_child(p)


func _keyboard_vector() -> Vector2:
	var v := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		v.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		v.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		v.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		v.y += 1.0
	return v
