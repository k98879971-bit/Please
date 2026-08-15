extends Control
## Меню крафта (по центру экрана). Базовые рецепты — всегда; каменные — нужен верстак.

const RECIPES := {
	"workbench": {"wood": 5},
	"axe": {"wood": 3},
	"sword": {"wood": 2},
	"bow": {"wood": 3},
	"crossbow": {"wood": 5},
	"rod": {"wood": 2},
	"pickaxe": {"wood": 3},
	"stone_axe": {"wood": 3, "stone": 3},
	"stone_sword": {"wood": 3, "stone": 4},
	"stone_bow": {"wood": 3, "stone": 3},
	"stone_crossbow": {"wood": 4, "stone": 5},
	"stone_rod": {"wood": 2, "stone": 2},
	"stone_pickaxe": {"wood": 3, "stone": 4},
}

const ADVANCED := ["stone_axe", "stone_sword", "stone_bow", "stone_crossbow", "stone_rod", "stone_pickaxe"]

const NAMES := {
	"workbench": "Верстак",
	"axe": "Топор", "sword": "Меч", "bow": "Лук", "crossbow": "Арбалет", "rod": "Удочка", "pickaxe": "Кирка",
	"stone_axe": "Кам. топор", "stone_sword": "Кам. меч", "stone_bow": "Кам. лук",
	"stone_crossbow": "Кам. арбалет", "stone_rod": "Кам. удочка", "stone_pickaxe": "Кам. кирка",
	"wood": "дерева", "stone": "камня", "meat": "мяса", "fish": "рыбы",
}

var _res_label: Label
var _buttons: Dictionary = {}


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -230.0
	offset_right = 230.0
	offset_top = -260.0
	offset_bottom = 260.0
	_build()
	Inv.changed.connect(_refresh)
	_refresh()


func _build() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var mc := MarginContainer.new()
	mc.set_anchors_preset(Control.PRESET_FULL_RECT)
	mc.add_theme_constant_override("margin_left", 12)
	mc.add_theme_constant_override("margin_top", 10)
	mc.add_theme_constant_override("margin_right", 12)
	mc.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(mc)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	mc.add_child(vbox)

	vbox.add_child(_make_label("КРАФТ", true))
	_res_label = _make_label("")
	vbox.add_child(_res_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)
	for id in RECIPES:
		var b := Button.new()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.text = _recipe_text(id)
		b.pressed.connect(_craft.bind(id))
		_buttons[id] = b
		grid.add_child(b)


func _refresh() -> void:
	_res_label.text = "Дерево: %d | Камень: %d | Мясо: %d | Рыба: %d" % [Inv.count("wood"), Inv.count("stone"), Inv.count("meat"), Inv.count("fish")]
	if Inv.has("workbench"):
		_res_label.text += "   [Верстак есть]"
	for id in _buttons:
		_buttons[id].disabled = not _can_craft(id)


func _can_craft(id: String) -> bool:
	if ADVANCED.has(id) and not Inv.has("workbench"):
		return false
	for need in RECIPES[id]:
		if not Inv.has(need, RECIPES[id][need]):
			return false
	return true


func _craft(id: String) -> void:
	if not _can_craft(id):
		return
	for need in RECIPES[id]:
		Inv.remove(need, RECIPES[id][need])
	if Inv.is_tool(id):
		Inv.give_tool(id)
	else:
		Inv.add(id)


func _make_label(text: String, header: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	if header:
		l.add_theme_font_size_override("font_size", 20)
	return l


func _recipe_text(id: String) -> String:
	var parts := []
	for need in RECIPES[id]:
		parts.append("%d %s" % [RECIPES[id][need], NAMES[need]])
	var label: String = NAMES[id]
	if ADVANCED.has(id):
		label += " *"
	return "%s (%s)" % [label, _join(parts)]


func _join(parts: Array) -> String:
	var s := ""
	for i in range(parts.size()):
		if i > 0:
			s += ", "
		s += str(parts[i])
	return s
