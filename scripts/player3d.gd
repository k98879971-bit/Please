extends CharacterBody3D
## Игрок от первого лица: ходьба, прыжок, обзор, добыча/охота. HP, респавн при смерти.

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


func _ready() -> void:
	add_to_group("player")
	_cam = $Camera3D
	_ray = $Camera3D/RayCast3D


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


func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, hp_max)


func _respawn() -> void:
	hp = MAX_HP
	global_position = spawn_pos
	velocity = Vector3.ZERO


func _use() -> void:
	_ray.force_raycast_update()
	if _ray.is_colliding():
		var col = _ray.get_collider()
		if col and col.has_method("gather"):
			col.gather()
		elif col and col.has_method("hit"):
			col.hit(1)
