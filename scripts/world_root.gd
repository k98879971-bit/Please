extends Node2D
## Корневая сцена (вид сбоку): мир-срез + игрок + UI. Случайный сид, сейв/загрузка, респавн деревьев.

const MIN_TREES := 40
const SAVE_EVERY := 20.0
const RESPAWN_EVERY := 12.0

const TreeScn := preload("res://scripts/tree.gd")
const HPBarScn := preload("res://scripts/hpbar.gd")
const JoystickScn := preload("res://scripts/joystick.gd")
const HotbarScn := preload("res://scripts/hotbar.gd")
const MenuPanelScn := preload("res://scripts/menupanel.gd")

const WNAMES := {
	"fist": "Кулаки",
	"axe": "Топор", "sword": "Меч", "bow": "Лук", "crossbow": "Арбалет", "rod": "Удочка", "pickaxe": "Кирка",
	"stone_axe": "Кам. топор", "stone_sword": "Кам. меч", "stone_bow": "Кам. лук",
	"stone_crossbow": "Кам. арбалет", "stone_rod": "Кам. удочка", "stone_pickaxe": "Кам. кирка",
}

@onready var _terrain = $Terrain
@onready var _entities: Node2D = $Entities
@onready var _player: CharacterBody2D = $Entities/Player

var _rng := RandomNumberGenerator.new()
var _menu_panel
var _equip_label: Label
var _world_seed := 0
var _save_timer := 0.0
var _respawn_timer := 0.0


func _ready() -> void:
	var smode := ""
	if Save.has_save():
		smode = String(Save.data.get("mode", ""))
	if Run.is_new:
		_world_seed = Run.world_seed
		Run.is_new = false
	elif Save.has_save() and smode == "side":
		_world_seed = int(Save.data.get("seed", 12345))
	else:
		_world_seed = randi()
	_rng.seed = _world_seed + 7
	_terrain.generate(_world_seed)

	var sp: Vector2 = _terrain.find_spawn()
	_player.global_position = sp
	_player.spawn_pos = sp
	_spawn_trees()
	_build_ui()
	_apply_save()


func _process(delta: float) -> void:
	if _player and _equip_label:
		_equip_label.text = "Оружие: " + WNAMES.get(_player.equipped, _player.equipped)
	_save_timer += delta
	if _save_timer >= SAVE_EVERY:
		_save_timer = 0.0
		_save()
	_respawn_timer += delta
	if _respawn_timer >= RESPAWN_EVERY:
		_respawn_timer = 0.0
		_respawn_trees()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save()


# --- Сохранение / загрузка ---

func save_and_quit() -> void:
	_save()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _save() -> void:
	if not is_instance_valid(_player):
		return
	var snap := Inv.snapshot()
	var state := {
		"mode": "side",
		"seed": _world_seed,
		"player": {
			"x": _player.global_position.x, "y": _player.global_position.y,
			"hp": _player.hp, "equipped": _player.equipped,
		},
		"items": snap["items"],
		"dur": snap["dur"],
		"mined_cells": _to_arr_vi(GS.mined_cells),
		"removed_trees": _to_arr_v2(GS.removed_trees),
	}
	Save.write(state)


func _apply_save() -> void:
	if String(Save.data.get("mode", "")) != "side":
		return
	var d: Dictionary = Save.data
	Inv.restore({"items": d.get("items", {}), "dur": d.get("dur", {})})
	var p: Dictionary = d.get("player", {})
	if p.size() > 0:
		_player.global_position = Vector2(float(p.get("x", 0.0)), float(p.get("y", 0.0)))
		_player.hp = int(p.get("hp", _player.hp))
		_player.equipped = String(p.get("equipped", "fist"))
	GS.mined_cells = _to_vecsi(d.get("mined_cells", []))
	GS.removed_trees = _to_vecs(d.get("removed_trees", []))
	for c in GS.mined_cells:
		_terrain.mine_cell(c)
	_free_at("trees", GS.removed_trees)


