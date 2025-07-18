extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed = 300.0
const RANGE = 200

var velocity: Vector2 = Vector2.ZERO
var travelled_distance = 0.0
var max_range_reached: bool = false
var start_position: Vector2 = Vector2.ZERO
var returning: bool = false
var user: String = ""


	
func _process(delta: float) -> void:
	animation_player.play("ball")
	position += velocity * delta
	travelled_distance += speed * delta
	

	if not returning and travelled_distance >= RANGE:
		max_range_reached = true
		returning = true
		velocity = (start_position - global_position).normalized() * speed
		
	
	elif returning and global_position.distance_to(start_position) <= 5:
		queue_free()
		

func setup(user: String, target_position: Vector2, start_position: Vector2):
	self.start_position = start_position
	var direction = target_position - global_position
	direction.y = 0 
	direction = direction.normalized()
	velocity = direction * speed
	rotation = direction.angle()
	sprite_2d.flip_h = true
	self.user = user
	collision_layer = 2
	collision_mask = 1
	
func setup_player(user: String, direction: Vector2, start_position: Vector2):
	self.start_position = start_position
	velocity = direction.normalized() * speed
	rotation = direction.angle()
	sprite_2d.flip_h = true
	self.user = user
	collision_layer = 1
	collision_mask = 2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and user == "Enemy":
		body.take_damage()
	elif body.is_in_group("Enemy") and user == "Player":
		body._on_hit()
	queue_free()
		
