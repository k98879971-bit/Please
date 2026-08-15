extends Control
## Главное меню. «Играть» — продолжить (загрузить сейв), «Новая игра» — случайный мир, «Выход» — выйти.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.16, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(cc)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	cc.add_child(vbox)

	var title := Label.new()
	title.text = "PIXEL SURVIVAL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "выживание в открытом мире"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	vbox.add_child(sub)

	var play := Button.new()
	play.text = "Играть (продолжить)"
	play.custom_minimum_size = Vector2(300, 70)
	play.add_theme_font_size_override("font_size", 26)
	play.pressed.connect(_play)
	vbox.add_child(play)

	var newg := Button.new()
	newg.text = "Новая игра (случайный мир)"
	newg.custom_minimum_size = Vector2(300, 70)
	newg.add_theme_font_size_override("font_size", 26)
	newg.pressed.connect(_new_game)
	vbox.add_child(newg)

	var exit := Button.new()
	exit.text = "Выход"
	exit.custom_minimum_size = Vector2(300, 70)
	exit.add_theme_font_size_override("font_size", 26)
	exit.pressed.connect(_exit)
	vbox.add_child(exit)


func _play() -> void:
	Save.reload()
	Run.is_new = false
	get_tree().change_scene_to_file("res://scenes/World.tscn")


func _new_game() -> void:
	Run.is_new = true
	Run.world_seed = randi()
	Save.clear()
	get_tree().change_scene_to_file("res://scenes/World.tscn")


func _exit() -> void:
	get_tree().quit()
