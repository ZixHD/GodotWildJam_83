extends Node2D

@onready var background_music: AudioStreamPlayer = $BackgroundMusic

func _ready() -> void:
	$BackgroundMusic.play()

func _on_level_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_2_end()
