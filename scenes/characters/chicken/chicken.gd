class_name Chicken
extends CharacterBody2D

@export_range(0.0, 500.0, 0.1) var min_movement_speed := 18.0
@export_range(0.0, 500.0, 0.1) var max_movement_speed := 30.0

var movement_speed := 25.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var movement_direction := Vector2.ZERO
var chicken_direction := Vector2.DOWN
var has_navigation_target := false


func _ready() -> void:
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 6.0


func set_navigation_target(target_position: Vector2) -> void:
	navigation_agent.target_position = target_position
	has_navigation_target = true


func set_random_navigation_target() -> bool:
	var navigation_map := navigation_agent.get_navigation_map()
	if not navigation_map.is_valid():
		return false

	var random_position := NavigationServer2D.map_get_random_point(
		navigation_map,
		navigation_agent.navigation_layers,
		false
	)
	var speed_min := minf(min_movement_speed, max_movement_speed)
	var speed_max := maxf(min_movement_speed, max_movement_speed)
	movement_speed = randf_range(speed_min, speed_max)
	set_navigation_target(random_position)
	return true


func get_navigation_direction() -> Vector2:
	if not has_navigation_target or navigation_agent.is_navigation_finished():
		return Vector2.ZERO

	return global_position.direction_to(navigation_agent.get_next_path_position())


func clear_navigation_target() -> void:
	has_navigation_target = false
	movement_direction = Vector2.ZERO


func set_movement_direction(direction: Vector2) -> void:
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	movement_direction = direction
	if direction != Vector2.ZERO:
		chicken_direction = direction
