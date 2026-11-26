extends CharacterBody2D

const CAJA_MUNICION = preload(
	"res://scenes/player/ammo_pickup.tscn"
)

@export_range(0.0, 1.0, 0.05)
var probabilidad_municion: float = 0.60

@export var max_health: int = 30
@export var move_speed: float = 65.0
@export var attack_range: float = 36.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var attack_height: float = 20.0

var health: int
var attack_timer: float = 0.0
var player: CharacterBody2D
var derrotado: bool = false

func _ready() -> void:
	# Registrar al enemigo para las colisiones y ataques
	add_to_group("enemies")

	health = max_health
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	print("Enemigo registrado en grupo enemies")


func _physics_process(delta: float) -> void:
	attack_timer = maxf(attack_timer - delta, 0.0)

	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = 0.0

	# Buscar a Steve si es necesario
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if is_instance_valid(player):
		var distance_x = player.global_position.x - global_position.x
		var distance_y = absf(player.global_position.y - global_position.y)

		# Perseguir a Steve
		if absf(distance_x) > attack_range:
			velocity.x = signf(distance_x) * move_speed

		# Atacar solo si esta cerca en X y en Y
		elif distance_y <= attack_height and attack_timer <= 0.0:
			attack_timer = attack_cooldown

			if player.has_method("take_damage"):
				player.take_damage(attack_damage)

	move_and_slide()


func soltar_municion() -> void:
	if randf() > probabilidad_municion:
		return

	var caja = CAJA_MUNICION.instantiate()

	get_tree().current_scene.add_child(caja)

	caja.global_position = global_position + Vector2(0, -12)

	print("El enemigo solto municion")



func take_damage(amount: int) -> void:
	if derrotado:
		return

	health -= amount
	print("Vida del enemigo: ", health)

	if health <= 0:
		derrotado = true
		print("Enemigo derrotado")

		soltar_municion()
		queue_free()
