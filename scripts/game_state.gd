extends Node

var health: int = 100
var ammo: int = 24
var municion_reserva: int = 0
var has_saved_stats: bool = false


func save_player(player: Node) -> void:
	# Guardar la vida
	health = int(player.get("health"))

	# Guardar las balas principales
	ammo = int(player.get("ammo"))

	# Guardar las balas almacenadas
	municion_reserva = int(player.get("municion_reserva"))

	has_saved_stats = true

	print("Datos guardados:")
	print("Vida: ", health)
	print("Cargador: ", ammo)
	print("Reserva: ", municion_reserva)
