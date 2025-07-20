extends Node

@onready var player: CharacterBody2D = $Player
@onready var camera_2d: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $Player/AnimationPlayer
@onready var canvas_animator: AnimationPlayer = $TransitionScreen/AnimationPlayer
@onready var first_stop: Marker2D = $FirstStop
@onready var second_stop: Marker2D = $SecondStop

var moving: bool = false;
signal dialog_finished
	
func _ready() -> void:
	canvas_animator.play("fade_to_normal")
	await canvas_animator.animation_finished
	_load_dialogue()
	Textbox.connect("dialog_finished", Callable(self, "can_move"))
	
func _process(delta: float) -> void:
	if moving:
		moving = false
		_move_player()
	
func can_move() -> void:
	moving = true
	
func _move_player() -> void:
	var tween = create_tween()
	animation_player.play("walk R")
	tween.tween_property(player, "global_position", first_stop.global_position, 3)
	await tween.finished
	tween.stop()
	tween = create_tween()
	animation_player.play("front walk")
	canvas_animator.play("fade_to_black")
	tween.tween_property(player, "global_position", second_stop.global_position, 1)
	await tween.finished
	_transition()
	
func _load_dialogue() -> void:
	var json_file: String = "res://Utils/Dialogue/Json/Level_F/level_f.json"
	DialogueManager.load_dialog_data(json_file)
	var dialogue: Array[Dictionary] = DialogueManager.get_message()
	for dia in dialogue:
		Textbox.queue_text(dia)
		
func _transition() -> void:
	var game_manager = get_tree().get_root().get_node("Gm")
	game_manager.load_credits()
