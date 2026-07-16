extends Node2D
class_name IngredientTray

## Una vaschetta di ingrediente sul bancone. Cliccabile: quando ci clicchi
## sopra, avvisa il gioco di che ingrediente hai scelto.

@export var ingredient_name: String = ""

signal tray_clicked(ingredient_name: String)

@onready var click_area: Area2D = $ClickArea

func _ready() -> void:
	click_area.input_event.connect(_on_input)
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)

func _on_input(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tray_clicked.emit(ingredient_name)

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
