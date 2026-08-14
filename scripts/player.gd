extends CharacterBody2D
## Управление игроком.
## Мобильный: плавающий виртуальный джойстик — коснись экрана и тяни палец в сторону.
## Десктоп: WASD / стрелки.

@export var speed: float = 260.0

const _JOY_DEAD := 8.0   # мёртвая зона джойстика, px
const _JOY_MAX := 90.0   # полный ход джойстика, px

var _touch_id := -1
var _touch_origin := Vector2.ZERO
var _touch_pos := Vector2.ZERO


func _ready() -> void:
	_touch_origin = Vector2.ZERO
	_touch_pos = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_id == -1:
			_touch_id = event.index
			_touch_origin = event.position
			_touch_pos = event.position
		elif not event.pressed and event.index == _touch_id:
			_touch_id = -1
	elif event is InputEventScreenDrag and event.index == _touch_id:
		_touch_pos = event.position


func _physics_process(_delta: float) -> void:
	var dir := _keyboard_vector()
	if _touch_id != -1:
		var d := _touch_pos - _touch_origin
		if d.length() > _JOY_DEAD:
			dir += d.limit_length(_JOY_MAX) / _JOY_MAX
	dir = dir.limit_length(1.0)
	velocity = dir * speed
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
