
extends CanvasLayer

# Referencias a la interfaz
@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var health_text: Label = $Control/HealthBar/HealthText
@onready var ammo_label: Label = $Control/AmmoLabel
@onready var charge_bar: ProgressBar = $Control/ChargeBar

# Referencia al jugador
var steve: Node = null

# Tiempo de carga del disparo
const CHARGE_DURATION: float = 0.8


func _ready() -> void:
	health_bar.show_percentage = false
	charge_bar.show_percentage = false

	charge_bar.min_value = 0.0
	charge_bar.max_value = CHARGE_DURATION


func _process(_delta: float) -> void:
	# Buscar a Steve
	if not is_instance_valid(steve):
		steve = get_tree().get_first_node_in_group("player")

	if not is_instance_valid(steve):
		return

	# VIDA Y MEJORAS
	var vida_actual: int = int(steve.get("health"))
	var vida_maxima: int = int(steve.get("max_health"))

	health_bar.max_value = float(vida_maxima)
	health_bar.value = float(vida_actual)

	# Mostrar vida actual y maxima
	health_text.text = "%d / %d HP" % [
		vida_actual,
		vida_maxima
	]

	# MUNICION
	var ammo: int = int(steve.get("ammo"))
	var max_ammo: int = int(steve.get("max_ammo"))

	ammo_label.text = "AMMO: %d / %d" % [
		ammo,
		max_ammo
	]

	# CARGA DEL DISPARO
	if bool(steve.get("is_charging")):
		charge_bar.value = minf(
			float(steve.get("charge_time")),
			CHARGE_DURATION
		)
	else:
		charge_bar.value = 0.0
