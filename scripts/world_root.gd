extends Node2D
## Корневая сцена: мир + сущности + UI.

const TREE_FOREST_CHANCE := 0.15
const TREE_GRASS_CHANCE := 0.025
const ORE_CHANCE := 0.25

const TreeScn := preload("res://scripts/tree.gd")
const AnimalScn := preload("res://scripts/animal.gd")
const FishScn := preload("res://scripts/fish.gd")
const OreScn := preload("res://scripts/ore.gd")
const MinimapScn := preload("res://scripts/minimap.gd")
const HPBarScn := preload("res://scripts/hpbar.gd")
const StaminaBarScn := preload("res://scripts/staminabar.gd")
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


func _ready() -> void:
	_rng.seed = 24601
	_player.global_position = _terrain.find_spawn()
	_spawn_trees()
	_spawn_ore()
	_spawn_animals()
	_spawn_fish()
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


func _spawn_ore() -> void:
	for x in range(_terrain.WORLD_W):
		for y in range(_terrain.WORLD_H):
			var cell := Vector2i(x, y)
			if _terrain.tile_at(_terrain.map_to_local(cell)) == _terrain.T.ROCK and _rng.randf() < ORE_CHANCE:
				var o = OreScn.new()
				o.position = _terrain.map_to_local(cell) + Vector2(_rng.randf_range(-8, 8), _rng.randf_range(-4, 8))
				_entities.add_child(o)


func _spawn_animals() -> void:
	var counts := {AnimalScn.Kind.CHICKEN: 14, AnimalScn.Kind.SHEEP: 10, AnimalScn.Kind.COW: 7}
	for kind in counts:
		for _i in range(counts[kind]):
			var a = AnimalScn.new()
			a.kind = kind
			a.position = _terrain.map_to_local(_terrain.random_land_tile(_rng))
			_entities.add_child(a)


func _spawn_fish() -> void:
	for _i in range(20):
		var f = FishScn.new()
		f.position = _terrain.map_to_local(_terrain.random_water_tile(_rng))
		_entities.add_child(f)


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
	root.add_child(HotbarScn.new())

	_equip_label = Label.new()
	_equip_label.offset_left = 12.0
	_equip_label.offset_top = 250.0
	_equip_label.offset_right = 12.0 + 170.0
	_equip_label.offset_bottom = 274.0
	root.add_child(_equip_label)

	var run_btn := Button.new()
	run_btn.text = "БЕГ"
	_stack(run_btn, 0)
	run_btn.button_down.connect(func() -> void: Controls.sprint = true)
	run_btn.button_up.connect(func() -> void: Controls.sprint = false)
	root.add_child(run_btn)

	var hit_btn := Button.new()
	hit_btn.text = "УДАР"
	_stack(hit_btn, 1)
	hit_btn.button_down.connect(func() -> void: Controls.attack_queued = true)
	root.add_child(hit_btn)

	var fish_btn := Button.new()
	fish_btn.text = "Рыба"
	_stack(fish_btn, 2)
	fish_btn.button_down.connect(func() -> void: Controls.fish_queued = true)
	root.add_child(fish_btn)

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


func _stack(btn: Button, idx: int) -> void:
	var bw := 120
	var bh := 72
	var gap := 10
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 1.0
	btn.anchor_bottom = 1.0
	btn.offset_right = -16
	btn.offset_left = -16 - bw
	var bottom := -16 - idx * (bh + gap)
	btn.offset_bottom = bottom
	btn.offset_top = bottom - bh
	btn.add_theme_font_size_override("font_size", 26)
