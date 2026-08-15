extends Control
## Панель крафта (открывается кнопкой «Меню»). Экипировка — тапом по ячейке хотбара.

const RECIPES := {
	"axe": {"wood": 3},
	"sword": {"wood": 2},
	"bow": {"wood": 3},
	"crossbow": {"wood": 5},
	"rod": {"wood": 2},
}

const NAMES := {
	"axe": "Топор",
	"sword": "Меч",
	"bow": "Лук",
	"crossbow": "Арбалет",
	"rod": "Удочка",
	"wood": "дерева",
	"meat": "мяса",
	"fish": "рыбы",
}

var _res_label: Label
var _craft_buttons: Dictionary = {}


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -300.0
	offset_right = -12.0
	offset_top = -150.0
	offset_bottom = 150.0
	_build()
	Inv.changed.connect(_refresh)
	_refresh()


func _build() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var mc := MarginContainer.new()
	mc.set_anchors_preset(Control.PRESET_FULL_RECT)
	mc.add_theme_constant_override("margin_left", 10)
	mc.add_theme_constant_override("margin_top", 10)
	mc.add_theme_constant_override("margin_right", 10)
	mc.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(mc)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	mc.add_child(vbox)

	vbox.add_child(_make_label("КРАФТ", true))
	_res_label = _make_label("")
	vbox.add_child(_res_label)
	for id in RECIPES:
		var b := Button.new()
		b.text = _recipe_text(id)
		b.pressed.connect(_craft.bind(id))
		_craft_buttons[id] = b
		vbox.add_child(b)


func _refresh() -> void:
	_res_label.text = "Дерево: %d | Мясо: %d | Рыба: %d" % [Inv.count("wood"), Inv.count("meat"), Inv.count("fish")]
	for id in _craft_buttons:
		_craft_buttons[id].disabled = not _can_craft(id)


func _can_craft(id: String) -> bool:
	for need in RECIPES[id]:
		if not Inv.has(need, RECIPES[id][need]):
			return false
	return true


func _craft(id: String) -> void:
	if not _can_craft(id):
		return
	for need in RECIPES[id]:
		Inv.remove(need, RECIPES[id][need])
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
	return "%s (%s)" % [NAMES[id], _join(parts)]


func _join(parts: Array) -> String:
	var s := ""
	for i in range(parts.size()):
		if i > 0:
			s += ", "
		s += str(parts[i])
	return s
