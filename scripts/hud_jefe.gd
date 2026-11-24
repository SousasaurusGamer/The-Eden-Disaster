
extends CanvasLayer

@export var jefe: Node2D

@onready var barra: ProgressBar = $Contenedor/BarraVida
@onready var titulo: Label = $Contenedor/Titulo

var animacion_vida: Tween
var ultima_vida: float = -1.0
var fase_visual: int = 0

var estilo_barra: StyleBoxFlat = StyleBoxFlat.new()


func _ready() -> void:
	if jefe == null:
		jefe = get_parent().get_node_or_null("JefePlanta")

	if not is_instance_valid(jefe):
		hide()
		return

	barra.max_value = float(jefe.get("vida_maxima"))
	barra.value = float(jefe.get("vida_actual"))
	ultima_vida = barra.value

	# Estilo de la barra
	estilo_barra.bg_color = Color("#E34F4F")
	estilo_barra.set_corner_radius_all(4)

	barra.add_theme_stylebox_override("fill", estilo_barra)

	actualizar_fase()


func _process(_delta: float) -> void:
	if not is_instance_valid(jefe):
		hide()
		return

	var vida_actual: float = float(jefe.get("vida_actual"))

	# Animar cuando el jefe pierde vida
	if vida_actual != ultima_vida:
		ultima_vida = vida_actual

		if animacion_vida and animacion_vida.is_running():
			animacion_vida.kill()

		animacion_vida = create_tween()
		animacion_vida.tween_property(
			barra,
			"value",
			vida_actual,
			0.4
		).set_trans(Tween.TRANS_SINE)

	# Detectar cambio de fase
	if int(jefe.get("fase")) != fase_visual:
		actualizar_fase()


func actualizar_fase() -> void:
	fase_visual = int(jefe.get("fase"))

	if fase_visual == 2:
		titulo.text = "PLANTA MUTANTE - FASE 2"
		estilo_barra.bg_color = Color("#A855D5")
	else:
		titulo.text = "PLANTA MUTANTE - FASE 1"
		estilo_barra.bg_color = Color("#E34F4F")
