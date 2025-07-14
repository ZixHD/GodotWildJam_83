extends CharacterBody2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var player: CharacterBody2D = $"../Player"


const PATROL_SPEED = 150.0
@export_range(150, 500) var CHASE_SPEED
enum state {IDLE, RUNNING, CONSUMED, ATTACKING, DEAD}
var entity_state = state.IDLE
var start_position: Vector2i = Vector2i.ZERO
var spotted_player = false

func _update_animation():
	match(entity_state):
		state.IDLE:
			print("Idle")
		state.RUNNING:
			print("Running")
		state.CONSUMED:
			print("Consumed")
		state.ATTACKING:
			print("ATTACKING")
		state.DEAD:
			print("DEAD")


func _ready() -> void:
	print("ready")
	start_position = self.global_position
	
func _process(delta: float) -> void:
	
	if entity_state != state.DEAD:
		_moving(delta)
	#_update_animation()
	
func _moving(delta: float) -> void:
	if velocity.x == 0:
		entity_state = state.IDLE
	elif velocity.x >= 0 or velocity.x <= 0:
		entity_state = state.RUNNING
		
	if ray_cast_2d.is_colliding():
		spotted_player = true
		
	if(spotted_player):
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * PATROL_SPEED
		move_and_slide()
	
