extends Node
## Сохранение/загрузка мира в user://save.json.

const PATH := "user://save.json"

var data := {}


func _ready() -> void:
	_load()


func has_save() -> bool:
	return data.size() > 0


func _load() -> void:
	if FileAccess.file_exists(PATH):
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				data = parsed


func reload() -> void:
	data = {}
	_load()


func write(state: Dictionary) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(state))
		f.close()


func clear() -> void:
	data = {}
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)
