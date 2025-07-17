extends Node2D
@onready var player: CharacterBody2D = $Player


func _on_spikes_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage()
	else:
		body._on_hit()
