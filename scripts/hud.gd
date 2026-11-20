extends CanvasLayer

# Referencias a la interfaz
@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var ammo_label: Label = $Control/AmmoLabel
@onready var charge_bar: ProgressBar = $Control/ChargeBar

# Referencia al jugador
var steve: Node = null

# Debe coincidir con CHARGE_TIME en steve.gd
const CHARGE_DURATION = 0.8


func _ready() -> void:
	health_bar.show_percentage = false
	charge_bar.show_percentage = false

	charge_bar.min_value = 0.0
	charge_bar.max_value = CHARGE_DURATION


func _process(_delta: float) -> void:
	# Buscar a Steve en el grupo player
	if not is_instance_valid(steve):
		steve = get_tree().get_first_node_in_group("player")

	if not is_instance_valid(steve):
		return

	# Actualizar vida
	health_bar.max_value = float(steve.get("max_health"))
	health_bar.value = float(steve.get("health"))

	# Actualizar municion
	var ammo = int(steve.get("ammo"))
	var max_ammo = int(steve.get("max_ammo"))

	ammo_label.text = "AMMO: %d / %d" % [ammo, max_ammo]

	# Actualizar carga de la pistola
	if bool(steve.get("is_charging")):
		charge_bar.value = minf(
			float(steve.get("charge_time")),
			CHARGE_DURATION
		)
	else:
		charge_bar.value = 0.0
