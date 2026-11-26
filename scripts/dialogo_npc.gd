extends CanvasLayer

@onready var cuadro: Panel = $Cuadro
@onready var nombre_label: Label = $Cuadro/Nombre
@onready var texto_label: Label = $Cuadro/Texto

var lineas: PackedStringArray
var indice: int = 0
var abierto: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	cuadro.hide()


func iniciar_dialogo(nombre_npc: String, contenido: String) -> void:
	if abierto:
		return

	lineas = contenido.split("\n", false)

	if lineas.is_empty():
		return

	abierto = true
	indice = 0

	nombre_label.text = nombre_npc
	cuadro.show()
	mostrar_linea()

	get_tree().paused = true


func mostrar_linea() -> void:
	texto_label.text = lineas[indice]


func _unhandled_input(event: InputEvent) -> void:
	if not abierto:
		return

	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()

		indice += 1

		if indice >= lineas.size():
			terminar_dialogo()
		else:
			mostrar_linea()


func terminar_dialogo() -> void:
	abierto = false
	cuadro.hide()
	get_tree().paused = false
