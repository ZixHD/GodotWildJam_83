extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	_transition()
	
func _transition() -> void:
	var game_manager = get_tree().get_root().get_node("Gm")
	game_manager.next_scene()
