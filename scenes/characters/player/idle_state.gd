extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	var movement_direction := GameInputEvents.movement_input(player.player_direction)
	if movement_direction != Vector2.ZERO:
		player.player_direction = movement_direction

	_play_idle_animation()

func _on_next_transitions() -> void:
	if GameInputEvents.is_tool_use_pressed():
		var tool_state := player.get_current_tool_state()
		if tool_state != &"":
			transition.emit(tool_state)
			return

	if GameInputEvents.is_movement_input(player.player_direction):
		transition.emit("walk")


func _on_enter() -> void:
	_play_idle_animation()


func _on_exit() -> void:
	pass


func _play_idle_animation() -> void:
	if not player or not animated_sprite_2d:
		return

	var animation_name := "idle_front"
	match player.player_direction:
		Vector2.LEFT:
			animation_name = "idle_left"
		Vector2.RIGHT:
			animation_name = "idle_right"
		Vector2.UP:
			animation_name = "idle_back"
		Vector2.DOWN:
			animation_name = "idle_front"

	if animated_sprite_2d.animation != animation_name:
		animated_sprite_2d.play(animation_name)
