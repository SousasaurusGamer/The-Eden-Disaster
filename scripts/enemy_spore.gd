
extends Area2D
class_name EnemySpore

@export var speed: float = 200.0
@export var damage: int = 10

var direction: Vector2 = Vector2.LEFT
var lifetime: float = 5.0

@onready var visual: ColorRect = $ColorRect


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	visual.color = Color("#E5B94E")


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()


# Cuando toca a Steve
func _on_body_entered(body: Node2D) -> void:
	print("Espora toca: ", body.name)

	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()

	elif body is StaticBody2D:
		queue_free()


# Cuando una bala de Steve toca la espora
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullets"):
		print("Espora destruida por una bala")
		area.queue_free()
		queue_free()
