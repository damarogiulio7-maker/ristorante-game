extends Node2D
class_name Waitress

## La cameriera collega clienti e cucina: va ai tavoli con clienti in attesa,
## prende l'ordine e lo passa al GameManager, poi quando il piatto è pronto
## lo ritira in cucina e lo porta al tavolo giusto.

enum State { IDLE, GOING_TO_ORDER, WAITING_FOR_FOOD, GOING_TO_KITCHEN, GOING_TO_SERVE }

@export var move_speed: float = 150.0

var tables: Array[TableSpot] = []
var recipes: Array[Recipe] = []
var game_manager: GameManager
var kitchen_pickup_position: Vector2 = Vector2.ZERO

var state: State = State.IDLE
var _current_table: TableSpot = null
var _current_order: Dictionary = {}

func _ready() -> void:
	if game_manager:
		game_manager.order_completed.connect(_on_order_completed)

func _process(delta: float) -> void:
	match state:
		State.IDLE:
			_find_table_to_serve()
		State.GOING_TO_ORDER:
			_move_toward(_current_table.global_position, delta, _on_reached_table_for_order)
		State.GOING_TO_KITCHEN:
			_move_toward(kitchen_pickup_position, delta, _on_reached_kitchen)
		State.GOING_TO_SERVE:
			_move_toward(_current_table.global_position, delta, _on_reached_table_to_serve)

func _move_toward(target: Vector2, delta: float, on_arrive: Callable) -> void:
	global_position = global_position.move_toward(target, move_speed * delta)
	if global_position.distance_to(target) < 6.0:
		on_arrive.call()

func _find_table_to_serve() -> void:
	if recipes.is_empty():
		return
	for table in tables:
		if table.state == TableSpot.State.WAITING_ORDER:
			_current_table = table
			state = State.GOING_TO_ORDER
			return

func _on_reached_table_for_order() -> void:
	var recipe: Recipe = recipes[randi() % recipes.size()]
	_current_order = {
		"item_name": recipe.recipe_name,
		"result_name": recipe.recipe_name + " (pronto)",
		"sale_price": recipe.sale_price,
		"table": _current_table,
	}
	if _current_table.current_customer:
		_current_table.current_customer.recipe = recipe
	_current_table.state = TableSpot.State.ORDER_TAKEN
	game_manager.submit_order(_current_order)
	state = State.WAITING_FOR_FOOD

func _on_order_completed(order: Dictionary, _earnings: int) -> void:
	if state != State.WAITING_FOR_FOOD:
		return
	if order.get("table", null) != _current_table:
		return
	state = State.GOING_TO_KITCHEN

func _on_reached_kitchen() -> void:
	state = State.GOING_TO_SERVE

func _on_reached_table_to_serve() -> void:
	_current_table.state = TableSpot.State.EATING
	_current_table = null
	_current_order = {}
	state = State.IDLE
