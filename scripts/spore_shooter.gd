
extends StaticBody2D

const CAJA_MUNICION = preload(
	"res://scenes/player/ammo_pickup.tscn"
)

const SPORE_SCENE = preload("res://scenes/enemies/enemy_spore.tscn")

# Configuracion del enemigo
@export var max_health: int = 40
@export var shoot_interval: float = 2.0

# Referencias
@onready var muzzle: Marker2D = $Muzzle

@export_range(0.0, 1.0, 0.05)
var probabilidad_municion: float = 0.10

# Variables
var health: int
var shoot_timer: float = 1.0
var is_dead: bool = false



func _ready() -> void:
	add_to_group("enemies")
	health = max_health

	print("Planta lanzadora lista. Vida: ", health)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	shoot_timer -= delta

	if shoot_timer > 0.0:
		return

	var player = get_tree().get_first_node_in_group("player") as Node2D

	if not is_instance_valid(player):
		return

	shoot_timer = shoot_interval
	shoot(player)


func shoot(player: Node2D) -> void:
	var spore: EnemySpore = SPORE_SCENE.instantiate() as EnemySpore

	get_tree().current_scene.add_child(spore)

	spore.global_position = muzzle.global_position

	var target_position = player.global_position + Vector2(0, -20)

	spore.direction = (
		target_position - spore.global_position
	).normalized()

	print("Planta lanzadora disparo una espora")


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health = maxi(health - amount, 0)

	print("Vida de planta lanzadora: ", health)

	if health <= 0:
		die()


func soltar_municion() -> void:
	if randf() > probabilidad_municion:
		return

	var caja = CAJA_MUNICION.instantiate()

	get_tree().current_scene.add_child(caja)

	caja.global_position = global_position + Vector2(0, -12)

	print("El enemigo solto municion")


func die() -> void:
	if is_dead:
		return

	is_dead = true
	print("Planta lanzadora derrotada")

	# Intentar soltar municion
	soltar_municion()

	# Eliminar la planta
	queue_free()
