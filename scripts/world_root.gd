extends Node2D
## Корневая сцена мира. Связывает сгенерированную карту и игрока.

@onready var _player: CharacterBody2D = $Player
@onready var _terrain: TileMapLayer = $Terrain


func _ready() -> void:
	# ставим игрока на проходимый тайл рядом с центром
	_player.global_position = _terrain.find_spawn()
