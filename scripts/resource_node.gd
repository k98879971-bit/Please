extends StaticBody3D
## Узел ресурса (дерево/камень/сера). Копается через raycast игрока.

@export var res_type := "wood"
@export var hp := 3


func gather() -> void:
	Inv.add(res_type)
	hp -= 1
	if hp <= 0:
		queue_free()
