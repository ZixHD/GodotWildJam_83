extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level_1/level_1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
