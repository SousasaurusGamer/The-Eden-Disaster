extends Area2D

@export var dano: int = 8

@onready var aviso: ColorRect = $AvisoVisual
@onready var pinchos: Polygon2D = $PinchosVisual
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var timer_aviso: Timer = $TimerAviso
@onready var timer_activo: Timer = $TimerActivo


func _ready() -> void:
	monitoring = true
	collision_layer = 0
	collision_mask = 1

	aviso.visible = true
	pinchos.visible = false
	colision.disabled = true

	timer_aviso.one_shot = true
	timer_activo.one_shot = true

	timer_aviso.timeout.connect(activar_pinchos)
	timer_activo.timeout.connect(desaparecer)
	body_entered.connect(golpear_jugador)

	timer_aviso.start(1.0)


func activar_pinchos() -> void:
	aviso.visible = false
	pinchos.visible = true

	colision.set_deferred("disabled", false)
	timer_activo.start(0.8)

	await get_tree().physics_frame

	for cuerpo in get_overlapping_bodies():
		golpear_jugador(cuerpo)


func golpear_jugador(body: Node2D) -> void:
	if not pinchos.visible:
		return

	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(dano)


func desaparecer() -> void:
	queue_free()
