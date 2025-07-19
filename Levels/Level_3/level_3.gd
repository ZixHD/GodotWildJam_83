extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	$AudioStreamPlayer.play()


func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_3_end()
