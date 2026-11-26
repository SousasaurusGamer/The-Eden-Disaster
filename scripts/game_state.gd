extends Node

var datos_notas: Dictionary = {}
var notas_encontradas: Array[String] = []
var health: int = 100
var ammo: int = 24
var municion_reserva: int = 0
var has_saved_stats: bool = false


# SISTEMA DE MEJORAS POR MUERTE

var puntos_mejora: int = 0

var mejoras_vida: int = 0
var mejoras_dano: int = 0
var mejoras_recarga: int = 0

var muerte_registrada: bool = false


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


func registrar_muerte() -> void:
	if muerte_registrada:
		return

	muerte_registrada = true
	puntos_mejora += 1


func comenzar_intento() -> void:
	muerte_registrada = false


func comprar_mejora(tipo: String) -> bool:
	if puntos_mejora <= 0:
		return false

	match tipo:
		"vida":
			if mejoras_vida >= 5:
				return false

			mejoras_vida += 1

		"dano":
			if mejoras_dano >= 3:
				return false

			mejoras_dano += 1

		"recarga":
			if mejoras_recarga >= 3:
				return false

			mejoras_recarga += 1

		_:
			return false

	puntos_mejora -= 1
	return true
