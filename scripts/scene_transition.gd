extends CanvasLayer

@onready var fondo: ColorRect = $Fondo

@export var duracion: float = 0.5

var cambiando: bool = false


func _ready() -> void:
	# Mantener la transicion encima de todas las escenas
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Comenzar con la pantalla visible
	fondo.modulate.a = 0.0
	fondo.hide()


func cambiar_escena(ruta: String) -> void:
	if cambiando:
		return

	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		push_error("Escena no encontrada: " + ruta)
		return

	cambiando = true
	fondo.show()

	# Oscurecer la pantalla
	var salida = create_tween()
	salida.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	salida.tween_property(
		fondo,
		"modulate:a",
		1.0,
		duracion
	)

	await salida.finished

	# Cambiar de escena cuando todo esta negro
	get_tree().paused = false

	var error = get_tree().change_scene_to_file(ruta)

	if error != OK:
		push_error("No se pudo cambiar de escena")
		fondo.hide()
		fondo.modulate.a = 0.0
		cambiando = false
		return

	await get_tree().process_frame

	# Mostrar lentamente la nueva escena
	var entrada = create_tween()
	entrada.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	entrada.tween_property(
		fondo,
		"modulate:a",
		0.0,
		duracion
	)

	await entrada.finished

	fondo.hide()
	cambiando = false
