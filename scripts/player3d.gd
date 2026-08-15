extends CharacterBody3D
## Игрок от первого лица. Видна рука/кулак, покачивание при ходьбе, анимация удара при атаке.

const GRAV := 22.0
const SPEED := 6.0
const JUMP := 7.5
const MAX_HP := 100

var hp := MAX_HP
var hp_max := MAX_HP
var spawn_pos := Vector3.ZERO

var _yaw := 0.0
var _pitch := 0.0
var _cam: Camera3D
var _ray: RayCast3D
var _vm: Node3D
var _vm_base := Vector3(0.35, -0.4, -0.6)
var _punch := 0.0
var _bob := 0.0


func _ready() -> void:
	add_to_group("player")
	_cam = $Camera3D
	_ray = $Camera3D/RayCast3D
	_build_viewmodel()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var size := get_viewport().get_visible_rect().size
		if event.position.x > size.x * 0.5 and event.position.y < size.y * 0.7:
			_yaw -= event.relative.x * 0.004
			_pitch -= event.relative.y * 0.004
			_pitch = clampf(_pitch, -1.2, 1.2)


func _physics_process(delta: float) -> void:
	if hp <= 0:
		_respawn()
		return
	_cam.rotation = Vector3(_pitch, _yaw, 0)
	velocity.y -= GRAV * delta

	var basis := _cam.global_transform.basis
	var fwd := -basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var right := basis.x
	right.y = 0.0
	right = right.normalized()

	var mv := Vector3.ZERO
	mv += right * Controls.move_vector.x
	mv += fwd * -Controls.move_vector.y
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		mv += fwd
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		mv -= fwd
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		mv += right
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		mv -= right
	if mv.length() > 0.01:
		mv = mv.normalized()

	velocity.x = mv.x * SPEED
	velocity.z = mv.z * SPEED

	if (Controls.jump_queued or Input.is_physical_key_pressed(KEY_SPACE)) and is_on_floor():
		velocity.y = JUMP
	Controls.jump_queued = false

	move_and_slide()

	if Controls.attack_queued:
		Controls.attack_queued = false
		_use()

	_animate(delta)


func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, hp_max)


func _respawn() -> void:
	hp = MAX_HP
	global_position = spawn_pos
	velocity = Vector3.ZERO


func _use() -> void:
	_punch = 0.28
	_ray.force_raycast_update()
	if _ray.is_colliding():
		var col = _ray.get_collider()
		if col and col.has_method("gather"):
			col.gather()
		elif col and col.has_method("hit"):
			col.hit(1)


func _animate(delta: float) -> void:
	# покачивание при ходьбе (head-bob + рука)
	var hspeed := Vector2(velocity.x, velocity.z).length()
	var move_amt: float = clampf(hspeed / SPEED, 0.0, 1.0)
	if hspeed > 0.3:
		_bob += delta * 11.0
	var bob_y: float = sin(_bob) * 0.035 * move_amt
	var bob_x: float = sin(_bob * 0.5) * 0.02 * move_amt
	_cam.position = Vector3(bob_x, 1.6 + bob_y, 0.0)

	# анимация удара кулаком
	if _punch > 0.0:
		_punch -= delta
		var prog: float = 1.0 - clampf(_punch / 0.28, 0.0, 1.0)
		var thrust: float = sin(prog * PI) * 0.35
		_vm.position = Vector3(_vm_base.x, _vm_base.y + bob_y * 0.6, _vm_base.z - thrust)
		_vm.rotation.x = -thrust * 0.8
	else:
		_vm.position = Vector3(_vm_base.x, _vm_base.y + bob_y * 0.6, _vm_base.z)
		_vm.rotation.x = 0.0


func _build_viewmodel() -> void:
	_vm = Node3D.new()
	_vm.position = _vm_base
	_cam.add_child(_vm)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.92, 0.72, 0.55)
	var arm := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.07
	cm.bottom_radius = 0.09
	cm.height = 0.45
	cm.material = mat
	arm.mesh = cm
	arm.position = Vector3(0, -0.18, 0.18)
	arm.rotation.x = -1.0
	_vm.add_child(arm)
	var fist := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.15, 0.15, 0.17)
	bm.material = mat
	fist.mesh = bm
	fist.position = Vector3(0, -0.4, 0.36)
	_vm.add_child(fist)
