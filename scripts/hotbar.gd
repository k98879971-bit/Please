extends Control
## Инвентарь-хотбар: ряд ячеек по центру внизу экрана. Тап по инструменту — экипировка.

const SLOTS := [
	{"id": "wood", "tool": false, "color": Color(0.50, 0.34, 0.18)},
	{"id": "meat", "tool": false, "color": Color(0.85, 0.25, 0.25)},
	{"id": "fish", "tool": false, "color": Color(0.30, 0.60, 0.90)},
	{"id": "axe", "tool": true, "color": Color(0.50, 0.50, 0.52)},
	{"id": "sword", "tool": true, "color": Color(0.82, 0.82, 0.88)},
	{"id": "bow", "tool": true, "color": Color(0.32, 0.60, 0.32)},
	{"id": "crossbow", "tool": true, "color": Color(0.30, 0.30, 0.35)},
	{"id": "rod", "tool": true, "color": Color(0.72, 0.60, 0.40)},
]

var _player
var _buttons: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sz := 60.0
	var gap := 6.0
	var n := SLOTS.size()
	var total := n * sz + (n - 1) * gap
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = -total * 0.5
	offset_right = total * 0.5
	offset_bottom = -14.0
	offset_top = -14.0 - sz
	_player = get_tree().get_first_node_in_group("player")

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", int(gap))
	add_child(hbox)
	for s in SLOTS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(sz, sz)
		b.text = "0"
		b.pressed.connect(_on_slot.bind(s.id, s.tool))
		_buttons.append(b)
		hbox.add_child(b)
	Inv.changed.connect(_refresh)
	_refresh()


func _on_slot(id: String, is_tool: bool) -> void:
	if is_tool and _player and Inv.count(id) > 0:
		_player.equipped = id
		_refresh()


func _refresh() -> void:
	for i in range(SLOTS.size()):
		var s: Dictionary = SLOTS[i]
		var c := Inv.count(s.id)
		var equipped: bool = (_player != null) and _player.equipped == s.id
		var owned: bool = (not s.tool) or c > 0
		_buttons[i].text = str(c)
		_buttons[i].disabled = bool(s.tool) and c <= 0
		_apply_style(_buttons[i], s.color, equipped, owned)


func _apply_style(b: Button, color: Color, equipped: bool, owned: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color if owned else color.darkened(0.6)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_right = 8
	sb.corner_radius_bottom_left = 8
	if equipped:
		sb.border_color = Color(1, 0.9, 0.2)
		sb.border_width_left = 4
		sb.border_width_right = 4
		sb.border_width_top = 4
		sb.border_width_bottom = 4
	else:
		sb.border_color = Color(0, 0, 0, 0.5)
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_stylebox_override("hover", sb)
	b.add_theme_stylebox_override("pressed", sb)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_font_size_override("font_size", 20)
