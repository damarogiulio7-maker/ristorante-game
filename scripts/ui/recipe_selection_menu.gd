extends Control
class_name RecipeSelectionMenu

## Menu di selezione ricette per il giocatore.
## Appare quando la cameriera arriva al tavolo e permette al giocatore di scegliere cosa preparare.

signal recipe_selected(recipe: Recipe)
signal menu_cancelled

var recipes: Array[Recipe] = []
var current_table: TableSpot = null
var game_config: GameConfig

var _recipe_buttons: Array[Button] = []

@onready var title_label: Label = $VBoxContainer/TitleLabel if has_node("VBoxContainer/TitleLabel") else null
@onready var recipes_container: VBoxContainer = $VBoxContainer/RecipesContainer if has_node("VBoxContainer/RecipesContainer") else null
@onready var cancel_button: Button = $VBoxContainer/CancelButton if has_node("VBoxContainer/CancelButton") else null

func _ready() -> void:
	# Carica il config
	var root = get_tree().root.get_child(0)
	if root.has_meta("config"):
		game_config = root.get_meta("config")
	else:
		game_config = GameConfig.new()
	
	visible = false
	
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)

func show_menu(table: TableSpot, available_recipes: Array[Recipe]) -> void:
	current_table = table
	recipes = available_recipes
	
	# Aggiorna il titolo
	if title_label:
		title_label.text = "Scegli il piatto da preparare"
	
	# Crea i bottoni per le ricette
	_create_recipe_buttons()
	
	visible = true
	# Metti il focus sul primo bottone
	if _recipe_buttons.size() > 0:
		_recipe_buttons[0].grab_focus()

func hide_menu() -> void:
	visible = false
	_clear_recipe_buttons()

func _create_recipe_buttons() -> void:
	_clear_recipe_buttons()
	
	if not recipes_container:
		return
	
	for recipe in recipes:
		var button = Button.new()
		button.text = "%s - %d€ [Diff: %d]" % [recipe.recipe_name, recipe.sale_price, recipe.difficulty]
		button.pressed.connect(func(): _on_recipe_selected(recipe))
		button.custom_minimum_size = Vector2(200, 40)
		recipes_container.add_child(button)
		_recipe_buttons.append(button)

func _clear_recipe_buttons() -> void:
	for button in _recipe_buttons:
		button.queue_free()
	_recipe_buttons.clear()

func _on_recipe_selected(recipe: Recipe) -> void:
	recipe_selected.emit(recipe)
	hide_menu()

func _on_cancel_pressed() -> void:
	menu_cancelled.emit()
	hide_menu()
