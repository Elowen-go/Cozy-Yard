extends NodeState

@export var chicken: Chicken
@export var animated_sprite_2d: AnimatedSprite2D

var is_navigation_active := false


func _ready() -> void:
	if chicken and not chicken.navigation_agent.velocity_computed.is_connected(_on_safe_velocity_computed):
		chicken.navigation_agent.velocity_computed.connect(_on_safe_velocity_computed)


func _on_process(_delta : float) -> void:
	if animated_sprite_2d and animated_sprite_2d.animation != &"walk":
		animated_sprite_2d.play(&"walk")


func _on_physics_process(_delta : float) -> void:
	if not chicken:
		return

	var navigation_direction := chicken.get_navigation_direction()
	if navigation_direction == Vector2.ZERO:
		is_navigation_active = false
		chicken.navigation_agent.velocity = Vector2.ZERO
		chicken.clear_navigation_target()
		chicken.velocity = Vector2.ZERO
		return

	chicken.set_movement_direction(navigation_direction)
	var desired_velocity := navigation_direction * chicken.movement_speed
	is_navigation_active = true

	if chicken.navigation_agent.avoidance_enabled:
		chicken.navigation_agent.velocity = desired_velocity
	else:
		_on_safe_velocity_computed(desired_velocity)


func _on_next_transitions() -> void:
	if chicken and not chicken.has_navigation_target:
		transition.emit("idle")


func _on_enter() -> void:
	is_navigation_active = true
	if animated_sprite_2d:
		animated_sprite_2d.play(&"walk")


func _on_exit() -> void:
	is_navigation_active = false
	if chicken:
		chicken.velocity = Vector2.ZERO


func _on_safe_velocity_computed(safe_velocity: Vector2) -> void:
	if not is_navigation_active or not chicken:
		return

	chicken.velocity = safe_velocity
	chicken.move_and_slide()
