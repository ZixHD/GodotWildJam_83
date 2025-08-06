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


var score_multiplier = 0
var level_timer = 0
var scene_index: int = -1;
var score = 0
var scenes: Array[PackedScene] = [
   MAIN_MENU, INTRO_SCREEN, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_F
]
var current_scene_instance = null
var transition_instance = null
var retry_instance = null
var child_room = null
signal next_level
signal retry


func load_scene(index: int) -> void:

	
	current_scene_instance = scenes[index]
	get_tree().change_scene_to_packed(current_scene_instance)
	if index > 3:
		Textbox.set_font()
	

	
	
func next_scene() -> void:
	scene_index += 1
	load_scene(scene_index)
	
func load_retry_scene() -> void:
	retry_instance = RETRY_SCREEN
	get_tree().change_scene_to_packed(retry_instance)
	

	
func retry_level() -> void:
	self.load_scene(scene_index)
	
func load_childroom() -> void:
	child_room = LEVEL_F
	get_tree().change_scene_to_packed(child_room)

func load_credits() -> void:

	const END_CREDITS = preload("res://Levels/Screens/EndCredits/end_credits.tscn")
	var end = END_CREDITS
	get_tree().change_scene_to_packed(end)
