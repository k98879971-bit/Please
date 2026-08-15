extends Node
## Глобальный инвентарь: ресурсы (стопками) + инструменты с прочностью.

signal changed

# Макс. прочность инструментов (дерево и камень).
const MAX_DUR := {
	"axe": 30, "sword": 50, "bow": 40, "crossbow": 55, "rod": 15, "pickaxe": 50,
	"stone_axe": 60, "stone_sword": 100, "stone_bow": 80, "stone_crossbow": 110, "stone_rod": 30, "stone_pickaxe": 100,
}

var _items := {}  # id -> кол-во (ресурсы и т.д.)
var _dur := {}    # id -> текущая прочность (инструменты)


func add(id: String, n: int = 1) -> void:
	_items[id] = _items.get(id, 0) + n
	changed.emit()


func count(id: String) -> int:
	return _items.get(id, 0)


func has(id: String, n: int = 1) -> bool:
	return count(id) >= n


func remove(id: String, n: int = 1) -> void:
	_items[id] = max(0, count(id) - n)
	changed.emit()


func is_tool(id: String) -> bool:
	return MAX_DUR.has(id)


func max_dur(id: String) -> int:
	return MAX_DUR.get(id, 0)


func durability_of(id: String) -> int:
	return _dur.get(id, 0)


# Создать/починить инструмент с полной прочностью.
func give_tool(id: String) -> void:
	_items[id] = 1
	_dur[id] = MAX_DUR[id]
	changed.emit()


# Износ на 1 при использовании; при 0 — ломается.
func use_tool(id: String) -> void:
	if not MAX_DUR.has(id) or count(id) <= 0:
		return
	var d: int = int(_dur.get(id, MAX_DUR[id])) - 1
	if d <= 0:
		_items[id] = 0
		_dur.erase(id)
	else:
		_dur[id] = d
	changed.emit()
