extends CanvasLayer

@onready var pantalla: Control = $Pantalla
@onready var titulo: Label = $Pantalla/Centro/Tarjeta/Contenido/Titulo
@onready var imagen: TextureRect = $Pantalla/Centro/Tarjeta/Contenido/Imagen
@onready var texto: Label = $Pantalla/Centro/Tarjeta/Contenido/Texto
@onready var boton_cerrar: Button = $Pantalla/Centro/Tarjeta/Contenido/BotonCerrar

var abierto: bool = false
var pensamiento_pendiente: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30

	pantalla.hide()
	boton_cerrar.pressed.connect(cerrar_recuerdo)


func mostrar_recuerdo(
	nombre: String,
	contenido: String,
	textura: Texture2D,
	pensamiento: String = ""
) -> void:
	if abierto:
		return

	abierto = true
	pensamiento_pendiente = pensamiento

	titulo.text = nombre
	texto.text = contenido
	imagen.texture = textura
	imagen.visible = textura != null

	pantalla.show()
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if not abierto:
		return

	if event.is_action_pressed("interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		cerrar_recuerdo()


func cerrar_recuerdo() -> void:
	if not abierto:
		return

	abierto = false
	pantalla.hide()
	get_tree().paused = false

	# Steve habla despues de cerrar la nota
	if not pensamiento_pendiente.is_empty():
		var frases: String = pensamiento_pendiente
		pensamiento_pendiente = ""

		DialogoNPC.call_deferred(
			"iniciar_dialogo",
			"Steve",
			frases
		)
