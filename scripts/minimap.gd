extends Control
## Миникарта: карта биомов + точка игрока + точки животных.

const SIZE := 170.0

var _tex: Texture2D
var _player
var _world_size := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# верхний левый угол
	offset_left = 12.0
	offset_top = 12.0
	offset_right = 12.0 + SIZE
	offset_bottom = 12.0 + SIZE
	var world = get_tree().get_first_node_in_group("world")
	if world:
		_tex = world.make_minimap_texture()
		_world_size = world.world_pixel_size()
	_player = get_tree().get_first_node_in_group("player")
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, Vector2(SIZE, SIZE))
	draw_rect(r, Color(0.04, 0.06, 0.04, 0.6), true)
	if _tex:
		draw_texture_rect(_tex, r, false)
	if _world_size != Vector2.ZERO:
		if _player:
			var p: Vector2 = _player.global_position / _world_size * SIZE
			draw_circle(p, 3.5, Color(1.0, 0.25, 0.2))
		for a in get_tree().get_nodes_in_group("animals"):
			var ap: Vector2 = a.global_position / _world_size * SIZE
			draw_circle(ap, 2.0, Color(1.0, 0.92, 0.25))
	draw_rect(r, Color(1, 1, 1, 0.7), false, 2.0)
