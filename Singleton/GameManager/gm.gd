extends Node

const LEVEL_1 = preload("res://Levels/Level_1/level_1.tscn")
const LEVEL_2 = preload("res://Levels/Level_2/level_2.tscn")
const LEVEL_3 = preload("res://Levels/Level_3/level_3.tscn")
const END_CREDITS = preload("res://Levels/Screens/EndCredits/end_credits.tscn")
const END_CUTSCENE = preload("res://Levels/Screens/EndCutscene/end_cutscene.tscn")
const INTRO_SCREEN = preload("res://Levels/Screens/IntroScreen/intro_screen.tscn")
const MAIN_MENU = preload("res://Levels/Screens/MainMenu/main_menu.tscn")
const RETRY_SCREEN = preload("res://Levels/Screens/RetryScreen/retry_screen.tscn")
const TRANSITION_SCREEN = preload("res://Levels/Screens/TransitionScreen/transition_screen.tscn")
const LEVEL_F = preload("res://Levels/ChildRoom/child_room.tscn")
const WILD_CARD = preload("res://UI/Wildcard/wild_card.tscn")
const POWER_UP_TIMER = 10.0

var score_multiplier = 0
var level_timer = 0
var scene_index: int = 0;
var score = 0
var scenes: Array[PackedScene] = [
	WILD_CARD, MAIN_MENU, INTRO_SCREEN, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_F
]
var current_scene_instance: Node = null
var transition_instance: Node = null
var retry_instance: Node = null
var child_room = null
signal next_level
signal retry

func _ready() -> void:
	load_scene(scene_index)

func load_scene(index: int) -> void:

	if current_scene_instance:
		current_scene_instance.queue_free()
	if transition_instance:
		transition_instance.queue_free()
	if index != 0:
		_load_dialogue(index)
	current_scene_instance = scenes[index].instantiate()
	add_child(current_scene_instance)
	
func _load_dialogue(index: int) -> void:
	var json_file: String = "res://Utils/Dialogue/Json/Level_" + str(index) + "/level_" + str(index) + ".json";
	#DialogueManager.load_dialog_data(json_file)
	#var dialogue: Array[Dictionary] = DialogueManager.get_message()
	#for dia in dialogue:
		#Textbox.queue_text(dia)
	
	
	
func next_scene() -> void:
	scene_index += 1
	load_scene(scene_index)
#	get the new scene after removing current
func load_transition() -> void:
	transition_instance = TRANSITION_SCREEN.instantiate()
	add_child(transition_instance)
	var gm = get_tree().get_root().get_node("Gm")
	var level = gm.get_node("Level_" + str(scene_index - 2))
	if level:
		level.queue_free()
	else:
		print("Level" + str(scene_index - 1) + " node not found!")
	
func load_retry_scene() -> void:
	retry_instance = RETRY_SCREEN.instantiate()
	add_child(retry_instance)
	var root = get_tree().root
	var gm = get_tree().get_root().get_node("Gm")
	var level = gm.get_node("Level_" + str(scene_index - 2))
	level.queue_free()
	
func retry_level() -> void:
	if retry_instance:
		retry_instance.queue_free()
	self.load_scene(scene_index)
	
func load_childroom() -> void:
	if current_scene_instance:
		current_scene_instance.queue_free()
	child_room = LEVEL_F.instantiate() 
	add_child(child_room)

func load_credits() -> void:
	if child_room:
		child_room.queue_free()
	const END_CREDITS = preload("res://Levels/Screens/EndCredits/end_credits.tscn")
	var end = END_CREDITS.instantiate()
	add_child(end)
