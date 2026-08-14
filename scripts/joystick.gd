extends Control
## Видимый виртуальный джойстик. Управление: касание внутри круга + перетаскивание.

const RADIUS := 64.0
const KNOB := 26.0

var _knob := Vector2.ZERO
var _touch := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch == -1:
			_touch = event.index
			_update(event.position)
		elif not event.pressed and event.index == _touch:
			_release()
	elif event is InputEventScreenDrag and event.index == _touch:
		_update(event.position)


func _update(local_pos: Vector2) -> void:
	var d := local_pos - size * 0.5
	d = d.limit_length(RADIUS)
	_knob = d
	Controls.move_vector = d / RADIUS
	queue_redraw()


func _release() -> void:
	_touch = -1
	_knob = Vector2.ZERO
	Controls.move_vector = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	draw_circle(c, RADIUS, Color(0.05, 0.08, 0.05, 0.45))
	draw_arc(c, RADIUS, 0.0, TAU, 48, Color(1, 1, 1, 0.55), 2.5)
	draw_circle(c + _knob, KNOB, Color(0.9, 0.9, 0.95, 0.85))
	draw_arc(c + _knob, KNOB, 0.0, TAU, 32, Color(0.1, 0.1, 0.1, 0.5), 2.0)
