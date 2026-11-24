extends StaticBody2D

const ESCENA_VENENO = preload("res://scenes/boss/proyectil_venenoso.tscn")
const VICTORY_SCENE = preload("res://scenes/ui/pantalla_victoria.tscn")


@export var vida_maxima: int = 200
@onready var punto_disparo: Marker2D = $PuntoDisparo
@onready var timer_veneno: Timer = $TemporizadorAtaque

var vida_actual: int
var fase: int = 1
var derrotado: bool = false

func _ready() -> void:
	add_to_group("enemies")
	vida_actual = vida_maxima
	print("¡Jefe final activado!")

	timer_veneno.one_shot = true
	timer_veneno.timeout.connect(disparar_veneno)
	timer_veneno.start(3.5)



func take_damage(dano: int) -> void:
	vida_actual = maxi(vida_actual - dano, 0)

	print("Vida del jefe: ", vida_actual, "/", vida_maxima)

	if vida_actual <= vida_maxima / 2.0 and fase == 1:

		cambiar_fase()

	if vida_actual <= 0:
		morir()


func cambiar_fase() -> void:
	fase = 2
	print("FASE 2 la planta esta furiosa")


func morir() -> void:
	if derrotado:
		return

	derrotado = true

	print("¡Jefe final derrotado!")

	# Mostrar pantalla de victoria
	var pantalla_victoria = VICTORY_SCENE.instantiate()
	get_tree().current_scene.add_child(pantalla_victoria)

	# Eliminar al jefe derrotado
	queue_free()



func disparar_veneno() -> void:
	var steve = get_tree().get_first_node_in_group("player")

	if steve != null:
		# Crear el proyectil
		var bola = ESCENA_VENENO.instantiate()
		get_tree().current_scene.add_child(bola)

		# Colocarlo en la boca de la planta
		bola.global_position = punto_disparo.global_position

		# Apuntar hacia la posicion actual de Steve
		var direccion_disparo = (
			steve.global_position - punto_disparo.global_position
		).normalized()

		bola.set("direccion", direccion_disparo)

		# Aumentar velocidad en fase 2
		if fase == 2:
			bola.set("velocidad", 230.0)
		else:
			bola.set("velocidad", 170.0)

		print("La planta lanza veneno")

	# Preparar el siguiente disparo
	if fase == 2:
		timer_veneno.start(2.5)
	else:
		timer_veneno.start(4.0)
