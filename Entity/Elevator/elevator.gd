extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody2D = $"../Player"
@onready var player_position: Marker2D = $PlayerPosition


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_end()
#		play the animation of the elevator closing
#		on animation_finished emit the signal and call GameManager.next_scene
		animation_player.play("door_open")
		player.global_position = player_position.global_position
		var running_dust_timer = Timer.new()
		running_dust_timer.wait_time = 2
		running_dust_timer.one_shot = true
		running_dust_timer.autostart = true
		add_child(running_dust_timer)
		running_dust_timer.start()
		running_dust_timer.timeout.connect(_close_door)

func _close_door() -> void:
	animation_player.play_backwards("door_open")
	var running_dust_timer = Timer.new()
	running_dust_timer.wait_time = 1.2
	running_dust_timer.one_shot = true
	running_dust_timer.autostart = true
	add_child(running_dust_timer)
	running_dust_timer.start()
	running_dust_timer.timeout.connect(_transition)

	
func _transition() -> void:
	GameManager.load_transition()
