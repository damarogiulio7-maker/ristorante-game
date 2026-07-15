extends Node2D
class_name TableSpot

## Un tavolo della sala. Tiene lo stato di occupazione, mostra il piatto
## quando il cliente sta mangiando, e i soldi lasciati alla fine del pasto.
## Cliccabile col mouse per raccogliere i soldi.

enum State { EMPTY, WAITING_ORDER, ORDER_TAKEN, FOOD_READY, EATING, DIRTY_WITH_MONEY }

@export var seat_offset: Vector2 = Vector2(0, -10)

signal money_available(table: TableSpot, amount: int)
signal money_collected(table: TableSpot, amount: int)

var state: State = State.EMPTY
var current_customer: Node2D = null
var money_amount: int = 0

var _last_state: State = State.EMPTY

@onready var click_area: Area2D = $ClickArea if has_node("ClickArea") else null
@onready var money_icon: Label = $MoneyIcon if has_node("MoneyIcon") else null
@onready var plate_icon: Node2D = $PlateIcon if has_node("PlateIcon") else null

func _ready() -> void:
	if click_area:
		click_area.input_event.connect(_on_click_area_input)
		click_area.mouse_entered.connect(_on_mouse_entered)
		click_area.mouse_exited.connect(_on_mouse_exited)
	if plate_icon:
		plate_icon.visible = false

func _on_mouse_entered() -> void:
	if state == State.DIRTY_WITH_MONEY:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _process(_delta: float) -> void:
	if state != _last_state:
		_last_state = state
		if plate_icon:
			plate_icon.visible = (state == State.EATING)

func get_seat_position() -> Vector2:
	return global_position + seat_offset

func is_free() -> bool:
	return state == State.EMPTY

func leave_money(amount: int) -> void:
	money_amount = amount
	state = State.DIRTY_WITH_MONEY
	if money_icon:
		money_icon.text = "💰%d€" % amount
		money_icon.visible = true
	money_available.emit(self, amount)

func _on_click_area_input(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state == State.DIRTY_WITH_MONEY:
			_collect_money()

func _collect_money() -> void:
	money_collected.emit(self, money_amount)
	money_amount = 0
	state = State.EMPTY
	if money_icon:
		money_icon.visible = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
