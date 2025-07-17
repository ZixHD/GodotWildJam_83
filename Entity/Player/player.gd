extends CharacterBody2D

@onready var dust_particles_running: GPUParticles2D = $DustParticlesRunning
@onready var dust_particles_jump_left: GPUParticles2D = $DustParticlesJumpLeft
@onready var dust_particles_jump_right: GPUParticles2D = $DustParticlesJumpRight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var marker_2d_left: Marker2D = $Marker2DLeft
@onready var marker_2d_right: Marker2D = $Marker2DRight
@onready var attack_range: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var power_up_timer: Timer = $PowerUpTimer
@onready var merry_collision: CollisionShape2D = $MerryHitbox/CollisionShape2D
@onready var throwables_spawn: Marker2D = $ThrowablesSpawn
@onready var throwables_timer: Timer = $ThrowablesTimer





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
const JUMP_VELOCITY = -650.0
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
enum ghost_state {CAMERA, MERRY, FIRE, SLIME}
var player_ghost_state = ghost_state.CAMERA
var was_in_air = false;
var player_state = state.IDLE
var idle_direction: int = 0
var jumped: bool = false;
var shooting: bool = false;
var level_end_flag: bool = false;
var can_attack: bool = false;
var power_up_name: String = "";
var can_throw: bool = true;


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
		state.JUMPING:
			if jumped:
				animation_player.play("jump")
				jumped = false
		state.SHOOTING:
			if shooting:
				_update_ghost_animation()
				await animation_player.animation_finished
				player_state = state.RUNNING
				shooting = false
				point_light_2d.enabled = false
				attack_range.disabled = true
				
		state.DEAD:
			await get_tree().create_timer(1.0).timeout;
			queue_free()
			GameManager.load_retry_scene()
			print("")

func _update_ghost_animation() -> void:
	match(player_ghost_state):
		ghost_state.CAMERA:
			animation_player.play("camera")
		ghost_state.MERRY:
			animation_player.play("attack_merry")
		ghost_state.FIRE:	
			animation_player.play("fire_attack")
		ghost_state.SLIME:	
			animation_player.play("slime_attack")
			
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
	
	
	power_up_timer.wait_time = GameManager.POWER_UP_TIMER
	power_up_timer.one_shot = true
	power_up_timer.autostart = false;
	power_up_timer.timeout.connect(on_power_expired)
	
	
	throwables_timer.wait_time = 0.5
	throwables_timer.one_shot = false
	throwables_timer.autostart = false;
	throwables_timer.timeout.connect(_on_throw)
	throwables_timer.start()
	
	

func on_level_end() -> void:
	level_end_flag = true
	player_state = state.IDLE
	
func _physics_process(delta: float) -> void:
	if !level_end_flag:
		if player_state != state.DEAD and player_state != state.SHOOTING:
			_moving(delta)
		_attack()
	_update_animation()

func _moving(delta: float) -> void:
	if is_on_floor():
		can_attack = true
		if velocity.x == 0:
			if player_state != state.DASHING and player_state != state.SHOOTING:
				player_state = state.IDLE;
		elif velocity.x <= 0 or velocity.x >= 0:
			if player_state != state.DASHING and player_state != state.SHOOTING:
				player_state = state.RUNNING;
			
	elif not is_on_floor() :
		velocity.y += get_my_gravity(velocity) * delta
		
	
	
	#wall_sliding(delta)
		
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
		
		velocity.y += 980.0 * delta
		player_state = state.DASHING
		collision_layer = 2 
		collision_mask = 4 | 5

		var current_distance = abs(position.x - dash_start_position)
		if(current_distance >= dash_max_distance or is_on_wall()):
			is_dashing = false;
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0;
	else:
		self.collision_layer = 1
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

func _attack() -> void:
	if Input.is_action_just_pressed("click") and player_state != state.DASHING and can_attack and can_throw:
		player_ghost_state = ghost_state.SLIME
		match(player_ghost_state):
			null:
				_camera_shoot()
			ghost_state.MERRY:
				print("merri")
				_merry_attack()
			ghost_state.FIRE:
				_fire_attack()
			ghost_state.SLIME:	
				_slime_attack()
		shooting = true
		player_state = state.SHOOTING
		
