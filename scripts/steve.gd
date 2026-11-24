
extends CharacterBody2D

@onready var golpe_visual: ColorRect = $AttackHitbox/GolpeVisual
@onready var golpe_colision: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var weapon_pivot: Node2D = $WeaponPivot
@export var max_health: int = 100
@onready var muzzle: Marker2D = $WeaponPivot/Muzzle
@export var max_ammo: int = 24
@export var reserva_maxima: int = 96
@export var intervalo_disparo: float = 0.5

const BULLET_SCENE = preload("res://scenes/player/bullet.tscn")
const DEFEAT_SCENE = preload("res://scenes/ui/pantalla_derrota.tscn")


# Movimiento
const SPEED = 200.0
const JUMP_FORCE = -500.0

const CHARGE_TIME = 0.8
const CHARGED_AMMO_COST = 3


# Rodada
const ROLL_SPEED = 330.0
const ROLL_DURATION = 0.28
const ROLL_COOLDOWN = 0.85

# Ataque
const ATTACK_DAMAGE = 10
const ATAQUE_DURACION = 0.15
const ATAQUE_RECARGA = 0.4

# Variables de movimiento
var facing_direction = 1.0
var roll_direction = 1.0
var roll_time = 0.0
var roll_cooldown = 0.0

# Variables del ataque
var ataque_tiempo = 0.0
var ataque_recarga = 0.0
var enemigos_golpeados: Array[Node2D] = []

# Vida
var health: int = 100
var is_dead: bool = false

var ammo: int = 12
var municion_reserva: int = 0
var recargando: bool = false

var charge_time = 0.0
var is_charging = false
var tiempo_disparo: float = 0.0

func _ready() -> void:
	add_to_group("player")

	if GameState.has_saved_stats:
		health = clampi(GameState.health, 1, max_health)
		ammo = clampi(GameState.ammo, 0, max_ammo)
		municion_reserva = clampi(GameState.municion_reserva, 0, reserva_maxima)
	else:
		health = max_health
		ammo = max_ammo
		municion_reserva = 0

	print("Vida de Steve: ", health)
	print("Municion de Steve: ", ammo)
	print("Municion de reserva: ", municion_reserva)
	

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Reducir el tiempo de espera entre disparos
	tiempo_disparo = maxf(tiempo_disparo - delta, 0.0)

	# Actualizar temporizadores
	var estaba_rodando = roll_time > 0.0

	roll_time = maxf(roll_time - delta, 0.0)
	roll_cooldown = maxf(roll_cooldown - delta, 0.0)

	# Restaurar colisiones al terminar la rodada
	if estaba_rodando and roll_time <= 0.0:
		set_enemy_collision_ignored(false)

	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Movimiento horizontal
	var direction = Input.get_axis("move_left", "move_right")

	# Mirar hacia el mouse cuando no rueda
	if roll_time <= 0.0:
		var mouse_position = get_global_mouse_position()

		if mouse_position.x > global_position.x:
			facing_direction = 1.0
		elif mouse_position.x < global_position.x:
			facing_direction = -1.0

	# Comenzar rodada
	if Input.is_action_just_pressed("roll") and is_on_floor() and roll_cooldown <= 0.0 and roll_time <= 0.0:
		roll_time = ROLL_DURATION
		roll_cooldown = ROLL_COOLDOWN

		# Priorizar la direccion de movimiento
		if absf(direction) > 0.01:
			roll_direction = signf(direction)
		else:
			roll_direction = facing_direction

		set_enemy_collision_ignored(true)
		print("Rodando en direccion: ", roll_direction)

	# Aplicar movimiento o rodada
	if roll_time > 0.0:
		velocity.x = roll_direction * ROLL_SPEED
		visual.scale.x = roll_direction
	else:
		velocity.x = direction * SPEED
		visual.scale.x = facing_direction

	# Apuntar la pistola hacia el mouse
	weapon_pivot.look_at(get_global_mouse_position())

	# Temporizadores de ataque
	ataque_tiempo = maxf(ataque_tiempo - delta, 0.0)
	ataque_recarga = maxf(ataque_recarga - delta, 0.0)

	# Ataque cuerpo a cuerpo
	if Input.is_action_just_pressed("attack_melee") and ataque_recarga <= 0.0 and roll_time <= 0.0:
		ataque_tiempo = ATAQUE_DURACION
		ataque_recarga = ATAQUE_RECARGA

		golpe_colision.position.x = 28.0 * facing_direction
		golpe_visual.position.x = golpe_colision.position.x - 14.0

		enemigos_golpeados.clear()
		print("Steve esta atacando")

	# Activar efecto y detectar golpes
	golpe_visual.visible = ataque_tiempo > 0.0

	if ataque_tiempo > 0.0:
		deal_damage()

	
	# Iniciar carga al presionar el mouse
	
	if Input.is_action_just_pressed("shoot") and roll_time <= 0.0 and not recargando and tiempo_disparo <= 0.0 and (ammo > 0 or municion_reserva > 0):
		is_charging = true
		charge_time = 0.0

	# Acumular tiempo mientras mantiene presionado
	if is_charging and Input.is_action_pressed("shoot"):
		charge_time += delta

	# Disparar solamente cuando suelta el mouse
	if Input.is_action_just_released("shoot") and is_charging:
		is_charging = false

		if roll_time <= 0.0:
			var charged = charge_time >= CHARGE_TIME
			shoot(charged)

		charge_time = 0.0

	# Aplicar movimiento fisico
	move_and_slide()


