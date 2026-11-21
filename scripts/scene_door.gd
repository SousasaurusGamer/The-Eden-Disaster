
extends Area2D

@export_file("*.tscn") var destination_scene: String

var player_near: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("interact"):
		if destination_scene.is_empty():
			return

		var player = get_tree().get_first_node_in_group("player")

		if player != null:
			GameState.save_player(player)

		player_near = false
		get_tree().change_scene_to_file.call_deferred(destination_scene)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		print("Presiona E para entrar o salir")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
