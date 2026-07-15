extends Node2D
class_name Waitress

## La cameriera collega clienti e cucina: va ai tavoli con clienti in attesa,
## si ferma un attimo a "parlare" e prendere l'ordine, lo passa al GameManager,
## poi quando il piatto è pronto lo ritira in cucina e lo porta al tavolo giusto.
##
## STATE MACHINE:
## - IDLE: Aspetta un tavolo con cliente in attesa
## - GOING_TO_ORDER: Si muove verso il tavolo
## - TALKING: Sta parlando con il cliente (talk_time_seconds)
## - WAITING_FOR_FOOD: Ha preso l'ordine, aspetta che sia preparato
## - GOING_TO_KITCHEN: Si muove verso la cucina per ritirare il piatto
## - GOING_TO_SERVE: Si muove verso il tavolo per servire il piatto

enum State { IDLE, GOING_TO_ORDER, TALKING, WAITING_FOR_FOOD, GOING_TO_KITCHEN, GOING_TO_SERVE }

var move_speed: float = 150.0
var talk_time_seconds: float = 1.2

var tables: Array[TableSpot] = []
var recipes: Array[Recipe] = []
var game_manager: GameManager
var kitchen_pickup_position: Vector2 = Vector2.ZERO
var game_config: GameConfig
var recipe_menu: RecipeSelectionMenu = null

var state: State = State.IDLE
var _current_table: TableSpot = null
var _current_order: Dictionary = {}
var _talk_timer: float = 0.0
var _waiting_for_recipe_selection: bool = false

func _ready() -> void:
	# Carica il config
	var root = get_tree().root.get_child(0)
	if root.has_meta("config"):
		game_config = root.get_meta("config")
	else:
		game_config = GameConfig.new()
	
	if game_manager:
		game_manager.order_completed.connect(_on_order_completed)
	
	# Cerca il menu di selezione ricette nella scena
	recipe_menu = get_tree().root.get_node_or_null("Main/HUD/RecipeSelectionMenu")

func _process(delta: float) -> void:
	# Se stiamo aspettando la selezione della ricetta, non fare niente
	if _waiting_for_recipe_selection:
		return
	
	match state:
		State.IDLE:
			_find_table_to_serve()
		State.GOING_TO_ORDER:
			_move_toward(_current_table.global_position, delta, _on_reached_table_for_order)
		State.TALKING:
			_talk_timer += delta
			if _talk_timer >= talk_time_seconds:
				_ask_for_order()
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
	_talk_timer = 0.0
	state = State.TALKING

func _ask_for_order() -> void:
	# Mostra il menu di selezione ricette
	if recipe_menu:
		_waiting_for_recipe_selection = true
		recipe_menu.recipe_selected.connect(_on_recipe_selected, CONNECT_ONE_SHOT)
		recipe_menu.menu_cancelled.connect(_on_recipe_selection_cancelled, CONNECT_ONE_SHOT)
		recipe_menu.show_menu(_current_table, recipes)
	else:
		# Fallback: scegli casualmente se il menu non è disponibile
		_take_order(recipes[randi() % recipes.size()])

func _on_recipe_selected(recipe: Recipe) -> void:
	_waiting_for_recipe_selection = false
	_take_order(recipe)

func _on_recipe_selection_cancelled() -> void:
	# Se il giocatore cancella, la cameriera torna idle
	_waiting_for_recipe_selection = false
	state = State.IDLE
	_current_table = null

func _take_order(recipe: Recipe) -> void:
	_current_order = {
		"item_name": recipe.recipe_name,
		"result_name": recipe.recipe_name + " (pronto)",
		"sale_price": recipe.sale_price,
		"table": _current_table,
		"recipe": recipe,
		"duration": recipe.prep_time_seconds,
	}
	
	if _current_table.current_customer:
		_current_table.current_customer.set_recipe_and_patience(recipe)
	
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
