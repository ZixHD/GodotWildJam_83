extends Node

@onready var player: CharacterBody2D = $Player
@onready var camera_2d: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $Player/AnimationPlayer
@onready var canvas_animator: AnimationPlayer = $TransitionScreen/AnimationPlayer

var moving: bool = false;
signal dialog_finished
	
func _ready() -> void:
	Textbox.connect("dialog_finished", Callable(self, "can_move"))
	
func _process(delta: float) -> void:
	if moving:
		moving = false
		_move_player()
	
func can_move() -> void:
	moving = true
	
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
