extends Node2D
## Корневая сцена: мир + сущности + UI. Спавнит деревья, животных, строит интерфейс.

const TREE_FOREST_CHANCE := 0.15
const TREE_GRASS_CHANCE := 0.025

const TreeScn := preload("res://scripts/tree.gd")
const AnimalScn := preload("res://scripts/animal.gd")
const MinimapScn := preload("res://scripts/minimap.gd")
const HPBarScn := preload("res://scripts/hpbar.gd")
const StaminaBarScn := preload("res://scripts/staminabar.gd")
const JoystickScn := preload("res://scripts/joystick.gd")
const MenuPanelScn := preload("res://scripts/menupanel.gd")

const WNAMES := {
	"fist": "Кулаки",
	"axe": "Топор",
	"sword": "Меч",
	"bow": "Лук",
	"crossbow": "Арбалет",
}

@onready var _terrain = $Terrain
@onready var _entities: Node2D = $Entities
@onready var _player: CharacterBody2D = $Entities/Player

var _rng := RandomNumberGenerator.new()
var _menu_panel
var _equip_label: Label


func _ready() -> void:
	_rng.seed = 24601
	_player.global_position = _terrain.find_spawn()
	_spawn_trees()
	_spawn_animals()
	_build_ui()


func _process(_delta: float) -> void:
	if _player and _equip_label:
		_equip_label.text = "Оружие: " + WNAMES.get(_player.equipped, _player.equipped)


func _spawn_trees() -> void:
	for x in range(_terrain.WORLD_W):
		for y in range(_terrain.WORLD_H):
			var cell := Vector2i(x, y)
			var t = _terrain.tile_at(_terrain.map_to_local(cell))
			var chance := 0.0
			if t == _terrain.T.FOREST:
				chance = TREE_FOREST_CHANCE
			elif t == _terrain.T.GRASS:
				chance = TREE_GRASS_CHANCE
			if chance > 0.0 and _rng.randf() < chance:
				var tree = TreeScn.new()
				tree.scale_rand = _rng.randf_range(0.8, 1.25)
				tree.position = _terrain.map_to_local(cell) + Vector2(_rng.randf_range(-8, 8), _rng.randf_range(0, 10))
				_entities.add_child(tree)


func _spawn_animals() -> void:
	var counts := {AnimalScn.Kind.CHICKEN: 14, AnimalScn.Kind.SHEEP: 10, AnimalScn.Kind.COW: 7}
	for kind in counts:
		for _i in range(counts[kind]):
			var a = AnimalScn.new()
			a.kind = kind
			a.position = _terrain.map_to_local(_terrain.random_land_tile(_rng))
			_entities.add_child(a)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	root.add_child(MinimapScn.new())
	root.add_child(HPBarScn.new())
	root.add_child(StaminaBarScn.new())
	root.add_child(JoystickScn.new())

	# Подпись текущего оружия (под полосами)
	_equip_label = Label.new()
	_equip_label.offset_left = 12.0
	_equip_label.offset_top = 250.0
	_equip_label.offset_right = 12.0 + 170.0
	_equip_label.offset_bottom = 274.0
	root.add_child(_equip_label)

	# Кнопки БЕГ и УДАР (нижний правый угол)
	var sprint := Button.new()
	sprint.text = "БЕГ"
	_anchor_bottom_right(sprint, 130, 90, 0)
	sprint.add_theme_font_size_override("font_size", 30)
	sprint.button_down.connect(func() -> void: Controls.sprint = true)
	sprint.button_up.connect(func() -> void: Controls.sprint = false)
	root.add_child(sprint)

	var atk := Button.new()
	atk.text = "УДАР"
	_anchor_bottom_right(atk, 130, 90, 130 + 16)
	atk.add_theme_font_size_override("font_size", 30)
	atk.button_down.connect(func() -> void: Controls.attack_queued = true)
	root.add_child(atk)

	# Меню (инвентарь/крафт) + кнопка
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


func _anchor_bottom_right(btn: Button, bw: int, bh: int, gap_left: int) -> void:
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 1.0
	btn.anchor_bottom = 1.0
	var right := -16 - gap_left
	btn.offset_right = right
	btn.offset_left = right - bw
	btn.offset_bottom = -16
	btn.offset_top = -16 - bh
