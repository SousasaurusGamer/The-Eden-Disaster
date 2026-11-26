extends Area2D

@export var nombre_npc: String = "Mara"
@export_multiline var dialogo: String = "Hello, steve."

var jugador_cerca: bool = false


func _ready() -> void:
	body_entered.connect(jugador_entra)
	body_exited.connect(jugador_sale)


func jugador_entra(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true
		print("Press E to talk to ", nombre_npc)


func jugador_sale(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false


func _unhandled_input(event: InputEvent) -> void:
	if not jugador_cerca:
		return

	if DialogoNPC.abierto:
		return

	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()

		DialogoNPC.call_deferred(
			"iniciar_dialogo",
			nombre_npc,
			dialogo
		)
