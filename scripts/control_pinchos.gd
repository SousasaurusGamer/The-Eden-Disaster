extends Node2D

# Escena del ataque que ya creamos
const ESCENA_PINCHOS = preload("res://scenes/boss/pinchos_suelo.tscn")

# Referencia al jefe
@export var jefe: Node2D

# Limites de la zona donde pueden aparecer
@export var limite_izquierdo: float = 60.0
@export var limite_derecho: float = 1092.0

# Altura del suelo
@export var altura_suelo: float = 590.0

# Tiempo entre ataques
@export var intervalo: float = 2.5

@onready var timer_ataques: Timer = $TimerAtaques


func _ready() -> void:
	timer_ataques.one_shot = true
	timer_ataques.timeout.connect(lanzar_ataque)

	# Primer ataque despues de 2 segundos
	timer_ataques.start(2.0)


func lanzar_ataque() -> void:
	# Detener ataques si el jefe murio
	if not is_instance_valid(jefe):
		timer_ataques.stop()
		return

	# Buscar a Steve
	var steve = get_tree().get_first_node_in_group("player")

	if steve != null:
		# Obtener su posicion
		var posicion_x: float = steve.global_position.x

		# Evitar ataques fuera del escenario
		posicion_x = clampf(
			posicion_x,
			limite_izquierdo,
			limite_derecho
		)

		# Crear el ataque
		var ataque = ESCENA_PINCHOS.instantiate()

		get_tree().current_scene.add_child(ataque)

		# Colocar los pinchos en el suelo
		ataque.global_position = Vector2(
			posicion_x,
			altura_suelo
		)

	# Preparar el siguiente ataque
	timer_ataques.start(intervalo)


func _process(_delta: float) -> void:
	if is_instance_valid(jefe) and jefe.get("fase") == 2:
		$TimerAtaques.stop()
