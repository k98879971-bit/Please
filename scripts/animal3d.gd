extends CharacterBody3D
## Животное 3D: узнаваемая модель + текстура + АНИМАЦИЯ НОГ при ходьбе. Мирные убегают, хищники нападают.

const GRAV := 22.0

enum Kind { CHICKEN, DEER, BOAR, BEAR }

const STATS := {
	Kind.CHICKEN: {"hp": 2, "speed": 3.0, "aggr": false, "dmg": 0, "meat": 1, "size": 0.4},
	Kind.DEER: {"hp": 3, "speed": 5.0, "aggr": false, "dmg": 0, "meat": 2, "size": 1.1},
	Kind.BOAR: {"hp": 4, "speed": 4.0, "aggr": true, "dmg": 8, "meat": 2, "size": 0.8},
	Kind.BEAR: {"hp": 7, "speed": 4.5, "aggr": true, "dmg": 14, "meat": 3, "size": 1.3},
}

@export var kind: int = Kind.CHICKEN
var body_mat: Material

var hp := 2
var _dir := Vector3.ZERO
var _timer := 0.0
var _atk := 0.0
var _player
var _walk_phase := 0.0
var _legs_arr: Array = []


func _ready() -> void:
	add_to_group("animals")
	var s: Dictionary = STATS[kind]
	hp = int(s["hp"])
	_player = get_tree().get_first_node_in_group("player")
	_build(s)


func _physics_process(delta: float) -> void:
	velocity.y -= GRAV * delta
	if _atk > 0.0:
		_atk -= delta
	_timer -= delta
	var s: Dictionary = STATS[kind]
	var spd: float = float(s["speed"])
	if is_instance_valid(_player):
		var d: float = global_position.distance_to(_player.global_position)
		var aggr: bool = bool(s["aggr"])
		if aggr and d < 11.0:
			_dir = (_player.global_position - global_position)
			_dir.y = 0.0
			_dir = _dir.normalized()
			spd *= 1.4
			if d < 1.6 and _atk <= 0.0:
				_player.take_damage(int(s["dmg"]))
				_atk = 1.0
		elif not aggr and d < 7.0:
			_dir = (global_position - _player.global_position)
			_dir.y = 0.0
			_dir = _dir.normalized()
			spd *= 1.3
		elif _timer <= 0.0:
			_pick_wander()
	elif _timer <= 0.0:
		_pick_wander()
	velocity.x = _dir.x * spd
	velocity.z = _dir.z * spd
	if _dir.length() > 0.1:
		rotation.y = atan2(_dir.x, _dir.z)
	move_and_slide()
	_animate_legs(delta, spd)


func _animate_legs(delta: float, base_spd: float) -> void:
	var hspeed := Vector2(velocity.x, velocity.z).length()
	var amt: float = clampf(hspeed / maxf(base_spd, 0.1), 0.0, 1.0)
	_walk_phase += delta * 9.0 * amt
	for entry in _legs_arr:
		var pivot: Node3D = entry[0]
		var off: float = float(entry[1])
		var target: float = sin(_walk_phase + off) * 0.6 * amt
		pivot.rotation.x = lerp_angle(pivot.rotation.x, target, 0.4)


func _pick_wander() -> void:
	if randf() < 0.3:
		_dir = Vector3.ZERO
	else:
		var a := randf() * TAU
		_dir = Vector3(sin(a), 0.0, cos(a))
	_timer = randf_range(1.5, 4.0)