func deal_damage() -> void:
	var cuerpos = $AttackHitbox.get_overlapping_bodies()

	for body in cuerpos:
		if body == self:
			continue

		if body.is_in_group("enemies") and body.has_method("take_damage") and not enemigos_golpeados.has(body):
			enemigos_golpeados.append(body)
			body.take_damage(ATTACK_DAMAGE)
			print("Enemigo golpeado: ", body.name)


func set_enemy_collision_ignored(ignored: bool) -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is PhysicsBody2D:
			var enemy: PhysicsBody2D = node

			if ignored:
				add_collision_exception_with(enemy)
				enemy.add_collision_exception_with(self)
			else:
				remove_collision_exception_with(enemy)
				enemy.remove_collision_exception_with(self)


func take_damage(amount: int) -> void:
	if is_dead:
		return

	# Invulnerabilidad durante la rodada
	if roll_time > 0.0:
		print("Steve esquivo el ataque")
		return

	# Restar vida
	health = maxi(health - amount, 0)
	print("Vida de Steve: ", health, "/", max_health)

	# Morir solamente cuando la vida llegue a cero
	if health <= 0:
		is_dead = true
		print("Steve ha muerto")

		GameState.has_saved_stats = false

		# Crear la pantalla de derrota
		var pantalla_derrota = DEFEAT_SCENE.instantiate()
		get_tree().current_scene.add_child(pantalla_derrota)





func shoot(charged: bool = false) -> void:
	# No disparar si estamos recargando o esperando
	if recargando or tiempo_disparo > 0.0:
		return

	# Comprobar si quedan balas
	if ammo <= 0:
		recargar_automaticamente()
		return

	# Si no hay 3 balas, disparar normalmente
	if charged and ammo < CHARGED_AMMO_COST:
		charged = false

	# Crear la bala
	var bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position
	bullet.global_rotation = weapon_pivot.global_rotation
	bullet.direction = Vector2.RIGHT.rotated(
		weapon_pivot.global_rotation
	)

	# Disparo cargado
	if charged:
		bullet.damage = 30
		bullet.speed = 450.0
		bullet.scale = Vector2(1.8, 1.8)

		ammo -= CHARGED_AMMO_COST
		print("Disparo cargado!")

	# Disparo normal
	else:
		bullet.damage = 10
		ammo -= 1
		print("Disparo normal")

	# IMPORTANTE: reiniciar el tiempo entre disparos
	tiempo_disparo = intervalo_disparo

	print("Municion restante: ", ammo)
	print("Proximo disparo en: ", intervalo_disparo, " segundos")

	# Recargar cuando se agote el cargador
	if ammo == 0:
		recargar_automaticamente()



func add_ammo(amount: int) -> bool:
	if amount <= 0:
		return false

	var municion_anterior: int = ammo + municion_reserva

	# Primero llenar el cargador principal
	var espacio_cargador: int = max_ammo - ammo
	var cantidad_cargador: int = mini(amount, espacio_cargador)

	ammo += cantidad_cargador

	# Guardar las balas sobrantes
	var sobrante: int = amount - cantidad_cargador

	var espacio_reserva: int = reserva_maxima - municion_reserva
	var cantidad_reserva: int = mini(sobrante, espacio_reserva)

	municion_reserva += cantidad_reserva

	print("Cargador: ", ammo, "/", max_ammo)
	print("Reserva: ", municion_reserva, "/", reserva_maxima)

	return ammo + municion_reserva > municion_anterior



func recargar_automaticamente() -> void:
	if recargando:
		return

	if ammo > 0 or municion_reserva <= 0:
		return

	if is_dead:
		return

	recargando = true
	print("Steve esta recargando...")

	# Esperar 2 segundos
	await get_tree().create_timer(2.0).timeout

	if not is_inside_tree() or is_dead:
		return

	# Pasar las balas de reserva al cargador
	var cantidad: int = mini(
		max_ammo - ammo,
		municion_reserva
	)

	ammo += cantidad
	municion_reserva -= cantidad

	recargando = false

	print("Recarga terminada")
	print("Balas principales: ", ammo, "/", max_ammo)
	print("Balas guardadas: ", municion_reserva)
