extends Node


const LEVEL_1 = preload("res://Levels/Level_1/level_1.tscn")
const LEVEL_2 = preload("res://Levels/Level_2/level_2.tscn")
const LEVEL_3 = preload("res://Levels/Level_3/level_3.tscn")
const LEVEL_F = preload("res://Levels/ChildRoom/child_room.tscn")
const TRANSITION_SCREEN = preload("res://Levels/Screens/TransitionScreen/transition_screen.tscn")
const RETRY_SCREEN = preload("res://Levels/Screens/RetryScreen/retry_screen.tscn")
const level2_json = "res://Utils/Dialogue/Json/Level_2/level_2.json"
const level3_json = "res://Utils/Dialogue/Json/Level_3/level_3.json"
const levelf_json = "res://Utils/Dialogue/Json/Level_F/level_F.json"
const POWER_UP_TIMER = 10.0

var score_multiplier = 0
var level_timer = 0
var scene_index: int = 0;
var score = 0
var scenes: Array[PackedScene] = [
	LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_F
]
var current_scene_instance: Node = null
var transition_instance: Node = null
var retry_instance: Node = null
signal next_level
signal retry

func _ready() -> void:
	#load_scene(3)
	print("wigga")
	
func load_scene(index: int) -> void:
	if current_scene_instance:
		current_scene_instance.queue_free()
	if transition_instance:
		transition_instance.queue_free()
	_load_dialogue(index)
	current_scene_instance = scenes[index].instantiate()
	add_child(current_scene_instance)
	
func _load_dialogue(index: int) -> void:
	var json_file: String = "res://Utils/Dialogue/Json/Level_" + str(index) + "/level_" + str(index) + ".json";
	DialogueManager.load_dialog_data(json_file)
	var dialogue: Array[Dictionary] = DialogueManager.get_message()
	for dia in dialogue:
		Textbox.queue_text(dia)
	
	
	
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
