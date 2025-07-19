extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	$AudioStreamPlayer.play()
	var camera = $Player/Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 384
	camera.limit_right = 1680
	$TheMoon/Sprite2D.visible = false

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_3_end()
