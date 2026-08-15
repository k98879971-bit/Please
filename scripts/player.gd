extends CharacterBody2D
## Игрок (вид сбоку): гравитация, ходьба, прыжок. Копает тайлы и рубит деревья.

const GRAVITY := 1500.0
const MOVE_SPEED := 190.0
const JUMP_SPEED := 480.0

var hp := 100
var hp_max := 100
var equipped := "fist"
var spawn_pos := Vector2.ZERO
var _facing := 1
var _facing_node: Node2D


func _ready() -> void:
	add_to_group("player")
	z_index = 10
	var cam := get_node_or_null("Camera2D")
	if cam is Camera2D:
		cam.make_current()
	_build_visual()


func _physics_process(delta: float) -> void:
	if hp <= 0:
		_respawn()
		return
	velocity.y += GRAVITY * delta
	var ix := Controls.move_vector.x
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		ix -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		ix += 1.0
	ix = clampf(ix, -1.0, 1.0)
	velocity.x = ix * MOVE_SPEED
	if ix > 0.1:
		_facing = 1
	elif ix < -0.1:
		_facing = -1

	var want_jump := Controls.jump_queued or Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_UP)
	if want_jump and is_on_floor():
		velocity.y = -JUMP_SPEED
	Controls.jump_queued = false

	move_and_slide()
	if _facing_node:
		_facing_node.scale.x = float(_facing)

	if Controls.attack_queued:
		Controls.attack_queued = false
		_attack()


func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, hp_max)


func _respawn() -> void:
	hp = hp_max
	global_position = spawn_pos
	velocity = Vector2.ZERO


func _attack() -> void:
	var world = get_tree().get_first_node_in_group("world")
	if world:
		for off in [Vector2(_facing * 14, -2), Vector2(_facing * 8, 12)]:
			var c = world.local_to_map(global_position + off)
			if world.is_solid_cell(c):
				var res = world.mine_cell(c)
				if res != "":
					Inv.add(res)
				GS.mined_cells.append(c)
	# рубим дерево перед собой
	for t in get_tree().get_nodes_in_group("trees"):
		if is_instance_valid(t) and abs(t.global_position.x - global_position.x) < 22 and abs(t.global_position.y - global_position.y) < 36:
			t.take_hit(1)
			break


func _build_visual() -> void:
	_add_circle(13.0, Color(0.10, 0.07, 0.04))
	_add_circle(11.0, Color(1.0, 0.52, 0.06))
	_facing_node = Node2D.new()
	add_child(_facing_node)
	var tri := Polygon2D.new()
	tri.polygon = PackedVector2Array([Vector2(15, 0), Vector2(7, -5), Vector2(7, 5)])
	tri.color = Color(1.0, 0.95, 0.2)
	_facing_node.add_child(tri)


func _add_circle(r: float, color: Color, n := 22) -> void:
	var p := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(n):
		var a := i * TAU / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r)
	p.polygon = pts
	p.color = color
	add_child(p)
