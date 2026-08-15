extends Control
## Инвентарь-хотбар по центру внизу: ресурсы + имеющиеся инструменты (с прочностью).
## Тап по инструменту — экипировать. Цвет инструмента краснеет по мере износа.

const RES := ["wood", "meat", "fish", "stone"]
const TOOL_ORDER := ["axe", "sword", "bow", "crossbow", "rod", "pickaxe", "stone_axe", "stone_sword", "stone_bow", "stone_crossbow", "stone_rod", "stone_pickaxe"]

const COLORS := {
	"wood": Color(0.50, 0.34, 0.18), "meat": Color(0.85, 0.25, 0.25),
	"fish": Color(0.30, 0.60, 0.90), "stone": Color(0.55, 0.55, 0.58),
	"axe": Color(0.50, 0.50, 0.52), "sword": Color(0.82, 0.82, 0.88),
	"bow": Color(0.32, 0.60, 0.32), "crossbow": Color(0.30, 0.30, 0.35),
	"rod": Color(0.72, 0.60, 0.40), "pickaxe": Color(0.55, 0.45, 0.35),
	"stone_axe": Color(0.45, 0.45, 0.48), "stone_sword": Color(0.60, 0.60, 0.65),
	"stone_bow": Color(0.40, 0.50, 0.40), "stone_crossbow": Color(0.35, 0.35, 0.40),
	"stone_rod": Color(0.60, 0.55, 0.45), "stone_pickaxe": Color(0.50, 0.45, 0.40),
}

var _player
var _hbox: HBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_right = 0.0
	offset_bottom = -14.0
	offset_top = -14.0 - 60.0
	_player = get_tree().get_first_node_in_group("player")
	_hbox = HBoxContainer.new()
	_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_hbox.add_theme_constant_override("separation", 6)
	add_child(_hbox)
	Inv.changed.connect(_rebuild)
	_rebuild()


func _rebuild() -> void:
	for c in _hbox.get_children():
		_hbox.remove_child(c)
		c.free()
	for id in RES:
		_add(id, false)
	for id in TOOL_ORDER:
		if Inv.count(id) > 0:
			_add(id, true)


func _add(id: String, is_tool: bool) -> void:
	var b := Button.new()
	b.custom_minimum_size = Vector2(54, 54)
	var num: int = Inv.durability_of(id) if is_tool else Inv.count(id)
	b.text = str(num)
	if is_tool:
		b.pressed.connect(_equip.bind(id))
	var base: Color = COLORS.get(id, Color.GRAY)
	var equipped: bool = (_player != null) and _player.equipped == id
	_style(b, base, equipped, is_tool, id)
	_hbox.add_child(b)


func _equip(id: String) -> void:
	if _player and Inv.count(id) > 0:
		_player.equipped = id
		_rebuild()


func _style(b: Button, base: Color, equipped: bool, is_tool: bool, id: String) -> void:
	var col := base
	if is_tool:
		var ratio := clampf(float(Inv.durability_of(id)) / float(max(1, Inv.max_dur(id))), 0.0, 1.0)
		col = base.lerp(Color(0.9, 0.2, 0.2), 1.0 - ratio)
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
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
	b.add_theme_font_size_override("font_size", 18)
