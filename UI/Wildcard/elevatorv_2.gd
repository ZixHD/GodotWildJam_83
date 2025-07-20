extends Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D




func play_sound() -> void:
	audio_stream_player_2d.play()
	



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.set_level_end()
