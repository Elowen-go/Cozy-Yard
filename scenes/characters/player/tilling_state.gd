extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var hit_component: HitComponent
@export var hit_component_collision_shape: CollisionShape2D
@export var action_duration := 0.6

var elapsed_time := 0.0


func _ready() -> void:
	if hit_component_collision_shape:
		hit_component_collision_shape.set_deferred("disabled", true)
		hit_component_collision_shape.position = Vector2.ZERO


func _on_process(delta: float) -> void:
	elapsed_time += delta


func _on_physics_process(_delta: float) -> void:
	pass


func _on_next_transitions() -> void:
	if elapsed_time >= action_duration:
		transition.emit("idle")


func _on_enter() -> void:
	elapsed_time = 0.0
	if not player or not animated_sprite_2d:
		return

	var animation_name := "tilling_front"
	match player.player_direction:
		Vector2.LEFT:
			animation_name = "tilling_left"
		Vector2.RIGHT:
			animation_name = "tilling_right"
		Vector2.UP:
			animation_name = "tilling_back"
		Vector2.DOWN:
			animation_name = "tilling_front"

	_update_hit_area()
	animated_sprite_2d.play(animation_name)


func _on_exit() -> void:
	_set_hit_area_enabled(false)
	elapsed_time = 0.0


func _update_hit_area() -> void:
	if not player or not hit_component or not hit_component_collision_shape:
		return

	hit_component_collision_shape.position = _get_hit_position(player.player_direction)
	hit_component.current_tool = player.current_tool
	hit_component.clear_hit_targets()
	hit_component_collision_shape.set_deferred("disabled", false)
	hit_component.set_deferred("monitoring", true)


func _set_hit_area_enabled(enabled: bool) -> void:
	if hit_component_collision_shape:
		hit_component_collision_shape.set_deferred("disabled", not enabled)
	if hit_component:
		hit_component.set_deferred("monitoring", enabled)


func _get_hit_position(direction: Vector2) -> Vector2:
	match direction:
		Vector2.LEFT:
			return Vector2(-9, -1)
		Vector2.RIGHT:
			return Vector2(9, -1)
		Vector2.UP:
			return Vector2(0, -18)
		_:
			return Vector2(0, 3)
