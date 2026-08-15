extends Control
## Панель: инвентарь + крафт + экипировка. Переключается кнопкой «Меню».

const RECIPES := {
	"axe": {"wood": 3},
	"sword": {"wood": 2},
	"bow": {"wood": 3},
	"crossbow": {"wood": 5},
}

const NAMES := {
	"fist": "Кулаки",
	"axe": "Топор",
	"sword": "Меч",
	"bow": "Лук",
	"crossbow": "Арбалет",
	"wood": "дерева",
	"meat": "мяса",
}

const WEAPON_ORDER := ["fist", "axe", "sword", "bow", "crossbow"]

var _player
var _res_label: Label
var _equip_label: Label
var _craft_buttons: Dictionary = {}
var _equip_buttons: Dictionary = {}


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -340.0
	offset_right = -12.0
	offset_top = -210.0
	offset_bottom = 210.0
	_player = get_tree().get_first_node_in_group("player")
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
	vbox.add_theme_constant_override("separation", 5)
	mc.add_child(vbox)

	vbox.add_child(_make_label("ИНВЕНТАРЬ", true))
	_res_label = _make_label("")
	vbox.add_child(_res_label)

	vbox.add_child(_make_label("КРАФТ", true))
	for id in RECIPES:
		var b := Button.new()
		b.text = _recipe_text(id)
		b.pressed.connect(_craft.bind(id))
		_craft_buttons[id] = b
		vbox.add_child(b)

	vbox.add_child(_make_label("ОРУЖИЕ", true))
	for w in WEAPON_ORDER:
		var b := Button.new()
		b.text = NAMES[w]
		b.pressed.connect(_equip.bind(w))
		_equip_buttons[w] = b
		vbox.add_child(b)
	_equip_label = _make_label("")
	vbox.add_child(_equip_label)


func _refresh() -> void:
	var wood := Inv.count("wood")
	var meat := Inv.count("meat")
	var txt := "Дерево: %d\nМясо: %d" % [wood, meat]
	var tools := []
	for t in ["axe", "sword", "bow", "crossbow"]:
		var c := Inv.count(t)
		if c > 0:
			tools.append("%s ×%d" % [NAMES[t], c])
	if not tools.is_empty():
		txt += "\nИнструменты: " + _join(tools)
	_res_label.text = txt

	for id in _craft_buttons:
		_craft_buttons[id].disabled = not _can_craft(id)
	for w in _equip_buttons:
		_equip_buttons[w].disabled = (w != "fist") and (Inv.count(w) <= 0)

	if _player:
		_equip_label.text = "Сейчас: " + NAMES.get(_player.equipped, _player.equipped)


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


func _equip(w: String) -> void:
	if _player:
		_player.equipped = w
		_refresh()


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
