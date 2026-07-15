extends Node2D
class_name Customer

## Un cliente del ristorante. Entra dalla porta, si siede a un tavolo libero,
## aspetta che la cameriera prenda l'ordine e porti il cibo, mangia, lascia i
## soldi sul tavolo ed esce. Le gambe scompaiono quando è seduto.

@export var move_speed: float = 140.0
@export var eating_time_seconds: float = 4.0

var assigned_table: TableSpot = null
var recipe: Recipe = null
var entry_position: Vector2 = Vector2.ZERO
var _eating_timer: float = 0.0
var _leaving: bool = false
var _is_seated: bool = false

@onready var leg_left: ColorRect = $LegLeft if has_node("LegLeft") else null
@onready var leg_right: ColorRect = $LegRight if has_node("LegRight") else null

func _process(delta: float) -> void:
	if _leaving:
		_set_seated(false)
		global_position = global_position.move_toward(entry_position, move_speed * delta)
		if global_position.distance_to(entry_position) < 4.0:
			queue_free()
		return

	if assigned_table == null:
		return

	if assigned_table.state == TableSpot.State.WAITING_ORDER or assigned_table.state == TableSpot.State.ORDER_TAKEN:
		var target: Vector2 = assigned_table.get_seat_position()
		global_position = global_position.move_toward(target, move_speed * delta)
		_set_seated(global_position.distance_to(target) < 4.0)

	elif assigned_table.state == TableSpot.State.EATING:
		_set_seated(true)
		_eating_timer += delta
		if _eating_timer >= eating_time_seconds:
			_finish_meal()

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
		var price: int = recipe.sale_price if recipe else 10
		assigned_table.leave_money(price)
	_leaving = true
