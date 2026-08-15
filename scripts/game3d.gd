extends Node3D
## 3D-сцена: земля, небо, ресурсы (дерево/камень/сера), игрок-FPS, HUD.

const Player3DScn := preload("res://scenes/Player3D.tscn")
const ResNode := preload("res://scripts/resource_node.gd")
const JoystickScn := preload("res://scripts/joystick.gd")

var _rng := RandomNumberGenerator.new()
var _labels := {}


func _ready() -> void:
	_rng.seed = 99
	_build_env()
	_build_ground()
	_build_resources()
	_build_player()
	_build_hud()


func _process(_delta: float) -> void:
	for r in _labels:
		_labels[r].text = "%s: %d" % [_rname(r), Inv.count(r)]


func _build_env() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.6
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(-0.6, -0.4, 0)
	sun.light_energy = 1.1
	add_child(sun)


func _build_ground() -> void:
	var g := StaticBody3D.new()
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(200, 200)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.50, 0.25)
	plane.material = mat
	mesh.mesh = plane
	g.add_child(mesh)
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(200, 1, 200)
	col.shape = box
	col.position = Vector3(0, -0.5, 0)
	g.add_child(col)
	add_child(g)


func _build_resources() -> void:
	for _i in range(35):
		_spawn_tree(_rand_pos())
	for _i in range(22):
		_spawn_rock(_rand_pos(), "stone")
	for _i in range(14):
		_spawn_rock(_rand_pos(), "sulfur")


func _rand_pos() -> Vector3:
	return Vector3(_rng.randf_range(-90, 90), 0, _rng.randf_range(-90, 90))


func _spawn_tree(pos: Vector3) -> void:
	var n := StaticBody3D.new()
	n.set_script(ResNode)
	n.res_type = "wood"
	n.hp = 3
	n.position = pos

	var trunk := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.25
	cm.bottom_radius = 0.35
	cm.height = 2.2
	var tm := StandardMaterial3D.new()
	tm.albedo_color = Color(0.40, 0.26, 0.14)
	cm.material = tm
	trunk.mesh = cm
	trunk.position = Vector3(0, 1.1, 0)
	n.add_child(trunk)

	var fol := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 1.2
	sm.height = 2.4
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.20, 0.50, 0.20)
	sm.material = fm
	fol.mesh = sm
	fol.position = Vector3(0, 2.8, 0)
	n.add_child(fol)

	var col := CollisionShape3D.new()
	var cb := CylinderShape3D.new()
	cb.radius = 0.5
	cb.height = 3.0
	col.shape = cb
	col.position = Vector3(0, 1.5, 0)
	n.add_child(col)
	add_child(n)


func _spawn_rock(pos: Vector3, rtype: String) -> void:
	var n := StaticBody3D.new()
	n.set_script(ResNode)
	n.res_type = rtype
	n.hp = 3 if rtype == "stone" else 2
	n.position = pos

	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.2, 1.0, 1.2)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.50, 0.50, 0.52) if rtype == "stone" else Color(0.85, 0.80, 0.25)
	bm.material = mat
	m.mesh = bm
	m.position = Vector3(0, 0.5, 0)
	n.add_child(m)

	var col := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.2, 1.0, 1.2)
	col.shape = bs
	col.position = Vector3(0, 0.5, 0)
	n.add_child(col)
	add_child(n)


func _build_player() -> void:
	var p := Player3DScn.instantiate()
	p.position = Vector3(0, 2, 0)
	add_child(p)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var vbox := VBoxContainer.new()
	vbox.offset_left = 16
	vbox.offset_top = 16
	vbox.add_theme_constant_override("separation", 4)
	root.add_child(vbox)
	for r in ["wood", "stone", "sulfur"]:
		var l := Label.new()
		l.text = _rname(r) + ": 0"
		l.add_theme_font_size_override("font_size", 24)
		vbox.add_child(l)
		_labels[r] = l

	root.add_child(JoystickScn.new())

	var g_btn := Button.new()
	g_btn.text = "ДОБЫТЬ"
	_stack(g_btn, 0)
	g_btn.button_down.connect(func() -> void: Controls.attack_queued = true)
	root.add_child(g_btn)

	var j_btn := Button.new()
	j_btn.text = "ПРЫЖОК"
	_stack(j_btn, 1)
	j_btn.button_down.connect(func() -> void: Controls.jump_queued = true)
	root.add_child(j_btn)


func _stack(btn: Button, idx: int) -> void:
	var bw := 150
	var bh := 80
	var gap := 12
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 1.0
	btn.anchor_bottom = 1.0
	btn.offset_right = -16
	btn.offset_left = -16 - bw
	var bottom := -16 - idx * (bh + gap)
	btn.offset_bottom = bottom
	btn.offset_top = bottom - bh
	btn.add_theme_font_size_override("font_size", 24)


func _rname(r: String) -> String:
	match r:
		"wood":
			return "Дерево"
		"stone":
			return "Камень"
		"sulfur":
			return "Сера"
		_:
			return r
