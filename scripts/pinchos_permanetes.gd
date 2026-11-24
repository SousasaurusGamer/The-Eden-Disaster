extends Area2D

@export var jefe: Node2D
@export var dano: int = 8
@export var tiempo_aviso: float = 3.5
@export var intervalo_dano: float = 1.5

@onready var aviso: ColorRect = $AvisoVisual
@onready var pinchos: Polygon2D = $PinchosVisual
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var timer_aviso: Timer = $TimerAviso

var activos: bool = false
var tiempo_espera: float = 0.0


func _ready() -> void:
	monitoring = true
	collision_layer = 0
	collision_mask = 1

	aviso.show()
	pinchos.hide()
	colision.disabled = true

	timer_aviso.one_shot = true
	timer_aviso.timeout.connect(activar_pinchos)
	timer_aviso.start(tiempo_aviso)


func activar_pinchos() -> void:
	aviso.hide()
	pinchos.show()

	colision.set_deferred("disabled", false)
	activos = true

	print("Pinchos permanentes activados")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(jefe):
		queue_free()
		return

	if not activos:
		return

	if tiempo_espera > 0.0:
		tiempo_espera -= delta
		return

	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("player"):
			if cuerpo.has_method("take_damage"):
				cuerpo.take_damage(dano)
				tiempo_espera = intervalo_dano
				break
