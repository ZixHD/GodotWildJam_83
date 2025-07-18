extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal on_transition_finished
signal on_pause
func _ready() -> void:
	color_rect.visible = true;
	animation_player.animation_finished.connect(_on_animation_finished)
	
func transition_to_scene():
	on_pause.emit()
	color_rect.visible = true
	animation_player.play("fade_to_black")
	
func _on_animation_finished(animation_name):
	print("ovde")
	if animation_name == "fade_to_black":
		on_transition_finished.emit()
		animation_player.play("fade_to_normal")
	elif animation_name == "fade_to_normal":
		color_rect.visible = false;
