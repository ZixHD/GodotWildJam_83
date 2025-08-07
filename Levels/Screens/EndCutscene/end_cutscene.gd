extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("slide_in")
	await animation_player.animation_finished

func return_to_normal() -> void:
	animation_player.play_backwards("slide_in")
