extends NodeState

@export var chicken: Chicken
@export var animated_sprite_2d: AnimatedSprite2D

var idle_elapsed := 0.0
@export var idle_duration := 1.5


func _on_process(_delta : float) -> void:
	idle_elapsed += _delta
	if animated_sprite_2d and animated_sprite_2d.animation != &"idle":
		animated_sprite_2d.play(&"idle")


func _on_physics_process(_delta : float) -> void:
	pass


func _on_next_transitions() -> void:
	if not chicken:
		return

	if chicken.movement_direction != Vector2.ZERO:
		transition.emit("walk")
		return

	if idle_elapsed >= idle_duration and chicken.set_random_navigation_target():
		transition.emit("walk")


func _on_enter() -> void:
	idle_elapsed = 0.0
	if animated_sprite_2d:
		animated_sprite_2d.play(&"idle")


func _on_exit() -> void:
	pass
