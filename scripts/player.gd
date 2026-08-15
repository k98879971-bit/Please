extends CharacterBody2D
## Игрок. HP=100, выносливость=50. Оружие с уроном. Рыбалка удочкой у воды.

@export var speed: float = 260.0
@export var sprint_mult: float = 1.6

const MAX_HP := 100
const STAMINA_MAX := 50.0
const ProjectileScn := preload("res://scripts/projectile.gd")

# Урон: меч 50, арбалет 55, лук 30, топор 25, кулаки 5. can_chop — может рубить деревья.
const WEAPONS := {
	"fist": {"damage": 5, "range": 80.0, "ranged": false, "can_chop": true},
	"axe": {"damage": 25, "range": 95.0, "ranged": false, "can_chop": true},
	"sword": {"damage": 50, "range": 110.0, "ranged": false, "can_chop": false},
	"bow": {"damage": 30, "range": 0.0, "ranged": true, "can_chop": false},
	"crossbow": {"damage": 55, "range": 0.0, "ranged": true, "can_chop": false},
}

var hp := MAX_HP
var hp_max := MAX_HP
var stamina := STAMINA_MAX
var equipped := "fist"
var _fish_cd := 0.0
var _facing: Node2D


func _ready() -> void:
	add_to_group("player")
	z_index = 10
	var cam := get_node_or_null("Camera2D")
	if cam is Camera2D:
		cam.make_current()
	_build_visual()


func _physics_process(delta: float) -> void:
	if _fish_cd > 0.0:
		_fish_cd -= delta
	var inp := _keyboard_vector()
	inp += Controls.move_vector
	inp = inp.limit_length(1.0)
	var moving := inp.length() > 0.05
	var can_sprint := Controls.sprint and moving and stamina > 0.0
	if can_sprint:
		stamina = max(0.0, stamina - 20.0 * delta)
	else:
		stamina = min(STAMINA_MAX, stamina + 15.0 * delta)
	var mult := sprint_mult if can_sprint else 1.0
	velocity = inp * speed * mult
	move_and_slide()
	if velocity.length() > 1.0 and _facing:
		_facing.rotation = velocity.angle()
	if Controls.attack_queued:
		Controls.attack_queued = false
		_attack()
	if Controls.fish_queued:
		Controls.fish_queued = false
		_try_fish()


func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, hp_max)


func _attack() -> void:
	var w: Dictionary = WEAPONS.get(equipped, WEAPONS["fist"])
	if w.ranged:
		_spawn_projectile(int(w.damage))
	else:
		_spawn_swing()
		_melee(int(w.damage), float(w.range), bool(w.can_chop))


func _melee(damage: int, rng: float, can_chop: bool) -> void:
	for a in get_tree().get_nodes_in_group("animals"):
		if is_instance_valid(a) and global_position.distance_to(a.global_position) < rng:
			a.take_hit(damage, global_position)
	if can_chop:
		for t in get_tree().get_nodes_in_group("trees"):
			if is_instance_valid(t) and global_position.distance_to(t.global_position) < rng:
				t.take_hit(damage)


func _try_fish() -> void:
	if _fish_cd > 0.0 or not Inv.has("rod"):
		return
	var world = get_tree().get_first_node_in_group("world")
	if not world:
		return
	var found := false
	for r in [44.0, 72.0, 100.0]:
		for i in range(10):
			var a := i * TAU / 10.0
			var p: Vector2 = global_position + Vector2(cos(a), sin(a)) * float(r)
			if world.is_water_at(p):
				found = true
				break
		if found:
			break
	if not found:
		return
	Inv.add("fish")
	_fish_cd = 1.2


func _spawn_projectile(damage: int) -> void:
	if not _facing:
		return
	var p = ProjectileScn.new()
	p.global_position = global_position
	var a := _facing.rotation
	p.dir = Vector2(cos(a), sin(a))
	p.damage = damage
	var ent = get_parent()
	if ent:
		ent.add_child(p)


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
	_add_circle(13.0, Color(0, 0, 0, 0.25), Vector2(0, 10))
	_add_circle(20.0, Color(0.10, 0.07, 0.04))
	_add_circle(16.0, Color(1.0, 0.52, 0.06))
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
