extends Node

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	player.visible = true;
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)
	

func _on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door_" + destination_tag;
	var door = get_node(door_path) as Door
	NavigationManager.trigger_player_spawn(door.get_node("Spawn").global_position, door.spawn_direction)
