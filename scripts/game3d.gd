extends Node3D
## 3D-сцена: земля, небо, ресурсы (дерево/камень/сера) с процедурными текстурами, игрок-FPS, HUD.

const Player3DScn := preload("res://scenes/Player3D.tscn")
const ResNode := preload("res://scripts/resource_node.gd")
const JoystickScn := preload("res://scripts/joystick.gd")

var _rng := RandomNumberGenerator.new()
var _labels := {}

var _mat_ground: StandardMaterial3D
var _mat_wood: StandardMaterial3D
var _mat_foliage: StandardMaterial3D
var _mat_stone: StandardMaterial3D
var _mat_sulfur: StandardMaterial3D


func _ready() -> void:
	_rng.seed = 99
	_build_materials()
	_build_env()
	_build_ground()
	_build_resources()
	_build_player()
	_build_hud()


func _process(_delta: float) -> void:
	for r in _labels:
		_labels[r].text = "%s: %d" % [_rname(r), Inv.count(r)]


# --- Материалы с процедурными текстурами ---

func _build_materials() -> void:
	_mat_ground = _mat(_noise_tex(Color(0.27, 0.48, 0.24), 0.14, 1), Vector3(40, 40, 40))
	_mat_wood = _mat(_noise_tex(Color(0.42, 0.27, 0.15), 0.10, 2), Vector3(2, 3, 2))
	_mat_foliage = _mat(_noise_tex(Color(0.18, 0.46, 0.18), 0.10, 3), Vector3(2, 2, 2))
	_mat_stone = _mat(_noise_tex(Color(0.50, 0.50, 0.52), 0.13, 4), Vector3(1, 1, 1))
	_mat_sulfur = _mat(_noise_tex(Color(0.86, 0.80, 0.26), 0.10, 5), Vector3(1.5, 1.5, 1.5))


func _noise_tex(base: Color, amp: float, seed: int, size := 128) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var n := FastNoiseLite.new()
	n.seed = seed
	n.frequency = 0.09
	n.fractal_type = FastNoiseLite.FRACTAL_FBM
	n.fractal_octaves = 4
	for y in range(size):
		for x in range(size):
			var v: float = n.get_noise_2d(float(x), float(y))
			var c := Color(
				clampf(base.r + v * amp, 0.0, 1.0),
				clampf(base.g + v * amp, 0.0, 1.0),
				clampf(base.b + v * amp, 0.0, 1.0))
			img.set_pixel(x, y, c)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func _mat(tex: ImageTexture, scale: Vector3) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.uv1_scale = scale
	return m


# --- Окружение ---

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
	plane.material = _mat_ground
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
	cm.material = _mat_wood
	trunk.mesh = cm
	trunk.position = Vector3(0, 1.1, 0)
	n.add_child(trunk)

	var fol := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 1.2
	sm.height = 2.4
	sm.material = _mat_foliage
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
	bm.material = _mat_stone if rtype == "stone" else _mat_sulfur
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
