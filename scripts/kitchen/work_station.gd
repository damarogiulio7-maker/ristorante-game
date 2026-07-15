extends Node2D
class_name WorkStation

## Rappresenta una stazione di lavoro in cucina (es. taglio, cottura).
## Quando un cuoco arriva, la stazione aspetta un click per iniziare, poi il
## giocatore deve continuare a cliccare per far procedere la preparazione
## (stile Cooking Mama/Overcooked) fino al completamento.

@export var station_name: String = "Stazione"
@export var work_time_seconds: float = 3.0

signal work_started(item_name: String)
signal work_completed(item_name: String, result_name: String)
signal progress_updated(fraction: float)
signal player_start_requested

var _is_busy: bool = false
var _in_progress: bool = false
var _waiting_for_first_click: bool = false
var _current_item: String = ""
var _current_result: String = ""
var _taps_done: int = 0
var _taps_required: int = 3

@onready var click_area: Area2D = $ClickArea if has_node("ClickArea") else null
@onready var ready_prompt: Label = $ReadyPrompt if has_node("ReadyPrompt") else null

func _ready() -> void:
	if click_area:
		click_area.input_event.connect(_on_click_area_input)
	if ready_prompt:
		ready_prompt.visible = false

func show_ready_prompt(show: bool) -> void:
	_waiting_for_first_click = show
	if ready_prompt:
		ready_prompt.text = "❗"
		ready_prompt.visible = show

func _on_click_area_input(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _waiting_for_first_click:
			_waiting_for_first_click = false
			if ready_prompt:
				ready_prompt.visible = false
			player_start_requested.emit()
		elif _in_progress:
			_register_tap()

func start_work(item_name: String, result_name: String, duration: float) -> void:
	if _is_busy:
		push_warning("%s è già occupata." % station_name)
		return

	_is_busy = true
	_in_progress = true
	_current_item = item_name
	_current_result = result_name
	_taps_done = 0
	_taps_required = max(3, int(round(duration * 2.0)))
	work_started.emit(item_name)
	progress_updated.emit(0.0)
	if ready_prompt:
		ready_prompt.text = "👆"
		ready_prompt.visible = true

func _register_tap() -> void:
	_taps_done += 1
	progress_updated.emit(clampf(float(_taps_done) / float(_taps_required), 0.0, 1.0))
	if _taps_done >= _taps_required:
		_complete_work()

func _complete_work() -> void:
	_is_busy = false
	_in_progress = false
	if ready_prompt:
		ready_prompt.visible = false
	work_completed.emit(_current_item, _current_result)
	_current_item = ""
	progress_updated.emit(0.0)

func is_busy() -> bool:
	return _is_busy
