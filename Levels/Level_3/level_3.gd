extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_position: Marker2D = $PlayerPosition
@onready var boss_walk: AudioStreamPlayer2D = $BossWalk
@onready var shake_timer: Timer = $ShakeTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var Scale : float = 0.2;
@export var randomStrength: float = 5.0;
@export var shakeFade: float = 50.0

const CANVAS_LAYER = preload("res://Levels/Screens/EndCutscene/end_cutscene.tscn")

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var camera_loaded: bool = false;
var dialogue_num: int = 0
var end_cutscene = null
var stop_shake: bool = false
var shake_time = 0.0
var shake_duration = 0.2


func _ready() -> void:
	audio_stream_player.play()
	var camera = $Player/Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 384
	camera.limit_right = 1680
	$TheMoon/Sprite2D.visible = false
	shake_timer.timeout.connect(trigger_shake)
	shake_timer.wait_time = 0.25
	Textbox.connect("dialog_finished", Callable(self, "on_dialog_finished"));
	
func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		end_cutscene = CANVAS_LAYER.instantiate()
		add_child(end_cutscene)
		body.on_level_3_end(player_position.global_position)
		await get_tree().create_timer(1.8).timeout
		boss_walk.play()
		var camera = $Camera2D
		camera_loaded = true
		shake_timer.start()
		await get_tree().create_timer(7).timeout
		_load_dialogue(dialogue_num)
		
func _process(delta: float) -> void:
	if camera_loaded and !stop_shake:
		if shake_time > 0:
			shake_time -= delta
			var intensity = shake_strength * (shake_time / shake_duration) # fades out
			var offset = Vector2(
				rng.randf_range(-intensity, intensity),
				rng.randf_range(-intensity, intensity)
			)
			$Camera2D.offset = offset
		else:
			$Camera2D.offset = Vector2.ZERO

func trigger_shake() -> void:
	shake_strength = randomStrength
	shake_time = shake_duration

func _load_dialogue(num: int) -> void:
	var json_file: String = ""
	if num == 0:
		json_file = "res://Utils/Dialogue/Json/Level_3/level_30.json";
	else:
		json_file = "res://Utils/Dialogue/Json/Level_3/level_31.json";
	DialogueManager.load_dialog_data(json_file)
	var dialogue: Array[Dictionary] = DialogueManager.get_message()
	for dia in dialogue:
		Textbox.queue_text(dia)
		
func on_dialog_finished() -> void:
	if dialogue_num == 0:
		dialogue_num = 1
		await get_tree().create_timer(2).timeout
		remove_child(end_cutscene)
		stop_shake = true
		audio_stream_player.stop()
		boss_walk.stop()
		_load_dialogue(dialogue_num)
	else:
		print("next scene")
		animation_player.play("fade_to_black")
		await animation_player.animation_finished
		_transition()
		
func _transition() -> void:
	var game_manager = get_tree().get_root().get_node("Gm")
	game_manager.load_childroom()
	
