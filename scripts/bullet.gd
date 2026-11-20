extends Area2D

@export var speed: float = 600.0
@export var damage: int = 10

var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 1.5


func _ready() -> void:
	add_to_group("player_bullets")
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		return

	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

	queue_free()
