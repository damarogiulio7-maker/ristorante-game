extends Node2D
class_name WorkStation

## Rappresenta una stazione di lavoro in cucina (es. taglio, cottura, impiattamento).
## Ogni stazione riceve un ingrediente, lo lavora in un certo tempo, e produce un risultato.

@export var station_name: String = "Stazione"
@export var work_time_seconds: float = 3.0

signal work_started(item_name: String)
signal work_completed(item_name: String, result_name: String)

var _is_working: bool = false
var _current_item: String = ""

func start_work(item_name: String, result_name: String) -> void:
	if _is_working:
		push_warning("%s è già occupata." % station_name)
		return

	_is_working = true
	_current_item = item_name
	work_started.emit(item_name)

	await get_tree().create_timer(work_time_seconds).timeout

	_is_working = false
	work_completed.emit(item_name, result_name)
	_current_item = ""

func is_busy() -> bool:
	return _is_working
