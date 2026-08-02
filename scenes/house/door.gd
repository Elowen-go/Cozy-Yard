extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var interactable_component: Interactablecomponent = $Interactablecomponent

var is_open := false


func _ready() -> void:
	_set_door_open(false)


func _on_interactable_activated() -> void:
	_set_door_open(true)


func _on_interactable_deactivated() -> void:
	_set_door_open(false)


func _set_door_open(open: bool) -> void:
	if is_open == open:
		return

	is_open = open
	collision_shape_2d.set_deferred("disabled", is_open)

	if is_open:
		animated_sprite_2d.play("open_door")
	else:
		animated_sprite_2d.play("close_door")
