extends CharacterBody2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var player: CharacterBody2D = $"../../Player"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_box: CollisionShape2D = $HitBox/CollisionShape2D
@onready var attack_range: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D



const PATROL_SPEED = 150.0
@export_range(150, 500) var CHASE_SPEED

enum state {IDLE, RUNNING, CONSUMED, ATTACKING, DEAD}
var entity_state = state.IDLE
var start_position: Vector2i = Vector2i.ZERO
var spotted_player: bool = false
var in_range: bool = false;
var attacking: bool = false;

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
			#attack_range.disabled = true;
			animation_player.play("attack")
			await animation_player.animation_finished
			entity_state = state.RUNNING
			#attack_range.disabled = false;
			attacking = false;
		
		state.DEAD:
			print("DEAD")


func _ready() -> void:
	print("ready")
	start_position = self.global_position

func _process(delta: float) -> void:
	
	if entity_state != state.ATTACKING and entity_state != state.DEAD:
		_moving(delta)
	_attack()
	_update_animation()
	
func _moving(delta: float) -> void:
	if velocity.x == 0:
		entity_state = state.IDLE
	elif velocity.x >= 0 or velocity.x <= 0:
		entity_state = state.RUNNING
		
	if ray_cast_2d.is_colliding():
		spotted_player = true
	if player:
		sprite_2d.flip_h = player.global_position.x > global_position.x
	if sprite_2d.is_flipped_h():
		hit_box.global_position.x = self.global_position.x + 55.0
	else:
		hit_box.global_position.x = self.global_position.x - 55.0
	
	velocity.y += 980.0 * delta
	
	if spotted_player and player:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * PATROL_SPEED
		move_and_slide()
	
func _on_hit() -> void:
	print("WOOOOOD")
	var explosion_scene = preload("res://Assets/Effects/Particles/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	entity_state = state.DEAD
	var particles: CPUParticles2D = explosion.get_node("CPUParticles2D")
	particles.emitting = true
	#play_explosion, wait 0.25 sec, then delete
	queue_free()

func _attack() -> void:
	if in_range and !attacking :
		entity_state = state.ATTACKING
		attacking = true
	
func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and !attacking:
		print("In range")
		in_range = true

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage()

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_range = false

func _leap_to_player() -> void:
	if !in_range:
		self.global_position = player.global_position - Vector2(-100, 0)
		
	
