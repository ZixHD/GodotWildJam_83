extends CharacterBody2D





@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1

@export_range(0, 1) var acceleration = 0.1;
@export_range(0, 1) var deceleration = 0.1;


#DASH
@export var dash_speed = 2000.0
@export var dash_max_distance = 200.0
@export var dash_curve: Curve
@export var dash_cooldown = 1.0

var is_dashing = false;
var dash_start_position = 0;
var dash_direction = 0;
var dash_timer = 0;
var dash_counter = 0;


const SPEED = 450.0
const AIR_SPEED = 350.0
const JUMP_VELOCITY = -600.0
const GRAVITY = 1500.0;
const FALL_GRAVITY = 2300;
const MAX_AIR_DASH = 1;

#coyote-time
var jump_buffer_timer: Timer;
var coyote_jump_timer: Timer;

#wall-slide
var is_wall_sliding = false;
var can_wall_jump = false;
var wall_slide_gravity = 100.0;
const wall_slide_jump_power = -500.0;
var reached_jump_peak = false;

#wall-jump
const wall_jump_pushback = 100;
const jump_power = -1000.0


#game-mechanics
const MAX_PLAYER_HEALTH = 1
enum state {RUNNING, IDLE, JUMPING, DASHING, SHOOTING, DEAD}

var player_state = state.IDLE
signal hit


func _update_animation() -> void:

	match(player_state):
		state.IDLE:
			print("IDLE")
		state.RUNNING:
			print("Running")
		state.DASHING:
			print("Dashing")
		state.JUMPING:
			print("Jumping")
		state.SHOOTING:
			print("Shooting")
		state.DEAD:
			print("Dead")

func _ready() -> void:
	jump_buffer_timer = Timer.new();
	add_child(jump_buffer_timer);
	jump_buffer_timer.one_shot = true;
	
	coyote_jump_timer = Timer.new();
	add_child(coyote_jump_timer);
	coyote_jump_timer.one_shot = true;

func _physics_process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_accept")):
		player_state = state.DEAD
	if player_state != state.DEAD:
		_moving(delta)
	#_update_animation()

func _moving(delta: float) -> void:
	if is_on_floor():
		if velocity.x == 0:
			player_state = state.IDLE;
		elif velocity.x <= 0 or velocity.x >= 0:
			player_state = state.RUNNING;
	if not is_on_floor() :
		#if velocity.y > 0:
			#reached_jump_peak = true;
		#
		#if(reached_jump_peak):
			#velocity.y += FALL_GRAVITY * delta
		#else:
		velocity.y += get_my_gravity(velocity) * delta
	
	
	wall_sliding(delta)
		
	if is_on_floor():
		reached_jump_peak = false
		dash_counter = MAX_AIR_DASH;
		if not coyote_jump_timer.is_stopped():
			
			coyote_jump_timer.stop()
	
	
	
	wall_jump(delta)	
	
	#if Input.is_action_just_released("jump") and velocity.y < 0:
		#velocity.y = JUMP_VELOCITY / 4;
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			player_state = state.JUMPING
		else:
			jump_buffer_timer.start(jump_buffer_time);
			
	if is_on_floor() and jump_buffer_timer.time_left > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer.stop()
		
	#if (!is_on_floor() and !coyote_jump_timer.is_stopped() and velocity.y < 0):
		#coyote_jump_timer.stop()
		#velocity.y = JUMP_VELOCITY
		
		

	var direction := Input.get_axis("left", "right")
		
	if direction:
		if(!is_on_floor()):
			velocity.x = move_toward(velocity.x, direction * AIR_SPEED, AIR_SPEED)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED)
		
		#velocity.x = direction * SPEED
	else:
		if(!is_on_floor()):
			velocity.x = move_toward(velocity.x, 0, AIR_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	var was_on_floor = is_on_floor();
	move_and_slide()
	if(was_on_floor && !is_on_floor() and coyote_jump_timer.is_stopped()) :
		coyote_jump_timer.start(coyote_time);
		
	#DASH
	dashing(direction, delta)
	
		
func dashing(direction, delta):
	
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		#if(!is_on_floor() and dash_counter > 0):
			#is_dashing = true
			#dash_start_position = position.x
			#dash_counter = dash_counter - 1;
			#dash_direction = direction
			#dash_timer = dash_cooldown;
		if is_on_floor() :
		
			is_dashing = true
			dash_start_position = position.x
			dash_counter = dash_counter - 1;
			dash_direction = direction
			dash_timer = dash_cooldown;
	
	if is_dashing:
		player_state = state.DASHING
		var current_distance = abs(position.x - dash_start_position)
		if(current_distance >= dash_max_distance or is_on_wall()):
			is_dashing = false;
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0;
			
	if(dash_timer > 0):
		dash_timer -= delta;
		
func wall_jump(delta):
	if(Input.is_action_just_pressed("jump")):
		if(is_on_wall() and Input.is_action_pressed("left")):
			velocity.y = wall_slide_jump_power;
			velocity.x = -wall_jump_pushback;
		if(is_on_wall() and Input.is_action_pressed("right")):
			velocity.y = wall_slide_jump_power;
			velocity.x = wall_jump_pushback;
	
func wall_sliding(delta):
	if(is_on_wall() and !is_on_floor()):
		
		if(Input.is_action_pressed("left") or Input.is_action_pressed("right")):
			if(!is_wall_sliding):
				velocity.y = 0
			is_wall_sliding = true;
			can_wall_jump = true;
		else:
			is_wall_sliding = false;
			can_wall_jump = false;
	else:
		is_wall_sliding = false;
		can_wall_jump = false;

	if(is_wall_sliding):
	
		velocity.y += (wall_slide_gravity * delta);
		velocity.y = min(velocity.y, wall_slide_gravity)
	
func get_my_gravity(my_velocity: Vector2):
	#if(my_velocity.y < 0):
		#return  GRAVITY
	#return FALL_GRAVITY
	return  GRAVITY
