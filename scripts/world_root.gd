extends Node2D
## Корневая сцена: мир + сущности + UI. Спавнит деревья, животных, строит интерфейс.

const TREE_FOREST_CHANCE := 0.15
const TREE_GRASS_CHANCE := 0.025

const TreeScn := preload("res://scripts/tree.gd")
const AnimalScn := preload("res://scripts/animal.gd")
const MinimapScn := preload("res://scripts/minimap.gd")
const HPBarScn := preload("res://scripts/hpbar.gd")
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

	# Миникарта и полоса HP (сами позиционируются в верхнем левом углу)
	root.add_child(MinimapScn.new())
	root.add_child(HPBarScn.new())

	# Крупный джойстик (сам позиционируется в нижнем левом углу)
	root.add_child(JoystickScn.new())

	# Кнопка БЕГ — правый нижний угол
	var sprint := Button.new()
	sprint.text = "БЕГ"
	_anchor_bottom_right(sprint, 130, 90, 0)
	sprint.add_theme_font_size_override("font_size", 30)
	sprint.button_down.connect(func() -> void: Controls.sprint = true)
	sprint.button_up.connect(func() -> void: Controls.sprint = false)
	root.add_child(sprint)

	# Кнопка УДАР — левее кнопки БЕГ
	var atk := Button.new()
	atk.text = "УДАР"
	_anchor_bottom_right(atk, 130, 90, 130 + 16)
	atk.add_theme_font_size_override("font_size", 30)
	atk.button_down.connect(func() -> void: Controls.attack_queued = true)
	root.add_child(atk)


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
