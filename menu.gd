extends Control

@onready var jugar_btn: Button = $CenterContainer/MarginContainer/VBoxContainer/JugarButton
@onready var opciones_btn: Button = $CenterContainer/MarginContainer/VBoxContainer/OpcionesButton
@onready var salir_btn: Button = $CenterContainer/MarginContainer/VBoxContainer/SalirButton

func _ready() -> void:
	jugar_btn.pressed.connect(_on_jugar_pressed)
	opciones_btn.pressed.connect(_on_opciones_pressed)
	salir_btn.pressed.connect(_on_salir_pressed)

	var botones: Array[Button] = [jugar_btn, opciones_btn, salir_btn]
	for b in botones:
		b.mouse_entered.connect(func(): _hover(b, 1.06))
		b.mouse_exited.connect(func(): _hover(b, 1.00))

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _on_opciones_pressed() -> void:
	get_tree().change_scene_to_file("res://opciones.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()

func _hover(b: Control, s: float) -> void:
	b.pivot_offset = b.size * 0.5
	var tw := create_tween()
	tw.tween_property(b, "scale", Vector2(s, s), 0.10)
