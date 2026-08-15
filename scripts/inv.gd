extends Node
## Глобальный инвентарь (предметы по id -> кол-во).

signal changed

var _items := {}


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
