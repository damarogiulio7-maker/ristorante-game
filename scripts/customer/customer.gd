extends Node2D
class_name Customer

## Un cliente del ristorante. Entra dalla porta, si siede a un tavolo libero,
## aspetta che la cameriera prenda l'ordine e porti il cibo, mangia, lascia i
## soldi sul tavolo ed esce. Le gambe scompaiono quando è seduto.
## MIGLIORAMENTO: Sistema di pazienza - se aspetta troppo, se ne va arrabbiato.

signal customer_left_angry(reason: String)

var assigned_table: TableSpot = null
var recipe: Recipe = null
var entry_position: Vector2 = Vector2.ZERO
var game_config: GameConfig = null

var _eating_timer: float = 0.0
var _patience_timer: float = 0.0
var _max_patience: float = 15.0
var _leaving: bool = false
var _is_seated: bool = false
var _left_angry: bool = false
var _is_impatient: bool = false

@onready var leg_left: ColorRect = $LegLeft if has_node("LegLeft") else null
@onready var leg_right: ColorRect = $LegRight if has_node("LegRight") else null

func _ready() -> void:
	# Carica il config dal game manager o crea uno di default
	var game_manager = get_tree().root.get_child(0).get_node_or_null("GameManager")
	if game_manager and game_manager.has_meta("config"):
		game_config = game_manager.get_meta("config")
	else:
		game_config = GameConfig.new()

func _process(delta: float) -> void:
	if _leaving:
		_set_seated(false)
		global_position = global_position.move_toward(entry_position, game_config.customer_move_speed * delta)
		if global_position.distance_to(entry_position) < 4.0:
			queue_free()
		return

	if assigned_table == null:
		return

	# ASPETTANDO ORDINE O ORDINE PRESO - incrementa pazienza
	if assigned_table.state == TableSpot.State.WAITING_ORDER or assigned_table.state == TableSpot.State.ORDER_TAKEN:
		var target: Vector2 = assigned_table.get_seat_position()
		global_position = global_position.move_toward(target, game_config.customer_move_speed * delta)
		_set_seated(global_position.distance_to(target) < 4.0)
		
		# Aumenta timer pazienza
		_patience_timer += delta
		_check_patience()

	# MANGIANDO - reset pazienza
	elif assigned_table.state == TableSpot.State.EATING:
		_set_seated(true)
		_patience_timer = 0.0
		_is_impatient = false
		_eating_timer += delta
		if _eating_timer >= game_config.customer_eating_time:
			_finish_meal()

func _check_patience() -> void:
	if _left_angry:
		return
	
	var patience_ratio = _patience_timer / _max_patience
	
	# Se esaurisce la pazienza, se ne va arrabbiato
	if patience_ratio >= 1.0:
		_leave_angry("Pazienza esaurita - ordine non ancora arrivato!")
		return
	
	# Diventa impatiente al 70% della pazienza
	if patience_ratio >= game_config.impatience_threshold and not _is_impatient:
		_is_impatient = true
		_show_impatience_feedback()

func _leave_angry(reason: String) -> void:
	if _left_angry:
		return
	_left_angry = true
	_leaving = true
	customer_left_angry.emit(reason)
	if assigned_table:
		assigned_table.clear_customer()

func _show_impatience_feedback() -> void:
	# TODO: Aggiungere animazione di impazienz (es. piedi che tamburellano, punto esclamativo)
	pass

func _set_seated(seated: bool) -> void:
	if seated == _is_seated:
		return
	_is_seated = seated
	if leg_left:
		leg_left.visible = not seated
	if leg_right:
		leg_right.visible = not seated

func _finish_meal() -> void:
	if assigned_table:
		# Calcola prezzo dinamico in base al tempo impiegato
		var price = _calculate_dynamic_price()
		assigned_table.leave_money(price)
	_leaving = true

func _calculate_dynamic_price() -> int:
	if not recipe:
		return game_config.base_order_value
	
	# Prezzo base dalla ricetta
	var base_price = recipe.sale_price
	
	# Bonus difficoltà
	var difficulty_bonus = (recipe.difficulty - 1) * int(recipe.sale_price * game_config.price_difficulty_multiplier)
	
	# Se il cliente non era impatiente = veloce = bonus
	var speed_bonus = 0
	if not _is_impatient:
		speed_bonus = game_config.price_time_bonus_amount
	
	return max(base_price, base_price + difficulty_bonus + speed_bonus)

func set_recipe_and_patience(new_recipe: Recipe) -> void:
	recipe = new_recipe
	_max_patience = game_config.get_customer_patience_for_recipe(new_recipe)
