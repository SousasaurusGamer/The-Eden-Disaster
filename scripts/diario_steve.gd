extends CanvasLayer

@onready var pantalla: Control = $Pantalla

@onready var contador: Label = $Pantalla/Centro/Panel/Margen/Principal/Cabecera/Contador

@onready var cerrar_boton: Button = $Pantalla/Centro/Panel/Margen/Principal/Cabecera/Cerrar

@onready var lista_notas: VBoxContainer = $Pantalla/Centro/Panel/Margen/Principal/Columnas/ListaNotas

@onready var titulo_nota: Label = $Pantalla/Centro/Panel/Margen/Principal/Columnas/Detalle/TituloNota

@onready var imagen: TextureRect = $Pantalla/Centro/Panel/Margen/Principal/Columnas/Detalle/Imagen

@onready var texto_nota: RichTextLabel = $Pantalla/Centro/Panel/Margen/Principal/Columnas/Detalle/TextoNota

var abierto: bool = false

const TOTAL_NOTAS: int = 5


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 25

	pantalla.hide()

	cerrar_boton.pressed.connect(cerrar_diario)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("diario"):
		return

	print("TAB DETECTADA")
	print("Juego pausado: ", get_tree().paused)
	print("Diario abierto: ", abierto)

	if abierto:
		cerrar_diario()
	elif not get_tree().paused:
		abrir_diario()
	else:
		print("No se puede abrir: el juego esta pausado")

	get_viewport().set_input_as_handled()

func abrir_diario() -> void:
	if abierto:
		return

	abierto = true

	actualizar_notas()

	pantalla.show()
	get_tree().paused = true


func cerrar_diario() -> void:
	if not abierto:
		return

	abierto = false

	pantalla.hide()
	get_tree().paused = false


func actualizar_notas() -> void:
	for hijo in lista_notas.get_children():
		hijo.queue_free()

	contador.text = "%d/%d ARCHIVOS" % [
		GameState.notas_encontradas.size(),
		TOTAL_NOTAS
	]

	titulo_nota.text = "Selecciona una nota"
	texto_nota.text = "Aquí aparecerán tus recuerdos."
	imagen.hide()

	for numero in range(1, TOTAL_NOTAS + 1):
		var id: String = "nota_%03d" % numero

		var encontrada: bool = GameState.notas_encontradas.has(id)

		var boton: Button = Button.new()
		boton.custom_minimum_size = Vector2(220, 42)

		if encontrada:
			boton.text = "ARCHIVO %03d" % numero

			boton.pressed.connect(
				mostrar_nota.bind(id)
			)
		else:
			boton.text = "??? BLOQUEADO"
			boton.disabled = true

		lista_notas.add_child(boton)


func mostrar_nota(id: String) -> void:
	if not GameState.datos_notas.has(id):
		titulo_nota.text = "Archivo no disponible"
		texto_nota.text = "No se guardó el contenido de esta nota."
		imagen.hide()
		return

	var datos: Dictionary = GameState.datos_notas[id]

	titulo_nota.text = datos.get("titulo", "Sin título")
	texto_nota.text = datos.get("texto", "")

	var textura: Texture2D = datos.get("imagen", null)

	imagen.texture = textura
	imagen.visible = textura != null
