extends CharacterBody2D

@onready var dust_particles_running: GPUParticles2D = $DustParticlesRunning
@onready var dust_particles_jump_left: GPUParticles2D = $DustParticlesJumpLeft
@onready var dust_particles_jump_right: GPUParticles2D = $DustParticlesJumpRight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1

@export_range(0, 1) var acceleration = 0.1;
@export_range(0, 1) var deceleration = 0.1;


#DASH
@export var dash_speed = 500.0
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
var was_in_air = false;
var player_state = state.IDLE
var idle_direction: int = 0
var jumped: bool = false;
signal hit


func _update_animation() -> void:

	match(player_state):
		state.IDLE:
			sprite_2d.flip_h = idle_direction
			animation_player.play("idle")
		state.RUNNING:
			animation_player.play("run")
			await animation_player.animation_finished
		state.DASHING:
			animation_player.play("roll")
			await animation_player.animation_finished
			player_state = state.RUNNING
			print("Dashing")
		state.JUMPING:
			if jumped:
				animation_player.play("jump")
				print("ovde")
				jumped = false
				#print("Jumping")
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
	
	
	var running_dust_timer = Timer.new()
	running_dust_timer.wait_time = 0.25
	running_dust_timer.one_shot = false
	running_dust_timer.autostart = true
	add_child(running_dust_timer)
	running_dust_timer.timeout.connect(_spawn_dust)

func _physics_process(delta: float) -> void:
	if player_state != state.DEAD:
		_moving(delta)
	_update_animation()

func _moving(delta: float) -> void:
	if is_on_floor():
		if velocity.x == 0:
			if player_state != state.DASHING:
				player_state = state.IDLE;
		elif velocity.x <= 0 or velocity.x >= 0:
			if player_state != state.DASHING:
				player_state = state.RUNNING;
			
	elif not is_on_floor() :
		velocity.y += get_my_gravity(velocity) * delta
		
	
	
	wall_sliding(delta)
		
	if is_on_floor():
		reached_jump_peak = false
		dash_counter = MAX_AIR_DASH;
		if not coyote_jump_timer.is_stopped():
			
			coyote_jump_timer.stop()
	
	wall_jump(delta)	
	
	if(velocity.x != 0):
		idle_direction = velocity.x > 0
		sprite_2d.flip_h = idle_direction
		dust_particles_running.position.x = 0  

	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			player_state = state.JUMPING
		else:
			jump_buffer_timer.start(jump_buffer_time);
			
	if is_on_floor() and jump_buffer_timer.time_left > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer.stop()
		
	if !is_on_floor() and !was_in_air:
		was_in_air = true
		player_state = state.JUMPING
		jumped = true
	elif is_on_floor() and was_in_air:
		was_in_air = false
		_spawn_jump_dust()


	var direction := Input.get_axis("left", "right")
		
	if direction:
		if(!is_on_floor()):
			velocity.x = move_toward(velocity.x, direction * AIR_SPEED, AIR_SPEED)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED)
		
	else:
		if(!is_on_floor()):
			velocity.x = move_toward(velocity.x, 0, AIR_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	var was_on_floor = is_on_floor();
	

	if(was_on_floor && !is_on_floor() and coyote_jump_timer.is_stopped()) :
		coyote_jump_timer.start(coyote_time);
		
	#DASH
	dashing(direction, delta)
	move_and_slide()
	
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
		collision_shape_2d.disabled = true
		var current_distance = abs(position.x - dash_start_position)
		if(current_distance >= dash_max_distance or is_on_wall()):
			is_dashing = false;
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0;
	else:
		collision_shape_2d.disabled = false;
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

func _spawn_dust() -> void:
	if player_state == state.RUNNING and is_on_floor():
		dust_particles_running.restart()
		dust_particles_running.emitting = true

func _spawn_jump_dust() -> void:
	dust_particles_jump_left.restart()
	dust_particles_jump_left.emitting = true
	dust_particles_jump_right.restart()
	dust_particles_jump_right.emitting = true;
