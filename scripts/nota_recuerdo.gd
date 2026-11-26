extends Area2D

@export var id_nota: String = "nota_001"
@export var titulo_nota: String = "ARCHIVO 001 - PROYECTO EDEN"

@export_multiline var contenido: String = "Elena y yo comenzamos el experimento..."

@export var imagen_recuerdo: Texture2D

@onready var aviso: Label = $Aviso

@export_multiline var pensamiento_steve: String = ""

var jugador_cerca: bool = false


func _ready() -> void:
	aviso.hide()

	body_entered.connect(jugador_entra)
	body_exited.connect(jugador_sale)

	# No mostrar notas que ya fueron recogidas
	if GameState.notas_encontradas.has(id_nota):
		queue_free()


func jugador_entra(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true
		aviso.show()


func jugador_sale(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false
		aviso.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not jugador_cerca:
		return

	if get_tree().paused:
		return

	if event.is_action_pressed("interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		recoger_nota()


func recoger_nota() -> void:
	if GameState.notas_encontradas.has(id_nota):
		return


	GameState.datos_notas[id_nota] = {
		"titulo": titulo_nota,
		"texto": contenido,
		"imagen": imagen_recuerdo
	}

	GameState.notas_encontradas.append(id_nota)
	
	PantallaRecuerdo.call_deferred(
		"mostrar_recuerdo",
		titulo_nota,
		contenido,
		imagen_recuerdo,
		pensamiento_steve
	)

	queue_free()
