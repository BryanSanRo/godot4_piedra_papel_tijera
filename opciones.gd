extends Control

@onready var volumen_label: Label = $CenterContainer/PanelContainer/VBoxContainer/VolumenLabel
@onready var volumen_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/VolumenSlider
@onready var volver_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/VolverButton


func _ready():
	
	volumen_slider.value = MusicManager.get_volume_linear() * 100.0
	_actualizar_texto(volumen_slider.value)

	volumen_slider.value_changed.connect(_on_volumen_changed)
	volver_btn.pressed.connect(_on_volver_pressed)
	_setup_hover([volver_btn])


func _on_volumen_changed(value: float) -> void:
	MusicManager.set_volume_linear(value / 100.0)
	_actualizar_texto(value)

func _actualizar_texto(value: float) -> void:
	volumen_label.text = "Volumen: %d%%" % int(value)

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
func _setup_hover(botones: Array[Control]) -> void:
	for b in botones:
		b.mouse_entered.connect(_on_btn_mouse_entered.bind(b))
		b.mouse_exited.connect(_on_btn_mouse_exited.bind(b))

func _on_btn_mouse_entered(b: Control) -> void:
	_hover(b, 1.06)

func _on_btn_mouse_exited(b: Control) -> void:
	_hover(b, 1.00)

func _hover(b: Control, s: float) -> void:
	b.pivot_offset = b.size * 0.5

	if b.has_meta("_hover_tw"):
		var prev := b.get_meta("_hover_tw") as Tween
		if prev:
			prev.kill()

	var tw := create_tween()
	b.set_meta("_hover_tw", tw)

	tw.tween_property(b, "scale", Vector2(s, s), 0.10)
