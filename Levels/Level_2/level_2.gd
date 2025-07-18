extends Node2D




func _on_level_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_2_end()
