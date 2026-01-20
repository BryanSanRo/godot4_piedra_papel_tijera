extends Control

@onready var turno_label: Label = $CenterContainer/VBoxContainer/TurnoLabel
@onready var info_label: Label = $CenterContainer/VBoxContainer/InfoLabel
@onready var marcador_label: Label = $CenterContainer/VBoxContainer/MarcadorLabel

@onready var piedra_btn: Button = $CenterContainer/VBoxContainer/OpcionesBox/PiedraButton
@onready var papel_btn: Button = $CenterContainer/VBoxContainer/OpcionesBox/PapelButton
@onready var tijera_btn: Button = $CenterContainer/VBoxContainer/OpcionesBox/TijeraButton

@onready var siguiente_btn: Button = $CenterContainer/VBoxContainer/SiguienteRondaButton
@onready var reiniciar_btn: Button = $ReiniciarButton

@onready var fondo_turno: ColorRect = $FondoTurno
@onready var overlay_fin: ColorRect = $OverlayFin

@onready var menu_btn: Button = $MenuButton
@onready var menu_dialog: ConfirmationDialog = $MenuConfirmDialog

var turno: int = 1
var eleccion_j1: String = ""
var eleccion_j2: String = ""
var puntos_j1: int = 0
var puntos_j2: int = 0

const OVERLAY_ALPHA := 0.25

func _ready() -> void:
	piedra_btn.text = ""
	papel_btn.text = ""
	tijera_btn.text = ""
	ocultar_boton_siguiente()
	overlay_fin.visible = false
	overlay_fin.color = Color(0, 0, 0, 0)

	siguiente_btn.pressed.connect(_on_siguiente_ronda_pressed)
	reiniciar_btn.pressed.connect(_on_reiniciar_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	menu_dialog.confirmed.connect(_on_menu_confirmed)

	piedra_btn.pressed.connect(func(): registrar_eleccion("Piedra"))
	papel_btn.pressed.connect(func(): registrar_eleccion("Papel"))
	tijera_btn.pressed.connect(func(): registrar_eleccion("Tijera"))

	menu_dialog.dialog_text = "¿Volver al menú principal?\nSe perderá la partida actual."
	menu_dialog.get_ok_button().text = "Sí, volver"
	if menu_dialog.has_method("get_cancel_button"):
		menu_dialog.get_cancel_button().text = "Cancelar"

	_setup_hover([reiniciar_btn])
	actualizar_ui_inicio()

func _on_menu_pressed() -> void:
	menu_dialog.min_size = Vector2(520, 240)
	menu_dialog.popup_centered()

func _on_menu_confirmed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_siguiente_ronda_pressed() -> void:
	ocultar_overlay_fin()
	ocultar_boton_siguiente()
	turno = 1
	eleccion_j1 = ""
	eleccion_j2 = ""
	actualizar_fondo_turno()
	turno_label.text = "Turno: Jugador 1"
	info_label.text = "Jugador 1, elige tu jugada"
	set_elecciones_habilitadas(true)

func _on_reiniciar_pressed() -> void:
	puntos_j1 = 0
	puntos_j2 = 0
	actualizar_ui_inicio()

func registrar_eleccion(eleccion: String) -> void:
	set_elecciones_habilitadas(false)
	animar_pulse(_btn_de_eleccion(eleccion))
	if turno == 1:
		eleccion_j1 = eleccion
		info_label.text = "Jugador 1 listo"
		animar_fade_label()
		await get_tree().create_timer(0.6).timeout
		turno = 2
		actualizar_fondo_turno()
		turno_label.text = "Turno: Jugador 2"
		info_label.text = "Jugador 2, elige tu jugada"
		set_elecciones_habilitadas(true)
	else:
		eleccion_j2 = eleccion
		await cuenta_atras()
		resolver_ronda()
		mostrar_overlay_fin()
		info_label.text += "\nPulsa 'Siguiente ronda' para continuar"
		mostrar_boton_siguiente()
		set_elecciones_habilitadas(false)

func resolver_ronda() -> void:
	var ganador := decidir_ganador(eleccion_j1, eleccion_j2)
	if ganador == 0:
		info_label.text = "Empate: %s vs %s" % [eleccion_j1, eleccion_j2]
	elif ganador == 1:
		puntos_j1 += 1
		info_label.text = "Gana J1: %s vs %s" % [eleccion_j1, eleccion_j2]
	else:
		puntos_j2 += 1
		info_label.text = "Gana J2: %s vs %s" % [eleccion_j1, eleccion_j2]
	actualizar_marcador()

func decidir_ganador(a: String, b: String) -> int:
	if a == b:
		return 0
	if a == "Piedra" and b == "Tijera":
		return 1
	if a == "Tijera" and b == "Papel":
		return 1
	if a == "Papel" and b == "Piedra":
		return 1
	return 2

func actualizar_ui_inicio() -> void:
	turno = 1
	eleccion_j1 = ""
	eleccion_j2 = ""
	ocultar_overlay_fin()
	ocultar_boton_siguiente()
	turno_label.text = "Turno: Jugador 1"
	info_label.text = "Jugador 1, elige tu jugada"
	actualizar_marcador()
	actualizar_fondo_turno()
	set_elecciones_habilitadas(true)

func actualizar_marcador() -> void:
	marcador_label.text = "J1: %d | J2: %d" % [puntos_j1, puntos_j2]

func actualizar_fondo_turno() -> void:
	var c: Color = Color(0.12, 0.20, 0.40, 1.0) if turno == 1 else Color(0.40, 0.20, 0.10, 1.0)
	var tw := create_tween()
	tw.tween_property(fondo_turno, "color", c, 0.25)

func set_elecciones_habilitadas(habilitadas: bool) -> void:
	var mf := Control.MOUSE_FILTER_STOP if habilitadas else Control.MOUSE_FILTER_IGNORE
	piedra_btn.mouse_filter = mf
	papel_btn.mouse_filter = mf
	tijera_btn.mouse_filter = mf

func mostrar_overlay_fin() -> void:
	overlay_fin.visible = true
	overlay_fin.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	tw.tween_property(overlay_fin, "color", Color(0, 0, 0, OVERLAY_ALPHA), 0.25)

func ocultar_overlay_fin() -> void:
	if not overlay_fin.visible:
		return
	var tw := create_tween()
	tw.tween_property(overlay_fin, "color", Color(0, 0, 0, 0.0), 0.20)
	tw.tween_callback(func(): overlay_fin.visible = false)

func mostrar_boton_siguiente() -> void:
	siguiente_btn.visible = true
	siguiente_btn.disabled = false

func ocultar_boton_siguiente() -> void:
	siguiente_btn.visible = false
	siguiente_btn.disabled = true

func _btn_de_eleccion(eleccion: String) -> Button:
	match eleccion:
		"Piedra": return piedra_btn
		"Papel": return papel_btn
		"Tijera": return tijera_btn
	return piedra_btn

func cuenta_atras() -> void:
	for t in ["Piedra...", "Papel...", "¡Tijera!"]:
		info_label.text = t
		animar_pulse(info_label)
		await get_tree().create_timer(0.35).timeout

func animar_pulse(n: CanvasItem) -> void:
	n.scale = Vector2.ONE
	var tw := create_tween()
	tw.tween_property(n, "scale", Vector2(1.08, 1.08), 0.10)
	tw.tween_property(n, "scale", Vector2.ONE, 0.10)

func animar_fade_label() -> void:
	info_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(info_label, "modulate:a", 0.2, 0.12)
	tw.tween_property(info_label, "modulate:a", 1.0, 0.12)

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
