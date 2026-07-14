extends Control

## Menu principale del gioco. Punto di ingresso definito in project.godot.

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/kitchen/kitchen_main.tscn")
