extends Node2D
class_name WorkStation

## Rappresenta una stazione di lavoro in cucina (es. taglio, cottura).
## Quando un cuoco arriva, la stazione aspetta un click per iniziare, poi il
## giocatore deve continuare a cliccare per far procedere la preparazione
## (stile Cooking Mama/Overcooked) fino al completamento.
## MIGLIORAMENTO: Ora usa la difficoltà dalla ricetta e ha timeout.

signal work_started(item_name: String)
signal work_completed(item_name: String, result_name: String)
signal progress_updated(fraction: float)
signal player_start_requested
signal work_timeout(item_name: String)

@export var station_name: String = "Stazione"

var _is_busy: bool = false
var _in_progress: bool = false
var _waiting_for_first_click: bool = false
var _current_item: String = ""
var _current_result: String = ""
var _current_recipe: Recipe = null
var _work_duration: float = 0.0
var _taps_done: int = 0
var _taps_required: int = 3
var _timeout_timer: float = 0.0
var _max_timeout: float = 60.0
var game_config: GameConfig

@onready var click_area: Area2D = $ClickArea if has_node("ClickArea") else null
@onready var ready_prompt: Label = $ReadyPrompt if has_node("ReadyPrompt") else null

func _ready() -> void:
	# Carica il config
	var game_manager = get_tree().root.get_child(0).get_node_or_null("GameManager")
	if game_manager and game_manager.has_meta("config"):
		game_config = game_manager.get_meta("config")
	else:
		game_config = GameConfig.new()
	
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

func start_work(item_name: String, result_name: String, duration: float, recipe: Recipe = null) -> void:
	if _is_busy:
		push_warning("%s è già occupata." % station_name)
		return

	_is_busy = true
	_in_progress = true
	_current_item = item_name
	_current_result = result_name
	_current_recipe = recipe
	_work_duration = duration
	_taps_done = 0
	_timeout_timer = 0.0
	
	# Calcola tap richiesti usando il config e la difficoltà della ricetta
	if recipe:
		_taps_required = game_config.get_taps_required(recipe, duration)
	else:
		_taps_required = max(3, int(round(duration * game_config.work_station_base_taps_multiplier)))
	
	work_started.emit(item_name)
	progress_updated.emit(0.0)
	if ready_prompt:
		ready_prompt.text = "👆"
		ready_prompt.visible = true

func _process(delta: float) -> void:
	# Monitora il timeout se il lavoro è in corso
	if _in_progress and not _waiting_for_first_click:
		_timeout_timer += delta
		if _timeout_timer >= _max_timeout:
			_work_timeout()

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
	_current_recipe = null
	progress_updated.emit(0.0)

func _work_timeout() -> void:
	_is_busy = false
	_in_progress = false
	if ready_prompt:
		ready_prompt.visible = false
	work_timeout.emit(_current_item)
	push_warning("Timeout in %s durante la preparazione di %s" % [station_name, _current_item])
	_current_item = ""
	_current_recipe = null
	progress_updated.emit(0.0)

func is_busy() -> bool:
	return _is_busy
