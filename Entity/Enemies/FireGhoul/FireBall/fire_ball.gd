extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed = 300.0
const RANGE = 1000
var velocity: Vector2 = Vector2.ZERO
var travelled_distance = 0

func _process(delta: float) -> void:
	animation_player.play("default")
	position += velocity * delta
	travelled_distance += speed * delta
	if (travelled_distance > RANGE):
		queue_free()
		
	
func setup(target_position: Vector2):
	var direction = target_position - global_position
	direction.y = 0
	direction = direction.normalized()
	velocity = direction * speed
	rotation = direction.angle()
	sprite_2d.flip_h = true
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage()
		queue_free()
