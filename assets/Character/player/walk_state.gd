extends NodeState

@export var player: Player
@export var animated_sprite_2D: AnimatedSprite2D
@export var speed: int = 50


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	var direction:Vector2 = GameInputEvents.movement_input()
	
	if direction == Vector2.UP:
		animated_sprite_2D.play("walk_back")
	elif direction == Vector2.DOWN:
		animated_sprite_2D.play("walk_front")
	elif direction == Vector2.LEFT:
		animated_sprite_2D.play("walk_left")
	elif direction == Vector2.RIGHT:
		animated_sprite_2D.play("walk_right")
	else:
		animated_sprite_2D.play("walk_front")

	#设置运动后的正确转向
	if direction != Vector2.ZERO:
		player.player_direction = direction
	
	#位移距离获取与移动
	player.velocity = direction * speed
	player.move_and_slide()

func _on_next_transitions() -> void:
	
	if !GameInputEvents.is_movement_input():
		transition.emit("Idle")

func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2D.stop()
