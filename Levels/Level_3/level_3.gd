extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_position: Marker2D = $PlayerPosition
@onready var boss_walk: AudioStreamPlayer2D = $BossWalk
@onready var shake_timer: Timer = $ShakeTimer

@export var Scale : float = 0.2;
@export var randomStrength: float = 5.0;
@export var shakeFade: float = 50.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var camera_loaded: bool = false;

func apply_shake():
	shake_strength = randomStrength
	
func random_offset() -> Vector2:
	var strength = randomStrength
	return Vector2(rng.randf_range(-strength, strength), rng.randf_range(-strength, strength))
	
func _ready() -> void:
	audio_stream_player.play()
	_load_dialogue()
	var camera = $Player/Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 384
	camera.limit_right = 1680
	$TheMoon/Sprite2D.visible = false
	shake_timer.timeout.connect(on_shake)
	shake_timer.wait_time = 0.25
	
func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.on_level_3_end(player_position.global_position)
		await get_tree().create_timer(2).timeout
		boss_walk.play()
		var camera = $Camera2D
		camera_loaded = true
		shake_timer.start()
		apply_shake() 
		
func on_shake() -> void:
	$Camera2D.offset = $Camera2D.offset.lerp(random_offset(), 0.4)

func _physics_process(delta: float) -> void:
	if camera_loaded:
		if shake_strength > 0:
			shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
			$Camera2D.offset = random_offset()
		else:
			$Camera2D.offset = Vector2.ZERO
	
func _load_dialogue() -> void:
	var json_file: String = "res://Utils/Dialogue/Json/Level_3/level_3.json";
	DialogueManager.load_dialog_data(json_file)
	var dialogue: Array[Dictionary] = DialogueManager.get_message()
	#for dia in dialogue:
		#Textbox.queue_text(dia)
