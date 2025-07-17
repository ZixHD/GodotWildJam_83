extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D
var lamp_on: bool = 0
var can_add_text: bool = true;
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	Textbox.dialog_started.connect(_on_dialog_started)
	Textbox.dialog_finished.connect(_on_dialog_finished)
	
func _on_dialog_started():
	can_add_text = false
	
func _on_dialog_finished():
	can_add_text = true
	
func _on_interact():
	var text: Array[Dictionary] = DialogManager.get_message("lamp");
	print("txt", text)
	print(text)
	if(can_add_text):
		if lamp_on:
			Textbox.queue_text(text[1])
			Textbox.queue_text(text[2])
		else:
			Textbox.queue_text(text[0])
		
	lamp_on = !lamp_on
	sprite_2d.frame = lamp_on
	
	
