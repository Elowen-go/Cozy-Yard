extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var movement_speed := 50.0

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	var movement_direction := GameInputEvents.movement_input(player.player_direction)
	if movement_direction == Vector2.ZERO:
		player.velocity = Vector2.ZERO
		return

	player.player_direction = movement_direction
	player.velocity = movement_direction * movement_speed
	player.move_and_slide()
	_play_walk_animation()


func _on_next_transitions() -> void:
	if GameInputEvents.is_tool_use_pressed():
		var tool_state := player.get_current_tool_state()
		if tool_state != &"":
			transition.emit(tool_state)
			return

	if not GameInputEvents.is_movement_input(player.player_direction):
		transition.emit("idle")


func _on_enter() -> void:
	_play_walk_animation()


func _on_exit() -> void:
	if player:
		player.velocity = Vector2.ZERO


func _play_walk_animation() -> void:
	if not player or not animated_sprite_2d:
		return

	var animation_name := "walk_front"
	match player.player_direction:
		Vector2.LEFT:
			animation_name = "walk_left"
		Vector2.RIGHT:
			animation_name = "walk_right"
		Vector2.UP:
			animation_name = "walk_back"
		Vector2.DOWN:
			animation_name = "walk_front"

	if animated_sprite_2d.animation != animation_name:
		animated_sprite_2d.play(animation_name)
