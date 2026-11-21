
extends CharacterBody2D

@onready var golpe_visual: ColorRect = $AttackHitbox/GolpeVisual
@onready var golpe_colision: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var weapon_pivot: Node2D = $WeaponPivot
@export var max_health: int = 100
@onready var muzzle: Marker2D = $WeaponPivot/Muzzle
@export var max_ammo: int = 12

const BULLET_SCENE = preload("res://scenes/player/bullet.tscn")

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

var charge_time = 0.0
var is_charging = false

func _ready() -> void:
	add_to_group("player")

	if GameState.has_saved_stats:
		health = clampi(GameState.health, 1, max_health)
		ammo = clampi(GameState.ammo, 0, max_ammo)
	else:
		health = max_health
		ammo = max_ammo

	print("Vida de Steve: ", health)
	print("Municion de Steve: ", ammo)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

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
	if Input.is_action_just_pressed("shoot") and roll_time <= 0.0 and ammo > 0:
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
		get_tree().call_deferred("reload_current_scene")




func shoot(charged: bool = false) -> void:
	if ammo <= 0:
		print("Sin municion")
		return

	# Si no hay 3 balas, disparar normalmente
	if charged and ammo < CHARGED_AMMO_COST:
		charged = false

	var bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position
	bullet.global_rotation = weapon_pivot.global_rotation
	bullet.direction = Vector2.RIGHT.rotated(weapon_pivot.global_rotation)

	if charged:
		bullet.damage = 30
		bullet.speed = 450.0
		bullet.scale = Vector2(1.8, 1.8)
		ammo -= CHARGED_AMMO_COST
		print("Disparo cargado!")
	else:
		bullet.damage = 10
		ammo -= 1
		print("Disparo normal")

	print("Municion restante: ", ammo)


func add_ammo(amount: int) -> bool:
	if ammo >= max_ammo:
		print("Municion completa")
		return false
	
	ammo = mini(ammo + amount, max_ammo)

	print("Municion recogida: ", ammo, "/", max_ammo)
	return true
