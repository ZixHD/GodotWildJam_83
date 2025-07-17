extends Node


@export_range(0, 1) var player_health
const LEVEL_1 = preload("res://Levels/Level_1/level_1.tscn")
const TRANSITION_SCREEN = preload("res://Levels/TransitionScreen/transition_screen.tscn")
const RETRY_SCREEN = preload("res://Levels/RetryScreen/retry_screen.tscn")
const POWER_UP_TIMER = 10.0
#player_healh
var score_multiplier = 0
var level_timer = 0
var scene_index: int = 0;
var score = 0
var scenes: Array[PackedScene] = [
	LEVEL_1
]
var current_scene_instance: Node = null
var transition_instance: Node = null
var retry_instance: Node = null
signal next_level
signal retry

#func _ready() -> void:
	#load_scene(0)
	
func load_scene(index: int) -> void:
	if current_scene_instance:
		current_scene_instance.queue_free()
	if transition_instance:
		transition_instance.queue_free()
	current_scene_instance = scenes[index].instantiate()
	add_child(current_scene_instance)
	
func next_scene() -> void:
	scene_index += 1
	load_scene(0)
#	get the new scene after removing current
func load_transition() -> void:
	transition_instance = TRANSITION_SCREEN.instantiate()
	add_child(transition_instance)
	var root = get_tree().root
	var level1 = root.get_node("Level_1")
	level1.queue_free()
	
func load_retry_scene() -> void:
	retry_instance = RETRY_SCREEN.instantiate()
	add_child(retry_instance)
	var root = get_tree().root
	var level1 = root.get_node("Level_1")
	level1.queue_free()
	
func retry_level() -> void:
	if retry_instance:
		retry_instance.queue_free()
	
	self.load_scene(0)
									 
