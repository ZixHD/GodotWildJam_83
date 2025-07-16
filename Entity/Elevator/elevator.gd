extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
#		play the animation of the elevator closing
#		on animation_finished emit the signal and call GameManager.next_scene
		var running_dust_timer = Timer.new()
		running_dust_timer.wait_time = 5
		running_dust_timer.one_shot = true
		running_dust_timer.autostart = true
		add_child(running_dust_timer)
		running_dust_timer.timeout.connect(_transition)

func _transition() -> void:
	GameManager.load_transition()
