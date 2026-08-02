class_name CollectableComponent
extends Area2D

signal collected(collectable_name: String, collector: Player)

@export var collectable_name: String


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	set_deferred("monitoring", false)
	collected.emit(collectable_name, body as Player)
