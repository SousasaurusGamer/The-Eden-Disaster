extends Control

@export_file("*.tscn") var escena_primer_nivel: String

@onready var boton_jugar: Button = $Centro/Opciones/BotonJugar
@onready var boton_controles: Button = $Centro/Opciones/BotonControles
@onready var boton_salir: Button = $Centro/Opciones/BotonSalir

@onready var pantalla_controles: Control = $PantallaControles
@onready var boton_volver: Button = $PantallaControles/CentroControles/OpcionesControles/BotonVolver


func _ready() -> void:
	get_tree().paused = false

	pantalla_controles.hide()

	boton_jugar.pressed.connect(jugar)
	boton_controles.pressed.connect(mostrar_controles)
	boton_salir.pressed.connect(salir)
	boton_volver.pressed.connect(volver)


func jugar() -> void:
	if escena_primer_nivel.is_empty():
		push_warning("Selecciona el primer nivel en el Inspector")
		return

	# Comenzar una partida nueva
	GameState.has_saved_stats = false
	GameState.health = 100
	GameState.ammo = 24
	GameState.municion_reserva = 0

	GameState.notas_encontradas.clear()
	GameState.datos_notas.clear()
	SceneTransition.cambiar_escena(escena_primer_nivel)


func mostrar_controles() -> void:
	pantalla_controles.show()


func volver() -> void:
	pantalla_controles.hide()


func salir() -> void:
	get_tree().quit()
