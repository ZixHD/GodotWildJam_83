extends Node2D

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var background_music: AudioStreamPlayer = $BackgroundMusic


func _ready() -> void:
	$BackgroundMusic.play()

func _on_spikes_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage()
	else:
		body._on_hit()
