extends CharacterBody2D
## Игрок. Движение: видимый джойстик (Controls.move_vector) + WASD/стрелки.
## Бег: удержание кнопки (Controls.sprint).

@export var speed: float = 260.0
@export var sprint_mult: float = 1.6


func _ready() -> void:
	add_to_group("player")


func _physics_process(_delta: float) -> void:
	var dir := _keyboard_vector()
	dir += Controls.move_vector
	dir = dir.limit_length(1.0)
	var mult := sprint_mult if Controls.sprint else 1.0
	velocity = dir * speed * mult
	move_and_slide()


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
