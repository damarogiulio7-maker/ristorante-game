extends Resource
class_name Recipe

## Definisce un piatto: nome, ingredienti richiesti, tempo di preparazione, valore.
## Ogni ricetta va salvata come file .tres nella cartella resources/recipes/

@export var recipe_name: String = ""
@export var ingredients: Array[String] = []
@export var prep_time_seconds: float = 5.0
@export var sale_price: int = 10
@export var difficulty: int = 1  # 1 = facile, 5 = molto difficile
