extends Sprite2D

@onready var collectable_component: CollectableComponent = $CollectableComponent


func _ready() -> void:
	collectable_component.collected.connect(_on_collected)


func _on_collected(_collectable_name: String, _collector: Player) -> void:
	queue_free()
