extends Node2D
class_name StaffMember

## Un membro dello staff che si sposta verso una stazione libera e aspetta
## che il giocatore clicchi la stazione per iniziare davvero a lavorare.
## MIGLIORAMENTO: Aggiunto sistema di affaticamento che influenza velocità.

enum State { IDLE, MOVING_TO_STATION, WAITING_FOR_PLAYER, WORKING }

@export var staff_name: String = "Cuoco"
@export var move_speed: float = 120.0
@export var skill_level: int = 1

signal became_idle(staff: StaffMember)
signal started_working(staff: StaffMember, station: WorkStation)
signal finished_order(staff: StaffMember, order: Dictionary)

var state: State = State.IDLE
var game_config: GameConfig
var _fatigue: float = 0.0  # 0.0 = riposato, 1.0 = completamente affaticato
var _target_station: WorkStation = null
var _current_order: Dictionary = {}

func _ready() -> void:
	# Carica il config
	var game_manager = get_tree().root.get_child(0).get_node_or_null("GameManager")
	if game_manager and game_manager.has_meta("config"):
		game_config = game_manager.get_meta("config")
	else:
		game_config = GameConfig.new()

func assign_to_station(station: WorkStation, order: Dictionary) -> void:
	if state != State.IDLE:
		push_warning("%s non è libero, non posso assegnargli un nuovo compito." % staff_name)
		return

	_target_station = station
	_current_order = order
	state = State.MOVING_TO_STATION

func _process(delta: float) -> void:
	# Recupera affaticamento quando idle
	if state == State.IDLE:
		_fatigue = maxf(_fatigue - (game_config.staff_fatigue_recovery_per_rest * delta), 0.0)
	
	if state == State.MOVING_TO_STATION and _target_station != null:
		var target_pos: Vector2 = _target_station.global_position
		var current_speed = move_speed * _get_fatigue_factor()
		global_position = global_position.move_toward(target_pos, current_speed * delta)
		if global_position.distance_to(target_pos) < 4.0:
			_arrive_at_station()

func _arrive_at_station() -> void:
	state = State.WAITING_FOR_PLAYER
	_target_station.show_ready_prompt(true)
	_target_station.player_start_requested.connect(_on_player_start, CONNECT_ONE_SHOT)

func _on_player_start() -> void:
	if state != State.WAITING_FOR_PLAYER:
		return
	_target_station.show_ready_prompt(false)
	_begin_work()

func _begin_work() -> void:
	state = State.WORKING
	started_working.emit(self, _target_station)

	var item_name: String = _current_order.get("item_name", "piatto")
	var result_name: String = _current_order.get("result_name", "piatto pronto")
	var recipe: Recipe = _current_order.get("recipe", null)

	if not _target_station.work_completed.is_connected(_on_station_work_completed):
		_target_station.work_completed.connect(_on_station_work_completed, CONNECT_ONE_SHOT)

	# Calcola durata considerando skill e affaticamento
	var speed_bonus: float = 1.0 + (maxf(skill_level - 1, 0) * game_config.staff_speed_per_skill_level)
	var fatigue_factor = _get_fatigue_factor()
	var duration: float = max(0.5, _current_order.get("duration", 5.0) / (speed_bonus * fatigue_factor))
	
	_target_station.start_work(item_name, result_name, duration, recipe)
	
	# Aumenta affaticamento quando finisce il lavoro
	_fatigue = minf(_fatigue + 0.2, 1.0)

func _on_station_work_completed(_item_name: String, result_name: String) -> void:
	_current_order["result_name"] = result_name
	finished_order.emit(self, _current_order)

	state = State.IDLE
	_target_station = null
	_current_order = {}
	became_idle.emit(self)

## Ritorna fattore moltiplicatore velocità in base all'affaticamento (0.5 - 1.0)
func _get_fatigue_factor() -> float:
	if _fatigue <= 0.0:
		return 1.0
	return lerpf(1.0, game_config.staff_fatigue_factor, _fatigue)
