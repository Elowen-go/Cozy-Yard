extends NodeState

@export var player: Player
@export var animated_sprite_2D: AnimatedSprite2D

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:

	#动画播放
	if player.player_direction == Vector2.UP:
		animated_sprite_2D.play("idle_back")
	elif player.player_direction == Vector2.DOWN:
		animated_sprite_2D.play("idle_front")
	elif player.player_direction == Vector2.LEFT:
		animated_sprite_2D.play("idle_left")
	elif player.player_direction == Vector2.RIGHT:
		animated_sprite_2D.play("idle_right")
	else:
		animated_sprite_2D.play("idle_front")
		
		
func _on_next_transitions() -> void:
	GameInputEvents.movement_input()
	
	if GameInputEvents.is_movement_input():
			transition.emit("Walk")
	if player.current_tool == DateTypes.Tools.AxeWood && GameInputEvents.use_tool():
			transition.emit("Chopping")
	if player.current_tool == DateTypes.Tools.TillGround && GameInputEvents.use_tool():
			transition.emit("Tilling")
	if player.current_tool == DateTypes.Tools.WaterCrops && GameInputEvents.use_tool():
			transition.emit("WaterCrops")

func _on_enter() -> void:
	pass


func _on_exit() -> void:
	#切换状态时，停止动画
	animated_sprite_2D.stop()
