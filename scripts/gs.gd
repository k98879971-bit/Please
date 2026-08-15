extends Node
## Изменённые игроком элементы мира (для корректного сохранения в виде сбоку).

var mined_cells: Array = []    # Vector2i — выкопанные тайлы
var removed_trees: Array = []  # Vector2 — срубленные деревья
