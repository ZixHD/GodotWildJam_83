extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var picture_1: TextureRect = $Picture_1
@onready var picture_2: TextureRect = $Picture_2
@onready var picture_3: TextureRect = $Picture_3
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var index: int = 0;
var can_play: bool = false;

func _ready() -> void:
	_load_dialogue()
	audio_stream_player_2d.play()
	Textbox.connect("dialog_finished", Callable(self, "_play"))
	
func _process(delta: float) -> void:
	if can_play:
		animation_player.play("Intro_" + str(index))
		index += 1
		if index <= 2:
			_load_dialogue()
		can_play = false;
	await animation_player.animation_finished
	if index == 1:
		picture_1.visible = false;
	elif index == 2:
		picture_2.visible = false;
	elif index == 3:
		picture_3.visible = false;


func _play() -> void:
	can_play = true;

func play_next_scene() -> void:
	var game_manager = get_tree().get_root().get_node("Gm")
	game_manager.next_scene()
	
func _load_dialogue() -> void:
	var json_file: String = "res://Utils/Dialogue/Json/Level_0/level_0" + str(index) + ".json";
	DialogueManager.load_dialog_data(json_file)
	var dialogue: Array[Dictionary] = DialogueManager.get_message()
	for dia in dialogue:
		Textbox.queue_text(dia)

	

	
	
