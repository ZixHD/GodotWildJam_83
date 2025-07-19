extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody2D = $"../Player"
@onready var player_position: Marker2D = $PlayerPosition
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var door_closing = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_1_end()
#		play the animation of the elevator closing
#		on animation_finished emit the signal and call GameManager.next_scene
		animation_player.play("door_open")
		#player.global_position = player_position.global_position
		var running_dust_timer = Timer.new()
		running_dust_timer.wait_time = 2
		running_dust_timer.one_shot = true
		running_dust_timer.autostart = true
		add_child(running_dust_timer)
		running_dust_timer.start()
		running_dust_timer.timeout.connect(_close_door)

func _close_door() -> void:
	door_closing = true
	self.z_index = 1
	animation_player.play_backwards("door_open")
	await animation_player.animation_finished
	animation_player.play("idle")
	var elevator_timer = Timer.new()
	elevator_timer.wait_time = 1.2
	elevator_timer.one_shot = true
	elevator_timer.autostart = true
	add_child(elevator_timer)
	elevator_timer.start()
	elevator_timer.timeout.connect(_transition)

	
func _transition() -> void:
	GameManager.load_transition()

func playSound() -> void:
	if !door_closing:
		audio_stream_player_2d.play()
