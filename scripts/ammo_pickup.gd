extends Area2D

@export var ammo_amount: int = 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("add_ammo"):
			var collected = body.add_ammo(ammo_amount)

			if collected:
				queue_free()