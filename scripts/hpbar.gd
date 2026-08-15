extends Control
## Полоса здоровья под миникартой.

const W := 170.0
const H := 26.0

var _player
var _label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# под миникартой (верх-лево)
	offset_left = 12.0
	offset_top = 12.0 + 170.0 + 8.0
	offset_right = 12.0 + W
	offset_bottom = offset_top + H
	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)
	_player = get_tree().get_first_node_in_group("player")
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()
	if _player:
		_label.text = "HP %d/%d" % [_player.hp, _player.hp_max]


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(0.05, 0.05, 0.05, 0.8), true)
	var ratio := 1.0
	if _player:
		ratio = clampf(float(_player.hp) / float(_player.hp_max), 0.0, 1.0)
	var col := Color(0.2, 0.8, 0.25) if ratio > 0.3 else Color(0.9, 0.2, 0.2)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * ratio, size.y)), col, true)
	draw_rect(r, Color(1, 1, 1, 0.8), false, 2.0)
