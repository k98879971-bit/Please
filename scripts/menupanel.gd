extends Control
## Меню крафта по центру: для каждого рецепта — ячейка результата + ячейки нужных материалов + кнопка.

const ID := preload("res://scripts/item_data.gd")

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

var _res_label: Label
var _rows: VBoxContainer


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -250.0
	offset_right = 250.0
	offset_top = -270.0
	offset_bottom = 270.0
	_build_skeleton()
	Inv.changed.connect(_on_changed)
	_rebuild()


func _build_skeleton() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var mc := MarginContainer.new()
	mc.set_anchors_preset(Control.PRESET_FULL_RECT)
	mc.add_theme_constant_override("margin_left", 10)
	mc.add_theme_constant_override("margin_top", 8)
	mc.add_theme_constant_override("margin_right", 10)
	mc.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(mc)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	mc.add_child(col)

	col.add_child(_make_label("КРАФТ", true))
	_res_label = _make_label("")
	col.add_child(_res_label)

	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(sc)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 6)
	sc.add_child(_rows)


func rebuild() -> void:
	_rebuild()


func _on_changed() -> void:
	if visible:
		_rebuild()


func _rebuild() -> void:
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.free()
	for id in RECIPES:
		_rows.add_child(_make_row(id))


func _make_row(id: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	var adv := ADVANCED.has(id)
	var locked := adv and not Inv.has("workbench")
	row.add_child(_cell(id, ID.NAMES.get(id, id), true, locked))
	row.add_child(_make_label("←"))
	for need in RECIPES[id]:
		var have := Inv.has(need, RECIPES[id][need])
		row.add_child(_cell(need, "%d %s" % [RECIPES[id][need], ID.NAMES.get(need, need)], have and not locked, locked))
	var cb := Button.new()
	cb.text = "Сделать"
	cb.disabled = locked or not _can_craft(id)
	cb.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cb.pressed.connect(_craft.bind(id))
	row.add_child(cb)
	return row


func _cell(id: String, text: String, ok: bool, locked: bool) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(62, 46)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base: Color = ID.COLORS.get(id, Color.GRAY)
	var bg := ColorRect.new()
	bg.color = base.darkened(0.55) if (locked or not ok) else base
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(bg)
	var l := Label.new()
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 12)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(l)
	return c


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
