extends Node2D
class_name StationProgressBar

## Barra visiva che mostra il progresso di lavorazione della stazione a cui
## è agganciata (nodo genitore). Nascosta quando la stazione è libera.

@onready var fill: ColorRect = $Fill

func _ready() -> void:
	var station: Node = get_parent()
	if station and station.has_signal("progress_updated"):
		station.progress_updated.connect(_on_progress)
		station.work_started.connect(_on_started)
		station.work_completed.connect(_on_completed)
	visible = false

func _on_started(_item_name: String) -> void:
	visible = true

func _on_progress(fraction: float) -> void:
	fill.offset_right = -30.0 + 60.0 * fraction

func _on_completed(_item_name: String, _result_name: String) -> void:
	visible = false