func _to_arr_vi(arr: Array) -> Array:
	var out: Array = []
	for v in arr:
		out.append([v.x, v.y])
	return out


func _to_vecsi(arr) -> Array:
	var out: Array = []
	for a in arr:
		out.append(Vector2i(int(a[0]), int(a[1])))
	return out


func _to_arr_v2(arr: Array) -> Array:
	var out: Array = []
	for v in arr:
		out.append([v.x, v.y])
	return out


func _to_vecs(arr) -> Array:
	var out: Array = []
	for a in arr:
		out.append(Vector2(float(a[0]), float(a[1])))
	return out


func _free_at(group: String, positions: Array) -> void:
	if positions.is_empty():
		return
	for n in get_tree().get_nodes_in_group(group):
		if not is_instance_valid(n):
			continue
		for p in positions:
			if n.global_position.distance_to(p) < 3.0:
				n.queue_free()
				break


# --- Деревья ---

func _spawn_trees() -> void:
	for _i in range(45):
		var cell: Vector2i = _terrain.random_grass_tile(_rng)
		var tree = TreeScn.new()
		tree.scale_rand = _rng.randf_range(0.7, 1.1)
		tree.position = _terrain.map_to_local(cell) - Vector2(0, 8)
		_entities.add_child(tree)


func _respawn_trees() -> void:
	var count := get_tree().get_nodes_in_group("trees").size()
	while count < MIN_TREES:
		var cell: Vector2i = _terrain.random_grass_tile(_rng)
		var tree = TreeScn.new()
		tree.position = _terrain.map_to_local(cell) - Vector2(0, 8)
		_entities.add_child(tree)
		count += 1


# --- UI ---

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	root.add_child(HPBarScn.new())
	root.add_child(JoystickScn.new())
	root.add_child(HotbarScn.new())

	_equip_label = Label.new()
	_equip_label.offset_left = 12.0
	_equip_label.offset_top = 12.0
	_equip_label.offset_right = 12.0 + 200.0
	_equip_label.offset_bottom = 36.0
	root.add_child(_equip_label)

	var jump_btn := Button.new()
	jump_btn.text = "ПРЫЖОК"
	_stack(jump_btn, 0)
	jump_btn.button_down.connect(func() -> void: Controls.jump_queued = true)
	root.add_child(jump_btn)

	var hit_btn := Button.new()
	hit_btn.text = "УДАР/КОПАТЬ"
	_stack(hit_btn, 1)
	hit_btn.button_down.connect(func() -> void: Controls.attack_queued = true)
	root.add_child(hit_btn)

	_menu_panel = MenuPanelScn.new()
	root.add_child(_menu_panel)
	var menu_btn := Button.new()
	menu_btn.text = "Меню"
	menu_btn.anchor_left = 1.0
	menu_btn.anchor_right = 1.0
	menu_btn.offset_left = -16.0 - 130.0
	menu_btn.offset_right = -16.0
	menu_btn.offset_top = 12.0
	menu_btn.offset_bottom = 12.0 + 56.0
	menu_btn.add_theme_font_size_override("font_size", 24)
	menu_btn.pressed.connect(_toggle_menu)
	root.add_child(menu_btn)


func _toggle_menu() -> void:
	if _menu_panel:
		_menu_panel.visible = not _menu_panel.visible
		if _menu_panel.visible:
			_menu_panel.rebuild()


func _stack(btn: Button, idx: int) -> void:
	var bw := 150
	var bh := 80
	var gap := 12
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 1.0
	btn.anchor_bottom = 1.0
	btn.offset_right = -16
	btn.offset_left = -16 - bw
	var bottom := -16 - idx * (bh + gap)
	btn.offset_bottom = bottom
	btn.offset_top = bottom - bh
	btn.add_theme_font_size_override("font_size", 24)
