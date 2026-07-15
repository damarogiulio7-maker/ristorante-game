extends Node
class_name CustomerManager

## Gestisce l'ingresso dei clienti dalla porta a intervalli regolari.
## IMPORTANTE: Deve essere inizializzato da kitchen_room.gd impostando:
## - tables: Array dei tavoli disponibili
## - door_position: Posizione della porta d'ingresso
## - customer_scene: La scena del cliente
## - customers_container: Il nodo genitore dove spawnare i clienti
## 
## MIGLIORAMENTI:
## - Limita il numero massimo di clienti in attesa (dalla config)
## - Connette il segnale customer_left_angry al GameManager

var is_open: bool = false
var tables: Array[TableSpot] = []
var door_position: Vector2 = Vector2.ZERO
var customer_scene: PackedScene
var customers_container: Node2D
var game_manager: GameManager
var game_config: GameConfig

var _timer: float = 0.0
var _customers_spawned: Array[Customer] = []

func _ready() -> void:
	# Carica il config e il game manager
	var root = get_tree().root.get_child(0)
	game_manager = root.get_node_or_null("GameManager")
	if game_manager and game_manager.has_meta("config"):
		game_config = game_manager.get_meta("config")
	else:
		game_config = GameConfig.new()

func _process(delta: float) -> void:
	if not is_open:
		return
	if customer_scene == null or customers_container == null:
		return
	
	_timer += delta
	if _timer >= game_config.customer_spawn_interval:
		_timer = 0.0
		_try_spawn_customer()

func _try_spawn_customer() -> void:
	# Rispetta il limite massimo di clienti
	if _customers_spawned.size() >= game_config.customer_max_in_queue:
		return
	
	var free_table: TableSpot = _find_free_table()
	if free_table == null:
		return

	var customer: Customer = customer_scene.instantiate()
	customers_container.add_child(customer)
	customer.global_position = door_position
	customer.entry_position = door_position
	customer.assigned_table = free_table

	# Connetti il segnale di impazienza al game manager
	if game_manager:
		customer.customer_left_angry.connect(game_manager.customer_left_angry)

	free_table.state = TableSpot.State.WAITING_ORDER
	free_table.current_customer = customer
	
	_customers_spawned.append(customer)
	customer.tree_exited.connect(func(): _customers_spawned.erase(customer))

func _find_free_table() -> TableSpot:
	for table in tables:
		if table.is_free():
			return table
	return null
