
extends CanvasLayer

@export_file("*.tscn") var escena_menu: String

@onready var boton_reintentar: Button = $Pantalla/Centro/Opciones/BotonReintentar
@onready var boton_menu: Button = $Pantalla/Centro/Opciones/BotonMenu

# Botones de mejoras
@onready var puntos: Label = $Pantalla/Centro/Opciones/Mejoras/Puntos
@onready var boton_vida: Button = $Pantalla/Centro/Opciones/Mejoras/BotonVida
@onready var boton_dano: Button = $Pantalla/Centro/Opciones/Mejoras/BotonDano
@onready var boton_recarga: Button = $Pantalla/Centro/Opciones/Mejoras/BotonRecarga


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10

	# Registrar una muerte y entregar un punto
	GameState.registrar_muerte()

	# Botones originales
	boton_reintentar.pressed.connect(reintentar)
	boton_menu.pressed.connect(volver_menu)

	# Botones de mejoras
	boton_vida.pressed.connect(
		comprar_mejora.bind("vida")
	)

	boton_dano.pressed.connect(
		comprar_mejora.bind("dano")
	)

	boton_recarga.pressed.connect(
		comprar_mejora.bind("recarga")
	)

	actualizar_mejoras()

	get_tree().paused = true


func actualizar_mejoras() -> void:
	puntos.text = "UPGRADE POINTS: %d" % GameState.puntos_mejora

	boton_vida.text = "HEALTH +10 HP  |  LVL %d/5" % GameState.mejoras_vida

	boton_dano.text = "DAMAGE +5%%  |  LVL %d/3" % GameState.mejoras_dano

	boton_recarga.text = "RELOAD -0.1s  |  LVL %d/3" % GameState.mejoras_recarga

	var sin_puntos: bool = GameState.puntos_mejora <= 0

	boton_vida.disabled = sin_puntos or GameState.mejoras_vida >= 5
	boton_dano.disabled = sin_puntos or GameState.mejoras_dano >= 3
	boton_recarga.disabled = sin_puntos or GameState.mejoras_recarga >= 3


func comprar_mejora(tipo: String) -> void:
	if GameState.comprar_mejora(tipo):
		print("Mejora comprada: ", tipo)

	actualizar_mejoras()


func reintentar() -> void:
	get_tree().paused = false

	# Reiniciar las estadísticas temporales
	GameState.has_saved_stats = false

	# Permitir registrar otra muerte
	GameState.comenzar_intento()

	SceneTransition.cambiar_escena(
		get_tree().current_scene.scene_file_path
	)


func volver_menu() -> void:
	if escena_menu.is_empty():
		push_warning("Falta asignar la escena del menu.")
		return

	get_tree().paused = false
	GameState.has_saved_stats = false
	GameState.comenzar_intento()

	SceneTransition.cambiar_escena(escena_menu)
