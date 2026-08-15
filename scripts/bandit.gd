extends Node2D
## Разбойник (враг): преследует и атакует игрока. На смерти роняет лут.

const HP_MAX := 25
const AGGRO := 280.0
const ATK_RANGE := 34.0
const SPEED := 82.0
const ATK_CD := 1.2
const DAMAGE := 6
const PickupScn := preload("res://scripts/pickup.gd")

var hp := HP_MAX
var _atk := 0.0
var _player


func _ready() -> void:
	add_to_group("enemies")
	z_index = 8
	_player = get_tree().get_first_node_in_group("player")
	_build_visual()


func _physics_process(delta: float) -> void:
	if _atk > 0.0:
		_atk -= delta
	if not is_instance_valid(_player):
		return
	var d: float = global_position.distance_to(_player.global_position)
	if d < AGGRO:
		var dir: Vector2 = (_player.global_position - global_position).normalized()
		global_position += dir * SPEED * delta
		if d < ATK_RANGE and _atk <= 0.0:
			_player.take_damage(DAMAGE)
			_atk = ATK_CD


func take_hit(damage: int, _from_pos: Vector2) -> void:
	hp -= damage
	if hp <= 0:
		_drop_loot()
		queue_free()


func _drop_loot() -> void:
	var drops := ["wood", "wood", "stone", "meat"]
	var id: String = drops[randi() % drops.size()]
	var pk = PickupScn.new()
	pk.item_id = id
	pk.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	var ent = get_parent()
	if ent:
		ent.add_child(pk)


func _build_visual() -> void:
	var body := Polygon2D.new()
	body.polygon = _circle(11.0, 16)
	body.color = Color(0.25, 0.15, 0.18)
	add_child(body)
	var head := Polygon2D.new()
	head.polygon = _circle(6.0, 14)
	head.color = Color(0.5, 0.35, 0.3)
	head.position = Vector2(0, -12)
	add_child(head)
	var wpn := Polygon2D.new()
	wpn.polygon = PackedVector2Array([Vector2(10, -6), Vector2(22, -10), Vector2(18, 2)])
	wpn.color = Color(0.7, 0.2, 0.2)
	add_child(wpn)


func _circle(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := i * TAU / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
