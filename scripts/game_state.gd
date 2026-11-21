extends Node

var health: int = 100
var ammo: int = 12
var has_saved_stats: bool = false


func save_player(player: Node) -> void:
	health = int(player.get("health"))
	ammo = int(player.get("ammo"))
	has_saved_stats = true

	print("Datos guardados: ", health, " HP, ", ammo, " balas")
