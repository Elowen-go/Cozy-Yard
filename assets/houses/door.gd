extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var interactable_component = $InteractableComponent

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_avtivated)
	interactable_component.interactable_deactivated.connect(on_interactable_deavtivated)
	collision_layer = 1
	
func on_interactable_avtivated() -> void:
		animated_sprite_2d.play("open_door")
		print("已激活")
		collision_layer = 2
	
func on_interactable_deavtivated() ->void:
		animated_sprite_2d.play("close_door")
		print("取消激活")
		collision_layer = 1
