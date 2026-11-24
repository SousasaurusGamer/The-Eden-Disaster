extends CanvasLayer

@export_file("*.tscn") var escena_menu: String

@onready var boton_reintentar: Button = $Pantalla/Centro/Opciones/BotonReintentar
@onready var boton_menu: Button = $Pantalla/Centro/Opciones/BotonMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10

	boton_reintentar.pressed.connect(volver_a_jugar)
	boton_menu.pressed.connect(volver_menu)

	# Pausar el juego al ganar
	get_tree().paused = true

	print("VICTORY! Steve ha ganado")


func volver_a_jugar() -> void:
	get_tree().paused = false

	GameState.has_saved_stats = false

	SceneTransition.cambiar_escena(
		get_tree().current_scene.scene_file_path
	)


func volver_menu() -> void:
	if escena_menu.is_empty():
		push_warning("Falta asignar el menu principal.")
		return

	get_tree().paused = false

	GameState.has_saved_stats = false

	SceneTransition.cambiar_escena(escena_menu)