func hit(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		Inv.add("meat", int(STATS[kind]["meat"]))
		queue_free()
	elif is_instance_valid(_player):
		_dir = (global_position - _player.global_position)
		_dir.y = 0.0
		_dir = _dir.normalized()


# --- Модели ---

func _build(s: Dictionary) -> void:
	var sz: float = float(s["size"])
	match kind:
		Kind.CHICKEN:
			_build_chicken(sz)
		Kind.DEER:
			_build_deer(sz)
		Kind.BOAR:
			_build_boar(sz)
		Kind.BEAR:
			_build_bear(sz)
	var col := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(sz * 1.4, sz * 1.7, sz * 1.9)
	col.shape = bs
	col.position = Vector3(0, sz * 0.85, 0)
	add_child(col)


func _leg_pivot(mat: Material, hip: Vector3, h: float, r: float, off: float) -> void:
	var pivot := Node3D.new()
	pivot.position = hip
	add_child(pivot)
	var m := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.material = mat
	m.mesh = c
	m.position = Vector3(0, -h * 0.5, 0)
	pivot.add_child(m)
	_legs_arr.append([pivot, off])


func _legs(mat: Material, hw: float, hl: float, h: float, r: float) -> void:
	for sx in [-1.0, 1.0]:
		for sl in [-1.0, 1.0]:
			var off := 0.0 if (sx * sl < 0.0) else PI
			_leg_pivot(mat, Vector3(sx * hw, h, sl * hl), h, r, off)


func _build_chicken(sz: float) -> void:
	var yellow := _flat(Color(1.0, 0.8, 0.2))
	var red := _flat(Color(0.9, 0.2, 0.2))
	var lh := sz * 0.45
	_box(Vector3(sz * 1.1, sz * 0.9, sz * 1.3), body_mat, Vector3(0, lh + sz * 0.45, 0))
	_box(Vector3(sz * 0.45, sz * 0.45, sz * 0.45), body_mat, Vector3(0, lh + sz * 1.0, sz * 0.45))
	_box(Vector3(sz * 0.16, sz * 0.22, sz * 0.3), red, Vector3(0, lh + sz * 1.28, sz * 0.42))
	_box(Vector3(sz * 0.12, sz * 0.1, sz * 0.25), yellow, Vector3(0, lh + sz * 0.95, sz * 0.72))
	_leg_pivot(yellow, Vector3(-sz * 0.2, lh, -sz * 0.2), lh, sz * 0.05, 0.0)
	_leg_pivot(yellow, Vector3(sz * 0.2, lh, -sz * 0.2), lh, sz * 0.05, PI)


func _build_deer(sz: float) -> void:
	var tan := _flat(Color(0.72, 0.56, 0.36))
	var lh := sz * 0.85
	_box(Vector3(sz * 0.7, sz * 0.7, sz * 1.5), body_mat, Vector3(0, lh + sz * 0.35, 0))
	_legs(body_mat, sz * 0.25, sz * 0.55, lh, sz * 0.09)
	_box(Vector3(sz * 0.4, sz * 0.4, sz * 0.5), body_mat, Vector3(0, lh + sz * 0.75, sz * 0.85))
	_cyl(sz * 0.04, sz * 0.4, tan, Vector3(-sz * 0.15, lh + sz * 1.1, sz * 0.8))
	_cyl(sz * 0.04, sz * 0.4, tan, Vector3(sz * 0.15, lh + sz * 1.1, sz * 0.8))
	_box(Vector3(sz * 0.15, sz * 0.22, sz * 0.15), tan, Vector3(0, lh + sz * 0.5, -sz * 0.8))


func _build_boar(sz: float) -> void:
	var pink := _flat(Color(0.5, 0.35, 0.3))
	var ivory := _flat(Color(0.92, 0.9, 0.85))
	var lh := sz * 0.45
	_box(Vector3(sz * 1.0, sz * 0.75, sz * 1.6), body_mat, Vector3(0, lh + sz * 0.4, 0))
	_legs(body_mat, sz * 0.35, sz * 0.6, lh, sz * 0.1)
	_box(Vector3(sz * 0.45, sz * 0.45, sz * 0.6), body_mat, Vector3(0, lh + sz * 0.7, sz * 0.8))
	_box(Vector3(sz * 0.26, sz * 0.2, sz * 0.26), pink, Vector3(0, lh + sz * 0.6, sz * 1.12))
	_cyl(sz * 0.03, sz * 0.18, ivory, Vector3(-sz * 0.12, lh + sz * 0.55, sz * 1.02))
	_cyl(sz * 0.03, sz * 0.18, ivory, Vector3(sz * 0.12, lh + sz * 0.55, sz * 1.02))


func _build_bear(sz: float) -> void:
	var dark := _flat(Color(0.16, 0.11, 0.08))
	var lh := sz * 0.55
	_box(Vector3(sz * 0.95, sz * 0.9, sz * 1.45), body_mat, Vector3(0, lh + sz * 0.45, 0))
	_legs(body_mat, sz * 0.32, sz * 0.55, lh, sz * 0.13)
	_box(Vector3(sz * 0.5, sz * 0.5, sz * 0.5), body_mat, Vector3(0, lh + sz * 0.85, sz * 0.75))
	_box(Vector3(sz * 0.18, sz * 0.18, sz * 0.1), dark, Vector3(-sz * 0.2, lh + sz * 1.18, sz * 0.7))
	_box(Vector3(sz * 0.18, sz * 0.18, sz * 0.1), dark, Vector3(sz * 0.2, lh + sz * 1.18, sz * 0.7))
	_box(Vector3(sz * 0.26, sz * 0.2, sz * 0.22), dark, Vector3(0, lh + sz * 0.78, sz * 1.05))


func _box(s: Vector3, mat: Material, pos: Vector3) -> void:
	var m := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = s
	b.material = mat
	m.mesh = b
	m.position = pos
	add_child(m)


func _cyl(r: float, h: float, mat: Material, pos: Vector3) -> void:
	var m := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.material = mat
	m.mesh = c
	m.position = pos
	add_child(m)


func _flat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	return m
