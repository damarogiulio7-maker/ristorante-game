extends Node2D

## Script della scena principale della cucina/sala.
## Collega stazioni, staff di cucina, tavoli, cameriera e gestore clienti.

@onready var game_manager: GameManager = $GameManager
@onready var money_label: Label = $HUD/MoneyLabel
@onready var reputation_label: Label = $HUD/ReputationLabel
@onready var log_label: Label = $HUD/LogLabel

func _ready() -> void:
	for station in $Stations.get_children():
		if station is WorkStation:
			game_manager.register_station(station)

	for staff in $Staff.get_children():
		if staff is StaffMember:
			game_manager.register_staff(staff)

	var recipe_list: Array[Recipe] = []
	for recipe_path in [
		"res://resources/recipes/pasta_pomodoro.tres",
		"res://resources/recipes/branzino_forno.tres",
	]:
		var recipe: Recipe = load(recipe_path)
		game_manager.register_recipe(recipe)
		recipe_list.append(recipe)

	var tables: Array[TableSpot] = []
	for table in $Environment/Tables.get_children():
		if table is TableSpot:
			tables.append(table)
			table.money_collected.connect(_on_table_money_collected)

	var waitress: Waitress = $Staff/Cameriera
	waitress.tables = tables
	waitress.recipes = recipe_list
	waitress.game_manager = game_manager
	waitress.kitchen_pickup_position = $Environment/Counter.global_position
	waitress._ready()

	var customer_manager: CustomerManager = $CustomerManager
	customer_manager.tables = tables
	customer_manager.door_position = $Environment/EntranceDoor.global_position + Vector2(55, 200)
	customer_manager.customer_scene = load("res://scenes/staff/customer.tscn")
	customer_manager.customers_container = $Customers

	game_manager.money_changed.connect(_on_money_changed)
	game_manager.reputation_changed.connect(_on_reputation_changed)
	game_manager.order_completed.connect(_on_order_completed)

	var open_button: Button = $HUD/OpenButton
	open_button.pressed.connect(func():
		customer_manager.is_open = true
		open_button.visible = false
		log_label.text = "Ristorante aperto, in attesa di clienti..."
	)

	_on_money_changed(game_manager.money)
	_on_reputation_changed(game_manager.reputation)
	log_label.text = "Ristorante chiuso. Premi \"Apri Ristorante\" per iniziare."

func _on_money_changed(new_amount: int) -> void:
	money_label.text = "Soldi: %d€" % new_amount

func _on_reputation_changed(new_amount: int) -> void:
	reputation_label.text = "Reputazione: %d" % new_amount

func _on_order_completed(order: Dictionary, _earnings: int) -> void:
	log_label.text = "Piatto pronto: %s" % order.get("item_name", "")

func _on_table_money_collected(_table: TableSpot, amount: int) -> void:
	game_manager.collect_money(amount)
