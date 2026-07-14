extends Node2D

## Script della scena principale della cucina/sala.
## Registra le stazioni, lo staff e le ricette nel GameManager,
## e aggiorna l'interfaccia (soldi, reputazione, ordini).

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

	for recipe_path in [
		"res://resources/recipes/pasta_pomodoro.tres",
		"res://resources/recipes/branzino_forno.tres",
	]:
		var recipe: Recipe = load(recipe_path)
		game_manager.register_recipe(recipe)

	game_manager.money_changed.connect(_on_money_changed)
	game_manager.reputation_changed.connect(_on_reputation_changed)
	game_manager.order_completed.connect(_on_order_completed)

	_on_money_changed(game_manager.money)
	_on_reputation_changed(game_manager.reputation)
	log_label.text = "In attesa di ordini..."

func _on_money_changed(new_amount: int) -> void:
	money_label.text = "Soldi: %d€" % new_amount

func _on_reputation_changed(new_amount: int) -> void:
	reputation_label.text = "Reputazione: %d" % new_amount

func _on_order_completed(order: Dictionary, earnings: int) -> void:
	log_label.text = "Completato: %s (+%d€)" % [order.get("item_name", ""), earnings]
