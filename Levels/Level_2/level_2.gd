extends Node2D

@onready var background_music: AudioStreamPlayer = $BackgroundMusic

func _ready() -> void:
	$BackgroundMusic.play()
	var camera = $Player/Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 1488
	camera.limit_right = 1680

func _on_level_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_2_end()
