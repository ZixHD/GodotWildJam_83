extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("slide_in")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		var game_manager = get_tree().get_root().get_node("Gm")
		game_manager.next_scene()
