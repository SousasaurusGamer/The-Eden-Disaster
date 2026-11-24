extends Area2D

@export var velocidad: float = 170.0
@export var dano_veneno: int = 2

var direccion: Vector2 = Vector2.LEFT
var tiempo_vida: float = 0.0
var impacto: bool = false


func _ready() -> void:
	monitoring = true
	collision_layer = 0
	collision_mask = 1

	body_entered.connect(golpear_jugador)


func _physics_process(delta: float) -> void:
	# Mover el proyectil
	global_position += direccion.normalized() * velocidad * delta

	# Destruirlo si no golpea a nadie
	tiempo_vida += delta

	if tiempo_vida >= 6.0:
		queue_free()


func golpear_jugador(body: Node2D) -> void:
	if impacto:
		return

	if not body.is_in_group("player"):
		return

	impacto = true

	# Evitar que se acumulen varios venenos
	if body.has_meta("veneno_activo"):
		queue_free()
		return

	body.set_meta("veneno_activo", true)

	# Ocultar la bola al impactar
	hide()
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)

	print("Steve ha sido envenenado")

	# Aplicar dano una vez por segundo
	for i in range(3):
		await get_tree().create_timer(1.0).timeout

		if not is_instance_valid(body):
			break

		if body.has_method("take_damage"):
			body.take_damage(dano_veneno)

	# Terminar el efecto
	if is_instance_valid(body):
		body.remove_meta("veneno_activo")

	print("El veneno ha terminado")
	queue_free()
