extends Node2D
class_name WorkStation

## Rappresenta una stazione di lavoro in cucina (es. taglio, cottura, impiattamento).
## Ogni stazione riceve un ingrediente, lo lavora in un certo tempo, e produce un
## risultato. Emette progress_updated (0..1) per mostrare una barra di preparazione.

@export var station_name: String = "Stazione"
@export var work_time_seconds: float = 3.0

signal work_started(item_name: String)
signal work_completed(item_name: String, result_name: String)
signal progress_updated(fraction: float)

var _is_working: bool = false
var _current_item: String = ""
var _elapsed: float = 0.0

func start_work(item_name: String, result_name: String) -> void:
	if _is_working:
		push_warning("%s è già occupata." % station_name)
		return

	_is_working = true
	_current_item = item_name
	_elapsed = 0.0
	work_started.emit(item_name)
	_run_work(result_name)

func _run_work(result_name: String) -> void:
	while _elapsed < work_time_seconds:
		await get_tree().process_frame
		_elapsed += get_process_delta_time()
		progress_updated.emit(clampf(_elapsed / work_time_seconds, 0.0, 1.0))

	_is_working = false
	work_completed.emit(_current_item, result_name)
	_current_item = ""
	progress_updated.emit(0.0)

func is_busy() -> bool:
	return _is_working
