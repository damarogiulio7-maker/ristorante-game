extends Node
class_name GameManager

## Cuore della simulazione: riceve gli ordini presi dalla cameriera ai tavoli,
## li assegna al primo membro dello staff e alla prima stazione libera.
## I soldi si guadagnano solo quando il giocatore clicca sui soldi lasciati
## dai clienti sui tavoli (vedi TableSpot.gd).

signal money_changed(new_amount: int)
signal reputation_changed(new_amount: int)
signal order_created(order: Dictionary)
signal order_completed(order: Dictionary, earnings: int)

@export var starting_money: int = 100
@export var starting_reputation: int = 50

var money: int = 0
var reputation: int = 50

var staff_members: Array[StaffMember] = []
var stations: Array[WorkStation] = []
var recipes: Array[Recipe] = []

var _pending_orders: Array[Dictionary] = []

func _ready() -> void:
	money = starting_money
	reputation = starting_reputation

func register_staff(staff: StaffMember) -> void:
	staff_members.append(staff)
	staff.became_idle.connect(_on_staff_idle)
	staff.finished_order.connect(_on_order_finished)

func register_station(station: WorkStation) -> void:
	stations.append(station)

func register_recipe(recipe: Recipe) -> void:
	recipes.append(recipe)

func submit_order(order: Dictionary) -> void:
	_pending_orders.append(order)
	order_created.emit(order)
	_try_assign_pending_orders()

func collect_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func _process(_delta: float) -> void:
	_try_assign_pending_orders()

func _try_assign_pending_orders() -> void:
	if _pending_orders.is_empty():
		return

	for staff in staff_members:
		if _pending_orders.is_empty():
			return
		if staff.state != StaffMember.State.IDLE:
			continue
		var station: WorkStation = _find_free_station()
		if station == null:
			return
		var order: Dictionary = _pending_orders.pop_front()
		staff.assign_to_station(station, order)

func _find_free_station() -> WorkStation:
	for station in stations:
		if not station.is_busy():
			return station
	return null

func _on_staff_idle(_staff: StaffMember) -> void:
	_try_assign_pending_orders()

func _on_order_finished(_staff: StaffMember, order: Dictionary) -> void:
	reputation = clampi(reputation + 1, 0, 100)
	reputation_changed.emit(reputation)
	order_completed.emit(order, order.get("sale_price", 0))
