extends Node2D
class_name CounterGame

## Il gioco vero: un cliente alla volta mostra un ordine (lista di
## ingredienti in un certo ordine). Il giocatore clicca le vaschette giuste
## in sequenza per comporre il piatto. Quando è completo, il cliente paga
## e ne arriva uno nuovo.

const INGREDIENT_COLORS := {
	"pasta": Color(0.93, 0.85, 0.6),
	"pomodoro": Color(0.8, 0.22, 0.15),
	"basilico": Color(0.25, 0.55, 0.25),
	"branzino": Color(0.78, 0.82, 0.86),
	"limone": Color(0.92, 0.86, 0.2),
	"olio": Color(0.75, 0.63, 0.18),
}

@onready var money_label: Label = $HUD/MoneyLabel
@onready var reputation_label: Label = $HUD/ReputationLabel
@onready var status_label: Label = $HUD/StatusLabel
@onready var order_label: Label = $OrderBubble/OrderLabel
@onready var plate_container: Node2D = $Plate/Items

var recipes: Array[Recipe] = []
var money: int = 100
var reputation: int = 50
var current_recipe: Recipe = null
var progress_index: int = 0

func _ready() -> void:
	for recipe_path in [
		"res://resources/recipes/pasta_pomodoro.tres",
		"res://resources/recipes/branzino_forno.tres",
	]:
		recipes.append(load(recipe_path))

	for tray in $Trays.get_children():
		if tray is IngredientTray:
			tray.tray_clicked.connect(_on_tray_clicked)

	_update_hud()
	_new_order()

func _new_order() -> void:
	current_recipe = recipes[randi() % recipes.size()]
	progress_index = 0
	_clear_plate()
	_update_order_display()
	status_label.text = ""

func _update_order_display() -> void:
	var parts: PackedStringArray = []
	for ingredient in current_recipe.ingredients:
		parts.append(ingredient)
	order_label.text = "%s vuole: %s" % [current_recipe.recipe_name, " → ".join(parts)]

func _on_tray_clicked(ingredient_name: String) -> void:
	if current_recipe == null:
		return

	if ingredient_name == current_recipe.ingredients[progress_index]:
		_add_to_plate(ingredient_name)
		progress_index += 1
		if progress_index >= current_recipe.ingredients.size():
			_serve()
	else:
		_flash_wrong()

func _add_to_plate(ingredient_name: String) -> void:
	var icon := ColorRect.new()
	icon.size = Vector2(36, 36)
	icon.position = Vector2(plate_container.get_child_count() * 42, 0)
	icon.color = INGREDIENT_COLORS.get(ingredient_name, Color.WHITE)
	plate_container.add_child(icon)

func _clear_plate() -> void:
	for child in plate_container.get_children():
		child.queue_free()

func _flash_wrong() -> void:
	status_label.text = "Ingrediente sbagliato!"
	var tween: Tween = create_tween()
	tween.tween_property(plate_container, "modulate", Color(1, 0.4, 0.4), 0.1)
	tween.tween_property(plate_container, "modulate", Color(1, 1, 1), 0.2)

func _serve() -> void:
	money += current_recipe.sale_price
	reputation = clampi(reputation + 2, 0, 100)
	_update_hud()
	status_label.text = "Servito: %s (+%d€)" % [current_recipe.recipe_name, current_recipe.sale_price]
	current_recipe = null
	_clear_plate()
	order_label.text = "..."
	await get_tree().create_timer(1.0).timeout
	_new_order()

func _update_hud() -> void:
	money_label.text = "Soldi: %d€" % money
	reputation_label.text = "Reputazione: %d" % reputation
