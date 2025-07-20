extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var slime_ball_spawn: Marker2D = $SlimeBallSpawn


const PATROL_SPEED = 150.0
@export_range(150, 500) var CHASE_SPEED

enum state {IDLE, RUNNING, CONSUMED, ATTACKING, DEAD}
var entity_state = state.IDLE
var start_position: Vector2i = Vector2i.ZERO
var spotted_player: bool = false
var in_range: bool = false;
var attacking: bool = false;
var can_attack: bool = false;
var stunned: bool = false;

signal attack_player

func _update_animation():
	match(entity_state):
		state.IDLE:
			animation_player.play("idle")
		state.RUNNING:
			animation_player.play("walk")
		state.CONSUMED:
			print("Consumed")
		state.ATTACKING:
			animation_player.play("attack")
			await animation_player.animation_finished
			entity_state = state.RUNNING
			attacking = false;
		state.DEAD:
			print("DEAD")

	
func get_id() -> String:
	return "Slime"

func _ready() -> void:
	
	attack_timer.start()
	attack_timer.wait_time = 2.0
	attack_timer.autostart = true;
	attack_timer.one_shot = false;
	attack_timer.timeout.connect(_attack_check)
	
func _process(delta: float) -> void:
	if entity_state != state.ATTACKING and entity_state != state.DEAD and !in_range:
		_moving(delta)
	if player:
		sprite_2d.flip_h = player.global_position.x > global_position.x
		if sprite_2d.is_flipped_h():
			ray_cast_2d.global_rotation_degrees = 270.0
		else:
			ray_cast_2d.global_rotation_degrees = 90.06
	_in_range_check()
	_attack()
	_update_animation()

func _moving(delta: float) -> void:
	
	if velocity.x == 0:
		entity_state = state.IDLE
	elif velocity.x >= 0 or velocity.x <= 0:
		entity_state = state.RUNNING
		
	if stunned:
		velocity.x = 0
		entity_state = state.IDLE
		await get_tree().create_timer(2.5).timeout
		stunned = false
	velocity.y += 980.0 * delta
	if spotted_player and player and !stunned:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * PATROL_SPEED
		move_and_slide()
		
		
func _attack() -> void:
	if in_range and !attacking and can_attack and !stunned:
		entity_state = state.ATTACKING
		const SLIME_BALL = preload("res://Entity/Enemies/SlimeGhoul/SlimeBall/slime_ball.tscn")
		var slime_ball = SLIME_BALL.instantiate()
		if player:
			get_tree().current_scene.add_child(slime_ball)
		slime_ball.global_position = slime_ball_spawn.global_position
		slime_ball.global_rotation = slime_ball_spawn.global_rotation
		if player:
			slime_ball.setup("Enemy", player.global_position, slime_ball_spawn.global_position)
		attacking = true
		can_attack = false
		
		
func _in_range_check() -> void:
	if ray_cast_2d.is_colliding():
		spotted_player = true
		if !attacking:
			in_range = true
	else:
		in_range = false
		
func _attack_check() -> void:
	if in_range:
		can_attack = true
	
func _on_hit() -> void:
	var explosion_scene = preload("res://Assets/Effects/Particles/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	entity_state = state.DEAD
	var particles: CPUParticles2D = explosion.get_node("CPUParticles2D")
	particles.emitting = true
	#play_explosion, wait 0.25 sec, then delete
	queue_free()
	
func _stunned() -> void:
	stunned = true
