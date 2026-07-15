extends Node
class_name GameManager

## Cuore della simulazione: riceve gli ordini presi dalla cameriera ai tavoli,
## li assegna al primo membro dello staff e alla prima stazione libera.
## I soldi si guadagnano solo quando il giocatore clicca sui soldi lasciati
## dai clienti sui tavoli (vedi TableSpot.gd).
## MIGLIORAMENTI: Usa GameConfig centralizzato, gestisce reputazione dinamica.

signal money_changed(new_amount: int)
signal reputation_changed(new_amount: int)
signal order_created(order: Dictionary)
signal order_completed(order: Dictionary, earnings: int)

var money: int = 0
var reputation: int = 0
var orders_completed: int = 0

var staff_members: Array[StaffMember] = []
var stations: Array[WorkStation] = []
var recipes: Array[Recipe] = []
var game_config: GameConfig
var save_manager: SaveManager

var _pending_orders: Array[Dictionary] = []
var _autosave_timer: float = 0.0

func _ready() -> void:
	# Carica o crea il config
	game_config = GameConfig.new()
	set_meta("config", game_config)  # Lo salva come metadato per i figli
	
	# Crea il save manager
	save_manager = SaveManager.new()
	add_child(save_manager)
	
	money = game_config.starting_money
	reputation = game_config.starting_reputation

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

## Chiamato quando un cliente se ne va arrabbiato (pazienza esaurita)
func customer_left_angry(_reason: String) -> void:
	_change_reputation(-game_config.reputation_decrease_per_timeout)

## Funzione interna per modificare reputazione con clamp
func _change_reputation(delta: int) -> void:
	reputation = clampi(reputation + delta, game_config.min_reputation, game_config.max_reputation)
	reputation_changed.emit(reputation)

func _process(_delta: float) -> void:
	_try_assign_pending_orders()
	
	# Autosave periodico
	if game_config.autosave_enabled:
		_autosave_timer += _delta
		if _autosave_timer >= game_config.autosave_interval:
			_autosave_timer = 0.0
			# TODO: Implementare save/load

func _try_assign_pending_orders() -> void:
	if _pending_orders.is_empty():
		return

	for staff in staff_members:
		if _pending_orders.is_empty():
			return
		
		# Salta se lo staff non è disponibile
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
	orders_completed += 1
	_change_reputation(game_config.reputation_increase_per_order)
	order_completed.emit(order, order.get("sale_price", 0))
	
	# Verifica se aumentare la difficoltà
	if game_config.should_increase_difficulty(orders_completed):
		_increase_difficulty()

func _increase_difficulty() -> void:
	# TODO: Aumentare difficoltà ricette, velocità staff, ecc.
	pass
