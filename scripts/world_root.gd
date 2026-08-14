extends Node2D
## Корневая сцена: мир + сущности + UI. Спавнит деревья, животных, строит интерфейс.

const TREE_FOREST_CHANCE := 0.15
const TREE_GRASS_CHANCE := 0.025

const TreeScn := preload("res://scripts/tree.gd")
const AnimalScn := preload("res://scripts/animal.gd")
const MinimapScn := preload("res://scripts/minimap.gd")
const JoystickScn := preload("res://scripts/joystick.gd")

@onready var _terrain = $Terrain
@onready var _entities: Node2D = $Entities
@onready var _player: CharacterBody2D = $Entities/Player

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 24601
	_player.global_position = _terrain.find_spawn()
	_spawn_trees()
	_spawn_animals()
	_build_ui()


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

	# Миникарта — верхний левый угол
	var mm = MinimapScn.new()
	mm.offset_left = 12
	mm.offset_top = 12
	mm.offset_right = 12 + 170
	mm.offset_bottom = 12 + 170
	root.add_child(mm)

	# Джойстик — нижний левый угол
	var joy = JoystickScn.new()
	joy.anchor_top = 1.0
	joy.anchor_bottom = 1.0
	joy.offset_left = 16
	joy.offset_right = 16 + 128
	joy.offset_top = -16 - 128
	joy.offset_bottom = -16
	root.add_child(joy)

	# Кнопка БЕГ — нижний правый угол
	var btn := Button.new()
	btn.text = "БЕГ"
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 1.0
	btn.anchor_bottom = 1.0
	btn.offset_left = -16 - 120
	btn.offset_right = -16
	btn.offset_top = -16 - 80
	btn.offset_bottom = -16
	btn.add_theme_font_size_override("font_size", 26)
	btn.button_down.connect(func() -> void: Controls.sprint = true)
	btn.button_up.connect(func() -> void: Controls.sprint = false)
	root.add_child(btn)
