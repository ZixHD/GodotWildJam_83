extends StaticBody2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player_2: AnimationPlayer = $"../EndCutscene/AnimationPlayer2"




func _ready() -> void:
	open_elevator()


func open_elevator() -> void:
	const CANVAS_LAYER = preload("res://Levels/Screens/EndCutscene/end_cutscene.tscn")
	var end_cutscene = CANVAS_LAYER.instantiate()
	add_child(end_cutscene)
	self.z_index = 1
	player.set_level_end()
	animation_player.play("idle")
	audio_stream_player_2d.play()
	await get_tree().create_timer(1).timeout
	animation_player.play("door_open")
	animation_player_2.play("slide_out")
	end_cutscene.return_to_normal()
	await animation_player.animation_finished
	self.z_index = 0
	player.set_level_end()
	await get_tree().create_timer(1).timeout
	animation_player.play_backwards("door_open")
