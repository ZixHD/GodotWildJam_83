extends Node

@onready var player: CharacterBody2D = $Player
@onready var camera_2d: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $Player/AnimationPlayer
@onready var canvas_animator: AnimationPlayer = $TransitionScreen/AnimationPlayer


func _ready() -> void:
	_move_player()
	
func _move_player() -> void:
	var tween = create_tween()
	var target_position = player.global_position + Vector2(225, 0)
	animation_player.play("walk R")
	tween.tween_property(player, "global_position", target_position, 2)
	await tween.finished
	tween.stop()
	tween = create_tween()
	animation_player.play("front walk")
	canvas_animator.play("fade_to_black")
	target_position = player.global_position + Vector2(0, 100)
	tween.tween_property(player, "global_position", target_position, 1)
