extends Node2D
class_name StaffMember

## Un membro dello staff che lavora in autonomia: si sposta verso una
## stazione libera, ci lavora, poi torna disponibile per il prossimo compito.
## Il giocatore non lo controlla direttamente: lo assume e lo supervisiona.

enum State { IDLE, MOVING_TO_STATION, WORKING }

@export var staff_name: String = "Cuoco"
@export var move_speed: float = 120.0
@export var skill_level: int = 1  # influenza la velocità di lavoro

signal became_idle(staff: StaffMember)
signal started_working(staff: StaffMember, station: WorkStation)
signal finished_order(staff: StaffMember, order: Dictionary)

var state: State = State.IDLE
var _target_station: WorkStation = null
var _current_order: Dictionary = {}

func assign_to_station(station: WorkStation, order: Dictionary) -> void:
	if state != State.IDLE:
		push_warning("%s non è libero, non posso assegnargli un nuovo compito." % staff_name)
		return

	_target_station = station
	_current_order = order
	state = State.MOVING_TO_STATION

func _process(delta: float) -> void:
	if state == State.MOVING_TO_STATION and _target_station != null:
		var target_pos: Vector2 = _target_station.global_position
		global_position = global_position.move_toward(target_pos, move_speed * delta)
		if global_position.distance_to(target_pos) < 4.0:
			_begin_work()

func _begin_work() -> void:
	state = State.WORKING
	started_working.emit(self, _target_station)

	var item_name: String = _current_order.get("item_name", "piatto")
	var result_name: String = _current_order.get("result_name", "piatto pronto")

	if not _target_station.work_completed.is_connected(_on_station_work_completed):
		_target_station.work_completed.connect(_on_station_work_completed, CONNECT_ONE_SHOT)

	# La velocità effettiva viene leggermente influenzata dallo skill_level.
	var speed_bonus: float = 1.0 + (skill_level - 1) * 0.15
	_target_station.work_time_seconds = max(0.5, _target_station.work_time_seconds / speed_bonus)
	_target_station.start_work(item_name, result_name)

func _on_station_work_completed(_item_name: String, result_name: String) -> void:
	_current_order["result_name"] = result_name
	finished_order.emit(self, _current_order)

	state = State.IDLE
	_target_station = null
	_current_order = {}
	became_idle.emit(self)
