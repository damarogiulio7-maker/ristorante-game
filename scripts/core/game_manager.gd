extends Node
class_name GameManager

## Cuore della simulazione: genera ordini periodicamente, li assegna al primo
## membro dello staff libero e alla prima stazione libera adatta, e tiene
## traccia di guadagni e reputazione.

signal money_changed(new_amount: int)
signal reputation_changed(new_amount: int)
signal order_created(order: Dictionary)
signal order_completed(order: Dictionary, earnings: int)

@export var order_interval_seconds: float = 6.0
@export var starting_money: int = 100
@export var starting_reputation: int = 50

var money: int = 0
var reputation: int = 50

var staff_members: Array[StaffMember] = []
var stations: Array[WorkStation] = []
var recipes: Array[Recipe] = []

var _pending_orders: Array[Dictionary] = []
var _order_timer: float = 0.0

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

func _process(delta: float) -> void:
	if recipes.is_empty():
		return

	_order_timer += delta
	if _order_timer >= order_interval_seconds:
		_order_timer = 0.0
		_create_random_order()

	_try_assign_pending_orders()

func _create_random_order() -> void:
	var recipe: Recipe = recipes[randi() % recipes.size()]
	var order: Dictionary = {
		"item_name": recipe.recipe_name,
		"result_name": recipe.recipe_name + " (pronto)",
		"sale_price": recipe.sale_price,
	}
	_pending_orders.append(order)
	order_created.emit(order)

func _try_assign_pending_orders() -> void:
	if _pending_orders.is_empty():
		return

	for staff in staff_members:
		if staff.state != StaffMember.State.IDLE:
			continue
		var station: WorkStation = _find_free_station()
		if station == null:
			return
		var order: Dictionary = _pending_orders.pop_front()
		staff.assign_to_station(station, order)
		if _pending_orders.is_empty():
			return

func _find_free_station() -> WorkStation:
	for station in stations:
		if not station.is_busy():
			return station
	return null

func _on_staff_idle(_staff: StaffMember) -> void:
	_try_assign_pending_orders()

func _on_order_finished(_staff: StaffMember, order: Dictionary) -> void:
	var earnings: int = order.get("sale_price", 0)
	money += earnings
	reputation = clampi(reputation + 1, 0, 100)
	money_changed.emit(money)
	reputation_changed.emit(reputation)
	order_completed.emit(order, earnings)
