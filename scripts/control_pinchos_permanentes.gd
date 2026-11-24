extends Node2D

const ESCENA_PINCHOS = preload(
	"res://scenes/boss/pinchos_permanentes.tscn"
)

@export var jefe: Node2D

@export var inicio_suelo: float = 0.0
@export var fin_suelo: float = 1152.0
@export var altura_suelo: float = 610.0

@export var ancho_pinchos: float = 100.0
@export var tiempo_advertencia: float = 3.5

var ataques_creados: bool = false


func _ready() -> void:
	if jefe == null:
		jefe = get_parent().get_node_or_null("JefePlanta")


func _process(_delta: float) -> void:
	if ataques_creados:
		return

	if not is_instance_valid(jefe):
		return

	if jefe.get("fase") == 2:
		ataques_creados = true
		cubrir_suelo_con_pinchos()


func cubrir_suelo_con_pinchos() -> void:
	var posicion_x: float = inicio_suelo + ancho_pinchos / 2.0

	while posicion_x - ancho_pinchos / 2.0 < fin_suelo:
		var ataque = ESCENA_PINCHOS.instantiate()

		ataque.set("jefe", jefe)
		ataque.set("tiempo_aviso", tiempo_advertencia)

		get_tree().current_scene.add_child(ataque)

		ataque.global_position = Vector2(
			posicion_x,
			altura_suelo
		)

		posicion_x += ancho_pinchos

	print("FASE 2: Todo el suelo cubierto")
