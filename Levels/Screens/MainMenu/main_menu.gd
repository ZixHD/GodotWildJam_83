extends Control

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	audio_stream_player_2d.play()
func _on_play_pressed() -> void:
	var game_manager = get_tree().get_root().get_node("Gm")
	game_manager.next_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
