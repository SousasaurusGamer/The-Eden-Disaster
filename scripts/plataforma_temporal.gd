extends AnimatableBody2D

@export var jefe: Node2D

@onready var visual: Node2D = $Visual
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var detector: Area2D = $DetectorJugador
@onready var timer_desaparicion: Timer = $TimerDesaparicion
@onready var timer_regreso: Timer = $TimerRegreso

var cuenta_iniciada: bool = false
var desaparecida: bool = false
var activada: bool = false


func _ready() -> void:
	add_to_group("plataformas_temporales")
	timer_desaparicion.one_shot = true
	timer_regreso.one_shot = true

	detector.body_entered.connect(detectar_jugador)
	timer_desaparicion.timeout.connect(desaparecer)
	timer_regreso.timeout.connect(reaparecer)

	if jefe == null:
		jefe = get_parent().get_node_or_null("JefePlanta")

	visual.hide()
	colision.set_deferred("disabled", true)
	detector.set_deferred("monitoring", false)


func _process(_delta: float) -> void:
	if not activada:
		if is_instance_valid(jefe) and jefe.get("fase") == 2:
			activar_plataforma()
		return

	if cuenta_iniciada and not desaparecida:
		if timer_desaparicion.time_left <= 1.0:
			var parpadeo = int(Time.get_ticks_msec() / 150) % 2

			if parpadeo == 0:
				visual.modulate.a = 0.4
			else:
				visual.modulate.a = 1.0


func detectar_jugador(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if cuenta_iniciada or desaparecida:
		return

	if body is CharacterBody2D and body.velocity.y < 0:
		return

	cuenta_iniciada = true
	timer_desaparicion.start(3.0)

	print("La plataforma comienza a romperse")



func desaparecer() -> void:
	var otra_disponible: bool = false

	# Buscar otras plataformas activas
	for plataforma in get_tree().get_nodes_in_group("plataformas_temporales"):
		if plataforma == self:
			continue

		if plataforma.get("activada") == true and plataforma.get("desaparecida") == false:
			otra_disponible = true
			break

	# Si es la ultima plataforma, no desaparecer
	if not otra_disponible:
		visual.modulate.a = 1.0
		timer_desaparicion.start(1.0)
		print("Esperando que otra plataforma regrese")
		return

	# Desaparicion normal
	desaparecida = true

	visual.hide()
	colision.set_deferred("disabled", true)
	detector.set_deferred("monitoring", false)

	timer_regreso.start(3.0)

	print("Plataforma desaparecida")


func reaparecer() -> void:
	visual.show()
	visual.modulate.a = 1.0

	colision.set_deferred("disabled", false)
	detector.set_deferred("monitoring", true)

	cuenta_iniciada = false
	desaparecida = false


func activar_plataforma() -> void:
	activada = true

	visual.show()
	visual.modulate.a = 1.0

	colision.set_deferred("disabled", false)
	detector.set_deferred("monitoring", true)

	print("Plataforma activada - Fase 2")
