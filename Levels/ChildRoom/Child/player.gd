extends CharacterBody2D

class_name Player

@onready var animation: AnimationPlayer = $AnimationPlayer
@export var speed: float = 150.0

enum state {IDLE_RIGHT, IDLE_LEFT, IDLE_UP, IDLE_DOWN, WALK_RIGHT, WALK_LEFT, WALK_UP, WALK_DOWN, PAUSED}
var player_state = state.IDLE_RIGHT
var input: Vector2 = Vector2.ZERO
var last_state_before_reading: state = state.IDLE_RIGHT;

func _ready() -> void:
	TransitionScreen.on_pause.connect(_on_pause_started)
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	Textbox.dialog_started.connect(_on_pause_started)
	Textbox.dialog_finished.connect(_on_pause_finished)
	
func update_animation() -> void:
	match(player_state):
		state.IDLE_RIGHT:
			animation.play("idle right")
		state.IDLE_LEFT:
			animation.play("idle left")
		state.IDLE_UP:
			animation.play("idle back")
		state.IDLE_DOWN:
			animation.play("idle front")
		state.WALK_RIGHT:
			animation.play("walk R")
			player_state = state.IDLE_RIGHT
		state.WALK_LEFT:
			animation.play("walk L")
			player_state = state.IDLE_LEFT
		state.WALK_UP:
			animation.play("walk back")
			player_state = state.IDLE_UP
		state.WALK_DOWN:
			animation.play("front walk")
			player_state = state.IDLE_DOWN
		state.PAUSED:
			_readingAnimations(last_state_before_reading)
			velocity = Vector2.ZERO  
			
		
func _readingAnimations(last_state: state):

	match(last_state):
		state.IDLE_RIGHT:
			animation.play("idle right")
		state.IDLE_LEFT:
			animation.play("idle left")
		state.IDLE_UP:
			animation.play("idle back")
		state.IDLE_DOWN:
			animation.play("idle front")
		state.WALK_RIGHT:
			animation.play("idle right")
		state.WALK_LEFT:
			animation.play("idle left")
		state.WALK_UP:
			animation.play("idle back")
		state.WALK_DOWN:
			animation.play("idle front")
	
	
	
func _process(delta: float) -> void:
	if(player_state != state.PAUSED):
		movement(delta)
	

func movement(_delta:float) -> void:
	input.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	if(Input.is_action_pressed("left")):
		player_state = state.WALK_LEFT
	if Input.is_action_pressed("right"):
		player_state = state.WALK_RIGHT
	if Input.is_action_pressed("down"):
		player_state = state.WALK_DOWN
	if Input.is_action_pressed("up"):
		player_state = state.WALK_UP
		
	
	input = input.normalized();
	velocity = input * speed
	move_and_slide()
	update_animation()
	
func _on_pause_started():
	last_state_before_reading = player_state
	player_state = state.PAUSED 
	update_animation()

func _on_pause_finished():
	player_state = last_state_before_reading;

func _on_spawn(position: Vector2, direction: String):
	global_position = position
	match(direction):
		"up":
			player_state = state.IDLE_UP
		"down":
			player_state = state.IDLE_DOWN
		"left":
			player_state = state.IDLE_LEFT
		"right":
			player_state = state.IDLE_RIGHT
			
			
