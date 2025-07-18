extends Node2D




func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_3_end()
