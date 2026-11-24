extends CanvasLayer

@export_file("*.tscn") var escena_menu: String

@onready var boton_reintentar: Button = $Pantalla/Centro/Opciones/BotonReintentar
@onready var boton_menu: Button = $Pantalla/Centro/Opciones/BotonMenu


func _ready() -> void:
	# Permitir utilizar los botones con el juego pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10

	boton_reintentar.pressed.connect(reintentar)
	boton_menu.pressed.connect(volver_menu)

	# Pausar el nivel
	get_tree().paused = true


func reintentar() -> void:
	get_tree().paused = false

	# Empezar de nuevo sin las estadisticas guardadas
	GameState.has_saved_stats = false

	SceneTransition.cambiar_escena(
		get_tree().current_scene.scene_file_path
	)

func volver_menu() -> void:
	if escena_menu.is_empty():
		push_warning("Falta asignar la escena del menu.")
		return

	get_tree().paused = false
	GameState.has_saved_stats = false

	SceneTransition.cambiar_escena(escena_menu)
