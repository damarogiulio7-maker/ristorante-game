extends Node2D
class_name StationProgressBar

## Barra visiva che mostra il progresso di lavorazione della stazione a cui
## è agganciata (nodo genitore), più un'icona che rimbalza mentre lavora.

@onready var fill: ColorRect = $Fill
@onready var activity_icon: Node2D = $"../ActivityIcon" if get_parent().has_node("ActivityIcon") else null

var _tween: Tween

func _ready() -> void:
	var station: Node = get_parent()
	if station and station.has_signal("progress_updated"):
		station.progress_updated.connect(_on_progress)
		station.work_started.connect(_on_started)
		station.work_completed.connect(_on_completed)
	visible = false
	if activity_icon:
		activity_icon.visible = false

func _on_started(_item_name: String) -> void:
	visible = true
	if activity_icon:
		activity_icon.visible = true
		_tween = create_tween().set_loops()
		_tween.tween_property(activity_icon, "scale", Vector2(1.3, 0.7), 0.2)
		_tween.tween_property(activity_icon, "scale", Vector2(0.85, 1.15), 0.2)
		_tween.tween_property(activity_icon, "scale", Vector2(1, 1), 0.15)

func _on_progress(fraction: float) -> void:
	fill.offset_right = -30.0 + 60.0 * fraction

func _on_completed(_item_name: String, _result_name: String) -> void:
	visible = false
	if _tween:
		_tween.kill()
	if activity_icon:
		activity_icon.visible = false
		activity_icon.scale = Vector2(1, 1)
