extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
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
	var text: Array[Dictionary] = DialogManager.get_message("bed");
	print(text)
	if(can_add_text):
		Textbox.queue_text(text)
	
