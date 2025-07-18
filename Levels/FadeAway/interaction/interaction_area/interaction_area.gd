extends Area2D
class_name InteractionArea

var interact: Callable = func():
	pass


func _on_body_entered(_body: Node2D) -> void:
	InteractionManager.register_area(self)
	pass # Replace with function body.


func _on_body_exited(_body: Node2D) -> void:
	InteractionManager.unregister_area(self)
	pass # Replace with function body.
