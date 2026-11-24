extends Node2D

const ESCENA_PINCHOS = preload("res://scenes/boss/pinchos_suelo.tscn")

@export var jefe: Node2D

@export var limite_izquierdo: float = 100.0
@export var limite_derecho: float = 1100.0
@export var altura_suelo: float = 580.0

@onready var timer: Timer = $TimerAleatorio


func _ready() -> void:
	timer.one_shot = true
	timer.timeout.connect(crear_ataque_aleatorio)
	timer.start(3.0)


func crear_ataque_aleatorio() -> void:
	# Comprobar que el jefe sigue vivo
	if not is_instance_valid(jefe):
		timer.stop()
		return

	# Consultar la fase actual del jefe
	var fase_2: bool = jefe.fase == 2

	var cantidad: int = 1
	var tiempo_minimo: float = 4.0
	var tiempo_maximo: float = 6.0

	# Aumentar ataques durante la fase 2
	if fase_2:
		cantidad = 2
		tiempo_minimo = 2.5
		tiempo_maximo = 3.5

	# Crear los ataques
	var primera_posicion: float = 0.0

	for i in range(cantidad):
		var posicion_x: float = randf_range(
			limite_izquierdo,
			limite_derecho
		)

		# Separar los dos ataques en fase 2
		if i == 0:
			primera_posicion = posicion_x
		else:
			var distancia: float = randf_range(180.0, 300.0)
			posicion_x = primera_posicion + distancia

			if posicion_x > limite_derecho:
				posicion_x = primera_posicion - distancia

			posicion_x = clampf(
				posicion_x,
				limite_izquierdo,
				limite_derecho
			)

		var ataque = ESCENA_PINCHOS.instantiate()
		get_tree().current_scene.add_child(ataque)

		ataque.global_position = Vector2(
			posicion_x,
			altura_suelo
		)

	# Programar el siguiente ataque
	var siguiente_tiempo: float = randf_range(
		tiempo_minimo,
		tiempo_maximo
	)

	timer.start(siguiente_tiempo)


func _process(_delta: float) -> void:
	if is_instance_valid(jefe) and jefe.get("fase") == 2:
		$TimerAleatorio.stop()
