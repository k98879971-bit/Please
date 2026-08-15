extends Node2D
## Снаряд (стрела/болт). Летит по направлению, бьёт животных и деревья.

var dir := Vector2.ZERO
var speed := 560.0
var damage := 2
var life := 1.6


func _ready() -> void:
	add_to_group("projectiles")
	rotation = dir.angle()
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([Vector2(-10, 0), Vector2(12, 0), Vector2(6, -3), Vector2(6, 3)])
	p.color = Color(0.92, 0.86, 0.5)
	add_child(p)


func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	for a in get_tree().get_nodes_in_group("animals"):
		if is_instance_valid(a) and global_position.distance_to(a.global_position) < 22.0:
			a.take_hit(damage, global_position)
			queue_free()
			return
	for t in get_tree().get_nodes_in_group("trees"):
		if is_instance_valid(t) and t.has_method("take_hit") and global_position.distance_to(t.global_position) < 24.0:
			t.take_hit(damage)
			queue_free()
			return
