extends Node2D

@onready var background_music: AudioStreamPlayer = $BackgroundMusic

func _ready() -> void:
	$BackgroundMusic.play()
	var camera = $Player/Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 1488
	camera.limit_right = 1680

func _on_level_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var enemies = get_tree().get_nodes_in_group("Enemy")
		#if enemies.size() == 0:
			# No enemies left, allow exit
		body.on_level_2_end()
		var end_timer = Timer.new()
		end_timer.wait_time = 1.2
		end_timer.one_shot = true
		end_timer.autostart = true
		add_child(end_timer)
		end_timer.start()
		end_timer.timeout.connect(_transition)
	#else:
			#print("Enemies still remain! Defeat them before proceeding.")

func _transition() -> void:
	var game_manager = get_tree().get_root().get_node("Gm")
	game_manager.load_transition()
		
