extends CharacterBody3D
## Животное в 3D. Бродит; мирные (курица/олень) убегают, хищники (кабан/медведь) нападают.

const GRAV := 22.0

enum Kind { CHICKEN, DEER, BOAR, BEAR }

const STATS := {
	Kind.CHICKEN: {"hp": 2, "speed": 3.0, "aggr": false, "dmg": 0, "meat": 1, "size": 0.4, "color": Color(0.95, 0.95, 0.90)},
	Kind.DEER: {"hp": 3, "speed": 5.0, "aggr": false, "dmg": 0, "meat": 2, "size": 1.1, "color": Color(0.60, 0.45, 0.30)},
	Kind.BOAR: {"hp": 4, "speed": 4.0, "aggr": true, "dmg": 8, "meat": 2, "size": 0.8, "color": Color(0.30, 0.25, 0.20)},
	Kind.BEAR: {"hp": 7, "speed": 4.5, "aggr": true, "dmg": 14, "meat": 3, "size": 1.3, "color": Color(0.25, 0.20, 0.18)},
}

@export var kind: int = Kind.CHICKEN

var hp := 2
var _dir := Vector3.ZERO
var _timer := 0.0
var _atk := 0.0
var _player


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


func _build(s: Dictionary) -> void:
	var sz: float = float(s["size"])
	var mat := StandardMaterial3D.new()
	mat.albedo_color = s["color"]
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(sz * 1.4, sz, sz * 0.8)
	bm.material = mat
	body.mesh = bm
	body.position = Vector3(0, sz * 0.5, 0)
	add_child(body)
	var head := MeshInstance3D.new()
	var hm := BoxMesh.new()
	hm.size = Vector3(sz * 0.5, sz * 0.5, sz * 0.5)
	hm.material = mat
	head.mesh = hm
	head.position = Vector3(0, sz * 0.85, sz * 0.7)
	add_child(head)
	var c := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(sz * 1.4, sz, sz * 1.5)
	c.shape = bs
	c.position = Vector3(0, sz * 0.5, 0)
	add_child(c)
