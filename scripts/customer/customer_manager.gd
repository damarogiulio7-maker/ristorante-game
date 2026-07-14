extends Node
class_name CustomerManager

## Fa entrare clienti dalla porta a intervalli regolari, se c'è un tavolo libero.

@export var spawn_interval_seconds: float = 7.0

var tables: Array[TableSpot] = []
var door_position: Vector2 = Vector2.ZERO
var customer_scene: PackedScene
var customers_container: Node2D

var _timer: float = 0.0

func _process(delta: float) -> void:
	if customer_scene == null or customers_container == null:
		return
	_timer += delta
	if _timer >= spawn_interval_seconds:
		_timer = 0.0
		_try_spawn_customer()

func _try_spawn_customer() -> void:
	var free_table: TableSpot = _find_free_table()
	if free_table == null:
		return

	var customer: Customer = customer_scene.instantiate()
	customers_container.add_child(customer)
	customer.global_position = door_position
	customer.assigned_table = free_table

	free_table.state = TableSpot.State.WAITING_ORDER
	free_table.current_customer = customer

func _find_free_table() -> TableSpot:
	for table in tables:
		if table.is_free():
			return table
	return null