func _camera_shoot() -> void:
	point_light_2d.enabled = true
	attack_range.disabled = false;
	if !is_on_floor():
		can_attack = false
	if sprite_2d.is_flipped_h():
		point_light_2d.global_position = marker_2d_right.global_position 
		point_light_2d.rotation_degrees = 270.0
		attack_range.global_position = point_light_2d.global_position 
	elif !sprite_2d.is_flipped_h():
		point_light_2d.global_position = marker_2d_left.global_position 
		point_light_2d.rotation_degrees = 90.0 
		attack_range.global_position = point_light_2d.global_position 
		
func _merry_attack() -> void:
	if !is_on_floor():
		can_attack = false
	if sprite_2d.is_flipped_h():
		merry_collision.global_position.x = self.global_position.x + 42.0
	elif !sprite_2d.is_flipped_h():
		merry_collision.global_position.x = self.global_position.x - 42.0

func _fire_attack() -> void:
	if !is_on_floor():
		can_attack = false
	const FIRE_BALL = preload("res://Entity/Enemies/FireGhoul/FireBall/fire_ball.tscn")
	var fire_ball = FIRE_BALL.instantiate()
	print("fire", fire_ball)
	get_tree().current_scene.add_child(fire_ball)
	fire_ball.global_position = throwables_spawn.global_position
	fire_ball.global_rotation = throwables_spawn.global_rotation
	var direction: Vector2 = Vector2.ZERO
	
	if sprite_2d.is_flipped_h():
		throwables_spawn.global_position.x = self.global_position.x + 42.0
		direction = Vector2.RIGHT
	elif !sprite_2d.is_flipped_h():
		throwables_spawn.global_position.x = self.global_position.x - 42.0
		direction = Vector2.LEFT
		
	if self:
		fire_ball.setup_player("Player", direction) 
	can_throw = false
	
func _slime_attack() -> void:
	if !is_on_floor():
		can_attack = false
	const SLIME_BALL = preload("res://Entity/Enemies/SlimeGhoul/SlimeBall/slime_ball.tscn")
	var slime_ball = SLIME_BALL.instantiate()
	get_tree().current_scene.add_child(slime_ball)
	slime_ball.global_position = throwables_spawn.global_position
	slime_ball.global_rotation = throwables_spawn.global_rotation
	var direction: Vector2 = Vector2.ZERO
	
	if sprite_2d.is_flipped_h():
		throwables_spawn.global_position.x = self.global_position.x + 42.0
		direction = Vector2.RIGHT
	elif !sprite_2d.is_flipped_h():
		throwables_spawn.global_position.x = self.global_position.x - 42.0
		direction = Vector2.LEFT
		
	if self:
		slime_ball.setup_player("Player", direction, throwables_spawn.global_position) 
	can_throw = false

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body._stunned()
		await get_tree().create_timer(0.25).timeout
		var mat := sprite_2d.material as ShaderMaterial
		mat.set_shader_parameter("apply", 1.0)
		power_up_name = body.get_id()
		_attack_change(power_up_name)
		power_up_timer.start()

func take_damage() -> void:
	#queue_free()
	var explosion_scene = preload("res://Assets/Effects/Particles/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	player_state = state.DEAD
	var particles: CPUParticles2D = explosion.get_node("CPUParticles2D")
	particles.emitting = true
	particles.color = Color(255, 0, 0)
	sprite_2d.visible = false

func on_power_expired() -> void:
	var mat := sprite_2d.material as ShaderMaterial
	mat.set_shader_parameter("apply", 0.0)
	player_ghost_state = ghost_state.CAMERA

func _attack_change(power_up: String) -> void:
	match(power_up):
		"Merry":
			player_ghost_state = ghost_state.MERRY
		"Fire":
			player_ghost_state = ghost_state.FIRE
		"Slime":
			player_ghost_state = ghost_state.SLIME


func _on_merry_hibtox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body._on_hit()
	
func _on_throw() -> void:
	can_throw = true
